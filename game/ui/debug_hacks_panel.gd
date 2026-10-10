extends CanvasLayer

signal action_requested(action_id: StringName)

var _unlock_button: Button

func _ready() -> void:
	layer = 100
	visible = false
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.015, 0.02, 0.025, 0.74)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420.0, 0.0)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	var heading := HBoxContainer.new()
	content.add_child(heading)
	var title := Label.new()
	title.text = "HERRAMIENTAS DE DEPURACIÓN"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 18)
	heading.add_child(title)
	var close_button := Button.new()
	close_button.text = "Cerrar"
	close_button.pressed.connect(hide)
	heading.add_child(close_button)

	_add_action_button(content, "Gold +1.000", &"add_gold")
	_add_action_button(content, "Mana +100", &"add_mana")
	_add_action_button(content, "Restaurar Mana al máximo", &"refill_mana")
	_add_action_button(content, "Curar la base", &"heal_base")
	_unlock_button = _add_action_button(content, "Desbloquear todo (solo esta run): no", &"toggle_unlocks")
	_add_action_button(content, "Iniciar la ronda seleccionada", &"start_wave")
	_add_action_button(content, "Empezar una run desde cero", &"restart_run")

	var note := Label.new()
	note.text = "Ctrl+K abre o cierra este menú. Los desbloqueos de depuración no se guardan."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 12)
	content.add_child(note)

func set_unlock_status(enabled: bool) -> void:
	if _unlock_button == null:
		return
	_unlock_button.text = "Desbloquear todo (solo esta run): %s" % ("sí" if enabled else "no")

func _add_action_button(parent: VBoxContainer, label: String, action_id: StringName) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(0.0, 38.0)
	button.pressed.connect(_on_action_pressed.bind(action_id))
	parent.add_child(button)
	return button

func _on_action_pressed(action_id: StringName) -> void:
	if action_id != &"toggle_unlocks":
		hide()
	action_requested.emit(action_id)
