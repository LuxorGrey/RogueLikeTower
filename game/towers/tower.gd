class_name Tower
extends Node2D

signal attack_fired(target: Enemy, damage: int)
signal stats_changed(level: int)

const ELEVATION_PIXEL_OFFSET: float = 18.0
const SCAN_INTERVAL: float = 0.1
const SHOT_FLASH_DURATION: float = 0.12
const RANGE_COLOR: Color = Color(0.30, 0.80, 1.0, 0.48)
const SHOT_COLOR: Color = Color(1.0, 0.91, 0.46, 0.96)
const DAMAGE_PACKET_SCRIPT: Script = preload("res://game/combat/damage_packet.gd")
const SAWBLADE_SCRIPT: Script = preload("res://game/towers/sawblade_projectile.gd")
const DAMAGE_TAG_PHYSICAL: int = 1
const DAMAGE_TAG_FIRE: int = 2
const DAMAGE_TAG_ARCANE: int = 4
const DAMAGE_TAG_POISON: int = 8

var cell_coord: Vector2i = Vector2i.ZERO
var elevation: int = 0
var level: int = 1
var last_error: String = ""

var _tower_data: TowerData
var _damage_service: Node
var _run_economy: Node
var _run_card_service: Node
var _hex_radius: float = 52.0
var _is_selected: bool = false
var _current_target: Enemy
var _targeting_mode: int = TowerData.TargetingMode.FIRST_PROGRESS
var _scan_timer: float = 0.0
var _attack_cooldown: float = 0.0
var _shot_flash_timer: float = 0.0
var _shot_target_position: Vector2 = Vector2.ZERO
var _shot_target_positions: Array[Vector2] = []
var _turret_angle: float = -PI * 0.5
var _is_mana_blocked: bool = false

func configure(
	tower_data: TowerData,
	coord: Vector2i,
	cell_elevation: int,
	map_origin: Vector2,
	hex_radius: float,
	damage_service: Node,
	run_economy: Node = null,
	run_card_service: Node = null
) -> bool:
	last_error = ""
	if tower_data == null or damage_service == null or hex_radius <= 0.0 or cell_elevation < 0 or cell_elevation > 2:
		last_error = "La torre recibió datos inválidos o no tiene DamageService."
		return false
	var errors := tower_data.validate()
	if not errors.is_empty():
		last_error = "; ".join(errors)
		return false
	_tower_data = tower_data
	_damage_service = damage_service
	_run_economy = run_economy
	_run_card_service = run_card_service
	if _run_card_service != null and _run_card_service.has_signal("modifiers_changed"):
		_run_card_service.connect(&"modifiers_changed", _on_run_card_modifiers_changed)
	cell_coord = coord
	elevation = cell_elevation
	_hex_radius = hex_radius
	_targeting_mode = tower_data.targeting_mode
	global_position = map_origin + HexMath.axial_to_world(
		HexCoord.new(coord.x, coord.y),
		hex_radius
	) - Vector2(0.0, float(cell_elevation) * ELEVATION_PIXEL_OFFSET)
	queue_redraw()
	return true

func _on_run_card_modifiers_changed() -> void:
	_scan_timer = 0.0
	queue_redraw()
	stats_changed.emit(level)

func set_selected(is_selected: bool) -> void:
	_is_selected = is_selected
	queue_redraw()

func set_targeting_mode(mode: int) -> bool:
	if _tower_data == null:
		return false
	if mode < TowerData.TargetingMode.FIRST_PROGRESS or mode > TowerData.TargetingMode.HIGHEST_ARMOR:
		return false
	_targeting_mode = mode
	_current_target = null
	_scan_timer = 0.0
	return true

func upgrade() -> bool:
	if _tower_data == null or level >= _tower_data.max_level:
		return false
	level += 1
	stats_changed.emit(level)
	queue_redraw()
	return true

func get_tower_data() -> TowerData:
	return _tower_data

func get_next_upgrade_cost() -> int:
	if _tower_data == null:
		return -1
	return _tower_data.get_upgrade_cost(level)

func get_mana_cost_per_attack() -> float:
	return get_current_mana_cost()

func is_mana_blocked() -> bool:
	return _is_mana_blocked

func get_current_target() -> Enemy:
	return _current_target

func get_current_damage() -> int:
	if _tower_data == null:
		return 0
	var damage: float = float(_tower_data.base_damage + (level - 1) * _tower_data.upgrade_damage_per_level)
	if _run_card_service != null and is_instance_valid(_run_card_service):
		damage += float(_run_card_service.call("get_tower_damage_add", _tower_data.id, _tower_data.damage_tags))
		damage *= float(_run_card_service.call("get_tower_damage_multiplier", _tower_data.id, _tower_data.damage_tags))
	return maxi(roundi(damage), 0)

func get_current_mana_cost() -> float:
	if _tower_data == null:
		return 0.0
	var mana_cost: float = _tower_data.mana_cost_per_attack
	if _run_card_service != null and is_instance_valid(_run_card_service):
		mana_cost *= float(_run_card_service.call("get_tower_mana_cost_multiplier", _tower_data.id))
	return maxf(mana_cost, 0.0)

func create_damage_packet() -> RefCounted:
	var packet: RefCounted = DAMAGE_PACKET_SCRIPT.new()
	if _tower_data == null:
		return packet
	packet.set("raw_damage", float(get_current_damage()))
	packet.set("source_id", get_instance_id())
	packet.set("damage_tags", _tower_data.damage_tags)
	packet.set("armor_multiplier", _tower_data.armor_multiplier)
	var health_multiplier: float = _tower_data.health_multiplier
	if _tower_data.attack_pattern == TowerData.AttackPattern.SAWBLADE:
		health_multiplier = 0.0
	packet.set("health_multiplier", health_multiplier)
	packet.set("regen_counter_strength", _tower_data.regen_counter_strength)
	packet.set("regen_counter_duration", _tower_data.regen_counter_duration)
	var status_payloads: Array[Resource] = []
	for status_effect in _tower_data.status_effects:
		if status_effect == null:
			continue
		var runtime_effect: Resource = status_effect.duplicate(true)
		if _run_card_service != null and is_instance_valid(_run_card_service):
			var duration_multiplier: float = float(_run_card_service.call(
				"get_status_duration_multiplier",
				_tower_data.id,
				StringName(runtime_effect.get("id"))
			))
			runtime_effect.set("duration", minf(float(runtime_effect.get("duration")) * duration_multiplier, 60.0))
		status_payloads.append(runtime_effect)
	packet.set("status_payloads", status_payloads)
	return packet

func get_current_attack_rate() -> float:
	if _tower_data == null:
		return 0.0
	var attack_rate: float = _tower_data.attack_rate + (level - 1) * _tower_data.upgrade_attack_rate_per_level
	if _run_card_service != null and is_instance_valid(_run_card_service):
		attack_rate *= float(_run_card_service.call("get_tower_attack_rate_multiplier", _tower_data.id))
	return maxf(attack_rate, 0.0)

func get_current_range_hexes() -> float:
	if _tower_data == null:
		return 0.0
	var range_hexes: float = (
		_tower_data.range_hexes
		+ (level - 1) * _tower_data.upgrade_range_per_level
		+ elevation * _tower_data.height_range_bonus_per_level
	)
	if _run_card_service != null and is_instance_valid(_run_card_service):
		range_hexes += float(_run_card_service.call("get_tower_range_add", _tower_data.id))
	return maxf(range_hexes, 0.0)

func get_current_area_radius_hexes() -> float:
	if _tower_data == null:
		return 0.0
	var radius: float = _tower_data.attack_area_radius_hexes
	if _run_card_service != null and is_instance_valid(_run_card_service):
		radius += float(_run_card_service.call("get_tower_area_radius_add", _tower_data.id))
	return maxf(radius, 0.0)

func get_current_range_pixels() -> float:
	var neighbor_distance: float = HexMath.axial_to_world(HexCoord.new(1, 0), _hex_radius).length()
	return get_current_range_hexes() * neighbor_distance

func get_targeting_mode() -> int:
	return _targeting_mode

func get_summary() -> String:
	if _tower_data == null:
		return "Torre sin configurar."
	var mana_summary: String = ""
	if get_current_mana_cost() > 0.0:
		mana_summary = " · %.1f maná/ataque" % get_current_mana_cost()
	return "%s · N%d/%d · daño %d · alcance %.1f hex · cadencia %.2f/s · %s · %s%s" % [
		_tower_data.display_name,
		level,
		_tower_data.max_level,
		get_current_damage(),
		get_current_range_hexes(),
		get_current_attack_rate(),
		get_attack_pattern_name(),
		get_damage_tag_name(_tower_data.damage_tags),
		mana_summary,
	]

func get_attack_pattern_name() -> String:
	if _tower_data == null:
		return "sin ataque"
	match _tower_data.attack_pattern:
		TowerData.AttackPattern.SINGLE_TARGET:
			return "objetivo único"
		TowerData.AttackPattern.AREA:
			return "área %.2f hex" % get_current_area_radius_hexes()
		TowerData.AttackPattern.CHAIN:
			return "hasta %d objetivos" % _tower_data.max_targets
		TowerData.AttackPattern.CONE:
			return "cono %.0f°" % _tower_data.cone_angle_degrees
		TowerData.AttackPattern.SAWBLADE:
			return "hoja perforante · sangrado"
		_:
			return "desconocido"

func get_damage_tag_name(tags: int) -> String:
	var names := PackedStringArray()
	if (tags & DAMAGE_TAG_PHYSICAL) != 0:
		names.append("físico")
	if (tags & DAMAGE_TAG_FIRE) != 0:
		names.append("fuego")
	if (tags & DAMAGE_TAG_ARCANE) != 0:
		names.append("arcano")
	if (tags & DAMAGE_TAG_POISON) != 0:
		names.append("veneno")
	return " + ".join(names) if not names.is_empty() else "sin tipo"

func get_targeting_mode_name(mode: int = -1) -> String:
	var active_mode: int = _targeting_mode if mode < 0 else mode
	match active_mode:
		TowerData.TargetingMode.FIRST_PROGRESS:
			return "más avanzado"
		TowerData.TargetingMode.LAST_PROGRESS:
			return "menos avanzado"
		TowerData.TargetingMode.HIGHEST_HEALTH:
			return "más vida"
		TowerData.TargetingMode.HIGHEST_ARMOR:
			return "más armadura"
		_:
			return "Desconocido"

func _physics_process(delta: float) -> void:
	if _tower_data == null:
		return
	if _shot_flash_timer > 0.0:
		_shot_flash_timer = maxf(_shot_flash_timer - delta, 0.0)
		queue_redraw()
	if RunManager.phase != RunManager.Phase.COMBAT:
		return
	if _current_target != null and not is_instance_valid(_current_target):
		_current_target = null
		_is_mana_blocked = false
		_scan_timer = 0.0
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_acquire_target()
		_scan_timer = SCAN_INTERVAL
	if _current_target == null:
		_is_mana_blocked = false
		return
	if not _is_target_in_range(_current_target):
		_current_target = null
		_is_mana_blocked = false
		return
	_turret_angle = global_position.direction_to(_current_target.global_position).angle()
	_attack_cooldown = maxf(_attack_cooldown - delta, 0.0)
	if _attack_cooldown <= 0.0:
		_fire_at_target()

func _acquire_target() -> void:
	var best_target: Enemy
	for node in get_tree().get_nodes_in_group(&"enemies"):
		var candidate := node as Enemy
		if candidate == null or not is_instance_valid(candidate):
			continue
		if candidate.state != Enemy.State.MOVING or not _is_target_in_range(candidate):
			continue
		if best_target == null or _target_precedes(candidate, best_target):
			best_target = candidate
	_current_target = best_target

func _target_precedes(candidate: Enemy, incumbent: Enemy) -> bool:
	match _targeting_mode:
		TowerData.TargetingMode.FIRST_PROGRESS:
			if not is_equal_approx(candidate.get_route_progress(), incumbent.get_route_progress()):
				return candidate.get_route_progress() > incumbent.get_route_progress()
		TowerData.TargetingMode.LAST_PROGRESS:
			if not is_equal_approx(candidate.get_route_progress(), incumbent.get_route_progress()):
				return candidate.get_route_progress() < incumbent.get_route_progress()
		TowerData.TargetingMode.HIGHEST_HEALTH:
			if candidate.get_current_health() != incumbent.get_current_health():
				return candidate.get_current_health() > incumbent.get_current_health()
		TowerData.TargetingMode.HIGHEST_ARMOR:
			if candidate.get_armor_value() != incumbent.get_armor_value():
				return candidate.get_armor_value() > incumbent.get_armor_value()
	return candidate.get_instance_id() < incumbent.get_instance_id()

func _is_target_in_range(target: Enemy) -> bool:
	if target == null or not is_instance_valid(target) or target.state != Enemy.State.MOVING:
		return false
	var effective_range: float = get_current_range_pixels()
	return global_position.distance_squared_to(target.global_position) <= effective_range * effective_range

func _fire_at_target() -> void:
	if _damage_service == null or not _is_target_in_range(_current_target):
		return
	var mana_cost: float = get_current_mana_cost()
	if mana_cost > 0.0 and _run_economy != null:
		if not bool(_run_economy.call("try_spend_mana", mana_cost)):
			_is_mana_blocked = true
			_attack_cooldown = 0.25
			return
	_is_mana_blocked = false
	var target: Enemy = _current_target
	_attack_cooldown = 1.0 / maxf(get_current_attack_rate(), 0.001)
	if _tower_data.attack_pattern == TowerData.AttackPattern.SAWBLADE:
		if not _launch_sawblade(target):
			_attack_cooldown = 0.25
			return
		_shot_target_position = target.global_position - global_position
		_shot_target_positions = [_shot_target_position]
		_shot_flash_timer = SHOT_FLASH_DURATION
		attack_fired.emit(target, get_current_damage())
		queue_redraw()
		return
	var packet: RefCounted = create_damage_packet()
	var targets: Array[Enemy] = _get_attack_targets(target)
	var did_hit: bool = false
	_shot_target_positions.clear()
	for affected_target in targets:
		if affected_target == null or not is_instance_valid(affected_target):
			continue
		if affected_target.state != Enemy.State.MOVING:
			continue
		var result: Variant = _damage_service.call("apply_damage", affected_target, packet)
		if result == null or not bool(result.get("is_valid")):
			continue
		var target_offset: Vector2 = affected_target.global_position - global_position
		_shot_target_positions.append(target_offset)
		if not did_hit:
			_shot_target_position = target_offset
			did_hit = true
		attack_fired.emit(affected_target, int(result.get("health_damage")))
	if not did_hit:
		return
	_shot_flash_timer = SHOT_FLASH_DURATION
	queue_redraw()

func _get_attack_targets(primary_target: Enemy) -> Array[Enemy]:
	var targets: Array[Enemy] = [primary_target]
	match _tower_data.attack_pattern:
		TowerData.AttackPattern.SINGLE_TARGET:
			return targets
		TowerData.AttackPattern.AREA:
			var radius: float = get_current_area_radius_hexes() * _hex_neighbor_distance()
			var radius_squared: float = radius * radius
			for node in get_tree().get_nodes_in_group(&"enemies"):
				var candidate := node as Enemy
				if candidate == null or not is_instance_valid(candidate) or candidate == primary_target:
					continue
				if candidate.state == Enemy.State.MOVING and candidate.global_position.distance_squared_to(primary_target.global_position) <= radius_squared:
					targets.append(candidate)
			return targets
		TowerData.AttackPattern.CHAIN:
			var candidates: Array[Enemy] = []
			for node in get_tree().get_nodes_in_group(&"enemies"):
				var candidate := node as Enemy
				if candidate == null or not is_instance_valid(candidate) or candidate == primary_target:
					continue
				if candidate.state == Enemy.State.MOVING and _is_target_in_range(candidate):
					candidates.append(candidate)
			candidates.sort_custom(func(a: Enemy, b: Enemy) -> bool:
				return primary_target.global_position.distance_squared_to(a.global_position) < primary_target.global_position.distance_squared_to(b.global_position)
			)
			for index in mini(candidates.size(), _tower_data.max_targets - 1):
				targets.append(candidates[index])
			return targets
		TowerData.AttackPattern.CONE:
			var forward: Vector2 = global_position.direction_to(primary_target.global_position)
			var half_angle: float = deg_to_rad(_tower_data.cone_angle_degrees * 0.5)
			var range_squared: float = get_current_range_pixels() * get_current_range_pixels()
			for node in get_tree().get_nodes_in_group(&"enemies"):
				var candidate := node as Enemy
				if candidate == null or not is_instance_valid(candidate) or candidate == primary_target:
					continue
				if candidate.state != Enemy.State.MOVING:
					continue
				var offset: Vector2 = candidate.global_position - global_position
				if offset.length_squared() <= range_squared and absf(forward.angle_to(offset.normalized())) <= half_angle:
					targets.append(candidate)
	return targets

func _launch_sawblade(target: Enemy) -> bool:
	if target == null or not is_instance_valid(target) or not target.has_method("get_remaining_route_waypoints"):
		return false
	var route: Array[Vector2] = target.call("get_remaining_route_waypoints")
	if route.size() < 2:
		return false
	var projectile := SAWBLADE_SCRIPT.new() as Node2D
	if projectile == null:
		return false
	var entities: Node = get_parent()
	if entities == null:
		projectile.free()
		return false
	entities.add_child(projectile)
	if not bool(projectile.call(
		"configure",
		global_position,
		route,
		create_damage_packet(),
		_damage_service,
		_tower_data.projectile_speed,
		_tower_data.projectile_hit_radius,
		_tower_data.pierce_damage_loss_per_hit
	)):
		projectile.queue_free()
		return false
	return true

func _hex_neighbor_distance() -> float:
	return HexMath.axial_to_world(HexCoord.new(1, 0), _hex_radius).length()

func _draw() -> void:
	if _tower_data == null:
		return
	if _is_selected:
		draw_arc(Vector2.ZERO, get_current_range_pixels(), 0.0, TAU, 72, RANGE_COLOR, 2.0, true)
	var pedestal := PackedVector2Array([
		Vector2(-16.0, -2.0),
		Vector2(-11.0, -12.0),
		Vector2(11.0, -12.0),
		Vector2(16.0, -2.0),
		Vector2(10.0, 5.0),
		Vector2(-10.0, 5.0),
	])
	var body_color: Color = _tower_data.visual_color
	var dark_color: Color = body_color.darkened(0.55)
	var light_color: Color = body_color.lightened(0.4)
	draw_colored_polygon(pedestal, dark_color)
	var turret_center := Vector2(0.0, -19.0)
	draw_circle(turret_center, 12.0, body_color)
	match _tower_data.visual_archetype:
		TowerData.VisualArchetype.BALLISTA:
			draw_arc(turret_center, 13.0, -PI * 0.5, PI * 0.5, 16, light_color, 3.0, true)
			draw_line(turret_center + Vector2(-11.0, 0.0), turret_center + Vector2(11.0, 0.0), dark_color, 2.0, true)
			draw_line(turret_center, turret_center + Vector2.RIGHT.rotated(_turret_angle) * 21.0, light_color, 2.0, true)
		TowerData.VisualArchetype.MORTAR:
			draw_line(turret_center, turret_center + Vector2.RIGHT.rotated(_turret_angle) * 22.0, dark_color, 9.0, true)
			draw_line(turret_center, turret_center + Vector2.RIGHT.rotated(_turret_angle) * 19.0, light_color, 4.0, true)
		TowerData.VisualArchetype.TESLA:
			draw_circle(turret_center, 5.0, light_color)
			draw_line(turret_center + Vector2(-8.0, -8.0), turret_center + Vector2(-8.0, -18.0), light_color, 2.0, true)
			draw_line(turret_center + Vector2(0.0, -8.0), turret_center + Vector2(0.0, -22.0), light_color, 2.0, true)
			draw_line(turret_center + Vector2(8.0, -8.0), turret_center + Vector2(8.0, -18.0), light_color, 2.0, true)
			draw_polyline(PackedVector2Array([turret_center + Vector2(-4.0, -21.0), turret_center + Vector2(2.0, -16.0), turret_center + Vector2(-2.0, -11.0), turret_center + Vector2(5.0, -7.0)]), Color.WHITE, 2.0, true)
		TowerData.VisualArchetype.FROST:
			for spoke in 3:
				var direction := Vector2.RIGHT.rotated(float(spoke) * PI / 3.0)
				draw_line(turret_center - direction * 10.0, turret_center + direction * 10.0, light_color, 2.5, true)
				draw_line(turret_center + direction * 5.0, turret_center + direction.rotated(0.7) * 9.0, light_color, 1.5, true)
				draw_line(turret_center + direction * 5.0, turret_center + direction.rotated(-0.7) * 9.0, light_color, 1.5, true)
		TowerData.VisualArchetype.FLAME:
			draw_colored_polygon(PackedVector2Array([turret_center + Vector2(-7.0, 1.0), turret_center + Vector2(-3.0, -12.0), turret_center + Vector2(1.0, -7.0), turret_center + Vector2(6.0, -20.0), turret_center + Vector2(8.0, -3.0)]), light_color)
			draw_circle(turret_center + Vector2(0.0, 1.0), 4.0, Color(1.0, 0.55, 0.16))
		TowerData.VisualArchetype.POISON:
			draw_rect(Rect2(turret_center + Vector2(-7.0, -10.0), Vector2(14.0, 17.0)), dark_color)
			draw_rect(Rect2(turret_center + Vector2(-4.0, -15.0), Vector2(8.0, 5.0)), light_color)
			draw_circle(turret_center + Vector2(0.0, -2.0), 4.0, body_color.lightened(0.2))
		TowerData.VisualArchetype.SHREDDER:
			var teeth := PackedVector2Array()
			for tooth in 16:
				var angle: float = float(tooth) * TAU / 16.0 + _turret_angle
				var radius: float = 12.0 if tooth % 2 == 0 else 8.0
				teeth.append(turret_center + Vector2.RIGHT.rotated(angle) * radius)
			draw_colored_polygon(teeth, light_color)
			draw_circle(turret_center, 4.0, dark_color)
	if _shot_flash_timer > 0.0:
		for target_offset in _shot_target_positions:
			draw_line(turret_center, target_offset, SHOT_COLOR, 2.0, true)
