class_name MetaShopPanel
extends CanvasLayer

signal new_run_requested

var _tower_profiles: Array[TowerData] = []
var _permanent_upgrades: Array[PermanentUpgradeData] = []
var _run_summary: Dictionary = {}
var _is_open: bool = false
var _debug_access_active: bool = false

@onready var _currency_label: Label = %CurrencyLabel
@onready var _summary_label: Label = %SummaryLabel
@onready var _outcome_label: Label = %OutcomeLabel
@onready var _debug_close_button: Button = %DebugCloseButton
@onready var _status_label: Label = %StatusLabel
@onready var _progression_map: MetaProgressionMap = %ProgressionMap

func configure(tower_profiles: Array[TowerData], permanent_upgrades: Array[PermanentUpgradeData]) -> void:
	_tower_profiles = tower_profiles.duplicate()
	_permanent_upgrades = permanent_upgrades.duplicate()

func _ready() -> void:
	layer = 10
	_progression_map.configure(_tower_profiles, _permanent_upgrades)
	_progression_map.node_selected.connect(_on_progression_node_selected)
	%NewRunButton.pressed.connect(_on_new_run_pressed)
	_debug_close_button.pressed.connect(_close_debug_access)
	_debug_close_button.hide()
	MetaProgression.progress_changed.connect(_refresh)
	hide()

func is_open() -> bool:
	return _is_open

func present(run_summary: Dictionary) -> void:
	_run_summary = run_summary.duplicate(true)
	_is_open = true
	_debug_access_active = false
	_debug_close_button.hide()
	_status_label.text = ""
	visible = true
	_refresh()

func present_for_debug() -> void:
	_run_summary = {"outcome": "DEBUG", "reached_round": 1, "completed_rounds": 0, "meta_reward": 0, "run_seed": 0}
	_is_open = true
	_debug_access_active = true
	_debug_close_button.show()
	_status_label.text = ""
	visible = true
	_refresh()

func _close_debug_access() -> void:
	if not _debug_access_active:
		return
	_debug_access_active = false
	_is_open = false
	hide()

func _refresh() -> void:
	if _currency_label == null or _progression_map == null:
		return
	var outcome: String = String(_run_summary.get("outcome", "MENU"))
	match outcome:
		"DEBUG":
			_outcome_label.text = "MAPA DE MEJORAS · DEPURACIÓN"
			_outcome_label.add_theme_color_override("font_color", Color("#f1cf78"))
			_summary_label.text = "Las compras permanentes se aplican desde la siguiente run."
		"VICTORY":
			_outcome_label.text = "RUN COMPLETADA"
			_outcome_label.add_theme_color_override("font_color", Color("#8fca8c"))
			_summary_label.text = _format_run_summary("Victoria")
		"DEFEAT":
			_outcome_label.text = "DERROTA · VUELVE A INTENTARLO"
			_outcome_label.add_theme_color_override("font_color", Color("#e58a72"))
			_summary_label.text = _format_run_summary("Derrota")
		"ABANDONED":
			_outcome_label.text = "RUN FINALIZADA"
			_outcome_label.add_theme_color_override("font_color", Color("#e0b85e"))
			_summary_label.text = _format_run_summary("Run finalizada")
		_:
			_outcome_label.text = "MAPA DE MEJORAS"
			_outcome_label.add_theme_color_override("font_color", Color("#f1cf78"))
			_summary_label.text = "Desbloquea una card para abrir la siguiente parte del árbol. Las compras se aplican en la próxima run."
	if outcome == "DEBUG":
		_summary_label.tooltip_text = "Acceso de depuración al mapa de mejoras permanentes."
	else:
		_summary_label.tooltip_text = "La tienda se mantiene como progreso permanente entre runs."
	_currency_label.text = "XP DE PERFIL   %d" % int(MetaProgression.call("get_meta_currency"))
	_progression_map.refresh()
	var can_save: bool = bool(MetaProgression.call("can_persist_progress"))
	if not can_save:
		_status_label.text = String(MetaProgression.call("get_save_error"))
		_status_label.add_theme_color_override("font_color", Color("#e58a72"))
	elif not bool(_run_summary.get("saved", true)) and not _status_label.text.begins_with("Desbloqueada") and not _status_label.text.begins_with("Mejora comprada") and not _status_label.text.begins_with("Error:"):
		_status_label.text = "La recompensa de esta run no se guardó: %s" % String(MetaProgression.call("get_save_error"))
		_status_label.add_theme_color_override("font_color", Color("#e58a72"))
	elif not _status_label.text.begins_with("Desbloqueada") and not _status_label.text.begins_with("Mejora comprada") and not _status_label.text.begins_with("Error:"):
		_status_label.text = "Haz clic en una card disponible. Los nodos bloqueados muestran sus requisitos al pasar el cursor."
		_status_label.add_theme_color_override("font_color", Color("#aebbc0"))

func _format_run_summary(outcome_label: String) -> String:
	var reached_round: int = int(_run_summary.get("reached_round", 1))
	var completed_rounds: int = int(_run_summary.get("completed_rounds", 0))
	var reward: int = int(_run_summary.get("meta_reward", 0))
	var summary: String = "%s · ronda %02d/45 · %d completas · +%d XP" % [
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
		_status_label.text = "Desbloqueada: la torre podrá aparecer como card en las próximas runs." if purchased else "Error: %s" % String(MetaProgression.call("get_save_error"))
	else:
		purchased = bool(MetaProgression.call("purchase_upgrade", node_id))
		_status_label.text = "Mejora comprada: se aplicará desde la siguiente run." if purchased else "Error: %s" % String(MetaProgression.call("get_save_error"))
	_status_label.add_theme_color_override("font_color", Color("#8fca8c") if purchased else Color("#e58a72"))
	if purchased:
		_progression_map.play_unlock_burst(local_position)
	_refresh()

func _on_new_run_pressed() -> void:
	new_run_requested.emit()
