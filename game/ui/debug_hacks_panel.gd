class_name DebugHacksPanel
extends CanvasLayer

signal action_requested(action_id: StringName)

@onready var _unlock_button: Button = %UnlockButton

func _ready() -> void:
	layer = 100
	hide()
	%CloseButton.pressed.connect(hide)
	%AddGoldButton.pressed.connect(_on_action_pressed.bind(&"add_gold"))
	%AddManaButton.pressed.connect(_on_action_pressed.bind(&"add_mana"))
	%RefillManaButton.pressed.connect(_on_action_pressed.bind(&"refill_mana"))
	%HealBaseButton.pressed.connect(_on_action_pressed.bind(&"heal_base"))
	_unlock_button.pressed.connect(_on_action_pressed.bind(&"toggle_unlocks"))
	%StartWaveButton.pressed.connect(_on_action_pressed.bind(&"start_wave"))
	%RestartRunButton.pressed.connect(_on_action_pressed.bind(&"restart_run"))

func set_unlock_status(enabled: bool) -> void:
	_unlock_button.text = "Desbloquear todo (solo esta run): %s" % ("sí" if enabled else "no")

func _on_action_pressed(action_id: StringName) -> void:
	if action_id != &"toggle_unlocks":
		hide()
	action_requested.emit(action_id)
