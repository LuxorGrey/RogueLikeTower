class_name DecorativeIslandField
extends Node2D

signal island_discovered(island_id: StringName)
signal treasure_open_requested(island_id: StringName, world_position: Vector2)

const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")
const TERRAIN_REGION_OUTLINE_SCRIPT: Script = preload("res://game/board/terrain_region_outline.gd")
const CAMPAIGN_ROUND_COUNT: int = 45
const HEX_RADIUS: float = 52.0
const HEX_NEIGHBOR_DISTANCE: float = HEX_RADIUS * 1.7320508
const MAX_ISLANDS: int = 6
const MIN_ISLAND_CELL_COUNT: int = 3
const MAX_ISLAND_CELL_COUNT: int = 7
const MIN_ANCHOR_GAP: int = 4
const MAX_ANCHOR_GAP: int = 7
const MIN_ISLAND_SEPARATION: int = 4
const START_ISLAND_MAX_DISTANCE: int = 8
const ISLAND_RING_BASE_DISTANCE: int = 8
const ISLAND_RING_STEP: int = 2
const ISLAND_RING_WIDTH: int = 3
const ISLAND_RING_EXPANSION_STEP: int = 4
const EMPTY_COORD: Vector2i = Vector2i(2147483647, 2147483647)
const TERRAIN_COLORS: Dictionary[int, Color] = {
	HexCell.TerrainType.GRASS: Color("#477653"),
	HexCell.TerrainType.MOUNTAIN: Color("#646567"),
}

var _templates: Array[TerrainPieceData] = []
var _island_groups: Array[ExplorationIslandData] = []
var _island_chests: Dictionary[StringName, IslandCardChest] = {}
var _reserved_island_coords: Dictionary[Vector2i, bool] = {}
var _board_cells: Dictionary[Vector2i, HexCell] = {}
var _run_seed: int = 0
var _campaign_round: int = 1
var _next_island_index: int = 0
var _base_coord: Vector2i = Vector2i.ZERO
var _initial_board_cell_count: int = 0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

func configure(
	templates: Array[TerrainPieceData],
	run_seed: int,
	campaign_round: int,
	board_cells: Dictionary[Vector2i, HexCell],
	base_coord: Vector2i
) -> void:
	_templates.assign(templates)
	_run_seed = run_seed
	_campaign_round = clampi(campaign_round, 1, CAMPAIGN_ROUND_COUNT)
	_board_cells = board_cells
	_initial_board_cell_count = board_cells.size()
	_base_coord = base_coord
	_island_groups.clear()
	_next_island_index = 0
	for chest in _island_chests.values():
		if is_instance_valid(chest):
			chest.queue_free()
	_island_chests.clear()
	_reserved_island_coords.clear()
	_ensure_island_groups_generated()
	queue_redraw()

func set_campaign_state(
	campaign_round: int,
	board_cells: Dictionary[Vector2i, HexCell]
) -> void:
	_campaign_round = clampi(campaign_round, 1, CAMPAIGN_ROUND_COUNT)
	_board_cells = board_cells
	_ensure_island_groups_generated()
	queue_redraw()

func get_visible_cells() -> Array[TerrainPieceCellData]:
	var visible_cells: Array[TerrainPieceCellData] = []
	for island in _island_groups:
		if not island.discovered or not _island_group_is_clear(island):
			continue
		visible_cells.append_array(island.cells)
	return visible_cells

func get_nearest_undiscovered_compass_target(camera_world_position: Vector2) -> Dictionary:
	var nearest_target: Dictionary = {}
	var nearest_distance: float = INF
	for island in _island_groups:
		if island.treasure_claimed:
			continue
		var world_position: Vector2 = to_global(_draw_axial_world_center(island.treasure_coord))
		var distance_world: float = world_position.distance_to(camera_world_position)
		if distance_world >= nearest_distance:
			continue
		nearest_distance = distance_world
		nearest_target = {
			"island_id": island.island_id,
			"island_number": island.island_index + 1,
			"spawn_round": island.spawn_round,
			"campaign_round": _campaign_round,
			"world_position": world_position,
			"camera_position": camera_world_position,
			"distance_hexes": distance_world / HEX_NEIGHBOR_DISTANCE,
		}
	return nearest_target

func get_reserved_coords() -> Dictionary[Vector2i, bool]:
	return _reserved_island_coords.duplicate()

func update_exploration(
	fog_center_world_position: Vector2,
	fog_reveal_radius: float,
	clear_edge_margin: float
) -> bool:
	var changed: bool = false
	var safe_reveal_radius: float = maxf(fog_reveal_radius - clear_edge_margin, 0.0)
	for island in _island_groups:
		if (
			island.spawn_round > _campaign_round
			or island.discovered
			or island.treasure_claimed
			or not _island_group_is_clear(island)
		):
			continue
		if island.island_index == 0 and _board_cells.size() <= _initial_board_cell_count:
			continue
		if not _island_group_is_inside_reveal_radius(island, fog_center_world_position, safe_reveal_radius):
			continue
		island.discovered = true
		_sync_island_chest(island)
		island_discovered.emit(island.island_id)
		changed = true
	if changed:
		queue_redraw()
	return changed

func mark_treasure_claimed(island_id: StringName) -> bool:
	var island: ExplorationIslandData = _get_island(island_id)
	if island == null or island.treasure_claimed:
		return false
	island.treasure_claimed = true
	_sync_island_chest(island)
	queue_redraw()
	return true

func try_activate_chest_at_world_position(world_position: Vector2) -> bool:
	for chest_variant in _island_chests.values():
		var chest: IslandCardChest = chest_variant as IslandCardChest
		if chest != null and is_instance_valid(chest):
			if chest.try_activate_at_world_position(world_position):
				return true
	return false

func update_chest_pointer_hover(world_position: Vector2, pointer_available: bool) -> void:
	var hovered_chest: IslandCardChest
	if pointer_available:
		for chest_variant in _island_chests.values():
			var chest: IslandCardChest = chest_variant as IslandCardChest
			if chest != null and is_instance_valid(chest):
				if chest.contains_world_position(world_position):
					hovered_chest = chest
					break
	for chest_variant in _island_chests.values():
		var chest: IslandCardChest = chest_variant as IslandCardChest
		if chest != null and is_instance_valid(chest):
			chest.set_pointer_hovered(chest == hovered_chest)

func has_hovered_chest() -> bool:
	for chest_variant in _island_chests.values():
		var chest: IslandCardChest = chest_variant as IslandCardChest
		if chest != null and is_instance_valid(chest) and chest.is_pointer_hovered():
			return true
	return false

func _ensure_island_groups_generated() -> void:
	while _next_island_index < MAX_ISLANDS:
		var spawn_round: int = _island_spawn_round(_next_island_index)
		var island: ExplorationIslandData = _create_island(_next_island_index, spawn_round)
		if island == null:
			push_warning("No se pudo reservar un espacio seguro para la isla %d." % (_next_island_index + 1))
			return
		_island_groups.append(island)
		_next_island_index += 1
		_rebuild_reserved_island_coords()

func _island_spawn_round(island_index: int) -> int:
	if island_index == 0:
		return 1
	return ceili(
		1.0 + float(island_index) * float(CAMPAIGN_ROUND_COUNT - 1) / float(MAX_ISLANDS - 1)
	)

func _create_island(island_index: int, spawn_round: int) -> ExplorationIslandData:
	if _templates.is_empty() or _board_cells.is_empty():
		return null
	var rng := RandomNumberGenerator.new()
	rng.seed = _run_seed ^ (7919 * (island_index + 1))
	var template: TerrainPieceData = _templates[rng.randi_range(0, _templates.size() - 1)]
	if template == null or template.cells.is_empty():
		return null
	var requested_count: int = rng.randi_range(MIN_ISLAND_CELL_COUNT, MAX_ISLAND_CELL_COUNT)
	var shape_cells: Array[TerrainPieceCellData] = _connected_template_subset(template, requested_count, rng)
	if shape_cells.size() < MIN_ISLAND_CELL_COUNT:
		return null
	var pivot: Vector2i = _template_pivot(template)
	var rotation_steps: int = rng.randi_range(0, 5)
	var relative_cells: Array[TerrainPieceCellData] = []
	for source_cell in shape_cells:
		var relative_coord: Vector2i = source_cell.local_coord - pivot
		var rotated := HexCoord.new(relative_coord.x, relative_coord.y).rotated60(rotation_steps)
		var cell := source_cell.duplicate(true) as TerrainPieceCellData
		if cell == null:
			continue
		cell.local_coord = rotated.to_key()
		cell.elevation = rng.randi_range(0, 2)
		cell.terrain_type = _decorative_terrain_for_height(cell.elevation, rng)
		cell.path_edges = 0
		cell.flexible_path_edges = 0
		cell.obstacle_type = HexCell.ObstacleType.NONE
		cell.chest_available = false
		cell.decorative_prop_ids.clear()
		cell.visual_variant = &""
		relative_cells.append(cell)

	var anchor: Vector2i = (
		_find_start_island_anchor(rng, island_index, relative_cells)
		if island_index == 0
		else _find_future_island_anchor(rng, island_index, relative_cells)
	)
	if anchor == EMPTY_COORD:
		return null
	var island := ExplorationIslandData.new()
	island.island_index = island_index
	island.island_id = StringName("island_%02d" % (island_index + 1))
	island.spawn_round = spawn_round
	island.anchor_coord = anchor
	for cell in relative_cells:
		cell.local_coord += anchor
		island.cells.append(cell)
	island.treasure_coord = island.cells[rng.randi_range(0, island.cells.size() - 1)].local_coord
	return island

func _find_start_island_anchor(
	rng: RandomNumberGenerator,
	island_index: int,
	relative_cells: Array[TerrainPieceCellData]
) -> Vector2i:
	for ring_expansion in range(4):
		var anchor: Vector2i = _find_anchor(
			rng,
			island_index,
			relative_cells,
			&"",
			true,
			ring_expansion
		)
		if anchor != EMPTY_COORD:
			return anchor
	return EMPTY_COORD

func _find_future_island_anchor(
	rng: RandomNumberGenerator,
	island_index: int,
	relative_cells: Array[TerrainPieceCellData]
) -> Vector2i:
	var board_coords: Array[Vector2i] = []
	board_coords.assign(_board_cells.keys())
	board_coords.sort_custom(Callable(self, "_sort_axial_coords"))
	for ring_expansion in range(8):
		var island_ring: Vector2i = _island_anchor_ring(island_index, ring_expansion)
		var candidate_set: Dictionary[Vector2i, bool] = {}
		for q_offset in range(-island_ring.y, island_ring.y + 1):
			for r_offset in range(-island_ring.y, island_ring.y + 1):
				var offset := Vector2i(q_offset, r_offset)
				var distance_from_base: int = _hex_distance(offset, Vector2i.ZERO)
				if distance_from_base < island_ring.x or distance_from_base > island_ring.y:
					continue
				var candidate: Vector2i = _base_coord + offset
				if not _candidate_is_safe(candidate, relative_cells, board_coords, &""):
					continue
				candidate_set[candidate] = true
		var candidates: Array[Vector2i] = []
		candidates.assign(candidate_set.keys())
		candidates.sort_custom(Callable(self, "_sort_axial_coords"))
		if not candidates.is_empty():
			return candidates[rng.randi_range(0, candidates.size() - 1)]
	return EMPTY_COORD

func _find_anchor(
	rng: RandomNumberGenerator,
	island_index: int,
	relative_cells: Array[TerrainPieceCellData],
	excluded_island_id: StringName,
	require_start_distance: bool,
	ring_expansion: int = 0
) -> Vector2i:
	var board_coords: Array[Vector2i] = []
	board_coords.assign(_board_cells.keys())
	board_coords.sort_custom(Callable(self, "_sort_axial_coords"))
	var candidate_set: Dictionary[Vector2i, bool] = {}
	for board_coord in board_coords:
		for q_offset in range(-MAX_ANCHOR_GAP, MAX_ANCHOR_GAP + 1):
			for r_offset in range(-MAX_ANCHOR_GAP, MAX_ANCHOR_GAP + 1):
				var offset := Vector2i(q_offset, r_offset)
				var offset_distance: int = _hex_distance(offset, Vector2i.ZERO)
				if offset_distance < MIN_ANCHOR_GAP or offset_distance > MAX_ANCHOR_GAP:
					continue
				var candidate: Vector2i = board_coord + offset
				if _board_cells.has(candidate) or candidate_set.has(candidate):
					continue
				if _minimum_board_distance(candidate, board_coords) < MIN_ANCHOR_GAP:
					continue
				var island_ring: Vector2i = _island_anchor_ring(island_index, ring_expansion)
				var distance_from_base: int = _hex_distance(candidate, _base_coord)
				if distance_from_base < island_ring.x or distance_from_base > island_ring.y:
					continue
				if require_start_distance and not _shape_is_within_start_distance(candidate, relative_cells):
					continue
				if not _candidate_is_safe(candidate, relative_cells, board_coords, excluded_island_id):
					continue
				candidate_set[candidate] = true
	var candidates: Array[Vector2i] = []
	candidates.assign(candidate_set.keys())
	candidates.sort_custom(Callable(self, "_sort_axial_coords"))
	if candidates.is_empty():
		return EMPTY_COORD
	return candidates[rng.randi_range(0, candidates.size() - 1)]

func _island_anchor_ring(island_index: int, ring_expansion: int) -> Vector2i:
	var minimum_distance: int = 3 if island_index == 0 else (
		ISLAND_RING_BASE_DISTANCE + (island_index - 1) * ISLAND_RING_STEP
	)
	var maximum_distance: int = START_ISLAND_MAX_DISTANCE if island_index == 0 else (
		minimum_distance + ISLAND_RING_WIDTH
	)
	var expansion: int = maxi(ring_expansion, 0) * ISLAND_RING_EXPANSION_STEP
	return Vector2i(minimum_distance + expansion, maximum_distance + expansion)

func _candidate_is_safe(
	anchor: Vector2i,
	relative_cells: Array[TerrainPieceCellData],
	board_coords: Array[Vector2i],
	excluded_island_id: StringName
) -> bool:
	for relative_cell in relative_cells:
		var coord: Vector2i = anchor + relative_cell.local_coord
		if _board_cells.has(coord):
			return false
		for board_coord in board_coords:
			if _hex_distance(coord, board_coord) <= 1:
				return false
		for island in _island_groups:
			if island.island_id == excluded_island_id:
				continue
			for existing_cell in island.cells:
				if _hex_distance(coord, existing_cell.local_coord) < MIN_ISLAND_SEPARATION:
					return false
	return true

func _shape_is_within_start_distance(
	anchor: Vector2i,
	relative_cells: Array[TerrainPieceCellData]
) -> bool:
	for cell in relative_cells:
		if _hex_distance(anchor + cell.local_coord, _base_coord) <= START_ISLAND_MAX_DISTANCE:
			return true
	return false

func _rebuild_reserved_island_coords() -> void:
	_reserved_island_coords.clear()
	for island in _island_groups:
		for cell in island.cells:
			_reserved_island_coords[cell.local_coord] = true

func _island_group_is_inside_reveal_radius(
	island: ExplorationIslandData,
	fog_center_world_position: Vector2,
	safe_reveal_radius: float
) -> bool:
	for cell in island.cells:
		for corner_index in range(6):
			var world_corner: Vector2 = to_global(
				_cell_corner(cell.local_coord, corner_index, cell.elevation)
			)
			if world_corner.distance_to(fog_center_world_position) > safe_reveal_radius:
				return false
	return true

func _sync_island_chest(island: ExplorationIslandData) -> void:
	var chest: IslandCardChest = _island_chests.get(island.island_id) as IslandCardChest
	if not island.discovered or island.treasure_claimed:
		if chest != null and is_instance_valid(chest):
			chest.set_available(false)
		return
	var treasure_cell: TerrainPieceCellData
	for cell in island.cells:
		if cell.local_coord == island.treasure_coord:
			treasure_cell = cell
			break
	if treasure_cell == null:
		return
	if chest == null or not is_instance_valid(chest):
		chest = IslandCardChest.new()
		add_child(chest)
		chest.activated.connect(_on_island_chest_activated)
		_island_chests[island.island_id] = chest
	chest.configure(
		island.island_id,
		_top_center(treasure_cell.local_coord, treasure_cell.elevation),
		true
	)

func _on_island_chest_activated(island_id: StringName, world_position: Vector2) -> void:
	treasure_open_requested.emit(island_id, world_position)

func _get_island(island_id: StringName) -> ExplorationIslandData:
	for island in _island_groups:
		if island.island_id == island_id:
			return island
	return null

func _connected_template_subset(
	template: TerrainPieceData,
	requested_count: int,
	rng: RandomNumberGenerator
) -> Array[TerrainPieceCellData]:
	var by_coord: Dictionary[Vector2i, TerrainPieceCellData] = {}
	for cell in template.cells:
		if cell != null:
			by_coord[cell.local_coord] = cell
	var result: Array[TerrainPieceCellData] = []
	if by_coord.is_empty():
		return result
	var ordered_coords: Array[Vector2i] = []
	ordered_coords.assign(by_coord.keys())
	ordered_coords.sort_custom(Callable(self, "_sort_axial_coords"))
	var selected: Dictionary[Vector2i, bool] = {}
	var pivot: Vector2i = Vector2i.ZERO if by_coord.has(Vector2i.ZERO) else ordered_coords[0]
	selected[pivot] = true
	var target_count: int = mini(requested_count, ordered_coords.size())
	while selected.size() < target_count:
		var frontier_set: Dictionary[Vector2i, bool] = {}
		for selected_coord in selected:
			for offset in HexCoord.DIRECTION_OFFSETS:
				var candidate: Vector2i = selected_coord + offset
				if by_coord.has(candidate) and not selected.has(candidate):
					frontier_set[candidate] = true
		var frontier: Array[Vector2i] = []
		frontier.assign(frontier_set.keys())
		frontier.sort_custom(Callable(self, "_sort_axial_coords"))
		if frontier.is_empty():
			break
		selected[frontier[rng.randi_range(0, frontier.size() - 1)]] = true
	var selected_coords: Array[Vector2i] = []
	selected_coords.assign(selected.keys())
	selected_coords.sort_custom(Callable(self, "_sort_axial_coords"))
	for coord in selected_coords:
		result.append(by_coord[coord])
	return result

func _template_pivot(template: TerrainPieceData) -> Vector2i:
	var ordered_coords: Array[Vector2i] = []
	for cell in template.cells:
		if cell != null:
			ordered_coords.append(cell.local_coord)
	if ordered_coords.has(Vector2i.ZERO):
		return Vector2i.ZERO
	if ordered_coords.is_empty():
		return Vector2i.ZERO
	ordered_coords.sort_custom(Callable(self, "_sort_axial_coords"))
	return ordered_coords[0]

func _draw() -> void:
	for island in _island_groups:
		if not island.discovered or not _island_group_is_clear(island):
			continue
		var cells: Array[TerrainPieceCellData] = island.cells.duplicate()
		cells.sort_custom(Callable(self, "_sort_cells_back_to_front"))
		var cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData] = {}
		var region_ids: Dictionary[Vector2i, Vector2i] = {}
		for cell in cells:
			cells_by_coord[cell.local_coord] = cell
			region_ids[cell.local_coord] = Vector2i(cell.terrain_type, cell.elevation)
		for cell in cells:
			_draw_front_cliffs(cell, cells_by_coord)
		for cell in cells:
			_draw_cell_top(cell)
		var exposed_edges: Dictionary[Vector2i, PackedInt32Array] = (
			TERRAIN_REGION_OUTLINE_SCRIPT.get_exposed_edges(region_ids)
		)
		for cell in cells:
			TERRAIN_REGION_OUTLINE_SCRIPT.draw_contour(
				self,
				_cell_corners(cell.local_coord, cell.elevation),
				exposed_edges.get(cell.local_coord, PackedInt32Array()),
				TERRAIN_VISUAL_CATALOG_SCRIPT.get_region_outline_color(cell.terrain_type),
				2.5
			)

func _draw_cell_top(cell: TerrainPieceCellData) -> void:
	var corners: PackedVector2Array = _cell_corners(cell.local_coord, cell.elevation)
	var color: Color = TERRAIN_COLORS.get(cell.terrain_type, Color.WHITE)
	draw_colored_polygon(corners, color)
	draw_colored_polygon(
		corners,
		TERRAIN_VISUAL_CATALOG_SCRIPT.get_elevation_tint(cell.elevation),
		PackedVector2Array([
			Vector2(0.5, 0.0), Vector2(1.0, 0.25), Vector2(1.0, 0.75),
			Vector2(0.5, 1.0), Vector2(0.0, 0.75), Vector2(0.0, 0.25),
		]),
		TERRAIN_VISUAL_CATALOG_SCRIPT.get_terrain_texture(
			cell.terrain_type,
			cell.visual_variant,
			cell.local_coord
		)
	)

func _draw_front_cliffs(
	cell: TerrainPieceCellData,
	cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData]
) -> void:
	for direction_index in [1, 2]:
		var neighbor_coord: Vector2i = cell.local_coord + HexCoord.DIRECTION_OFFSETS[direction_index]
		var neighbor: TerrainPieceCellData = cells_by_coord.get(neighbor_coord) as TerrainPieceCellData
		var neighbor_height: int = neighbor.elevation if neighbor != null else 0
		var exposed_levels: int = cell.elevation - neighbor_height
		if exposed_levels <= 0:
			continue
		var edge_start: int = posmod(direction_index + 1, 6)
		var edge_end: int = posmod(direction_index + 2, 6)
		var upper_start: Vector2 = _cell_corner(cell.local_coord, edge_start, cell.elevation)
		var upper_end: Vector2 = _cell_corner(cell.local_coord, edge_end, cell.elevation)
		var lower_offset := Vector2(0.0, float(exposed_levels) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET)
		var quad := PackedVector2Array([
			upper_start,
			upper_end,
			upper_end + lower_offset,
			upper_start + lower_offset,
		])
		var cliff_texture: Texture2D = TERRAIN_VISUAL_CATALOG_SCRIPT.get_cliff_texture(cell.terrain_type)
		var texture_size: Vector2 = cliff_texture.get_size()
		var edge_length: float = upper_start.distance_to(upper_end)
		var uv_span := Vector2(
			edge_length * 20.0 / maxf(texture_size.x, 1.0),
			lower_offset.length() * 20.0 / maxf(texture_size.y, 1.0)
		)
		var uv_left: float = fposmod(float(cell.local_coord.x * 31 + cell.local_coord.y * 17 + direction_index), maxf(1.0 - uv_span.x, 0.001))
		var uvs := PackedVector2Array([
			Vector2(uv_left, 0.0),
			Vector2(uv_left + uv_span.x, 0.0),
			Vector2(uv_left + uv_span.x, uv_span.y),
			Vector2(uv_left, uv_span.y),
		])
		draw_polygon(
			quad,
			TERRAIN_VISUAL_CATALOG_SCRIPT.get_cliff_face_colors(cell.terrain_type),
			uvs,
			cliff_texture
		)
		draw_polygon(quad, TERRAIN_VISUAL_CATALOG_SCRIPT.get_cliff_gradient_colors())

func _island_group_is_clear(island: ExplorationIslandData) -> bool:
	if _board_cells.is_empty():
		return true
	for island_cell in island.cells:
		if _board_cells.has(island_cell.local_coord):
			return false
	return true

func _minimum_board_distance(candidate: Vector2i, board_coords: Array[Vector2i]) -> int:
	var minimum_distance: int = 2147483647
	for coord in board_coords:
		minimum_distance = mini(minimum_distance, _hex_distance(candidate, coord))
	return minimum_distance

func _decorative_terrain_for_height(height: int, rng: RandomNumberGenerator) -> int:
	if height <= 0:
		return HexCell.TerrainType.GRASS
	if height >= 2 and rng.randf() < 0.55:
		return HexCell.TerrainType.MOUNTAIN
	return HexCell.TerrainType.GRASS

func _draw_axial_world_center(coord: Vector2i) -> Vector2:
	return HexMath.axial_to_world(HexCoord.new(coord.x, coord.y), HEX_RADIUS)

func _top_center(coord: Vector2i, elevation: int) -> Vector2:
	return _draw_axial_world_center(coord) - Vector2(
		0.0,
		float(elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
	)

func _cell_corner(coord: Vector2i, corner_index: int, elevation: int) -> Vector2:
	return HexMath.axial_hex_corner(HexCoord.new(coord.x, coord.y), corner_index, HEX_RADIUS) - Vector2(
		0.0,
		float(elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
	)

func _cell_corners(coord: Vector2i, elevation: int) -> PackedVector2Array:
	var corners := PackedVector2Array()
	for corner_index in range(6):
		corners.append(_cell_corner(coord, corner_index, elevation))
	return corners

func _sort_cells_back_to_front(a: TerrainPieceCellData, b: TerrainPieceCellData) -> bool:
	var a_center: Vector2 = _draw_axial_world_center(a.local_coord)
	var b_center: Vector2 = _draw_axial_world_center(b.local_coord)
	if not is_equal_approx(a_center.y, b_center.y):
		return a_center.y < b_center.y
	return a_center.x < b_center.x

func _sort_axial_coords(a: Vector2i, b: Vector2i) -> bool:
	if a.x != b.x:
		return a.x < b.x
	return a.y < b.y

func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	var delta: Vector2i = a - b
	return maxi(maxi(absi(delta.x), absi(delta.y)), absi(delta.x + delta.y))
