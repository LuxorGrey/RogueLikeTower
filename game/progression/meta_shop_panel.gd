class_name MetaShopPanel
extends CanvasLayer

signal close_requested

var _tower_profiles: Array[TowerData] = []
var _permanent_upgrades: Array[PermanentUpgradeData] = []
var _run_summary: Dictionary = {}
var _is_open: bool = false
var _pan_button: int = MOUSE_BUTTON_NONE
var _pan_origin: Vector2 = Vector2.ZERO
var _pan_last_position: Vector2 = Vector2.ZERO
var _pan_dragging: bool = false

@export_group("Outcome colors")
@export var menu_color: Color = Color("#f1cf78")
@export var debug_color: Color = Color("#f1cf78")
@export var victory_color: Color = Color("#8fca8c")
@export var defeat_color: Color = Color("#e58a72")
@export var abandoned_color: Color = Color("#e0b85e")

@onready var _currency_label: Label = %CurrencyLabel
@onready var _summary_label: RichTextLabel = %SummaryLabel
@onready var _outcome_label: Label = %OutcomeLabel
@onready var _close_button: Button = %CloseButton
@onready var _progression_map: MetaProgressionMap = %ProgressionMap
@onready var _scroll: ScrollContainer = %Scroll

func configure(tower_profiles: Array[TowerData], permanent_upgrades: Array[PermanentUpgradeData]) -> void:
	_tower_profiles = tower_profiles.duplicate()
	_permanent_upgrades = permanent_upgrades.duplicate()

func _ready() -> void:
	layer = 10
	_progression_map.configure(_tower_profiles, _permanent_upgrades)
	_progression_map.node_selected.connect(_on_progression_node_selected)
	_close_button.pressed.connect(_close_map)
	MetaProgression.progress_changed.connect(_refresh)
	hide()

func is_open() -> bool:
	return _is_open

func present(run_summary: Dictionary) -> void:
	_run_summary = run_summary.duplicate(true)
	_is_open = true
	_close_button.tooltip_text = "Volver al menú principal"
	visible = true
	_refresh()

func present_for_debug() -> void:
	_run_summary = {"outcome": "DEBUG", "reached_round": 1, "completed_rounds": 0, "meta_reward": 0, "run_seed": 0}
	_is_open = true
	_close_button.tooltip_text = "Volver al tablero"
	visible = true
	_refresh()

func _close_map() -> void:
	_is_open = false
	_pan_button = MOUSE_BUTTON_NONE
	_pan_dragging = false
	hide()
	close_requested.emit()

func _refresh() -> void:
	if _currency_label == null or _progression_map == null:
		return
	var outcome: String = String(_run_summary.get("outcome", "MENU"))
	match outcome:
		"DEBUG":
			_outcome_label.text = "MAPA DE MEJORAS · DEPURACIÓN"
			_outcome_label.add_theme_color_override("font_color", debug_color)
			_summary_label.hide()
		"VICTORY":
			_outcome_label.text = "RUN COMPLETADA"
			_outcome_label.add_theme_color_override("font_color", victory_color)
			_summary_label.text = _format_run_summary("Victoria")
			_summary_label.show()
		"DEFEAT":
			_outcome_label.text = "DERROTA · VUELVE A INTENTARLO"
			_outcome_label.add_theme_color_override("font_color", defeat_color)
			_summary_label.text = _format_run_summary("Derrota")
			_summary_label.show()
		"ABANDONED":
			_outcome_label.text = "RUN FINALIZADA"
			_outcome_label.add_theme_color_override("font_color", abandoned_color)
			_summary_label.text = _format_run_summary("Run finalizada")
			_summary_label.show()
		_:
			_outcome_label.text = "MAPA DE MEJORAS"
			_outcome_label.add_theme_color_override("font_color", menu_color)
			_summary_label.hide()
	_currency_label.text = "%d" % int(MetaProgression.call("get_meta_currency"))
	_progression_map.refresh()
	var can_save: bool = bool(MetaProgression.call("can_persist_progress"))
	if not can_save:
		_currency_label.tooltip_text = String(MetaProgression.call("get_save_error"))
	elif not bool(_run_summary.get("saved", true)):
		_currency_label.tooltip_text = "La recompensa de esta run no se guardó: %s" % String(MetaProgression.call("get_save_error"))
	else:
		_currency_label.tooltip_text = "Saldo disponible para las mejoras permanentes."

func _format_run_summary(outcome_label: String) -> String:
	var reached_round: int = int(_run_summary.get("reached_round", 1))
	var completed_rounds: int = int(_run_summary.get("completed_rounds", 0))
	var reward: int = int(_run_summary.get("meta_reward", 0))
	var summary: String = "%s · ronda %02d/45 · %d completas · [img=18x18]res://assets/sprites/ui/icons/exp.png[/img] +%d" % [
		outcome_label,
		reached_round,
		completed_rounds,
		reward,
	]
	var tower_entries: Array = _run_summary.get("tower_summary", [])
	var tower_lines: Array[String] = []
	for entry_variant in tower_entries:
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = entry_variant
		var tower_id: StringName = StringName(entry.get("tower_id", ""))
		var display_name: String = String(tower_id)
		for tower_data in _tower_profiles:
			if tower_data != null and tower_data.id == tower_id:
				display_name = tower_data.display_name
				break
		tower_lines.append("%s ×%d · %d daño" % [display_name, int(entry.get("count", 0)), int(entry.get("damage", 0))])
	if not tower_lines.is_empty():
		summary += "\n" + "   ·   ".join(tower_lines)
	return summary

func _on_progression_node_selected(node_kind: StringName, node_id: StringName, local_position: Vector2) -> void:
	var purchased: bool = false
	if node_kind == &"tower":
		purchased = bool(MetaProgression.call("purchase_tower", node_id))
	else:
		purchased = bool(MetaProgression.call("purchase_upgrade", node_id))
	if purchased:
		_progression_map.play_unlock_burst(local_position)
	else:
		push_warning("No se pudo comprar '%s': %s" % [node_id, String(MetaProgression.call("get_save_error"))])
	_refresh()

func _input(event: InputEvent) -> void:
	if not _is_open or not _scroll.visible:
		return
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE]:
			if button_event.pressed and _scroll.get_global_rect().has_point(button_event.position):
				if button_event.button_index == MOUSE_BUTTON_LEFT and _is_pointer_over_upgrade_node(button_event.position):
					return
				_pan_button = button_event.button_index
				_pan_origin = button_event.position
				_pan_last_position = button_event.position
				_pan_dragging = false
			elif not button_event.pressed and button_event.button_index == _pan_button:
				if _pan_dragging:
					get_viewport().set_input_as_handled()
				_pan_button = MOUSE_BUTTON_NONE
				_pan_dragging = false
	elif event is InputEventMouseMotion and _pan_button != MOUSE_BUTTON_NONE:
		var motion := event as InputEventMouseMotion
		if not _pan_dragging and motion.position.distance_to(_pan_origin) >= 8.0:
			_pan_dragging = true
		if _pan_dragging:
			var delta: Vector2 = motion.position - _pan_last_position
			_scroll.scroll_horizontal = maxi(_scroll.scroll_horizontal - roundi(delta.x), 0)
			_scroll.scroll_vertical = maxi(_scroll.scroll_vertical - roundi(delta.y), 0)
			get_viewport().set_input_as_handled()
		_pan_last_position = motion.position

func _is_pointer_over_upgrade_node(pointer_position: Vector2) -> bool:
	for child in _progression_map.get_children():
		if child is MetaUpgradeNode and child.get_global_rect().has_point(pointer_position):
			return true
	return false
