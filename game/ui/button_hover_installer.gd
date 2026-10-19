class_name UIButtonHoverInstaller
extends Node

const BALATRO_HOVER_SCRIPT: Script = preload("res://game/ui/components/balatro_card_hover.gd")
const BUTTON_HOVER_SCALE: Vector2 = Vector2(1.04, 1.04)
const BUTTON_HOVER_PEAK_SCALE: Vector2 = Vector2(1.075, 1.075)

static func install(root: Node) -> void:
	for child in root.get_children():
		if child is UIButtonHoverInstaller:
			return
	var installer := UIButtonHoverInstaller.new()
	installer.name = "UIButtonHoverInstaller"
	root.add_child(installer)

func _ready() -> void:
	var ui_root: Node = get_parent()
	if ui_root != null:
		_watch_subtree(ui_root)

func _watch_subtree(node: Node) -> void:
	if node == self:
		return
	if node is BaseButton:
		_attach_balatro_hover(node as BaseButton)
	var is_ui_branch: bool = node == get_parent() or node is Control or node is CanvasLayer
	if not is_ui_branch:
		return
	if not node.child_entered_tree.is_connected(_on_child_entered_tree):
		node.child_entered_tree.connect(_on_child_entered_tree)
	for child in node.get_children():
		if child is Control or child is CanvasLayer:
			_watch_subtree(child)

func _on_child_entered_tree(child: Node) -> void:
	_watch_subtree(child)

func _attach_balatro_hover(button: BaseButton) -> void:
	for child in button.get_children():
		if child.get_script() == BALATRO_HOVER_SCRIPT:
			return
	var hover_effect := BALATRO_HOVER_SCRIPT.new() as Node
	hover_effect.name = "BalatroButtonHoverEffect"
	hover_effect.set("hover_scale", BUTTON_HOVER_SCALE)
	hover_effect.set("hover_peak_scale", BUTTON_HOVER_PEAK_SCALE)
	hover_effect.set("tilt_horizontal_strength", 0.03)
	hover_effect.set("tilt_vertical_strength", 0.012)
	button.add_child(hover_effect)
