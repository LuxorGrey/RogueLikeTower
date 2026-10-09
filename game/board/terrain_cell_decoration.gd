class_name TerrainCellDecoration
extends Node2D

const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")

const CHEST_DISPLAY_SIZE: Vector2 = Vector2(84.0, 84.0)
const ART_SHADOW_COLOR: Color = Color(0.025, 0.035, 0.025, 0.40)
const ART_OFFSET_Y: float = 6.0

var _obstacle_type: int = HexCell.ObstacleType.NONE
var _chest_available: bool = false

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func configure(obstacle_type: int, chest_available: bool) -> void:
	_obstacle_type = obstacle_type
	_chest_available = chest_available
	queue_redraw()

func _draw() -> void:
	var visual_size: Vector2 = _get_visual_size()
	if visual_size == Vector2.ZERO:
		return
	draw_set_transform(Vector2(0.0, ART_OFFSET_Y + 1.0), 0.0, Vector2(1.0, 0.34))
	draw_circle(Vector2.ZERO, maxf(visual_size.x * 0.37, 24.0), ART_SHADOW_COLOR)
	draw_set_transform(Vector2(0.0, ART_OFFSET_Y), 0.0, Vector2.ONE)
	if _obstacle_type >= 0 and _obstacle_type < TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_COUNT:
		var source_region: Rect2 = TERRAIN_VISUAL_CATALOG_SCRIPT.get_obstacle_art_region(_obstacle_type)
		draw_texture_rect_region(
			TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLES_ATLAS,
			Rect2(Vector2(-visual_size.x * 0.5, -visual_size.y), visual_size),
			source_region
		)
	elif _chest_available:
		draw_texture_rect(
			TERRAIN_VISUAL_CATALOG_SCRIPT.TREASURE_CHEST,
			Rect2(Vector2(-CHEST_DISPLAY_SIZE.x * 0.5, -CHEST_DISPLAY_SIZE.y), CHEST_DISPLAY_SIZE),
			false
		)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _get_visual_size() -> Vector2:
	if _obstacle_type >= 0 and _obstacle_type < TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_COUNT:
		return TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_DISPLAY_SIZE
	if _chest_available:
		return CHEST_DISPLAY_SIZE
	return Vector2.ZERO
