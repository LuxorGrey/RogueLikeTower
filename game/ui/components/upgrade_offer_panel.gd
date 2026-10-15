class_name UpgradeOfferPanel
extends PanelContainer

const UPGRADE_CARD_SCENE: PackedScene = preload("res://game/ui/components/upgrade_offer_card.tscn")
const FIXED_CARD_COUNT: int = CardPoolData.FIXED_OFFER_SIZE

@export_group("Offer layout")
@export_range(400.0, 1600.0, 1.0) var panel_width: float = 900.0
@export_range(300.0, 1500.0, 1.0) var card_row_width: float = 820.0
@export_range(160.0, 600.0, 1.0) var card_max_width: float = 260.0
@export_range(0.0, 64.0, 1.0) var card_gap: float = 20.0
@export_range(180.0, 700.0, 1.0) var card_height: float = 352.0
@export_range(32.0, 180.0, 1.0) var heading_and_spacing_height: float = 83.0

@onready var _card_container: GridContainer = %Cards
@onready var heading_label: Label = %HeadingLabel

var cards: Array[UpgradeOfferCard] = []

func _ready() -> void:
	for child in _card_container.get_children():
		var card := child as UpgradeOfferCard
		if card != null:
			cards.append(card)
	_apply_panel_size()

func set_card_count(_count: int) -> void:
	var target_count: int = FIXED_CARD_COUNT
	while cards.size() < target_count:
		var card := UPGRADE_CARD_SCENE.instantiate() as UpgradeOfferCard
		card.name = "UpgradeCard%d" % (cards.size() + 1)
		_card_container.add_child(card)
		cards.append(card)

	var column_count: int = mini(target_count, 3)
	_card_container.columns = column_count
	var card_width: float = minf(
		card_max_width,
		floor((card_row_width - card_gap * float(column_count - 1)) / float(column_count))
	)
	for index in cards.size():
		var card: UpgradeOfferCard = cards[index]
		card.visible = index < target_count
		card.disabled = index >= target_count
		card.custom_minimum_size = Vector2(card_width, card_height)
		card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		card.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_apply_panel_size()

func _apply_panel_size() -> void:
	var height: float = heading_and_spacing_height + card_height
	custom_minimum_size = Vector2(panel_width, height)
	offset_left = -panel_width * 0.5
	offset_right = panel_width * 0.5
	offset_top = -height * 0.5
	offset_bottom = height * 0.5
