class_name MetaUpgradeNode
extends Button

@onready var _surface: PanelContainer = %Surface
@onready var _icon: TextureRect = %Icon
@onready var _title: Label = %Title
@onready var _description: RichTextLabel = %Description
@onready var _status: Label = %Status
@onready var _currency_icon: TextureRect = %CurrencyIcon

@export_group("Node surface")
@export var locked_border_color: Color = Color("#4d5958")
@export var purchased_border_color: Color = Color("#e8c76e")
@export var normal_aura_color: Color = Color("#80e085")
@export var locked_aura_color: Color = Color("#66706f")
@export var purchased_aura_color: Color = Color("#f1cf78")
@export_range(0.0, 1.0, 0.01) var normal_aura_alpha: float = 0.22
@export_range(0.0, 1.0, 0.01) var hover_aura_alpha: float = 0.52

@export_group("Node status colors")
@export var locked_status_color: Color = Color("#9baaa6")
@export var purchased_status_color: Color = Color("#f1cf78")
@export var available_status_color: Color = Color("#8de7aa")
@export var positive_effect_text_color: Color = Color("#75df8b")
@export var negative_effect_text_color: Color = Color("#f07872")
@export_range(0.0, 1.0, 0.01) var hover_border_lighten: float = 0.18
@export var locked_control_modulate: Color = Color("#9da7a3")

var _normal_style: StyleBoxFlat
var _hover_style: StyleBoxFlat
var _base_surface_style: StyleBoxFlat

func _ready() -> void:
	text = ""
	flat = true
	_base_surface_style = _surface.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func configure_node(
	title: String,
	description: String,
	status_text: String,
	icon_texture: Texture2D,
	locked: bool,
	purchased: bool,
	tooltip: String,
	status_currency_icon: Texture2D = null
) -> void:
	if _title == null:
		return
	_title.text = title
	_description.clear()
	_description.append_text(
		StatValueColorizer.colorize(description, positive_effect_text_color, negative_effect_text_color)
	)
	_status.text = status_text
	_currency_icon.texture = status_currency_icon
	_currency_icon.visible = status_currency_icon != null
	_icon.texture = icon_texture
	_icon.visible = true
	tooltip_text = tooltip
	disabled = locked
	var border_color: Color = _base_surface_style.border_color
	var aura_color := normal_aura_color
	if locked:
		border_color = locked_border_color
		aura_color = locked_aura_color
	elif purchased:
		border_color = purchased_border_color
		aura_color = purchased_aura_color
	_normal_style = _base_surface_style.duplicate() as StyleBoxFlat
	_normal_style.border_color = border_color
	_normal_style.shadow_color = Color(aura_color.r, aura_color.g, aura_color.b, normal_aura_alpha)
	_hover_style = _base_surface_style.duplicate() as StyleBoxFlat
	_hover_style.bg_color = _base_surface_style.bg_color.lightened(0.08)
	_hover_style.border_color = border_color.lightened(hover_border_lighten)
	_hover_style.shadow_color = Color(aura_color.r, aura_color.g, aura_color.b, hover_aura_alpha)
	_hover_style.shadow_size = _base_surface_style.shadow_size + 10
	_surface.add_theme_stylebox_override("panel", _normal_style)
	_status.add_theme_color_override("font_color", locked_status_color if locked else purchased_status_color if purchased else available_status_color)
	modulate = locked_control_modulate if locked else Color.WHITE
func _on_mouse_entered() -> void:
	if _hover_style != null and _surface != null:
		_surface.add_theme_stylebox_override("panel", _hover_style)

func _on_mouse_exited() -> void:
	if _normal_style != null and _surface != null:
		_surface.add_theme_stylebox_override("panel", _normal_style)
