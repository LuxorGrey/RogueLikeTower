class_name WaveDirector
extends Node

signal wave_started(round_number: int)
signal wave_completed(round_number: int)
signal wave_failed(reason: String)
signal enemy_count_changed(alive_count: int)
signal base_damaged(amount: int, current_health: int, maximum_health: int)

var last_error: String = ""
var _wave_data: WaveData
var _path_graph: PathGraph
var _base: GameBase
var _entities: Node2D
var _damage_service: Node
var _map_origin: Vector2 = Vector2.ZERO
var _hex_radius: float = 52.0
var _active_enemies: Dictionary[int, Enemy] = {}
var _is_running: bool = false
var _is_spawning: bool = false
var _wave_token: int = 0

func get_alive_enemy_count() -> int:
	return _active_enemies.size()

func start_wave(
	wave_data: WaveData,
	path_graph: PathGraph,
	base: GameBase,
	entities: Node2D,
	map_origin: Vector2,
	hex_radius: float,
	damage_service: Node = null
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
	_map_origin = map_origin
	_hex_radius = hex_radius
	_wave_token += 1
	_is_running = true
	_is_spawning = true
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
		for enemy_index in range(group.count):
			if wave_token != _wave_token:
				return
			var route := _select_route(group, enemy_index)
			if route == null or not _spawn_enemy(group.enemy_data, route):
				_fail_wave("No se pudo generar un enemigo con una ruta válida.")
				return
			if enemy_index + 1 < group.count and group.spawn_interval > 0.0:
				await get_tree().create_timer(group.spawn_interval).timeout
				if wave_token != _wave_token:
					return

	_is_spawning = false
	_check_wave_completion()

func _select_route(group: WaveEnemyGroupData, enemy_index: int) -> PathRoute:
	var available_routes: Array[PathRoute] = []
	for route in _path_graph.routes:
		if route.is_reachable:
			available_routes.append(route)
	if available_routes.is_empty():
		return null
	if group.spawn_endpoint_policy == WaveEnemyGroupData.SpawnEndpointPolicy.ROUND_ROBIN:
		return available_routes[posmod(enemy_index, available_routes.size())]
	return available_routes[0]

func _spawn_enemy(enemy_data: EnemyData, route: PathRoute) -> bool:
	if route == null or not route.is_reachable or route.cells.is_empty():
		return false
	if route.base_endpoint == null or route.cells.back() != route.base_endpoint.cell_coord:
		return false
	if enemy_data == null or enemy_data.scene == null:
		return false
	var enemy := enemy_data.scene.instantiate() as Enemy
	if enemy == null:
		return false
	_entities.add_child(enemy)
	if not enemy.configure(enemy_data, route, _map_origin, _hex_radius, _damage_service):
		enemy.queue_free()
		return false
	var enemy_id: int = enemy.get_instance_id()
	_active_enemies[enemy_id] = enemy
	enemy.reached_base.connect(_on_enemy_reached_base.bind(enemy_id))
	enemy.defeated.connect(_on_enemy_defeated.bind(enemy_id))
	enemy_count_changed.emit(_active_enemies.size())
	return true

func _on_enemy_reached_base(base_damage: int, enemy_id: int) -> void:
	if not _active_enemies.has(enemy_id):
		return
	_active_enemies.erase(enemy_id)
	var applied_damage: int = _base.apply_damage(base_damage)
	base_damaged.emit(applied_damage, _base.get_current_health(), _base.get_maximum_health())
	enemy_count_changed.emit(_active_enemies.size())
	if _base.get_current_health() <= 0:
		_fail_wave("La base ha sido destruida.")
		return
	_check_wave_completion()

func _on_enemy_defeated(enemy_id: int) -> void:
	if not _active_enemies.has(enemy_id):
		return
	_active_enemies.erase(enemy_id)
	enemy_count_changed.emit(_active_enemies.size())
	_check_wave_completion()

func _check_wave_completion() -> void:
	if not _is_running or _is_spawning or not _active_enemies.is_empty():
		return
	_is_running = false
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
	enemy_count_changed.emit(0)
	wave_failed.emit(reason)
