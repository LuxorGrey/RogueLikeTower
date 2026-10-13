class_name CardPoolData
extends Resource

@export var cards: Array[Resource] = []
@export var catalogs: Array[Resource] = []
@export_range(1, 6, 1) var offer_size: int = 3
@export_range(1, 45, 1) var first_offer_round: int = 3
@export_range(1, 45, 1) var offer_interval: int = 3

func should_offer_after(round_number: int) -> bool:
	return (
		round_number >= first_offer_round
		and round_number < 45
		and posmod(round_number - first_offer_round, offer_interval) == 0
	)

func get_all_cards() -> Array[Resource]:
	var result: Array[Resource] = cards.duplicate()
	for catalog in catalogs:
		if catalog == null or not catalog.has_method("get"):
			continue
		var catalog_cards: Variant = catalog.get("cards")
		if catalog_cards is Array:
			for card in catalog_cards:
				result.append(card as Resource)
	return result

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if offer_size < 1 or offer_size > 6:
		errors.append("El tamaño de oferta debe estar entre 1 y 6 cartas.")
	if first_offer_round < 1 or first_offer_round > 45:
		errors.append("La primera ronda de oferta debe estar entre 1 y 45.")
	if offer_interval < 1 or offer_interval > 45:
		errors.append("El intervalo de oferta debe ser positivo.")
	var ids: Dictionary = {}
	var eligible_count: int = 0
	var all_cards: Array[Resource] = get_all_cards()
	for catalog in catalogs:
		if catalog == null or not catalog.has_method("validate"):
			errors.append("El pool contiene un catálogo adicional no válido.")
			continue
		errors.append_array(catalog.call("validate"))
	for card in all_cards:
		if card == null or not card.has_method("validate"):
			errors.append("El pool solo puede contener CardData válidas.")
			continue
		var card_id: StringName = StringName(card.get("id"))
		if ids.has(card_id):
			errors.append("El pool repite el ID de carta %s." % card_id)
		ids[card_id] = true
		var card_errors: PackedStringArray = card.call("validate")
		for message in card_errors:
			errors.append(message)
		if float(card.get("offer_weight")) > 0.0:
			eligible_count += 1
	for card in all_cards:
		if card == null:
			continue
		for prerequisite_id in card.get("required_card_ids"):
			if not ids.has(prerequisite_id):
				errors.append("La carta %s requiere un prerrequisito ausente: %s." % [card.get("id"), prerequisite_id])
		for prerequisite_id in card.get("any_required_card_ids"):
			if not ids.has(prerequisite_id):
				errors.append("La carta %s requiere un prerrequisito alternativo ausente: %s." % [card.get("id"), prerequisite_id])
	if eligible_count < offer_size:
		errors.append("El pool no contiene suficientes cartas con peso positivo para una oferta.")
	return errors
