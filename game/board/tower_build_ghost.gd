class_name TowerBuildGhost
extends Node2D

const HEX_RADIUS: float = 52.0
const ART_OFFSET_Y: float = 8.0
const TOWER_GHOST_SHADER: Shader = preload("res://game/board/tower_placement_ghost.gdshader")
const TOWER_ART_CATALOG_SCRIPT: Script = preload("res://game/towers/tower_art_catalog.gd")

var _board_cells: Dictionary[Vector2i, HexCell] = {}
var _active: bool = false
var _coord: Vector2i = Vector2i.ZERO
var _is_valid: bool = false
var _range_pixels: float = 0.0
var _icon: Texture2D
var _tower_id: StringName = &""
var _icon_size: float = 54.0
var _elevation_damage_bonus_per_level: float = 1.0
var _icon_sprite: Sprite2D
var _base_sprite: Sprite2D
var _turret_pivot: Node2D
var _turret_sprite: Sprite2D
var _ghost_material: ShaderMaterial

func _ready() -> void:
	z_as_relative = false
	z_index = 4096
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_icon_sprite = Sprite2D.new()
	_icon_sprite.name = "PlacementGhostSprite"
	_icon_sprite.centered = true
	_icon_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_ghost_material = ShaderMaterial.new()
	_ghost_material.shader = TOWER_GHOST_SHADER
	_icon_sprite.material = _ghost_material
	add_child(_icon_sprite)

func set_preview(
	active: bool,
	coord: Vector2i,
	is_valid: bool,
	range_pixels: float,
	icon: Texture2D,
	icon_size: float,
	board_cells: Dictionary[Vector2i, HexCell],
	elevation_damage_bonus_per_level: float,
	tower_id: StringName = &""
) -> void:
	_active = active
	_coord = coord
	_is_valid = is_valid
	_range_pixels = maxf(range_pixels, 0.0)
	_icon = icon
	_tower_id = tower_id
	_icon_size = maxf(icon_size, 1.0)
	_elevation_damage_bonus_per_level = maxf(elevation_damage_bonus_per_level, 0.0)
	_board_cells = board_cells
	visible = active
	_sync_ghost_sprite()
	queue_redraw()

func _sync_ghost_sprite() -> void:
	if _icon_sprite == null:
		return
	var definition: Dictionary = TOWER_ART_CATALOG_SCRIPT.get_definition(_tower_id)
	var has_split_art: bool = not definition.is_empty()
	_icon_sprite.visible = _active and _icon != null and not has_split_art
	if has_split_art:
		_sync_split_ghost_art()
		_base_sprite.visible = _active
		_turret_pivot.visible = _active
	elif _base_sprite != null:
		_base_sprite.visible = false
		_turret_pivot.visible = false
	if not _active:
		return
	var cell: HexCell = _board_cells.get(_coord) as HexCell
	if cell == null:
		_icon_sprite.visible = false
		if _base_sprite != null:
			_base_sprite.visible = false
		if _turret_pivot != null:
			_turret_pivot.visible = false
		return
	var center: Vector2 = HexMath.axial_to_world(HexCoord.new(_coord.x, _coord.y), HEX_RADIUS)
	center.y -= float(cell.elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
	if not has_split_art and _icon != null:
		_icon_sprite.position = center + Vector2(0.0, -_icon_size * 0.5 + ART_OFFSET_Y)
		_icon_sprite.texture = _icon
		_icon_sprite.scale = Vector2.ONE * _icon_size / Vector2(_icon.get_size())
	var ghost_color: Color = Color("#55f28a") if _is_valid else Color("#ff5056")
	_ghost_material.set_shader_parameter("ghost_color", ghost_color)
	if has_split_art:
		_base_sprite.visible = true
		_turret_pivot.visible = true
		_base_sprite.position = center + TOWER_ART_CATALOG_SCRIPT.get_part_offset(
			_tower_id,
			&"base",
			_icon_size * 1.12
		)
		_turret_pivot.position = center
		_turret_sprite.position = TOWER_ART_CATALOG_SCRIPT.get_part_offset(
			_tower_id,
			&"turret",
			_icon_size * 1.12
		)
		var component_scale: float = TOWER_ART_CATALOG_SCRIPT.get_component_scale(
			_tower_id,
			_icon_size * 1.12
		)
		_base_sprite.scale = Vector2.ONE * component_scale
		_turret_sprite.scale = Vector2.ONE * component_scale
		_base_sprite.material.set_shader_parameter("ghost_color", ghost_color)
		_turret_sprite.material.set_shader_parameter("ghost_color", ghost_color)

func _sync_split_ghost_art() -> void:
	if _base_sprite != null:
		return
	_base_sprite = _create_ghost_part("PlacementGhostBase")
	add_child(_base_sprite)
	_turret_pivot = Node2D.new()
	_turret_pivot.name = "PlacementGhostTurretPivot"
	add_child(_turret_pivot)
	_turret_sprite = _create_ghost_part("PlacementGhostTurret")
	_turret_pivot.add_child(_turret_sprite)
	_base_sprite.texture = TOWER_ART_CATALOG_SCRIPT.get_part_texture(_tower_id, &"base")
	_turret_sprite.texture = TOWER_ART_CATALOG_SCRIPT.get_part_texture(_tower_id, &"turret")

func _create_ghost_part(sprite_name: String) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = sprite_name
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var material := ShaderMaterial.new()
	material.shader = TOWER_GHOST_SHADER
	sprite.material = material
	return sprite

func _draw() -> void:
	if not _active:
		return
	var cell: HexCell = _board_cells.get(_coord) as HexCell
	if cell == null:
		return
	var center: Vector2 = HexMath.axial_to_world(HexCoord.new(_coord.x, _coord.y), HEX_RADIUS)
	center.y -= float(cell.elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
	var valid_tint := Color(0.22, 1.0, 0.40, 0.96)
	var invalid_tint := Color(1.0, 0.12, 0.10, 0.98)
	var tint: Color = valid_tint if _is_valid else invalid_tint
	if _range_pixels > 0.0:
		draw_arc(center, _range_pixels, 0.0, TAU, 72, Color(tint.r, tint.g, tint.b, 0.38), 2.0, true)
	var corners := PackedVector2Array()
	var axial_coord := HexCoord.new(_coord.x, _coord.y)
	for corner_index in range(6):
		var corner: Vector2 = HexMath.axial_hex_corner(axial_coord, corner_index, HEX_RADIUS)
		corner.y -= float(cell.elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
		corners.append(corner)
	corners.append(corners[0])
	draw_polyline(corners, tint, 4.0, true)
	for corner_index in range(corners.size() - 1):
		draw_circle(corners[corner_index], 2.0, tint)
	if cell.elevation > 0:
		var damage_bonus: float = float(cell.elevation) * _elevation_damage_bonus_per_level
		var bonus_text: String = "%d" % roundi(damage_bonus) if is_equal_approx(damage_bonus, roundf(damage_bonus)) else "%.1f" % damage_bonus
		var badge_center: Vector2 = center + Vector2(0.0, -HEX_RADIUS - 13.0)
		var badge_rect := Rect2(badge_center + Vector2(-26.0, -11.0), Vector2(52.0, 22.0))
		draw_rect(badge_rect, Color("#10231a"), true)
		draw_rect(badge_rect, Color("#8de7aa"), false, 1.5, true)
		draw_string(ThemeDB.fallback_font, badge_center + Vector2(-20.0, 5.0), "+%s daño" % bonus_text, HORIZONTAL_ALIGNMENT_LEFT, 42.0, 12, Color.WHITE)
	if _icon == null:
		draw_circle(center + Vector2(0.0, -7.0 + ART_OFFSET_Y), 9.0, tint)
