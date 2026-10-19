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
const TOWER_PREVIEW_NAMES: Dictionary[StringName, String] = {
	&"ballista": "Ballista",
	&"mortar": "Mortar",
	&"tesla_coil": "Tesla Coil",
	&"frost_keep": "Frost Keep",
	&"flame_thrower": "Flame Thrower",
	&"poison_sprayer": "Poison Sprayer",
	&"shredder": "Shredder",
}
const STATUS_PREVIEW_NAMES: Dictionary[StringName, String] = {
	&"bleed": "Bleed",
	&"burn": "Burn",
	&"poison": "Poison",
	&"slow": "Slow",
}

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
	if not should_offer_after(round_number):
		return []
	return _create_offer()

func create_bonus_offer() -> Array[Resource]:
	if not _is_configured:
		last_error = "RunCardService no está configurado para generar la oferta del tesoro."
		return []
	return _create_offer()

func _create_offer() -> Array[Resource]:
	var empty_offer: Array[Resource] = []
	if not _current_offer.is_empty():
		return _current_offer.duplicate()
	var available_cards: Array[Resource] = []
	var recruit_cards: Array[Resource] = []
	var pool_cards: Array = _pool.call("get_all_cards")
	for card_variant in pool_cards:
		var card := card_variant as Resource
		if card == null or not _is_card_available(card):
			continue
		available_cards.append(card)
		if _is_recruit_card(card):
			recruit_cards.append(card)
	# Si queda una torre elegible, la oferta garantiza un reclutamiento.
	# Los otros espacios siguen siendo aleatorios y nunca se permiten tres reclutas.
	if not recruit_cards.is_empty():
		var mandatory_recruit: Resource = recruit_cards[_pick_weighted_index(recruit_cards)]
		_current_offer.append(mandatory_recruit)
		available_cards.erase(mandatory_recruit)
	while _current_offer.size() < FIXED_UPGRADE_OFFER_SIZE:
		var recruit_count: int = 0
		for offered_card in _current_offer:
			if _is_recruit_card(offered_card):
				recruit_count += 1
		var candidates: Array[Resource] = []
		for card in available_cards:
			if recruit_count >= 2 and _is_recruit_card(card):
				continue
			candidates.append(card)
		if candidates.is_empty():
			break
		var selected_index: int = _pick_weighted_index(candidates)
		var selected_card: Resource = candidates[selected_index]
		_current_offer.append(selected_card)
		available_cards.erase(selected_card)
	if _current_offer.size() != FIXED_UPGRADE_OFFER_SIZE:
		last_error = "No hay suficientes cartas desbloqueadas para completar la oferta."
		_current_offer.clear()
		return empty_offer
	_shuffle_resources(_current_offer)
	_current_offer.sort_custom(_sort_offer_by_rarity)
	last_error = ""
	return _current_offer.duplicate()

func _sort_offer_by_rarity(first: Resource, second: Resource) -> bool:
	return int(first.get("rarity")) < int(second.get("rarity"))

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

func get_card_preview_rows(card: Resource) -> Array[Dictionary]:
	var preview_rows: Array[Dictionary] = []
	if card == null:
		return preview_rows
	var grouped_operations: Array[Dictionary] = []
	for operation_variant in card.get("modifier_operations"):
		var operation := operation_variant as Resource
		if operation == null:
			continue
		var group_index: int = -1
		for index in grouped_operations.size():
			var first_operation: Resource = grouped_operations[index]["first"] as Resource
			if _same_preview_scope(first_operation, operation):
				group_index = index
				break
		if group_index < 0:
			grouped_operations.append({"first": operation, "operations": [operation]})
		else:
			var matching_operations: Array = grouped_operations[group_index]["operations"]
			matching_operations.append(operation)
			grouped_operations[group_index]["operations"] = matching_operations
	for group in grouped_operations:
		var first_operation: Resource = group["first"] as Resource
		var operation_type: int = int(first_operation.get("type"))
		var before_value: float = _get_preview_total(first_operation)
		var after_value: float = before_value
		for matching_operation_variant in group["operations"]:
			var matching_operation := matching_operation_variant as Resource
			var operation_value: float = float(matching_operation.get("value"))
			after_value = (
				after_value * operation_value
				if _is_multiplicative_preview(operation_type)
				else after_value + operation_value
			)
		preview_rows.append({
			"label": _preview_label(first_operation),
			"before": before_value,
			"after": after_value,
			"format": _preview_format(operation_type),
			"tone": _preview_change_tone(operation_type, before_value, after_value),
		})
	return preview_rows

func _same_preview_scope(first: Resource, second: Resource) -> bool:
	return (
		int(first.get("type")) == int(second.get("type"))
		and StringName(first.get("affected_tower_id")) == StringName(second.get("affected_tower_id"))
		and int(first.get("affected_damage_tags")) == int(second.get("affected_damage_tags"))
		and StringName(first.get("affected_status_id")) == StringName(second.get("affected_status_id"))
		and int(first.get("affected_hit_point_layer")) == int(second.get("affected_hit_point_layer"))
	)

func _get_preview_total(operation: Resource) -> float:
	var operation_type: int = int(operation.get("type"))
	var tower_id: StringName = StringName(operation.get("affected_tower_id"))
	var damage_tags: int = int(operation.get("affected_damage_tags"))
	var status_id: StringName = StringName(operation.get("affected_status_id"))
	if operation_type == OperationType.TOWER_HIT_POINT_MULTIPLIER_ADD:
		var hit_point_layer: int = int(operation.get("affected_hit_point_layer"))
		var total: float = 0.0
		for active_operation in _active_operations:
			if int(active_operation.get("type")) != operation_type:
				continue
			if int(active_operation.get("affected_hit_point_layer")) != hit_point_layer:
				continue
			if not _operation_matches(active_operation, tower_id, damage_tags, status_id):
				continue
			total += float(active_operation.get("value"))
		return total
	if _is_multiplicative_preview(operation_type):
		return _multiply_matching_operations(operation_type, tower_id, damage_tags, status_id)
	return _sum_matching_operations(operation_type, tower_id, damage_tags, status_id)

func _is_multiplicative_preview(operation_type: int) -> bool:
	return operation_type in [
		OperationType.TOWER_DAMAGE_MULTIPLIER,
		OperationType.TOWER_ATTACK_RATE_MULTIPLIER,
		OperationType.TOWER_MANA_COST_MULTIPLIER,
		OperationType.STATUS_DURATION_MULTIPLIER,
	]

func _preview_change_tone(operation_type: int, before_value: float, after_value: float) -> StringName:
	if is_equal_approx(before_value, after_value):
		return &"neutral"
	var lower_is_better: bool = operation_type in [
		OperationType.TOWER_MANA_COST_MULTIPLIER,
		OperationType.TOWER_MANA_COST_DAMAGE_RATIO_ADD,
		OperationType.ENEMY_BASE_DAMAGE_ADD,
	]
	var change_is_beneficial: bool = (
		after_value < before_value
		if lower_is_better
		else after_value > before_value
	)
	return &"positive" if change_is_beneficial else &"negative"

func _preview_format(operation_type: int) -> StringName:
	match operation_type:
		OperationType.TOWER_DAMAGE_MULTIPLIER, OperationType.TOWER_ATTACK_RATE_MULTIPLIER, OperationType.TOWER_MANA_COST_MULTIPLIER, OperationType.STATUS_DURATION_MULTIPLIER:
			return &"multiplier"
		OperationType.TOWER_CRIT_CHANCE_ADD, OperationType.TOWER_HIT_POINT_MULTIPLIER_ADD, OperationType.TOWER_STATUS_DAMAGE_BONUS, OperationType.TOWER_SLOW_FRACTION_ADD, OperationType.TOWER_ELEVATION_RANGE_BONUS_MULTIPLIER_ADD, OperationType.TOWER_AREA_RADIUS_MULTIPLIER_ADD, OperationType.STATUS_CRIT_CHANCE_ADD, OperationType.STATUS_CRIT_DAMAGE_CONVERSION_ADD, OperationType.STATUS_SLOW_DAMAGE_SCALING_ADD, OperationType.STATUS_POISON_SLOW_FRACTION_ADD, OperationType.TOWER_CRIT_CHANCE_PER_LEVEL_ADD, OperationType.TOWER_MANA_COST_DAMAGE_RATIO_ADD, OperationType.MANA_REGEN_MAX_PERCENT_ADD, OperationType.MANA_ON_KILL_MAX_PERCENT_ADD:
			return &"percent"
		OperationType.TOWER_RANGE_ADD, OperationType.TOWER_AREA_RADIUS_ADD:
			return &"range"
		OperationType.MANA_REGEN_ADD, OperationType.STATUS_MAX_DAMAGE_PER_SECOND_ADD:
			return &"rate"
		_:
			return &"number"

func _preview_label(operation: Resource) -> String:
	var operation_type: int = int(operation.get("type"))
	var effect_name: String = "Mejora"
	match operation_type:
		OperationType.TOWER_DAMAGE_ADD, OperationType.TOWER_DAMAGE_MULTIPLIER:
			effect_name = "Daño"
		OperationType.TOWER_RANGE_ADD:
			effect_name = "Alcance"
		OperationType.TOWER_ATTACK_RATE_MULTIPLIER:
			effect_name = "Cadencia"
		OperationType.TOWER_AREA_RADIUS_ADD, OperationType.TOWER_AREA_RADIUS_MULTIPLIER_ADD:
			effect_name = "Área"
		OperationType.TOWER_MANA_COST_MULTIPLIER, OperationType.TOWER_MANA_COST_DAMAGE_RATIO_ADD:
			effect_name = "Coste de Mana"
		OperationType.STATUS_DURATION_MULTIPLIER:
			effect_name = "Duración"
		OperationType.MANA_MAX_ADD:
			effect_name = "Mana máximo"
		OperationType.MANA_REGEN_ADD, OperationType.MANA_REGEN_MAX_PERCENT_ADD:
			effect_name = "Regeneración de Mana"
		OperationType.TOWER_CRIT_CHANCE_ADD, OperationType.STATUS_CRIT_CHANCE_ADD, OperationType.TOWER_CRIT_CHANCE_PER_LEVEL_ADD:
			effect_name = "Crítico"
		OperationType.TOWER_HIT_POINT_MULTIPLIER_ADD:
			effect_name = ["Salud", "Armadura", "Escudo"][clampi(int(operation.get("affected_hit_point_layer")), 0, 2)]
		OperationType.TOWER_STATUS_DAMAGE_BONUS, OperationType.STATUS_CONDITION_LAYER_DAMAGE_ADD, OperationType.STATUS_MAX_DAMAGE_PER_SECOND_ADD:
			effect_name = "Daño periódico"
		OperationType.TOWER_SLOW_FRACTION_ADD, OperationType.STATUS_SLOW_DAMAGE_SCALING_ADD, OperationType.STATUS_POISON_SLOW_FRACTION_ADD:
			effect_name = "Slow"
		OperationType.TOWER_ELEVATION_RANGE_BONUS_MULTIPLIER_ADD:
			effect_name = "Alcance por altura"
		OperationType.STATUS_CRIT_DAMAGE_CONVERSION_ADD:
			effect_name = "Conversión a crítico"
		OperationType.MANA_ON_KILL_MAX_PERCENT_ADD:
			effect_name = "Mana por baja"
		OperationType.GOLD_PER_KILL_ADD:
			effect_name = "Gold por baja"
		OperationType.ENEMY_BASE_DAMAGE_ADD:
			effect_name = "Daño a la base"
		OperationType.BASE_MAX_HEALTH_ADD:
			effect_name = "Health de base"
		OperationType.STATUS_STRENGTH_CAP_ADD:
			effect_name = "Límite de estado"
	var tower_id: StringName = StringName(operation.get("affected_tower_id"))
	var status_id: StringName = StringName(operation.get("affected_status_id"))
	if tower_id != &"":
		return "%s · %s" % [TOWER_PREVIEW_NAMES.get(tower_id, String(tower_id)), effect_name]
	if status_id != &"":
		return "%s · %s" % [STATUS_PREVIEW_NAMES.get(status_id, String(status_id).capitalize()), effect_name]
	return effect_name

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

func _is_recruit_card(card: Resource) -> bool:
	return StringName(card.get("grant_tower_id")) != &""

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
