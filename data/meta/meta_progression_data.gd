class_name MetaProgressionData
extends Resource

@export var starting_unlocked_towers: Array[StringName] = [&"tower:ballista_demo"]
@export var permanent_upgrades: Array[PermanentUpgradeData] = []
@export_range(0, 1000000, 1) var base_run_reward: int = 5
@export_range(0, 1000000, 1) var reward_per_completed_round: int = 5
@export_range(0, 1000000, 1) var victory_bonus: int = 30
@export_range(0, 1000000000, 1) var maximum_run_reward: int = 1000

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if base_run_reward < 0 or reward_per_completed_round < 0 or victory_bonus < 0:
		errors.append("Las recompensas de run no pueden ser negativas.")
	if maximum_run_reward < 0:
		errors.append("La recompensa máxima no puede ser negativa.")
	if maximum_run_reward < base_run_reward:
		errors.append("La recompensa máxima no puede ser menor que la recompensa base.")
	var seen_towers: Dictionary[StringName, bool] = {}
	for unlock_id in starting_unlocked_towers:
		if unlock_id == &"" or seen_towers.has(unlock_id):
			errors.append("Los desbloqueos iniciales deben ser IDs no vacíos y únicos.")
			break
		seen_towers[unlock_id] = true
	var seen_upgrades: Dictionary[StringName, bool] = {}
	for upgrade in permanent_upgrades:
		if upgrade == null:
			errors.append("El catálogo contiene una mejora permanente vacía.")
			continue
		errors.append_array(upgrade.validate())
		if seen_upgrades.has(upgrade.id):
			errors.append("El catálogo contiene IDs de mejoras permanentes duplicados.")
		seen_upgrades[upgrade.id] = true
	for upgrade in permanent_upgrades:
		if upgrade == null:
			continue
		for prerequisite in upgrade.prerequisites:
			if not seen_upgrades.has(prerequisite):
				errors.append("El prerrequisito '%s' no existe en el catálogo." % prerequisite)
	return errors
