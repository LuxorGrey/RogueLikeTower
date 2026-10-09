class_name WaveCampaignData
extends Resource

const CAMPAIGN_ROUND_COUNT: int = 45
const DIRECT_ENEMY_COUNT: int = 1093

@export var rounds: Array[WaveData] = []
@export_range(0.0, 0.25, 0.005) var health_growth_per_round: float = 0.0
@export_range(0.0, 0.1, 0.005) var base_damage_growth_per_round: float = 0.0
@export_range(0.0, 0.1, 0.005) var reward_growth_per_round: float = 0.0

func get_round(round_number: int) -> WaveData:
	if round_number < 1 or round_number > rounds.size():
		return null
	return rounds[round_number - 1]

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if rounds.size() != CAMPAIGN_ROUND_COUNT:
		errors.append("La campaña debe contener exactamente 45 rondas.")
	var direct_enemy_total: int = 0
	if health_growth_per_round < 0.0 or base_damage_growth_per_round < 0.0 or reward_growth_per_round < 0.0:
		errors.append("Los escalados de campaña no pueden ser negativos.")
	for round_index in range(rounds.size()):
		var wave: WaveData = rounds[round_index]
		if wave == null:
			errors.append("Falta WaveData para la ronda %d." % (round_index + 1))
			continue
		errors.append_array(wave.validate())
		if wave.round_number != round_index + 1:
			errors.append("La entrada %d debe ser la ronda %d." % [round_index, round_index + 1])
		var has_tier_2_boss: bool = false
		var has_boss: bool = false
		for group in wave.groups:
			if group == null or group.enemy_data == null:
				continue
			has_boss = has_boss or group.enemy_data.boss_tier > 0
			has_tier_2_boss = has_tier_2_boss or group.enemy_data.boss_tier >= 2
		var expected_type: int = WaveData.EncounterType.STANDARD
		if has_tier_2_boss:
			expected_type = WaveData.EncounterType.TIER_2_BOSS
		elif has_boss:
			expected_type = WaveData.EncounterType.BOSS
		if wave.encounter_type != expected_type:
			errors.append("El tipo de encuentro de la ronda %d no coincide con sus enemigos jefe." % wave.round_number)
		for group in wave.groups:
			if group != null:
				direct_enemy_total += group.count
	if direct_enemy_total != DIRECT_ENEMY_COUNT:
		errors.append("Las oleadas deben contener exactamente 1.093 enemigos directos; hay %d." % direct_enemy_total)
	return errors

func scale_enemy_for_round(enemy_data: EnemyData, round_number: int) -> EnemyData:
	if enemy_data == null:
		return null
	var scaled_enemy := enemy_data.duplicate() as EnemyData
	if scaled_enemy == null:
		return null
	var elapsed_rounds: int = maxi(round_number - 1, 0)
	scaled_enemy.max_health = maxi(1, roundi(float(enemy_data.max_health) * (1.0 + health_growth_per_round * elapsed_rounds)))
	scaled_enemy.base_damage = maxi(0, roundi(float(enemy_data.base_damage) * (1.0 + base_damage_growth_per_round * elapsed_rounds)))
	scaled_enemy.kill_reward = maxi(0, roundi(float(enemy_data.kill_reward) * (1.0 + reward_growth_per_round * elapsed_rounds)))
	return scaled_enemy
