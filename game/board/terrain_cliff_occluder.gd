extends Node2D

const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")
const HEX_RADIUS: float = 52.0
const CLIFF_TEXTURE_PIXEL_DENSITY: float = 20.0

var _terrain_type: int = HexCell.TerrainType.GRASS
var _coord: Vector2i = Vector2i.ZERO
var _elevation: int = 0
var _neighbor_elevation: int = 0
var _direction_index: int = 1

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func configure_cliff(
	terrain_type: int,
	coord: Vector2i,
	elevation: int,
	neighbor_elevation: int,
	direction_index: int
) -> void:
	_terrain_type = terrain_type
	_coord = coord
	_elevation = maxi(elevation, 0)
	_neighbor_elevation = clampi(neighbor_elevation, 0, _elevation)
	_direction_index = posmod(direction_index, 6)
	queue_redraw()

func _draw() -> void:
	var exposed_levels: int = _elevation - _neighbor_elevation
	if exposed_levels <= 0:
		return
	var axial_coord := HexCoord.new(_coord.x, _coord.y)
	var ground_center: Vector2 = HexMath.axial_to_world(axial_coord, HEX_RADIUS)
	var lower_offset := Vector2(
		0.0,
		float(_neighbor_elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
	)
	var vertical_offset := Vector2(
		0.0,
		float(exposed_levels) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
	)
	var edge_start: int = posmod(_direction_index + 1, 6)
	var edge_end: int = posmod(_direction_index + 2, 6)
	var upper_level_offset := Vector2(
		0.0,
		float(_elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
	)
	var upper_start_world: Vector2 = HexMath.axial_hex_corner(axial_coord, edge_start, HEX_RADIUS)
	var upper_end_world: Vector2 = HexMath.axial_hex_corner(axial_coord, edge_end, HEX_RADIUS)
	var sort_anchor: Vector2 = (
		(upper_start_world + upper_end_world) * 0.5
		- ground_center
		- lower_offset
	)
	var cliff_texture: Texture2D = TERRAIN_VISUAL_CATALOG_SCRIPT.get_cliff_texture(_terrain_type)
	var texture_size: Vector2i = cliff_texture.get_size()
	var upper_start: Vector2 = upper_start_world - ground_center - upper_level_offset - sort_anchor
	var upper_end: Vector2 = upper_end_world - ground_center - upper_level_offset - sort_anchor
	var lower_start: Vector2 = upper_start_world - ground_center - lower_offset - sort_anchor
	var lower_end: Vector2 = upper_end_world - ground_center - lower_offset - sort_anchor
	var edge_length: float = upper_end.distance_to(upper_start)
	var uv_span := Vector2(
		edge_length * CLIFF_TEXTURE_PIXEL_DENSITY / float(texture_size.x),
		vertical_offset.length() * CLIFF_TEXTURE_PIXEL_DENSITY / float(texture_size.y)
	)
	var max_u_start: float = maxf(1.0 - uv_span.x, 0.0)
	var elevated_center: Vector2 = ground_center - upper_level_offset
	var uv_seed: float = (
		elevated_center.x + elevated_center.y * 1.73 + float(_direction_index) * HEX_RADIUS
	) * CLIFF_TEXTURE_PIXEL_DENSITY / float(texture_size.x)
	var uv_left: float = fposmod(uv_seed, max_u_start) if max_u_start > 0.0 else 0.0
	var cliff_uvs := PackedVector2Array([
		Vector2(uv_left, 0.0),
		Vector2(uv_left + uv_span.x, 0.0),
		Vector2(uv_left + uv_span.x, uv_span.y),
		Vector2(uv_left, uv_span.y),
	])
	var cliff_quad := PackedVector2Array([
		upper_start,
		upper_end,
		lower_end,
		lower_start,
	])
	draw_polygon(
		cliff_quad,
		TERRAIN_VISUAL_CATALOG_SCRIPT.get_cliff_face_colors(
			_terrain_type,
			_direction_index
		),
		cliff_uvs,
		cliff_texture
	)
