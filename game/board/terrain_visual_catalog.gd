class_name TerrainVisualCatalog
extends RefCounted

const TERRAIN_ATLAS: Texture2D = preload("res://assets/terrain/terrain_atlas.png")
const OBSTACLES_ATLAS: Texture2D = preload("res://assets/terrain/obstacles_atlas.png")
const TREASURE_CHEST: Texture2D = preload("res://assets/terrain/treasure_chest.png")
const TERRAIN_VARIANT_COUNT: int = 3
const OBSTACLE_COUNT: int = 5
const OBSTACLE_COLUMNS: int = 3
const OBSTACLE_DISPLAY_SIZE: Vector2 = Vector2(104.0, 104.0)
const GRASS_OBSTACLE_CHANCE: float = 0.25
const MOUNTAIN_OBSTACLE_CHANCE: float = 0.15
const BASE_CHEST_CHANCE: float = 0.01
const MAX_CHEST_CHANCE: float = 0.20
const CHEST_CHANCE_PER_LEVEL: float = 0.05
const CHEST_GOLD_REWARD: int = 25
const TERRAIN_REFERENCE_SLOT_SIZE: Vector2 = Vector2(418.0, 418.0)
const TERRAIN_ART_BOUNDS: Array[Array] = [
	[Rect2(60.0, 14.0, 330.0, 367.0), Rect2(45.0, 13.0, 329.0, 367.0), Rect2(29.0, 13.0, 329.0, 367.0)],
	[Rect2(60.0, 3.0, 330.0, 368.0), Rect2(43.0, 3.0, 330.0, 368.0), Rect2(28.0, 3.0, 330.0, 368.0)],
	[Rect2(60.0, 0.0, 330.0, 366.0), Rect2(43.0, 0.0, 330.0, 366.0), Rect2(29.0, 0.0, 329.0, 366.0)],
]
const OBSTACLE_ART_BOUNDS: Array[Rect2] = [
	Rect2(85.0, 114.0, 370.0, 329.0),
	Rect2(159.0, 59.0, 212.0, 405.0),
	Rect2(56.0, 81.0, 358.0, 364.0),
	Rect2(124.0, 23.0, 204.0, 417.0),
	Rect2(72.0, 138.0, 389.0, 263.0),
]

static func get_terrain_region(terrain_type: int, visual_variant: StringName, coord: Vector2i) -> Rect2:
	var columns: int = TERRAIN_VARIANT_COUNT
	var slot_size := Vector2(
		float(TERRAIN_ATLAS.get_width()) / float(columns),
		float(TERRAIN_ATLAS.get_height()) / float(columns)
	)
	var prefix: String = _terrain_prefix(terrain_type)
	var variant_index: int = _variant_index(prefix, visual_variant, coord, terrain_type)
	var row: int = clampi(terrain_type, HexCell.TerrainType.PATH, HexCell.TerrainType.MOUNTAIN)
	return Rect2(Vector2(float(variant_index) * slot_size.x, float(row) * slot_size.y), slot_size)

static func get_terrain_art_region(terrain_type: int, visual_variant: StringName, coord: Vector2i) -> Rect2:
	var tile_region: Rect2 = get_terrain_region(terrain_type, visual_variant, coord)
	var slot_size := tile_region.size
	var row: int = clampi(terrain_type, HexCell.TerrainType.PATH, HexCell.TerrainType.MOUNTAIN)
	var variant_index: int = _variant_index(_terrain_prefix(terrain_type), visual_variant, coord, terrain_type)
	var reference_bounds: Rect2 = TERRAIN_ART_BOUNDS[row][variant_index]
	var scale_to_slot := slot_size / TERRAIN_REFERENCE_SLOT_SIZE
	return Rect2(
		tile_region.position + reference_bounds.position * scale_to_slot,
		reference_bounds.size * scale_to_slot
	)

static func get_obstacle_region(obstacle_type: int) -> Rect2:
	var slot_size := Vector2(
		float(OBSTACLES_ATLAS.get_width()) / float(OBSTACLE_COLUMNS),
		float(OBSTACLES_ATLAS.get_height()) / 2.0
	)
	var column: int = posmod(obstacle_type, OBSTACLE_COLUMNS)
	var row: int = floori(float(obstacle_type) / float(OBSTACLE_COLUMNS))
	return Rect2(Vector2(float(column) * slot_size.x, float(row) * slot_size.y), slot_size)

static func get_obstacle_art_region(obstacle_type: int) -> Rect2:
	var slot_region: Rect2 = get_obstacle_region(obstacle_type)
	var bounds: Rect2 = OBSTACLE_ART_BOUNDS[clampi(obstacle_type, 0, OBSTACLE_COUNT - 1)]
	var scale_to_slot := slot_region.size / Vector2(512.0, 512.0)
	return Rect2(slot_region.position + bounds.position * scale_to_slot, bounds.size * scale_to_slot)

static func set_random_cell_contents(cell: HexCell, run_seed: int, chest_chance: float) -> void:
	if cell == null:
		return
	var coord: Vector2i = cell.coord.to_key()
	var visual_rng := _rng_for(run_seed, coord, 17)
	var terrain_prefix: String = _terrain_prefix(cell.terrain_type)
	cell.visual_variant = StringName("%s_%d" % [terrain_prefix, visual_rng.randi_range(0, TERRAIN_VARIANT_COUNT - 1)])
	cell.obstacle_type = HexCell.ObstacleType.NONE
	cell.chest_available = false
	if cell.terrain_type == HexCell.TerrainType.PATH:
		return

	var obstacle_chance: float = (
		GRASS_OBSTACLE_CHANCE
		if cell.terrain_type == HexCell.TerrainType.GRASS
		else MOUNTAIN_OBSTACLE_CHANCE
	)
	var obstacle_rng := _rng_for(run_seed, coord, 31)
	if obstacle_rng.randf() < obstacle_chance:
		cell.obstacle_type = obstacle_rng.randi_range(0, OBSTACLE_COUNT - 1)
		return

	var chest_rng := _rng_for(run_seed, coord, 47)
	cell.chest_available = chest_rng.randf() < clampf(chest_chance, BASE_CHEST_CHANCE, MAX_CHEST_CHANCE)

static func _variant_index(prefix: String, visual_variant: StringName, coord: Vector2i, terrain_type: int) -> int:
	var name: String = String(visual_variant)
	if name.begins_with(prefix + "_"):
		var suffix: String = name.get_slice("_", 1)
		var parsed_index: int = suffix.to_int()
		if parsed_index >= 0 and parsed_index < TERRAIN_VARIANT_COUNT:
			return parsed_index
	return posmod(absi(coord.x * 31 + coord.y * 17 + terrain_type * 7), TERRAIN_VARIANT_COUNT)

static func _terrain_prefix(terrain_type: int) -> String:
	match terrain_type:
		HexCell.TerrainType.PATH:
			return "path"
		HexCell.TerrainType.GRASS:
			return "grass"
		HexCell.TerrainType.MOUNTAIN:
			return "mountain"
		_:
			return "path"

static func _rng_for(run_seed: int, coord: Vector2i, salt: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d:%d:%d:%d" % [run_seed, coord.x, coord.y, salt])
	return rng
