class_name SaveData
extends RefCounted

const CURRENT_VERSION: int = 1
const MAX_META_CURRENCY: int = 1000000000

var meta_currency: int = 0
var unlocked_towers: Array[StringName] = []
var permanent_upgrade_levels: Dictionary[StringName, int] = {}
var settings: Dictionary = {}
var total_runs_started: int = 0
var total_runs_completed: int = 0
var total_victories: int = 0
var best_round_reached: int = 0
var total_meta_earned: int = 0
var last_run_summary: Dictionary = {}
var migration_required: bool = false

func to_dictionary() -> Dictionary:
	var saved_upgrade_levels: Dictionary = {}
	for upgrade_id in permanent_upgrade_levels:
		saved_upgrade_levels[String(upgrade_id)] = int(permanent_upgrade_levels[upgrade_id])
	var saved_unlocks: Array[String] = []
	for unlock_id in unlocked_towers:
		saved_unlocks.append(String(unlock_id))
	return {
		"version": CURRENT_VERSION,
		"meta_currency": meta_currency,
		"unlocked_towers": saved_unlocks,
		"permanent_upgrade_levels": saved_upgrade_levels,
		"settings": settings.duplicate(true),
		"total_runs_started": total_runs_started,
		"total_runs_completed": total_runs_completed,
		"total_victories": total_victories,
		"best_round_reached": best_round_reached,
		"total_meta_earned": total_meta_earned,
		"last_run_summary": last_run_summary.duplicate(true),
	}

func load_dictionary(data: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var version_value: Variant = data.get("version", 0)
	var source_version: int = -1
	if version_value is int:
		source_version = int(version_value)
	elif version_value is float and is_finite(float(version_value)) and is_equal_approx(float(version_value), roundf(float(version_value))):
		source_version = int(roundf(float(version_value)))
	if source_version < 0 or source_version > CURRENT_VERSION:
		errors.append("La versión %s no se puede migrar a la versión %d." % [str(version_value), CURRENT_VERSION])
		return errors
	var currency_value: Variant = data.get("meta_currency", 0)
	if not _is_integral_number(currency_value) or int(roundf(float(currency_value))) < 0 or int(roundf(float(currency_value))) > MAX_META_CURRENCY:
		errors.append("La moneda meta del guardado está fuera de rango.")
	var unlocks_value: Variant = data.get("unlocked_towers", [])
	if not unlocks_value is Array:
		errors.append("La lista de torres desbloqueadas no es válida.")
	var levels_value: Variant = data.get("permanent_upgrade_levels", {})
	if not levels_value is Dictionary:
		errors.append("Los niveles permanentes guardados no son válidos.")
	var settings_value: Variant = data.get("settings", {})
	if not settings_value is Dictionary:
		errors.append("Los ajustes guardados no son válidos.")
	var summary_value: Variant = data.get("last_run_summary", {})
	if not summary_value is Dictionary:
		errors.append("El resumen de run guardado no es válido.")
	for field_name in ["total_runs_started", "total_runs_completed", "total_victories", "best_round_reached", "total_meta_earned"]:
		var counter: Variant = data.get(field_name, 0)
		if not _is_integral_number(counter) or int(roundf(float(counter))) < 0 or int(roundf(float(counter))) > MAX_META_CURRENCY:
			errors.append("El contador '%s' del guardado no es válido." % field_name)
	if not errors.is_empty():
		return errors

	meta_currency = int(roundf(float(currency_value)))
	migration_required = source_version != CURRENT_VERSION
	for unlock_variant in unlocks_value:
		if not unlock_variant is String:
			errors.append("La lista de desbloqueos contiene un ID no textual.")
			continue
		var unlock_id := StringName(String(unlock_variant).strip_edges())
		if unlock_id == &"":
			continue
		if not unlocked_towers.has(unlock_id):
			unlocked_towers.append(unlock_id)
	for raw_upgrade_id in levels_value:
		var level_value: Variant = levels_value[raw_upgrade_id]
		if not raw_upgrade_id is String or not _is_integral_number(level_value) or int(roundf(float(level_value))) < 0 or int(roundf(float(level_value))) > 20:
			errors.append("El nivel guardado de una mejora no es válido.")
			continue
		permanent_upgrade_levels[StringName(String(raw_upgrade_id))] = int(roundf(float(level_value)))
	settings = settings_value.duplicate(true)
	last_run_summary = summary_value.duplicate(true)
	total_runs_started = int(roundf(float(data.get("total_runs_started", 0))))
	total_runs_completed = int(roundf(float(data.get("total_runs_completed", 0))))
	total_victories = int(roundf(float(data.get("total_victories", 0))))
	best_round_reached = int(roundf(float(data.get("best_round_reached", 0))))
	total_meta_earned = int(roundf(float(data.get("total_meta_earned", 0))))
	return errors

static func _is_integral_number(value: Variant) -> bool:
	if value is int:
		return true
	if value is float and is_finite(float(value)):
		return is_equal_approx(float(value), roundf(float(value)))
	return false
