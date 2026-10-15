class_name RunCardService
extends Node

enum OperationType {
	TOWER_DAMAGE_ADD,
	TOWER_DAMAGE_MULTIPLIER,
	TOWER_RANGE_ADD,
	TOWER_ATTACK_RATE_MULTIPLIER,
	TOWER_AREA_RADIUS_ADD,
	TOWER_MANA_COST_MULTIPLIER,
	STATUS_DURATION_MULTIPLIER,
	MANA_MAX_ADD,
	MANA_REGEN_ADD,
	TOWER_CRIT_CHANCE_ADD,
	TOWER_HIT_POINT_MULTIPLIER_ADD,
	TOWER_STATUS_DAMAGE_BONUS,
	TOWER_SLOW_FRACTION_ADD,
	TOWER_ELEVATION_RANGE_BONUS_MULTIPLIER_ADD,
	TOWER_AREA_RADIUS_MULTIPLIER_ADD,
	STATUS_MAX_DAMAGE_PER_SECOND_ADD,
	STATUS_CONDITION_LAYER_DAMAGE_ADD,
	STATUS_CRIT_CHANCE_ADD,
	STATUS_CRIT_DAMAGE_CONVERSION_ADD,
	STATUS_SLOW_DAMAGE_SCALING_ADD,
	STATUS_POISON_SLOW_FRACTION_ADD,
	TOWER_CRIT_CHANCE_PER_LEVEL_ADD,
	TOWER_MANA_COST_DAMAGE_RATIO_ADD,
	MANA_REGEN_MAX_PERCENT_ADD,
	MANA_ON_KILL_MAX_PERCENT_ADD,
	GOLD_PER_KILL_ADD,
	ENEMY_BASE_DAMAGE_ADD,
	BASE_MAX_HEALTH_ADD,
	STATUS_STRENGTH_CAP_ADD,
}

signal card_selected(card: Resource)
signal modifiers_changed

const FIXED_UPGRADE_OFFER_SIZE: int = CardPoolData.FIXED_OFFER_SIZE

var last_error: String = ""
var _pool: Resource
var _unlocked_content_ids: Dictionary = {}
var _current_offer: Array[Resource] = []
var _selected_cards: Array[Resource] = []
var _active_operations: Array[Resource] = []
var _selected_counts: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _is_configured: bool = false
var _debug_unlock_all: bool = false
var _run_tower_ids: Dictionary[StringName, bool] = {}

func configure(
	card_pool: Resource,
	unlocked_content_ids: Array[StringName],
	run_seed: int = 0,
	use_run_seed: bool = false,
	run_tower_ids: Array[StringName] = []
) -> bool:
	last_error = ""
	if card_pool == null or not card_pool.has_method("validate"):
		last_error = "RunCardService requiere un CardPoolData válido."
		return false
	var errors: PackedStringArray = card_pool.call("validate")
	if not errors.is_empty():
		last_error = "; ".join(errors)
		return false
	_pool = card_pool
	_run_tower_ids.clear()
	for tower_id in run_tower_ids:
		_run_tower_ids[tower_id] = true
	_unlocked_content_ids.clear()
	for content_id in unlocked_content_ids:
		_unlocked_content_ids[content_id] = true
	_current_offer.clear()
	_selected_cards.clear()
	_active_operations.clear()
	_selected_counts.clear()
	if use_run_seed:
		_rng.seed = run_seed
	else:
		_rng.randomize()
	_is_configured = true
	return true

func set_debug_unlock_all_enabled(enabled: bool) -> void:
	_debug_unlock_all = enabled

func should_offer_after(round_number: int) -> bool:
	return _is_configured and bool(_pool.call("should_offer_after", round_number))

func create_offer(round_number: int) -> Array[Resource]:
	var empty_offer: Array[Resource] = []
	if not should_offer_after(round_number):
		return empty_offer
	if not _current_offer.is_empty():
		return _current_offer.duplicate()
	var recruit_cards: Array[Resource] = []
	var upgrade_cards: Array[Resource] = []
	var pool_cards: Array = _pool.call("get_all_cards")
	for card_variant in pool_cards:
		var card := card_variant as Resource
		if card == null or not _is_card_available(card):
			continue
		if StringName(card.get("grant_tower_id")) != &"":
			recruit_cards.append(card)
		else:
			upgrade_cards.append(card)
	# Las torres pendientes se reparten aleatoriamente entre ofertas y comparten
	# los mismos tres espacios con mejoras. Si no salen, siguen disponibles.
	_shuffle_resources(recruit_cards)
	for recruit_index in range(mini(recruit_cards.size(), FIXED_UPGRADE_OFFER_SIZE)):
		_current_offer.append(recruit_cards[recruit_index])
	while _current_offer.size() < FIXED_UPGRADE_OFFER_SIZE and not upgrade_cards.is_empty():
		var selected_index: int = _pick_weighted_index(upgrade_cards)
		_current_offer.append(upgrade_cards[selected_index])
		upgrade_cards.remove_at(selected_index)
	if _current_offer.size() != FIXED_UPGRADE_OFFER_SIZE:
		last_error = "No hay suficientes cartas desbloqueadas para completar la oferta."
		_current_offer.clear()
		return empty_offer
	_shuffle_resources(_current_offer)
	last_error = ""
	return _current_offer.duplicate()

func select_card(offer_index: int) -> bool:
	if not _is_configured or offer_index < 0 or offer_index >= _current_offer.size():
		last_error = "La selección no coincide con una carta de la oferta actual."
		return false
	var selected: Resource = _current_offer[offer_index]
	var card_id: StringName = StringName(selected.get("id"))
	var granted_tower_id: StringName = StringName(selected.get("grant_tower_id"))
	if granted_tower_id != &"":
		_run_tower_ids[granted_tower_id] = true
	_selected_cards.append(selected)
	for operation_variant in selected.get("modifier_operations"):
		var operation := operation_variant as Resource
		if operation != null:
			_active_operations.append(operation)
	_selected_counts[card_id] = int(_selected_counts.get(card_id, 0)) + 1
	_current_offer.clear()
	last_error = ""
	card_selected.emit(selected)
	modifiers_changed.emit()
	return true

func get_current_offer() -> Array[Resource]:
	return _current_offer.duplicate()

func get_tower_damage_add(tower_id: StringName, damage_tags: int) -> float:
	return _sum_matching_operations(OperationType.TOWER_DAMAGE_ADD, tower_id, damage_tags)

func get_tower_damage_multiplier(tower_id: StringName, damage_tags: int) -> float:
	return _multiply_matching_operations(OperationType.TOWER_DAMAGE_MULTIPLIER, tower_id, damage_tags)

func get_tower_range_add(tower_id: StringName) -> float:
	return _sum_matching_operations(OperationType.TOWER_RANGE_ADD, tower_id)

func get_tower_attack_rate_multiplier(tower_id: StringName) -> float:
	return _multiply_matching_operations(OperationType.TOWER_ATTACK_RATE_MULTIPLIER, tower_id)

func get_tower_area_radius_add(tower_id: StringName) -> float:
	return _sum_matching_operations(OperationType.TOWER_AREA_RADIUS_ADD, tower_id)

func get_tower_mana_cost_multiplier(tower_id: StringName) -> float:
	return _multiply_matching_operations(OperationType.TOWER_MANA_COST_MULTIPLIER, tower_id)

func get_tower_hit_point_multiplier_add(tower_id: StringName, layer: int) -> float:
	var total: float = 0.0
	for operation in _active_operations:
		if int(operation.get("type")) != OperationType.TOWER_HIT_POINT_MULTIPLIER_ADD:
			continue
		if int(operation.get("affected_hit_point_layer")) != layer:
			continue
		if _operation_matches(operation, tower_id, 0, &""):
			total += float(operation.get("value"))
	return total

func get_tower_crit_chance_add(tower_id: StringName) -> float:
	return _sum_matching_operations(OperationType.TOWER_CRIT_CHANCE_ADD, tower_id)

func get_tower_crit_chance_per_level_add(tower_id: StringName) -> float:
	return _sum_matching_operations(OperationType.TOWER_CRIT_CHANCE_PER_LEVEL_ADD, tower_id)

func get_status_duration_multiplier(tower_id: StringName, status_id: StringName) -> float:
	return _multiply_matching_operations(
		OperationType.STATUS_DURATION_MULTIPLIER,
		tower_id,
		0,
		status_id
	)

func get_mana_max_bonus() -> float:
	return _sum_matching_operations(OperationType.MANA_MAX_ADD, &"")

func get_mana_regen_bonus() -> float:
	return _sum_matching_operations(OperationType.MANA_REGEN_ADD, &"")

func get_mana_regen_max_percent_bonus() -> float:
	return _sum_matching_operations(OperationType.MANA_REGEN_MAX_PERCENT_ADD, &"")

func get_mana_on_kill_max_percent_bonus() -> float:
	return _sum_matching_operations(OperationType.MANA_ON_KILL_MAX_PERCENT_ADD, &"")

func _shuffle_resources(cards: Array[Resource]) -> void:
	for index in range(cards.size() - 1, 0, -1):
		var swap_index: int = _rng.randi_range(0, index)
		var card: Resource = cards[index]
		cards[index] = cards[swap_index]
		cards[swap_index] = card

func get_tower_status_ids(tower_id: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	for operation in _active_operations:
		if int(operation.get("type")) != OperationType.TOWER_STATUS_DAMAGE_BONUS:
			continue
		var status_id: StringName = StringName(operation.get("affected_status_id"))
		if status_id == &"" or not _operation_matches(operation, tower_id, 0, status_id):
			continue
		if not result.has(status_id):
			result.append(status_id)
	return result

func get_tower_status_damage_bonus(tower_id: StringName, status_id: StringName) -> float:
	return _sum_matching_operations(OperationType.TOWER_STATUS_DAMAGE_BONUS, tower_id, 0, status_id)

func get_status_max_damage_per_second_bonus(tower_id: StringName, status_id: StringName) -> float:
	return _sum_matching_operations(OperationType.STATUS_MAX_DAMAGE_PER_SECOND_ADD, tower_id, 0, status_id)

func get_status_condition_layer_damage_add(status_id: StringName) -> float:
	return _sum_matching_operations(OperationType.STATUS_CONDITION_LAYER_DAMAGE_ADD, &"", 0, status_id)

func get_status_crit_chance_add(status_id: StringName) -> float:
	return _sum_matching_operations(OperationType.STATUS_CRIT_CHANCE_ADD, &"", 0, status_id)

func get_status_crit_damage_conversion_fraction(status_id: StringName) -> float:
	return _sum_matching_operations(OperationType.STATUS_CRIT_DAMAGE_CONVERSION_ADD, &"", 0, status_id)

func get_status_slow_damage_scaling(status_id: StringName) -> float:
	return _sum_matching_operations(OperationType.STATUS_SLOW_DAMAGE_SCALING_ADD, &"", 0, status_id)

func get_status_strength_cap_add(status_id: StringName) -> float:
	return _sum_matching_operations(OperationType.STATUS_STRENGTH_CAP_ADD, &"", 0, status_id)

func get_status_poison_slow_fraction() -> float:
	return _sum_matching_operations(OperationType.STATUS_POISON_SLOW_FRACTION_ADD, &"", 0, &"poison")

func get_tower_slow_fraction_add(tower_id: StringName) -> float:
	return _sum_matching_operations(OperationType.TOWER_SLOW_FRACTION_ADD, tower_id)

func get_tower_elevation_range_bonus_multiplier_add(tower_id: StringName) -> float:
	return _sum_matching_operations(OperationType.TOWER_ELEVATION_RANGE_BONUS_MULTIPLIER_ADD, tower_id)

func get_tower_area_radius_multiplier_add(tower_id: StringName) -> float:
	return _sum_matching_operations(OperationType.TOWER_AREA_RADIUS_MULTIPLIER_ADD, tower_id)

func get_tower_mana_cost_damage_ratio_add(tower_id: StringName) -> float:
	return _sum_matching_operations(OperationType.TOWER_MANA_COST_DAMAGE_RATIO_ADD, tower_id)

func get_gold_per_kill_bonus() -> int:
	return roundi(_sum_matching_operations(OperationType.GOLD_PER_KILL_ADD, &""))

func get_enemy_base_damage_bonus() -> int:
	return roundi(_sum_matching_operations(OperationType.ENEMY_BASE_DAMAGE_ADD, &""))

func get_base_max_health_bonus() -> int:
	return roundi(_sum_matching_operations(OperationType.BASE_MAX_HEALTH_ADD, &""))

func _is_card_available(card: Resource) -> bool:
	if float(card.get("offer_weight")) <= 0.0:
		return false
	var card_id: StringName = StringName(card.get("id"))
	if int(_selected_counts.get(card_id, 0)) >= int(card.get("max_per_run")):
		return false
	var requirement: StringName = StringName(card.get("unlock_requirement"))
	if not (_debug_unlock_all or requirement == &"" or _unlocked_content_ids.has(requirement)):
		return false
	var grant_tower_id: StringName = StringName(card.get("grant_tower_id"))
	if grant_tower_id != &"" and _run_tower_ids.has(grant_tower_id):
		return false
	for operation_variant in card.get("modifier_operations"):
		var operation: Resource = operation_variant as Resource
		if operation == null:
			continue
		var affected_tower_id: StringName = StringName(operation.get("affected_tower_id"))
		if affected_tower_id != &"" and not _run_tower_ids.has(affected_tower_id):
			return false
	for required_card_id in card.get("required_card_ids"):
		if int(_selected_counts.get(required_card_id, 0)) <= 0:
			return false
	var alternatives: Array = card.get("any_required_card_ids")
	if not alternatives.is_empty():
		var has_any_prerequisite: bool = false
		for required_card_id in alternatives:
			if int(_selected_counts.get(required_card_id, 0)) > 0:
				has_any_prerequisite = true
				break
		if not has_any_prerequisite:
			return false
	return true

func _pick_weighted_index(candidates: Array[Resource]) -> int:
	var total_weight: float = 0.0
	for card in candidates:
		total_weight += maxf(float(card.get("offer_weight")), 0.0)
	if total_weight <= 0.0:
		return 0
	var roll: float = _rng.randf_range(0.0, total_weight)
	for index in candidates.size():
		roll -= maxf(float(candidates[index].get("offer_weight")), 0.0)
		if roll <= 0.0:
			return index
	return candidates.size() - 1

func _sum_matching_operations(operation_type: int, tower_id: StringName, damage_tags: int = 0, status_id: StringName = &"") -> float:
	var total: float = 0.0
	for operation in _active_operations:
		if int(operation.get("type")) != operation_type:
			continue
		if not _operation_matches(operation, tower_id, damage_tags, status_id):
			continue
		total += float(operation.get("value"))
	return total

func _multiply_matching_operations(operation_type: int, tower_id: StringName, damage_tags: int = 0, status_id: StringName = &"") -> float:
	var result: float = 1.0
	for operation in _active_operations:
		if int(operation.get("type")) != operation_type:
			continue
		if not _operation_matches(operation, tower_id, damage_tags, status_id):
			continue
		result *= float(operation.get("value"))
	return result

func _operation_matches(operation: Resource, tower_id: StringName, damage_tags: int, status_id: StringName) -> bool:
	var affected_tower: StringName = StringName(operation.get("affected_tower_id"))
	if affected_tower != &"" and affected_tower != tower_id:
		return false
	var affected_tags: int = int(operation.get("affected_damage_tags"))
	if affected_tags != 0 and (damage_tags & affected_tags) == 0:
		return false
	var affected_status: StringName = StringName(operation.get("affected_status_id"))
	return affected_status == &"" or affected_status == status_id
