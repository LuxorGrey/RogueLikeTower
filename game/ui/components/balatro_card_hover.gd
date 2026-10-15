extends Node

const HOVER_SHADER: Shader = preload("res://game/ui/components/balatro_card_hover.gdshader")

var _card: Control
var _motion_target: Control
var _shine: ColorRect
var _material: ShaderMaterial
var _tween: Tween

func _ready() -> void:
	_card = get_parent() as Control
	if _card == null:
		return
	_motion_target = _card.get_node_or_null("CardMargin") as Control
	if _motion_target == null:
		_motion_target = _card
	_card.mouse_entered.connect(_on_mouse_entered)
	_card.mouse_exited.connect(_on_mouse_exited)
	_card.gui_input.connect(_on_gui_input)
	_card.resized.connect(_sync_pivot)
	_sync_pivot()
	if _motion_target != _card:
		_motion_target.pivot_offset = _motion_target.size * 0.5
		_motion_target.resized.connect(func() -> void:
			if is_instance_valid(_motion_target):
				_motion_target.pivot_offset = _motion_target.size * 0.5
		)
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

func _sync_pivot() -> void:
	if _card != null:
		_card.pivot_offset = _card.size * 0.5

func _on_mouse_entered() -> void:
	if _card == null:
		return
	_card.pivot_offset = _card.size * 0.5
	if _material != null:
		_material.set_shader_parameter("effect_strength", 1.0)
	_animate_card(Vector2(1.025, 1.025), 0.0)
	_update_hover_position()

func _on_mouse_exited() -> void:
	if _card == null:
		return
	if _material != null:
		_material.set_shader_parameter("effect_strength", 0.0)
	_animate_card(Vector2.ONE, 0.0)

func _on_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion or _card == null:
		return
	_update_hover_position()
	var normalized_x: float = clampf(_card.get_local_mouse_position().x / maxf(_card.size.x, 1.0), 0.0, 1.0)
	var normalized_y: float = clampf(_card.get_local_mouse_position().y / maxf(_card.size.y, 1.0), 0.0, 1.0)
	_card.rotation = (normalized_x - 0.5) * 0.045 + (0.5 - normalized_y) * 0.012

func _update_hover_position() -> void:
	if _card == null or _material == null:
		return
	var local_mouse: Vector2 = _card.get_local_mouse_position()
	var hover_uv := Vector2(
		clampf(local_mouse.x / maxf(_card.size.x, 1.0), 0.0, 1.0),
		clampf(local_mouse.y / maxf(_card.size.y, 1.0), 0.0, 1.0)
	)
	_material.set_shader_parameter("hover_uv", hover_uv)

func _animate_card(target_scale: Vector2, target_rotation: float) -> void:
	if _tween != null and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_motion_target, "scale", target_scale, 0.14)
	_tween.parallel().tween_property(_card, "rotation", target_rotation, 0.14)
