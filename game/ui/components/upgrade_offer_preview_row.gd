@tool
class_name UpgradeOfferPreviewRow
extends HBoxContainer

@export_group("Bonus value colors")
@export var positive_color: Color = Color("#75df8b"):
	set(value):
		positive_color = value
		_apply_tone_color()
@export var negative_color: Color = Color("#f07872"):
	set(value):
		negative_color = value
		_apply_tone_color()
@export var neutral_color: Color = Color("#aebbb8"):
	set(value):
		neutral_color = value
		_apply_tone_color()

var _tone: StringName = &"positive"

func _ready() -> void:
	_apply_tone_color()

func configure_preview(label_text: String, before_text: String, after_text: String, tone: StringName) -> void:
	_tone = tone
	var name_label := get_node("NameLabel") as Label
	var before_label := get_node("BeforeLabel") as Label
	var after_label := get_node("AfterLabel") as Label
	name_label.text = label_text
	before_label.text = before_text
	after_label.text = after_text
	_apply_tone_color()

func _apply_tone_color() -> void:
	var after_label := get_node_or_null("AfterLabel") as Label
	if after_label == null:
		return
	match _tone:
		&"negative":
			after_label.add_theme_color_override("font_color", negative_color)
		&"neutral":
			after_label.add_theme_color_override("font_color", neutral_color)
		_:
			after_label.add_theme_color_override("font_color", positive_color)
