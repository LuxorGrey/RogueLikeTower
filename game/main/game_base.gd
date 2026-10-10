class_name GameBase
extends Node2D

signal health_changed(current_health: int, maximum_health: int)
signal defeated

const BASE_TILE_COLOR: Color = Color(0.36, 0.29, 0.16)
const BASE_OUTLINE: Color = Color(0.16, 0.13, 0.08)

@export var base_data: BaseData
@export_range(1.0, 200.0, 1.0) var footprint_radius: float = 52.0

@onready var _health: HealthComponent = %Health
@onready var _base_sprite: Sprite2D = %BaseSprite

var _is_hovered: bool = false

func _ready() -> void:
	_health.health_changed.connect(_on_health_changed)
	_health.health_depleted.connect(_on_health_depleted)
	if base_data == null:
		push_error("GameBase necesita BaseData.")
		return
	var validation_errors := base_data.validate()
	if not validation_errors.is_empty():
		push_error("BaseData inválido: %s" % "; ".join(validation_errors))
		return
	_health.initialize(base_data.max_health)
	_base_sprite.texture = base_data.sprite_texture
	_base_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	if base_data.sprite_texture != null:
		_base_sprite.scale = base_data.sprite_size / Vector2(base_data.sprite_texture.get_width(), base_data.sprite_texture.get_height())
	queue_redraw()

func apply_damage(amount: int) -> int:
	return _health.apply_damage(amount)

func heal(amount: int) -> int:
	return _health.heal(amount)

func get_current_health() -> int:
	return _health.current_health

func get_maximum_health() -> int:
	return _health.maximum_health

func set_hovered(is_hovered: bool) -> void:
	if _is_hovered == is_hovered:
		return
	_is_hovered = is_hovered
	queue_redraw()

func _draw() -> void:
	var footprint := _hex_corners(footprint_radius)
	var closed_footprint := footprint.duplicate()
	closed_footprint.append(footprint[0])
	draw_colored_polygon(footprint, BASE_TILE_COLOR)
	draw_polyline(closed_footprint, BASE_OUTLINE, 4.0, true)

	if _is_hovered:
		var hover_tint := Color(0.51, 0.75, 0.90, 0.34)
		draw_colored_polygon(footprint, hover_tint)
		draw_polyline(closed_footprint, Color(0.72, 0.87, 0.98), 5.0, true)

func _hex_corners(radius: float) -> PackedVector2Array:
	var corners := PackedVector2Array()
	for corner_index in range(6):
		var angle_radians: float = deg_to_rad(-90.0 + 60.0 * float(corner_index))
		corners.append(Vector2(cos(angle_radians), sin(angle_radians)) * radius)
	return corners

func _on_health_changed(current_health: int, maximum_health: int) -> void:
	health_changed.emit(current_health, maximum_health)
	queue_redraw()

func _on_health_depleted() -> void:
	defeated.emit()
