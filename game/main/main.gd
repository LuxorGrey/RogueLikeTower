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
const M7_DAMAGE_TEST_WAVE: WaveData = preload("res://data/waves/m7_damage_test.tres")
const M8_STATUS_TEST_WAVE: WaveData = preload("res://data/waves/m8_status_test.tres")
const RUN_ECONOMY_DATA: Resource = preload("res://data/run/run_economy_m9.tres")
const BALLISTA: TowerData = preload("res://data/towers/ballista.tres")
const MORTAR: TowerData = preload("res://data/towers/mortar.tres")
const TESLA_COIL: TowerData = preload("res://data/towers/tesla_coil.tres")
const FROST_KEEP: TowerData = preload("res://data/towers/frost_keep.tres")
const FLAME_THROWER: TowerData = preload("res://data/towers/flame_thrower.tres")
const POISON_SPRAYER: TowerData = preload("res://data/towers/poison_sprayer.tres")
const SHREDDER: TowerData = preload("res://data/towers/shredder.tres")
const ARMOR_PIERCING_BOLT: TowerData = preload("res://data/towers/armor_piercing_bolt.tres")
const SAPPING_BOLT: TowerData = preload("res://data/towers/sapping_bolt.tres")
const STATUS_PROBE: TowerData = preload("res://data/towers/status_probe_m8.tres")
const TOWER_PROFILES: Array[TowerData] = [BALLISTA, MORTAR, TESLA_COIL, FROST_KEEP, FLAME_THROWER, POISON_SPRAYER, SHREDDER]
const TOWER_SHORT_NAMES: PackedStringArray = ["BALLISTA", "MORTERO", "TESLA", "FRÍO", "FUEGO", "VENENO", "SHREDDER"]
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
var _selected_wave: WaveData = FIRST_WAVE
var _active_wave_name: String = "Oleada básica"
var _selected_tower_data: TowerData = BALLISTA
var _combat_debug_timer: float = 0.0
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
@onready var _terrain_panel: PanelContainer = %TerrainPanel
@onready var _tower_toolbar: PanelContainer = %TowerToolbar
@onready var _tower_shortcut_buttons: Array[Button] = [
	%TowerShortcut1,
	%TowerShortcut2,
	%TowerShortcut3,
	%TowerShortcut4,
	%TowerShortcut5,
	%TowerShortcut6,
	%TowerShortcut7,
]
@onready var _camera: Camera2D = %Camera2D
@onready var _rotate_left: Button = %RotateLeft
@onready var _rotate_right: Button = %RotateRight
@onready var _entities: Node2D = %Entities
@onready var _base: GameBase = %GameBase
@onready var _wave_director: WaveDirector = %WaveDirector
@onready var _base_status: Label = %BaseStatus
@onready var _economy_status: Label = %EconomyStatus
@onready var _wave_status: Label = %WaveStatus
@onready var _start_wave_button: Button = %StartWave
@onready var _build_controller: BuildController = %BuildController
@onready var _build_status: Label = %BuildStatus
@onready var _tower_status: Label = %TowerStatus
@onready var _combat_debug: Label = %CombatDebug
@onready var _tower_actions: HBoxContainer = %TowerActions
@onready var _tower_targeting_mode: OptionButton = %TowerTargetingMode
@onready var _upgrade_tower_button: Button = %UpgradeTower
@onready var _wave_selector: OptionButton = %WaveSelector
@onready var _damage_service: Node = %DamageService
@onready var _run_economy: Node = %RunEconomyService

var _reward_transition_token: int = 0

func _ready() -> void:
	_camera.position = get_viewport_rect().size * 0.5
	_camera.make_current()
	_pieces = [STRAIGHT_PIECE, GENTLE_TURN_PIECE, HARD_TURN_PIECE, FORK_PIECE, CONVERGENCE_PIECE]
	_rotate_left.pressed.connect(_rotate_by.bind(-1))
	_rotate_right.pressed.connect(_rotate_by.bind(1))
	_start_wave_button.pressed.connect(_start_selected_wave)
	_wave_selector.item_selected.connect(_on_wave_profile_selected)
	for index in _tower_shortcut_buttons.size():
		_tower_shortcut_buttons[index].pressed.connect(_select_tower_and_build.bind(index))
	_confirm_button.pressed.connect(_confirm_placement)
	_cancel_button.pressed.connect(_cancel_placement)
	_piece_selector.item_selected.connect(_on_piece_selected)
	_piece_preview.hover_changed.connect(_on_preview_hover_changed)
	_piece_preview.hover_cleared.connect(_on_preview_hover_cleared)
	_base.health_changed.connect(_on_base_health_changed)
	_run_economy.connect(&"gold_changed", _on_gold_changed)
	_run_economy.connect(&"mana_changed", _on_mana_changed)
	_wave_director.wave_started.connect(_on_wave_started)
	_wave_director.wave_completed.connect(_on_wave_completed)
	_wave_director.wave_failed.connect(_on_wave_failed)
	_wave_director.enemy_count_changed.connect(_on_enemy_count_changed)
	_wave_director.base_damaged.connect(_on_base_damaged)
	_wave_director.reward_earned.connect(_on_reward_earned)
	_build_controller.tower_selected.connect(_on_tower_selected)
	_build_controller.tower_upgraded.connect(_on_tower_upgraded)
	_build_controller.build_mode_changed.connect(_on_build_mode_changed)
	_tower_targeting_mode.item_selected.connect(_on_targeting_mode_selected)
	_upgrade_tower_button.pressed.connect(_on_upgrade_tower_pressed)
	_build_controller.configure(
		_board_grid,
		_entities,
		_piece_preview.global_position,
		HEX_RADIUS,
		_damage_service,
		_run_economy
	)
	_populate_wave_options()
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
	_wave_status.text = "Preparada · 3 enemigos"
	RunManager.transition_to(RunManager.Phase.ROUND_PREP)
	if not bool(_run_economy.call("configure", RUN_ECONOMY_DATA)):
		push_error("No se pudo iniciar la economía de run: %s" % _run_economy.get("last_error"))
	_refresh_tower_controls()
	_refresh_path_status()
	_piece_selector.add_item("— sin pieza —", 0)
	for piece in _pieces:
		_piece_selector.add_item(piece.display_name)
	_piece_selector.select(1)
	_on_piece_selected(1)

func _process(_delta: float) -> void:
	_combat_debug_timer -= _delta
	if _combat_debug_timer <= 0.0:
		_refresh_combat_debug()
		_combat_debug_timer = 0.2
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
		elif key_event.pressed and not key_event.echo:
			match key_event.keycode:
				KEY_1:
					_select_tower_and_build(0)
					get_viewport().set_input_as_handled()
				KEY_2:
					_select_tower_and_build(1)
					get_viewport().set_input_as_handled()
				KEY_3:
					_select_tower_and_build(2)
					get_viewport().set_input_as_handled()
				KEY_4:
					_select_tower_and_build(3)
					get_viewport().set_input_as_handled()
				KEY_5:
					_select_tower_and_build(4)
					get_viewport().set_input_as_handled()
				KEY_6:
					_select_tower_and_build(5)
					get_viewport().set_input_as_handled()
				KEY_7:
					_select_tower_and_build(6)
					get_viewport().set_input_as_handled()
				KEY_8:
					_select_debug_tower_and_build(ARMOR_PIERCING_BOLT)
					get_viewport().set_input_as_handled()
				KEY_9:
					_select_debug_tower_and_build(SAPPING_BOLT)
					get_viewport().set_input_as_handled()
				KEY_0:
					_select_debug_tower_and_build(STATUS_PROBE)
					get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_MIDDLE:
			return
		if mouse_event.pressed and _is_mouse_over_hud(mouse_event.position):
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
	if _is_mouse_over_hud(get_viewport().get_mouse_position()):
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
			KEY_F3:
				_toggle_terrain_panel()
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

func _is_mouse_over_hud(mouse_position: Vector2) -> bool:
	if not _hud.visible:
		return false
	return (
		(_hud_panel.visible and _hud_panel.get_global_rect().has_point(mouse_position))
		or (_tower_toolbar.visible and _tower_toolbar.get_global_rect().has_point(mouse_position))
		or (_terrain_panel.visible and _terrain_panel.get_global_rect().has_point(mouse_position))
	)

func _toggle_terrain_panel() -> void:
	_terrain_panel.visible = not _terrain_panel.visible

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
			_build_status.text = "%s construida por %d oro en (%d, %d)." % [
				_selected_tower_data.display_name,
				_selected_tower_data.build_cost,
				_hovered_coord.x,
				_hovered_coord.y,
			]
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

func _select_tower_and_build(index: int) -> void:
	if index < 0 or index >= TOWER_PROFILES.size():
		return
	_select_tower_profile_and_build(TOWER_PROFILES[index])

func _select_debug_tower_and_build(tower_data: TowerData) -> void:
	_select_tower_profile_and_build(tower_data)
	if _build_controller.is_build_mode() and _selected_tower_data == tower_data:
		_build_status.text = "Perfil de diagnóstico: %s · clic en Grass/Montaña libre." % tower_data.display_name

func _select_tower_profile_and_build(chosen_tower: TowerData) -> void:
	if chosen_tower == null:
		return
	if _build_controller.is_build_mode() and _selected_tower_data == chosen_tower:
		_build_controller.cancel_build_mode()
		_build_status.text = "Construcción cancelada."
		_refresh_tower_controls()
		return
	_selected_tower_data = chosen_tower
	_cancel_placement()
	if _build_controller.begin_build(_selected_tower_data):
		_build_status.text = "%s · clic en Grass/Montaña libre." % _selected_tower_data.display_name
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

func _populate_wave_options() -> void:
	_selected_tower_data = BALLISTA
	_wave_selector.clear()
	_wave_selector.add_item("Oleada básica · 3 enemigos")
	_wave_selector.add_item("Diagnóstico · blindado regenerador")
	_wave_selector.add_item("Estados M8 · objetivo lento")
	_wave_selector.select(0)
	_selected_wave = FIRST_WAVE
	_active_wave_name = "Oleada básica"
	_wave_status.text = "Preparada · 3 enemigos"
	_start_wave_button.text = "▶ Iniciar oleada seleccionada"
	_refresh_tower_controls()

func _on_wave_profile_selected(index: int) -> void:
	if index < 0 or index > 2:
		return
	match index:
		0:
			_selected_wave = FIRST_WAVE
			_active_wave_name = "Oleada básica"
			_wave_status.text = "Preparada · 3 enemigos"
		1:
			_selected_wave = M7_DAMAGE_TEST_WAVE
			_active_wave_name = "Diagnóstico blindado"
			_wave_status.text = "Preparada · 1 blindado · armadura 4 · regen 2/s"
		2:
			_selected_wave = M8_STATUS_TEST_WAVE
			_active_wave_name = "Prueba de estados M8"
			_wave_status.text = "Preparada · 1 objetivo · vida 180 · velocidad 32"
	_start_wave_button.text = "▶ Iniciar oleada seleccionada"

func _on_targeting_mode_selected(index: int) -> void:
	if index < 0 or index >= _tower_targeting_mode.item_count:
		return
	var mode: int = _tower_targeting_mode.get_item_id(index)
	if _build_controller.set_selected_targeting_mode(mode):
		_refresh_tower_controls()

func _on_upgrade_tower_pressed() -> void:
	var tower: Tower = _build_controller.selected_tower
	var upgrade_cost: int = tower.get_next_upgrade_cost() if tower != null and is_instance_valid(tower) else -1
	if _build_controller.upgrade_selected_tower():
		_build_status.text = "Torre mejorada · −%d oro." % upgrade_cost
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
	var can_build: bool = _build_controller.can_build_in_current_phase()
	var is_defeated: bool = RunManager.phase == RunManager.Phase.RUN_DEFEAT
	for index in _tower_shortcut_buttons.size():
		var shortcut_button: Button = _tower_shortcut_buttons[index]
		var tower_data: TowerData = TOWER_PROFILES[index]
		var mana_suffix: String = " · %.1f maná/ataque" % tower_data.mana_cost_per_attack if tower_data.mana_cost_per_attack > 0.0 else ""
		shortcut_button.text = "%d · %s\n%d oro" % [
			index + 1,
			TOWER_SHORT_NAMES[index],
			tower_data.build_cost,
		]
		shortcut_button.tooltip_text = "%s\n%s · coste %d oro%s · %s" % [
			tower_data.display_name,
			tower_data.role_summary,
			tower_data.build_cost,
			mana_suffix,
			_tower_attack_description(tower_data),
		]
		shortcut_button.add_theme_color_override("font_color", tower_data.visual_color)
		shortcut_button.disabled = not can_build or not bool(_run_economy.call("can_afford_gold", tower_data.build_cost))
		shortcut_button.set_pressed_no_signal(
			build_mode and TOWER_PROFILES[index] == _selected_tower_data
		)
	_wave_selector.disabled = build_mode or not _can_start_wave() or is_defeated
	_tower_actions.visible = selected != null and not build_mode
	_start_wave_button.disabled = (
		build_mode
		or not _path_graph.is_valid
		or not _can_start_wave()
		or is_defeated
	)
	_tower_targeting_mode.disabled = build_mode or selected == null or not _build_controller.can_build_in_current_phase()
	var next_upgrade_cost: int = selected.get_next_upgrade_cost() if selected != null else -1
	_upgrade_tower_button.text = "Mejorar · %d oro" % next_upgrade_cost if next_upgrade_cost >= 0 else "Mejorar"
	_upgrade_tower_button.disabled = (
		build_mode
		or selected == null
		or next_upgrade_cost < 0
		or not bool(_run_economy.call("can_afford_gold", next_upgrade_cost))
		or not _build_controller.can_build_in_current_phase()
	)
	if build_mode:
		_tower_status.text = "Construir: %s · selecciona Grass o Montaña" % _selected_tower_data.display_name
	elif selected == null:
		_tower_status.text = "Torre: ninguna · pulsa 1–7 para construir"
	else:
		_tower_status.text = selected.get_summary()

func _tower_attack_description(tower_data: TowerData) -> String:
	match tower_data.attack_pattern:
		TowerData.AttackPattern.SINGLE_TARGET:
			return "objetivo único"
		TowerData.AttackPattern.AREA:
			return "área %.1f hex" % tower_data.attack_area_radius_hexes
		TowerData.AttackPattern.CHAIN:
			return "hasta %d blancos" % tower_data.max_targets
		TowerData.AttackPattern.CONE:
			return "cono %.0f°" % tower_data.cone_angle_degrees
		TowerData.AttackPattern.SAWBLADE:
			return "hoja perforante por PATH"
		_:
			return "ataque no configurado"

func _start_selected_wave() -> void:
	if not _path_graph.is_valid or not _can_start_wave():
		return
	if _build_controller.is_build_mode():
		_build_controller.cancel_build_mode()
	_cancel_placement()
	_placement_enabled = false
	_refresh_placement()
	_start_wave_button.disabled = true
	if not _wave_director.start_wave(
		_selected_wave,
		_path_graph,
		_base,
		_entities,
		_piece_preview.global_position,
		HEX_RADIUS,
		_damage_service
	):
		_placement_enabled = true
		_refresh_placement()
		_wave_status.text = "No se pudo iniciar: %s" % _wave_director.last_error
		_refresh_tower_controls()

func _on_wave_started(round_number: int) -> void:
	RunManager.transition_to(RunManager.Phase.COMBAT)
	_wave_status.text = "%s · ronda %d · enemigos 0" % [_active_wave_name, round_number]
	_refresh_tower_controls()

func _on_wave_completed(round_number: int) -> void:
	_reward_transition_token += 1
	var transition_token: int = _reward_transition_token
	RunManager.transition_to(RunManager.Phase.ROUND_REWARD)
	var round_reward: int = _selected_wave.round_reward if _selected_wave != null else 0
	_wave_status.text = "%s completada · ronda %d · +%d oro · procesando recompensa…" % [
		_active_wave_name,
		round_number,
		round_reward,
	]
	_start_wave_button.text = "↻ Probar oleada seleccionada"
	_refresh_tower_controls()
	await get_tree().create_timer(0.8).timeout
	if transition_token != _reward_transition_token or RunManager.phase != RunManager.Phase.ROUND_REWARD:
		return
	_placement_enabled = true
	RunManager.transition_to(RunManager.Phase.TERRAIN_EXPANSION)
	_wave_status.text = "%s completada · ronda %d · +%d oro · elige otra y vuelve a probar" % [
		_active_wave_name,
		round_number,
		round_reward,
	]
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
		_wave_status.text = "%s · enemigos en ruta: %d" % [_active_wave_name, alive_count]

func _can_start_wave() -> bool:
	return RunManager.phase == RunManager.Phase.ROUND_PREP or RunManager.phase == RunManager.Phase.TERRAIN_EXPANSION

func _on_reward_earned(amount: int, reason: int) -> void:
	var economy_reason: StringName = &"kill_reward"
	if reason == WaveDirector.RewardReason.ROUND_CLEAR:
		economy_reason = &"round_reward"
	var accepted: int = int(_run_economy.call("add_gold", amount, economy_reason))
	if accepted <= 0:
		return
	if reason == WaveDirector.RewardReason.ENEMY_KILL:
		_build_status.text = "Recompensa por baja: +%d oro." % accepted
	elif reason == WaveDirector.RewardReason.ROUND_CLEAR:
		_build_status.text = "Recompensa por oleada: +%d oro." % accepted

func _on_gold_changed(_current_gold: int, _delta: int, _reason: StringName) -> void:
	_refresh_economy_status()
	_refresh_tower_controls()

func _on_mana_changed(_current_mana: float, _maximum_mana: float) -> void:
	_refresh_economy_status()

func _refresh_economy_status() -> void:
	if _run_economy == null or _economy_status == null:
		return
	_economy_status.text = "Oro %d  ·  Maná %.1f / %.0f  ·  regen %.1f/s" % [
		int(_run_economy.call("get_gold")),
		float(_run_economy.call("get_mana")),
		float(_run_economy.call("get_maximum_mana")),
		float(_run_economy.call("get_mana_regen_per_second")),
	]

func _refresh_combat_debug() -> void:
	var tower: Tower = _build_controller.selected_tower
	if tower == null or not is_instance_valid(tower):
		_combat_debug.text = "Objetivo: selecciona una torre"
		return
	var target: Enemy = tower.get_current_target()
	if target == null or not is_instance_valid(target) or target.state != Enemy.State.MOVING:
		_combat_debug.text = "Objetivo: ninguno en alcance"
		if tower.is_mana_blocked():
			_combat_debug.text += " · sin maná"
		return
	var estimate: Variant = _damage_service.call("preview_damage", target, tower.create_damage_packet())
	var status_summaries: PackedStringArray = target.get_active_status_summaries()
	var status_text: String = "Estados: —" if status_summaries.is_empty() else "Estados: %s" % " · ".join(status_summaries)
	var tower_data: TowerData = tower.get_tower_data()
	var damage_tag_name: String = tower.get_damage_tag_name(tower_data.damage_tags)
	var mana_text: String = ""
	if tower.get_mana_cost_per_attack() > 0.0:
		mana_text = " · sin maná" if tower.is_mana_blocked() else " · %.1f maná/ataque" % tower.get_mana_cost_per_attack()
	var regen_text: String = ""
	var effective_regen: float = target.get_effective_regen_per_second()
	if not is_equal_approx(effective_regen, target.get_regen_per_second()):
		regen_text = " → %.1f/s" % effective_regen
	var damage_summary: String = "impacto %d %s" % [int(estimate.get("calculated_health_damage")), damage_tag_name]
	if tower_data.attack_pattern == TowerData.AttackPattern.SAWBLADE:
		damage_summary = "Bleed bruto %d" % tower.get_current_damage()
	_combat_debug.text = "%s · %d/%d HP · arm %d · regen %.1f%s · %s%s\n%s" % [
		target.get_display_name(),
		target.get_current_health(),
		target.get_maximum_health(),
		target.get_armor_value(),
		target.get_regen_per_second(),
		regen_text,
		damage_summary,
		mana_text,
		status_text,
	]

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
