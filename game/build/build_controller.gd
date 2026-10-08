class_name BuildController
extends Node

signal build_mode_changed(is_active: bool)
signal tower_built(tower: Tower, coord: Vector2i)
signal tower_selected(tower: Tower, coord: Vector2i)
signal tower_upgraded(tower: Tower, new_level: int)

var last_error: String = ""
var selected_tower: Tower
var _board_grid: HexGrid
var _entities: Node2D
var _map_origin: Vector2 = Vector2.ZERO
var _hex_radius: float = 52.0
var _tower_data: TowerData
var _damage_service: Node
var _is_build_mode: bool = false
var _towers_by_coord: Dictionary[Vector2i, Tower] = {}

func configure(
	board_grid: HexGrid,
	entities: Node2D,
	map_origin: Vector2,
	hex_radius: float,
	damage_service: Node
) -> bool:
	if board_grid == null or entities == null or damage_service == null or hex_radius <= 0.0:
		last_error = "BuildController requiere grid, entidades, DamageService y radio positivos."
		return false
	_board_grid = board_grid
	_entities = entities
	_map_origin = map_origin
	_hex_radius = hex_radius
	_damage_service = damage_service
	return true

func can_build_in_current_phase() -> bool:
	return (
		RunManager.phase == RunManager.Phase.ROUND_PREP
		or RunManager.phase == RunManager.Phase.COMBAT
		or RunManager.phase == RunManager.Phase.TERRAIN_EXPANSION
	)

func begin_build(tower_data: TowerData) -> bool:
	last_error = ""
	if not can_build_in_current_phase():
		last_error = "No se pueden construir torres en esta fase de la run."
		return false
	if tower_data == null:
		last_error = "Selecciona datos de torre antes de construir."
		return false
	var errors := tower_data.validate()
	if not errors.is_empty():
		last_error = "; ".join(errors)
		return false
	_deselect_tower()
	_tower_data = tower_data
	_is_build_mode = true
	build_mode_changed.emit(true)
	return true

func cancel_build_mode() -> void:
	if not _is_build_mode:
		return
	_is_build_mode = false
	_tower_data = null
	build_mode_changed.emit(false)

func is_build_mode() -> bool:
	return _is_build_mode

func get_active_tower_data() -> TowerData:
	return _tower_data

func get_tower_at(coord: Vector2i) -> Tower:
	return _towers_by_coord.get(coord) as Tower

func get_placement_error(coord: Vector2i) -> String:
	if not _is_build_mode or _tower_data == null:
		return "Activa el modo de construcción."
	if not can_build_in_current_phase():
		return "La fase actual no permite construir torres."
	if _board_grid == null or not _board_grid.cells.has(coord):
		return "No hay una casilla de terreno bajo el cursor."
	var cell: HexCell = _board_grid.cells[coord]
	if cell == null or not cell.buildable or cell.terrain_type == HexCell.TerrainType.PATH:
		return "Solo se puede construir en Grass o Montaña."
	if cell.occupied or _towers_by_coord.has(coord):
		return "Esa casilla ya está ocupada."
	if not _tower_data.allows_terrain(cell.terrain_type):
		return "%s no permite construir en %s." % [
			_tower_data.display_name,
			_terrain_name(cell.terrain_type),
		]
	return ""

func get_preview_range_pixels(coord: Vector2i) -> float:
	if _tower_data == null or _board_grid == null or not _board_grid.cells.has(coord):
		return 0.0
	var cell: HexCell = _board_grid.cells[coord]
	var range_hexes: float = (
		_tower_data.range_hexes
		+ cell.elevation * _tower_data.height_range_bonus_per_level
	)
	var neighbor_distance: float = HexMath.axial_to_world(HexCoord.new(1, 0), _hex_radius).length()
	return range_hexes * neighbor_distance

func place_tower(coord: Vector2i) -> bool:
	last_error = get_placement_error(coord)
	if not last_error.is_empty():
		return false
	var cell: HexCell = _board_grid.cells[coord]
	var tower := _tower_data.scene.instantiate() as Tower
	if tower == null:
		last_error = "La escena de TowerData no crea un nodo Tower."
		return false
	_entities.add_child(tower)
	if not tower.configure(_tower_data, coord, cell.elevation, _map_origin, _hex_radius, _damage_service):
		last_error = tower.last_error
		tower.queue_free()
		return false
	cell.occupied = true
	cell.tower_id = _tower_data.id
	_towers_by_coord[coord] = tower
	tower_built.emit(tower, coord)
	select_tower_at(coord)
	return true

func select_tower_at(coord: Vector2i) -> bool:
	var tower: Tower = get_tower_at(coord)
	if tower == null or not is_instance_valid(tower):
		return false
	_deselect_tower()
	selected_tower = tower
	selected_tower.set_selected(true)
	tower_selected.emit(selected_tower, coord)
	return true

func clear_selection() -> void:
	_deselect_tower()

func upgrade_selected_tower() -> bool:
	last_error = ""
	if not can_build_in_current_phase():
		last_error = "La fase actual no permite mejorar torres."
		return false
	if selected_tower == null or not is_instance_valid(selected_tower):
		last_error = "Selecciona una torre antes de mejorarla."
		return false
	if not selected_tower.upgrade():
		last_error = "La torre ya está en su nivel máximo."
		return false
	tower_upgraded.emit(selected_tower, selected_tower.level)
	return true

func set_selected_targeting_mode(mode: int) -> bool:
	if not can_build_in_current_phase() or selected_tower == null or not is_instance_valid(selected_tower):
		return false
	if not selected_tower.set_targeting_mode(mode):
		return false
	tower_selected.emit(selected_tower, selected_tower.cell_coord)
	return true

func _deselect_tower() -> void:
	if selected_tower != null and is_instance_valid(selected_tower):
		selected_tower.set_selected(false)
	selected_tower = null

func _terrain_name(terrain_type: int) -> String:
	match terrain_type:
		HexCell.TerrainType.GRASS:
			return "Grass"
		HexCell.TerrainType.MOUNTAIN:
			return "Montaña"
		_:
			return "Camino"
