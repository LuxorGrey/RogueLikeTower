class_name IslandCardChest
extends Area2D

signal activated(island_id: StringName, world_position: Vector2)

const CHEST_TEXTURE: Texture2D = preload("res://assets/sprites/terrain/island_card_chest.png")
const DISPLAY_HEIGHT: float = 54.0

var island_id: StringName = &""
var _chest_sprite: Sprite2D
var _collision_shape: CollisionShape2D
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
	_chest_sprite.position = Vector2(0.0, -DISPLAY_HEIGHT * 0.5)
	add_child(_chest_sprite)

	_collision_shape = CollisionShape2D.new()
	_collision_shape.name = "IslandCardChestHitbox"
	var circle := CircleShape2D.new()
	circle.radius = 28.0
	_collision_shape.shape = circle
	_collision_shape.position = Vector2(0.0, -DISPLAY_HEIGHT * 0.45)
	add_child(_collision_shape)

	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_sync_hover_visual()

func configure(next_island_id: StringName, local_position: Vector2, available: bool) -> void:
	island_id = next_island_id
	position = local_position
	visible = available
	input_pickable = available
	queue_redraw()

func set_available(available: bool) -> void:
	visible = available
	input_pickable = available
	_hovered = false
	_sync_hover_visual()
	queue_redraw()

func _draw() -> void:
	if not visible:
		return
	var label_position := Vector2(-68.0, -DISPLAY_HEIGHT - 11.0)
	draw_string(
		ThemeDB.fallback_font,
		label_position,
		"ELIGE 1 CARTA",
		HORIZONTAL_ALIGNMENT_CENTER,
		136.0,
		11,
		Color("#f4ffff")
	)

func _on_input_event(viewport: Node, event: InputEvent, _shape_index: int) -> void:
	if not visible or not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	viewport.set_input_as_handled()
	activated.emit(island_id, global_position)

func _on_mouse_entered() -> void:
	_hovered = true
	_sync_hover_visual()

func _on_mouse_exited() -> void:
	_hovered = false
	_sync_hover_visual()

func _sync_hover_visual() -> void:
	if _chest_sprite == null:
		return
	_chest_sprite.scale = Vector2.ONE * (DISPLAY_HEIGHT / maxf(CHEST_TEXTURE.get_height(), 1.0))
	if _hovered:
		_chest_sprite.scale *= 1.08
		_chest_sprite.modulate = Color("#dfffff")
	else:
		_chest_sprite.modulate = Color.WHITE
