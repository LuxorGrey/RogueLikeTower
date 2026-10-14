class_name TowerRosterData
extends Resource

@export var profiles: Array[TowerData] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	var seen: Dictionary[StringName, bool] = {}
	for tower in profiles:
		if tower == null:
			errors.append("El roster contiene una torre vacía.")
			continue
		errors.append_array(tower.validate())
		if seen.has(tower.id):
			errors.append("El roster repite la torre %s." % tower.id)
		seen[tower.id] = true
	return errors
