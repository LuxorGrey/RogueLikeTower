class_name MetaShopPanel
extends CanvasLayer

signal new_run_requested

const ICON_CATALOG_RESOURCE: Resource = preload("res://game/ui/resources/icon_catalog.tres")
const SHOP_ROW_SCENE: PackedScene = preload("res://game/progression/meta_shop_row.tscn")

var _tower_profiles: Array[TowerData] = []
var _permanent_upgrades: Array[PermanentUpgradeData] = []
var _run_summary: Dictionary = {}
var _is_open: bool = false
var _tower_rows: Array[Dictionary] = []
var _upgrade_rows: Array[Dictionary] = []
var _icon_catalog: Resource

@onready var _currency_label: Label = %CurrencyLabel
@onready var _summary_label: Label = %SummaryLabel
@onready var _outcome_label: Label = %OutcomeLabel
@onready var _status_label: Label = %StatusLabel
@onready var _tower_tab_button: Button = %TowerTabButton
@onready var _upgrade_tab_button: Button = %UpgradeTabButton
@onready var _tower_list: VBoxContainer = %TowerList
@onready var _upgrade_list: VBoxContainer = %UpgradeList

func configure(tower_profiles: Array[TowerData], permanent_upgrades: Array[PermanentUpgradeData]) -> void:
	_tower_profiles = tower_profiles.duplicate()
	_permanent_upgrades = permanent_upgrades.duplicate()

func _ready() -> void:
	layer = 10
	_icon_catalog = ICON_CATALOG_RESOURCE
	var tab_group := ButtonGroup.new()
	_tower_tab_button.button_group = tab_group
	_upgrade_tab_button.button_group = tab_group
	_tower_tab_button.pressed.connect(_select_category.bind(&"towers"))
	_upgrade_tab_button.pressed.connect(_select_category.bind(&"upgrades"))
	for tower_data in _tower_profiles:
		if tower_data == null or tower_data.unlock_id == &"":
			continue
		var row := _create_shop_row(tower_data.display_name, tower_data.role_summary)
		_tower_list.add_child(row.container)
		row.button.pressed.connect(_on_tower_purchase_pressed.bind(tower_data.unlock_id))
		row["data"] = tower_data
		_tower_rows.append(row)
	for upgrade in _permanent_upgrades:
		if upgrade == null:
			continue
		var row := _create_shop_row(upgrade.display_name, upgrade.description)
		_upgrade_list.add_child(row.container)
		row.button.pressed.connect(_on_upgrade_purchase_pressed.bind(upgrade.id))
		row["data"] = upgrade
		_upgrade_rows.append(row)
	%NewRunButton.pressed.connect(_on_new_run_pressed)
	_select_category(&"towers")
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

func _create_shop_row(title_text: String, description_text: String) -> Dictionary:
	var row_container := SHOP_ROW_SCENE.instantiate() as PanelContainer
	var title := row_container.get_node("Body/Labels/Title") as RichTextLabel
	var description := row_container.get_node("Body/Labels/Description") as RichTextLabel
	var action_button := row_container.get_node("Body/ActionButton") as Button
	_set_rich_text_with_currency_icons(title, title_text)
	_set_rich_text_with_currency_icons(description, description_text)
	return {
		"container": row_container,
		"title": title,
		"description": description,
		"button": action_button,
	}

func _set_rich_text_with_currency_icons(label: RichTextLabel, source_text: String) -> void:
	label.clear()
	var currency_pattern := RegEx.new()
	currency_pattern.compile("(?i)\\b(gold|mana|oro|man[aá])\\b")
	var matches: Array[RegExMatch] = currency_pattern.search_all(source_text)
	var cursor: int = 0
	for currency_match in matches:
		var match_start: int = currency_match.get_start(0)
		label.append_text(source_text.substr(cursor, match_start - cursor))
		var currency_text: String = currency_match.get_string(1).to_lower()
		var icon_name: StringName = &"gold" if currency_text in ["oro", "gold"] else &"mana"
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
	_tower_tab_button.set_pressed_no_signal(category == &"towers")
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
	_summary_label.text = "Ronda alcanzada %02d/20   ·   %d rondas completas   ·   +%d Meta Currency" % [
		reached_round,
		completed_rounds,
		reward,
	]
	_summary_label.tooltip_text = "Semilla de esta run: %d" % run_seed_value
	_currency_label.text = "META CURRENCY   %d" % int(MetaProgression.call("get_meta_currency"))
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

func _on_new_run_pressed() -> void:
	new_run_requested.emit()
