class_name UpgradeOfferPanel
extends PanelContainer

const UPGRADE_CARD_SCENE: PackedScene = preload("res://game/ui/components/upgrade_offer_card.tscn")

@onready var heading_label: Label = %HeadingLabel
@onready var _card_container: HBoxContainer = %Cards

var cards: Array[UpgradeOfferCard] = []

func _ready() -> void:
	for child in _card_container.get_children():
		var card := child as UpgradeOfferCard
		if card != null:
			cards.append(card)

func set_card_count(count: int) -> void:
	var target_count: int = maxi(count, 1)
	while cards.size() < target_count:
		var card := UPGRADE_CARD_SCENE.instantiate() as UpgradeOfferCard
		card.name = "UpgradeCard%d" % (cards.size() + 1)
		_card_container.add_child(card)
		cards.append(card)
	while cards.size() > target_count:
		var card: UpgradeOfferCard = cards.pop_back()
		_card_container.remove_child(card)
		card.queue_free()
