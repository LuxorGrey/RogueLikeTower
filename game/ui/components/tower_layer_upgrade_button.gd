@tool
class_name TowerLayerUpgradeButton
extends Button

@export var layer_icon_texture: Texture2D:
	set(value):
		layer_icon_texture = value
		if is_inside_tree():
			var icon_view := get_node_or_null("Content/IconCenter/LayerIcon") as TextureRect
			if icon_view != null:
				icon_view.texture = value

@export_group("Layer colors")
@export var health_layer_color: Color = Color("#82df8b")
@export var armor_layer_color: Color = Color("#f2bd68")
@export var shield_layer_color: Color = Color("#72d5f2")
@export var xp_background_style: StyleBoxFlat
@export var health_xp_fill_style: StyleBoxFlat
@export var armor_xp_fill_style: StyleBoxFlat
@export var shield_xp_fill_style: StyleBoxFlat

@onready var layer_icon: TextureRect = %LayerIcon
@onready var level_label: RichTextLabel = %LevelLabel
@onready var xp_bar: ProgressBar = %XPBar
@onready var xp_label: Label = %XPLabel
@onready var effect_label: Label = %EffectLabel
@onready var cost_icon: TextureRect = %CostIcon
@onready var amount_label: Label = %AmountLabel

func _ready() -> void:
	layer_icon.texture = layer_icon_texture
	configure_layer_visuals(Enemy.HitPointLayer.HEALTH)

func configure_layer_visuals(layer: int) -> void:
	var layer_color: Color = health_layer_color
	var fill_style: StyleBoxFlat = health_xp_fill_style
	match layer:
		Enemy.HitPointLayer.ARMOR:
			layer_color = armor_layer_color
			fill_style = armor_xp_fill_style
		Enemy.HitPointLayer.SHIELD:
			layer_color = shield_layer_color
			fill_style = shield_xp_fill_style
	level_label.add_theme_color_override("default_color", layer_color)
	if xp_background_style != null:
		xp_bar.add_theme_stylebox_override("background", xp_background_style)
	if fill_style != null:
		xp_bar.add_theme_stylebox_override("fill", fill_style)
