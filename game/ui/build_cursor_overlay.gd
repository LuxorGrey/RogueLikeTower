class_name BuildCursorOverlay
extends TextureRect

@export_group("Cursor appearance")
@export var cursor_size: Vector2 = Vector2(32.0, 32.0)
@export_range(0.0, 10.0, 0.1) var pulse_rate: float = 3.2
@export_range(0.5, 1.2, 0.01) var minimum_pulse_scale: float = 0.9
@export_range(0.5, 1.2, 0.01) var maximum_pulse_scale: float = 1.0

var _pulse_time: float = 0.0

func _ready() -> void:
	custom_minimum_size = cursor_size
	size = cursor_size
	pivot_offset = cursor_size * 0.5
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()
	set_process(false)

func activate(cursor_texture: Texture2D) -> void:
	if texture != cursor_texture:
		texture = cursor_texture
	visible = cursor_texture != null
	set_process(visible)

func deactivate() -> void:
	hide()
	set_process(false)
	scale = Vector2.ONE

func _process(delta: float) -> void:
	_pulse_time += delta * pulse_rate
	position = get_viewport().get_mouse_position() - cursor_size * 0.5
	var pulse: float = lerpf(minimum_pulse_scale, maximum_pulse_scale, 0.5 + 0.5 * sin(_pulse_time))
	scale = Vector2.ONE * pulse
