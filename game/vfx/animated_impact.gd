extends Sprite2D

var _frame_count: int = 1
var _columns: int = 1
var _frames_per_second: float = 12.0
var _display_size: float = 64.0
var _elapsed: float = 0.0
var _frame_size := Vector2.ZERO
var _initial_scale := Vector2.ONE
var _static_sprite_duration: float = 0.0
var _animate_static_sprite: bool = false
var _loop_forever: bool = false
var _loop_count: int = 1

func configure(
	sprite_sheet: Texture2D,
	frame_count: int,
	frames_per_second: float,
	display_size: float,
	world_position: Vector2,
	loop_forever: bool = false,
	columns: int = 0,
	source_frame_size: Vector2i = Vector2i.ZERO,
	layer_z_index: int = 8,
	loop_count: int = 1,
	animate_static_sprite: bool = false
) -> bool:
	if sprite_sheet == null or frame_count <= 0 or frames_per_second <= 0.0 or display_size <= 0.0:
		return false
	if source_frame_size == Vector2i.ZERO:
		if sprite_sheet.get_width() % frame_count != 0:
			return false
		_columns = frame_count
		_frame_size = Vector2(
			float(sprite_sheet.get_width()) / float(frame_count),
			float(sprite_sheet.get_height())
		)
	else:
		if source_frame_size.x <= 0 or source_frame_size.y <= 0:
			return false
		if sprite_sheet.get_width() % source_frame_size.x != 0 or sprite_sheet.get_height() % source_frame_size.y != 0:
			return false
		var sheet_columns: int = int(float(sprite_sheet.get_width()) / float(source_frame_size.x))
		var sheet_rows: int = int(float(sprite_sheet.get_height()) / float(source_frame_size.y))
		_columns = columns if columns > 0 else sheet_columns
		if _columns <= 0 or _columns > sheet_columns or frame_count > _columns * sheet_rows:
			return false
		_frame_size = Vector2(source_frame_size)
	_frame_count = frame_count
	_frames_per_second = frames_per_second
	_display_size = display_size
	_loop_forever = loop_forever
	_loop_count = maxi(loop_count, 1)
	_animate_static_sprite = animate_static_sprite and _frame_count == 1
	_static_sprite_duration = float(_loop_count) / _frames_per_second
	_elapsed = 0.0
	texture = sprite_sheet
	region_enabled = true
	region_rect = Rect2(Vector2.ZERO, _frame_size)
	centered = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	scale = Vector2(_display_size / _frame_size.x, _display_size / _frame_size.y)
	_initial_scale = scale
	modulate.a = 1.0
	global_position = world_position
	z_index = layer_z_index
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	return true

func _process(delta: float) -> void:
	_elapsed += delta
	var elapsed_frames: float = _elapsed * _frames_per_second
	var completed_loops: int = floori(elapsed_frames / float(_frame_count))
	if _animate_static_sprite:
		var progress: float = clampf(_elapsed / maxf(_static_sprite_duration, 0.001), 0.0, 1.0)
		var eased_progress: float = 1.0 - (1.0 - progress) * (1.0 - progress)
		scale = _initial_scale * lerpf(0.82, 1.10, eased_progress)
		modulate.a = 1.0 - progress
	if not _loop_forever and completed_loops >= _loop_count:
		queue_free()
		return
	var frame_index: int = int(elapsed_frames) % _frame_count
	var frame_origin := Vector2(
		float(frame_index % _columns) * _frame_size.x,
		float(floori(float(frame_index) / float(_columns))) * _frame_size.y
	)
	region_rect = Rect2(frame_origin, _frame_size)
