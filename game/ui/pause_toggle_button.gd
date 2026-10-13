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
	text = "Reanudar · P" if is_paused else "Pausar · P"

func _on_toggled(is_pressed: bool) -> void:
	get_tree().paused = is_pressed
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
