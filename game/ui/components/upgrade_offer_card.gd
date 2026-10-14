class_name UpgradeOfferCard
extends Button

const UNIVERSAL_CARD_TEXTURE: Texture2D = preload("res://game/ui/cards/upgrade_card_universal.png")

@onready var tower_icon: TextureRect = %TowerIcon
@onready var title_label: RichTextLabel = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var card_panel: Panel = %CardPanel
@onready var card_sprite: NinePatchRect = %CardSprite
@onready var rarity_label: Label = %RarityLabel

var _normal_panel_style: StyleBoxFlat
var _hover_panel_style: StyleBoxFlat

func _ready() -> void:
	var empty_style := StyleBoxEmpty.new()
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(state_name, empty_style)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func configure_visuals(icon_texture: Texture2D, rarity: int) -> void:
	tower_icon.texture = icon_texture
	tower_icon.visible = icon_texture != null
	var aura_color := _rarity_aura_color(rarity)
	card_sprite.texture = UNIVERSAL_CARD_TEXTURE
	rarity_label.text = _rarity_tier_text(rarity)
	rarity_label.add_theme_color_override("font_color", aura_color.lightened(0.12))
	_normal_panel_style = _create_panel_style(aura_color, 0.32, 11)
	_hover_panel_style = _create_panel_style(aura_color, 0.58, 19)
	card_panel.add_theme_stylebox_override("panel", _normal_panel_style)

func _create_panel_style(
	aura_color: Color,
	aura_alpha: float,
	aura_size: int
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style.set_border_width_all(0)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(aura_color.r, aura_color.g, aura_color.b, aura_alpha)
	style.shadow_size = aura_size
	style.shadow_offset = Vector2.ZERO
	return style

func _rarity_tier_text(rarity: int) -> String:
	match rarity:
		0:
			return "TIER I · COMÚN"
		1:
			return "TIER II · POCO COMÚN"
		2:
			return "TIER III · RARA"
		_:
			return "TIER I · COMÚN"

func _rarity_aura_color(rarity: int) -> Color:
	match rarity:
		1:
			return Color("#7fbfe1")
		2:
			return Color("#e0b85e")
		_:
			return Color("#82c598")

func _on_mouse_entered() -> void:
	if _hover_panel_style != null:
		card_panel.add_theme_stylebox_override("panel", _hover_panel_style)

func _on_mouse_exited() -> void:
	if _normal_panel_style != null:
		card_panel.add_theme_stylebox_override("panel", _normal_panel_style)
