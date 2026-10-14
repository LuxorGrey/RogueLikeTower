class_name UpgradeOfferCard
extends Button

const AURA_SHADER: Shader = preload("res://game/ui/components/upgrade_card_aura.gdshader")

@onready var tower_icon: TextureRect = %TowerIcon
@onready var title_label: RichTextLabel = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var card_panel: Panel = %CardPanel
@onready var aura_glow: ColorRect = %AuraGlow
@onready var rarity_label: Label = %RarityLabel

var _normal_panel_style: StyleBoxFlat
var _hover_panel_style: StyleBoxFlat
var _aura_material: ShaderMaterial

func _ready() -> void:
	var empty_style := StyleBoxEmpty.new()
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(state_name, empty_style)
	_normal_panel_style = _create_panel_style(Color("#11191c"), Color("#435257"))
	_hover_panel_style = _create_panel_style(Color("#192428"), Color("#77878a"))
	card_panel.add_theme_stylebox_override("panel", _normal_panel_style)
	card_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aura_material = ShaderMaterial.new()
	_aura_material.shader = AURA_SHADER
	_aura_material.set_shader_parameter("glow_strength", 0.42)
	aura_glow.material = _aura_material
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func configure_visuals(icon_texture: Texture2D, rarity: int) -> void:
	tower_icon.texture = icon_texture
	tower_icon.visible = icon_texture != null
	var aura_color: Color = _rarity_aura_color(rarity)
	rarity_label.text = _rarity_tier_text(rarity)
	rarity_label.add_theme_color_override("font_color", aura_color.lightened(0.12))
	if _aura_material != null:
		_aura_material.set_shader_parameter("aura_color", aura_color)

func _create_panel_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style

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
			return Color("#68d49a")
		CardData.Rarity.RARE:
			return Color("#6eaaff")
		_:
			return Color("#c2cdca")

func _on_mouse_entered() -> void:
	if _hover_panel_style != null:
		card_panel.add_theme_stylebox_override("panel", _hover_panel_style)
	if _aura_material != null:
		_aura_material.set_shader_parameter("glow_strength", 0.82)

func _on_mouse_exited() -> void:
	if _normal_panel_style != null:
		card_panel.add_theme_stylebox_override("panel", _normal_panel_style)
	if _aura_material != null:
		_aura_material.set_shader_parameter("glow_strength", 0.42)
