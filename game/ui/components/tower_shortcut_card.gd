@tool
class_name TowerShortcutCard
extends Button

@export var tower_icon_texture: Texture2D:
	set(value):
		tower_icon_texture = value
		if is_inside_tree():
			var icon_view := get_node_or_null("CardMargin/CardContent/TowerIcon") as TextureRect
			if icon_view != null:
				icon_view.texture = value

@onready var tower_icon: TextureRect = %TowerIcon
@onready var name_label: Label = %TowerName
@onready var gold_icon: TextureRect = %GoldIcon
@onready var price_label: Label = %PriceLabel

func _ready() -> void:
	tower_icon.texture = tower_icon_texture

func set_tower_visuals(display_name: String, visual_color: Color) -> void:
	text = ""
	tower_icon.texture = tower_icon_texture
	name_label.text = display_name
	name_label.add_theme_color_override("font_color", visual_color.lightened(0.45))

func set_build_cost(amount: int) -> void:
	price_label.text = "%d" % amount
