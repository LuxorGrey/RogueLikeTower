extends CanvasLayer

signal resume_requested
signal menu_requested

@onready var _resume_button: Button = %ResumeButton
@onready var _menu_button: Button = %MenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resume_button.pressed.connect(func() -> void: resume_requested.emit())
	_menu_button.pressed.connect(func() -> void: menu_requested.emit())
	set_paused(false)

func set_paused(paused: bool) -> void:
	visible = paused

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		resume_requested.emit()
		get_viewport().set_input_as_handled()
