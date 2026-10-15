class_name PauseToggleButton
extends Button

const PAUSE_ACTION: StringName = &"toggle_pause"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	toggle_mode = true
	toggled.connect(_on_toggled)
	_ensure_pause_action()
	sync_pause_state()

func _process(_delta: float) -> void:
	sync_pause_state()

func _unhandled_key_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or key_event.echo or not key_event.is_action_pressed(PAUSE_ACTION):
		return
	get_viewport().set_input_as_handled()
	get_tree().paused = not get_tree().paused
	sync_pause_state()

func sync_pause_state() -> void:
	var is_paused: bool = get_tree().paused
	if button_pressed != is_paused:
		set_pressed_no_signal(is_paused)
	text = ""
	tooltip_text = "Reanudar (P)" if is_paused else "Pausar (P)"
	queue_redraw()

func _draw() -> void:
	var is_paused: bool = get_tree().paused
	var glyph_color: Color = get_theme_color("font_color")
	var center_y: float = size.y * 0.5
	var glyph_left: float = size.x * 0.5 - 15.0
	if is_paused:
		var play_points := PackedVector2Array([
			Vector2(glyph_left, center_y - 8.0),
			Vector2(glyph_left, center_y + 8.0),
			Vector2(glyph_left + 13.0, center_y),
		])
		draw_colored_polygon(play_points, glyph_color)
	else:
		draw_rect(Rect2(glyph_left, center_y - 8.0, 4.0, 16.0), glyph_color)
		draw_rect(Rect2(glyph_left + 8.0, center_y - 8.0, 4.0, 16.0), glyph_color)
	var label_font: Font = get_theme_font("font")
	var label_size: int = get_theme_font_size("font_size")
	draw_string(
		label_font,
		Vector2(glyph_left + 19.0, center_y + label_size * 0.34),
		"P",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		label_size,
		glyph_color
	)

func _on_toggled(toggled_on: bool) -> void:
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
