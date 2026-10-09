class_name WaveDirector
extends Node

enum RewardReason { ENEMY_KILL, ROUND_CLEAR }

signal wave_started(round_number: int)
signal wave_completed(round_number: int)
signal wave_failed(reason: String)
signal enemy_count_changed(alive_count: int)
signal population_changed(pending_count: int, alive_count: int)
signal base_damaged(amount: int, current_health: int, maximum_health: int)
signal reward_earned(amount: int, reason: int)

var last_error: String = ""
var _wave_data: WaveData
var _path_graph: PathGraph
var _base: GameBase
var _entities: Node2D
var _damage_service: Node
var _campaign_data: Resource
var _is_diagnostic: bool = false
var _map_origin: Vector2 = Vector2.ZERO
var _hex_radius: float = 52.0
var _active_enemies: Dictionary[int, Enemy] = {}
var _kill_rewards: Dictionary[int, int] = {}
var _pending_spawn_count: int = 0
var _is_running: bool = false
var _is_spawning: bool = false
var _wave_token: int = 0
var _campaign_spawn_index: int = 0
var _ability_runtime: Dictionary[int, Dictionary] = {}

func _process(delta: float) -> void:
	if not _is_running or delta <= 0.0:
		return
	for enemy_id_variant in _active_enemies.keys():
		var enemy_id: int = int(enemy_id_variant)
		var enemy: Enemy = _active_enemies.get(enemy_id) as Enemy
		if enemy == null or not is_instance_valid(enemy) or enemy.state != Enemy.State.MOVING:
			continue
		var enemy_data: EnemyData = enemy.get_enemy_data()
		var runtime: Dictionary = _ability_runtime.get(enemy_id, {})
		var timers: Dictionary = runtime.get("periodic_timers", {})
		var triggered: Dictionary = runtime.get("triggered", {})
		for ability_index in range(enemy_data.abilities.size()):
			var ability: EnemyAbilityData = enemy_data.abilities[ability_index]
			if ability.trigger == EnemyAbilityData.Trigger.NEAR_BASE:
				if not bool(triggered.get(ability_index, false)) and enemy.get_remaining_route_steps() <= ability.near_base_hexes:
					triggered[ability_index] = true
					if not _execute_enemy_ability(ability, enemy):
						_fail_wave("Falló una habilidad activada cerca de la base.")
						return
			elif ability.trigger == EnemyAbilityData.Trigger.PERIODIC:
				var time_left: float = float(timers.get(ability_index, ability.interval)) - delta
				if time_left <= 0.0:
					time_left += ability.interval
					if not _execute_enemy_ability(ability, enemy):
						_fail_wave("Falló una habilidad periódica de enemigo.")
						return
				timers[ability_index] = time_left
		_ability_runtime[enemy_id] = runtime

func get_alive_enemy_count() -> int:
	return _active_enemies.size()

func get_pending_spawn_count() -> int:
	return _pending_spawn_count

func start_wave(
	wave_data: WaveData,
	path_graph: PathGraph,
	base: GameBase,
	entities: Node2D,
	map_origin: Vector2,
	hex_radius: float,
	damage_service: Node = null,
	campaign_data: Resource = null,
	diagnostic_mode: bool = false
) -> bool:
	last_error = ""
	if _is_running:
		last_error = "Ya hay una oleada en curso."
		return false
	if wave_data == null or path_graph == null or base == null or entities == null:
		last_error = "Faltan datos para iniciar la oleada."
		return false
	var wave_errors := wave_data.validate()
	if not wave_errors.is_empty():
		last_error = "; ".join(wave_errors)
		return false
	if not path_graph.is_valid or path_graph.routes.is_empty():
		last_error = "El grafo PATH no tiene rutas válidas hacia la base."
		return false
	if base.get_current_health() <= 0 or hex_radius <= 0.0:
		last_error = "La base debe seguir activa y el radio hexagonal debe ser positivo."
		return false

	_wave_data = wave_data
	_path_graph = path_graph
	_base = base
	_entities = entities
	_damage_service = damage_service
	_campaign_data = campaign_data
	_is_diagnostic = diagnostic_mode
	_map_origin = map_origin
	_hex_radius = hex_radius
	_pending_spawn_count = 0
	_campaign_spawn_index = 0
	for group in wave_data.groups:
		_pending_spawn_count += group.count
	_wave_token += 1
	_is_running = true
	_is_spawning = true
	_emit_population_changed()
	wave_started.emit(wave_data.round_number)
	_spawn_wave_groups(_wave_token)
	return true

func _spawn_wave_groups(wave_token: int) -> void:
	for group in _wave_data.groups:
		if wave_token != _wave_token:
			return
		if group.delay_before_group > 0.0:
			await get_tree().create_timer(group.delay_before_group).timeout
			if wave_token != _wave_token:
				return
		for pulse_index in range(group.count):
			if wave_token != _wave_token:
				return
			var route: PathRoute = _select_campaign_route(group) if _campaign_data != null else _select_route(group, pulse_index)
			if route == null:
				_fail_wave("No hay salidas PATH alcanzables para generar enemigos.")
				return
			if wave_token != _wave_token:
				return
			_pending_spawn_count = maxi(_pending_spawn_count - 1, 0)
			_emit_population_changed()
			if not _spawn_enemy(group.enemy_data, route):
				_fail_wave("No se pudo generar un enemigo con una ruta válida.")
				return
			if pulse_index + 1 < group.count and group.spawn_interval > 0.0:
				await get_tree().create_timer(group.spawn_interval).timeout
				if wave_token != _wave_token:
					return

	_is_spawning = false
	_emit_population_changed()
	_check_wave_completion()

func _select_route(group: WaveEnemyGroupData, enemy_index: int) -> PathRoute:
	var available_routes: Array[PathRoute] = _get_reachable_routes()
	if available_routes.is_empty():
		return null
	if group.spawn_endpoint_policy == WaveEnemyGroupData.SpawnEndpointPolicy.ROUND_ROBIN:
		return available_routes[posmod(enemy_index, available_routes.size())]
	return available_routes[0]

func _select_campaign_route(group: WaveEnemyGroupData) -> PathRoute:
	var available_routes: Array[PathRoute] = _get_reachable_routes()
	if available_routes.is_empty():
		return null
	var selected_route: PathRoute = available_routes[posmod(_campaign_spawn_index, available_routes.size())]
	_campaign_spawn_index += 1
	return selected_route

func _get_spawn_routes(group: WaveEnemyGroupData, pulse_index: int) -> Array[PathRoute]:
	if _campaign_data != null:
		return _get_reachable_routes()
	var routes: Array[PathRoute] = []
	var route: PathRoute = _select_route(group, pulse_index)
	if route != null:
		routes.append(route)
	return routes

func _get_reachable_routes() -> Array[PathRoute]:
	var available_routes: Array[PathRoute] = []
	if _path_graph == null:
		return available_routes
	for route in _path_graph.routes:
		if route != null and route.is_reachable:
			available_routes.append(route)
	return available_routes

func _spawn_enemy(
	enemy_data: EnemyData,
	route: PathRoute,
	spawn_position: Vector2 = Vector2.ZERO,
	remaining_waypoints: Array[Vector2] = [],
	use_spawn_position_override: bool = false,
	health_override: int = 0,
	armor_override: int = -1,
	shield_override: int = -1,
	move_speed_override: float = 0.0
) -> bool:
	if route == null or not route.is_reachable or route.cells.is_empty():
		return false
	if route.base_endpoint == null or route.cells.back() != route.base_endpoint.cell_coord:
		return false
	if enemy_data == null or enemy_data.scene == null:
		return false
	var configured_enemy_data: EnemyData = enemy_data
	if _campaign_data != null:
		var scaled_data: Variant = _campaign_data.call("scale_enemy_for_round", enemy_data, _wave_data.round_number)
		if not (scaled_data is EnemyData):
			return false
		configured_enemy_data = scaled_data as EnemyData
	if health_override > 0 or armor_override >= 0 or shield_override >= 0 or move_speed_override > 0.0:
		var overridden_data: EnemyData = configured_enemy_data.duplicate(true) as EnemyData
		if overridden_data == null:
			return false
		if health_override > 0:
			overridden_data.max_health = health_override
		if armor_override >= 0:
			overridden_data.armor = armor_override
		if shield_override >= 0:
			overridden_data.shield = shield_override
		if move_speed_override > 0.0:
			overridden_data.move_speed = move_speed_override
		configured_enemy_data = overridden_data
	var enemy := configured_enemy_data.scene.instantiate() as Enemy
	if enemy == null:
		return false
	_entities.add_child(enemy)
	if not enemy.configure(
		configured_enemy_data,
		route,
		_map_origin,
		_hex_radius,
		_damage_service,
		spawn_position,
		remaining_waypoints,
		use_spawn_position_override
	):
		enemy.queue_free()
		return false
	var enemy_id: int = enemy.get_instance_id()
	_active_enemies[enemy_id] = enemy
	_kill_rewards[enemy_id] = configured_enemy_data.kill_reward if not _is_diagnostic else 0
	enemy.reached_base.connect(_on_enemy_reached_base.bind(enemy_id))
	enemy.defeated.connect(_on_enemy_defeated.bind(enemy_id))
	enemy.armor_depleted.connect(_on_enemy_armor_depleted)
	enemy.shield_depleted.connect(_on_enemy_shield_depleted)
	var periodic_timers: Dictionary = {}
	var triggered: Dictionary = {}
	for ability_index in range(configured_enemy_data.abilities.size()):
		var ability: EnemyAbilityData = configured_enemy_data.abilities[ability_index]
		triggered[ability_index] = false
		if ability.trigger == EnemyAbilityData.Trigger.PERIODIC:
			periodic_timers[ability_index] = ability.interval
	_ability_runtime[enemy_id] = {"periodic_timers": periodic_timers, "triggered": triggered}
	enemy_count_changed.emit(_active_enemies.size())
	_emit_population_changed()
	for ability_index in range(configured_enemy_data.abilities.size()):
		var ability: EnemyAbilityData = configured_enemy_data.abilities[ability_index]
		if ability.trigger == EnemyAbilityData.Trigger.ON_SPAWN:
			if not _execute_enemy_ability(ability, enemy):
				return false
	return true

func _on_enemy_reached_base(base_damage: int, enemy_id: int) -> void:
	if not _active_enemies.has(enemy_id):
		return
	_active_enemies.erase(enemy_id)
	_kill_rewards.erase(enemy_id)
	var applied_damage: int = 0
	if not _is_diagnostic:
		applied_damage = _base.apply_damage(base_damage)
		base_damaged.emit(applied_damage, _base.get_current_health(), _base.get_maximum_health())
	enemy_count_changed.emit(_active_enemies.size())
	_emit_population_changed()
	if not _is_diagnostic and _base.get_current_health() <= 0:
		_fail_wave("La base ha sido destruida.")
		return
	_check_wave_completion()

func _on_enemy_defeated(enemy_id: int) -> void:
	if not _active_enemies.has(enemy_id):
		return
	var enemy: Enemy = _active_enemies[enemy_id] as Enemy
	if enemy != null and is_instance_valid(enemy):
		var enemy_data: EnemyData = enemy.get_enemy_data()
		var runtime: Dictionary = _ability_runtime.get(enemy_id, {})
		var triggered: Dictionary = runtime.get("triggered", {})
		for ability_index in range(enemy_data.abilities.size()):
			var ability: EnemyAbilityData = enemy_data.abilities[ability_index]
			if ability.trigger == EnemyAbilityData.Trigger.ON_DEATH and ability.effect == EnemyAbilityData.Effect.TRANSFORM:
				triggered[ability_index] = true
				if enemy.transform_to(ability.transform_enemy_data, ability.transformed_health_override):
					_ability_runtime[enemy_id] = runtime
					return
		for ability_index in range(enemy_data.abilities.size()):
			var ability: EnemyAbilityData = enemy_data.abilities[ability_index]
			if ability.trigger == EnemyAbilityData.Trigger.ON_DEATH and not _execute_enemy_ability(ability, enemy):
				_fail_wave("Falló una habilidad de enemigo al morir.")
				return
	_active_enemies.erase(enemy_id)
	_ability_runtime.erase(enemy_id)
	var kill_reward: int = int(_kill_rewards.get(enemy_id, 0))
	_kill_rewards.erase(enemy_id)
	if kill_reward > 0:
		reward_earned.emit(kill_reward, RewardReason.ENEMY_KILL)
	enemy_count_changed.emit(_active_enemies.size())
	_emit_population_changed()
	_check_wave_completion()

func _on_enemy_armor_depleted(enemy: Enemy) -> void:
	_execute_event_abilities(enemy, EnemyAbilityData.Trigger.ARMOR_DEPLETED)

func _on_enemy_shield_depleted(enemy: Enemy) -> void:
	_execute_event_abilities(enemy, EnemyAbilityData.Trigger.SHIELD_DEPLETED)

func _execute_event_abilities(enemy: Enemy, trigger: int) -> void:
	if enemy == null or not is_instance_valid(enemy) or enemy.state != Enemy.State.MOVING:
		return
	var enemy_data: EnemyData = enemy.get_enemy_data()
	var enemy_id: int = enemy.get_instance_id()
	for ability in enemy_data.abilities:
		if ability.trigger == trigger and not _execute_enemy_ability(ability, enemy):
			_fail_wave("Falló una habilidad activada al agotar una capa.")
			return

func _execute_enemy_ability(ability: EnemyAbilityData, source: Enemy) -> bool:
	if ability == null or source == null or not is_instance_valid(source):
		return false
	match ability.effect:
		EnemyAbilityData.Effect.HASTE:
			for target in _get_ability_targets(source, ability):
				target.apply_haste(ability.strength)
			return true
		EnemyAbilityData.Effect.FORTIFICATION:
			for target in _get_ability_targets(source, ability):
				target.apply_fortification(ability.strength)
			return true
		EnemyAbilityData.Effect.SPAWN_ENEMY:
			if ability.spawn_enemy_data == null:
				return false
			var route: PathRoute = source.get_route()
			var remaining_waypoints: Array[Vector2] = source.get_remaining_route_waypoints()
			for _spawn_index in range(ability.spawn_count):
				if not _spawn_enemy(
					ability.spawn_enemy_data,
					route,
					source.global_position,
					remaining_waypoints,
					true,
					ability.spawned_health_override,
					ability.spawned_armor_override,
					ability.spawned_shield_override,
					ability.spawned_move_speed_override
				):
					return false
			return true
		EnemyAbilityData.Effect.TRANSFORM:
			return source.transform_to(ability.transform_enemy_data, ability.transformed_health_override)
		EnemyAbilityData.Effect.TELEPORT:
			return source.teleport_forward_tiles(ability.teleport_tiles)
	return false

func _get_ability_targets(source: Enemy, ability: EnemyAbilityData) -> Array[Enemy]:
	var targets: Array[Enemy] = []
	if ability.target_policy in [EnemyAbilityData.TargetPolicy.SELF, EnemyAbilityData.TargetPolicy.SELF_AND_NEARBY_ENEMIES]:
		if source.state == Enemy.State.MOVING:
			targets.append(source)
	if ability.target_policy in [EnemyAbilityData.TargetPolicy.NEARBY_ENEMIES, EnemyAbilityData.TargetPolicy.SELF_AND_NEARBY_ENEMIES]:
		var source_coord: HexCoord = source.get_hex_coord(_map_origin, _hex_radius)
		for enemy_variant in _active_enemies.values():
			var candidate: Enemy = enemy_variant as Enemy
			if candidate == null or not is_instance_valid(candidate) or candidate == source or candidate.state != Enemy.State.MOVING:
				continue
			var candidate_coord: HexCoord = candidate.get_hex_coord(_map_origin, _hex_radius)
			if source_coord.distance_to(candidate_coord) <= ability.radius_hexes:
				targets.append(candidate)
	return targets

func _check_wave_completion() -> void:
	if not _is_running or _is_spawning or _pending_spawn_count > 0 or not _active_enemies.is_empty():
		return
	_is_running = false
	_emit_population_changed()
	if _wave_data.round_reward > 0 and not _is_diagnostic:
		reward_earned.emit(_wave_data.round_reward, RewardReason.ROUND_CLEAR)
	wave_completed.emit(_wave_data.round_number)

func _fail_wave(reason: String) -> void:
	if not _is_running:
		return
	_is_running = false
	_is_spawning = false
	_wave_token += 1
	for enemy in _active_enemies.values():
		if is_instance_valid(enemy):
			enemy.queue_free()
	_active_enemies.clear()
	_kill_rewards.clear()
	_pending_spawn_count = 0
	enemy_count_changed.emit(0)
	_emit_population_changed()
	wave_failed.emit(reason)

func _emit_population_changed() -> void:
	population_changed.emit(_pending_spawn_count, _active_enemies.size())
