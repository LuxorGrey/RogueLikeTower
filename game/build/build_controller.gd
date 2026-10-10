class_name BuildController
extends Node

signal build_mode_changed(is_active: bool)
signal tower_built(tower: Tower, coord: Vector2i)
signal tower_selected(tower: Tower, coord: Vector2i)
signal tower_upgraded(tower: Tower, new_level: int)
signal tower_demolished(tower_data: TowerData, next_build_cost: int)

var last_error: String = ""
var selected_tower: Tower
var _board_grid: HexGrid
var _entities: Node2D
var _map_origin: Vector2 = Vector2.ZERO
var _hex_radius: float = 52.0
var _tower_data: TowerData
var _damage_service: Node
var _run_economy: Node
var _run_card_service: Node
var _meta_progression: Node
var _is_build_mode: bool = false
var _towers_by_coord: Dictionary[Vector2i, Tower] = {}

func configure(
	board_grid: HexGrid,
	entities: Node2D,
	map_origin: Vector2,
	hex_radius: float,
	damage_service: Node,
	run_economy: Node = null,
	run_card_service: Node = null,
	meta_progression: Node = null
) -> bool:
	if board_grid == null or entities == null or damage_service == null or hex_radius <= 0.0:
		last_error = "BuildController requiere grid, entidades, DamageService y radio positivos."
		return false
	_board_grid = board_grid
	_entities = entities
	_map_origin = map_origin
	_hex_radius = hex_radius
	_damage_service = damage_service
	_run_economy = run_economy
	_run_card_service = run_card_service
	_meta_progression = meta_progression
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
	if _meta_progression != null and not bool(_meta_progression.call("is_tower_unlocked", tower_data)):
		last_error = "La torre está bloqueada. Desbloquéala en la tienda entre runs."
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

func get_tower_count(tower_data: TowerData) -> int:
	if tower_data == null:
		return 0
	var count: int = 0
	for tower_variant in _towers_by_coord.values():
		var tower := tower_variant as Tower
		if tower != null and is_instance_valid(tower) and tower.get_tower_data() != null:
			if tower.get_tower_data().id == tower_data.id:
				count += 1
	return count

func get_current_build_cost(tower_data: TowerData) -> int:
	if tower_data == null:
		return -1
	return tower_data.build_cost + get_tower_count(tower_data) * tower_data.build_cost_increment

func get_placement_error(coord: Vector2i) -> String:
	if not _is_build_mode or _tower_data == null:
		return "Activa el modo de construcción."
	if not can_build_in_current_phase():
		return "La fase actual no permite construir torres."
	if _meta_progression != null and not bool(_meta_progression.call("is_tower_unlocked", _tower_data)):
		return "La torre está bloqueada. Desbloquéala en la tienda entre runs."
	if _board_grid == null or not _board_grid.cells.has(coord):
		return "No hay una casilla de terreno bajo el cursor."
	var cell: HexCell = _board_grid.cells[coord]
	if cell == null or not cell.buildable or cell.terrain_type == HexCell.TerrainType.PATH:
		return "Solo se puede construir en Grass o Mountain."
	if cell.obstacle_type != HexCell.ObstacleType.NONE:
		return "Un obstáculo bloquea esta casilla."
	if cell.chest_available:
		return "Abre el cofre antes de construir en esta casilla."
	if cell.occupied or _towers_by_coord.has(coord):
		return "Esa casilla ya está ocupada."
	if not _tower_data.allows_terrain(cell.terrain_type):
		return "%s no permite construir en %s." % [
			_tower_data.display_name,
			_terrain_name(cell.terrain_type),
		]
	var build_cost: int = get_current_build_cost(_tower_data)
	if _run_economy != null and not bool(_run_economy.call("can_afford_gold", build_cost)):
		return "Gold insuficiente: %d disponibles · %d necesarios." % [
			int(_run_economy.call("get_gold")),
			build_cost,
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
	if _run_card_service != null and is_instance_valid(_run_card_service):
		range_hexes += float(_run_card_service.call("get_tower_range_add", _tower_data.id))
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
	if not tower.configure(_tower_data, coord, cell.elevation, _map_origin, _hex_radius, _damage_service, _run_economy, _run_card_service, _meta_progression, _board_grid):
		last_error = tower.last_error
		tower.free()
		return false
	var build_cost: int = get_current_build_cost(_tower_data)
	if _run_economy != null and not bool(_run_economy.call("try_spend_gold", build_cost, &"tower_build")):
		last_error = "No se pudo completar la compra: Gold insuficiente."
		tower.free()
		return false
	_entities.add_child(tower)
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

func upgrade_selected_tower(hit_point_layer: int = Enemy.HitPointLayer.HEALTH) -> bool:
	last_error = ""
	if not can_build_in_current_phase():
		last_error = "La fase actual no permite mejorar torres."
		return false
	if selected_tower == null or not is_instance_valid(selected_tower):
		last_error = "Selecciona una torre antes de mejorarla."
		return false
	var upgrade_cost: int = selected_tower.get_next_upgrade_cost(hit_point_layer)
	if upgrade_cost < 0:
		last_error = "La torre ya está en su nivel máximo."
		return false
	if _run_economy != null and not bool(_run_economy.call("can_afford_gold", upgrade_cost)):
		last_error = "Gold insuficiente: %d disponibles · %d necesarios." % [
			int(_run_economy.call("get_gold")),
			upgrade_cost,
		]
		return false
	if _run_economy != null and not bool(_run_economy.call("try_spend_gold", upgrade_cost, &"tower_upgrade")):
		last_error = "No se pudo completar la mejora: Gold insuficiente."
		return false
	if not selected_tower.upgrade(hit_point_layer):
		if _run_economy != null:
			_run_economy.call("add_gold", upgrade_cost, &"upgrade_refund")
		last_error = "La torre ya está en su nivel máximo."
		return false
	tower_upgraded.emit(selected_tower, selected_tower.level)
	return true

func demolish_selected_tower() -> bool:
	last_error = ""
	if not can_build_in_current_phase():
		last_error = "No se pueden demoler torres en esta fase."
		return false
	if selected_tower == null or not is_instance_valid(selected_tower):
		last_error = "Selecciona una torre antes de demolerla."
		return false
	var tower: Tower = selected_tower
	var coord: Vector2i = tower.cell_coord
	var tower_data: TowerData = tower.get_tower_data()
	if _board_grid != null and _board_grid.cells.has(coord):
		var cell: HexCell = _board_grid.cells[coord]
		if cell != null:
			cell.occupied = false
			cell.tower_id = &""
	_towers_by_coord.erase(coord)
	tower.set_selected(false)
	selected_tower = null
	tower.queue_free()
	tower_demolished.emit(tower_data, get_current_build_cost(tower_data))
	return true

func set_selected_targeting_mode(mode: int) -> bool:
	if not can_build_in_current_phase() or selected_tower == null or not is_instance_valid(selected_tower):
		return false
	if not selected_tower.set_targeting_priority(0, mode):
		return false
	tower_selected.emit(selected_tower, selected_tower.cell_coord)
	return true

func set_selected_targeting_priority(slot: int, mode: int) -> bool:
	if not can_build_in_current_phase() or selected_tower == null or not is_instance_valid(selected_tower):
		return false
	if not selected_tower.set_targeting_priority(slot, mode):
		return false
	tower_selected.emit(selected_tower, selected_tower.cell_coord)
	return true

func set_selected_targeting_priorities(priorities: Array[int]) -> bool:
	if not can_build_in_current_phase() or selected_tower == null or not is_instance_valid(selected_tower):
		return false
	if not selected_tower.set_targeting_priorities(priorities):
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
			return "Mountain"
		_:
			return "Path"
