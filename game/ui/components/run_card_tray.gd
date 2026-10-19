class_name RunCardTray
extends PanelContainer

@export_group("Tray layout")
@export_range(1, 12, 1) var max_visible_icons: int = 7
@export var card_icon_size: Vector2 = Vector2(28.0, 28.0)

@onready var count_label: Label = %CountLabel
@onready var icon_row: HBoxContainer = %CardIcons

var _visible_icons: Array[TextureRect] = []
var _total_cards: int = 0

func _ready() -> void:
	hide()

func append_card_icon(icon_texture: Texture2D, display_name: String, description: String) -> TextureRect:
	_total_cards += 1
	count_label.text = "MEJORAS · %d" % _total_cards
	while _visible_icons.size() >= max_visible_icons:
		var oldest_icon: TextureRect = _visible_icons.pop_front()
		icon_row.remove_child(oldest_icon)
		oldest_icon.queue_free()
	var icon := TextureRect.new()
	icon.name = "ActiveCardIcon%d" % _total_cards
	icon.texture = icon_texture
	icon.custom_minimum_size = card_icon_size
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_STOP
	icon.tooltip_text = "%s\n%s" % [display_name, description]
	icon.modulate = Color(1.0, 1.0, 1.0, 0.0)
	icon_row.add_child(icon)
	_visible_icons.append(icon)
	show()
	return icon
