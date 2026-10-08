extends RefCounted

const PANEL_FILL: Color = Color("#172228")
const PANEL_EDGE: Color = Color("#607176")
const BUTTON_FILL: Color = Color("#293a40")
const BUTTON_EDGE: Color = Color("#52656b")
const BUTTON_HOVER: Color = Color("#354a50")
const ACCENT: Color = Color("#d9b86f")
const TEXT_COLOR: Color = Color("#e9e5d8")
const MUTED_TEXT: Color = Color("#89979a")

func apply_to_tree(root: Node) -> void:
	var panel_style: StyleBoxFlat = _make_panel_style()
	var normal_style: StyleBoxFlat = _make_button_style(BUTTON_FILL, BUTTON_EDGE)
	var hover_style: StyleBoxFlat = _make_button_style(BUTTON_HOVER, ACCENT)
	var pressed_style: StyleBoxFlat = _make_button_style(Color("#1e2c31"), ACCENT)
	var disabled_style: StyleBoxFlat = _make_button_style(Color("#202b30"), Color("#39474c"))
	_visit(root, panel_style, normal_style, hover_style, pressed_style, disabled_style)

func _visit(
	node: Node,
	panel_style: StyleBoxFlat,
	normal_style: StyleBoxFlat,
	hover_style: StyleBoxFlat,
	pressed_style: StyleBoxFlat,
	disabled_style: StyleBoxFlat
) -> void:
	if node is PanelContainer or node is Panel:
		(node as Control).add_theme_stylebox_override("panel", panel_style)
	elif node is Button:
		var button := node as Button
		button.add_theme_stylebox_override("normal", normal_style)
		button.add_theme_stylebox_override("hover", hover_style)
		button.add_theme_stylebox_override("pressed", pressed_style)
		button.add_theme_stylebox_override("focus", hover_style)
		button.add_theme_stylebox_override("disabled", disabled_style)
		button.add_theme_color_override("font_color", TEXT_COLOR)
		button.add_theme_color_override("font_hover_color", TEXT_COLOR)
		button.add_theme_color_override("font_pressed_color", ACCENT)
		button.add_theme_color_override("font_disabled_color", MUTED_TEXT)
	for child in node.get_children():
		_visit(child, panel_style, normal_style, hover_style, pressed_style, disabled_style)

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_FILL
	style.border_color = PANEL_EDGE
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.content_margin_left = 8.0
	style.content_margin_top = 8.0
	style.content_margin_right = 8.0
	style.content_margin_bottom = 8.0
	return style

func _make_button_style(fill_color: Color, edge_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = edge_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 10.0
	style.content_margin_top = 6.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 6.0
	return style
