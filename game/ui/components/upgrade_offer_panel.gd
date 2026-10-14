class_name UpgradeOfferPanel
extends PanelContainer

const UPGRADE_CARD_SCENE: PackedScene = preload("res://game/ui/components/upgrade_offer_card.tscn")
const PANEL_WIDTH: float = 900.0
const CARD_ROW_WIDTH: float = 820.0
const CARD_MAX_WIDTH: float = 260.0
const CARD_GAP: float = 20.0
const CARD_VERTICAL_GAP: float = 18.0
const CARD_HEIGHT: float = 352.0
const COMPACT_CARD_HEIGHT: float = 312.0
const FIXED_CARD_COUNT: int = CardPoolData.FIXED_OFFER_SIZE

@onready var _card_container: GridContainer = %Cards
@onready var heading_label: Label = %HeadingLabel

var cards: Array[UpgradeOfferCard] = []

func _ready() -> void:
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	for child in _card_container.get_children():
		var card := child as UpgradeOfferCard
		if card != null:
			cards.append(card)
	_apply_panel_size(1, CARD_HEIGHT)

func set_card_count(_count: int) -> void:
	var target_count: int = FIXED_CARD_COUNT
	while cards.size() < target_count:
		var card := UPGRADE_CARD_SCENE.instantiate() as UpgradeOfferCard
		card.name = "UpgradeCard%d" % (cards.size() + 1)
		_card_container.add_child(card)
		cards.append(card)

	var column_count: int = mini(target_count, 3)
	var row_count: int = int(ceili(float(target_count) / 3.0))
	var card_height: float = CARD_HEIGHT if row_count == 1 else COMPACT_CARD_HEIGHT
	_card_container.columns = column_count
	var card_width: float = minf(
		CARD_MAX_WIDTH,
		floor((CARD_ROW_WIDTH - CARD_GAP * float(column_count - 1)) / float(column_count))
	)
	for index in cards.size():
		var card: UpgradeOfferCard = cards[index]
		card.visible = index < target_count
		card.disabled = index >= target_count
		card.custom_minimum_size = Vector2(card_width, card_height)
		card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		card.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var compact_scale: float = 0.88 if row_count > 1 else 1.0
		card.tower_icon.custom_minimum_size = Vector2(96.0, 96.0) * compact_scale
		card.title_label.add_theme_font_size_override("normal_font_size", 21 if row_count == 1 else 18)
		card.description_label.add_theme_font_size_override("normal_font_size", 15 if row_count == 1 else 13)
		card.description_label.custom_minimum_size.y = 100.0 if row_count == 1 else 82.0
	_apply_panel_size(row_count, card_height)

func _apply_panel_size(row_count: int, card_height: float) -> void:
	var height: float = 83.0 + float(row_count) * card_height
	if row_count > 1:
		height += float(row_count - 1) * CARD_VERTICAL_GAP
	custom_minimum_size = Vector2(PANEL_WIDTH, height)
	offset_left = -PANEL_WIDTH * 0.5
	offset_right = PANEL_WIDTH * 0.5
	offset_top = -height * 0.5
	offset_bottom = height * 0.5
