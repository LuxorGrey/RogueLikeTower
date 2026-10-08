extends Node2D

const HEX_RADIUS: float = 52.0
const ELEVATION_PIXEL_OFFSET: float = 18.0
const PROVISIONAL_BASE_COORD: Vector2i = Vector2i.ZERO
const STARTING_PIECE: TerrainPieceData = preload("res://data/terrain/starting_terrain_piece.tres")
const STRAIGHT_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/straight.tres")
const GENTLE_TURN_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/gentle_turn.tres")
const HARD_TURN_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/hard_turn.tres")
const FORK_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/fork.tres")
const CONVERGENCE_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/convergence.tres")
const FIRST_WAVE: WaveData = preload("res://data/waves/round_01.tres")
const BASIC_BOLT: TowerData = preload("res://data/towers/basic_bolt.tres")
const MIN_CAMERA_ZOOM: float = 0.45
const MAX_CAMERA_ZOOM: float = 2.5
const CAMERA_ZOOM_STEP: float = 1.12

var _board_grid := HexGrid.new()
var _pieces: Array[TerrainPieceData] = []
var _selected_piece: TerrainPieceData
var _rotation_steps: int = 0
var _anchor_coord: Vector2i = Vector2i.ZERO
var _next_piece_instance_id: int = 1
var _latest_placement: TerrainPlacementResult
var _is_panning: bool = false
var _path_graph := PathGraph.new()
var _path_debug_visible: bool = false
var _placement_enabled: bool = true
var _first_wave_completed: bool = false
var _hovered_coord: Vector2i = Vector2i.ZERO
var _has_hovered_cell: bool = false

@onready var _piece_preview: TerrainPiecePreview = %PiecePreview
@onready var _piece_status: Label = %PieceStatus
@onready var _rotation_status: Label = %RotationStatus
@onready var _hover_status: Label = %HoverStatus
@onready var _path_status: Label = %PathStatus
@onready var _placement_status: Label = %PlacementStatus
@onready var _piece_selector: OptionButton = %PieceSelector
@onready var _confirm_button: Button = %ConfirmPlacement
@onready var _cancel_button: Button = %CancelPlacement
@onready var _hud_panel: PanelContainer = %Panel
@onready var _hud: CanvasLayer = %HUD
@onready var _camera: Camera2D = %Camera2D
@onready var _rotate_left: Button = %RotateLeft
@onready var _rotate_right: Button = %RotateRight
@onready var _entities: Node2D = %Entities
@onready var _base: GameBase = %GameBase
@onready var _wave_director: WaveDirector = %WaveDirector
@onready var _base_status: Label = %BaseStatus
@onready var _wave_status: Label = %WaveStatus
@onready var _start_wave_button: Button = %StartWave
@onready var _build_controller: BuildController = %BuildController
@onready var _build_tower_button: Button = %BuildTower
@onready var _build_status: Label = %BuildStatus
@onready var _tower_status: Label = %TowerStatus
@onready var _tower_targeting_mode: OptionButton = %TowerTargetingMode
@onready var _upgrade_tower_button: Button = %UpgradeTower

func _ready() -> void:
	_camera.position = get_viewport_rect().size * 0.5
	_camera.make_current()
	_pieces = [STRAIGHT_PIECE, GENTLE_TURN_PIECE, HARD_TURN_PIECE, FORK_PIECE, CONVERGENCE_PIECE]
	_rotate_left.pressed.connect(_rotate_by.bind(-1))
	_rotate_right.pressed.connect(_rotate_by.bind(1))
	_start_wave_button.pressed.connect(_start_first_wave)
	_confirm_button.pressed.connect(_confirm_placement)
	_cancel_button.pressed.connect(_cancel_placement)
	_piece_selector.item_selected.connect(_on_piece_selected)
	_piece_preview.hover_changed.connect(_on_preview_hover_changed)
	_piece_preview.hover_cleared.connect(_on_preview_hover_cleared)
	_base.health_changed.connect(_on_base_health_changed)
	_wave_director.wave_started.connect(_on_wave_started)
	_wave_director.wave_completed.connect(_on_wave_completed)
	_wave_director.wave_failed.connect(_on_wave_failed)
	_wave_director.enemy_count_changed.connect(_on_enemy_count_changed)
	_wave_director.base_damaged.connect(_on_base_damaged)
	_build_controller.tower_selected.connect(_on_tower_selected)
	_build_controller.tower_upgraded.connect(_on_tower_upgraded)
	_build_controller.build_mode_changed.connect(_on_build_mode_changed)
	_build_tower_button.pressed.connect(_on_build_tower_pressed)
	_tower_targeting_mode.item_selected.connect(_on_targeting_mode_selected)
	_upgrade_tower_button.pressed.connect(_on_upgrade_tower_pressed)
	_build_controller.configure(_board_grid, _entities, _piece_preview.global_position, HEX_RADIUS)
	_populate_targeting_modes()

	var starting_errors := STARTING_PIECE.validate()
	if not starting_errors.is_empty():
		_placement_status.text = "Tablero inicial inválido: %s" % "; ".join(starting_errors)
		push_error(_placement_status.text)
		return
	var starting_cells := TerrainPlacementValidator.instantiate_cells(STARTING_PIECE, Vector2i.ZERO, 0, 0)
	if not _board_grid.add_cells(starting_cells):
		_placement_status.text = "No se pudo crear el tablero inicial."
		push_error(_placement_status.text)
		return
	_path_graph.rebuild(_board_grid.cells, PROVISIONAL_BASE_COORD)
	if not _path_graph.is_valid:
		push_error("Grafo PATH inicial inválido: %s" % "; ".join(_path_graph.errors))

	_piece_preview.set_board_cells(_board_grid.cells)
	_piece_preview.set_path_graph(_path_graph)
	_base.global_position = _piece_preview.global_position + HexMath.axial_to_world(
		HexCoord.new(PROVISIONAL_BASE_COORD.x, PROVISIONAL_BASE_COORD.y),
		HEX_RADIUS
	)
	_on_base_health_changed(_base.get_current_health(), _base.get_maximum_health())
	_refresh_tower_controls()
	_start_wave_button.disabled = not _path_graph.is_valid
	_wave_status.text = "Oleada 1 lista · 3 enemigos de prueba"
	RunManager.transition_to(RunManager.Phase.ROUND_PREP)
	_refresh_tower_controls()
	_refresh_path_status()
	_piece_selector.add_item("— sin pieza —", 0)
	for piece in _pieces:
		_piece_selector.add_item(piece.display_name)
	_piece_selector.select(1)
	_on_piece_selected(1)

func _process(_delta: float) -> void:
	if _is_panning or not _placement_enabled or _build_controller.is_build_mode():
		return
	_update_anchor_from_mouse()

func _input(event: InputEvent) -> void:
	# H y el arrastre activo deben seguir respondiendo aunque el puntero cruce el HUD.
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_H:
			_toggle_hud()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_MIDDLE:
			return
		if mouse_event.pressed and _hud.visible and _hud_panel.get_global_rect().has_point(mouse_event.position):
			return
		_is_panning = mouse_event.pressed
		if not _is_panning:
			_update_anchor_from_mouse()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _is_panning:
		var motion_event := event as InputEventMouseMotion
		_camera.position -= motion_event.relative / _camera.zoom.x
		get_viewport().set_input_as_handled()

func _update_anchor_from_mouse() -> void:
	if _hud.visible and _hud_panel.get_global_rect().has_point(get_viewport().get_mouse_position()):
		return
	var mouse_position: Vector2 = _piece_preview.get_local_mouse_position()
	var next_anchor: Vector2i = HexMath.world_to_axial(mouse_position, HEX_RADIUS).to_key()
	if next_anchor == _anchor_coord:
		return
	_anchor_coord = next_anchor
	_refresh_placement()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_cancel_active_tool()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event == null or not key_event.pressed or key_event.echo:
			return
		match key_event.keycode:
			KEY_Q:
				_rotate_by(-1)
				get_viewport().set_input_as_handled()
			KEY_E:
				_rotate_by(1)
				get_viewport().set_input_as_handled()
			KEY_R:
				_reset_camera()
				get_viewport().set_input_as_handled()
			KEY_D:
				_toggle_path_debug()
				get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event == null:
			return
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at_cursor(CAMERA_ZOOM_STEP)
			get_viewport().set_input_as_handled()
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at_cursor(1.0 / CAMERA_ZOOM_STEP)
			get_viewport().set_input_as_handled()
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_handle_board_click()
			get_viewport().set_input_as_handled()
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_active_tool()
			get_viewport().set_input_as_handled()

func _toggle_hud() -> void:
	_hud.visible = not _hud.visible

func _zoom_at_cursor(factor: float) -> void:
	var old_zoom: float = _camera.zoom.x
	var new_zoom: float = clampf(old_zoom * factor, MIN_CAMERA_ZOOM, MAX_CAMERA_ZOOM)
	if is_equal_approx(old_zoom, new_zoom):
		return
	var viewport_center: Vector2 = get_viewport_rect().size * 0.5
	var cursor_offset: Vector2 = get_viewport().get_mouse_position() - viewport_center
	_camera.position += cursor_offset * (1.0 / old_zoom - 1.0 / new_zoom)
	_camera.zoom = Vector2.ONE * new_zoom
	_update_anchor_from_mouse()

func _reset_camera() -> void:
	_camera.position = _board_center_world()
	_camera.zoom = Vector2.ONE
	_update_anchor_from_mouse()

func _board_center_world() -> Vector2:
	if _board_grid.cells.is_empty():
		return get_viewport_rect().size * 0.5
	var minimum := Vector2(1e20, 1e20)
	var maximum := Vector2(-1e20, -1e20)
	for coord in _board_grid.cells:
		var cell: HexCell = _board_grid.cells[coord]
		var center := _piece_preview.to_global(
			HexMath.axial_to_world(HexCoord.new(coord.x, coord.y), HEX_RADIUS)
		)
		center.y -= float(cell.elevation) * ELEVATION_PIXEL_OFFSET
		minimum.x = minf(minimum.x, center.x - HEX_RADIUS)
		minimum.y = minf(minimum.y, center.y - HEX_RADIUS)
		maximum.x = maxf(maximum.x, center.x + HEX_RADIUS)
		maximum.y = maxf(maximum.y, center.y + HEX_RADIUS)
	return (minimum + maximum) * 0.5

func _rotate_by(step_delta: int) -> void:
	if not _placement_enabled or _build_controller.is_build_mode() or _selected_piece == null:
		return
	_rotation_steps = posmod(_rotation_steps + step_delta, 6)
	_refresh_placement()

func _on_piece_selected(index: int) -> void:
	if not _placement_enabled:
		return
	if index <= 0 or index > _pieces.size():
		_cancel_placement()
		return
	_selected_piece = _pieces[index - 1]
	_rotation_steps = 0
	_piece_status.text = _piece_summary(_selected_piece)
	_refresh_placement()

func _refresh_placement() -> void:
	var can_edit_terrain: bool = _placement_enabled and not _build_controller.is_build_mode()
	_piece_selector.disabled = not can_edit_terrain
	_rotate_left.disabled = not can_edit_terrain or _selected_piece == null
	_rotate_right.disabled = not can_edit_terrain or _selected_piece == null
	_cancel_button.disabled = not can_edit_terrain or _selected_piece == null
	if _selected_piece == null:
		_latest_placement = null
		_piece_preview.set_placement_preview(null, _anchor_coord, _rotation_steps, false, false)
		_confirm_button.disabled = true
		_piece_status.text = "Tablero confirmado · %d casillas" % _board_grid.cells.size()
		_rotation_status.text = "Orientación: —"
		_placement_status.text = "Elige una pieza para iniciar la colocación."
		return

	_latest_placement = TerrainPlacementValidator.evaluate(
		_selected_piece,
		_anchor_coord,
		_rotation_steps,
		_board_grid.cells
	)
	_piece_preview.set_placement_preview(
		_selected_piece,
		_anchor_coord,
		_rotation_steps,
		_latest_placement.is_valid
	)
	_confirm_button.disabled = not can_edit_terrain or not _latest_placement.is_valid
	_rotation_status.text = "Orientación: %d° · posición %d/6" % [
		_rotation_steps * 60,
		_rotation_steps + 1,
	]
	_placement_status.text = "%s · conexiones: %d" % [
		_latest_placement.message(),
		_latest_placement.path_connection_count,
	]

func _confirm_placement() -> void:
	if not _placement_enabled or _selected_piece == null or _latest_placement == null or not _latest_placement.is_valid:
		return
	var cells := TerrainPlacementValidator.instantiate_cells(
		_selected_piece,
		_anchor_coord,
		_rotation_steps,
		_next_piece_instance_id
	)
	var candidate_board: Dictionary[Vector2i, HexCell] = {}
	for coord in _board_grid.cells:
		candidate_board[coord] = _board_grid.cells[coord]
	for coord in cells:
		candidate_board[coord] = cells[coord]
	var candidate_graph := PathGraph.new()
	candidate_graph.rebuild(candidate_board, PROVISIONAL_BASE_COORD)
	if not candidate_graph.is_valid:
		_placement_status.text = "No se confirma: red PATH inválida · %s" % "; ".join(candidate_graph.errors)
		return
	if not _board_grid.add_cells(cells):
		_placement_status.text = "La pieza dejó de encajar antes de confirmar."
		return
	_path_graph = candidate_graph
	_next_piece_instance_id += 1
	_piece_preview.set_board_cells(_board_grid.cells)
	_piece_preview.set_path_graph(_path_graph)
	_refresh_path_status()
	_cancel_placement()

func _cancel_placement() -> void:
	_selected_piece = null
	_latest_placement = null
	_piece_selector.select(0)
	_refresh_placement()

func _cancel_active_tool() -> void:
	if _build_controller.is_build_mode():
		_build_controller.cancel_build_mode()
		_refresh_build_preview()
		_refresh_placement()
		_refresh_tower_controls()
		return
	_cancel_placement()

func _handle_board_click() -> void:
	if _build_controller.is_build_mode():
		if not _has_hovered_cell:
			_build_status.text = "Coloca el cursor sobre una casilla existente."
			return
		if _build_controller.place_tower(_hovered_coord):
			_build_status.text = "Basic Bolt construida en (%d, %d)." % [_hovered_coord.x, _hovered_coord.y]
			_build_controller.cancel_build_mode()
			_refresh_build_preview()
			_refresh_placement()
			_refresh_tower_controls()
		else:
			_build_status.text = _build_controller.last_error
			_refresh_build_preview()
		return
	if _has_hovered_cell:
		var tower: Tower = _build_controller.get_tower_at(_hovered_coord)
		if tower != null:
			_cancel_placement()
			_build_controller.select_tower_at(_hovered_coord)
			_refresh_tower_controls()
			return
	if _placement_enabled:
		_confirm_placement()

func _on_build_tower_pressed() -> void:
	if _build_controller.is_build_mode():
		_build_controller.cancel_build_mode()
		_build_status.text = "Construcción cancelada."
	else:
		_cancel_placement()
		if _build_controller.begin_build(BASIC_BOLT):
			_build_status.text = "Basic Bolt · elige una casilla libre de Grass o Montaña."
		else:
			_build_status.text = _build_controller.last_error
	_refresh_build_preview()
	_refresh_placement()
	_refresh_tower_controls()

func _on_build_mode_changed(is_active: bool) -> void:
	if not is_active:
		_piece_preview.set_tower_build_preview(false)
	_refresh_build_preview()
	_refresh_placement()
	_refresh_tower_controls()

func _refresh_build_preview() -> void:
	if not _build_controller.is_build_mode() or not _has_hovered_cell:
		_piece_preview.set_tower_build_preview(false)
		return
	var error: String = _build_controller.get_placement_error(_hovered_coord)
	_piece_preview.set_tower_build_preview(
		true,
		_hovered_coord,
		error.is_empty(),
		_build_controller.get_preview_range_pixels(_hovered_coord)
	)

func _populate_targeting_modes() -> void:
	_tower_targeting_mode.clear()
	_tower_targeting_mode.add_item("Más avanzado", TowerData.TargetingMode.FIRST_PROGRESS)
	_tower_targeting_mode.add_item("Menos avanzado", TowerData.TargetingMode.LAST_PROGRESS)
	_tower_targeting_mode.add_item("Más vida", TowerData.TargetingMode.HIGHEST_HEALTH)
	_tower_targeting_mode.add_item("Más armadura", TowerData.TargetingMode.HIGHEST_ARMOR)
	_tower_targeting_mode.select(TowerData.TargetingMode.FIRST_PROGRESS)

func _on_targeting_mode_selected(index: int) -> void:
	if index < 0 or index >= _tower_targeting_mode.item_count:
		return
	var mode: int = _tower_targeting_mode.get_item_id(index)
	if _build_controller.set_selected_targeting_mode(mode):
		_refresh_tower_controls()

func _on_upgrade_tower_pressed() -> void:
	if _build_controller.upgrade_selected_tower():
		_build_status.text = "Torre mejorada sin coste en este prototipo (la economía llega en M9)."
	else:
		_build_status.text = _build_controller.last_error
	_refresh_tower_controls()

func _on_tower_selected(tower: Tower, _coord: Vector2i) -> void:
	if tower == null or not is_instance_valid(tower):
		return
	_tower_status.text = tower.get_summary()
	var mode_index: int = _tower_targeting_mode.get_item_index(tower.get_targeting_mode())
	if mode_index >= 0:
		_tower_targeting_mode.select(mode_index)
	_refresh_tower_controls()

func _on_tower_upgraded(tower: Tower, _new_level: int) -> void:
	_on_tower_selected(tower, tower.cell_coord)

func _refresh_tower_controls() -> void:
	var build_mode: bool = _build_controller.is_build_mode()
	var selected: Tower = _build_controller.selected_tower
	_build_tower_button.disabled = not _build_controller.can_build_in_current_phase()
	_build_tower_button.text = "Cancelar construcción" if build_mode else "Construir Basic Bolt"
	_tower_targeting_mode.disabled = build_mode or selected == null or not _build_controller.can_build_in_current_phase()
	_upgrade_tower_button.disabled = (
		build_mode
		or selected == null
		or selected.level >= selected.get_tower_data().max_level
		or not _build_controller.can_build_in_current_phase()
	)
	if build_mode:
		_tower_status.text = "Basic Bolt · preview de alcance y terreno válido"
	elif selected == null:
		_tower_status.text = "Ninguna torre seleccionada."
		_build_status.text = "Construye una torre o selecciona una ya colocada."
	else:
		_tower_status.text = selected.get_summary()

func _start_first_wave() -> void:
	if _first_wave_completed or not _path_graph.is_valid:
		return
	_cancel_placement()
	_placement_enabled = false
	_refresh_placement()
	_start_wave_button.disabled = true
	if not _wave_director.start_wave(
		FIRST_WAVE,
		_path_graph,
		_base,
		_entities,
		_piece_preview.global_position,
		HEX_RADIUS
	):
		_placement_enabled = true
		_start_wave_button.disabled = false
		_refresh_placement()
		_wave_status.text = "No se pudo iniciar la oleada: %s" % _wave_director.last_error

func _on_wave_started(round_number: int) -> void:
	RunManager.transition_to(RunManager.Phase.COMBAT)
	_wave_status.text = "Oleada %d · enemigos activos: 0" % round_number
	_refresh_tower_controls()

func _on_wave_completed(round_number: int) -> void:
	_first_wave_completed = true
	_placement_enabled = true
	_start_wave_button.disabled = true
	_start_wave_button.text = "Oleada de prueba completada"
	_wave_status.text = "Oleada %d completada · puedes expandir el terreno o preparar la siguiente prueba" % round_number
	RunManager.transition_to(RunManager.Phase.TERRAIN_EXPANSION)
	_refresh_placement()
	_refresh_tower_controls()

func _on_wave_failed(reason: String) -> void:
	_build_controller.cancel_build_mode()
	_placement_enabled = false
	_start_wave_button.disabled = true
	_wave_status.text = "DERROTA · %s" % reason
	RunManager.transition_to(RunManager.Phase.RUN_DEFEAT)
	_refresh_placement()
	_refresh_tower_controls()

func _on_enemy_count_changed(alive_count: int) -> void:
	if RunManager.phase == RunManager.Phase.COMBAT:
		_wave_status.text = "Oleada 1 · enemigos en ruta: %d" % alive_count

func _on_base_health_changed(current_health: int, maximum_health: int) -> void:
	_base_status.text = "Base · vida %d / %d" % [current_health, maximum_health]
	if current_health <= 0:
		_base_status.text += " · DESTRUIDA"

func _on_base_damaged(amount: int, current_health: int, maximum_health: int) -> void:
	_on_base_health_changed(current_health, maximum_health)
	if amount > 0:
		_wave_status.text = "La base recibió %d de daño · enemigos en ruta: %d" % [
			amount,
			_wave_director.get_alive_enemy_count(),
		]

func _piece_summary(piece: TerrainPieceData) -> String:
	var path_count: int = 0
	var grass_count: int = 0
	var mountain_count: int = 0
	for cell in piece.cells:
		match cell.terrain_type:
			HexCell.TerrainType.PATH:
				path_count += 1
			HexCell.TerrainType.GRASS:
				grass_count += 1
			HexCell.TerrainType.MOUNTAIN:
				mountain_count += 1
	return "%s · %d hexágonos\nCamino %d · Grass %d · Montaña %d" % [
		piece.display_name,
		piece.cells.size(),
		path_count,
		grass_count,
		mountain_count,
	]

func _on_preview_hover_changed(local_coord: Vector2i, terrain_type: int, elevation: int) -> void:
	_hovered_coord = local_coord
	_has_hovered_cell = true
	_hover_status.text = "Casilla del tablero (q,r): (%d, %d) · %s · h%d" % [
		local_coord.x,
		local_coord.y,
		_terrain_display_name(terrain_type),
		elevation,
	]
	_refresh_build_preview()

func _on_preview_hover_cleared() -> void:
	_has_hovered_cell = false
	_hover_status.text = "Casilla del tablero (q,r): — · hover sobre cara superior"
	_piece_preview.set_tower_build_preview(false)

func _toggle_path_debug() -> void:
	_path_debug_visible = not _path_debug_visible
	_piece_preview.set_path_debug_visible(_path_debug_visible)
	_refresh_path_status()

func _refresh_path_status() -> void:
	if _path_graph == null:
		_path_status.text = "Grafo PATH: pendiente"
		return
	var graph_state: String = "válido" if _path_graph.is_valid else "inválido"
	var base_text: String = "—"
	if _path_graph.base_endpoint != null:
		base_text = "(%d,%d)" % [
			_path_graph.base_endpoint.cell_coord.x,
			_path_graph.base_endpoint.cell_coord.y,
		]
	var debug_state: String = "ON" if _path_debug_visible else "OFF"
	_path_status.text = "M4 PATH: %d · spawns %d · ramas %d · base* %s · %s · D:%s" % [
		_path_graph.nodes.size(),
		_path_graph.spawn_endpoints.size(),
		_path_graph.get_branch_count(),
		base_text,
		graph_state,
		debug_state,
	]

func _terrain_display_name(terrain_type: int) -> String:
	match terrain_type:
		HexCell.TerrainType.PATH:
			return "CAMINO"
		HexCell.TerrainType.GRASS:
			return "GRASS"
		HexCell.TerrainType.MOUNTAIN:
			return "MONTAÑA"
		_:
			return "DESCONOCIDO"
