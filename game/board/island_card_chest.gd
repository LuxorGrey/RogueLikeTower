class_name IslandCardChest
extends Area2D

signal activated(island_id: StringName, world_position: Vector2)

const CHEST_TEXTURE: Texture2D = preload("res://assets/sprites/terrain/island_card_chest.png")
const ANIMATED_IMPACT_SCRIPT: Script = preload("res://game/vfx/animated_impact.gd")
const ITEM_GLOW_SHEET: Texture2D = preload("res://assets/sprites/ui/Cozy_Chunky/PNG_1x/pickup_ui/item_glow.png")
const CHEST_HOVER_SHADER: Shader = preload("res://game/board/obstacle_hover_glow.gdshader")
const DISPLAY_HEIGHT: float = 62.0
const ITEM_GLOW_DISPLAY_SIZE: float = 68.0
const ITEM_GLOW_FPS: float = 12.0
const HIT_RADIUS: float = 34.0
const HIT_CENTER: Vector2 = Vector2(0.0, -DISPLAY_HEIGHT * 0.45)

var island_id: StringName = &""
var _chest_sprite: Sprite2D
var _hover_sprite: Sprite2D
var _item_glow: Sprite2D
var _collision_shape: CollisionShape2D
var _appearance_tween: Tween
var _hover_tween: Tween
var _idle_bounce_tween: Tween
var _base_position: Vector2 = Vector2.ZERO
var _base_scale: Vector2 = Vector2.ONE
var _available: bool = false
var _hovered: bool = false

func _ready() -> void:
	input_pickable = true
	collision_layer = 1
	collision_mask = 0
	z_index = 4
	_chest_sprite = Sprite2D.new()
	_chest_sprite.name = "IslandCardChestSprite"
	_chest_sprite.centered = true
	_chest_sprite.texture = CHEST_TEXTURE
	_chest_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var sprite_scale: float = DISPLAY_HEIGHT / maxf(CHEST_TEXTURE.get_height(), 1.0)
	_chest_sprite.scale = Vector2.ONE * sprite_scale
	_chest_sprite.position = Vector2(0.0, -DISPLAY_HEIGHT * 0.5 + 6.0)
	_base_position = _chest_sprite.position
	_base_scale = _chest_sprite.scale
	add_child(_chest_sprite)
	_item_glow = ANIMATED_IMPACT_SCRIPT.new() as Sprite2D
	_item_glow.name = "IslandTreasureGlow"
	_item_glow.show_behind_parent = true
	_chest_sprite.add_child(_item_glow)
	_configure_item_glow()
	_item_glow.position = Vector2.ZERO
	_item_glow.visible = false
	_hover_sprite = Sprite2D.new()
	_hover_sprite.name = "IslandTreasureHoverGlow"
	_hover_sprite.centered = true
	_hover_sprite.texture = CHEST_TEXTURE
	_hover_sprite.scale = Vector2.ONE * 1.16
	_hover_sprite.z_index = 1
	_hover_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var hover_material := ShaderMaterial.new()
	hover_material.shader = CHEST_HOVER_SHADER
	hover_material.set_shader_parameter("outline_color", Color("#ffe079"))
	_hover_sprite.material = hover_material
	_chest_sprite.add_child(_hover_sprite)

	_collision_shape = CollisionShape2D.new()
	_collision_shape.name = "IslandCardChestHitbox"
	var circle := CircleShape2D.new()
	circle.radius = HIT_RADIUS
	_collision_shape.shape = circle
	_collision_shape.position = HIT_CENTER
	add_child(_collision_shape)

	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_sync_hover_visual()

func configure(next_island_id: StringName, local_position: Vector2, available: bool) -> void:
	var chest_appeared: bool = available and not _available
	island_id = next_island_id
	position = local_position
	_set_available(available)
	if chest_appeared:
		_play_appearance()

func set_available(available: bool) -> void:
	_set_available(available)

func try_activate_at_world_position(world_position: Vector2) -> bool:
	if not contains_world_position(world_position):
		return false
	return _activate()

func contains_world_position(world_position: Vector2) -> bool:
	if not _available or not visible or _collision_shape == null:
		return false
	var local_position: Vector2 = to_local(world_position)
	return local_position.distance_squared_to(_collision_shape.position) <= HIT_RADIUS * HIT_RADIUS

func set_pointer_hovered(is_over_chest: bool) -> void:
	var next_hovered: bool = is_over_chest and _available
	if _hovered == next_hovered:
		return
	_hovered = next_hovered
	_sync_hover_visual()

func is_pointer_hovered() -> bool:
	return _hovered and _available

func intersects_world_rect(world_rect: Rect2) -> bool:
	if not _available or not is_visible_in_tree() or _chest_sprite == null:
		return false
	var sprite_rect: Rect2 = _chest_sprite.get_rect()
	var sprite_transform: Transform2D = _chest_sprite.global_transform
	var local_corners := PackedVector2Array([
		sprite_rect.position,
		Vector2(sprite_rect.end.x, sprite_rect.position.y),
		sprite_rect.end,
		Vector2(sprite_rect.position.x, sprite_rect.end.y),
	])
	var first_corner: Vector2 = sprite_transform * local_corners[0]
	var minimum: Vector2 = first_corner
	var maximum: Vector2 = first_corner
	for corner_index in range(1, local_corners.size()):
		var world_corner: Vector2 = sprite_transform * local_corners[corner_index]
		minimum.x = minf(minimum.x, world_corner.x)
		minimum.y = minf(minimum.y, world_corner.y)
		maximum.x = maxf(maximum.x, world_corner.x)
		maximum.y = maxf(maximum.y, world_corner.y)
	return Rect2(minimum, maximum - minimum).grow(3.0).intersects(world_rect)

func _on_input_event(viewport: Node, event: InputEvent, _shape_index: int) -> void:
	if not visible or not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	viewport.set_input_as_handled()
	_activate()

func _on_mouse_entered() -> void:
	set_pointer_hovered(true)

func _on_mouse_exited() -> void:
	set_pointer_hovered(false)

func _sync_hover_visual() -> void:
	if _chest_sprite == null:
		return
	if _idle_bounce_tween != null and _idle_bounce_tween.is_running():
		_idle_bounce_tween.kill()
	if _hover_tween != null and _hover_tween.is_running():
		_hover_tween.kill()
	_chest_sprite.position = _base_position
	_chest_sprite.scale = _base_scale
	if _hovered:
		_chest_sprite.modulate = Color("#fff0bd")
		_hover_tween = create_tween().set_loops()
		_hover_tween.tween_property(
			_chest_sprite,
			"position:y",
			_base_position.y - 6.0,
			0.18
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_hover_tween.parallel().tween_property(
			_chest_sprite,
			"scale",
			_base_scale * 1.06,
			0.18
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_hover_tween.tween_property(
			_chest_sprite,
			"position:y",
			_base_position.y,
			0.2
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_hover_tween.parallel().tween_property(
			_chest_sprite,
			"scale",
			_base_scale,
			0.2
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		_chest_sprite.modulate = Color.WHITE
		if _available:
			_start_idle_bounce()
	if _hover_sprite != null:
		_hover_sprite.visible = _available and _hovered

func _set_available(available: bool) -> void:
	_available = available
	visible = available
	input_pickable = available
	_hovered = false
	if not available:
		if _idle_bounce_tween != null and _idle_bounce_tween.is_running():
			_idle_bounce_tween.kill()
		if _appearance_tween != null and _appearance_tween.is_running():
			_appearance_tween.kill()
		_chest_sprite.position = _base_position
		_chest_sprite.scale = _base_scale
	_sync_hover_visual()
	_sync_item_glow()

func _start_idle_bounce() -> void:
	if not _available or _hovered or _chest_sprite == null:
		return
	if _idle_bounce_tween != null and _idle_bounce_tween.is_running():
		return
	var phase_delay: float = fposmod(float(get_instance_id()) * 0.61803398875, 0.8)
	_idle_bounce_tween = create_tween().set_loops()
	_idle_bounce_tween.tween_interval(0.75 + phase_delay)
	_idle_bounce_tween.tween_property(
		_chest_sprite,
		"position:y",
		_base_position.y - 9.0,
		0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_idle_bounce_tween.parallel().tween_property(
		_chest_sprite,
		"scale",
		_base_scale * 1.045,
		0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_idle_bounce_tween.tween_property(
		_chest_sprite,
		"position:y",
		_base_position.y,
		0.3
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_idle_bounce_tween.parallel().tween_property(
		_chest_sprite,
		"scale",
		_base_scale,
		0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_idle_bounce_tween.tween_interval(1.15)

func _configure_item_glow() -> void:
	if _item_glow == null:
		return
	var frame_count: int = int(float(ITEM_GLOW_SHEET.get_width()) / 128.0)
	_item_glow.call(
		"configure",
		ITEM_GLOW_SHEET,
		frame_count,
		ITEM_GLOW_FPS,
		ITEM_GLOW_DISPLAY_SIZE,
		_chest_sprite.global_position,
		true,
		frame_count,
		Vector2i(128, 128),
		0
	)
	_item_glow.position = Vector2.ZERO

func _sync_item_glow() -> void:
	if _item_glow != null and is_instance_valid(_item_glow):
		if _available and not _item_glow.is_inside_tree():
			_configure_item_glow()
		_item_glow.visible = _available

func _play_appearance() -> void:
	if _appearance_tween != null and _appearance_tween.is_running():
		_appearance_tween.kill()
	_chest_sprite.position = _base_position + Vector2(0.0, 14.0)
	_chest_sprite.scale = _base_scale * 0.55
	_appearance_tween = create_tween()
	_appearance_tween.tween_property(
		_chest_sprite,
		"position",
		_base_position + Vector2(0.0, -20.0),
		0.34
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_appearance_tween.parallel().tween_property(
		_chest_sprite,
		"scale",
		_base_scale * 1.16,
		0.34
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_appearance_tween.tween_property(
		_chest_sprite,
		"position",
		_base_position + Vector2(0.0, 2.0),
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_appearance_tween.parallel().tween_property(
		_chest_sprite,
		"scale",
		_base_scale * 0.94,
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_appearance_tween.tween_property(
		_chest_sprite,
		"position",
		_base_position,
		0.18
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_appearance_tween.parallel().tween_property(
		_chest_sprite,
		"scale",
		_base_scale,
		0.18
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _activate() -> bool:
	if not _available:
		return false
	activated.emit(island_id, global_position)
	return true
