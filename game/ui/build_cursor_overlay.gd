class_name BuildCursorOverlay
extends TextureRect

const CURSOR_SIZE: Vector2 = Vector2(32.0, 32.0)
const PULSE_RATE: float = 3.2

var _pulse_time: float = 0.0

func _ready() -> void:
	custom_minimum_size = CURSOR_SIZE
	size = CURSOR_SIZE
	pivot_offset = CURSOR_SIZE * 0.5
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
	_pulse_time += delta * PULSE_RATE
	position = get_viewport().get_mouse_position() - CURSOR_SIZE * 0.5
	var pulse: float = 0.9 + 0.1 * (0.5 + 0.5 * sin(_pulse_time))
	scale = Vector2.ONE * pulse
