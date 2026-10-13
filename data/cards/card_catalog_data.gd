class_name CardCatalogData
extends Resource

@export var cards: Array[Resource] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	var ids: Dictionary[StringName, bool] = {}
	for card in cards:
		if card == null or not card.has_method("validate"):
			errors.append("El catálogo contiene un recurso que no es CardData válida.")
			continue
		var card_id: StringName = StringName(card.get("id"))
		if ids.has(card_id):
			errors.append("El catálogo repite el ID de carta %s." % card_id)
		ids[card_id] = true
		errors.append_array(card.call("validate"))
	# Prerequisites may point to cards in the parent CardPoolData or another catalog.
	# CardPoolData validates those references after combining every catalog.
	return errors
