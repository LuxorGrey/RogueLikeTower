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
}

signal card_selected(card: Resource)
signal modifiers_changed

var last_error: String = ""
var _pool: Resource
var _unlocked_content_ids: Dictionary = {}
var _current_offer: Array[Resource] = []
var _selected_cards: Array[Resource] = []
var _active_operations: Array[Resource] = []
var _selected_counts: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _is_configured: bool = false

func configure(card_pool: Resource, unlocked_content_ids: Array[StringName]) -> bool:
	last_error = ""
	if card_pool == null or not card_pool.has_method("validate"):
		last_error = "RunCardService requiere un CardPoolData válido."
		return false
	var errors: PackedStringArray = card_pool.call("validate")
	if not errors.is_empty():
		last_error = "; ".join(errors)
		return false
	_pool = card_pool
	_unlocked_content_ids.clear()
	for content_id in unlocked_content_ids:
		_unlocked_content_ids[content_id] = true
	_current_offer.clear()
	_selected_cards.clear()
	_active_operations.clear()
	_selected_counts.clear()
	_rng.randomize()
	_is_configured = true
	return true

func should_offer_after(round_number: int) -> bool:
	return _is_configured and bool(_pool.call("should_offer_after", round_number))

func create_offer(round_number: int) -> Array[Resource]:
	var empty_offer: Array[Resource] = []
	if not should_offer_after(round_number):
		return empty_offer
	if not _current_offer.is_empty():
		return _current_offer.duplicate()
	var candidates: Array[Resource] = []
	var pool_cards: Array = _pool.get("cards")
	for card_variant in pool_cards:
		var card := card_variant as Resource
		if card == null or not _is_card_available(card):
			continue
		candidates.append(card)
	var offer_size: int = int(_pool.get("offer_size"))
	while _current_offer.size() < offer_size and not candidates.is_empty():
		var selected_index: int = _pick_weighted_index(candidates)
		_current_offer.append(candidates[selected_index])
		candidates.remove_at(selected_index)
	if _current_offer.size() != offer_size:
		last_error = "No hay suficientes cartas desbloqueadas para completar la oferta."
		_current_offer.clear()
		return empty_offer
	last_error = ""
	return _current_offer.duplicate()

func select_card(offer_index: int) -> bool:
	if not _is_configured or offer_index < 0 or offer_index >= _current_offer.size():
		last_error = "La selección no coincide con una carta de la oferta actual."
		return false
	var selected: Resource = _current_offer[offer_index]
	var card_id: StringName = StringName(selected.get("id"))
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

func get_selected_cards() -> Array[Resource]:
	return _selected_cards.duplicate()

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

func _is_card_available(card: Resource) -> bool:
	if float(card.get("offer_weight")) <= 0.0:
		return false
	var card_id: StringName = StringName(card.get("id"))
	if int(_selected_counts.get(card_id, 0)) >= int(card.get("max_per_run")):
		return false
	var requirement: StringName = StringName(card.get("unlock_requirement"))
	return requirement == &"" or _unlocked_content_ids.has(requirement)

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
