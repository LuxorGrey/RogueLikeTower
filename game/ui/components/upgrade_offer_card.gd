class_name UpgradeOfferCard
extends Button

@onready var tower_icon: TextureRect = %TowerIcon
@onready var title_label: RichTextLabel = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var card_panel: Panel = %CardPanel
@onready var aura_glow: ColorRect = %AuraGlow
@onready var rarity_label: Label = %RarityLabel

@export_group("Card appearance")
@export var normal_panel_style: StyleBoxFlat
@export var hover_panel_style: StyleBoxFlat
@export var common_aura_color: Color = Color("#c2cdca")
@export var uncommon_aura_color: Color = Color("#68d49a")
@export var rare_aura_color: Color = Color("#6eaaff")
@export_range(0.0, 1.0, 0.01) var rarity_label_lighten_amount: float = 0.12
@export_range(0.0, 1.5, 0.01) var normal_aura_strength: float = 0.42
@export_range(0.0, 1.5, 0.01) var hover_aura_strength: float = 0.82

var _normal_panel_style: StyleBoxFlat
var _hover_panel_style: StyleBoxFlat
var _aura_material: ShaderMaterial

func _ready() -> void:
	_normal_panel_style = normal_panel_style
	_hover_panel_style = hover_panel_style
	_aura_material = aura_glow.material as ShaderMaterial
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func configure_visuals(icon_texture: Texture2D, rarity: int) -> void:
	tower_icon.texture = icon_texture
	tower_icon.visible = icon_texture != null
	var aura_color: Color = _rarity_aura_color(rarity)
	rarity_label.text = _rarity_tier_text(rarity)
	rarity_label.add_theme_color_override("font_color", aura_color.lightened(rarity_label_lighten_amount))
	if _aura_material != null:
		_aura_material.set_shader_parameter("aura_color", aura_color)

func _rarity_tier_text(rarity: int) -> String:
	match rarity:
		CardData.Rarity.UNCOMMON:
			return "TIER II · POCO COMÚN"
		CardData.Rarity.RARE:
			return "TIER III · RARA"
		_:
			return "TIER I · COMÚN"

func _rarity_aura_color(rarity: int) -> Color:
	match rarity:
		CardData.Rarity.UNCOMMON:
			return uncommon_aura_color
		CardData.Rarity.RARE:
			return rare_aura_color
		_:
			return common_aura_color

func _on_mouse_entered() -> void:
	if _hover_panel_style != null:
		card_panel.add_theme_stylebox_override("panel", _hover_panel_style)
	if _aura_material != null:
		_aura_material.set_shader_parameter("glow_strength", hover_aura_strength)

func _on_mouse_exited() -> void:
	if _normal_panel_style != null:
		card_panel.add_theme_stylebox_override("panel", _normal_panel_style)
	if _aura_material != null:
		_aura_material.set_shader_parameter("glow_strength", normal_aura_strength)
