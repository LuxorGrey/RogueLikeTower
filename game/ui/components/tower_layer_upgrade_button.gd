@tool
class_name TowerLayerUpgradeButton
extends Button

@export var layer_icon_texture: Texture2D:
	set(value):
		layer_icon_texture = value
		if is_inside_tree():
			var icon_view := get_node_or_null("Content/LayerIcon") as TextureRect
			if icon_view != null:
				icon_view.texture = value

@onready var layer_icon: TextureRect = %LayerIcon
@onready var level_label: RichTextLabel = %LevelLabel
@onready var xp_bar: ProgressBar = %XPBar
@onready var xp_label: Label = %XPLabel
@onready var effect_label: Label = %EffectLabel
@onready var cost_icon: TextureRect = %CostIcon
@onready var amount_label: Label = %AmountLabel

func _ready() -> void:
	layer_icon.texture = layer_icon_texture
	xp_label.hide()
