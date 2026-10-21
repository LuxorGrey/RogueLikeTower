class_name UpgradeOfferPanel
extends PanelContainer

signal choice_resolution_finished

const UPGRADE_CARD_SCENE: PackedScene = preload("res://game/ui/components/upgrade_offer_card.tscn")
const FIXED_CARD_COUNT: int = CardPoolData.FIXED_OFFER_SIZE

@export_group("Offer layout")
@export_range(400.0, 1600.0, 1.0) var panel_width: float = 900.0
@export_range(300.0, 1500.0, 1.0) var card_row_width: float = 820.0
@export_range(160.0, 600.0, 1.0) var card_max_width: float = 260.0
@export_range(0.0, 64.0, 1.0) var card_gap: float = 20.0
@export_range(180.0, 700.0, 1.0) var card_height: float = 392.0
@export_range(32.0, 180.0, 1.0) var heading_and_spacing_height: float = 83.0
@export_range(0.0, 0.4, 0.01) var deal_stagger: float = 0.08
@export_range(0.0, 0.2, 0.01) var reveal_stagger: float = 0.06
@export_range(0.0, 0.15, 0.01) var fan_rotation: float = 0.045

@onready var _card_container: GridContainer = %Cards
@onready var heading_label: Label = %HeadingLabel

var cards: Array[UpgradeOfferCard] = []
var _pending_choice_animations: int = 0

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

func reveal_offer() -> void:
	var deal_tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for index in cards.size():
		var card: UpgradeOfferCard = cards[index]
		if not card.visible:
			continue
		var centered_index: float = float(index) - float(cards.size() - 1) * 0.5
		card.prepare_for_offer(centered_index * fan_rotation)
		deal_tween.tween_property(card, "scale", Vector2.ONE, 0.2).set_delay(float(index) * deal_stagger)
		deal_tween.parallel().tween_property(card, "modulate:a", 1.0, 0.16).set_delay(float(index) * deal_stagger)
	await deal_tween.finished
	for index in cards.size():
		var card: UpgradeOfferCard = cards[index]
		if not card.visible:
			continue
		var is_featured_reveal: bool = (
			card._current_rarity == CardData.Rarity.RECRUITMENT
			or (index == cards.size() - 1 and card._current_rarity == CardData.Rarity.RARE)
		)
		await card.reveal_card(is_featured_reveal)
		if index < cards.size() - 1:
			await get_tree().create_timer(reveal_stagger).timeout

func disable_card_input() -> void:
	for card in cards:
		card.disabled = true

func resolve_choice(index: int, target_icon: Control) -> void:
	for card in cards:
		card.disabled = true
	var animations: Array[Tween] = []
	for card_index in cards.size():
		var card: UpgradeOfferCard = cards[card_index]
		if not card.visible:
			continue
		if card_index == index:
			animations.append(card.animate_choice_to_hud(target_icon, get_parent()))
		else:
			animations.append(card.animate_discard_burn())
	if animations.is_empty():
		return
	_pending_choice_animations = animations.size()
	for animation in animations:
		animation.finished.connect(_on_choice_animation_finished, CONNECT_ONE_SHOT)
	await choice_resolution_finished

func _on_choice_animation_finished() -> void:
	_pending_choice_animations -= 1
	if _pending_choice_animations <= 0:
		choice_resolution_finished.emit()

func _apply_panel_size() -> void:
	var height: float = heading_and_spacing_height + card_height
	custom_minimum_size = Vector2(panel_width, height)
	offset_left = -panel_width * 0.5
	offset_right = panel_width * 0.5
	offset_top = -height * 0.5
	offset_bottom = height * 0.5
