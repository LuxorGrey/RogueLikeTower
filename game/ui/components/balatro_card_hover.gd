extends Node

const HOVER_SHADER: Shader = preload("res://game/ui/components/balatro_card_hover.gdshader")

@export_group("Balatro hover")
@export var hover_scale: Vector2 = Vector2(1.025, 1.025)
@export var hover_peak_scale: Vector2 = Vector2(1.055, 1.055)
@export_range(0.5, 1.5, 0.01) var lift_pivot_factor: float = 1.0
@export_range(0.0, 0.12, 0.001) var tilt_horizontal_strength: float = 0.045
@export_range(0.0, 0.12, 0.001) var tilt_vertical_strength: float = 0.012

var _card: Control
var _motion_target: Control
var _shine: ColorRect
var _material: ShaderMaterial
var _tween: Tween
var _base_rotation: float = 0.0
var _base_motion_scale: Vector2 = Vector2.ONE
var _is_hovered: bool = false

func _ready() -> void:
	_card = get_parent() as Control
	if _card == null:
		return
	_motion_target = _card.get_node_or_null("CardMargin") as Control
	if _motion_target == null:
		_motion_target = _card
	_base_motion_scale = _motion_target.scale
	_card.mouse_entered.connect(_on_mouse_entered)
	_card.mouse_exited.connect(_on_mouse_exited)
	_card.gui_input.connect(_on_gui_input)
	_card.resized.connect(_sync_pivot)
	_sync_pivot()
	if _motion_target != _card:
		_motion_target.resized.connect(_sync_motion_pivot)
	call_deferred("_create_sheen")

func _create_sheen() -> void:
	if not is_instance_valid(_card) or not _card.is_inside_tree() or _shine != null:
		return
	_shine = ColorRect.new()
	_shine.name = "BalatroHoverSheen"
	_shine.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shine.color = Color.WHITE
	_material = ShaderMaterial.new()
	_material.shader = HOVER_SHADER
	_material.set_shader_parameter("effect_strength", 0.0)
	_shine.material = _material
	_card.add_child(_shine)
	if _shine.get_parent() == _card:
		_card.move_child(_shine, 0)
	if _is_hovered:
		_material.set_shader_parameter("effect_strength", 1.0)
		_update_hover_position()

func _sync_pivot() -> void:
	if _card != null:
		_card.pivot_offset = _card.size * 0.5
	_sync_motion_pivot()

func _sync_motion_pivot() -> void:
	if _motion_target == null:
		return
	var pivot_y: float = _motion_target.size.y * lift_pivot_factor if _is_hovered else _motion_target.size.y * 0.5
	_motion_target.pivot_offset = Vector2(_motion_target.size.x * 0.5, pivot_y)

func _on_mouse_entered() -> void:
	if _card == null:
		return
	if _card is BaseButton and (_card as BaseButton).disabled:
		return
	_is_hovered = true
	_card.pivot_offset = _card.size * 0.5
	_sync_motion_pivot()
	if _material != null:
		_material.set_shader_parameter("effect_strength", 1.0)
	_animate_card(true, _base_rotation)
	_update_hover_position()

func _on_mouse_exited() -> void:
	if _card == null:
		return
	_is_hovered = false
	if _material != null:
		_material.set_shader_parameter("effect_strength", 0.0)
	_animate_card(false, _base_rotation)

func _on_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion or _card == null:
		return
	_update_hover_position()
	var normalized_x: float = clampf(_card.get_local_mouse_position().x / maxf(_card.size.x, 1.0), 0.0, 1.0)
	var normalized_y: float = clampf(_card.get_local_mouse_position().y / maxf(_card.size.y, 1.0), 0.0, 1.0)
	_card.rotation = _base_rotation \
		+ (normalized_x - 0.5) * tilt_horizontal_strength \
		+ (0.5 - normalized_y) * tilt_vertical_strength

func _update_hover_position() -> void:
	if _card == null or _material == null:
		return
	var local_mouse: Vector2 = _card.get_local_mouse_position()
	var hover_uv := Vector2(
		clampf(local_mouse.x / maxf(_card.size.x, 1.0), 0.0, 1.0),
		clampf(local_mouse.y / maxf(_card.size.y, 1.0), 0.0, 1.0)
	)
	_material.set_shader_parameter("hover_uv", hover_uv)

func _animate_card(is_entering: bool, target_rotation: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().bind_node(self).set_ignore_time_scale(true)
	if is_entering:
		_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_motion_target, "scale", _base_motion_scale * hover_peak_scale, 0.12)
		_tween.parallel().tween_property(_card, "rotation", target_rotation, 0.15)
		_tween.chain().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_motion_target, "scale", _base_motion_scale * hover_scale, 0.08)
		return
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_motion_target, "scale", _base_motion_scale, 0.16)
	_tween.parallel().tween_property(_motion_target, "pivot_offset", _motion_target.size * 0.5, 0.16)
	_tween.parallel().tween_property(_card, "rotation", target_rotation, 0.16)

func set_base_rotation(rotation_radians: float) -> void:
	_base_rotation = rotation_radians
	if _card != null:
		_card.rotation = _base_rotation
