class_name TerrainVisualCatalog
extends RefCounted

const PATH_VARIANTS: Array[Texture2D] = [
	preload("res://assets/terrain/tiles/path_01.png"),
	preload("res://assets/terrain/tiles/path_02.png"),
	preload("res://assets/terrain/tiles/path_03.png"),
]
const GRASS_VARIANTS: Array[Texture2D] = [
	preload("res://assets/terrain/tiles/grass_01.png"),
	preload("res://assets/terrain/tiles/grass_02.png"),
	preload("res://assets/terrain/tiles/grass_03.png"),
]
const MOUNTAIN_VARIANTS: Array[Texture2D] = [
	preload("res://assets/terrain/tiles/mountain_01.png"),
	preload("res://assets/terrain/tiles/mountain_02.png"),
	preload("res://assets/terrain/tiles/mountain_03.png"),
]
const GRASS_CLIFF_TEXTURE: Texture2D = preload("res://assets/terrain/tiles/grass_cliff_face.png")
const MOUNTAIN_CLIFF_TEXTURE: Texture2D = preload("res://assets/terrain/tiles/mountain_cliff_face.png")
const GRASS_CLIFF_BOTTOM_TINT: Color = Color("#263b2b")
const MOUNTAIN_CLIFF_BOTTOM_TINT: Color = Color("#24242a")
const OBSTACLE_TEXTURES: Array[Texture2D] = [
	preload("res://assets/terrain/obstacles/rock.png"),
	preload("res://assets/terrain/obstacles/crystal_shard.png"),
	preload("res://assets/terrain/obstacles/tall_grass.png"),
	preload("res://assets/terrain/obstacles/totem.png"),
	preload("res://assets/terrain/obstacles/stone_pile.png"),
]
const TREASURE_CHEST: Texture2D = preload("res://assets/terrain/treasure_chest.png")
const TERRAIN_VARIANT_COUNT: int = 3
const OBSTACLE_COUNT: int = 5
const OBSTACLE_DISPLAY_NAMES: Array[String] = ["Roca", "Cristal", "Hierba alta", "Tótem", "Montón de piedra"]
const OBSTACLE_DISPLAY_SIZE: Vector2 = Vector2(86.0, 86.0)
const GRASS_OBSTACLE_CHANCE: float = 0.25
const MOUNTAIN_OBSTACLE_CHANCE: float = 0.15
const BASE_CHEST_CHANCE: float = 0.01
const MAX_CHEST_CHANCE: float = 0.20
const CHEST_CHANCE_PER_LEVEL: float = 0.05
const CHEST_GOLD_REWARD: int = 25

static func get_terrain_texture(terrain_type: int, visual_variant: StringName, coord: Vector2i) -> Texture2D:
	var variant_index: int = _variant_index(
		_terrain_prefix(terrain_type),
		visual_variant,
		coord,
		terrain_type
	)
	var variants: Array[Texture2D] = PATH_VARIANTS
	match terrain_type:
		HexCell.TerrainType.GRASS:
			variants = GRASS_VARIANTS
		HexCell.TerrainType.MOUNTAIN:
			variants = MOUNTAIN_VARIANTS
	return variants[variant_index]

static func get_obstacle_texture(obstacle_type: int) -> Texture2D:
	if obstacle_type < 0 or obstacle_type >= OBSTACLE_TEXTURES.size():
		return null
	return OBSTACLE_TEXTURES[obstacle_type]

static func get_cliff_texture(terrain_type: int) -> Texture2D:
	if terrain_type == HexCell.TerrainType.GRASS:
		return GRASS_CLIFF_TEXTURE
	return MOUNTAIN_CLIFF_TEXTURE

static func get_cliff_bottom_tint(terrain_type: int) -> Color:
	if terrain_type == HexCell.TerrainType.GRASS:
		return GRASS_CLIFF_BOTTOM_TINT
	return MOUNTAIN_CLIFF_BOTTOM_TINT

static func get_cliff_face_colors(terrain_type: int) -> PackedColorArray:
	var bottom_tint: Color = get_cliff_bottom_tint(terrain_type)
	return PackedColorArray([Color.WHITE, Color.WHITE, bottom_tint, bottom_tint])

static func get_obstacle_display_name(obstacle_type: int) -> String:
	if obstacle_type < 0 or obstacle_type >= OBSTACLE_DISPLAY_NAMES.size():
		return "Obstáculo"
	return OBSTACLE_DISPLAY_NAMES[obstacle_type]

static func get_elevation_tint(elevation: int) -> Color:
	var height_level: int = clampi(elevation, 0, 3)
	return Color(1.0 - 0.01 * float(height_level), 1.0 - 0.005 * float(height_level), 1.0)

static func create_piece_offer(
	piece: TerrainPieceData,
	run_seed: int,
	offer_index: int
) -> TerrainPieceData:
	if piece == null:
		return null
	var offer := TerrainPieceData.new()
	offer.id = piece.id
	offer.display_name = piece.display_name
	offer.weight = piece.weight
	offer.tags = piece.tags.duplicate()
	offer.requires_path_connection = piece.requires_path_connection
	for source_cell in piece.cells:
		if source_cell == null:
			continue
		var offer_cell := source_cell.duplicate(true) as TerrainPieceCellData
		if offer_cell == null:
			continue
		offer_cell.obstacle_type = HexCell.ObstacleType.NONE
		offer_cell.chest_available = false
		if offer_cell.terrain_type != HexCell.TerrainType.PATH:
			var offer_key := "%d:%d:%s:%d:%d" % [
				run_seed,
				offer_index,
				String(piece.id),
				offer_cell.local_coord.x,
				offer_cell.local_coord.y,
			]
			var obstacle_rng := RandomNumberGenerator.new()
			obstacle_rng.seed = hash(offer_key + ":obstacle")
			var elevation_rng := RandomNumberGenerator.new()
			elevation_rng.seed = hash(offer_key + ":elevation")
			offer_cell.elevation = _roll_elevation(offer_cell.terrain_type, elevation_rng)
			var obstacle_chance: float = (
				GRASS_OBSTACLE_CHANCE
				if offer_cell.terrain_type == HexCell.TerrainType.GRASS
				else MOUNTAIN_OBSTACLE_CHANCE
			)
			if obstacle_rng.randf() < obstacle_chance:
				offer_cell.obstacle_type = obstacle_rng.randi_range(0, OBSTACLE_COUNT - 1)
		offer.cells.append(offer_cell)
	limit_piece_obstacles(offer.cells, 2)
	return offer

static func limit_piece_obstacles(cells: Array[TerrainPieceCellData], maximum: int = 2) -> void:
	var obstacle_cells: Array[TerrainPieceCellData] = []
	for cell in cells:
		if cell != null and cell.obstacle_type != HexCell.ObstacleType.NONE:
			obstacle_cells.append(cell)
	obstacle_cells.sort_custom(func(a: TerrainPieceCellData, b: TerrainPieceCellData) -> bool:
		if a.local_coord.x != b.local_coord.x:
			return a.local_coord.x < b.local_coord.x
		return a.local_coord.y < b.local_coord.y
	)
	for index in range(maximum, obstacle_cells.size()):
		obstacle_cells[index].obstacle_type = HexCell.ObstacleType.NONE
		obstacle_cells[index].chest_available = false

static func enforce_starting_board_obstacles(
	cells: Dictionary[Vector2i, HexCell],
	base_coord: Vector2i
) -> void:
	var obstacles: Array[HexCell] = []
	for coord in cells:
		var cell: HexCell = cells[coord]
		if cell == null or cell.obstacle_type == HexCell.ObstacleType.NONE:
			continue
		var protected: bool = coord == base_coord
		for offset in HexCoord.DIRECTION_OFFSETS:
			if coord == base_coord + offset:
				protected = true
				break
		if protected:
			cell.obstacle_type = HexCell.ObstacleType.NONE
			cell.chest_available = false
		else:
			obstacles.append(cell)
	obstacles.sort_custom(func(a: HexCell, b: HexCell) -> bool:
		if a.coord.q != b.coord.q:
			return a.coord.q < b.coord.q
		return a.coord.r < b.coord.r
	)
	for index in range(1, obstacles.size()):
		obstacles[index].obstacle_type = HexCell.ObstacleType.NONE
		obstacles[index].chest_available = false

static func limit_hex_cell_obstacles(cells: Dictionary[Vector2i, HexCell], maximum: int = 2) -> void:
	var obstacle_cells: Array[HexCell] = []
	for coord in cells:
		var cell: HexCell = cells[coord]
		if cell != null and cell.obstacle_type != HexCell.ObstacleType.NONE:
			obstacle_cells.append(cell)
	obstacle_cells.sort_custom(func(a: HexCell, b: HexCell) -> bool:
		if a.coord.q != b.coord.q:
			return a.coord.q < b.coord.q
		return a.coord.r < b.coord.r
	)
	for index in range(maximum, obstacle_cells.size()):
		obstacle_cells[index].obstacle_type = HexCell.ObstacleType.NONE
		obstacle_cells[index].chest_available = false

static func roll_chest_at_placement(cell: HexCell, run_seed: int, chest_chance: float) -> void:
	if cell == null:
		return
	cell.chest_available = false
	if cell.terrain_type == HexCell.TerrainType.PATH or cell.obstacle_type != HexCell.ObstacleType.NONE:
		return
	var chest_rng := _rng_for(run_seed, cell.coord.to_key(), 47)
	cell.chest_available = chest_rng.randf() < clampf(
		chest_chance,
		BASE_CHEST_CHANCE,
		MAX_CHEST_CHANCE
	)

static func set_random_cell_contents(cell: HexCell, run_seed: int, chest_chance: float) -> void:
	if cell == null:
		return
	cell.elevation = get_random_elevation(cell.terrain_type, run_seed, cell.coord.to_key())
	set_random_visual_variant(cell, run_seed)
	cell.obstacle_type = HexCell.ObstacleType.NONE
	cell.chest_available = false
	if cell.terrain_type == HexCell.TerrainType.PATH:
		return

	var coord: Vector2i = cell.coord.to_key()
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

static func set_random_visual_variant(cell: HexCell, run_seed: int) -> void:
	if cell == null:
		return
	var coord: Vector2i = cell.coord.to_key()
	var visual_rng := _rng_for(run_seed, coord, 17)
	var terrain_prefix: String = _terrain_prefix(cell.terrain_type)
	cell.visual_variant = StringName("%s_%d" % [terrain_prefix, visual_rng.randi_range(0, TERRAIN_VARIANT_COUNT - 1)])

static func get_random_elevation(
	terrain_type: int,
	run_seed: int,
	coord: Vector2i,
	salt: int = 59
) -> int:
	if terrain_type == HexCell.TerrainType.PATH:
		return 0
	var elevation_rng := _rng_for(run_seed, coord, salt)
	return _roll_elevation(terrain_type, elevation_rng)

static func _roll_elevation(terrain_type: int, rng: RandomNumberGenerator) -> int:
	match terrain_type:
		HexCell.TerrainType.GRASS:
			return rng.randi_range(1, 2)
		HexCell.TerrainType.MOUNTAIN:
			return rng.randi_range(2, 3)
	return 0

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
