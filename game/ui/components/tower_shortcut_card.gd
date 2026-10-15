@tool
class_name TowerShortcutCard
extends Button

@export_group("Card appearance")
@export_range(0.0, 1.0, 0.01) var name_label_lighten_amount: float = 0.45

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
@onready var shortcut_badge: PanelContainer = %ShortcutBadge
@onready var shortcut_number_label: Label = %ShortcutNumberLabel

func _ready() -> void:
	tower_icon.texture = tower_icon_texture

func set_tower_visuals(display_name: String, visual_color: Color) -> void:
	text = ""
	tower_icon.texture = tower_icon_texture
	name_label.text = display_name
	name_label.add_theme_color_override("font_color", visual_color.lightened(name_label_lighten_amount))

func set_build_cost(amount: int) -> void:
	price_label.text = "%d" % amount

func set_shortcut_number(number: int) -> void:
	shortcut_number_label.text = str(number) if number > 0 else ""
	shortcut_badge.visible = number > 0
