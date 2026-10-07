extends Node2D

const HEX_RADIUS: float = 52.0
const ELEVATION_PIXEL_OFFSET: float = 18.0
const STARTING_PIECE: TerrainPieceData = preload("res://data/terrain/starting_terrain_piece.tres")
const STRAIGHT_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/straight.tres")
const GENTLE_TURN_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/gentle_turn.tres")
const HARD_TURN_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/hard_turn.tres")
const FORK_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/fork.tres")
const CONVERGENCE_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/convergence.tres")
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

@onready var _piece_preview: TerrainPiecePreview = %PiecePreview
@onready var _piece_status: Label = %PieceStatus
@onready var _rotation_status: Label = %RotationStatus
@onready var _hover_status: Label = %HoverStatus
@onready var _placement_status: Label = %PlacementStatus
@onready var _piece_selector: OptionButton = %PieceSelector
@onready var _confirm_button: Button = %ConfirmPlacement
@onready var _cancel_button: Button = %CancelPlacement
@onready var _hud_panel: PanelContainer = %Panel
@onready var _hud: CanvasLayer = %HUD
@onready var _camera: Camera2D = %Camera2D
@onready var _rotate_left: Button = %RotateLeft
@onready var _rotate_right: Button = %RotateRight

func _ready() -> void:
	_camera.position = get_viewport_rect().size * 0.5
	_camera.make_current()
	_pieces = [STRAIGHT_PIECE, GENTLE_TURN_PIECE, HARD_TURN_PIECE, FORK_PIECE, CONVERGENCE_PIECE]
	_rotate_left.pressed.connect(_rotate_by.bind(-1))
	_rotate_right.pressed.connect(_rotate_by.bind(1))
	_confirm_button.pressed.connect(_confirm_placement)
	_cancel_button.pressed.connect(_cancel_placement)
	_piece_selector.item_selected.connect(_on_piece_selected)
	_piece_preview.hover_changed.connect(_on_preview_hover_changed)
	_piece_preview.hover_cleared.connect(_on_preview_hover_cleared)

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

	_piece_preview.set_board_cells(_board_grid.cells)
	_piece_selector.add_item("— sin pieza —", 0)
	for piece in _pieces:
		_piece_selector.add_item(piece.display_name)
	_piece_selector.select(1)
	_on_piece_selected(1)

func _process(_delta: float) -> void:
	if _is_panning:
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
		_cancel_placement()
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
			_confirm_placement()
			get_viewport().set_input_as_handled()
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()
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
	if _selected_piece == null:
		return
	_rotation_steps = posmod(_rotation_steps + step_delta, 6)
	_refresh_placement()

func _on_piece_selected(index: int) -> void:
	if index <= 0 or index > _pieces.size():
		_cancel_placement()
		return
	_selected_piece = _pieces[index - 1]
	_rotation_steps = 0
	_piece_status.text = _piece_summary(_selected_piece)
	_refresh_placement()

func _refresh_placement() -> void:
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
	_confirm_button.disabled = not _latest_placement.is_valid
	_rotation_status.text = "Orientación: %d° · posición %d/6" % [
		_rotation_steps * 60,
		_rotation_steps + 1,
	]
	_placement_status.text = "%s · conexiones: %d" % [
		_latest_placement.message(),
		_latest_placement.path_connection_count,
	]

func _confirm_placement() -> void:
	if _selected_piece == null or _latest_placement == null or not _latest_placement.is_valid:
		return
	var cells := TerrainPlacementValidator.instantiate_cells(
		_selected_piece,
		_anchor_coord,
		_rotation_steps,
		_next_piece_instance_id
	)
	if not _board_grid.add_cells(cells):
		_placement_status.text = "La pieza dejó de encajar antes de confirmar."
		return
	_next_piece_instance_id += 1
	_piece_preview.set_board_cells(_board_grid.cells)
	_cancel_placement()

func _cancel_placement() -> void:
	_selected_piece = null
	_latest_placement = null
	_piece_selector.select(0)
	_refresh_placement()

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
	_hover_status.text = "Casilla del tablero (q,r): (%d, %d) · %s · h%d" % [
		local_coord.x,
		local_coord.y,
		_terrain_display_name(terrain_type),
		elevation,
	]

func _on_preview_hover_cleared() -> void:
	_hover_status.text = "Casilla del tablero (q,r): — · hover sobre cara superior"

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
