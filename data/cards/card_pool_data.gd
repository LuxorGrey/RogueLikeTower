class_name CardPoolData
extends Resource

@export var cards: Array[Resource] = []
@export_range(1, 3, 1) var offer_size: int = 3
@export_range(1, 20, 1) var first_offer_round: int = 3
@export_range(1, 20, 1) var offer_interval: int = 3

func should_offer_after(round_number: int) -> bool:
	return (
		round_number >= first_offer_round
		and round_number <= 19
		and posmod(round_number - first_offer_round, offer_interval) == 0
	)

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if offer_size < 1 or offer_size > 3:
		errors.append("El tamaño de oferta del prototipo debe estar entre 1 y 3 cartas.")
	if first_offer_round < 1 or first_offer_round > 20:
		errors.append("La primera ronda de oferta debe estar entre 1 y 20.")
	if offer_interval < 1 or offer_interval > 20:
		errors.append("El intervalo de oferta debe ser positivo.")
	var ids: Dictionary = {}
	var eligible_count: int = 0
	for card in cards:
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
	if eligible_count < offer_size:
		errors.append("El pool no contiene suficientes cartas con peso positivo para una oferta.")
	return errors
