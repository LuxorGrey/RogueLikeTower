class_name UpgradeOfferCard
extends Button

const PREVIEW_ROW_SCENE: PackedScene = preload("res://game/ui/components/upgrade_offer_preview_row.tscn")

@onready var tower_icon: TextureRect = %TowerIcon
@onready var icon_center: CenterContainer = $ContentMargin/CardContent/IconCenter
@onready var title_label: RichTextLabel = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var card_panel: Panel = %CardPanel
@onready var aura_glow: ColorRect = %AuraGlow
@onready var rarity_label: Label = %RarityLabel
@onready var recruitment_banner: PanelContainer = %RecruitmentBanner
@onready var content_margin: MarginContainer = %ContentMargin
@onready var card_back: Panel = %CardBack
@onready var preview_values: VBoxContainer = %PreviewValues
@onready var burn_overlay: ColorRect = %BurnOverlay
@onready var hover_effect: Node = $BalatroHoverEffect

@export_group("Card appearance")
@export var normal_panel_style: StyleBoxFlat
@export var hover_panel_style: StyleBoxFlat
@export var uncommon_surface_color: Color = Color("#203a2f")
@export var rare_surface_color: Color = Color("#202f4a")
@export var recruitment_surface_color: Color = Color("#251d31")
@export var common_aura_color: Color = Color("#c2cdca")
@export var uncommon_aura_color: Color = Color("#68d49a")
@export var rare_aura_color: Color = Color("#6eaaff")
@export var recruitment_aura_color: Color = Color("#ffd071")
@export var recruitment_border_color: Color = Color("#e8b44f")
@export_group("Card appearance")
@export_range(0.0, 1.0, 0.01) var rarity_label_lighten_amount: float = 0.12
@export_range(0.0, 1.5, 0.01) var normal_aura_strength: float = 0.42
@export_range(0.0, 1.5, 0.01) var hover_aura_strength: float = 0.82
@export_range(0.0, 2.0, 0.01) var recruitment_aura_strength: float = 1.05
@export_range(0.0, 2.0, 0.01) var recruitment_hover_aura_strength: float = 1.45
@export_group("Card animation")
@export_range(0.05, 1.0, 0.01) var flip_duration: float = 0.16
@export_range(0.05, 1.0, 0.01) var rare_reveal_duration: float = 0.32
@export_range(0.1, 2.0, 0.01) var selection_flight_duration: float = 0.46
@export_range(0.1, 2.0, 0.01) var discard_burn_duration: float = 0.52

var _normal_panel_style: StyleBoxFlat
var _hover_panel_style: StyleBoxFlat
var _aura_material: ShaderMaterial
var _burn_material: ShaderMaterial
var _preview_rows: Array[Dictionary] = []
var _preview_tween: Tween
var _current_rarity: int = CardData.Rarity.COMMON
var _base_rotation: float = 0.0
var _positive_preview_color: Color = Color("#75df8b")
var _negative_preview_color: Color = Color("#f07872")

func _ready() -> void:
	_aura_material = aura_glow.material.duplicate() as ShaderMaterial
	aura_glow.material = _aura_material
	_burn_material = burn_overlay.material.duplicate() as ShaderMaterial
	burn_overlay.material = _burn_material
	_normal_panel_style = normal_panel_style
	_hover_panel_style = hover_panel_style
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	resized.connect(_sync_pivot)
	_sync_pivot()

func configure_visuals(
	icon_texture: Texture2D,
	rarity: int,
	preview_rows: Array[Dictionary] = [],
	positive_color: Color = Color("#75df8b"),
	negative_color: Color = Color("#f07872")
) -> void:
	_current_rarity = rarity
	_positive_preview_color = positive_color
	_negative_preview_color = negative_color
	tower_icon.texture = icon_texture
	tower_icon.visible = icon_texture != null
	var is_recruitment: bool = rarity == CardData.Rarity.RECRUITMENT
	recruitment_banner.visible = is_recruitment
	tower_icon.custom_minimum_size = Vector2(108.0, 108.0) if is_recruitment else Vector2(88.0, 88.0)
	icon_center.custom_minimum_size.y = 112.0 if is_recruitment else 94.0
	title_label.add_theme_color_override("default_color", Color("#fff1cd") if is_recruitment else Color("#f4f7f3"))
	var aura_color: Color = _rarity_aura_color(rarity)
	rarity_label.text = _rarity_tier_text(rarity)
	rarity_label.add_theme_color_override("font_color", aura_color.lightened(rarity_label_lighten_amount))
	if _aura_material != null:
		_aura_material.set_shader_parameter("aura_color", aura_color)
		_aura_material.set_shader_parameter("glow_strength", _normal_glow_strength())
	_apply_rarity_panel_styles()
	_set_preview_rows(preview_rows)

func prepare_for_offer(rotation_radians: float) -> void:
	_base_rotation = rotation_radians
	if hover_effect.has_method("set_base_rotation"):
		hover_effect.call("set_base_rotation", _base_rotation)
	rotation = _base_rotation
	content_margin.hide()
	card_back.show()
	burn_overlay.hide()
	if _burn_material != null:
		_burn_material.set_shader_parameter("burn_progress", 0.0)
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	scale = Vector2(0.82, 0.82)
	disabled = true
	_sync_pivot()

func reveal_card(is_rare_reveal: bool = false) -> void:
	var close_tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	close_tween.tween_property(self, "scale:x", 0.035, flip_duration * 0.5)
	await close_tween.finished
	card_back.hide()
	content_margin.show()
	var open_tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	open_tween.tween_property(self, "scale:x", 1.0, flip_duration * 0.5)
	await open_tween.finished
	_animate_preview_values()
	if is_rare_reveal:
		await _play_rare_reveal()
	disabled = false

func animate_choice_to_hud(target_icon: Control, animation_layer: Node) -> Tween:
	disabled = true
	var flying_icon := TextureRect.new()
	flying_icon.name = "SelectedCardIconFlight"
	flying_icon.texture = tower_icon.texture
	flying_icon.z_index = 40
	flying_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flying_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	flying_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var source_rect: Rect2 = tower_icon.get_global_rect()
	var target_rect: Rect2 = target_icon.get_global_rect()
	flying_icon.position = source_rect.position
	flying_icon.size = source_rect.size
	flying_icon.pivot_offset = source_rect.size * 0.5
	animation_layer.add_child(flying_icon)
	target_icon.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(flying_icon, "global_position", target_rect.position, selection_flight_duration)
	tween.tween_property(flying_icon, "size", target_rect.size, selection_flight_duration)
	tween.tween_property(flying_icon, "rotation", TAU * 0.25, selection_flight_duration)
	tween.tween_property(self, "modulate:a", 0.0, selection_flight_duration * 0.78)
	tween.tween_property(self, "scale", Vector2(0.88, 0.88), selection_flight_duration)
	tween.finished.connect(func() -> void:
		if is_instance_valid(flying_icon):
			flying_icon.queue_free()
		if is_instance_valid(target_icon):
			target_icon.modulate = Color.WHITE
	)
	return tween

func animate_discard_burn() -> Tween:
	disabled = true
	burn_overlay.show()
	if _burn_material != null:
		_burn_material.set_shader_parameter("burn_progress", 0.0)
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_method(_set_burn_progress, 0.0, 1.0, discard_burn_duration)
	tween.tween_property(self, "modulate:a", 0.0, discard_burn_duration)
	tween.tween_property(self, "scale", Vector2(0.94, 0.94), discard_burn_duration)
	return tween

func _set_burn_progress(progress: float) -> void:
	if _burn_material == null:
		return
	_burn_material.set_shader_parameter("burn_progress", clampf(progress, 0.0, 1.0))

func _set_preview_rows(preview_rows: Array[Dictionary]) -> void:
	for child in preview_values.get_children():
		child.queue_free()
	_preview_rows.clear()
	for preview_variant in preview_rows:
		var preview: Dictionary = preview_variant
		var value_format: StringName = StringName(preview.get("format", &"number"))
		var row := PREVIEW_ROW_SCENE.instantiate() as UpgradeOfferPreviewRow
		row.positive_color = _positive_preview_color
		row.negative_color = _negative_preview_color
		preview_values.add_child(row)
		row.call(
			"configure_preview",
			String(preview.get("label", "Mejora")),
			_format_preview_value(float(preview.get("before", 0.0)), value_format),
			_format_preview_value(float(preview.get("after", 0.0)), value_format),
			StringName(preview.get("tone", &"positive"))
		)
		var stored_preview: Dictionary = preview.duplicate()
		stored_preview["after_label"] = row.get_node("AfterLabel")
		_preview_rows.append(stored_preview)

func _format_preview_value(value: float, value_format: StringName) -> String:
	match value_format:
		&"multiplier":
			return "×%s" % _format_decimal(value, 2)
		&"percent":
			return "%s%%" % _format_signed(value * 100.0, 0)
		&"range":
			return "%s hex" % _format_signed(value, 1)
		&"rate":
			return "%s/s" % _format_signed(value, 1)
		_:
			return _format_signed(value, 1)

func _format_decimal(value: float, decimals: int) -> String:
	return String.num(value, decimals).replace(".", ",")

func _format_signed(value: float, decimals: int) -> String:
	if is_zero_approx(value):
		return "0"
	var sign: String = "+" if value > 0.0 else ""
	return "%s%s" % [sign, _format_decimal(value, decimals)]

func _apply_rarity_panel_styles() -> void:
	if normal_panel_style == null or hover_panel_style == null:
		return
	var rarity_color: Color = _rarity_aura_color(_current_rarity)
	var normal_style: StyleBoxFlat = normal_panel_style.duplicate() as StyleBoxFlat
	var hover_style: StyleBoxFlat = hover_panel_style.duplicate() as StyleBoxFlat
	if _current_rarity != CardData.Rarity.COMMON:
		normal_style.bg_color = _rarity_surface_color(_current_rarity)
		normal_style.border_color = rarity_color.darkened(0.14)
		hover_style.bg_color = normal_style.bg_color.lightened(0.08)
		hover_style.border_color = normal_style.border_color.lightened(0.08)
	if _current_rarity == CardData.Rarity.RECRUITMENT:
		normal_style.border_color = recruitment_border_color
		hover_style.border_color = recruitment_border_color.lightened(0.22)
		for style: StyleBoxFlat in [normal_style, hover_style]:
			style.border_width_left = 4
			style.border_width_top = 4
			style.border_width_right = 4
			style.border_width_bottom = 4
			style.corner_radius_top_left = 12
			style.corner_radius_top_right = 12
			style.corner_radius_bottom_right = 12
			style.corner_radius_bottom_left = 12
			style.shadow_color = Color(0.92, 0.56, 0.16, 0.45)
			style.shadow_size = 12
	card_panel.add_theme_stylebox_override("panel", normal_style)
	_hover_panel_style = hover_style
	_normal_panel_style = normal_style

func _rarity_tier_text(rarity: int) -> String:
	match rarity:
		CardData.Rarity.UNCOMMON:
			return "TIER II · POCO COMÚN"
		CardData.Rarity.RARE:
			return "TIER III · RARA"
		CardData.Rarity.RECRUITMENT:
			return "TIER IV · RECLUTAMIENTO"
		_:
			return "TIER I · COMÚN"

func _rarity_surface_color(rarity: int) -> Color:
	match rarity:
		CardData.Rarity.UNCOMMON:
			return uncommon_surface_color
		CardData.Rarity.RARE:
			return rare_surface_color
		CardData.Rarity.RECRUITMENT:
			return recruitment_surface_color
		_:
			return normal_panel_style.bg_color if normal_panel_style != null else Color("#202a27")

func _rarity_aura_color(rarity: int) -> Color:
	match rarity:
		CardData.Rarity.UNCOMMON:
			return uncommon_aura_color
		CardData.Rarity.RARE:
			return rare_aura_color
		CardData.Rarity.RECRUITMENT:
			return recruitment_aura_color
		_:
			return common_aura_color

func _normal_glow_strength() -> float:
	return recruitment_aura_strength if _current_rarity == CardData.Rarity.RECRUITMENT else normal_aura_strength

func _hover_glow_strength() -> float:
	return recruitment_hover_aura_strength if _current_rarity == CardData.Rarity.RECRUITMENT else hover_aura_strength

func _play_rare_reveal() -> void:
	if _aura_material != null:
		_aura_material.set_shader_parameter("glow_strength", 1.85 if _current_rarity == CardData.Rarity.RECRUITMENT else 1.5)
	var start_color: Color = card_panel.self_modulate
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.13, 1.13) if _current_rarity == CardData.Rarity.RECRUITMENT else Vector2(1.08, 1.08), rare_reveal_duration * 0.45)
	tween.parallel().tween_property(card_panel, "self_modulate", Color(2.1, 1.85, 1.35, 1.0) if _current_rarity == CardData.Rarity.RECRUITMENT else Color(1.8, 1.8, 1.8, 1.0), rare_reveal_duration * 0.25)
	tween.chain().tween_property(self, "scale", Vector2.ONE, rare_reveal_duration * 0.55)
	tween.parallel().tween_property(card_panel, "self_modulate", start_color, rare_reveal_duration * 0.55)
	await tween.finished
	if _aura_material != null:
		_aura_material.set_shader_parameter("glow_strength", _normal_glow_strength())

func _animate_preview_values() -> void:
	if _preview_rows.is_empty():
		return
	if _preview_tween != null and _preview_tween.is_running():
		_preview_tween.kill()
	_preview_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for preview in _preview_rows:
		var target_label: Label = preview["after_label"] as Label
		var value_format: StringName = StringName(preview.get("format", &"number"))
		var before_value: float = float(preview.get("before", 0.0))
		var after_value: float = float(preview.get("after", 0.0))
		target_label.text = _format_preview_value(before_value, value_format)
		_preview_tween.tween_method(
			func(value: float) -> void:
				target_label.text = _format_preview_value(value, value_format),
			before_value,
			after_value,
			0.42
		)

func _on_mouse_entered() -> void:
	if _hover_panel_style != null:
		card_panel.add_theme_stylebox_override("panel", _hover_panel_style)
	if _aura_material != null:
		_aura_material.set_shader_parameter("glow_strength", _hover_glow_strength())
	_animate_preview_values()

func _on_mouse_exited() -> void:
	if _normal_panel_style != null:
		card_panel.add_theme_stylebox_override("panel", _normal_panel_style)
	if _aura_material != null:
		_aura_material.set_shader_parameter("glow_strength", _normal_glow_strength())

func _sync_pivot() -> void:
	pivot_offset = size * 0.5
