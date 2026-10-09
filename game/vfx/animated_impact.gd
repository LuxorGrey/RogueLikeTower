extends Sprite2D

var _frame_count: int = 1
var _frames_per_second: float = 12.0
var _display_size: float = 64.0
var _elapsed: float = 0.0
var _source_frame_size := Vector2.ZERO

func configure(
	sprite_sheet: Texture2D,
	frame_count: int,
	frames_per_second: float,
	display_size: float,
	world_position: Vector2
) -> bool:
	if sprite_sheet == null or frame_count <= 0 or frames_per_second <= 0.0 or display_size <= 0.0:
		return false
	if sprite_sheet.get_width() % frame_count != 0:
		return false
	_frame_count = frame_count
	_frames_per_second = frames_per_second
	_display_size = display_size
	_source_frame_size = Vector2(float(sprite_sheet.get_width()) / float(frame_count), sprite_sheet.get_height())
	texture = sprite_sheet
	region_enabled = true
	region_rect = Rect2(Vector2.ZERO, _source_frame_size)
	centered = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	scale = Vector2(_display_size / _source_frame_size.x, _display_size / _source_frame_size.y)
	global_position = world_position
	z_index = 8
	set_process(true)
	return true

func _process(delta: float) -> void:
	_elapsed += delta
	var frame_index: int = floori(_elapsed * _frames_per_second)
	if frame_index >= _frame_count:
		queue_free()
		return
	region_rect = Rect2(Vector2(_source_frame_size.x * float(frame_index), 0.0), _source_frame_size)
