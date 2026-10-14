extends Node

enum Phase {
	RUN_SETUP,
	ROUND_PREP,
	COMBAT,
	ROUND_REWARD,
	TERRAIN_EXPANSION,
	CARD_OFFER,
	ROUND_TRANSITION,
	RUN_VICTORY,
	RUN_DEFEAT,
}

signal phase_changed(new_phase: int)

var phase: Phase = Phase.RUN_SETUP
var _run_tower_ids: Dictionary[StringName, bool] = {}
var _tower_id_by_instance: Dictionary[int, StringName] = {}
var _tower_build_counts: Dictionary[StringName, int] = {}
var _tower_damage_totals: Dictionary[StringName, int] = {}

func begin_run() -> void:
	_run_tower_ids.clear()
	_run_tower_ids[&"ballista_demo"] = true
	_tower_id_by_instance.clear()
	_tower_build_counts.clear()
	_tower_damage_totals.clear()
	transition_to(Phase.RUN_SETUP)

func grant_tower(tower_id: StringName) -> bool:
	if tower_id == &"" or _run_tower_ids.has(tower_id):
		return false
	_run_tower_ids[tower_id] = true
	return true

func has_tower_in_run(tower_id: StringName) -> bool:
	return _run_tower_ids.has(tower_id)

func get_run_tower_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for tower_id in _run_tower_ids:
		result.append(tower_id)
	return result

func record_tower_built(instance_id: int, tower_id: StringName) -> void:
	if instance_id <= 0 or tower_id == &"":
		return
	_tower_id_by_instance[instance_id] = tower_id
	_tower_build_counts[tower_id] = int(_tower_build_counts.get(tower_id, 0)) + 1

func record_tower_damage(instance_id: int, damage: int) -> void:
	if damage <= 0 or not _tower_id_by_instance.has(instance_id):
		return
	var tower_id: StringName = _tower_id_by_instance[instance_id]
	_tower_damage_totals[tower_id] = int(_tower_damage_totals.get(tower_id, 0)) + damage

func get_tower_run_summary(unlocked_tower_ids: Array[StringName]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for tower_id in _tower_build_counts:
		if not unlocked_tower_ids.has(StringName("tower:%s" % tower_id)):
			continue
		result.append({
			"tower_id": String(tower_id),
			"count": int(_tower_build_counts[tower_id]),
			"damage": int(_tower_damage_totals.get(tower_id, 0)),
		})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a.get("tower_id", "")) < String(b.get("tower_id", ""))
	)
	return result

func transition_to(next_phase: Phase) -> void:
	if phase == next_phase:
		return
	phase = next_phase
	phase_changed.emit(phase)
