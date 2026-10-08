class_name MetaShopPanel
extends CanvasLayer

signal new_run_requested

const PANEL_WIDTH: float = 960.0
const PANEL_HEIGHT: float = 850.0

var _tower_profiles: Array[TowerData] = []
var _permanent_upgrades: Array[PermanentUpgradeData] = []
var _run_summary: Dictionary = {}
var _is_open: bool = false
var _currency_label: Label
var _summary_label: Label
var _status_label: Label
var _tower_rows: Array[Dictionary] = []
var _upgrade_rows: Array[Dictionary] = []

func configure(tower_profiles: Array[TowerData], permanent_upgrades: Array[PermanentUpgradeData]) -> void:
	_tower_profiles = tower_profiles.duplicate()
	_permanent_upgrades = permanent_upgrades.duplicate()

func _ready() -> void:
	layer = 10
	_build_interface()
	hide()

func is_open() -> bool:
	return _is_open

func present(run_summary: Dictionary) -> void:
	_run_summary = run_summary.duplicate(true)
	_is_open = true
	visible = true
	_refresh()

func _build_interface() -> void:
	var root := Control.new()
	root.name = "MetaShopRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.025, 0.035, 0.045, 0.88)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(backdrop)

	var panel := PanelContainer.new()
	panel.name = "MetaShop"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -PANEL_WIDTH * 0.5
	panel.offset_top = -PANEL_HEIGHT * 0.5
	panel.offset_right = PANEL_WIDTH * 0.5
	panel.offset_bottom = PANEL_HEIGHT * 0.5
	root.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	var title := Label.new()
	title.text = "META-PROGRESIÓN · TIENDA ENTRE RUNS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	content.add_child(title)

	_summary_label = Label.new()
	_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_summary_label)

	_currency_label = Label.new()
	_currency_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_currency_label.add_theme_color_override("font_color", Color(0.97, 0.82, 0.42))
	_currency_label.add_theme_font_size_override("font_size", 19)
	content.add_child(_currency_label)

	var separator := HSeparator.new()
	content.add_child(separator)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0.0, 545.0)
	content.add_child(scroll)

	var entries := VBoxContainer.new()
	entries.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entries.add_theme_constant_override("separation", 8)
	scroll.add_child(entries)

	var tower_heading := Label.new()
	tower_heading.text = "DESBLOQUEOS DE TORRES"
	tower_heading.add_theme_font_size_override("font_size", 17)
	entries.add_child(tower_heading)
	for tower_data in _tower_profiles:
		if tower_data == null or tower_data.unlock_id == &"":
			continue
		var row := _create_shop_row(tower_data.display_name, tower_data.role_summary, "")
		entries.add_child(row.container)
		row.button.pressed.connect(_on_tower_purchase_pressed.bind(tower_data.unlock_id))
		row["data"] = tower_data
		_tower_rows.append(row)

	var upgrade_heading := Label.new()
	upgrade_heading.text = "MEJORAS PERMANENTES"
	upgrade_heading.add_theme_font_size_override("font_size", 17)
	entries.add_child(upgrade_heading)
	for upgrade in _permanent_upgrades:
		if upgrade == null:
			continue
		var row := _create_shop_row(upgrade.display_name, upgrade.description, "")
		entries.add_child(row.container)
		row.button.pressed.connect(_on_upgrade_purchase_pressed.bind(upgrade.id))
		row["data"] = upgrade
		_upgrade_rows.append(row)

	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_status_label)

	var new_run_button := Button.new()
	new_run_button.text = "Empezar nueva run"
	new_run_button.custom_minimum_size = Vector2(0.0, 46.0)
	new_run_button.pressed.connect(func() -> void: new_run_requested.emit())
	content.add_child(new_run_button)

func _create_shop_row(title_text: String, description_text: String, button_text: String) -> Dictionary:
	var row_container := PanelContainer.new()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row_container.add_child(row)
	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.add_theme_constant_override("separation", 2)
	row.add_child(labels)
	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 15)
	labels.add_child(title)
	var description := Label.new()
	description.text = description_text
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_color_override("font_color", Color(0.72, 0.77, 0.8))
	labels.add_child(description)
	var action_button := Button.new()
	action_button.text = button_text
	action_button.custom_minimum_size = Vector2(220.0, 42.0)
	row.add_child(action_button)
	return {
		"container": row_container,
		"title": title,
		"description": description,
		"button": action_button,
	}

func _refresh() -> void:
	if _currency_label == null or _summary_label == null:
		return
	var outcome: String = String(_run_summary.get("outcome", ""))
	var outcome_text: String = "¡DEMO COMPLETADA!" if outcome == "VICTORY" else "RUN FINALIZADA"
	var reached_round: int = int(_run_summary.get("reached_round", 1))
	var completed_rounds: int = int(_run_summary.get("completed_rounds", 0))
	var reward: int = int(_run_summary.get("meta_reward", 0))
	var run_seed_value: int = int(_run_summary.get("run_seed", 0))
	_summary_label.text = "%s · ronda alcanzada %d/20 · rondas completas %d · +%d moneda meta · semilla %d" % [
		outcome_text,
		reached_round,
		completed_rounds,
		reward,
		run_seed_value,
	]
	_currency_label.text = "Moneda meta disponible: %d" % int(MetaProgression.call("get_meta_currency"))
	var can_save: bool = bool(MetaProgression.call("can_persist_progress"))
	for row in _tower_rows:
		var tower_data := row["data"] as TowerData
		var action_button := row["button"] as Button
		var is_unlocked: bool = bool(MetaProgression.call("is_tower_unlocked", tower_data))
		if is_unlocked:
			action_button.text = "Desbloqueada"
			action_button.disabled = true
		else:
			action_button.text = "Desbloquear · %d meta" % tower_data.meta_unlock_cost
			action_button.disabled = not can_save or int(MetaProgression.call("get_meta_currency")) < tower_data.meta_unlock_cost
	for row in _upgrade_rows:
		var upgrade := row["data"] as PermanentUpgradeData
		var action_button := row["button"] as Button
		var level: int = int(MetaProgression.call("get_upgrade_level", upgrade.id))
		var cost: int = upgrade.get_cost_for_next_level(level)
		if cost < 0:
			action_button.text = "Nivel máximo · %d/%d" % [level, upgrade.max_level]
			action_button.disabled = true
		else:
			action_button.text = "Mejorar · %d/%d · %d meta" % [level, upgrade.max_level, cost]
			action_button.disabled = not can_save or int(MetaProgression.call("get_meta_currency")) < cost or not bool(MetaProgression.call("can_purchase_upgrade", upgrade.id))
	if not can_save:
		_status_label.text = String(MetaProgression.call("get_save_error"))
		_status_label.add_theme_color_override("font_color", Color(1.0, 0.48, 0.4))
	elif not bool(_run_summary.get("saved", true)) and not _status_label.text.begins_with("Comprado") and not _status_label.text.begins_with("Error:"):
		_status_label.text = "La recompensa de esta run no se guardó: %s" % String(MetaProgression.call("get_save_error"))
		_status_label.add_theme_color_override("font_color", Color(1.0, 0.48, 0.4))
	elif not _status_label.text.begins_with("Comprado") and not _status_label.text.begins_with("Error:"):
		_status_label.text = "Las compras y mejoras quedan guardadas al confirmarse."
		_status_label.add_theme_color_override("font_color", Color(0.72, 0.77, 0.8))

func _on_tower_purchase_pressed(unlock_id: StringName) -> void:
	var purchased: bool = bool(MetaProgression.call("purchase_tower", unlock_id))
	_status_label.text = "Comprado: torre desbloqueada para futuras runs." if purchased else "Error: %s" % String(MetaProgression.call("get_save_error"))
	if purchased:
		_status_label.add_theme_color_override("font_color", Color(0.52, 0.9, 0.62))
	else:
		_status_label.add_theme_color_override("font_color", Color(1.0, 0.48, 0.4))
	_refresh()

func _on_upgrade_purchase_pressed(upgrade_id: StringName) -> void:
	var purchased: bool = bool(MetaProgression.call("purchase_upgrade", upgrade_id))
	_status_label.text = "Comprado: la mejora se aplicará desde la siguiente run." if purchased else "Error: %s" % String(MetaProgression.call("get_save_error"))
	if purchased:
		_status_label.add_theme_color_override("font_color", Color(0.52, 0.9, 0.62))
	else:
		_status_label.add_theme_color_override("font_color", Color(1.0, 0.48, 0.4))
	_refresh()
