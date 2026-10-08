class_name MetaShopPanel
extends CanvasLayer

signal new_run_requested

const HUD_STYLE_SCRIPT: Script = preload("res://game/ui/rogue_hud_style.gd")
const ICON_CATALOG_SCRIPT: Script = preload("res://game/ui/icon_catalog.gd")

var _tower_profiles: Array[TowerData] = []
var _permanent_upgrades: Array[PermanentUpgradeData] = []
var _run_summary: Dictionary = {}
var _is_open: bool = false
var _currency_label: Label
var _summary_label: Label
var _outcome_label: Label
var _status_label: Label
var _tower_tab_button: Button
var _upgrade_tab_button: Button
var _tower_list: VBoxContainer
var _upgrade_list: VBoxContainer
var _tower_rows: Array[Dictionary] = []
var _upgrade_rows: Array[Dictionary] = []
var _ui_style: RefCounted
var _icon_catalog: RefCounted

func configure(tower_profiles: Array[TowerData], permanent_upgrades: Array[PermanentUpgradeData]) -> void:
	_tower_profiles = tower_profiles.duplicate()
	_permanent_upgrades = permanent_upgrades.duplicate()

func _ready() -> void:
	layer = 10
	_icon_catalog = ICON_CATALOG_SCRIPT.new() as RefCounted
	_build_interface()
	_ui_style = HUD_STYLE_SCRIPT.new() as RefCounted
	_ui_style.call("apply_to_tree", self)
	hide()

func is_open() -> bool:
	return _is_open

func present(run_summary: Dictionary) -> void:
	_run_summary = run_summary.duplicate(true)
	_is_open = true
	_status_label.text = ""
	_select_category(&"towers")
	visible = true
	_refresh()

func _build_interface() -> void:
	var root := Control.new()
	root.name = "MetaShopRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.025, 0.035, 0.045, 0.9)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(backdrop)

	var panel := PanelContainer.new()
	panel.name = "MetaShop"
	panel.anchor_left = 0.035
	panel.anchor_top = 0.035
	panel.anchor_right = 0.965
	panel.anchor_bottom = 0.965
	panel.custom_minimum_size = Vector2(760.0, 560.0)
	root.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	var eyebrow := Label.new()
	eyebrow.text = "CIERRE DE RUN  ·  PROGRESO PERMANENTE"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_font_size_override("font_size", 12)
	eyebrow.add_theme_color_override("font_color", Color("#9eafb0"))
	content.add_child(eyebrow)

	_outcome_label = Label.new()
	_outcome_label.text = "RUN FINALIZADA"
	_outcome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_outcome_label.add_theme_font_size_override("font_size", 30)
	content.add_child(_outcome_label)

	_summary_label = Label.new()
	_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary_label.add_theme_font_size_override("font_size", 15)
	_summary_label.add_theme_color_override("font_color", Color("#ccd4d2"))
	content.add_child(_summary_label)

	_currency_label = Label.new()
	_currency_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_currency_label.add_theme_color_override("font_color", Color("#e5be6a"))
	_currency_label.add_theme_font_size_override("font_size", 20)
	content.add_child(_currency_label)

	var separator := HSeparator.new()
	content.add_child(separator)

	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 10)
	content.add_child(tabs)
	var tab_group := ButtonGroup.new()
	_tower_tab_button = _create_tab_button("TORRES", tab_group)
	_upgrade_tab_button = _create_tab_button("MEJORAS PERMANENTES", tab_group)
	tabs.add_child(_tower_tab_button)
	tabs.add_child(_upgrade_tab_button)
	_tower_tab_button.pressed.connect(_select_category.bind(&"towers"))
	_upgrade_tab_button.pressed.connect(_select_category.bind(&"upgrades"))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0.0, 260.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)

	var lists := VBoxContainer.new()
	lists.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lists.add_theme_constant_override("separation", 10)
	scroll.add_child(lists)

	_tower_list = VBoxContainer.new()
	_tower_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tower_list.add_theme_constant_override("separation", 8)
	lists.add_child(_tower_list)
	var tower_heading := _create_category_heading("AMPLÍA TU ARSENAL", "Desbloquea torres para tus próximas runs.")
	_tower_list.add_child(tower_heading)
	for tower_data in _tower_profiles:
		if tower_data == null or tower_data.unlock_id == &"":
			continue
		var row := _create_shop_row(tower_data.display_name, tower_data.role_summary)
		_tower_list.add_child(row.container)
		row.button.pressed.connect(_on_tower_purchase_pressed.bind(tower_data.unlock_id))
		row["data"] = tower_data
		_tower_rows.append(row)

	_upgrade_list = VBoxContainer.new()
	_upgrade_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_upgrade_list.add_theme_constant_override("separation", 8)
	lists.add_child(_upgrade_list)
	var upgrade_heading := _create_category_heading("MEJORA LA SIGUIENTE RUN", "Los niveles permanentes se aplican al empezar una run nueva.")
	_upgrade_list.add_child(upgrade_heading)
	for upgrade in _permanent_upgrades:
		if upgrade == null:
			continue
		var row := _create_shop_row(upgrade.display_name, upgrade.description)
		_upgrade_list.add_child(row.container)
		row.button.pressed.connect(_on_upgrade_purchase_pressed.bind(upgrade.id))
		row["data"] = upgrade
		_upgrade_rows.append(row)

	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.custom_minimum_size.y = 22.0
	content.add_child(_status_label)

	var new_run_button := Button.new()
	new_run_button.text = "Empezar nueva run"
	new_run_button.custom_minimum_size = Vector2(0.0, 48.0)
	new_run_button.tooltip_text = "Vuelve al tablero con los desbloqueos y mejoras permanentes comprados."
	new_run_button.pressed.connect(func() -> void: new_run_requested.emit())
	content.add_child(new_run_button)
	_select_category(&"towers")

func _create_tab_button(label_text: String, tab_group: ButtonGroup) -> Button:
	var button := Button.new()
	button.text = label_text
	button.toggle_mode = true
	button.button_group = tab_group
	button.custom_minimum_size = Vector2(210.0, 42.0)
	return button

func _create_category_heading(title_text: String, subtitle_text: String) -> VBoxContainer:
	var heading := VBoxContainer.new()
	heading.add_theme_constant_override("separation", 2)
	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 16)
	heading.add_child(title)
	var subtitle := Label.new()
	subtitle.text = subtitle_text
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color("#aebbc0"))
	heading.add_child(subtitle)
	return heading

func _create_shop_row(title_text: String, description_text: String) -> Dictionary:
	var row_container := PanelContainer.new()
	row_container.custom_minimum_size.y = 68.0
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row_container.add_child(row)
	var accent := ColorRect.new()
	accent.color = Color("#d9b86f")
	accent.custom_minimum_size = Vector2(4.0, 40.0)
	accent.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(accent)
	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.add_theme_constant_override("separation", 2)
	row.add_child(labels)
	var title := RichTextLabel.new()
	title.fit_content = true
	title.scroll_active = false
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_set_rich_text_with_currency_icons(title, title_text)
	title.add_theme_font_size_override("font_size", 15)
	labels.add_child(title)
	var description := RichTextLabel.new()
	description.fit_content = true
	description.scroll_active = false
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_set_rich_text_with_currency_icons(description, description_text)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_color_override("font_color", Color("#aebbc0"))
	description.add_theme_font_size_override("font_size", 13)
	labels.add_child(description)
	var action_button := Button.new()
	action_button.custom_minimum_size = Vector2(205.0, 42.0)
	row.add_child(action_button)
	return {
		"container": row_container,
		"title": title,
		"description": description,
		"button": action_button,
	}

func _set_rich_text_with_currency_icons(label: RichTextLabel, source_text: String) -> void:
	label.clear()
	var currency_pattern := RegEx.new()
	currency_pattern.compile("(?i)\\b(oro|man[aá])\\b")
	var matches: Array[RegExMatch] = currency_pattern.search_all(source_text)
	var cursor: int = 0
	for currency_match in matches:
		var match_start: int = currency_match.get_start(0)
		label.append_text(source_text.substr(cursor, match_start - cursor))
		var currency_text: String = currency_match.get_string(1).to_lower()
		var icon_name: StringName = &"gold" if currency_text == "oro" else &"mana"
		var currency_icon: Texture2D = _icon_catalog.call("get_icon", icon_name) as Texture2D
		if currency_icon != null:
			label.add_image(currency_icon, 16, 16)
		cursor = currency_match.get_end(0)
	label.append_text(source_text.substr(cursor))

func _select_category(category: StringName) -> void:
	if _tower_list == null or _upgrade_list == null:
		return
	_tower_list.visible = category == &"towers"
	_upgrade_list.visible = category == &"upgrades"
	if _tower_tab_button != null:
		_tower_tab_button.set_pressed_no_signal(category == &"towers")
	if _upgrade_tab_button != null:
		_upgrade_tab_button.set_pressed_no_signal(category == &"upgrades")

func _refresh() -> void:
	if _currency_label == null or _summary_label == null:
		return
	var outcome: String = String(_run_summary.get("outcome", ""))
	if outcome == "VICTORY":
		_outcome_label.text = "VICTORIA · DEMO COMPLETADA"
		_outcome_label.add_theme_color_override("font_color", Color("#8fca8c"))
	else:
		_outcome_label.text = "DERROTA · RUN FINALIZADA"
		_outcome_label.add_theme_color_override("font_color", Color("#e58a72"))
	var reached_round: int = int(_run_summary.get("reached_round", 1))
	var completed_rounds: int = int(_run_summary.get("completed_rounds", 0))
	var reward: int = int(_run_summary.get("meta_reward", 0))
	var run_seed_value: int = int(_run_summary.get("run_seed", 0))
	_summary_label.text = "Ronda alcanzada %02d/20   ·   %d rondas completas   ·   +%d moneda meta" % [
		reached_round,
		completed_rounds,
		reward,
	]
	_summary_label.tooltip_text = "Semilla de esta run: %d" % run_seed_value
	_currency_label.text = "MONEDA META   %d" % int(MetaProgression.call("get_meta_currency"))
	_tower_tab_button.text = "TORRES  ·  %d" % _tower_rows.size()
	_upgrade_tab_button.text = "MEJORAS  ·  %d" % _upgrade_rows.size()
	var can_save: bool = bool(MetaProgression.call("can_persist_progress"))
	var current_currency: int = int(MetaProgression.call("get_meta_currency"))
	for row in _tower_rows:
		var tower_data := row["data"] as TowerData
		var action_button := row["button"] as Button
		var is_unlocked: bool = bool(MetaProgression.call("is_tower_unlocked", tower_data))
		if is_unlocked:
			action_button.text = "Desbloqueada"
			action_button.disabled = true
			action_button.tooltip_text = "Ya forma parte del arsenal para las próximas runs."
		else:
			action_button.text = "Desbloquear · %d" % tower_data.meta_unlock_cost
			action_button.disabled = not can_save or current_currency < tower_data.meta_unlock_cost
			action_button.tooltip_text = "Añade %s al arsenal permanente por %d monedas meta." % [tower_data.display_name, tower_data.meta_unlock_cost]
	for row in _upgrade_rows:
		var upgrade := row["data"] as PermanentUpgradeData
		var action_button := row["button"] as Button
		var level: int = int(MetaProgression.call("get_upgrade_level", upgrade.id))
		var cost: int = upgrade.get_cost_for_next_level(level)
		if cost < 0:
			action_button.text = "Máximo · %d/%d" % [level, upgrade.max_level]
			action_button.disabled = true
			action_button.tooltip_text = "Esta mejora ya alcanzó su máximo permanente."
		else:
			action_button.text = "Mejorar · %d/%d · %d" % [level, upgrade.max_level, cost]
			action_button.disabled = not can_save or current_currency < cost or not bool(MetaProgression.call("can_purchase_upgrade", upgrade.id))
			action_button.tooltip_text = "Nivel %d/%d · coste %d monedas meta." % [level, upgrade.max_level, cost]
	if not can_save:
		_status_label.text = String(MetaProgression.call("get_save_error"))
		_status_label.add_theme_color_override("font_color", Color("#e58a72"))
	elif not bool(_run_summary.get("saved", true)) and not _status_label.text.begins_with("Comprado") and not _status_label.text.begins_with("Error:"):
		_status_label.text = "La recompensa de esta run no se guardó: %s" % String(MetaProgression.call("get_save_error"))
		_status_label.add_theme_color_override("font_color", Color("#e58a72"))
	elif not _status_label.text.begins_with("Comprado") and not _status_label.text.begins_with("Error:"):
		_status_label.text = "Las compras se guardan al confirmarse y se aplican desde la próxima run."
		_status_label.add_theme_color_override("font_color", Color("#aebbc0"))

func _on_tower_purchase_pressed(unlock_id: StringName) -> void:
	var purchased: bool = bool(MetaProgression.call("purchase_tower", unlock_id))
	_status_label.text = "Comprado: torre desbloqueada para futuras runs." if purchased else "Error: %s" % String(MetaProgression.call("get_save_error"))
	_status_label.add_theme_color_override("font_color", Color("#8fca8c") if purchased else Color("#e58a72"))
	_refresh()

func _on_upgrade_purchase_pressed(upgrade_id: StringName) -> void:
	var purchased: bool = bool(MetaProgression.call("purchase_upgrade", upgrade_id))
	_status_label.text = "Comprado: la mejora se aplicará desde la siguiente run." if purchased else "Error: %s" % String(MetaProgression.call("get_save_error"))
	_status_label.add_theme_color_override("font_color", Color("#8fca8c") if purchased else Color("#e58a72"))
	_refresh()
