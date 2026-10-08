class_name WaveData
extends Resource

@export_range(1, 20, 1) var round_number: int = 1
@export var groups: Array[WaveEnemyGroupData] = []
@export_range(0, 1000000, 1) var round_reward: int = 0

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if round_number <= 0:
		errors.append("La ronda debe ser mayor que cero.")
	if groups.is_empty():
		errors.append("WaveData requiere al menos un grupo.")
	if round_reward < 0:
		errors.append("La recompensa de ronda no puede ser negativa.")
	for group_index in range(groups.size()):
		var group: WaveEnemyGroupData = groups[group_index]
		if group == null:
			errors.append("WaveData contiene un grupo vacío en índice %d." % group_index)
		else:
			errors.append_array(group.validate())
	return errors
