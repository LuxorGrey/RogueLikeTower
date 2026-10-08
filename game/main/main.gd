extends Node2D

const HEX_RADIUS: float = 52.0
const ELEVATION_PIXEL_OFFSET: float = 18.0
const STARTING_BOARD: Resource = preload("res://data/terrain/starting_board.tres")
const STRAIGHT_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/straight.tres")
const GENTLE_TURN_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/gentle_turn.tres")
const HARD_TURN_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/hard_turn.tres")
const FORK_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/fork.tres")
const CONVERGENCE_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/convergence.tres")
const FIRST_WAVE: WaveData = preload("res://data/waves/round_01.tres")
const DEMO_CAMPAIGN: Resource = preload("res://data/waves/demo_campaign.tres")
const M7_DAMAGE_TEST_WAVE: WaveData = preload("res://data/waves/m7_damage_test.tres")
const M8_STATUS_TEST_WAVE: WaveData = preload("res://data/waves/m8_status_test.tres")
const TOWER_LAYER_TEST_WAVE: WaveData = preload("res://data/waves/tower_layer_training_wave.tres")
const RUN_ECONOMY_DATA: Resource = preload("res://data/run/run_economy_m9.tres")
const DEMO_CARD_POOL: Resource = preload("res://data/cards/demo_card_pool.tres")
const META_SHOP_PANEL_SCRIPT: Script = preload("res://game/progression/meta_shop_panel.gd")
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
var _placement_enabled: bool = false
var _selected_wave: WaveData = FIRST_WAVE
var _active_wave_name: String = "Oleada básica"
var _campaign_round_number: int = 1
var _campaign_is_valid: bool = true
var _selected_wave_is_debug: bool = false
var _debug_return_phase: int = RunManager.Phase.ROUND_PREP
var _awaiting_campaign_expansion: bool = false
var _selected_tower_data: TowerData = BALLISTA
var _combat_debug_timer: float = 0.0
var _hovered_coord: Vector2i = Vector2i.ZERO
var _has_hovered_cell: bool = false
var _terrain_rng := RandomNumberGenerator.new()
var _offered_terrain_pieces: Array[TerrainPieceData] = []
var _selected_expansion_piece: TerrainPieceData
var _pending_expansion_round: int = 0
var _pending_expansion_reward: int = 0
var _upgrade_card_buttons: Array[Button] = []
var _upgrade_card_titles: Array[Label] = []
var _upgrade_card_descriptions: Array[Label] = []
var _upgrade_card_rarities: Array[Label] = []
var _upgrade_card_panel: PanelContainer
var _upgrade_card_heading: Label
var _meta_shop_panel: CanvasLayer

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
@onready var _terrain_card_panel: PanelContainer = %TerrainCardPanel
@onready var _terrain_card_buttons: Array[Button] = [
	%TerrainCard1,
	%TerrainCard2,
	%TerrainCard3,
]
@onready var _terrain_card_titles: Array[Label] = [
	%CardTitle1,
	%CardTitle2,
	%CardTitle3,
]
@onready var _terrain_card_previews: Array[Control] = [
	%CardPreview1,
	%CardPreview2,
	%CardPreview3,
]
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
@onready var _tower_actions: VBoxContainer = %TowerActions
@onready var _tower_priority_selectors: Array[OptionButton] = [
	%TowerPriority1,
	%TowerPriority2,
	%TowerPriority3,
]
@onready var _tower_upgrade_buttons: Array[Button] = [
	%UpgradeHealth,
	%UpgradeArmor,
	%UpgradeShield,
]
@onready var _demolish_tower_button: Button = %DemolishTower
@onready var _wave_selector: OptionButton = %WaveSelector
@onready var _damage_service: Node = %DamageService
@onready var _run_economy: Node = %RunEconomyService
@onready var _run_card_service: Node = %RunCardService

var _reward_transition_token: int = 0
var _base_coord: Vector2i = Vector2i.ZERO

func _ready() -> void:
	_base_coord = STARTING_BOARD.get("base_coord")
	MetaProgression.call("configure_tower_catalog", TOWER_PROFILES)
	var current_run_seed: int = int(MetaProgression.call("begin_run"))
	GameState.run_seed = current_run_seed
	GameState.current_round = 1
	_terrain_rng.seed = current_run_seed
	var run_number: int = int(MetaProgression.call("get_total_runs_started"))
	var starting_board_rotation_steps: int = posmod(run_number - 1, HexCoord.DIRECTION_OFFSETS.size())
	_camera.position = get_viewport_rect().size * 0.5
	_camera.make_current()
	_pieces = [STRAIGHT_PIECE, GENTLE_TURN_PIECE, HARD_TURN_PIECE, FORK_PIECE, CONVERGENCE_PIECE]
	_rotate_left.pressed.connect(_rotate_by.bind(-1))
	_rotate_right.pressed.connect(_rotate_by.bind(1))
	for index in _terrain_card_buttons.size():
		_terrain_card_buttons[index].pressed.connect(_on_terrain_card_selected.bind(index))
		_style_terrain_card_button(_terrain_card_buttons[index])
	_create_upgrade_card_panel()
	_meta_shop_panel = META_SHOP_PANEL_SCRIPT.new() as CanvasLayer
	_meta_shop_panel.call(
		"configure",
		TOWER_PROFILES,
		MetaProgression.call("get_permanent_upgrades")
	)
	add_child(_meta_shop_panel)
	_meta_shop_panel.connect("new_run_requested", _on_new_run_requested)
	for index in _upgrade_card_buttons.size():
		_upgrade_card_buttons[index].pressed.connect(_on_upgrade_card_selected.bind(index))
	_start_wave_button.pressed.connect(_start_selected_wave)
	_wave_selector.item_selected.connect(_on_wave_profile_selected)
	for index in _tower_shortcut_buttons.size():
		_tower_shortcut_buttons[index].pressed.connect(_select_tower_and_build.bind(index))
	_confirm_button.pressed.connect(_confirm_placement)
	_cancel_button.pressed.connect(_cancel_active_tool)
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
	_wave_director.population_changed.connect(_on_population_changed)
	_wave_director.base_damaged.connect(_on_base_damaged)
	_wave_director.reward_earned.connect(_on_reward_earned)
	_build_controller.tower_selected.connect(_on_tower_selected)
	_build_controller.tower_built.connect(_on_tower_list_changed)
	_build_controller.tower_demolished.connect(_on_tower_demolished)
	_build_controller.tower_upgraded.connect(_on_tower_upgraded)
	_build_controller.build_mode_changed.connect(_on_build_mode_changed)
	for slot in _tower_priority_selectors.size():
		_tower_priority_selectors[slot].item_selected.connect(_on_targeting_mode_selected.bind(slot))
	for layer in _tower_upgrade_buttons.size():
		_tower_upgrade_buttons[layer].pressed.connect(_on_upgrade_tower_pressed.bind(layer))
	_demolish_tower_button.pressed.connect(_on_demolish_tower_pressed)
	_build_controller.configure(
		_board_grid,
		_entities,
		_piece_preview.global_position,
		HEX_RADIUS,
		_damage_service,
		_run_economy,
		_run_card_service,
		MetaProgression
	)
	var unlocked_content_ids: Array[StringName] = []
	unlocked_content_ids.assign(MetaProgression.call("get_unlocked_content_ids"))
	if not bool(_run_card_service.call("configure", DEMO_CARD_POOL, unlocked_content_ids, current_run_seed, true)):
		push_error("No se pudo configurar el pool de cartas M11: %s" % _run_card_service.get("last_error"))
	_run_economy.call("set_run_card_service", _run_card_service)
	var campaign_errors: PackedStringArray = DEMO_CAMPAIGN.call("validate")
	if not campaign_errors.is_empty():
		_campaign_is_valid = false
		push_error("Campaña M10 inválida: %s" % "; ".join(campaign_errors))
	_populate_targeting_modes()

	var starting_errors: PackedStringArray = STARTING_BOARD.call("validate")
	if not starting_errors.is_empty():
		_placement_status.text = "Tablero inicial inválido: %s" % "; ".join(starting_errors)
		push_error(_placement_status.text)
		return
	var starting_cells: Dictionary[Vector2i, HexCell] = STARTING_BOARD.call(
		"instantiate_cells",
		starting_board_rotation_steps
	)
	if not _board_grid.add_cells(starting_cells):
		_placement_status.text = "No se pudo crear el tablero inicial."
		push_error(_placement_status.text)
		return
	_path_graph.rebuild(_board_grid.cells, _base_coord, int(STARTING_BOARD.get("minimum_spawn_route_cells")))
	if not _path_graph.is_valid:
		push_error("Grafo PATH inicial inválido: %s" % "; ".join(_path_graph.errors))

	_piece_preview.set_board_cells(_board_grid.cells)
	_piece_preview.set_path_graph(_path_graph)
	_populate_wave_options()
	_base.global_position = _piece_preview.global_position + HexMath.axial_to_world(
		HexCoord.new(_base_coord.x, _base_coord.y),
		HEX_RADIUS
	)
	_base.footprint_radius = HEX_RADIUS
	_base.queue_redraw()
	_on_base_health_changed(_base.get_current_health(), _base.get_maximum_health())
	_refresh_tower_controls()
	_start_wave_button.disabled = not _path_graph.is_valid
	_placement_enabled = false
	_wave_status.text = "Preparación · ronda 1/20 · %d enemigos" % _get_wave_enemy_count(FIRST_WAVE)
	RunManager.transition_to(RunManager.Phase.ROUND_PREP)
	var permanent_economy_bonuses: Dictionary = MetaProgression.call("get_run_economy_bonuses")
	if not bool(_run_economy.call("configure", RUN_ECONOMY_DATA, permanent_economy_bonuses)):
		push_error("No se pudo iniciar la economía de run: %s" % _run_economy.get("last_error"))
	_refresh_tower_controls()
	_refresh_path_status()
	_piece_selector.add_item("— sin pieza —", 0)
	for piece in _pieces:
		_piece_selector.add_item(piece.display_name)
	_piece_selector.select(0)
	_on_piece_selected(0)
	_terrain_card_panel.hide()
	_upgrade_card_panel.hide()

func _process(_delta: float) -> void:
	_combat_debug_timer -= _delta
	if _combat_debug_timer <= 0.0:
		_refresh_combat_debug()
		_refresh_tower_controls()
		_combat_debug_timer = 0.2
	if _is_panning or not _placement_enabled or _build_controller.is_build_mode():
		return
	_update_anchor_from_mouse()

func _input(event: InputEvent) -> void:
	if _meta_shop_panel != null and bool(_meta_shop_panel.call("is_open")):
		if event is InputEventKey:
			var overlay_key := event as InputEventKey
			if overlay_key.pressed and not overlay_key.echo and overlay_key.keycode == KEY_H:
				_toggle_hud()
				get_viewport().set_input_as_handled()
		return
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
	if _meta_shop_panel != null and bool(_meta_shop_panel.call("is_open")):
		get_viewport().set_input_as_handled()
		return
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
	if _meta_shop_panel != null and bool(_meta_shop_panel.call("is_open")):
		return true
	if not _hud.visible:
		return false
	return (
		(_hud_panel.visible and _hud_panel.get_global_rect().has_point(mouse_position))
		or (_tower_toolbar.visible and _tower_toolbar.get_global_rect().has_point(mouse_position))
		or (_terrain_panel.visible and _terrain_panel.get_global_rect().has_point(mouse_position))
		or (_terrain_card_panel.visible and _terrain_card_panel.get_global_rect().has_point(mouse_position))
		or (_upgrade_card_panel != null and _upgrade_card_panel.visible and _upgrade_card_panel.get_global_rect().has_point(mouse_position))
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
	if RunManager.phase == RunManager.Phase.CARD_OFFER:
		_latest_placement = null
		_piece_preview.set_placement_preview(null, _anchor_coord, _rotation_steps, false, false)
		_piece_selector.disabled = true
		_rotate_left.disabled = true
		_rotate_right.disabled = true
		_cancel_button.disabled = true
		_confirm_button.disabled = true
		_piece_status.text = "Expansión colocada · mejora pendiente"
		_rotation_status.text = "Orientación: —"
		_placement_status.text = "Elige una carta de mejora antes de la siguiente ronda."
		return
	var can_edit_terrain: bool = _placement_enabled and not _build_controller.is_build_mode()
	var is_campaign_card_placement: bool = (
		_awaiting_campaign_expansion
		and RunManager.phase == RunManager.Phase.TERRAIN_EXPANSION
		and _selected_expansion_piece != null
	)
	_piece_selector.disabled = not can_edit_terrain or is_campaign_card_placement
	_rotate_left.disabled = not can_edit_terrain or _selected_piece == null
	_rotate_right.disabled = not can_edit_terrain or _selected_piece == null
	_cancel_button.disabled = not can_edit_terrain or _selected_piece == null
	_cancel_button.text = "Volver a cartas" if is_campaign_card_placement else "Cancelar"
	if _selected_piece == null:
		_latest_placement = null
		_piece_preview.set_placement_preview(null, _anchor_coord, _rotation_steps, false, false)
		_confirm_button.disabled = true
		_piece_status.text = "Tablero confirmado · %d casillas" % _board_grid.cells.size()
		_rotation_status.text = "Orientación: —"
		_placement_status.text = (
			"Elige una carta de terreno para continuar."
			if _awaiting_campaign_expansion
			else "Elige una pieza para iniciar la colocación."
		)
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
		_latest_placement.is_valid,
		can_edit_terrain
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
	var candidate_grid := HexGrid.new()
	candidate_grid.cells = candidate_board
	var cells_to_add: Dictionary[Vector2i, HexCell] = {}
	for coord in cells:
		cells_to_add[coord] = cells[coord]
	for hole_coord in candidate_grid.get_enclosed_void_coords():
		var filled_cell: HexCell = _create_auto_fill_cell(hole_coord)
		candidate_board[hole_coord] = filled_cell
		cells_to_add[hole_coord] = filled_cell
	var candidate_graph := PathGraph.new()
	candidate_graph.rebuild(candidate_board, _base_coord, int(STARTING_BOARD.get("minimum_spawn_route_cells")))
	if not candidate_graph.is_valid:
		_placement_status.text = "No se confirma: red PATH inválida · %s" % "; ".join(candidate_graph.errors)
		return
	if not _board_grid.add_cells(cells_to_add):
		_placement_status.text = "La pieza dejó de encajar antes de confirmar."
		return
	_path_graph = candidate_graph
	_next_piece_instance_id += 1
	_piece_preview.set_board_cells(_board_grid.cells)
	_piece_preview.set_path_graph(_path_graph)
	_refresh_path_status()
	_refresh_campaign_option_counts()
	var confirmed_campaign_expansion: bool = (
		_awaiting_campaign_expansion
		and RunManager.phase == RunManager.Phase.TERRAIN_EXPANSION
	)
	if confirmed_campaign_expansion:
		_awaiting_campaign_expansion = false
		_selected_expansion_piece = null
		_offered_terrain_pieces.clear()
		_terrain_card_panel.hide()
	_cancel_placement()
	if confirmed_campaign_expansion:
		_placement_enabled = false
		if bool(_run_card_service.call("should_offer_after", _pending_expansion_round)):
			var upgrade_cards: Array[Resource] = _run_card_service.call("create_offer", _pending_expansion_round)
			if upgrade_cards.size() == _upgrade_card_buttons.size():
				_present_upgrade_card_offer(_pending_expansion_round, upgrade_cards)
				_refresh_placement()
				_refresh_tower_controls()
				return
			push_error("No se pudo crear oferta M11: %s" % _run_card_service.get("last_error"))
		_prepare_next_campaign_round()
		return

func _create_auto_fill_cell(coord: Vector2i) -> HexCell:
	var fill_mountain: bool = _terrain_rng.randi_range(0, 1) == 1
	var cell := HexCell.new(HexCoord.new(coord.x, coord.y))
	cell.terrain_type = HexCell.TerrainType.MOUNTAIN if fill_mountain else HexCell.TerrainType.GRASS
	cell.elevation = 2 if fill_mountain else 1
	cell.buildable = true
	cell.visual_variant = &"auto_filled_void"
	return cell

func _cancel_placement() -> void:
	_selected_piece = null
	_latest_placement = null
	_piece_selector.select(0)
	_refresh_placement()

func _cancel_active_tool() -> void:
	if RunManager.phase == RunManager.Phase.CARD_OFFER:
		return
	if _terrain_card_panel.visible and _selected_expansion_piece == null:
		return
	if (
		_awaiting_campaign_expansion
		and RunManager.phase == RunManager.Phase.TERRAIN_EXPANSION
		and _selected_expansion_piece != null
	):
		if _build_controller.is_build_mode():
			_build_controller.cancel_build_mode()
			_refresh_build_preview()
		_return_to_terrain_card_offer()
		return
	if _build_controller.is_build_mode():
		_build_controller.cancel_build_mode()
		_refresh_build_preview()
		_refresh_placement()
		_refresh_tower_controls()
		return
	_cancel_placement()

func _handle_board_click() -> void:
	if RunManager.phase == RunManager.Phase.CARD_OFFER:
		return
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
			if _selected_expansion_piece == null:
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
	if not bool(MetaProgression.call("is_tower_unlocked", chosen_tower)):
		_build_status.text = "Torre bloqueada · desbloquéala en la tienda al terminar la run."
		return
	if _awaiting_campaign_expansion and _selected_expansion_piece == null:
		_build_status.text = "Elige una carta de terreno antes de continuar."
		return
	if _build_controller.is_build_mode() and _selected_tower_data == chosen_tower:
		_build_controller.cancel_build_mode()
		_build_status.text = "Construcción cancelada."
		_refresh_tower_controls()
		return
	_selected_tower_data = chosen_tower
	if _selected_expansion_piece == null:
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
	var labels: PackedStringArray = [
		"Más avanzado", "Menos avanzado", "Casi sin vida/capa", "Más vida",
		"Más armadura", "Más escudo", "Menos vida", "Menos armadura",
		"Menos escudo", "Más lento", "Más rápido",
	]
	for selector in _tower_priority_selectors:
		selector.clear()
		selector.add_item("Sin criterio", -1)
		for mode in labels.size():
			selector.add_item(labels[mode], mode)
		selector.select(1)

func _populate_wave_options() -> void:
	_selected_tower_data = BALLISTA
	_wave_selector.clear()
	for round_index in range(20):
		var wave: WaveData = _get_campaign_round(round_index + 1)
		var encounter_label: String = _encounter_label(wave)
		_wave_selector.add_item("Ronda %02d/20 · %s · %d enemigos" % [
			round_index + 1,
			encounter_label,
			_get_wave_enemy_count(wave),
		])
	_wave_selector.add_item("DEBUG · blindado regenerador")
	_wave_selector.add_item("DEBUG · objetivo de estados M8")
	_wave_selector.add_item("DEBUG · capas escudo/armadura/vida")
	_wave_selector.select(0)
	_selected_wave = _get_campaign_round(_campaign_round_number)
	_selected_wave_is_debug = false
	_set_campaign_wave_name()
	_wave_status.text = "Preparación · ronda %d/20 · %d enemigos" % [
		_campaign_round_number,
		_get_wave_enemy_count(_selected_wave),
	]
	_start_wave_button.text = "▶ Iniciar ronda %d/20" % _campaign_round_number
	_refresh_tower_controls()

func _refresh_campaign_option_counts() -> void:
	for round_index in range(20):
		var wave: WaveData = _get_campaign_round(round_index + 1)
		_wave_selector.set_item_text(round_index, "Ronda %02d/20 · %s · %d enemigos" % [
			round_index + 1,
			_encounter_label(wave),
			_get_wave_enemy_count(wave),
		])

func _on_wave_profile_selected(index: int) -> void:
	if index < 0:
		return
	if index < 20:
		if index + 1 != _campaign_round_number or RunManager.phase != RunManager.Phase.ROUND_PREP:
			_wave_selector.select(_campaign_round_number - 1)
			return
		_selected_wave = _get_campaign_round(index + 1)
		_selected_wave_is_debug = false
		_set_campaign_wave_name()
		_wave_status.text = "Preparación · ronda %d/20 · %d enemigos" % [
			_campaign_round_number,
			_get_wave_enemy_count(_selected_wave),
		]
	elif index == 20:
		_selected_wave = M7_DAMAGE_TEST_WAVE
		_selected_wave_is_debug = true
		_active_wave_name = "Diagnóstico blindado"
		_wave_status.text = "Diagnóstico · 1 blindado · armadura 4 · regen 2/s"
	elif index == 21:
		_selected_wave = M8_STATUS_TEST_WAVE
		_selected_wave_is_debug = true
		_active_wave_name = "Prueba de estados M8"
		_wave_status.text = "Prueba de estados · 1 objetivo · vida 180 · velocidad 32"
	elif index == 22:
		_selected_wave = TOWER_LAYER_TEST_WAVE
		_selected_wave_is_debug = true
		_active_wave_name = "Prueba de capas H/A/E"
		_wave_status.text = "Prueba de capas · escudo 40 · armadura 60 · vida 120 · regeneración 1/s por capa"
	else:
		return
	_start_wave_button.text = "▶ Iniciar prueba" if _selected_wave_is_debug else "▶ Iniciar ronda %d/20" % _campaign_round_number
	_refresh_tower_controls()

func _on_targeting_mode_selected(index: int, slot: int) -> void:
	if slot < 0 or slot >= _tower_priority_selectors.size():
		return
	var selector: OptionButton = _tower_priority_selectors[slot]
	if index < 0 or index >= selector.item_count:
		return
	var mode: int = selector.get_item_id(index)
	if _build_controller.set_selected_targeting_priority(slot, mode):
		_refresh_tower_controls()
	else:
		_build_status.text = "Cada criterio de prioridad solo puede aparecer una vez."
		var selected_tower: Tower = _build_controller.selected_tower
		if selected_tower != null and is_instance_valid(selected_tower):
			_on_tower_selected(selected_tower, selected_tower.cell_coord)

func _on_upgrade_tower_pressed(layer: int) -> void:
	var tower: Tower = _build_controller.selected_tower
	var upgrade_cost: int = tower.get_next_upgrade_cost() if tower != null and is_instance_valid(tower) else -1
	if _build_controller.upgrade_selected_tower(layer):
		_build_status.text = "Torre mejorada: +1 daño base y +1 %s · −%d oro." % [
			_hp_layer_name(layer),
			upgrade_cost,
		]
	else:
		_build_status.text = _build_controller.last_error
	_refresh_tower_controls()

func _on_demolish_tower_pressed() -> void:
	if _build_controller.demolish_selected_tower():
		_build_status.text = "Torre demolida. No se devuelve oro; baja el coste de la siguiente torre de ese tipo."
	else:
		_build_status.text = _build_controller.last_error
	_refresh_tower_controls()

func _on_tower_list_changed(_tower: Tower, _coord: Vector2i) -> void:
	_refresh_tower_controls()

func _on_tower_demolished(_tower_data: TowerData, _next_build_cost: int) -> void:
	_tower_status.text = "Torre: ninguna · pulsa 1–7 para construir"
	_refresh_tower_controls()

func _on_tower_selected(tower: Tower, _coord: Vector2i) -> void:
	if tower == null or not is_instance_valid(tower):
		return
	_tower_status.text = tower.get_summary()
	var priorities: Array[int] = tower.get_targeting_priorities()
	for slot in _tower_priority_selectors.size():
		var mode: int = priorities[slot] if slot < priorities.size() else -1
		var mode_index: int = _tower_priority_selectors[slot].get_item_index(mode)
		if mode_index >= 0:
			_tower_priority_selectors[slot].select(mode_index)
	_refresh_tower_controls()

func _on_tower_upgraded(tower: Tower, _new_level: int) -> void:
	_on_tower_selected(tower, tower.cell_coord)

func _refresh_tower_controls() -> void:
	var build_mode: bool = _build_controller.is_build_mode()
	var selected: Tower = _build_controller.selected_tower
	var waiting_for_terrain_card: bool = _awaiting_campaign_expansion and _selected_expansion_piece == null
	var can_build: bool = _build_controller.can_build_in_current_phase() and not waiting_for_terrain_card
	var is_run_ended: bool = RunManager.phase == RunManager.Phase.RUN_DEFEAT or RunManager.phase == RunManager.Phase.RUN_VICTORY
	for index in _tower_shortcut_buttons.size():
		var shortcut_button: Button = _tower_shortcut_buttons[index]
		var tower_data: TowerData = TOWER_PROFILES[index]
		var tower_unlocked: bool = bool(MetaProgression.call("is_tower_unlocked", tower_data))
		shortcut_button.visible = tower_unlocked
		var effective_mana_cost: float = tower_data.mana_cost_per_attack
		if effective_mana_cost > 0.0 and _run_card_service != null:
			effective_mana_cost *= float(_run_card_service.call("get_tower_mana_cost_multiplier", tower_data.id))
		var mana_suffix: String = ""
		if tower_data.mana_cost_per_second > 0.0:
			var mana_per_second: float = tower_data.mana_cost_per_second
			if _run_card_service != null:
				mana_per_second *= float(_run_card_service.call("get_tower_mana_cost_multiplier", tower_data.id))
			mana_suffix = " · %.1f maná/s" % mana_per_second
		elif effective_mana_cost > 0.0:
			mana_suffix = " · %.1f maná/ataque" % effective_mana_cost
		var build_cost: int = _build_controller.get_current_build_cost(tower_data)
		shortcut_button.text = "%d · %s\n%d oro" % [
			index + 1,
			TOWER_SHORT_NAMES[index],
			build_cost,
		]
		shortcut_button.tooltip_text = "%s\n%s · coste %d oro%s · %s" % [
			tower_data.display_name,
			tower_data.role_summary,
			build_cost,
			mana_suffix,
			_tower_attack_description(tower_data),
		]
		shortcut_button.add_theme_color_override("font_color", tower_data.visual_color)
		shortcut_button.disabled = not can_build or not bool(_run_economy.call("can_afford_gold", build_cost))
		shortcut_button.set_pressed_no_signal(
			build_mode and TOWER_PROFILES[index] == _selected_tower_data
		)
	_refresh_wave_option_states()
	_wave_selector.disabled = build_mode or not _can_start_wave() or is_run_ended
	_tower_actions.visible = selected != null and not build_mode
	_start_wave_button.disabled = (
		build_mode
		or not _path_graph.is_valid
		or not _can_start_selected_wave()
		or is_run_ended
	)
	for selector in _tower_priority_selectors:
		selector.disabled = build_mode or selected == null or not _build_controller.can_build_in_current_phase()
	var next_upgrade_cost: int = selected.get_next_upgrade_cost() if selected != null else -1
	for layer in _tower_upgrade_buttons.size():
		var upgrade_button: Button = _tower_upgrade_buttons[layer]
		if next_upgrade_cost >= 0:
			upgrade_button.text = "+%s · %d oro" % [_hp_layer_name(layer), next_upgrade_cost]
		else:
			upgrade_button.text = "+%s · máx." % _hp_layer_name(layer)
		upgrade_button.disabled = build_mode or selected == null or next_upgrade_cost < 0 or not bool(_run_economy.call("can_afford_gold", next_upgrade_cost)) or not _build_controller.can_build_in_current_phase()
	_demolish_tower_button.disabled = build_mode or selected == null or not _build_controller.can_build_in_current_phase()
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
			var effective_radius: float = tower_data.attack_area_radius_hexes
			if _run_card_service != null:
				effective_radius += float(_run_card_service.call("get_tower_area_radius_add", tower_data.id))
			return "área %.1f hex" % effective_radius
		TowerData.AttackPattern.CHAIN:
			return "hasta %d blancos" % tower_data.max_targets
		TowerData.AttackPattern.ALL_IN_RANGE:
			return "todos los enemigos en alcance"
		TowerData.AttackPattern.CONE:
			return "cono %.0f°" % tower_data.cone_angle_degrees
		TowerData.AttackPattern.SAWBLADE:
			return "hoja perforante por PATH"
		_:
			return "ataque no configurado"

func _hp_layer_name(layer: int) -> String:
	match layer:
		Enemy.HitPointLayer.HEALTH:
			return "vida"
		Enemy.HitPointLayer.ARMOR:
			return "armadura"
		Enemy.HitPointLayer.SHIELD:
			return "escudo"
		_:
			return "capa"

func _start_selected_wave() -> void:
	if RunManager.phase == RunManager.Phase.CARD_OFFER or not _path_graph.is_valid or not _can_start_selected_wave():
		return
	if _selected_wave_is_debug:
		_debug_return_phase = RunManager.phase
		if _debug_return_phase == RunManager.Phase.TERRAIN_EXPANSION:
			_selected_expansion_piece = null
			_terrain_card_panel.hide()
	elif _selected_wave == null or _selected_wave.round_number != _campaign_round_number:
		return
	_terrain_card_panel.hide()
	_upgrade_card_panel.hide()
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
		_damage_service,
		DEMO_CAMPAIGN if not _selected_wave_is_debug else null,
		_selected_wave_is_debug
	):
		_placement_enabled = false
		if _selected_wave_is_debug and _debug_return_phase == RunManager.Phase.TERRAIN_EXPANSION and _awaiting_campaign_expansion:
			_present_terrain_card_offer()
		_refresh_placement()
		_wave_status.text = "No se pudo iniciar: %s" % _wave_director.last_error
		_refresh_tower_controls()

func _on_wave_started(round_number: int) -> void:
	RunManager.transition_to(RunManager.Phase.COMBAT)
	var round_label: String = "prueba de diagnóstico" if _selected_wave_is_debug else "ronda %d/20" % round_number
	_wave_status.text = "%s · %s · preparando spawns…" % [_active_wave_name, round_label]
	_refresh_tower_controls()

func _on_wave_completed(round_number: int) -> void:
	_reward_transition_token += 1
	var transition_token: int = _reward_transition_token
	RunManager.transition_to(RunManager.Phase.ROUND_REWARD)
	if _build_controller.is_build_mode():
		_build_controller.cancel_build_mode()
	var completed_wave: WaveData = _selected_wave
	var was_debug_wave: bool = _selected_wave_is_debug
	var return_phase: int = _debug_return_phase
	var round_reward: int = completed_wave.round_reward if completed_wave != null and not was_debug_wave else 0
	_wave_status.text = "%s completada · ronda %d · +%d oro · procesando recompensa…" % [
		_active_wave_name,
		round_number,
		round_reward,
	]
	_start_wave_button.text = "Procesando recompensa…"
	_refresh_tower_controls()
	await get_tree().create_timer(0.8).timeout
	if transition_token != _reward_transition_token or RunManager.phase != RunManager.Phase.ROUND_REWARD:
		return
	if was_debug_wave:
		_placement_enabled = false
		if return_phase == RunManager.Phase.TERRAIN_EXPANSION:
			RunManager.transition_to(RunManager.Phase.TERRAIN_EXPANSION)
			if _awaiting_campaign_expansion:
				_present_terrain_card_offer()
		else:
			RunManager.transition_to(RunManager.Phase.ROUND_PREP)
		_wave_status.text = "Prueba de diagnóstico completada · campaña detenida en ronda %d/20" % _campaign_round_number
		_start_wave_button.text = "▶ Iniciar prueba"
	else:
		_selected_wave_is_debug = false
		if round_number >= 20:
			_placement_enabled = false
			_awaiting_campaign_expansion = false
			RunManager.transition_to(RunManager.Phase.RUN_VICTORY)
			_wave_status.text = "¡DEMO COMPLETADA! · 20/20 rondas superadas · +%d oro" % round_reward
			_start_wave_button.text = "DEMO COMPLETADA"
			_show_run_end(&"VICTORY", round_number)
		else:
			_placement_enabled = false
			_awaiting_campaign_expansion = true
			_pending_expansion_round = round_number
			_pending_expansion_reward = round_reward
			_begin_campaign_terrain_expansion(round_number, round_reward)
	_refresh_placement()
	_refresh_tower_controls()

func _on_wave_failed(reason: String) -> void:
	_build_controller.cancel_build_mode()
	if _selected_wave_is_debug:
		_placement_enabled = false
		if _debug_return_phase == RunManager.Phase.TERRAIN_EXPANSION:
			RunManager.transition_to(RunManager.Phase.TERRAIN_EXPANSION)
			if _awaiting_campaign_expansion:
				_present_terrain_card_offer()
		else:
			RunManager.transition_to(RunManager.Phase.ROUND_PREP)
		_wave_status.text = "Diagnóstico detenido · %s · campaña en ronda %d/20" % [reason, _campaign_round_number]
	else:
		_placement_enabled = false
		_start_wave_button.disabled = true
		_wave_status.text = "DERROTA · %s" % reason
		RunManager.transition_to(RunManager.Phase.RUN_DEFEAT)
		_show_run_end(&"DEFEAT", _campaign_round_number)
	_refresh_placement()
	_refresh_tower_controls()

func _on_enemy_count_changed(alive_count: int) -> void:
	if RunManager.phase == RunManager.Phase.COMBAT:
		_wave_status.text = "%s · enemigos en ruta: %d" % [_active_wave_name, alive_count]

func _on_population_changed(pending_count: int, alive_count: int) -> void:
	if RunManager.phase == RunManager.Phase.COMBAT:
		_wave_status.text = "%s · pendientes: %d · en ruta: %d" % [
			_active_wave_name,
			pending_count,
			alive_count,
		]

func _can_start_wave() -> bool:
	return RunManager.phase == RunManager.Phase.ROUND_PREP or RunManager.phase == RunManager.Phase.TERRAIN_EXPANSION

func _can_start_selected_wave() -> bool:
	if _selected_wave_is_debug:
		return _can_start_wave()
	return (
		_campaign_is_valid
		and RunManager.phase == RunManager.Phase.ROUND_PREP
		and not _awaiting_campaign_expansion
		and _selected_wave != null
		and _selected_wave.round_number == _campaign_round_number
	)

func _refresh_wave_option_states() -> void:
	for round_index in range(20):
		_wave_selector.set_item_disabled(
			round_index,
			round_index + 1 != _campaign_round_number or RunManager.phase != RunManager.Phase.ROUND_PREP
		)
	var diagnostics_available: bool = _can_start_wave() and RunManager.phase != RunManager.Phase.RUN_DEFEAT and RunManager.phase != RunManager.Phase.RUN_VICTORY
	_wave_selector.set_item_disabled(20, not diagnostics_available)
	_wave_selector.set_item_disabled(21, not diagnostics_available)

func _get_campaign_round(round_number: int) -> WaveData:
	var wave: Variant = DEMO_CAMPAIGN.call("get_round", round_number)
	return wave as WaveData if wave is WaveData else null

func _get_wave_enemy_count(wave: WaveData) -> int:
	if wave == null:
		return 0
	var total: int = 0
	for group in wave.groups:
		if group != null:
			total += group.count
	var route_count: int = _get_reachable_spawn_route_count()
	return total * maxi(route_count, 1)

func _get_reachable_spawn_route_count() -> int:
	if _path_graph == null:
		return 0
	var route_count: int = 0
	for route in _path_graph.routes:
		if route != null and route.is_reachable:
			route_count += 1
	return route_count

func _encounter_label(wave: WaveData) -> String:
	if wave == null:
		return "sin datos"
	match wave.encounter_type:
		WaveData.EncounterType.MINIBOSS:
			return "minijefe"
		WaveData.EncounterType.TIER_2_BOSS:
			return "jefe Tier 2"
		_:
			return "normal"

func _set_campaign_wave_name() -> void:
	if _selected_wave == null:
		_active_wave_name = "Ronda %02d/20" % _campaign_round_number
		return
	_active_wave_name = "Ronda %02d/20 · %s" % [_campaign_round_number, _encounter_label(_selected_wave)]

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
	var estimate: Variant = _damage_service.call("preview_damage", target, tower.create_damage_packet(false))
	var status_summaries: PackedStringArray = target.get_active_status_summaries()
	var status_text: String = "Estados: —" if status_summaries.is_empty() else "Estados: %s" % " · ".join(status_summaries)
	var tower_data: TowerData = tower.get_tower_data()
	var damage_tag_name: String = tower.get_damage_tag_name(tower_data.damage_tags)
	var mana_text: String = ""
	if tower.get_mana_cost_per_attack() > 0.0:
		mana_text = " · sin maná" if tower.is_mana_blocked() else " · %.1f maná/ataque" % tower.get_mana_cost_per_attack()
	var active_layer: int = target.get_active_hit_point_layer()
	var damage_summary: String = "impacto %d %s · %s" % [
		int(estimate.get("total_damage")),
		damage_tag_name,
		_hp_layer_name(active_layer),
	]
	if tower_data.attack_pattern == TowerData.AttackPattern.SAWBLADE:
		var blade_damage: int = tower.get_current_damage()
		damage_summary = "hoja base %d · impacto estimado %d · Bleed %d" % [
			blade_damage,
			int(estimate.get("total_damage")),
			blade_damage,
		]
	_combat_debug.text = "%s · Esc %d/%d · Arm %d/%d · Vida %d/%d · regen E/A/V %.1f/%.1f/%.1f/s · %s%s\n%s" % [
		target.get_display_name(),
		target.get_shield_value(),
		target.get_maximum_shield(),
		target.get_armor_value(),
		target.get_maximum_armor(),
		target.get_current_health(),
		target.get_maximum_health(),
		target.get_shield_regen_per_second(),
		target.get_armor_regen_per_second(),
		target.get_regen_per_second(),
		damage_summary,
		mana_text,
		status_text,
	]

func _on_base_health_changed(current_health: int, maximum_health: int) -> void:
	_base_status.text = "Base · vida %d / %d" % [current_health, maximum_health]
	if current_health <= 0:
		_base_status.text += " · DESTRUIDA"

func _show_run_end(outcome: StringName, reached_round: int) -> void:
	if _meta_shop_panel == null:
		return
	var summary: Dictionary = MetaProgression.call("finish_run", outcome, reached_round, GameState.run_seed)
	_meta_shop_panel.call("present", summary)

func _on_new_run_requested() -> void:
	get_tree().reload_current_scene()

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

func _present_terrain_card_offer() -> void:
	if _offered_terrain_pieces.is_empty():
		var candidates: Array[TerrainPieceData] = []
		candidates.append_array(_pieces)
		for index in range(candidates.size() - 1, 0, -1):
			var swap_index: int = _terrain_rng.randi_range(0, index)
			var piece_to_swap: TerrainPieceData = candidates[index]
			candidates[index] = candidates[swap_index]
			candidates[swap_index] = piece_to_swap
		for index in range(mini(_terrain_card_buttons.size(), candidates.size())):
			_offered_terrain_pieces.append(candidates[index])
	if _offered_terrain_pieces.size() != _terrain_card_buttons.size():
		push_error("La expansión necesita tres piezas de terreno diferentes para ofrecer.")
		return

	for index in _terrain_card_buttons.size():
		var piece: TerrainPieceData = _offered_terrain_pieces[index]
		_terrain_card_buttons[index].text = ""
		_terrain_card_buttons[index].tooltip_text = ""
		_terrain_card_buttons[index].disabled = false
		_terrain_card_buttons[index].set_pressed_no_signal(false)
		_terrain_card_titles[index].text = piece.display_name
		_terrain_card_previews[index].call("set_piece", piece)
	_set_terrain_card_layout(false)
	_terrain_card_panel.show()
	_placement_enabled = false
	_selected_expansion_piece = null
	_selected_piece = null
	_piece_selector.select(0)
	_refresh_placement()
	_start_wave_button.disabled = true
	_start_wave_button.text = "Elige terreno para continuar"
	_refresh_tower_controls()

func _begin_campaign_terrain_expansion(round_number: int, round_reward: int) -> void:
	_upgrade_card_panel.hide()
	_placement_enabled = false
	_awaiting_campaign_expansion = true
	RunManager.transition_to(RunManager.Phase.TERRAIN_EXPANSION)
	_wave_status.text = "Ronda %d/20 completada · +%d oro · elige una de tres piezas para desbloquear la ronda %d" % [
		round_number,
		round_reward,
		round_number + 1,
	]
	_present_terrain_card_offer()

func _present_upgrade_card_offer(round_number: int, cards: Array[Resource]) -> void:
	if cards.size() != _upgrade_card_buttons.size():
		push_error("La oferta M11 debe coincidir con el número de cards visibles.")
		return
	if _build_controller.is_build_mode():
		_build_controller.cancel_build_mode()
	_upgrade_card_heading.text = "MEJORAS DE RUN · RONDA %02d" % round_number
	for index in _upgrade_card_buttons.size():
		var card: Resource = cards[index]
		_upgrade_card_titles[index].text = String(card.get("display_name"))
		_upgrade_card_descriptions[index].text = String(card.get("description"))
		_upgrade_card_rarities[index].text = _card_rarity_name(int(card.get("rarity")))
		_upgrade_card_buttons[index].tooltip_text = String(card.get("description"))
		_style_upgrade_card_button(_upgrade_card_buttons[index], int(card.get("rarity")))
	_upgrade_card_panel.show()
	_terrain_card_panel.hide()
	_placement_enabled = false
	_selected_expansion_piece = null
	_selected_piece = null
	_latest_placement = null
	_piece_selector.select(0)
	_refresh_placement()
	RunManager.transition_to(RunManager.Phase.CARD_OFFER)
	_wave_status.text = "Ronda %d/20 completada · +%d oro · elige una mejora para la run" % [
		round_number,
		_pending_expansion_reward,
	]
	_start_wave_button.disabled = true
	_start_wave_button.text = "Elige una carta de mejora"
	_refresh_tower_controls()

func _on_upgrade_card_selected(index: int) -> void:
	if RunManager.phase != RunManager.Phase.CARD_OFFER:
		return
	if not bool(_run_card_service.call("select_card", index)):
		push_error("No se pudo seleccionar la carta: %s" % _run_card_service.get("last_error"))
		return
	_upgrade_card_panel.hide()
	_prepare_next_campaign_round()
	_refresh_tower_controls()

func _prepare_next_campaign_round() -> void:
	_campaign_round_number += 1
	_selected_wave = _get_campaign_round(_campaign_round_number)
	_selected_wave_is_debug = false
	if _selected_wave == null:
		_wave_status.text = "Error: no existe la ronda %d de la campaña." % _campaign_round_number
		push_error(_wave_status.text)
		return
	_wave_selector.select(_campaign_round_number - 1)
	_set_campaign_wave_name()
	RunManager.transition_to(RunManager.Phase.ROUND_PREP)
	_wave_status.text = "Preparación · ronda %d/20 · %d enemigos" % [
		_campaign_round_number,
		_get_wave_enemy_count(_selected_wave),
	]
	_start_wave_button.text = "▶ Iniciar ronda %d/20" % _campaign_round_number
	_refresh_placement()
	_refresh_tower_controls()

func _card_rarity_name(rarity: int) -> String:
	match rarity:
		1:
			return "POCO COMÚN"
		2:
			return "RARA"
		_:
			return "COMÚN"

func _style_upgrade_card_button(button: Button, rarity: int) -> void:
	var accent: Color = Color("8bb89f")
	if rarity == 1:
		accent = Color("84b8d5")
	elif rarity == 2:
		accent = Color("d1ab62")
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color("202b34")
	normal_style.border_color = accent.darkened(0.18)
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(10)
	normal_style.content_margin_left = 14.0
	normal_style.content_margin_right = 14.0
	normal_style.content_margin_top = 12.0
	normal_style.content_margin_bottom = 12.0
	var hover_style: StyleBoxFlat = normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color("2a3a45")
	hover_style.border_color = accent.lightened(0.1)
	var pressed_style: StyleBoxFlat = hover_style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = Color("344b56")
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", hover_style)

func _create_upgrade_card_panel() -> void:
	_upgrade_card_panel = PanelContainer.new()
	_upgrade_card_panel.name = "UpgradeCardPanelRuntime"
	_upgrade_card_panel.anchor_left = 0.5
	_upgrade_card_panel.anchor_right = 0.5
	_upgrade_card_panel.anchor_top = 0.5
	_upgrade_card_panel.anchor_bottom = 0.5
	_upgrade_card_panel.offset_left = -500.0
	_upgrade_card_panel.offset_top = -195.0
	_upgrade_card_panel.offset_right = 500.0
	_upgrade_card_panel.offset_bottom = 195.0
	_upgrade_card_panel.custom_minimum_size = Vector2(1000.0, 390.0)
	_upgrade_card_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_upgrade_card_panel.z_index = 20
	_upgrade_card_panel.hide()
	_hud.add_child(_upgrade_card_panel)
	var background := StyleBoxFlat.new()
	background.bg_color = Color("121a20")
	background.border_color = Color("556a72")
	background.set_border_width_all(2)
	background.set_corner_radius_all(12)
	background.content_margin_left = 18.0
	background.content_margin_right = 18.0
	background.content_margin_top = 14.0
	background.content_margin_bottom = 14.0
	_upgrade_card_panel.add_theme_stylebox_override("panel", background)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_upgrade_card_panel.add_child(content)
	_upgrade_card_heading = Label.new()
	_upgrade_card_heading.text = "MEJORAS DE RUN"
	_upgrade_card_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_upgrade_card_heading.add_theme_font_size_override("font_size", 21)
	content.add_child(_upgrade_card_heading)
	var subtitle := Label.new()
	subtitle.text = "Elige una carta. Sus efectos se mantienen durante esta run."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color("aebbc0"))
	content.add_child(subtitle)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(row)
	var offer_card_count: int = maxi(int(DEMO_CARD_POOL.get("offer_size")), 1)
	for index in offer_card_count:
		var card_button := Button.new()
		card_button.name = "UpgradeCard%d" % (index + 1)
		card_button.custom_minimum_size = Vector2(300.0, 260.0)
		card_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card_button.text = ""
		card_button.mouse_filter = Control.MOUSE_FILTER_STOP
		row.add_child(card_button)
		var card_content := VBoxContainer.new()
		card_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		card_content.add_theme_constant_override("separation", 12)
		card_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_button.add_child(card_content)
		var rarity_label := Label.new()
		rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rarity_label.add_theme_font_size_override("font_size", 12)
		rarity_label.add_theme_color_override("font_color", Color("aac1c6"))
		rarity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_content.add_child(rarity_label)
		var title_label := Label.new()
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_label.add_theme_font_size_override("font_size", 20)
		title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_content.add_child(title_label)
		var description_label := Label.new()
		description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		description_label.add_theme_font_size_override("font_size", 15)
		description_label.add_theme_color_override("font_color", Color("d3dcdf"))
		description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_content.add_child(description_label)
		_upgrade_card_buttons.append(card_button)
		_upgrade_card_titles.append(title_label)
		_upgrade_card_descriptions.append(description_label)
		_upgrade_card_rarities.append(rarity_label)

func _on_terrain_card_selected(index: int) -> void:
	if (
		index < 0
		or index >= _offered_terrain_pieces.size()
		or not _awaiting_campaign_expansion
		or RunManager.phase != RunManager.Phase.TERRAIN_EXPANSION
	):
		return
	if _build_controller.is_build_mode():
		_build_controller.cancel_build_mode()
		_refresh_build_preview()
	_selected_expansion_piece = _offered_terrain_pieces[index]
	_selected_piece = _selected_expansion_piece
	_rotation_steps = 0
	_placement_enabled = true
	_piece_selector.select(_pieces.find(_selected_piece) + 1)
	_piece_status.text = _piece_summary(_selected_piece)
	for card_index in _terrain_card_buttons.size():
		_terrain_card_buttons[card_index].set_pressed_no_signal(card_index == index)
	_set_terrain_card_layout(true)
	_terrain_card_panel.show()
	_wave_status.text = "Expansión · %s seleccionada · coloca una posición válida" % _selected_piece.display_name
	_start_wave_button.disabled = true
	_start_wave_button.text = "Coloca terreno para continuar"
	_refresh_placement()
	_refresh_tower_controls()

func _return_to_terrain_card_offer() -> void:
	_selected_expansion_piece = null
	_selected_piece = null
	_latest_placement = null
	_placement_enabled = false
	_piece_selector.select(0)
	_present_terrain_card_offer()

func _set_terrain_card_layout(is_inventory: bool) -> void:
	_terrain_card_panel.anchor_left = 0.5
	_terrain_card_panel.anchor_right = 0.5
	if is_inventory:
		_terrain_card_panel.anchor_top = 1.0
		_terrain_card_panel.anchor_bottom = 1.0
		_terrain_card_panel.offset_left = -310.0
		_terrain_card_panel.offset_top = -258.0
		_terrain_card_panel.offset_right = 310.0
		_terrain_card_panel.offset_bottom = -104.0
		_terrain_card_panel.custom_minimum_size = Vector2(620.0, 154.0)
	else:
		_terrain_card_panel.anchor_top = 0.5
		_terrain_card_panel.anchor_bottom = 0.5
		_terrain_card_panel.offset_left = -390.0
		_terrain_card_panel.offset_top = -170.0
		_terrain_card_panel.offset_right = 390.0
		_terrain_card_panel.offset_bottom = 170.0
		_terrain_card_panel.custom_minimum_size = Vector2(780.0, 340.0)
	var margin: MarginContainer = _terrain_card_panel.get_node("Margin") as MarginContainer
	margin.add_theme_constant_override("margin_left", 10 if is_inventory else 18)
	margin.add_theme_constant_override("margin_right", 10 if is_inventory else 18)
	margin.add_theme_constant_override("margin_top", 8 if is_inventory else 14)
	margin.add_theme_constant_override("margin_bottom", 8 if is_inventory else 14)
	var card_size: Vector2 = Vector2(184.0, 126.0) if is_inventory else Vector2(232.0, 278.0)
	var preview_size: Vector2 = Vector2(168.0, 82.0) if is_inventory else Vector2(208.0, 230.0)
	for index in _terrain_card_buttons.size():
		_terrain_card_buttons[index].custom_minimum_size = card_size
		_terrain_card_previews[index].custom_minimum_size = preview_size
		_terrain_card_titles[index].add_theme_font_size_override("font_size", 14 if is_inventory else 18)

func _style_terrain_card_button(button: Button) -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.10, 0.14, 0.16, 0.98)
	normal_style.border_color = Color(0.37, 0.47, 0.49, 1.0)
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(10)
	normal_style.content_margin_left = 8.0
	normal_style.content_margin_top = 8.0
	normal_style.content_margin_right = 8.0
	normal_style.content_margin_bottom = 8.0
	var hover_style := normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(0.15, 0.21, 0.22, 1.0)
	hover_style.border_color = Color(0.70, 0.84, 0.75, 1.0)
	var selected_style := normal_style.duplicate() as StyleBoxFlat
	selected_style.bg_color = Color(0.16, 0.22, 0.19, 1.0)
	selected_style.border_color = Color(0.94, 0.78, 0.34, 1.0)
	selected_style.set_border_width_all(3)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", selected_style)

func _on_preview_hover_changed(local_coord: Vector2i, terrain_type: int, elevation: int) -> void:
	_hovered_coord = local_coord
	_has_hovered_cell = true
	_base.set_hovered(local_coord == _base_coord)
	_hover_status.text = "Casilla del tablero (q,r): (%d, %d) · %s · h%d" % [
		local_coord.x,
		local_coord.y,
		_terrain_display_name(terrain_type),
		elevation,
	]
	_refresh_build_preview()

func _on_preview_hover_cleared() -> void:
	_has_hovered_cell = false
	_base.set_hovered(false)
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
