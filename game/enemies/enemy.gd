class_name Enemy
extends Node2D

signal health_changed(current_health: int, maximum_health: int)
signal hit_points_changed(health: int, armor: int, shield: int)
signal reached_base(base_damage: int)
signal defeated
signal state_changed(new_state: int)

enum State { UNCONFIGURED, MOVING, REACHED_BASE, DEAD }
enum HitPointLayer { HEALTH, ARMOR, SHIELD }

const BODY_COLOR: Color = Color(0.82, 0.30, 0.27)
const BODY_OUTLINE: Color = Color(0.16, 0.07, 0.07)
const HEALTH_BACK_COLOR: Color = Color(0.12, 0.13, 0.14)
const HEALTH_FILL_COLOR: Color = Color(0.36, 0.86, 0.40)
const ARMOR_FILL_COLOR: Color = Color(0.78, 0.69, 0.48)
const SHIELD_FILL_COLOR: Color = Color(0.31, 0.73, 0.98)
const DAMAGE_TEXT_COLORS: Dictionary = {
	HitPointLayer.HEALTH: Color("#ff6b68"),
	HitPointLayer.ARMOR: Color("#f2c46e"),
	HitPointLayer.SHIELD: Color("#65ceff"),
}
const ICON_CATALOG_SCRIPT: Script = preload("res://game/ui/icon_catalog.gd")
const STATUS_ICON_IDS: Dictionary = {
	"burn": &"burn",
	"slow": &"slow",
	"poison": &"poison",
	"bleed": &"bleed",
}
const HIT_JUMP_DURATION: float = 0.32
const HIT_FLASH_DURATION: float = 0.14

var state: State = State.UNCONFIGURED
var _enemy_data: EnemyData
var _body_color: Color = BODY_COLOR
var _body_radius: float = 10.0
var _regen_fraction: float = 0.0
var _armor_regen_fraction: float = 0.0
var _shield_regen_fraction: float = 0.0
var _armor_current: int = 0
var _shield_current: int = 0
var _status_speed_multiplier: float = 1.0
var _regen_counter_strength: float = 0.0
var _regen_counter_time_left: float = 0.0
var _icon_catalog: RefCounted
var _hit_jump_time_left: float = 0.0
var _hit_flash_time_left: float = 0.0
var _jump_height: float = 0.0

@onready var _health: HealthComponent = %Health
@onready var _path_follower: PathFollowerComponent = %PathFollower
@onready var _status_controller: Node = %StatusEffects

func _ready() -> void:
	_icon_catalog = ICON_CATALOG_SCRIPT.new() as RefCounted
	add_to_group(&"enemies")
	_health.health_changed.connect(_on_health_changed)
	_health.health_depleted.connect(_on_health_depleted)
	_path_follower.route_completed.connect(_on_route_completed)
	_status_controller.connect(&"status_changed", _on_status_effects_changed)

func _process(delta: float) -> void:
	if _hit_jump_time_left > 0.0 or _hit_flash_time_left > 0.0:
		_hit_jump_time_left = maxf(_hit_jump_time_left - delta, 0.0)
		_hit_flash_time_left = maxf(_hit_flash_time_left - delta, 0.0)
		var jump_progress: float = 1.0 - _hit_jump_time_left / HIT_JUMP_DURATION
		_jump_height = sin(clampf(jump_progress, 0.0, 1.0) * PI) * 10.0
		queue_redraw()
	else:
		_jump_height = 0.0
	if state != State.MOVING or _enemy_data == null or delta <= 0.0:
		return
	var active_status_ids: PackedStringArray = _status_controller.call("get_active_status_ids")
	var counter_time: float = minf(_regen_counter_time_left, delta)
	var uncountered_time: float = maxf(delta - counter_time, 0.0)
	var health_regen_amount: float = _enemy_data.regen_per_second * (
		uncountered_time + counter_time * (1.0 - _regen_counter_strength)
	)
	if _regen_counter_time_left > 0.0:
		_regen_counter_time_left = maxf(_regen_counter_time_left - delta, 0.0)
		if _regen_counter_time_left <= 0.0:
			_regen_counter_strength = 0.0
	if active_status_ids.has("bleed"):
		health_regen_amount = 0.0
	var armor_regen_amount: float = _enemy_data.armor_regen_per_second * delta
	var shield_regen_amount: float = _enemy_data.shield_regen_per_second * delta
	if active_status_ids.has("burn"):
		armor_regen_amount = 0.0
	if active_status_ids.has("poison"):
		shield_regen_amount = 0.0
	_apply_regeneration(health_regen_amount, armor_regen_amount, shield_regen_amount)

func configure(
	enemy_data: EnemyData,
	route: PathRoute,
	map_origin: Vector2,
	hex_radius: float,
	damage_service: Node = null
) -> bool:
	if not is_node_ready() or enemy_data == null or route == null:
		return false
	var data_errors := enemy_data.validate()
	if not data_errors.is_empty() or not route.is_reachable or route.spawn_endpoint == null:
		return false
	if route.cells.is_empty() or route.base_endpoint == null or hex_radius <= 0.0:
		return false
	_enemy_data = enemy_data
	_body_color = enemy_data.placeholder_color
	_body_radius = enemy_data.placeholder_radius
	_regen_fraction = 0.0
	_armor_regen_fraction = 0.0
	_shield_regen_fraction = 0.0
	_armor_current = enemy_data.armor
	_shield_current = enemy_data.shield
	_regen_counter_strength = 0.0
	_regen_counter_time_left = 0.0
	_status_controller.call("clear_all")
	_status_controller.call("configure_damage_service", damage_service)
	if not _health.initialize(enemy_data.max_health):
		return false
	var waypoints: Array[Vector2] = []
	for coord in route.cells:
		var hex_coord := HexCoord.new(coord.x, coord.y)
		waypoints.append(map_origin + HexMath.axial_to_world(hex_coord, hex_radius))
	var outside_coord: Vector2i = route.spawn_endpoint.outside_coord
	var outside_hex := HexCoord.new(outside_coord.x, outside_coord.y)
	var start_position: Vector2 = map_origin + HexMath.axial_to_world(outside_hex, hex_radius)
	if not _path_follower.configure(self, start_position, waypoints, enemy_data.move_speed):
		return false
	_change_state(State.MOVING)
	queue_redraw()
	return true

func apply_damage(amount: int) -> int:
	# Compatibilidad del smoke M5; el combate de juego debe pasar por DamageService.
	return _apply_resolved_damage(amount)

func _apply_resolved_damage(amount: int) -> int:
	if state != State.MOVING:
		return 0
	return _health.apply_damage(amount)

func _apply_layer_damage(layer_damage: Dictionary) -> Dictionary:
	var applied := {"health": 0, "armor": 0, "shield": 0}
	if state != State.MOVING:
		return applied
	var shield_damage: int = mini(maxi(int(layer_damage.get("shield", 0)), 0), _shield_current)
	if shield_damage > 0:
		_shield_current -= shield_damage
		applied["shield"] = shield_damage
	var armor_damage: int = mini(maxi(int(layer_damage.get("armor", 0)), 0), _armor_current)
	if armor_damage > 0:
		_armor_current -= armor_damage
		applied["armor"] = armor_damage
	var health_damage: int = maxi(int(layer_damage.get("health", 0)), 0)
	if health_damage > 0 and is_instance_valid(_health):
		applied["health"] = _health.apply_damage(health_damage)
	hit_points_changed.emit(get_current_health(), _armor_current, _shield_current)
	queue_redraw()
	return applied

func _apply_regeneration(health_amount: float, armor_amount: float, shield_amount: float) -> void:
	if _health.current_health < _health.maximum_health and health_amount > 0.0:
		_regen_fraction += health_amount
		var health_heal: int = int(floor(_regen_fraction))
		if health_heal > 0:
			var healed: int = _health.heal(health_heal)
			_regen_fraction = maxf(_regen_fraction - float(healed), 0.0)
			if healed < health_heal:
				_regen_fraction = 0.0
	elif _health.current_health >= _health.maximum_health:
		_regen_fraction = 0.0
	if _armor_current < _enemy_data.armor and armor_amount > 0.0:
		_armor_regen_fraction += armor_amount
		var armor_heal: int = int(floor(_armor_regen_fraction))
		if armor_heal > 0:
			var armor_restored: int = mini(armor_heal, _enemy_data.armor - _armor_current)
			_armor_current += armor_restored
			_armor_regen_fraction = maxf(_armor_regen_fraction - float(armor_restored), 0.0)
			if armor_restored < armor_heal:
				_armor_regen_fraction = 0.0
	elif _armor_current >= _enemy_data.armor:
		_armor_regen_fraction = 0.0
	if _shield_current < _enemy_data.shield and shield_amount > 0.0:
		_shield_regen_fraction += shield_amount
		var shield_heal: int = int(floor(_shield_regen_fraction))
		if shield_heal > 0:
			var shield_restored: int = mini(shield_heal, _enemy_data.shield - _shield_current)
			_shield_current += shield_restored
			_shield_regen_fraction = maxf(_shield_regen_fraction - float(shield_restored), 0.0)
			if shield_restored < shield_heal:
				_shield_regen_fraction = 0.0
	elif _shield_current >= _enemy_data.shield:
		_shield_regen_fraction = 0.0
	if health_amount > 0.0 or armor_amount > 0.0 or shield_amount > 0.0:
		hit_points_changed.emit(get_current_health(), _armor_current, _shield_current)
		queue_redraw()

func apply_regen_counter(strength: float, duration: float) -> void:
	if state != State.MOVING or strength <= 0.0 or duration <= 0.0:
		return
	_regen_counter_strength = maxf(_regen_counter_strength, clampf(strength, 0.0, 1.0))
	_regen_counter_time_left = maxf(_regen_counter_time_left, duration)

func apply_status_effect(effect_data: Resource, source_id: int, total_damage_override: int = -1) -> bool:
	if state != State.MOVING:
		return false
	return bool(_status_controller.call("apply_effect", effect_data, source_id, total_damage_override))

func set_status_speed_multiplier(multiplier: float) -> void:
	_status_speed_multiplier = clampf(multiplier, 0.05, 1.0)
	_path_follower.set_speed_multiplier(_status_speed_multiplier)

func get_current_move_speed() -> float:
	return _enemy_data.move_speed * _status_speed_multiplier if _enemy_data != null else 0.0

func get_active_status_summaries() -> PackedStringArray:
	return _status_controller.call("get_active_status_summaries")

func show_damage_feedback(layer: int, amount: int, is_critical: bool = false) -> void:
	if amount <= 0:
		return
	_hit_jump_time_left = HIT_JUMP_DURATION
	_hit_flash_time_left = HIT_FLASH_DURATION
	queue_redraw()
	var effects_parent: Node = get_parent()
	if effects_parent == null:
		return
	var popup := Label.new()
	popup.text = "−%d%s" % [amount, "!" if is_critical else ""]
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.size = Vector2(84.0, 26.0)
	popup.pivot_offset = popup.size * 0.5
	popup.z_index = 100
	popup.add_theme_font_size_override("font_size", 17 if is_critical else 15)
	popup.add_theme_color_override("font_color", DAMAGE_TEXT_COLORS.get(layer, Color.WHITE))
	popup.add_theme_color_override("font_outline_color", Color("#111820"))
	popup.add_theme_constant_override("outline_size", 3)
	effects_parent.add_child(popup)
	var initial_position: Vector2 = global_position + Vector2(-42.0, -_body_radius - 65.0)
	popup.global_position = initial_position
	var tween: Tween = popup.create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "global_position", initial_position + Vector2(0.0, -31.0), 0.58).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup, "modulate:a", 0.0, 0.58).set_delay(0.16)
	tween.chain().tween_callback(popup.queue_free)

func get_display_name() -> String:
	return _enemy_data.display_name if _enemy_data != null else "Enemigo"

func get_current_health() -> int:
	return _health.current_health

func get_maximum_health() -> int:
	return _health.maximum_health

func get_armor_value() -> int:
	return _armor_current if _enemy_data != null else 0

func get_shield_value() -> int:
	return _shield_current if _enemy_data != null else 0

func get_maximum_armor() -> int:
	return _enemy_data.armor if _enemy_data != null else 0

func get_maximum_shield() -> int:
	return _enemy_data.shield if _enemy_data != null else 0

func get_active_hit_point_layer() -> int:
	if _shield_current > 0:
		return HitPointLayer.SHIELD
	if _armor_current > 0:
		return HitPointLayer.ARMOR
	return HitPointLayer.HEALTH

func get_hit_point_value(layer: int) -> int:
	match layer:
		HitPointLayer.HEALTH:
			return get_current_health()
		HitPointLayer.ARMOR:
			return get_armor_value()
		HitPointLayer.SHIELD:
			return get_shield_value()
		_:
			return 0

func get_total_current_hit_points() -> int:
	return get_current_health() + get_armor_value() + get_shield_value()

func get_total_maximum_hit_points() -> int:
	return get_maximum_health() + get_maximum_armor() + get_maximum_shield()

func get_regen_per_second() -> float:
	return _enemy_data.regen_per_second if _enemy_data != null else 0.0

func get_armor_regen_per_second() -> float:
	if _enemy_data == null:
		return 0.0
	var statuses: PackedStringArray = _status_controller.call("get_active_status_ids")
	return 0.0 if statuses.has("burn") else _enemy_data.armor_regen_per_second

func get_shield_regen_per_second() -> float:
	if _enemy_data == null:
		return 0.0
	var statuses: PackedStringArray = _status_controller.call("get_active_status_ids")
	return 0.0 if statuses.has("poison") else _enemy_data.shield_regen_per_second

func get_regen_counter_strength() -> float:
	return _regen_counter_strength if _regen_counter_time_left > 0.0 else 0.0

func get_regen_counter_time_left() -> float:
	return _regen_counter_time_left

func get_effective_regen_per_second() -> float:
	return get_regen_per_second() * (1.0 - get_regen_counter_strength())

func get_damage_tag_multiplier(damage_tags: int) -> float:
	return _enemy_data.get_damage_tag_multiplier(damage_tags) if _enemy_data != null else 1.0

func get_route_progress() -> float:
	return _path_follower.get_progress_ratio()

func get_remaining_route_waypoints() -> Array[Vector2]:
	return _path_follower.get_remaining_route_waypoints()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, _body_radius + 2.0, Color(0.02, 0.03, 0.04, 0.28))
	draw_set_transform(Vector2(0.0, -_jump_height), 0.0, Vector2.ONE)
	draw_circle(Vector2.ZERO, _body_radius + 3.0, BODY_OUTLINE)
	var flash_ratio: float = _hit_flash_time_left / HIT_FLASH_DURATION
	var body_color: Color = _body_color.lerp(Color.WHITE, clampf(flash_ratio, 0.0, 1.0))
	draw_circle(Vector2.ZERO, _body_radius, body_color)
	draw_arc(Vector2.ZERO, _body_radius + 2.0, 0.0, TAU, 20, Color(1.0, 0.82, 0.62), 1.5, true)
	var active_status_ids: PackedStringArray = _status_controller.call("get_active_status_ids")
	if active_status_ids.has("slow"):
		draw_arc(Vector2.ZERO, 15.0, 0.0, TAU, 24, Color(0.40, 0.85, 1.0, 0.9), 2.0, true)
	if active_status_ids.has("burn"):
		draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 24, Color(1.0, 0.48, 0.18, 0.9), 2.0, true)
	if active_status_ids.has("bleed"):
		draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 24, Color(0.92, 0.31, 0.43, 0.9), 2.0, true)
	if active_status_ids.has("poison"):
		draw_arc(Vector2.ZERO, 24.0, 0.0, TAU, 24, Color(0.42, 0.88, 0.36, 0.9), 2.0, true)
	if _enemy_data == null:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	_draw_status_icons()
	_draw_hit_point_bars()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_hit_point_bars() -> void:
	var bar_width: float = maxf(_body_radius * 5.4, 68.0)
	var bar_left: float = -bar_width * 0.5
	var row_y: float = -_body_radius - 22.0
	var bar_height: float = 8.0
	var row_gap: float = 2.0
	var rows: Array[Dictionary] = [
		{"id": &"shield", "current": _shield_current, "maximum": _enemy_data.shield, "color": SHIELD_FILL_COLOR},
		{"id": &"armor", "current": _armor_current, "maximum": _enemy_data.armor, "color": ARMOR_FILL_COLOR},
		{"id": &"health", "current": _health.current_health, "maximum": _health.maximum_health, "color": HEALTH_FILL_COLOR},
	]
	var displayed_rows: int = 0
	for row in rows:
		var maximum: int = int(row["maximum"])
		if maximum <= 0:
			continue
		var current: int = int(row["current"])
		var icon_name: StringName = StringName(row["id"])
		var fill_color: Color = row["color"]
		var layer_icon: Texture2D = _icon_catalog.call("get_icon", icon_name) as Texture2D
		if layer_icon != null:
			draw_texture_rect(layer_icon, Rect2(bar_left - 17.0, row_y - 3.0, 14.0, 14.0), false)
		draw_rect(Rect2(bar_left, row_y, bar_width, bar_height), HEALTH_BACK_COLOR)
		var fill_ratio: float = clampf(float(current) / float(maximum), 0.0, 1.0)
		draw_rect(Rect2(bar_left, row_y, bar_width * fill_ratio, bar_height), fill_color)
		if icon_name == &"health":
			for segment_index in range(1, 10):
				var segment_x: float = bar_left + bar_width * float(segment_index) / 10.0
				draw_line(Vector2(segment_x, row_y), Vector2(segment_x, row_y + bar_height), Color(0.08, 0.1, 0.12, 0.78), 1.0)
		draw_rect(Rect2(bar_left, row_y, bar_width, bar_height), Color(0.92, 0.95, 0.98, 0.84), false, 0.7)
		row_y += bar_height + row_gap
		displayed_rows += 1
	if displayed_rows > 1:
		draw_rect(Rect2(bar_left - 1.5, -_body_radius - 23.5, bar_width + 3.0, float(displayed_rows) * (bar_height + row_gap) - row_gap + 3.0), Color(0.08, 0.1, 0.12, 0.74), false, 1.0)

func _draw_status_icons() -> void:
	var stacks_by_id: Dictionary = _status_controller.call("get_active_status_stacks")
	if stacks_by_id.is_empty():
		return
	var status_ids: Array = stacks_by_id.keys()
	status_ids.sort()
	var icon_size: float = 20.0
	var gap: float = 4.0
	var total_width: float = float(status_ids.size()) * icon_size + float(maxi(status_ids.size() - 1, 0)) * gap
	var start_x: float = -total_width * 0.5
	var status_y: float = -_body_radius - 48.0
	for status_id_variant in status_ids:
		var status_id: StringName = StringName(status_id_variant)
		var icon_name: StringName = STATUS_ICON_IDS.get(String(status_id), &"")
		var icon_texture: Texture2D = _icon_catalog.call("get_icon", icon_name) as Texture2D if icon_name != &"" else null
		if icon_texture != null:
			var icon_rect := Rect2(start_x, status_y, icon_size, icon_size)
			draw_texture_rect(icon_texture, icon_rect, false)
		var stacks: int = int(stacks_by_id[status_id_variant])
		if stacks > 1 and ThemeDB.fallback_font != null:
			var count_position: Vector2 = Vector2(start_x + icon_size + 1.0, status_y + icon_size + 1.0)
			draw_string(ThemeDB.fallback_font, count_position + Vector2(1.0, 1.0), str(stacks), HORIZONTAL_ALIGNMENT_RIGHT, 15.0, 12, Color("#101820"))
			draw_string(ThemeDB.fallback_font, count_position, str(stacks), HORIZONTAL_ALIGNMENT_RIGHT, 15.0, 12, Color.WHITE)
		start_x += icon_size + gap

func _on_health_changed(current_health: int, maximum_health: int) -> void:
	health_changed.emit(current_health, maximum_health)
	queue_redraw()

func _on_health_depleted() -> void:
	if state != State.MOVING:
		return
	_path_follower.stop()
	_change_state(State.DEAD)
	defeated.emit()
	queue_free()

func _on_status_effects_changed(_active_ids: PackedStringArray) -> void:
	queue_redraw()

func _on_route_completed() -> void:
	if state != State.MOVING or _enemy_data == null:
		return
	_change_state(State.REACHED_BASE)
	reached_base.emit(_enemy_data.base_damage)
	queue_free()

func _change_state(next_state: State) -> void:
	if state == next_state:
		return
	if state == State.MOVING and next_state != State.MOVING:
		_status_controller.call("clear_all")
	state = next_state
	state_changed.emit(state)
