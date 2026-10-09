extends Node

const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")

signal progress_changed
signal run_ended(summary: Dictionary)

const SAVE_PATH: String = "user://rogue_tower_meta.json"
const TEMP_SAVE_PATH: String = "user://rogue_tower_meta.json.tmp"
const BACKUP_SAVE_PATH: String = "user://rogue_tower_meta.json.bak"
const PROGRESSION_DATA: MetaProgressionData = preload("res://data/meta/demo_meta_progression.tres")

var last_error: String = ""
var current_run_seed: int = 0

var _save_data := SaveData.new()
var _tower_catalog: Dictionary[StringName, TowerData] = {}
var _upgrade_catalog: Dictionary[StringName, PermanentUpgradeData] = {}
var _active_run: bool = false
var _active_run_id: String = ""
var _save_blocked: bool = false

func _ready() -> void:
	var profile_errors := PROGRESSION_DATA.validate()
	if not profile_errors.is_empty():
		_save_blocked = true
		last_error = "Configuración meta inválida: %s" % "; ".join(profile_errors)
		push_error(last_error)
	for upgrade in PROGRESSION_DATA.permanent_upgrades:
		if upgrade != null:
			_upgrade_catalog[upgrade.id] = upgrade
	_load_progress()

func configure_tower_catalog(tower_profiles: Array[TowerData]) -> void:
	_tower_catalog.clear()
	for tower_data in tower_profiles:
		if tower_data == null or tower_data.unlock_id == &"":
			continue
		if _tower_catalog.has(tower_data.unlock_id):
			push_error("ID de desbloqueo de torre duplicado: %s" % tower_data.unlock_id)
			continue
		_tower_catalog[tower_data.unlock_id] = tower_data
	for starting_unlock in PROGRESSION_DATA.starting_unlocked_towers:
		if not _tower_catalog.has(starting_unlock):
			push_warning("El desbloqueo inicial '%s' no coincide con una TowerData." % starting_unlock)

func begin_run() -> int:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	current_run_seed = int(rng.seed)
	_active_run_id = "%d-%d" % [_save_data.total_runs_started + 1, current_run_seed]
	_active_run = true
	_save_data.total_runs_started += 1
	if not _save_progress():
		push_warning("No se pudo guardar el inicio de run: %s" % last_error)
	progress_changed.emit()
	return current_run_seed

func finish_run(outcome: StringName, reached_round: int, run_seed: int) -> Dictionary:
	if not _active_run:
		return _save_data.last_run_summary.duplicate(true)
	if outcome != &"VICTORY" and outcome != &"DEFEAT":
		last_error = "El resultado de run debe ser VICTORY o DEFEAT."
		return {}
	var safe_reached_round: int = clampi(reached_round, 1, 20)
	var completed_rounds: int = 20 if outcome == &"VICTORY" else maxi(safe_reached_round - 1, 0)
	var reward: int = PROGRESSION_DATA.base_run_reward + completed_rounds * PROGRESSION_DATA.reward_per_completed_round
	if outcome == &"VICTORY":
		reward += PROGRESSION_DATA.victory_bonus
	reward = mini(reward, PROGRESSION_DATA.maximum_run_reward)
	var previous_currency: int = _save_data.meta_currency
	_save_data.meta_currency = mini(_save_data.meta_currency + reward, SaveData.MAX_META_CURRENCY)
	_save_data.total_runs_completed += 1
	if outcome == &"VICTORY":
		_save_data.total_victories += 1
		_save_data.best_round_reached = maxi(_save_data.best_round_reached, 20)
	else:
		_save_data.best_round_reached = maxi(_save_data.best_round_reached, safe_reached_round)
	_save_data.total_meta_earned = mini(_save_data.total_meta_earned + (_save_data.meta_currency - previous_currency), SaveData.MAX_META_CURRENCY)
	_save_data.last_run_summary = {
		"run_id": _active_run_id,
		"outcome": String(outcome),
		"reached_round": safe_reached_round,
		"completed_rounds": completed_rounds,
		"meta_reward": _save_data.meta_currency - previous_currency,
		"meta_currency_total": _save_data.meta_currency,
		"run_number": _save_data.total_runs_started,
		"run_seed": run_seed,
	}
	_active_run = false
	if not _save_progress():
		push_warning("La run terminó, pero no se pudo persistir su recompensa meta: %s" % last_error)
	_save_data.last_run_summary["saved"] = not _save_blocked and last_error.is_empty()
	progress_changed.emit()
	var result := _save_data.last_run_summary.duplicate(true)
	run_ended.emit(result)
	return result

func get_meta_currency() -> int:
	return _save_data.meta_currency

func get_save_error() -> String:
	return last_error

func can_persist_progress() -> bool:
	return not _save_blocked

func get_last_run_summary() -> Dictionary:
	return _save_data.last_run_summary.duplicate(true)

func get_total_runs_started() -> int:
	return _save_data.total_runs_started

func get_best_round_reached() -> int:
	return _save_data.best_round_reached

func is_tower_unlocked(tower_data: TowerData) -> bool:
	if tower_data == null or tower_data.unlock_id == &"":
		return true
	return _save_data.unlocked_towers.has(tower_data.unlock_id)

func is_content_unlocked(content_id: StringName) -> bool:
	return get_unlocked_content_ids().has(content_id)

func get_unlocked_content_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for unlock_id in _save_data.unlocked_towers:
		if not result.has(unlock_id):
			result.append(unlock_id)
	for upgrade in PROGRESSION_DATA.permanent_upgrades:
		if upgrade == null:
			continue
		var current_level: int = _get_upgrade_level(upgrade)
		for level_index in range(current_level):
			var operation: PermanentUpgradeOperation = upgrade.operations_by_level[level_index]
			if operation.effect_type != PermanentUpgradeOperation.EffectType.UNLOCK_CONTENT:
				continue
			if not result.has(operation.unlocked_content_id):
				result.append(operation.unlocked_content_id)
	return result

func get_permanent_upgrades() -> Array[PermanentUpgradeData]:
	return PROGRESSION_DATA.permanent_upgrades.duplicate()

func get_unlocked_tower_ids() -> Array[StringName]:
	return _save_data.unlocked_towers.duplicate()

func get_upgrade_level(upgrade_id: StringName) -> int:
	var upgrade := _upgrade_catalog.get(upgrade_id) as PermanentUpgradeData
	if upgrade == null:
		return 0
	return _get_upgrade_level(upgrade)

func get_run_economy_bonuses() -> Dictionary:
	return {
		"starting_gold": roundi(_get_permanent_bonus(PermanentUpgradeOperation.EffectType.STARTING_GOLD_ADD)),
		"starting_mana": _get_permanent_bonus(PermanentUpgradeOperation.EffectType.STARTING_MANA_ADD),
		"maximum_mana": _get_permanent_bonus(PermanentUpgradeOperation.EffectType.MAXIMUM_MANA_ADD),
		"mana_regen_per_second": _get_permanent_bonus(PermanentUpgradeOperation.EffectType.MANA_REGEN_ADD),
	}

func get_chest_spawn_chance() -> float:
	return clampf(
		TERRAIN_VISUAL_CATALOG_SCRIPT.BASE_CHEST_CHANCE
			+ _get_permanent_bonus(PermanentUpgradeOperation.EffectType.CHEST_SPAWN_CHANCE_ADD),
		TERRAIN_VISUAL_CATALOG_SCRIPT.BASE_CHEST_CHANCE,
		TERRAIN_VISUAL_CATALOG_SCRIPT.MAX_CHEST_CHANCE
	)

func get_tower_damage_multiplier(tower_id: StringName) -> float:
	var multiplier: float = 1.0
	for upgrade in PROGRESSION_DATA.permanent_upgrades:
		if upgrade == null:
			continue
		for level_index in range(_get_upgrade_level(upgrade)):
			var operation: PermanentUpgradeOperation = upgrade.operations_by_level[level_index]
			if operation.effect_type != PermanentUpgradeOperation.EffectType.TOWER_DAMAGE_MULTIPLIER:
				continue
			if operation.affected_tower_id != &"" and operation.affected_tower_id != tower_id:
				continue
			multiplier *= operation.value
	return clampf(multiplier, 0.0, 4.0)

func can_purchase_tower(unlock_id: StringName) -> bool:
	var tower_data := _tower_catalog.get(unlock_id) as TowerData
	return (
		not _save_blocked
		and tower_data != null
		and tower_data.meta_unlock_cost > 0
		and not _save_data.unlocked_towers.has(unlock_id)
		and _save_data.meta_currency >= tower_data.meta_unlock_cost
	)

func purchase_tower(unlock_id: StringName) -> bool:
	last_error = ""
	if _save_blocked:
		last_error = "El guardado no es compatible o está dañado; se conserva intacto y la tienda queda desactivada."
		return false
	var tower_data := _tower_catalog.get(unlock_id) as TowerData
	if tower_data == null or tower_data.meta_unlock_cost <= 0:
		last_error = "No existe una compra válida para la torre seleccionada."
		return false
	if _save_data.unlocked_towers.has(unlock_id):
		last_error = "Esa torre ya está desbloqueada."
		return false
	if _save_data.meta_currency < tower_data.meta_unlock_cost:
		last_error = "Moneda meta insuficiente: %d disponibles · %d necesarios." % [_save_data.meta_currency, tower_data.meta_unlock_cost]
		return false
	var previous_currency: int = _save_data.meta_currency
	_save_data.meta_currency -= tower_data.meta_unlock_cost
	_save_data.unlocked_towers.append(unlock_id)
	if not _save_progress():
		_save_data.meta_currency = previous_currency
		_save_data.unlocked_towers.erase(unlock_id)
		return false
	progress_changed.emit()
	return true

func can_purchase_upgrade(upgrade_id: StringName) -> bool:
	var upgrade := _upgrade_catalog.get(upgrade_id) as PermanentUpgradeData
	if _save_blocked or upgrade == null:
		return false
	var current_level: int = _get_upgrade_level(upgrade)
	var cost: int = upgrade.get_cost_for_next_level(current_level)
	if cost < 0 or _save_data.meta_currency < cost:
		return false
	for prerequisite in upgrade.prerequisites:
		if int(_save_data.permanent_upgrade_levels.get(prerequisite, 0)) <= 0:
			return false
	return true

func purchase_upgrade(upgrade_id: StringName) -> bool:
	last_error = ""
	if _save_blocked:
		last_error = "El guardado no es compatible o está dañado; se conserva intacto y la tienda queda desactivada."
		return false
	var upgrade := _upgrade_catalog.get(upgrade_id) as PermanentUpgradeData
	if upgrade == null:
		last_error = "No existe la mejora permanente seleccionada."
		return false
	var current_level: int = _get_upgrade_level(upgrade)
	var cost: int = upgrade.get_cost_for_next_level(current_level)
	if cost < 0:
		last_error = "La mejora ya alcanzó su nivel máximo."
		return false
	for prerequisite in upgrade.prerequisites:
		if int(_save_data.permanent_upgrade_levels.get(prerequisite, 0)) <= 0:
			last_error = "Falta el prerrequisito '%s'." % prerequisite
			return false
	if _save_data.meta_currency < cost:
		last_error = "Moneda meta insuficiente: %d disponibles · %d necesarios." % [_save_data.meta_currency, cost]
		return false
	var previous_currency: int = _save_data.meta_currency
	_save_data.meta_currency -= cost
	_save_data.permanent_upgrade_levels[upgrade_id] = current_level + 1
	if not _save_progress():
		_save_data.meta_currency = previous_currency
		if current_level == 0:
			_save_data.permanent_upgrade_levels.erase(upgrade_id)
		else:
			_save_data.permanent_upgrade_levels[upgrade_id] = current_level
		return false
	progress_changed.emit()
	return true

func _get_upgrade_level(upgrade: PermanentUpgradeData) -> int:
	if upgrade == null:
		return 0
	return clampi(int(_save_data.permanent_upgrade_levels.get(upgrade.id, 0)), 0, upgrade.max_level)

func _get_permanent_bonus(effect_type: int) -> float:
	var total: float = 0.0
	for upgrade in PROGRESSION_DATA.permanent_upgrades:
		if upgrade == null:
			continue
		for level_index in range(_get_upgrade_level(upgrade)):
			var operation: PermanentUpgradeOperation = upgrade.operations_by_level[level_index]
			if operation.effect_type == effect_type:
				total += operation.value
	return total

func _load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_save_data = _create_default_save()
		if not _save_progress():
			push_warning("No se pudo crear el guardado de meta-progresión: %s" % last_error)
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_save_blocked = true
		last_error = "No se pudo abrir el guardado existente: %s" % error_string(FileAccess.get_open_error())
		_save_data = _create_default_save()
		push_error(last_error)
		return
	var raw_text: String = file.get_as_text()
	file.close()
	var parser := JSON.new()
	var parse_error: Error = parser.parse(raw_text)
	if parse_error != OK or not parser.data is Dictionary:
		_save_blocked = true
		last_error = "El guardado existente está dañado; no se sobrescribirá."
		_save_data = _create_default_save()
		push_error(last_error)
		return
	var loaded := SaveData.new()
	var validation_errors: PackedStringArray = loaded.load_dictionary(parser.data)
	if not validation_errors.is_empty():
		_save_blocked = true
		last_error = "Guardado no compatible: %s" % "; ".join(validation_errors)
		_save_data = _create_default_save()
		push_error(last_error)
		return
	_save_data = loaded
	var defaults_added: bool = loaded.migration_required
	for starting_unlock in PROGRESSION_DATA.starting_unlocked_towers:
		if _save_data.unlocked_towers.has(starting_unlock):
			continue
		_save_data.unlocked_towers.append(starting_unlock)
		defaults_added = true
	if defaults_added:
		if not _save_progress():
			push_warning("No se pudo persistir el unlock inicial: %s" % last_error)
	else:
		last_error = ""

func _create_default_save() -> SaveData:
	var defaults := SaveData.new()
	defaults.unlocked_towers = PROGRESSION_DATA.starting_unlocked_towers.duplicate()
	return defaults

func _save_progress() -> bool:
	if _save_blocked:
		last_error = "El guardado existente se conserva porque su formato no es válido."
		return false
	var file := FileAccess.open(TEMP_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		last_error = "No se pudo abrir el archivo temporal de guardado: %s" % error_string(FileAccess.get_open_error())
		return false
	file.store_line(JSON.stringify(_save_data.to_dictionary(), "\t"))
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		last_error = "No se pudieron escribir los datos de meta-progresión (%s)." % error_string(write_error)
		return false
	var absolute_save_path: String = ProjectSettings.globalize_path(SAVE_PATH)
	var absolute_temp_path: String = ProjectSettings.globalize_path(TEMP_SAVE_PATH)
	var absolute_backup_path: String = ProjectSettings.globalize_path(BACKUP_SAVE_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		if FileAccess.file_exists(BACKUP_SAVE_PATH):
			var backup_remove_error: Error = DirAccess.remove_absolute(absolute_backup_path)
			if backup_remove_error != OK:
				last_error = "No se pudo actualizar la copia de seguridad (%s)." % error_string(backup_remove_error)
				DirAccess.remove_absolute(absolute_temp_path)
				return false
		var backup_error: Error = DirAccess.copy_absolute(absolute_save_path, absolute_backup_path)
		if backup_error != OK:
			last_error = "No se pudo crear la copia de seguridad (%s)." % error_string(backup_error)
			DirAccess.remove_absolute(absolute_temp_path)
			return false
		var remove_error: Error = DirAccess.remove_absolute(absolute_save_path)
		if remove_error != OK:
			last_error = "No se pudo reemplazar el guardado anterior (%s)." % error_string(remove_error)
			DirAccess.remove_absolute(absolute_temp_path)
			return false
	var rename_error: Error = DirAccess.rename_absolute(absolute_temp_path, absolute_save_path)
	if rename_error != OK:
		if FileAccess.file_exists(BACKUP_SAVE_PATH) and not FileAccess.file_exists(SAVE_PATH):
			DirAccess.copy_absolute(absolute_backup_path, absolute_save_path)
		last_error = "No se pudo finalizar el guardado (%s)." % error_string(rename_error)
		return false
	last_error = ""
	return true
