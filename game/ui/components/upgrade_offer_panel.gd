class_name UpgradeOfferPanel
extends PanelContainer

const UPGRADE_CARD_SCENE: PackedScene = preload("res://game/ui/components/upgrade_offer_card.tscn")
const CARD_ROW_WIDTH: float = 976.0
const CARD_MAX_WIDTH: float = 252.0
const CARD_GAP: float = 18.0
const CARD_HEIGHT: float = 340.0

@onready var heading_label: Label = %HeadingLabel
@onready var _card_container: HBoxContainer = %Cards

var cards: Array[UpgradeOfferCard] = []

func _ready() -> void:
	for child in _card_container.get_children():
		var card := child as UpgradeOfferCard
		if card != null:
			cards.append(card)

func set_card_count(count: int) -> void:
	var target_count: int = clampi(count, 1, 6)
	while cards.size() < 6:
		var card := UPGRADE_CARD_SCENE.instantiate() as UpgradeOfferCard
		card.name = "UpgradeCard%d" % (cards.size() + 1)
		_card_container.add_child(card)
		cards.append(card)
	var card_width: float = minf(
		CARD_MAX_WIDTH,
		floor((CARD_ROW_WIDTH - CARD_GAP * float(target_count - 1)) / float(target_count))
	)
	for index in cards.size():
		var card: UpgradeOfferCard = cards[index]
		card.visible = index < target_count
		card.disabled = index >= target_count
		card.custom_minimum_size = Vector2(card_width, CARD_HEIGHT)
		card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		card.title_label.add_theme_font_size_override("normal_font_size", 19 if target_count <= 3 else 16)
		card.description_label.add_theme_font_size_override("normal_font_size", 15 if target_count <= 3 else 13)
