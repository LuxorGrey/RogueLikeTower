class_name Tower
extends Node2D

signal attack_fired(target: Enemy, damage: int)
signal stats_changed(level: int)

const ELEVATION_PIXEL_OFFSET: float = 18.0
const SCAN_INTERVAL: float = 0.1
const SHOT_FLASH_DURATION: float = 0.12
const BASE_COLOR: Color = Color(0.28, 0.64, 0.78)
const BASE_DARK_COLOR: Color = Color(0.10, 0.28, 0.36)
const TURRET_COLOR: Color = Color(0.70, 0.87, 0.90)
const RANGE_COLOR: Color = Color(0.30, 0.80, 1.0, 0.48)
const SHOT_COLOR: Color = Color(1.0, 0.91, 0.46, 0.96)
const DAMAGE_PACKET_SCRIPT: Script = preload("res://game/combat/damage_packet.gd")
const DAMAGE_TAG_PHYSICAL: int = 1
const DAMAGE_TAG_FIRE: int = 2
const DAMAGE_TAG_ARCANE: int = 4

var cell_coord: Vector2i = Vector2i.ZERO
var elevation: int = 0
var level: int = 1
var last_error: String = ""

var _tower_data: TowerData
var _damage_service: Node
var _hex_radius: float = 52.0
var _is_selected: bool = false
var _current_target: Enemy
var _targeting_mode: int = TowerData.TargetingMode.FIRST_PROGRESS
var _scan_timer: float = 0.0
var _attack_cooldown: float = 0.0
var _shot_flash_timer: float = 0.0
var _shot_target_position: Vector2 = Vector2.ZERO
var _turret_angle: float = -PI * 0.5

func configure(
	tower_data: TowerData,
	coord: Vector2i,
	cell_elevation: int,
	map_origin: Vector2,
	hex_radius: float,
	damage_service: Node
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

func get_current_target() -> Enemy:
	return _current_target

func get_current_damage() -> int:
	if _tower_data == null:
		return 0
	return _tower_data.base_damage + (level - 1) * _tower_data.upgrade_damage_per_level

func create_damage_packet() -> RefCounted:
	var packet: RefCounted = DAMAGE_PACKET_SCRIPT.new()
	if _tower_data == null:
		return packet
	packet.set("raw_damage", float(get_current_damage()))
	packet.set("source_id", get_instance_id())
	packet.set("damage_tags", _tower_data.damage_tags)
	packet.set("armor_multiplier", _tower_data.armor_multiplier)
	packet.set("health_multiplier", _tower_data.health_multiplier)
	packet.set("regen_counter_strength", _tower_data.regen_counter_strength)
	packet.set("regen_counter_duration", _tower_data.regen_counter_duration)
	return packet

func get_current_attack_rate() -> float:
	if _tower_data == null:
		return 0.0
	return _tower_data.attack_rate + (level - 1) * _tower_data.upgrade_attack_rate_per_level

func get_current_range_hexes() -> float:
	if _tower_data == null:
		return 0.0
	return (
		_tower_data.range_hexes
		+ (level - 1) * _tower_data.upgrade_range_per_level
		+ elevation * _tower_data.height_range_bonus_per_level
	)

func get_current_range_pixels() -> float:
	var neighbor_distance: float = HexMath.axial_to_world(HexCoord.new(1, 0), _hex_radius).length()
	return get_current_range_hexes() * neighbor_distance

func get_targeting_mode() -> int:
	return _targeting_mode

func get_summary() -> String:
	if _tower_data == null:
		return "Torre sin configurar."
	return "%s · N%d/%d · daño %d · alcance %.1f hex" % [
		_tower_data.display_name,
		level,
		_tower_data.max_level,
		get_current_damage(),
		get_current_range_hexes(),
	]

func get_damage_tag_name(tags: int) -> String:
	var names := PackedStringArray()
	if (tags & DAMAGE_TAG_PHYSICAL) != 0:
		names.append("físico")
	if (tags & DAMAGE_TAG_FIRE) != 0:
		names.append("fuego")
	if (tags & DAMAGE_TAG_ARCANE) != 0:
		names.append("arcano")
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
		_scan_timer = 0.0
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_acquire_target()
		_scan_timer = SCAN_INTERVAL
	if _current_target == null:
		return
	if not _is_target_in_range(_current_target):
		_current_target = null
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
	var target: Enemy = _current_target
	var result: Variant = _damage_service.call("apply_damage", target, create_damage_packet())
	_attack_cooldown = 1.0 / maxf(get_current_attack_rate(), 0.001)
	if result == null or not bool(result.get("is_valid")):
		return
	_shot_target_position = target.global_position - global_position
	_shot_flash_timer = SHOT_FLASH_DURATION
	attack_fired.emit(target, int(result.get("health_damage")))
	queue_redraw()

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
	draw_colored_polygon(pedestal, BASE_DARK_COLOR)
	draw_circle(Vector2(0.0, -19.0), 12.0, BASE_COLOR)
	draw_circle(Vector2(0.0, -19.0), 7.0, TURRET_COLOR)
	var barrel_end: Vector2 = Vector2.RIGHT.rotated(_turret_angle) * 20.0 + Vector2(0.0, -19.0)
	draw_line(Vector2(0.0, -19.0), barrel_end, BASE_DARK_COLOR, 5.0, true)
	if _shot_flash_timer > 0.0:
		draw_line(Vector2(0.0, -19.0), _shot_target_position, SHOT_COLOR, 3.0, true)
