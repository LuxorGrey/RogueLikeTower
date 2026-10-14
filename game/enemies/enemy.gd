class_name Enemy
extends Node2D

signal health_changed(current_health: int, maximum_health: int)
signal hit_points_changed(health: int, armor: int, shield: int)
signal reached_base(base_damage: int)
signal defeated
signal state_changed(new_state: int)
signal armor_depleted(enemy: Enemy)
signal shield_depleted(enemy: Enemy)

enum State { UNCONFIGURED, MOVING, REACHED_BASE, DEAD }
enum HitPointLayer { HEALTH, ARMOR, SHIELD }

const BODY_COLOR: Color = Color(0.82, 0.30, 0.27)
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
const ANIMATED_IMPACT_SCRIPT: Script = preload("res://game/vfx/animated_impact.gd")
const COZY_STATUS_ROOT: String = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/status/"
const PROJECT_FONT: Font = preload("res://assets/fonts/PatrickHand-Regular.ttf")
const STATUS_SPRITE_FILES: Dictionary = {
	&"burn": "burn.png",
	&"slow": "frost.png",
	&"poison": "poison.png",
	&"bleed": "bleed.png",
	&"haste": "buff.png",
	&"fortification": "buff.png",
	&"stun": "stun.png",
}
const HIT_JUMP_DURATION: float = 0.32
const HIT_FLASH_DURATION: float = 0.14
const VISUAL_ART_OFFSET_Y: float = 6.0
const ENEMY_OUTLINE_SHADER: Shader = preload("res://game/board/interactable_outline.gdshader")
const ENEMY_OUTLINE_SIZE_PX: float = 2.0
const ENEMY_OUTLINE_FALLBACK_COLOR: Color = Color("#e8f4ff")
const ENEMY_OUTLINE_COLORS: Dictionary = {
	&"campaign_armored_goblin": Color("#e7ffa8"),
	&"campaign_armored_orc": Color("#c5e9ff"),
	&"campaign_bat": Color("#e7c4ff"),
	&"campaign_battering_ram": Color("#ffe2b8"),
	&"campaign_blink_dog": Color("#b9f4ff"),
	&"campaign_cyclops": Color("#b5e9ff"),
	&"campaign_demon": Color("#ffb8a8"),
	&"campaign_dodecahedron": Color("#a8fff1"),
	&"campaign_fallen_oogie": Color("#fff0b0"),
	&"campaign_goblin": Color("#d8ffab"),
	&"campaign_hexahedron": Color("#dbc8ff"),
	&"campaign_icosahedron": Color("#bddaff"),
	&"campaign_imp": Color("#ffc2e1"),
	&"campaign_jack_o_lantern": Color("#ffd69c"),
	&"campaign_manticore": Color("#ffe0a1"),
	&"campaign_octahedron": Color("#d4ffa8"),
	&"campaign_oogie": Color("#fff6b0"),
	&"campaign_oogie_von_oogovich_haunted": Color("#ffd8f0"),
	&"campaign_oogiehedron": Color("#b8f1ff"),
	&"campaign_orc": Color("#d6f7c2"),
	&"campaign_succubus": Color("#ffbde5"),
	&"campaign_tetrahedron": Color("#aee7ff"),
	&"campaign_troll": Color("#aeffc8"),
	&"campaign_vampire": Color("#ffd0dd"),
	&"campaign_werewolf": Color("#d6d2ff"),
	&"campaign_witch": Color("#c8ffe8"),
	&"armored_regenerator_m7_test": Color("#d3ffb8"),
	&"cyclops_demo": Color("#a8e4ff"),
	&"status_training_dummy_m8_test": Color("#cffcff"),
	&"tower_layer_training_dummy": Color("#f1f1ff"),
	&"werewolf_demo": Color("#c3c3ff"),
}
const DAMAGE_POPUP_SIZE_MIN: int = 12
const DAMAGE_POPUP_SIZE_MAX: int = 22
const DAMAGE_POPUP_PUNCH_SCALE: float = 1.75
const DAMAGE_POPUP_PUNCH_DURATION: float = 0.18
const DAMAGE_POPUP_ARC_MID_DURATION: float = 0.2
const DAMAGE_POPUP_ARC_END_DURATION: float = 0.42

var state: State = State.UNCONFIGURED
var _enemy_data: EnemyData
var _sprite_texture: Texture2D
var _outline_sprite: Sprite2D
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
var _status_icon_sprites: Dictionary[StringName, Sprite2D] = {}
var _hit_jump_time_left: float = 0.0
var _hit_flash_time_left: float = 0.0
var _hit_flash_color: Color = Color.WHITE
var _jump_height: float = 0.0
var _damage_feedback_average: float = 0.0
var _next_damage_popup_side: int = -1
var _damage_popup_lane: int = 0
var _is_facing_left: bool = false
var _haste_strength: float = 0.0
var _fortification_strength: float = 0.0
var _route: PathRoute
var _map_origin: Vector2 = Vector2.ZERO
var _hex_radius: float = 0.0
var _damage_service: Node

const RT_STATUS_DECAY_PER_SECOND: float = 6.0
const RT_STATUS_MAX_STRENGTH: float = 60.0
const RT_FORTIFICATION_DAMAGE_REDUCTION: float = 5.0

@onready var _health: HealthComponent = %Health
@onready var _path_follower: PathFollowerComponent = %PathFollower
@onready var _status_controller: Node = %StatusEffects

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_outline_sprite = Sprite2D.new()
	_outline_sprite.name = "EnemyOutline"
	_outline_sprite.centered = true
	_outline_sprite.show_behind_parent = true
	_outline_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var outline_material := ShaderMaterial.new()
	outline_material.shader = ENEMY_OUTLINE_SHADER
	outline_material.set_shader_parameter("outline_only", true)
	outline_material.set_shader_parameter("outline_size_px", ENEMY_OUTLINE_SIZE_PX)
	_outline_sprite.material = outline_material
	add_child(_outline_sprite)
	_icon_catalog = ICON_CATALOG_SCRIPT.new() as RefCounted
	add_to_group(&"enemies")
	_health.health_changed.connect(_on_health_changed)
	_health.health_depleted.connect(_on_health_depleted)
	_path_follower.route_completed.connect(_on_route_completed)
	_path_follower.horizontal_direction_changed.connect(_on_horizontal_direction_changed)
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
	_sync_outline_sprite_position()
	if state != State.MOVING or _enemy_data == null or delta <= 0.0:
		return
	var had_rt_status: bool = _haste_strength > 0.0 or _fortification_strength > 0.0
	_haste_strength = maxf(_haste_strength - RT_STATUS_DECAY_PER_SECOND * delta, 0.0)
	_fortification_strength = maxf(_fortification_strength - RT_STATUS_DECAY_PER_SECOND * delta, 0.0)
	if had_rt_status:
		_update_move_speed_multiplier()
		queue_redraw()
	_sync_status_icon_sprites()
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
	damage_service: Node = null,
	spawn_position: Vector2 = Vector2.ZERO,
	remaining_waypoints: Array[Vector2] = [],
	use_spawn_position_override: bool = false
) -> bool:
	if not is_node_ready() or enemy_data == null or route == null:
		return false
	var data_errors := enemy_data.validate()
	if not data_errors.is_empty() or not route.is_reachable or route.spawn_endpoint == null:
		return false
	if route.cells.is_empty() or route.base_endpoint == null or hex_radius <= 0.0:
		return false
	_enemy_data = enemy_data
	_sprite_texture = enemy_data.sprite_texture
	_body_color = enemy_data.placeholder_color
	_body_radius = enemy_data.placeholder_radius
	_sync_outline_sprite()
	_regen_fraction = 0.0
	_armor_regen_fraction = 0.0
	_shield_regen_fraction = 0.0
	_armor_current = enemy_data.armor
	_shield_current = enemy_data.shield
	_regen_counter_strength = 0.0
	_regen_counter_time_left = 0.0
	_haste_strength = 0.0
	_fortification_strength = 0.0
	_status_speed_multiplier = 1.0
	_route = route
	_map_origin = map_origin
	_hex_radius = hex_radius
	_damage_service = damage_service
	_status_controller.call("clear_all")
	_status_controller.call("configure_damage_service", damage_service)
	if not _health.initialize(enemy_data.max_health):
		return false
	var waypoints: Array[Vector2] = remaining_waypoints.duplicate()
	var start_position: Vector2
	if use_spawn_position_override:
		start_position = spawn_position
	else:
		waypoints.clear()
		for coord in route.cells:
			var hex_coord := HexCoord.new(coord.x, coord.y)
			waypoints.append(map_origin + HexMath.axial_to_world(hex_coord, hex_radius))
		var outside_coord: Vector2i = route.spawn_endpoint.outside_coord
		var outside_hex := HexCoord.new(outside_coord.x, outside_coord.y)
		start_position = map_origin + HexMath.axial_to_world(outside_hex, hex_radius)
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
	var had_shield: bool = _shield_current > 0
	if shield_damage > 0:
		_shield_current -= shield_damage
		applied["shield"] = shield_damage
	var armor_damage: int = mini(maxi(int(layer_damage.get("armor", 0)), 0), _armor_current)
	var had_armor: bool = _armor_current > 0
	if armor_damage > 0:
		_armor_current -= armor_damage
		applied["armor"] = armor_damage
	var health_damage: int = maxi(int(layer_damage.get("health", 0)), 0)
	if health_damage > 0 and is_instance_valid(_health):
		applied["health"] = _health.apply_damage(health_damage)
	if had_shield and _shield_current <= 0:
		shield_depleted.emit(self)
	if had_armor and _armor_current <= 0:
		armor_depleted.emit(self)
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

func apply_status_effect(
	effect_data: Resource,
	source_id: int,
	total_damage_override: int = -1,
	strength_override: float = -1.0
) -> bool:
	if state != State.MOVING:
		return false
	return bool(_status_controller.call(
		"apply_effect",
		effect_data,
		source_id,
		total_damage_override,
		strength_override
	))

func has_status(effect_id: StringName) -> bool:
	return _status_controller != null and is_instance_valid(_status_controller) and bool(_status_controller.call("has_status", effect_id))

func get_status_strength(effect_id: StringName) -> float:
	if _status_controller == null or not is_instance_valid(_status_controller):
		return 0.0
	return float(_status_controller.call("get_status_strength", effect_id))

func consume_status_damage(effect_id: StringName, fraction: float) -> Dictionary:
	if _status_controller == null or not is_instance_valid(_status_controller):
		return {}
	return _status_controller.call("consume_status_damage", effect_id, fraction)

func set_status_speed_multiplier(multiplier: float) -> void:
	_status_speed_multiplier = clampf(multiplier, 0.05, 1.0)
	_update_move_speed_multiplier()

func apply_haste(strength: float) -> void:
	if state != State.MOVING or strength <= 0.0:
		return
	_haste_strength = minf(_haste_strength + strength, RT_STATUS_MAX_STRENGTH)
	_update_move_speed_multiplier()
	_sync_status_icon_sprites()
	queue_redraw()

func apply_fortification(strength: float) -> void:
	if state != State.MOVING or strength <= 0.0:
		return
	_fortification_strength = minf(_fortification_strength + strength, RT_STATUS_MAX_STRENGTH)
	_sync_status_icon_sprites()
	queue_redraw()

func get_fortification_damage_reduction() -> float:
	return RT_FORTIFICATION_DAMAGE_REDUCTION if _fortification_strength > 0.0 else 0.0

func get_enemy_data() -> EnemyData:
	return _enemy_data

func get_route() -> PathRoute:
	return _route

func get_remaining_route_steps() -> int:
	return _path_follower.get_remaining_waypoint_count()

func get_hex_coord(map_origin: Vector2, hex_radius: float) -> HexCoord:
	return HexMath.world_to_axial(global_position - map_origin, hex_radius)

func transform_to(enemy_data: EnemyData, health_override: int = 0) -> bool:
	if enemy_data == null or _route == null or _path_follower == null:
		return false
	var errors: PackedStringArray = enemy_data.validate()
	if not errors.is_empty():
		return false
	var remaining_waypoints: Array[Vector2] = _path_follower.get_remaining_route_waypoints()
	if remaining_waypoints.size() < 2:
		return false
	_enemy_data = enemy_data
	_sprite_texture = enemy_data.sprite_texture
	_body_color = enemy_data.placeholder_color
	_body_radius = enemy_data.placeholder_radius
	_sync_outline_sprite()
	_armor_current = enemy_data.armor
	_shield_current = enemy_data.shield
	_regen_fraction = 0.0
	_armor_regen_fraction = 0.0
	_shield_regen_fraction = 0.0
	_haste_strength = 0.0
	_fortification_strength = 0.0
	_status_speed_multiplier = 1.0
	_status_controller.call("clear_all")
	_status_controller.call("configure_damage_service", _damage_service)
	var transformed_health: int = health_override if health_override > 0 else enemy_data.max_health
	if not _health.initialize(transformed_health):
		return false
	if not _path_follower.configure(self, global_position, remaining_waypoints, enemy_data.move_speed):
		return false
	_change_state(State.MOVING)
	hit_points_changed.emit(get_current_health(), _armor_current, _shield_current)
	queue_redraw()
	return true

func get_current_move_speed() -> float:
	var haste_multiplier: float = 1.0 + _haste_strength / 100.0
	return _enemy_data.move_speed * _status_speed_multiplier * haste_multiplier if _enemy_data != null else 0.0

func get_active_status_summaries() -> PackedStringArray:
	var summaries: PackedStringArray = _status_controller.call("get_active_status_summaries")
	if _haste_strength > 0.0:
		summaries.append("Haste %d · %.1fs" % [roundi(_haste_strength), _haste_strength / RT_STATUS_DECAY_PER_SECOND])
	if _fortification_strength > 0.0:
		summaries.append("Fortification %d · %.1fs" % [roundi(_fortification_strength), _fortification_strength / RT_STATUS_DECAY_PER_SECOND])
	return summaries

func _get_all_active_status_ids() -> PackedStringArray:
	var ids: PackedStringArray = _status_controller.call("get_active_status_ids")
	if _haste_strength > 0.0:
		ids.append("haste")
	if _fortification_strength > 0.0:
		ids.append("fortification")
	ids.sort()
	return ids

func _get_all_active_status_stacks() -> Dictionary:
	var stacks: Dictionary = _status_controller.call("get_active_status_stacks")
	if _haste_strength > 0.0:
		stacks["haste"] = 1
	if _fortification_strength > 0.0:
		stacks["fortification"] = 1
	return stacks

func show_damage_feedback(layer: int, amount: int, is_critical: bool = false) -> void:
	if amount <= 0:
		return
	_hit_jump_time_left = HIT_JUMP_DURATION
	_hit_flash_time_left = HIT_FLASH_DURATION
	_hit_flash_color = DAMAGE_TEXT_COLORS.get(layer, Color.WHITE)
	queue_redraw()
	var effects_parent: Node = get_parent()
	if effects_parent == null:
		return
	var popup := Label.new()
	popup.text = "%s−%d%s" % ["CRIT " if is_critical else "", amount, "!" if is_critical else ""]
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.size = Vector2(128.0, 32.0)
	popup.pivot_offset = popup.size * 0.5
	popup.z_index = 100
	var reference_damage: float = _damage_feedback_average if _damage_feedback_average > 0.0 else float(amount)
	var relative_damage: float = clampf(float(amount) / reference_damage, 0.65, 1.8)
	var size_ratio: float = inverse_lerp(0.65, 1.8, relative_damage)
	var popup_font_size: int = roundi(lerpf(float(DAMAGE_POPUP_SIZE_MIN), float(DAMAGE_POPUP_SIZE_MAX), size_ratio))
	if is_critical:
		popup_font_size = mini(popup_font_size + 3, DAMAGE_POPUP_SIZE_MAX + 3)
	popup.add_theme_font_size_override("font_size", popup_font_size)
	popup.add_theme_color_override("font_color", DAMAGE_TEXT_COLORS.get(layer, Color.WHITE))
	popup.add_theme_color_override("font_outline_color", Color("#111820"))
	popup.add_theme_constant_override("outline_size", 4 if is_critical else 3)
	effects_parent.add_child(popup)
	var side: int = _next_damage_popup_side
	_next_damage_popup_side *= -1
	var lane: int = _damage_popup_lane
	_damage_popup_lane = (_damage_popup_lane + 1) % 3
	var initial_position: Vector2 = global_position + Vector2(
		-64.0 + float(side * 8),
		-_body_radius - 58.0 - float(lane * 9)
	)
	popup.global_position = initial_position
	popup.scale = Vector2.ONE * DAMAGE_POPUP_PUNCH_SCALE if not is_critical else Vector2.ONE * 2.0
	popup.modulate.a = 0.0
	var middle_position: Vector2 = initial_position + Vector2(float(side * 18), -25.0)
	var end_position: Vector2 = initial_position + Vector2(float(side * 42), -49.0)
	var tween: Tween = popup.create_tween().bind_node(popup)
	tween.set_parallel(true)
	tween.tween_property(popup, "modulate:a", 1.0, 0.06)
	tween.tween_property(popup, "scale", Vector2.ONE, DAMAGE_POPUP_PUNCH_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.tween_property(popup, "global_position", middle_position, DAMAGE_POPUP_ARC_MID_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup, "global_position", end_position, DAMAGE_POPUP_ARC_END_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(popup, "modulate:a", 0.0, 0.24).set_delay(0.12)
	tween.chain().tween_callback(popup.queue_free)
	_damage_feedback_average = float(amount) if _damage_feedback_average <= 0.0 else lerpf(_damage_feedback_average, float(amount), 0.12)

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

func get_layer_status_damage_bonus(layer: int) -> float:
	if _status_controller == null or not is_instance_valid(_status_controller):
		return 0.0
	var status_id: StringName = &""
	match layer:
		HitPointLayer.HEALTH:
			status_id = &"bleed"
		HitPointLayer.ARMOR:
			status_id = &"burn"
		HitPointLayer.SHIELD:
			status_id = &"poison"
		_:
			return 0.0
	return 1.0 if bool(_status_controller.call("has_status", status_id)) else 0.0

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

func teleport_forward_tiles(tile_count: int) -> bool:
	return _path_follower.advance_tiles(tile_count)

func _draw() -> void:
	draw_set_transform(Vector2(0.0, -_jump_height + VISUAL_ART_OFFSET_Y), 0.0, Vector2.ONE)
	var flash_ratio: float = _hit_flash_time_left / HIT_FLASH_DURATION
	if _sprite_texture != null:
		var sprite_extent: float = _enemy_data.sprite_extent if _enemy_data.sprite_extent > 0.0 else maxf(_body_radius * 3.2, 48.0)
		var sprite_rect := Rect2(
			Vector2(-sprite_extent * 0.5, -sprite_extent * 0.5),
			Vector2(sprite_extent, sprite_extent)
		)
		var sprite_tint: Color = Color.WHITE.lerp(_hit_flash_color, clampf(flash_ratio, 0.0, 1.0))
		draw_set_transform(Vector2(0.0, -_jump_height + VISUAL_ART_OFFSET_Y), 0.0, Vector2(-1.0, 1.0) if _is_facing_left else Vector2.ONE)
		draw_texture_rect(_sprite_texture, sprite_rect, false, sprite_tint)
		draw_set_transform(Vector2(0.0, -_jump_height + VISUAL_ART_OFFSET_Y), 0.0, Vector2.ONE)
	else:
		var outline_color: Color = _get_enemy_outline_color()
		draw_circle(Vector2.ZERO, _body_radius + 3.0, outline_color)
		var body_color: Color = _body_color.lerp(_hit_flash_color, clampf(flash_ratio, 0.0, 1.0))
		draw_circle(Vector2.ZERO, _body_radius, body_color)
		draw_arc(Vector2.ZERO, _body_radius + 2.0, 0.0, TAU, 20, outline_color, 1.5, true)
	var active_status_ids: PackedStringArray = _get_all_active_status_ids()
	if active_status_ids.has("slow"):
		draw_arc(Vector2.ZERO, 15.0, 0.0, TAU, 24, Color(0.40, 0.85, 1.0, 0.9), 2.0, true)
	if active_status_ids.has("burn"):
		draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 24, Color(1.0, 0.48, 0.18, 0.9), 2.0, true)
	if active_status_ids.has("bleed"):
		draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 24, Color(0.92, 0.31, 0.43, 0.9), 2.0, true)
	if active_status_ids.has("poison"):
		draw_arc(Vector2.ZERO, 24.0, 0.0, TAU, 24, Color(0.42, 0.88, 0.36, 0.9), 2.0, true)
	if active_status_ids.has("haste"):
		draw_arc(Vector2.ZERO, 27.0, 0.0, TAU, 24, Color(0.35, 0.77, 1.0, 0.9), 2.0, true)
	if active_status_ids.has("fortification"):
		draw_arc(Vector2.ZERO, 30.0, 0.0, TAU, 24, Color(0.92, 0.73, 0.33, 0.9), 2.0, true)
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
	var stacks_by_id: Dictionary = _get_all_active_status_stacks()
	if stacks_by_id.is_empty():
		return
	var status_ids: Array = stacks_by_id.keys()
	status_ids.sort()
	var icon_size: float = 22.0
	var gap: float = 4.0
	var total_width: float = float(status_ids.size()) * icon_size + float(maxi(status_ids.size() - 1, 0)) * gap
	var start_x: float = -total_width * 0.5
	var status_y: float = -_body_radius - 48.0
	for status_id_variant in status_ids:
		var stacks: int = int(stacks_by_id[status_id_variant])
		if stacks > 1:
			var count_position: Vector2 = Vector2(start_x + icon_size + 1.0, status_y + icon_size + 1.0)
			draw_string(PROJECT_FONT, count_position, str(stacks), HORIZONTAL_ALIGNMENT_RIGHT, 15.0, 12, Color.WHITE)
		start_x += icon_size + gap

func _sync_status_icon_sprites() -> void:
	if not is_inside_tree():
		return
	var stacks_by_id: Dictionary = _get_all_active_status_stacks()
	var status_ids: Array = stacks_by_id.keys()
	status_ids.sort()
	var active: Dictionary[StringName, bool] = {}
	for status_id_variant in status_ids:
		var status_id: StringName = StringName(status_id_variant)
		var sprite_file: String = String(STATUS_SPRITE_FILES.get(status_id, ""))
		if sprite_file.is_empty():
			continue
		active[status_id] = true
		var icon: Sprite2D = _status_icon_sprites.get(status_id) as Sprite2D
		if icon == null or not is_instance_valid(icon):
			var sprite_sheet: Texture2D = load(COZY_STATUS_ROOT + sprite_file) as Texture2D
			if sprite_sheet == null:
				continue
			icon = ANIMATED_IMPACT_SCRIPT.new() as Sprite2D
			if icon == null:
				continue
			icon.name = "Status_%s" % String(status_id)
			add_child(icon)
			_status_icon_sprites[status_id] = icon
			var frame_count: int = int(float(sprite_sheet.get_width()) / 128.0)
			if not bool(icon.call(
				"configure",
				sprite_sheet,
				frame_count,
				12.0,
				22.0,
				global_position,
				true,
				frame_count,
				Vector2i(128, 128),
				20
			)):
				icon.queue_free()
				_status_icon_sprites.erase(status_id)
				continue
	var icon_size: float = 22.0
	var gap: float = 4.0
	var visible_ids: Array[StringName] = []
	for status_id in active:
		if _status_icon_sprites.has(status_id):
			visible_ids.append(status_id)
	var total_width: float = float(visible_ids.size()) * icon_size + float(maxi(visible_ids.size() - 1, 0)) * gap
	var start_x: float = -total_width * 0.5
	for status_id in visible_ids:
		var icon: Sprite2D = _status_icon_sprites[status_id]
		icon.position = Vector2(start_x + icon_size * 0.5, -_body_radius - 48.0 - _jump_height)
		icon.visible = true
		start_x += icon_size + gap
	for status_id_variant in _status_icon_sprites.keys():
		var status_id: StringName = StringName(status_id_variant)
		if active.has(status_id):
			continue
		var stale_icon: Sprite2D = _status_icon_sprites[status_id]
		if is_instance_valid(stale_icon):
			stale_icon.queue_free()
		_status_icon_sprites.erase(status_id)

func _on_health_changed(current_health: int, maximum_health: int) -> void:
	health_changed.emit(current_health, maximum_health)
	queue_redraw()

func _on_health_depleted() -> void:
	if state != State.MOVING:
		return
	_path_follower.stop()
	_change_state(State.DEAD)
	defeated.emit()
	if state == State.DEAD:
		queue_free()

func _on_status_effects_changed(_active_ids: PackedStringArray) -> void:
	_sync_status_icon_sprites()
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
		_haste_strength = 0.0
		_fortification_strength = 0.0
		_status_speed_multiplier = 1.0
	state = next_state
	_sync_status_icon_sprites()
	state_changed.emit(state)

func _update_move_speed_multiplier() -> void:
	var haste_multiplier: float = 1.0 + _haste_strength / 100.0
	_path_follower.set_speed_multiplier(_status_speed_multiplier * haste_multiplier)

func _on_horizontal_direction_changed(is_facing_left: bool) -> void:
	if _is_facing_left == is_facing_left:
		return
	_is_facing_left = is_facing_left
	_sync_outline_sprite_orientation()
	queue_redraw()

func _sync_outline_sprite() -> void:
	if _outline_sprite == null or not is_instance_valid(_outline_sprite):
		return
	_outline_sprite.texture = _sprite_texture
	_outline_sprite.visible = _sprite_texture != null
	if _sprite_texture == null:
		return
	var sprite_extent: float = _get_sprite_extent()
	var texture_size: Vector2 = Vector2(_sprite_texture.get_size())
	_outline_sprite.scale = Vector2(
		sprite_extent / maxf(texture_size.x, 1.0),
		sprite_extent / maxf(texture_size.y, 1.0)
	)
	var outline_material := _outline_sprite.material as ShaderMaterial
	if outline_material != null:
		outline_material.set_shader_parameter("outline_color", _get_enemy_outline_color())
	_sync_outline_sprite_orientation()
	_sync_outline_sprite_position()

func _sync_outline_sprite_orientation() -> void:
	if _outline_sprite != null and is_instance_valid(_outline_sprite):
		_outline_sprite.flip_h = _is_facing_left

func _sync_outline_sprite_position() -> void:
	if _outline_sprite != null and is_instance_valid(_outline_sprite):
		_outline_sprite.position = Vector2(0.0, -_jump_height + VISUAL_ART_OFFSET_Y)

func _get_sprite_extent() -> float:
	if _enemy_data == null:
		return maxf(_body_radius * 3.2, 48.0)
	if _enemy_data.sprite_extent > 0.0:
		return _enemy_data.sprite_extent
	return maxf(_body_radius * 3.2, 48.0)

func _get_enemy_outline_color() -> Color:
	if _enemy_data == null:
		return ENEMY_OUTLINE_FALLBACK_COLOR
	var outline_color: Color = ENEMY_OUTLINE_COLORS.get(
		_enemy_data.id,
		ENEMY_OUTLINE_FALLBACK_COLOR
	)
	return outline_color
