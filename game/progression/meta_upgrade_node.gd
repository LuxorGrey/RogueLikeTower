class_name MetaUpgradeNode
extends Button

@onready var _surface: PanelContainer = %Surface
@onready var _icon: TextureRect = %Icon
@onready var _title: Label = %Title
@onready var _description: Label = %Description
@onready var _status: Label = %Status

var _normal_style: StyleBoxFlat
var _hover_style: StyleBoxFlat

func _ready() -> void:
	text = ""
	flat = true
	add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	add_theme_stylebox_override("disabled", StyleBoxEmpty.new())
	custom_minimum_size = Vector2(236.0, 254.0)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func configure_node(
	title: String,
	description: String,
	status_text: String,
	icon_texture: Texture2D,
	locked: bool,
	purchased: bool,
	tooltip: String
) -> void:
	if _title == null:
		return
	_title.text = title
	_description.text = description
	_status.text = status_text
	_icon.texture = icon_texture
	_icon.visible = true
	tooltip_text = tooltip
	disabled = locked
	var border_color := Color("#82938a")
	var aura_color := Color("#80e085")
	if locked:
		border_color = Color("#4d5958")
		aura_color = Color("#66706f")
	elif purchased:
		border_color = Color("#e8c76e")
		aura_color = Color("#f1cf78")
	_normal_style = _make_style(Color("#10171a"), border_color, aura_color, 0.22, 10)
	_hover_style = _make_style(Color("#18252a"), border_color.lightened(0.18), aura_color, 0.52, 20)
	_surface.add_theme_stylebox_override("panel", _normal_style)
	_status.add_theme_color_override("font_color", Color("#9baaa6") if locked else Color("#f1cf78") if purchased else Color("#8de7aa"))
	modulate = Color("#9da7a3") if locked else Color.WHITE

func _make_style(background: Color, border: Color, aura: Color, alpha: float, blur: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 13.0
	style.content_margin_right = 13.0
	style.content_margin_top = 11.0
	style.content_margin_bottom = 9.0
	style.shadow_color = Color(aura.r, aura.g, aura.b, alpha)
	style.shadow_size = blur
	style.shadow_offset = Vector2.ZERO
	return style

func _on_mouse_entered() -> void:
	if _hover_style != null and _surface != null:
		_surface.add_theme_stylebox_override("panel", _hover_style)

func _on_mouse_exited() -> void:
	if _normal_style != null and _surface != null:
		_surface.add_theme_stylebox_override("panel", _normal_style)
