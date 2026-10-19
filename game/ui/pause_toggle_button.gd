@tool
class_name PauseToggleButton
extends Button

const PAUSE_ACTION: StringName = &"toggle_pause"

@export_group("Pause button glyph")
@export_range(0.0, 40.0, 1.0) var glyph_left_inset: float = 15.0:
	set(value):
		glyph_left_inset = value
		queue_redraw()
@export_range(2.0, 20.0, 1.0) var pause_bar_width: float = 4.0:
	set(value):
		pause_bar_width = value
		queue_redraw()
@export_range(0.0, 20.0, 1.0) var pause_bar_gap: float = 4.0:
	set(value):
		pause_bar_gap = value
		queue_redraw()
@export_range(4.0, 32.0, 1.0) var glyph_height: float = 16.0:
	set(value):
		glyph_height = value
		queue_redraw()
@export_range(4.0, 32.0, 1.0) var play_glyph_width: float = 13.0:
	set(value):
		play_glyph_width = value
		queue_redraw()
@export_range(0.0, 40.0, 1.0) var label_offset_x: float = 19.0:
	set(value):
		label_offset_x = value
		queue_redraw()
@export_range(0.0, 1.0, 0.01) var label_baseline_factor: float = 0.34:
	set(value):
		label_baseline_factor = value
		queue_redraw()

var _pause_locked: bool = false

func _ready() -> void:
	toggle_mode = true
	if Engine.is_editor_hint():
		text = ""
		queue_redraw()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	toggled.connect(_on_toggled)
	_ensure_pause_action()
	sync_pause_state()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	sync_pause_state()

func _unhandled_key_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if _pause_locked:
		return
	var key_event := event as InputEventKey
	if key_event == null or key_event.echo or not key_event.is_action_pressed(PAUSE_ACTION):
		return
	get_viewport().set_input_as_handled()
	get_tree().paused = not get_tree().paused
	sync_pause_state()

func set_pause_locked(locked: bool) -> void:
	_pause_locked = locked
	disabled = locked
	sync_pause_state()

func sync_pause_state() -> void:
	if Engine.is_editor_hint():
		text = ""
		queue_redraw()
		return
	var is_paused: bool = get_tree().paused
	if button_pressed != is_paused:
		set_pressed_no_signal(is_paused)
	text = ""
	tooltip_text = "Reanudar (P)" if is_paused else "Pausar (P)"
	queue_redraw()

func _draw() -> void:
	var is_paused: bool = not Engine.is_editor_hint() and get_tree().paused
	var glyph_color: Color = get_theme_color("font_color")
	var center_y: float = size.y * 0.5
	var glyph_left: float = size.x * 0.5 - glyph_left_inset
	var glyph_top: float = center_y - glyph_height * 0.5
	if is_paused:
		var play_points := PackedVector2Array([
			Vector2(glyph_left, glyph_top),
			Vector2(glyph_left, glyph_top + glyph_height),
			Vector2(glyph_left + play_glyph_width, center_y),
		])
		draw_colored_polygon(play_points, glyph_color)
	else:
		draw_rect(Rect2(glyph_left, glyph_top, pause_bar_width, glyph_height), glyph_color)
		draw_rect(
			Rect2(glyph_left + pause_bar_width + pause_bar_gap, glyph_top, pause_bar_width, glyph_height),
			glyph_color
		)
	var label_font: Font = get_theme_font("font")
	var label_size: int = get_theme_font_size("font_size")
	draw_string(
		label_font,
		Vector2(glyph_left + label_offset_x, center_y + label_size * label_baseline_factor),
		"P",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		label_size,
		glyph_color
	)

func _on_toggled(toggled_on: bool) -> void:
	if Engine.is_editor_hint():
		return
	if _pause_locked:
		set_pressed_no_signal(true)
		return
	get_tree().paused = toggled_on
	sync_pause_state()

func _ensure_pause_action() -> void:
	if not InputMap.has_action(PAUSE_ACTION):
		InputMap.add_action(PAUSE_ACTION)
	for event in InputMap.action_get_events(PAUSE_ACTION):
		var key_event := event as InputEventKey
		if key_event != null and key_event.physical_keycode == KEY_P:
			return
	var pause_key := InputEventKey.new()
	pause_key.physical_keycode = KEY_P
	InputMap.action_add_event(PAUSE_ACTION, pause_key)
