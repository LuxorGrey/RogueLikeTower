class_name TerrainSurfaceOccluder
extends Node2D

const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")
const HEX_RADIUS: float = 52.0

var _terrain_type: int = HexCell.TerrainType.GRASS
var _visual_variant: StringName = &""
var _coord: Vector2i = Vector2i.ZERO

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func configure_surface(terrain_type: int, visual_variant: StringName, coord: Vector2i) -> void:
	_terrain_type = terrain_type
	_visual_variant = visual_variant
	_coord = coord
	queue_redraw()

func _draw() -> void:
	var radius: float = HEX_RADIUS
	var tile_size := Vector2(HEX_RADIUS * sqrt(3.0), HEX_RADIUS * 2.0)
	var corners := _hex_corners(radius)
	draw_colored_polygon(corners, _terrain_color(_terrain_type))

	var tile_region: Rect2 = TERRAIN_VISUAL_CATALOG_SCRIPT.get_terrain_art_region(
		_terrain_type,
		_visual_variant,
		_coord
	)
	var texture: Texture2D = TERRAIN_VISUAL_CATALOG_SCRIPT.TERRAIN_ATLAS
	var atlas_size := Vector2(texture.get_size())
	var texture_uvs := PackedVector2Array()
	var tile_rect := Rect2(-tile_size * 0.5, tile_size)
	for point in corners:
		var tile_uv: Vector2 = (point - tile_rect.position) / tile_rect.size
		texture_uvs.append((tile_region.position + tile_uv * tile_region.size) / atlas_size)
	draw_polygon(
		corners,
		PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE]),
		texture_uvs,
		texture
	)

func _hex_corners(radius: float) -> PackedVector2Array:
	var corners := PackedVector2Array()
	for corner_index in range(6):
		var angle_radians: float = deg_to_rad(-90.0 + 60.0 * float(corner_index))
		corners.append(Vector2(cos(angle_radians), sin(angle_radians)) * radius)
	return corners

func _terrain_color(terrain_type: int) -> Color:
	match terrain_type:
		HexCell.TerrainType.PATH:
			return Color(0.35, 0.40, 0.43)
		HexCell.TerrainType.GRASS:
			return Color(0.28, 0.57, 0.34)
		HexCell.TerrainType.MOUNTAIN:
			return Color(0.63, 0.58, 0.48)
		_:
			return Color.MAGENTA
