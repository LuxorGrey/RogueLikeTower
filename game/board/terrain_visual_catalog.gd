class_name TerrainVisualCatalog
extends RefCounted

const PATH_VARIANTS: Array[Texture2D] = [
	preload("res://assets/sprites/terrain/tiles/path_01.png"),
	preload("res://assets/sprites/terrain/tiles/path_02.png"),
	preload("res://assets/sprites/terrain/tiles/path_03.png"),
]
const GRASS_VARIANTS: Array[Texture2D] = [
	preload("res://assets/sprites/terrain/tiles/grass_01.png"),
	preload("res://assets/sprites/terrain/tiles/grass_02.png"),
	preload("res://assets/sprites/terrain/tiles/grass_03.png"),
]
const MOUNTAIN_VARIANTS: Array[Texture2D] = [
	preload("res://assets/sprites/terrain/tiles/mountain_01.png"),
	preload("res://assets/sprites/terrain/tiles/mountain_02.png"),
	preload("res://assets/sprites/terrain/tiles/mountain_03.png"),
]
const GRASS_CLIFF_TEXTURE: Texture2D = preload("res://assets/sprites/terrain/tiles/grass_cliff_face.png")
const MOUNTAIN_CLIFF_TEXTURE: Texture2D = preload("res://assets/sprites/terrain/tiles/mountain_cliff_face.png")
const GRASS_CLIFF_SOURCE_COLOR: Color = Color("#406e4d")
const MOUNTAIN_CLIFF_SOURCE_COLOR: Color = Color("#646567")
const GRASS_CLIFF_FACE_COLOR: Color = Color("#407850")
const MOUNTAIN_CLIFF_FACE_COLOR: Color = Color("#3b3c41")
const PATH_REGION_OUTLINE_COLOR: Color = Color("#FFD052")
const GRASS_REGION_OUTLINE_COLOR: Color = Color("#406e4d")
const MOUNTAIN_REGION_OUTLINE_COLOR: Color = Color("#646567")
const OBSTACLE_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/terrain/obstacles/obstacle_bramble_bush.png"),
	preload("res://assets/sprites/terrain/obstacles/obstacle_fallen_log.png"),
	preload("res://assets/sprites/terrain/obstacles/obstacle_branch_pile.png"),
	preload("res://assets/sprites/terrain/obstacles/obstacle_tree_stump.png"),
	preload("res://assets/sprites/terrain/obstacles/obstacle_rock_and_wood.png"),
	preload("res://assets/sprites/terrain/obstacles/obstacle_supply_crate.png"),
	preload("res://assets/sprites/terrain/obstacles/obstacle_exposed_roots.png"),
	preload("res://assets/sprites/terrain/obstacles/obstacle_mossy_rock_cluster.png"),
]
const GRASS_PROP_IDS: Array[StringName] = [
	&"prop_grass_tuft_small", &"prop_grass_tuft_wide", &"prop_grass_sprout",
	&"prop_grass_stone_cluster", &"prop_grass_rock", &"prop_grass_mushroom_red",
	&"prop_grass_mushroom_amber", &"prop_grass_flower_yellow",
]
const MOUNTAIN_PROP_IDS: Array[StringName] = [
	&"prop_mountain_rock_cluster", &"prop_mountain_mossy_rock", &"prop_mountain_tuft_grass",
	&"prop_mountain_stone_scatter", &"prop_mountain_rock_small",
]
const PATH_PROP_IDS: Array[StringName] = [
	&"prop_path_gold_pebbles", &"prop_path_amber_stones", &"prop_path_dry_grass",
	&"prop_path_stone_scatter", &"prop_path_sand_pile",
]
const PROP_TEXTURES: Dictionary[StringName, Texture2D] = {
	&"prop_grass_tuft_small": preload("res://assets/sprites/terrain/random_props/grass/prop_grass_tuft_small.png"),
	&"prop_grass_tuft_wide": preload("res://assets/sprites/terrain/random_props/grass/prop_grass_tuft_wide.png"),
	&"prop_grass_sprout": preload("res://assets/sprites/terrain/random_props/grass/prop_grass_sprout.png"),
	&"prop_grass_stone_cluster": preload("res://assets/sprites/terrain/random_props/grass/prop_grass_stone_cluster.png"),
	&"prop_grass_rock": preload("res://assets/sprites/terrain/random_props/grass/prop_grass_rock.png"),
	&"prop_grass_mushroom_red": preload("res://assets/sprites/terrain/random_props/grass/prop_grass_mushroom_red.png"),
	&"prop_grass_mushroom_amber": preload("res://assets/sprites/terrain/random_props/grass/prop_grass_mushroom_amber.png"),
	&"prop_grass_flower_yellow": preload("res://assets/sprites/terrain/random_props/grass/prop_grass_flower_yellow.png"),
	&"prop_mountain_rock_cluster": preload("res://assets/sprites/terrain/random_props/mountain/prop_mountain_rock_cluster.png"),
	&"prop_mountain_mossy_rock": preload("res://assets/sprites/terrain/random_props/mountain/prop_mountain_mossy_rock.png"),
	&"prop_mountain_tuft_grass": preload("res://assets/sprites/terrain/random_props/mountain/prop_mountain_tuft_grass.png"),
	&"prop_mountain_stone_scatter": preload("res://assets/sprites/terrain/random_props/mountain/prop_mountain_stone_scatter.png"),
	&"prop_mountain_rock_small": preload("res://assets/sprites/terrain/random_props/mountain/prop_mountain_rock_small.png"),
	&"prop_path_gold_pebbles": preload("res://assets/sprites/terrain/random_props/path/prop_path_gold_pebbles.png"),
	&"prop_path_amber_stones": preload("res://assets/sprites/terrain/random_props/path/prop_path_amber_stones.png"),
	&"prop_path_dry_grass": preload("res://assets/sprites/terrain/random_props/path/prop_path_dry_grass.png"),
	&"prop_path_stone_scatter": preload("res://assets/sprites/terrain/random_props/path/prop_path_stone_scatter.png"),
	&"prop_path_sand_pile": preload("res://assets/sprites/terrain/random_props/path/prop_path_sand_pile.png"),
}
const TREASURE_CHEST: Texture2D = preload("res://assets/sprites/terrain/treasure_chest.png")
const TERRAIN_VARIANT_COUNT: int = 3
const OBSTACLE_COUNT: int = 8
const OBSTACLE_DISPLAY_NAMES: Array[String] = [
	"Matorral", "Tronco caído", "Montón de ramas", "Tocón",
	"Rocas y madera", "Caja de suministros", "Raíces expuestas", "Roca musgosa",
]
const OBSTACLE_DESCRIPTIONS: Array[String] = [
	"Vegetación densa que bloquea la construcción.",
	"Un tronco atraviesa la casilla y estorba el paso de obra.",
	"Ramas amontonadas ocupan el espacio de construcción.",
	"El resto de un árbol impide levantar una torre aquí.",
	"Piedras y madera cubren esta casilla.",
	"Una caja abandonada ocupa el lugar de una torre.",
	"Las raíces sobresalen y bloquean la construcción.",
	"Una roca cubierta de musgo ocupa la casilla.",
]
const OBSTACLE_DISPLAY_SIZE: Vector2 = Vector2(94.6, 94.6)
const PROP_DISPLAY_SIZE: Vector2 = Vector2(39.6, 39.6)
const PROP_CHANCE_PER_ASSET: float = 0.10
const MAX_PROPS_PER_CELL: int = 2
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

static func get_prop_texture(prop_id: StringName) -> Texture2D:
	return PROP_TEXTURES.get(prop_id) as Texture2D

static func get_prop_ids_for_terrain(terrain_type: int) -> Array[StringName]:
	match terrain_type:
		HexCell.TerrainType.GRASS:
			return GRASS_PROP_IDS.duplicate()
		HexCell.TerrainType.MOUNTAIN:
			return MOUNTAIN_PROP_IDS.duplicate()
		_:
			return PATH_PROP_IDS.duplicate()

static func get_cliff_texture(terrain_type: int) -> Texture2D:
	if terrain_type == HexCell.TerrainType.GRASS:
		return GRASS_CLIFF_TEXTURE
	return MOUNTAIN_CLIFF_TEXTURE

static func get_cliff_face_color(terrain_type: int) -> Color:
	if terrain_type == HexCell.TerrainType.GRASS:
		return GRASS_CLIFF_FACE_COLOR
	return MOUNTAIN_CLIFF_FACE_COLOR

static func get_cliff_face_colors(
	terrain_type: int
) -> PackedColorArray:
	var source_color: Color = GRASS_CLIFF_SOURCE_COLOR
	if terrain_type == HexCell.TerrainType.MOUNTAIN:
		source_color = MOUNTAIN_CLIFF_SOURCE_COLOR
	var target_color: Color = get_cliff_face_color(terrain_type)
	# The cliff PNGs are flat fills. This ratio makes their displayed upper color
	# equal the requested palette color while keeping the existing textured path.
	var face_tint := Color(
		target_color.r / maxf(source_color.r, 0.001),
		target_color.g / maxf(source_color.g, 0.001),
		target_color.b / maxf(source_color.b, 0.001),
		1.0
	)
	return PackedColorArray([face_tint, face_tint, face_tint, face_tint])

static func get_cliff_gradient_colors() -> PackedColorArray:
	var transparent_black := Color(0.0, 0.0, 0.0, 0.0)
	var opaque_black := Color(0.0, 0.0, 0.0, 1.0)
	return PackedColorArray([
		transparent_black,
		transparent_black,
		opaque_black,
		opaque_black,
	])

static func get_obstacle_display_name(obstacle_type: int) -> String:
	if obstacle_type < 0 or obstacle_type >= OBSTACLE_DISPLAY_NAMES.size():
		return "Obstáculo"
	return OBSTACLE_DISPLAY_NAMES[obstacle_type]

static func get_obstacle_description(obstacle_type: int) -> String:
	if obstacle_type < 0 or obstacle_type >= OBSTACLE_DESCRIPTIONS.size():
		return "Ocupa una casilla y bloquea la construcción."
	return OBSTACLE_DESCRIPTIONS[obstacle_type]

static func get_elevation_tint(elevation: int) -> Color:
	var height_level: int = clampi(elevation, 0, 3)
	var shade_multiplier: float = 1.0 - 0.05 * float(height_level)
	return Color(shade_multiplier, shade_multiplier, shade_multiplier, 1.0)

static func get_region_outline_color(terrain_type: int) -> Color:
	match terrain_type:
		HexCell.TerrainType.PATH:
			return PATH_REGION_OUTLINE_COLOR
		HexCell.TerrainType.GRASS:
			return GRASS_REGION_OUTLINE_COLOR
		HexCell.TerrainType.MOUNTAIN:
			return MOUNTAIN_REGION_OUTLINE_COLOR
		_:
			return Color.WHITE

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
		var offer_key := "%d:%d:%s:%d:%d" % [
			run_seed,
			offer_index,
			String(piece.id),
			offer_cell.local_coord.x,
			offer_cell.local_coord.y,
		]
		var prop_rng := RandomNumberGenerator.new()
		prop_rng.seed = hash(offer_key + ":props")
		offer_cell.decorative_prop_ids = _roll_decorative_props(offer_cell.terrain_type, prop_rng)
		if offer_cell.terrain_type != HexCell.TerrainType.PATH:
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

static func set_random_cell_contents(
	cell: HexCell,
	run_seed: int,
	chest_chance: float,
	base_coord: Vector2i
) -> void:
	if cell == null:
		return
	cell.elevation = get_random_elevation(cell.terrain_type, run_seed, cell.coord.to_key())
	constrain_base_adjacent_cell(cell, base_coord, run_seed)
	set_random_visual_variant(cell, run_seed)
	cell.decorative_prop_ids = get_decorative_prop_ids(
		cell.terrain_type,
		run_seed,
		cell.coord.to_key()
	)
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

static func constrain_base_adjacent_cell(cell: HexCell, base_coord: Vector2i, run_seed: int) -> void:
	if cell == null or not _is_adjacent_to_base(cell.coord.to_key(), base_coord):
		return
	if cell.terrain_type == HexCell.TerrainType.MOUNTAIN:
		cell.terrain_type = HexCell.TerrainType.GRASS
		cell.buildable = true
	cell.elevation = 0 if cell.terrain_type == HexCell.TerrainType.PATH else 1
	cell.decorative_prop_ids = get_decorative_prop_ids(
		cell.terrain_type,
		run_seed,
		cell.coord.to_key()
	)
	set_random_visual_variant(cell, run_seed)

static func get_decorative_prop_ids(
	terrain_type: int,
	run_seed: int,
	coord: Vector2i
) -> Array[StringName]:
	var prop_rng := _rng_for(run_seed, coord, 71)
	return _roll_decorative_props(terrain_type, prop_rng)

static func _roll_decorative_props(
	terrain_type: int,
	rng: RandomNumberGenerator
) -> Array[StringName]:
	var selected: Array[StringName] = []
	for prop_id in get_prop_ids_for_terrain(terrain_type):
		if rng.randf() < PROP_CHANCE_PER_ASSET:
			selected.append(prop_id)
	while selected.size() > MAX_PROPS_PER_CELL:
		var remove_index: int = rng.randi_range(0, selected.size() - 1)
		selected.remove_at(remove_index)
	return selected

static func _is_adjacent_to_base(coord: Vector2i, base_coord: Vector2i) -> bool:
	for direction in HexCoord.DIRECTION_OFFSETS:
		if coord == base_coord + direction:
			return true
	return false

static func set_random_visual_variant(cell: HexCell, run_seed: int) -> void:
	if cell == null:
		return
	cell.visual_variant = get_random_visual_variant(
		cell.terrain_type,
		run_seed,
		cell.coord.to_key()
	)

static func get_random_visual_variant(
	terrain_type: int,
	run_seed: int,
	coord: Vector2i
) -> StringName:
	var visual_rng := _rng_for(run_seed, coord, 17)
	var terrain_prefix: String = _terrain_prefix(terrain_type)
	return StringName("%s_%d" % [terrain_prefix, visual_rng.randi_range(0, TERRAIN_VARIANT_COUNT - 1)])

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
