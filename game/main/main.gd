extends Node2D

const HEX_RADIUS: float = 52.0
const CAMPAIGN_ROUND_COUNT: int = 45
const DEBUG_WAVE_START_INDEX: int = CAMPAIGN_ROUND_COUNT
const ELEVATION_PIXEL_OFFSET: float = 18.0
const STARTING_BOARD: Resource = preload("res://data/terrain/starting_board.tres")
const STRAIGHT_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/straight.tres")
const GENTLE_TURN_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/gentle_turn.tres")
const HARD_TURN_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/hard_turn.tres")
const FORK_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/fork.tres")
const CONVERGENCE_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/convergence.tres")
const MEADOW_HILLS_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/meadow_hills.tres")
const MOUNTAIN_MASSIF_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/mountain_massif.tres")
const OPEN_GRASSLAND_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/open_grassland.tres")
const STAGGERED_RIDGE_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/staggered_ridge.tres")
const MOUNTAIN_ISLET_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/mountain_islet.tres")
const TWIN_PEAKS_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/twin_peaks.tres")
const DEAD_END_SPUR_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/dead_end_spur.tres")
const CLIFF_TURN_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/cliff_turn.tres")
const MEADOW_SWITCHBACK_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/meadow_switchback.tres")
const THREE_WAY_RAVINE_PIECE: TerrainPieceData = preload("res://data/terrain/pieces/three_way_ravine.tres")
const FIRST_WAVE: WaveData = preload("res://data/waves/round_01.tres")
const DEMO_CAMPAIGN: Resource = preload("res://data/waves/demo_campaign.tres")
const M7_DAMAGE_TEST_WAVE: WaveData = preload("res://data/waves/m7_damage_test.tres")
const M8_STATUS_TEST_WAVE: WaveData = preload("res://data/waves/m8_status_test.tres")
const TOWER_LAYER_TEST_WAVE: WaveData = preload("res://data/waves/tower_layer_training_wave.tres")
const RUN_ECONOMY_DATA: Resource = preload("res://data/run/run_economy_m9.tres")
const DEMO_CARD_POOL: Resource = preload("res://data/cards/demo_card_pool.tres")
const META_SHOP_PANEL_SCRIPT: Script = preload("res://game/progression/meta_shop_panel.gd")
const DEBUG_HACKS_PANEL_SCRIPT: Script = preload("res://game/ui/debug_hacks_panel.gd")
const HUD_STYLE_SCRIPT: Script = preload("res://game/ui/rogue_hud_style.gd")
const ICON_CATALOG_SCRIPT: Script = preload("res://game/ui/icon_catalog.gd")
const IMPACT_VFX_SCRIPT: Script = preload("res://game/vfx/animated_impact.gd")
const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")
const TOWER_CARD_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui/tower_card_button.png")
const TERRAIN_EXPANSION_CARD_TEXTURE: Texture2D = preload("res://assets/ui/terrain_expansion_card_frame.png")
const START_ROUND_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui/start_round_button.png")
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
const MIN_CAMERA_ZOOM: float = 0.45
const MAX_CAMERA_ZOOM: float = 2.5
const CAMERA_ZOOM_STEP: float = 1.12
const CURSOR_DEFAULT_PATH: String = "res://assets/third_party/tiny_swords/cursors/Cursor_01.png"
const CURSOR_INTERACT_PATH: String = "res://assets/third_party/tiny_swords/cursors/Cursor_02.png"
const CURSOR_INVALID_PATH: String = "res://assets/third_party/tiny_swords/cursors/Cursor_03.png"
const CURSOR_BUILD_PATH: String = "res://assets/third_party/tiny_swords/cursors/Cursor_04.png"

enum CursorKind { DEFAULT, INTERACT, INVALID, TOWER_PLACEMENT }

var _board_grid := HexGrid.new()
var _pieces: Array[TerrainPieceData] = []
var _selected_piece: TerrainPieceData
var _rotation_steps: int = 0
var _anchor_coord: Vector2i = Vector2i.ZERO
var _next_piece_instance_id: int = 1
var _latest_placement: TerrainPlacementResult
var _placement_path_graph: PathGraph
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
var _run_seed: int = 0
var _chest_spawn_chance: float = TERRAIN_VISUAL_CATALOG_SCRIPT.BASE_CHEST_CHANCE
var _offered_terrain_pieces: Array[TerrainPieceData] = []
var _selected_expansion_piece: TerrainPieceData
var _pending_expansion_round: int = 0
var _pending_expansion_reward: int = 0
var _upgrade_card_buttons: Array[Button] = []
var _upgrade_card_titles: Array[RichTextLabel] = []
var _upgrade_card_descriptions: Array[RichTextLabel] = []
var _upgrade_card_rarities: Array[Label] = []
var _upgrade_card_tower_icons: Array[TextureRect] = []
var _upgrade_card_panel: PanelContainer
var _upgrade_card_heading: Label
var _meta_shop_panel: CanvasLayer
var _hud_style: RefCounted
var _icon_catalog: RefCounted
var _gold_feedback_tween: Tween
var _cursor_textures: Dictionary[int, Texture2D] = {}
var _current_cursor_kind: int = -1
var _hovered_interactable_control: Control
var _tower_shortcut_names: Array[Label] = []
var _tower_shortcut_prices: Array[Label] = []
var _tower_shortcut_icons: Array[TextureRect] = []
var _tower_shortcut_icon_tweens: Dictionary[int, Tween] = {}
var _tower_upgrade_amounts: Array[Label] = []
var _tower_upgrade_effect_labels: Array[Label] = []
var _tower_upgrade_cost_icons: Array[TextureRect] = []
var _tower_upgrade_layer_icons: Array[TextureRect] = []
var _tower_upgrade_level_labels: Array[Label] = []
var _tower_upgrade_xp_labels: Array[Label] = []
var _tower_upgrade_xp_bars: Array[ProgressBar] = []
var _tower_card_pulse_tween: Tween
var _tower_card_pulsing_index: int = -1
var _hovered_tower: Tower
var _debug_hacks_panel: CanvasLayer
var _visible_target_priority_count: int = 1
var _priority_visibility_tower_instance_id: int = 0

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
@onready var _round_panel: PanelContainer = %RoundPanel
@onready var _tower_info_panel: PanelContainer = %TowerInfoPanel
@onready var _tower_info_content: VBoxContainer = %TowerInfoContent
@onready var _tower_portrait: TextureRect = %TowerPortrait
@onready var _hud: CanvasLayer = %HUD
@onready var _build_cursor_overlay: TextureRect = %BuildCursor
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
@onready var _terrain_card_counts: Array[Label] = [
	%CardCount1,
	%CardCount2,
	%CardCount3,
]
@onready var _terrain_card_previews: Array[Control] = [
	%CardPreview1,
	%CardPreview2,
	%CardPreview3,
]
@onready var _tower_toolbar: MarginContainer = %TowerToolbar
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
@onready var _base_health_bar: Control = %BaseHealthBar
@onready var _base_status: Label = %BaseStatus
@onready var _resources_row: Control = %ResourcesRow
@onready var _gold_icon: TextureRect = %GoldIcon
@onready var _gold_group: HBoxContainer = %GoldGroup
@onready var _gold_status: Label = %GoldStatus
@onready var _mana_icon: TextureRect = %ManaIcon
@onready var _mana_status: Label = %ManaStatus
@onready var _wave_status: RichTextLabel = %WaveStatus
@onready var _round_progress: Control = %RoundProgress
@onready var _start_wave_button: Button = %StartWave
@onready var _build_controller: BuildController = %BuildController
@onready var _build_status: RichTextLabel = %BuildStatus
@onready var _tower_status: RichTextLabel = %TowerStatus
@onready var _combat_debug: RichTextLabel = %CombatDebug
@onready var _tower_actions: VBoxContainer = %TowerActions
@onready var _tower_priority_buttons: Array[OptionButton] = [
	%TowerPriority1,
	%TowerPriority2,
	%TowerPriority3,
]
@onready var _tower_priority_rows: Array[Control] = [
	%PrioritySlot1,
	%PrioritySlot2,
	%PrioritySlot3,
]
@onready var _tower_priority_add_button: Button = %AddPriority
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
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_base_coord = STARTING_BOARD.get("base_coord")
	MetaProgression.call("configure_tower_catalog", TOWER_PROFILES)
	MetaProgression.call("set_debug_unlock_all_enabled", false)
	var current_run_seed: int = int(MetaProgression.call("begin_run"))
	_run_seed = current_run_seed
	_chest_spawn_chance = float(MetaProgression.call("get_chest_spawn_chance"))
	GameState.run_seed = current_run_seed
	GameState.current_round = 1
	_terrain_rng.seed = current_run_seed
	var run_number: int = int(MetaProgression.call("get_total_runs_started"))
	var starting_board_rotation_steps: int = posmod(run_number - 1, HexCoord.DIRECTION_OFFSETS.size())
	_camera.position = get_viewport_rect().size * 0.5
	_camera.make_current()
	_pieces = [
		STRAIGHT_PIECE, GENTLE_TURN_PIECE, HARD_TURN_PIECE, FORK_PIECE, CONVERGENCE_PIECE,
		MEADOW_HILLS_PIECE, MOUNTAIN_MASSIF_PIECE, OPEN_GRASSLAND_PIECE, STAGGERED_RIDGE_PIECE,
		MOUNTAIN_ISLET_PIECE, TWIN_PEAKS_PIECE, DEAD_END_SPUR_PIECE, CLIFF_TURN_PIECE,
		MEADOW_SWITCHBACK_PIECE, THREE_WAY_RAVINE_PIECE,
	]
	_rotate_left.pressed.connect(_rotate_by.bind(-1))
	_rotate_right.pressed.connect(_rotate_by.bind(1))
	_hud_style = HUD_STYLE_SCRIPT.new() as RefCounted
	_hud_style.call("apply_to_tree", _hud)
	_configure_hud_visuals()
	_configure_cursors()
	_configure_hud_tooltips()
	for index in _terrain_card_buttons.size():
		_terrain_card_buttons[index].pressed.connect(_on_terrain_card_selected.bind(index))
		_style_terrain_card_button(_terrain_card_buttons[index])
	_create_upgrade_card_panel()
	_hud_style.call("apply_to_tree", _upgrade_card_panel)
	_meta_shop_panel = META_SHOP_PANEL_SCRIPT.new() as CanvasLayer
	_meta_shop_panel.call(
		"configure",
		TOWER_PROFILES,
		MetaProgression.call("get_permanent_upgrades")
	)
	add_child(_meta_shop_panel)
	_wire_interactable_cursors(_meta_shop_panel)
	_meta_shop_panel.connect("new_run_requested", _on_new_run_requested)
	_debug_hacks_panel = DEBUG_HACKS_PANEL_SCRIPT.new() as CanvasLayer
	add_child(_debug_hacks_panel)
	_hud_style.call("apply_to_tree", _debug_hacks_panel)
	_debug_hacks_panel.connect("action_requested", _on_debug_hack_requested)
	_debug_hacks_panel.call("set_unlock_status", bool(MetaProgression.call("is_debug_unlock_all_enabled")))
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
	_build_controller.tower_built.connect(_on_tower_built_for_vfx)
	_build_controller.tower_demolished.connect(_on_tower_demolished)
	_build_controller.tower_upgraded.connect(_on_tower_upgraded)
	_build_controller.build_mode_changed.connect(_on_build_mode_changed)
	for slot in _tower_priority_buttons.size():
		_tower_priority_buttons[slot].item_selected.connect(_on_targeting_priority_selected.bind(slot))
	_tower_priority_add_button.pressed.connect(_on_add_targeting_priority_pressed)
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
	_damage_service.connect(&"damage_resolved", _on_damage_resolved)
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
	for cell_variant in starting_cells.values():
		TERRAIN_VISUAL_CATALOG_SCRIPT.set_random_cell_contents(cell_variant as HexCell, _run_seed, _chest_spawn_chance)
	_path_graph.rebuild(_board_grid.cells, _base_coord, int(STARTING_BOARD.get("minimum_spawn_route_cells")))
	if not _path_graph.is_valid:
		push_error("Grafo PATH inicial inválido: %s" % "; ".join(_path_graph.errors))

	_piece_preview.set_decoration_parent(_entities)
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
	_wave_status.text = "Preparación · ronda 1/45 · %d enemigos" % _get_wave_enemy_count(FIRST_WAVE)
	RunManager.transition_to(RunManager.Phase.ROUND_PREP)
	var permanent_economy_bonuses: Dictionary = MetaProgression.call("get_run_economy_bonuses")
	if not bool(_run_economy.call("configure", RUN_ECONOMY_DATA, permanent_economy_bonuses)):
		push_error("No se pudo iniciar la economía de run: %s" % _run_economy.get("last_error"))
	_refresh_tower_controls()
	_refresh_path_status()
	_round_progress.call("set_progress", _campaign_round_number, 0)
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
	_refresh_pointer_cursor()
	if _is_panning or not _placement_enabled or _build_controller.is_build_mode():
		return
	_update_anchor_from_mouse()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var debug_key := event as InputEventKey
		if debug_key.pressed and not debug_key.echo and debug_key.ctrl_pressed and debug_key.keycode == KEY_K:
			_toggle_debug_hacks()
			get_viewport().set_input_as_handled()
			return
		if _debug_hacks_panel != null and _debug_hacks_panel.visible:
			if debug_key.pressed and not debug_key.echo and debug_key.keycode == KEY_ESCAPE:
				_debug_hacks_panel.hide()
			get_viewport().set_input_as_handled()
			return
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
	_refresh_tower_controls()

func _toggle_debug_hacks() -> void:
	if _debug_hacks_panel == null:
		return
	_debug_hacks_panel.visible = not _debug_hacks_panel.visible
	if _debug_hacks_panel.visible:
		_debug_hacks_panel.call("set_unlock_status", bool(MetaProgression.call("is_debug_unlock_all_enabled")))

func _on_debug_hack_requested(action_id: StringName) -> void:
	match action_id:
		&"add_gold":
			_run_economy.call("add_gold", 1000, &"debug")
		&"add_mana":
			_run_economy.call("debug_add_mana", 100.0)
		&"refill_mana":
			_run_economy.call("refill_mana_to_max")
		&"heal_base":
			_base.heal(_base.get_maximum_health())
		&"toggle_unlocks":
			var unlock_all: bool = not bool(MetaProgression.call("is_debug_unlock_all_enabled"))
			MetaProgression.call("set_debug_unlock_all_enabled", unlock_all)
			_run_card_service.call("set_debug_unlock_all_enabled", unlock_all)
			_debug_hacks_panel.call("set_unlock_status", unlock_all)
			_refresh_tower_controls()
		&"start_wave":
			_start_selected_wave()
		&"restart_run":
			_on_new_run_requested()
	_refresh_tower_controls()

func _configure_hud_visuals() -> void:
	_icon_catalog = ICON_CATALOG_SCRIPT.new() as RefCounted
	_gold_icon.texture = _icon_catalog.call("get_icon", &"gold") as Texture2D
	_mana_icon.texture = _icon_catalog.call("get_icon", &"mana") as Texture2D
	_style_start_wave_button()
	_configure_tower_shortcut_visuals()
	_configure_tower_upgrade_visuals()
	_gold_group.pivot_offset = _gold_group.size * 0.5

func _configure_cursors() -> void:
	var cursor_paths: Array[String] = [
		CURSOR_DEFAULT_PATH,
		CURSOR_INTERACT_PATH,
		CURSOR_INVALID_PATH,
		CURSOR_BUILD_PATH,
	]
	for cursor_index in cursor_paths.size():
		var cursor_path: String = cursor_paths[cursor_index]
		if ResourceLoader.exists(cursor_path):
			_cursor_textures[cursor_index] = load(cursor_path) as Texture2D
	_wire_interactable_cursors(_hud)
	_set_cursor(CursorKind.DEFAULT)

func _wire_interactable_cursors(root: Node) -> void:
	for candidate in root.find_children("*", "BaseButton", true, false):
		var interactable := candidate as BaseButton
		if interactable == null:
			continue
		interactable.mouse_entered.connect(_on_interactable_mouse_entered.bind(interactable))
		interactable.mouse_exited.connect(_on_interactable_mouse_exited.bind(interactable))

func _on_interactable_mouse_entered(interactable: BaseButton) -> void:
	_hovered_interactable_control = interactable
	_refresh_pointer_cursor()

func _on_interactable_mouse_exited(interactable: BaseButton) -> void:
	if _hovered_interactable_control == interactable:
		_hovered_interactable_control = null
	_refresh_pointer_cursor()

func _refresh_pointer_cursor() -> void:
	if is_instance_valid(_hovered_interactable_control):
		var hovered_button := _hovered_interactable_control as BaseButton
		_set_cursor(CursorKind.INVALID if hovered_button.disabled else CursorKind.INTERACT)
		return
	if _build_controller != null and _build_controller.is_build_mode():
		var invalid_placement: bool = false
		if _has_hovered_cell:
			invalid_placement = not _build_controller.get_placement_error(_hovered_coord).is_empty()
		_set_cursor(CursorKind.INVALID if invalid_placement else CursorKind.TOWER_PLACEMENT)
		return
	if _hovered_tower != null and is_instance_valid(_hovered_tower):
		_set_cursor(CursorKind.INTERACT)
		return
	if _has_hovered_cell:
		var hovered_cell: HexCell = _board_grid.cells.get(_hovered_coord) as HexCell
		if hovered_cell != null and hovered_cell.chest_available:
			_set_cursor(CursorKind.INTERACT)
			return
	_set_cursor(CursorKind.DEFAULT)

func _set_cursor(cursor_kind: int) -> void:
	var build_mode: bool = _build_controller != null and _build_controller.is_build_mode()
	var cursor_texture: Texture2D = _cursor_textures.get(cursor_kind) as Texture2D
	if (
		build_mode
		and not is_instance_valid(_hovered_interactable_control)
		and (cursor_kind == CursorKind.TOWER_PLACEMENT or cursor_kind == CursorKind.INVALID)
	):
		_build_cursor_overlay.call("activate", cursor_texture)
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		_current_cursor_kind = cursor_kind
		return
	_build_cursor_overlay.call("deactivate")
	if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if cursor_kind == _current_cursor_kind:
		return
	if cursor_texture == null:
		return
	var hotspot := Vector2(13.0, 11.0)
	if cursor_kind == CursorKind.TOWER_PLACEMENT:
		hotspot = cursor_texture.get_size() * 0.5
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
	_current_cursor_kind = cursor_kind

func _configure_tower_shortcut_visuals() -> void:
	var icon_names: Array[StringName] = [
		&"ballista", &"mortar", &"tesla_coil", &"frost_keep", &"flame_thrower", &"poison_sprayer", &"shredder",
	]
	_tower_shortcut_names.clear()
	_tower_shortcut_prices.clear()
	_tower_shortcut_icons.clear()
	for index in _tower_shortcut_buttons.size():
		var shortcut_button: Button = _tower_shortcut_buttons[index]
		shortcut_button.text = ""
		shortcut_button.custom_minimum_size = Vector2(144.0, 148.0)
		shortcut_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		shortcut_button.add_theme_stylebox_override("normal", _create_tower_card_style(Color.WHITE))
		shortcut_button.add_theme_stylebox_override("hover", _create_tower_card_style(Color(1.12, 1.08, 0.92, 1.0)))
		shortcut_button.add_theme_stylebox_override("pressed", _create_tower_card_style(Color(0.82, 0.88, 0.98, 1.0)))
		shortcut_button.add_theme_stylebox_override("hover_pressed", _create_tower_card_style(Color(0.92, 0.98, 1.08, 1.0)))
		shortcut_button.add_theme_stylebox_override("disabled", _create_tower_card_style(Color(0.62, 0.65, 0.70, 0.76)))
		var margins := MarginContainer.new()
		margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margins.add_theme_constant_override("margin_left", 4)
		margins.add_theme_constant_override("margin_top", 4)
		margins.add_theme_constant_override("margin_right", 4)
		margins.add_theme_constant_override("margin_bottom", 4)
		margins.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var content := VBoxContainer.new()
		content.alignment = BoxContainer.ALIGNMENT_CENTER
		content.add_theme_constant_override("separation", 2)
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margins.add_child(content)
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(64.0, 64.0)
		icon.pivot_offset = Vector2(32.0, 32.0)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _icon_catalog.call("get_icon", icon_names[index]) as Texture2D
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(icon)
		var name_label := Label.new()
		name_label.text = TOWER_PROFILES[index].display_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.add_theme_color_override("font_color", TOWER_PROFILES[index].visual_color.lightened(0.45))
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(name_label)
		var price_row := HBoxContainer.new()
		price_row.alignment = BoxContainer.ALIGNMENT_CENTER
		price_row.add_theme_constant_override("separation", 3)
		price_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(price_row)
		var price_icon := TextureRect.new()
		price_icon.custom_minimum_size = Vector2(17.0, 17.0)
		price_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		price_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		price_icon.texture = _gold_icon.texture
		price_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		price_row.add_child(price_icon)
		var price_label := Label.new()
		price_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		price_label.add_theme_font_size_override("font_size", 13)
		price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		price_row.add_child(price_label)
		shortcut_button.add_child(margins)
		_tower_shortcut_icons.append(icon)
		_tower_shortcut_names.append(name_label)
		_tower_shortcut_prices.append(price_label)

func _create_tower_card_style(tint: Color) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = TOWER_CARD_BUTTON_TEXTURE
	style.texture_margin_left = 4.25
	style.texture_margin_top = 3.68
	style.texture_margin_right = 4.25
	style.texture_margin_bottom = 3.68
	style.content_margin_left = 9.0
	style.content_margin_top = 9.0
	style.content_margin_right = 9.0
	style.content_margin_bottom = 9.0
	style.modulate_color = tint
	return style

func _configure_tower_upgrade_visuals() -> void:
	_tower_upgrade_amounts.clear()
	_tower_upgrade_effect_labels.clear()
	_tower_upgrade_cost_icons.clear()
	_tower_upgrade_layer_icons.clear()
	_tower_upgrade_level_labels.clear()
	_tower_upgrade_xp_labels.clear()
	_tower_upgrade_xp_bars.clear()
	var layer_icons: Array[StringName] = [&"health", &"armor", &"shield"]
	var layer_names: Array[String] = ["Health", "Armor", "Shield"]
	for layer in _tower_upgrade_buttons.size():
		var button: Button = _tower_upgrade_buttons[layer]
		button.text = ""
		button.custom_minimum_size = Vector2(116.0, 140.0)
		var content := VBoxContainer.new()
		content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		content.alignment = BoxContainer.ALIGNMENT_CENTER
		content.add_theme_constant_override("separation", 1)
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var layer_icon := TextureRect.new()
		layer_icon.custom_minimum_size = Vector2(26.0, 26.0)
		layer_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		layer_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		layer_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		layer_icon.texture = _icon_catalog.call("get_icon", layer_icons[layer]) as Texture2D
		layer_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(layer_icon)
		var level_label := Label.new()
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level_label.add_theme_font_size_override("font_size", 10)
		level_label.add_theme_color_override("font_color", _hp_layer_color(layer))
		level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(level_label)
		var xp_bar := ProgressBar.new()
		xp_bar.custom_minimum_size = Vector2(0.0, 7.0)
		xp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		xp_bar.min_value = 0.0
		xp_bar.max_value = 100.0
		xp_bar.show_percentage = false
		xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var xp_background := StyleBoxFlat.new()
		xp_background.bg_color = Color("#1c252b")
		xp_background.set_corner_radius_all(4)
		var xp_fill := StyleBoxFlat.new()
		xp_fill.bg_color = _hp_layer_color(layer)
		xp_fill.set_corner_radius_all(4)
		xp_bar.add_theme_stylebox_override("background", xp_background)
		xp_bar.add_theme_stylebox_override("fill", xp_fill)
		content.add_child(xp_bar)
		var xp_label := Label.new()
		xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		xp_label.add_theme_font_size_override("font_size", 9)
		xp_label.add_theme_color_override("font_color", Color("#d5dce0"))
		xp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(xp_label)
		var effect_label := Label.new()
		effect_label.text = "+1 Daño · +1 %s" % layer_names[layer]
		effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		effect_label.add_theme_font_size_override("font_size", 10)
		effect_label.add_theme_color_override("font_color", _hp_layer_color(layer))
		effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(effect_label)
		var price_row := HBoxContainer.new()
		price_row.alignment = BoxContainer.ALIGNMENT_CENTER
		price_row.add_theme_constant_override("separation", 4)
		price_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cost_icon := TextureRect.new()
		cost_icon.custom_minimum_size = Vector2(18.0, 18.0)
		cost_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cost_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cost_icon.texture = _gold_icon.texture
		cost_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		price_row.add_child(cost_icon)
		var amount_label := Label.new()
		amount_label.add_theme_font_size_override("font_size", 14)
		amount_label.add_theme_color_override("font_color", Color("#ffe29a"))
		amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		price_row.add_child(amount_label)
		content.add_child(price_row)
		button.add_child(content)
		_tower_upgrade_layer_icons.append(layer_icon)
		_tower_upgrade_effect_labels.append(effect_label)
		_tower_upgrade_amounts.append(amount_label)
		_tower_upgrade_cost_icons.append(cost_icon)
		_tower_upgrade_level_labels.append(level_label)
		_tower_upgrade_xp_labels.append(xp_label)
		_tower_upgrade_xp_bars.append(xp_bar)

func _hp_layer_color(layer: int) -> Color:
	match layer:
		Enemy.HitPointLayer.HEALTH:
			return Color("#82df8b")
		Enemy.HitPointLayer.ARMOR:
			return Color("#f2bd68")
		Enemy.HitPointLayer.SHIELD:
			return Color("#72d5f2")
		_:
			return Color.WHITE

func _format_tower_summary(source_text: String) -> String:
	var result := _style_summary_layer(source_text, "Health", "health", "#82df8b")
	result = _style_summary_layer(result, "Armor", "armor", "#f2bd68")
	result = _style_summary_layer(result, "Shield", "shield", "#72d5f2")
	result = result.replace("Daño ", "[b]Daño[/b] ")
	result = result.replace("Rango ", "[b]Rango[/b] ")
	result = result.replace("RPM", "[b]RPM[/b]")
	result = result.replace("Crítico ", "[b]Crítico[/b] ")
	result = result.replace("XP {icon:health}", "[b]XP[/b] {icon:health}")
	return result

func _style_summary_layer(source_text: String, layer_name: String, icon_name: String, color_hex: String) -> String:
	var fragment: String = "%s {icon:%s} " % [layer_name, icon_name]
	var layer_start: int = source_text.find(fragment)
	if layer_start < 0:
		return source_text
	var value_start: int = layer_start + fragment.length()
	var separator_end: int = source_text.find(" · ", value_start)
	var line_end: int = source_text.find("\n", value_start)
	var value_end: int = separator_end if separator_end >= 0 else line_end
	if value_end < 0:
		value_end = source_text.length()
	var value: String = source_text.substr(value_start, value_end - value_start)
	var formatted: String = "[b][color=%s]%s[/color][/b] {icon:%s} [color=%s]%s[/color]" % [
		color_hex,
		layer_name,
		icon_name,
		color_hex,
		value,
	]
	return source_text.substr(0, layer_start) + formatted + source_text.substr(value_end)

func _fit_tower_info_panel() -> void:
	if not is_instance_valid(_tower_info_panel) or not _tower_info_panel.visible:
		return
	var viewport_size: Vector2 = _tower_info_panel.get_viewport_rect().size
	var panel_top: float = 76.0
	var panel_width: float = minf(420.0, maxf(240.0, viewport_size.x - 48.0))
	_tower_info_panel.offset_left = -panel_width - 24.0
	_tower_info_panel.offset_right = -24.0
	_tower_info_panel.offset_top = panel_top
	_tower_info_panel.size.x = panel_width
	_tower_info_content.pivot_offset = Vector2.ZERO
	_tower_info_content.scale = Vector2.ONE
	var desired_height: float = maxf(150.0, ceilf(_tower_info_panel.get_combined_minimum_size().y))
	var available_height: float = maxf(96.0, viewport_size.y - panel_top - 24.0)
	var vertical_scale: float = minf(1.0, available_height / desired_height)
	_tower_info_panel.size.y = desired_height
	_tower_info_panel.offset_bottom = _tower_info_panel.offset_top + desired_height
	_tower_info_panel.pivot_offset = Vector2(panel_width * 0.5, 0.0)
	_tower_info_panel.scale = Vector2(1.0, vertical_scale)

func _update_tower_card_pulse(index: int) -> void:
	if _tower_card_pulsing_index == index and _tower_card_pulse_tween != null and _tower_card_pulse_tween.is_running():
		return
	if _tower_card_pulse_tween != null and _tower_card_pulse_tween.is_running():
		_tower_card_pulse_tween.kill()
	if _tower_card_pulsing_index >= 0 and _tower_card_pulsing_index < _tower_shortcut_buttons.size():
		_tower_shortcut_buttons[_tower_card_pulsing_index].scale = Vector2.ONE
	_tower_card_pulsing_index = index
	if index < 0 or index >= _tower_shortcut_buttons.size():
		return
	var selected_card: Button = _tower_shortcut_buttons[index]
	selected_card.pivot_offset = selected_card.size * 0.5
	selected_card.scale = Vector2.ONE
	_tower_card_pulse_tween = create_tween().set_loops()
	_tower_card_pulse_tween.tween_property(selected_card, "scale", Vector2(1.045, 1.045), 0.48).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tower_card_pulse_tween.tween_property(selected_card, "scale", Vector2.ONE, 0.48).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_viewport_size_changed() -> void:
	call_deferred("_fit_tower_info_panel")

func _configure_hud_tooltips() -> void:
	_base_health_bar.tooltip_text = "Health restante de Main Tower. Si llega a cero, termina la run."
	_gold_status.tooltip_text = "Gold disponible para construir y mejorar torres."
	_mana_status.tooltip_text = "Mana disponible para activar algunas torres."
	_wave_status.tooltip_text = "Fase y actividad de la ronda de campaña actual."
	_round_progress.tooltip_text = "Cada punto representa una oleada. Pasa el cursor para ver su composición."
	_wave_selector.tooltip_text = "Selector técnico de rondas y perfiles DEBUG. Solo aparece en el panel F3."
	_piece_selector.tooltip_text = "Selecciona una pieza disponible para inspeccionar o colocar."
	_rotate_left.tooltip_text = "Gira la pieza 60 grados en sentido antihorario. Atajo: Q."
	_rotate_right.tooltip_text = "Gira la pieza 60 grados en sentido horario. Atajo: E."
	_confirm_button.tooltip_text = "Confirma la pieza si el preview indica que su posición es válida."
	_cancel_button.tooltip_text = "Cancela la colocación activa. También puedes pulsar Esc o clic derecho."
	_combat_debug.tooltip_text = "Inspección técnica de capas, regeneración, daño previsto y estados del objetivo."
	_build_status.tooltip_text = "Estado de construcción, recompensa reciente o motivo de rechazo."
	_start_wave_button.tooltip_text = "Inicia la ronda activa de la campaña."
	for slot in _tower_priority_buttons.size():
		_tower_priority_buttons[slot].tooltip_text = "Criterio de prioridad %d. El siguiente criterio solo decide empates." % (slot + 1)
	for layer in _tower_upgrade_buttons.size():
		_tower_upgrade_buttons[layer].tooltip_text = "Mejora el multiplicador de daño de %s." % _hp_layer_name(layer)
	_demolish_tower_button.tooltip_text = "Retira la torre seleccionada sin reembolso y reduce el coste futuro de ese tipo."

func _is_mouse_over_hud(mouse_position: Vector2) -> bool:
	if _meta_shop_panel != null and bool(_meta_shop_panel.call("is_open")):
		return true
	if not _hud.visible:
		return false
	return (
		(_hud_panel.visible and _hud_panel.get_global_rect().has_point(mouse_position))
		or (_resources_row.visible and _resources_row.get_global_rect().has_point(mouse_position))
		or (_round_panel.visible and _round_panel.get_global_rect().has_point(mouse_position))
		or (_tower_info_panel.visible and _tower_info_panel.get_global_rect().has_point(mouse_position))
		or (_tower_toolbar.visible and _tower_toolbar.get_global_rect().has_point(mouse_position))
		or (_terrain_panel.visible and _terrain_panel.get_global_rect().has_point(mouse_position))
		or (_terrain_card_panel.visible and _terrain_card_panel.get_global_rect().has_point(mouse_position))
		or (_upgrade_card_panel != null and _upgrade_card_panel.visible and _upgrade_card_panel.get_global_rect().has_point(mouse_position))
	)

func _toggle_terrain_panel() -> void:
	_terrain_panel.visible = not _terrain_panel.visible
	if _terrain_panel.visible:
		_refresh_combat_debug()
	_refresh_tower_controls()

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
		_placement_path_graph = null
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
		_placement_path_graph = null
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
	_placement_path_graph = null
	var placement_is_valid: bool = _latest_placement.is_valid
	if placement_is_valid and can_edit_terrain:
		_placement_path_graph = _build_placement_preview_graph()
		placement_is_valid = _placement_path_graph.is_valid
	_piece_preview.set_placement_preview(
		_selected_piece,
		_anchor_coord,
		_rotation_steps,
		placement_is_valid,
		can_edit_terrain,
		_placement_path_graph
	)
	_confirm_button.disabled = not can_edit_terrain or not placement_is_valid
	_rotation_status.text = "Orientación: %d° · posición %d/6" % [
		_rotation_steps * 60,
		_rotation_steps + 1,
	]
	var placement_message: String = _latest_placement.message()
	if _latest_placement.is_valid and can_edit_terrain:
		if _placement_path_graph == null or not _placement_path_graph.is_valid:
			placement_message = "Esta posición deja la red PATH inválida. "
			if _placement_path_graph != null and not _placement_path_graph.errors.is_empty():
				placement_message += "; ".join(_placement_path_graph.errors)
		else:
			placement_message += " · " + _spawn_preview_summary(_placement_path_graph)
	_placement_status.text = "%s · conexiones: %d" % [
		placement_message,
		_latest_placement.path_connection_count,
	]

func _build_placement_preview_graph() -> PathGraph:
	var candidate_board: Dictionary[Vector2i, HexCell] = {}
	for coord in _board_grid.cells:
		candidate_board[coord] = _board_grid.cells[coord]
	var piece_cells: Dictionary[Vector2i, HexCell] = TerrainPlacementValidator.instantiate_cells(
		_selected_piece,
		_anchor_coord,
		_rotation_steps,
		_next_piece_instance_id
	)
	for coord in piece_cells:
		candidate_board[coord] = piece_cells[coord]
	var candidate_grid := HexGrid.new()
	candidate_grid.cells = candidate_board
	for hole_coord in candidate_grid.get_enclosed_void_coords():
		# El tipo de relleno no cambia el grafo porque solo PATH tiene conexiones.
		var preview_fill := HexCell.new(HexCoord.new(hole_coord.x, hole_coord.y))
		preview_fill.terrain_type = HexCell.TerrainType.GRASS
		preview_fill.elevation = 1
		preview_fill.buildable = true
		preview_fill.visual_variant = &"auto_filled_void_preview"
		candidate_board[hole_coord] = preview_fill
	var candidate_graph := PathGraph.new()
	candidate_graph.rebuild(candidate_board, _base_coord, int(STARTING_BOARD.get("minimum_spawn_route_cells")))
	return candidate_graph

func _spawn_preview_summary(candidate_graph: PathGraph) -> String:
	var current_keys: Dictionary = _get_spawn_endpoint_keys(_path_graph)
	var candidate_keys: Dictionary = _get_spawn_endpoint_keys(candidate_graph)
	var added_count: int = 0
	var closed_count: int = 0
	for key in candidate_keys:
		if not current_keys.has(key):
			added_count += 1
	for key in current_keys:
		if not candidate_keys.has(key):
			closed_count += 1
	if added_count == 0 and closed_count == 0:
		return "Spawns %d → %d · sin cambios" % [current_keys.size(), candidate_keys.size()]
	return "Spawns %d → %d · %d nuevos · %d se cierran" % [
		current_keys.size(),
		candidate_keys.size(),
		added_count,
		closed_count,
	]

func _get_spawn_endpoint_keys(graph: PathGraph) -> Dictionary:
	var keys: Dictionary = {}
	if graph == null:
		return keys
	for route in graph.routes:
		if route == null or not route.is_reachable or route.spawn_endpoint == null:
			continue
		var endpoint: PathEndpoint = route.spawn_endpoint
		keys["%d,%d,%d" % [endpoint.cell_coord.x, endpoint.cell_coord.y, endpoint.edge_direction]] = true
	return keys

func _confirm_placement() -> void:
	if (
		not _placement_enabled
		or _selected_piece == null
		or _latest_placement == null
		or not _latest_placement.is_valid
		or _placement_path_graph == null
		or not _placement_path_graph.is_valid
	):
		return
	var cells := TerrainPlacementValidator.instantiate_cells(
		_selected_piece,
		_anchor_coord,
		_rotation_steps,
		_next_piece_instance_id
	)
	for cell_variant in cells.values():
		TERRAIN_VISUAL_CATALOG_SCRIPT.set_random_cell_contents(cell_variant as HexCell, _run_seed, _chest_spawn_chance)
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
	TERRAIN_VISUAL_CATALOG_SCRIPT.set_random_cell_contents(cell, _run_seed, _chest_spawn_chance)
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
	if not _placement_enabled and _has_hovered_cell:
		var hovered_cell: HexCell = _board_grid.cells.get(_hovered_coord) as HexCell
		if hovered_cell != null and hovered_cell.chest_available:
			_open_treasure_chest(hovered_cell)
			return
	if _build_controller.is_build_mode():
		if not _has_hovered_cell:
			_build_status.text = "Coloca el cursor sobre una casilla existente."
			return
		if _build_controller.place_tower(_hovered_coord):
			_set_rich_text_with_currency_icons(_build_status, "%s construida por %d Gold en (%d, %d)." % [
				_selected_tower_data.display_name,
				_selected_tower_data.build_cost,
				_hovered_coord.x,
				_hovered_coord.y,
			])
			_build_controller.cancel_build_mode()
			_refresh_build_preview()
			_refresh_placement()
			_refresh_tower_controls()
		else:
			_set_rich_text_with_currency_icons(_build_status, _build_controller.last_error)
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
	if _build_controller.selected_tower != null:
		_build_controller.clear_selection()
		_refresh_tower_controls()
	if _placement_enabled:
		_confirm_placement()

func _open_treasure_chest(cell: HexCell) -> void:
	if cell == null or not cell.chest_available:
		return
	cell.chest_available = false
	var gold_awarded: int = int(_run_economy.call(
		"add_gold",
		TERRAIN_VISUAL_CATALOG_SCRIPT.CHEST_GOLD_REWARD,
		&"terrain_chest"
	))
	var reward_text: String = "Cofre abierto · +%d Gold." % gold_awarded
	if gold_awarded <= 0:
		reward_text = "Cofre abierto · Gold al máximo."
	_set_rich_text_with_currency_icons(_build_status, reward_text)
	_piece_preview.refresh_cell_decorations()
	_piece_preview.queue_redraw()
	_refresh_tower_controls()

func _select_tower_and_build(index: int) -> void:
	if index < 0 or index >= TOWER_PROFILES.size():
		return
	_select_tower_profile_and_build(TOWER_PROFILES[index])

func _select_debug_tower_and_build(tower_data: TowerData) -> void:
	_select_tower_profile_and_build(tower_data)

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
		_build_status.clear()
	else:
		_set_rich_text_with_currency_icons(_build_status, _build_controller.last_error)
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
		_build_controller.get_preview_range_pixels(_hovered_coord),
		_icon_catalog.call("get_tower_icon", StringName(_selected_tower_data.id)) as Texture2D,
		_selected_tower_data.visual_icon_size
	)

func _populate_targeting_modes() -> void:
	var labels: PackedStringArray = [
		"Más avanzado", "Menos avanzado", "Menos HP total", "Más Health",
		"Más Armor", "Más Shield", "Menos Health", "Menos Armor",
		"Menos Shield", "Más lento", "Más rápido",
	]
	for slot in _tower_priority_buttons.size():
		var selector: OptionButton = _tower_priority_buttons[slot]
		selector.clear()
		var popup: PopupMenu = selector.get_popup()
		if slot > 0:
			selector.add_item("Sin criterio", -1)
			popup.set_item_tooltip(0, "Deja vacía esta posición de desempate.")
		for mode in labels.size():
			var item_index: int = selector.item_count
			selector.add_item(labels[mode], mode)
			popup.set_item_tooltip(item_index, _targeting_mode_tooltip(mode))
		selector.select(0)
	_sync_targeting_priority_menu(null)

func _targeting_mode_tooltip(mode: int) -> String:
	match mode:
		TowerData.TargetingMode.FIRST_PROGRESS:
			return "El enemigo con más progreso por su ruta, más cerca de la base."
		TowerData.TargetingMode.LAST_PROGRESS:
			return "El enemigo con menos progreso por su ruta, más lejos de la base."
		TowerData.TargetingMode.LOWEST_TOTAL_HIT_POINTS:
			return "Menor suma de puntos restantes de Health, Armor y Shield."
		TowerData.TargetingMode.HIGHEST_HEALTH:
			return "Mayor cantidad actual de puntos Health restantes."
		TowerData.TargetingMode.HIGHEST_ARMOR:
			return "Mayor cantidad actual de puntos Armor restantes."
		TowerData.TargetingMode.HIGHEST_SHIELD:
			return "Mayor cantidad actual de puntos Shield restantes."
		TowerData.TargetingMode.LOWEST_HEALTH:
			return "Menor cantidad actual de puntos Health restantes."
		TowerData.TargetingMode.LOWEST_ARMOR:
			return "Menor cantidad actual de puntos Armor restantes."
		TowerData.TargetingMode.LOWEST_SHIELD:
			return "Menor cantidad actual de puntos Shield restantes."
		TowerData.TargetingMode.SLOWEST:
			return "El enemigo que se mueve más despacio."
		TowerData.TargetingMode.FASTEST:
			return "El enemigo que se mueve más rápido."
		_:
			return "Criterio de selección de objetivo."

func _populate_wave_options() -> void:
	_selected_tower_data = BALLISTA
	_wave_selector.clear()
	var campaign_waves: Array[WaveData] = []
	for round_index in range(CAMPAIGN_ROUND_COUNT):
		var wave: WaveData = _get_campaign_round(round_index + 1)
		campaign_waves.append(wave)
		var encounter_label: String = _encounter_label(wave)
		_wave_selector.add_item("Ronda %02d/45 · %s · %d enemigos" % [
			round_index + 1,
			encounter_label,
			_get_wave_enemy_count(wave),
		])
	_round_progress.call("set_campaign_waves", campaign_waves)
	_wave_selector.add_item("DEBUG · Armored Regenerator")
	_wave_selector.add_item("DEBUG · Status Training Target")
	_wave_selector.add_item("DEBUG · Health/Armor/Shield target")
	_wave_selector.select(0)
	_selected_wave = _get_campaign_round(_campaign_round_number)
	_selected_wave_is_debug = false
	_set_campaign_wave_name()
	_wave_status.text = "Preparación · ronda %d/45 · %d enemigos" % [
		_campaign_round_number,
		_get_wave_enemy_count(_selected_wave),
	]
	_set_start_wave_button_text("▶ Iniciar ronda %d/45" % _campaign_round_number)
	_refresh_tower_controls()

func _refresh_campaign_option_counts() -> void:
	for round_index in range(CAMPAIGN_ROUND_COUNT):
		var wave: WaveData = _get_campaign_round(round_index + 1)
		_wave_selector.set_item_text(round_index, "Ronda %02d/45 · %s · %d enemigos" % [
			round_index + 1,
			_encounter_label(wave),
			_get_wave_enemy_count(wave),
		])

func _on_wave_profile_selected(index: int) -> void:
	if index < 0:
		return
	if index < CAMPAIGN_ROUND_COUNT:
		if index + 1 != _campaign_round_number or RunManager.phase != RunManager.Phase.ROUND_PREP:
			_wave_selector.select(_campaign_round_number - 1)
			return
		_selected_wave = _get_campaign_round(index + 1)
		_selected_wave_is_debug = false
		_set_campaign_wave_name()
		_wave_status.text = "Preparación · ronda %d/45 · %d enemigos" % [
			_campaign_round_number,
			_get_wave_enemy_count(_selected_wave),
		]
	elif index == DEBUG_WAVE_START_INDEX:
		_selected_wave = M7_DAMAGE_TEST_WAVE
		_selected_wave_is_debug = true
		_active_wave_name = "Armored Regenerator (M7 DEBUG)"
		_wave_status.text = "DEBUG · 1 Armored Regenerator · Armor 4 · regen 2/s"
	elif index == DEBUG_WAVE_START_INDEX + 1:
		_selected_wave = M8_STATUS_TEST_WAVE
		_selected_wave_is_debug = true
		_active_wave_name = "Status Training Target (M8 DEBUG)"
		_wave_status.text = "DEBUG · 1 Status Training Target · Health 180 · velocidad 32"
	elif index == DEBUG_WAVE_START_INDEX + 2:
		_selected_wave = TOWER_LAYER_TEST_WAVE
		_selected_wave_is_debug = true
		_active_wave_name = "Health/Armor/Shield Training Target (M12A DEBUG)"
		_wave_status.text = "DEBUG · Shield 40 · Armor 60 · Health 120 · regeneración 1/s por capa"
	else:
		return
	_set_start_wave_button_text("▶ Iniciar prueba" if _selected_wave_is_debug else "▶ Iniciar ronda %d/45" % _campaign_round_number)
	_refresh_tower_controls()

func _on_targeting_priority_selected(item_index: int, slot: int) -> void:
	var tower: Tower = _build_controller.selected_tower
	if tower == null or not is_instance_valid(tower):
		return
	var selector: OptionButton = _tower_priority_buttons[slot]
	var mode: int = selector.get_item_id(item_index)
	var next_priorities: Array[int] = tower.get_targeting_priorities()
	while next_priorities.size() < 3:
		next_priorities.append(-1)
	if slot == 0 and mode < 0:
		_sync_targeting_priority_menu(tower)
		return
	var previous_mode: int = next_priorities[slot]
	if mode >= 0:
		var duplicate_slot: int = next_priorities.find(mode)
		if duplicate_slot >= 0 and duplicate_slot != slot:
			if previous_mode < 0:
				_sync_targeting_priority_menu(tower)
				return
			next_priorities[duplicate_slot] = previous_mode
	next_priorities[slot] = mode
	if not _build_controller.set_selected_targeting_priorities(next_priorities):
		_sync_targeting_priority_menu(tower)
		return
	_sync_targeting_priority_menu(tower)
	_refresh_tower_controls()

func _sync_targeting_priority_menu(tower: Tower) -> void:
	var selected_modes: Array[int] = []
	if tower != null and is_instance_valid(tower):
		selected_modes = tower.get_targeting_priorities()
		var tower_instance_id: int = tower.get_instance_id()
		if tower_instance_id != _priority_visibility_tower_instance_id:
			_priority_visibility_tower_instance_id = tower_instance_id
			_visible_target_priority_count = 1
			for slot in range(selected_modes.size() - 1, -1, -1):
				if selected_modes[slot] >= 0:
					_visible_target_priority_count = slot + 1
					break
	else:
		selected_modes = [TowerData.TargetingMode.FIRST_PROGRESS, -1, -1]
		_priority_visibility_tower_instance_id = 0
		_visible_target_priority_count = 1
	while selected_modes.size() < 3:
		selected_modes.append(-1)
	for slot in _tower_priority_buttons.size():
		var selector: OptionButton = _tower_priority_buttons[slot]
		_tower_priority_rows[slot].visible = slot < _visible_target_priority_count
		var selected_mode: int = selected_modes[slot]
		for item_index in selector.item_count:
			if selector.get_item_id(item_index) == selected_mode:
				selector.select(item_index)
				break
		selector.tooltip_text = "Elige el criterio de prioridad %d. Si hay empate, se usa el siguiente." % (slot + 1)
	_tower_priority_add_button.visible = tower != null and is_instance_valid(tower) and _visible_target_priority_count < 3
	_tower_priority_add_button.disabled = not _build_controller.can_build_in_current_phase()
	if _tower_info_panel.visible:
		call_deferred("_fit_tower_info_panel")

func _on_add_targeting_priority_pressed() -> void:
	if _visible_target_priority_count >= _tower_priority_rows.size():
		return
	var tower: Tower = _build_controller.selected_tower
	if tower == null or not is_instance_valid(tower):
		return
	_visible_target_priority_count += 1
	_sync_targeting_priority_menu(tower)

func _on_upgrade_tower_pressed(layer: int) -> void:
	var tower: Tower = _build_controller.selected_tower
	var upgrade_cost: int = tower.get_next_upgrade_cost(layer) if tower != null and is_instance_valid(tower) else -1
	if _build_controller.upgrade_selected_tower(layer):
		_set_rich_text_with_currency_icons(_build_status, "%s mejorado: +1 daño base y +1 %s · −%d Gold." % [
			_hp_layer_name(layer),
			_hp_layer_name(layer),
			upgrade_cost,
		])
	else:
		_set_rich_text_with_currency_icons(_build_status, _build_controller.last_error)
	_refresh_tower_controls()

func _on_demolish_tower_pressed() -> void:
	if _build_controller.demolish_selected_tower():
		_build_status.text = "Torre retirada. El siguiente precio de este tipo baja."
	else:
		_set_rich_text_with_currency_icons(_build_status, _build_controller.last_error)
	_refresh_tower_controls()

func _on_tower_list_changed(_tower: Tower, _coord: Vector2i) -> void:
	_refresh_tower_controls()

func _on_tower_built_for_vfx(tower: Tower, _coord: Vector2i) -> void:
	if tower == null or not is_instance_valid(tower):
		return
	tower.impact_effect_requested.connect(_spawn_impact_vfx)
	_animate_tower_shortcut_icon(tower.get_tower_data().id)

func _animate_tower_shortcut_icon(tower_id: StringName) -> void:
	for index in TOWER_PROFILES.size():
		if TOWER_PROFILES[index].id != tower_id or index >= _tower_shortcut_icons.size():
			continue
		var icon: TextureRect = _tower_shortcut_icons[index]
		if not is_instance_valid(icon):
			return
		var previous_tween: Tween = _tower_shortcut_icon_tweens.get(index) as Tween
		if previous_tween != null and previous_tween.is_running():
			previous_tween.kill()
		icon.rotation = 0.0
		icon.scale = Vector2.ONE
		var tween: Tween = create_tween()
		_tower_shortcut_icon_tweens[index] = tween
		tween.tween_property(icon, "rotation", deg_to_rad(10.0), 0.075)
		tween.parallel().tween_property(icon, "scale", Vector2(1.16, 1.16), 0.075)
		tween.tween_property(icon, "rotation", deg_to_rad(-9.0), 0.085)
		tween.parallel().tween_property(icon, "scale", Vector2(0.96, 0.96), 0.085)
		tween.tween_property(icon, "rotation", deg_to_rad(6.0), 0.075)
		tween.parallel().tween_property(icon, "scale", Vector2(1.08, 1.08), 0.075)
		tween.tween_property(icon, "rotation", 0.0, 0.08)
		tween.parallel().tween_property(icon, "scale", Vector2.ONE, 0.08)
		return

func _spawn_impact_vfx(effect_id: StringName, world_position: Vector2) -> void:
	var sheet_path: String = ""
	var frame_count: int = 1
	var frames_per_second: float = 12.0
	var display_size: float = 72.0
	match effect_id:
		&"dust_01":
			sheet_path = "res://assets/third_party/tiny_swords/particle_fx/Dust_01.png"
			frame_count = 8
			display_size = 76.0
		&"explosion_01":
			sheet_path = "res://assets/third_party/tiny_swords/particle_fx/Explosion_01.png"
			frame_count = 8
			frames_per_second = 14.0
			display_size = 148.0
		&"tesla_coil":
			sheet_path = "res://assets/third_party/tiny_swords/particle_fx/TeslaCoil.png"
			frame_count = 8
			display_size = 108.0
		&"ice_01":
			sheet_path = "res://assets/third_party/tiny_swords/particle_fx/Ice_01.png"
			frame_count = 10
			display_size = 82.0
		&"fire_03":
			sheet_path = "res://assets/third_party/tiny_swords/particle_fx/Fire_03.png"
			frame_count = 12
			display_size = 86.0
		&"poison":
			sheet_path = "res://assets/third_party/tiny_swords/particle_fx/Poison.png"
			frame_count = 9
			display_size = 142.0
		&"blood":
			sheet_path = "res://assets/third_party/tiny_swords/particle_fx/Blood.png"
			frame_count = 10
			display_size = 80.0
		_:
			return
	if not ResourceLoader.exists(sheet_path):
		return
	var sprite_sheet := load(sheet_path) as Texture2D
	if sprite_sheet == null:
		return
	var effect := IMPACT_VFX_SCRIPT.new() as Sprite2D
	if effect == null:
		return
	_entities.add_child(effect)
	if not bool(effect.call("configure", sprite_sheet, frame_count, frames_per_second, display_size, world_position)):
		effect.queue_free()

func _on_tower_demolished(_tower_data: TowerData, _next_build_cost: int) -> void:
	_tower_status.text = "Torre: ninguna · pulsa 1–7 para construir"
	_refresh_tower_controls()

func _on_tower_selected(tower: Tower, _coord: Vector2i) -> void:
	if tower == null or not is_instance_valid(tower):
		return
	_set_rich_text_with_currency_icons(_tower_status, _format_tower_summary(tower.get_summary()))
	_sync_targeting_priority_menu(tower)
	_refresh_combat_debug()
	_refresh_tower_controls()

func _on_tower_upgraded(tower: Tower, _new_level: int) -> void:
	_on_tower_selected(tower, tower.cell_coord)

func _refresh_tower_controls() -> void:
	var build_mode: bool = _build_controller.is_build_mode()
	var selected: Tower = _build_controller.selected_tower
	var has_selected_tower: bool = selected != null and is_instance_valid(selected)
	var waiting_for_terrain_card: bool = _awaiting_campaign_expansion and _selected_expansion_piece == null
	var can_build: bool = _build_controller.can_build_in_current_phase() and not waiting_for_terrain_card
	var is_run_ended: bool = RunManager.phase == RunManager.Phase.RUN_DEFEAT or RunManager.phase == RunManager.Phase.RUN_VICTORY
	var selected_card_index: int = -1
	for index in _tower_shortcut_buttons.size():
		var shortcut_button: Button = _tower_shortcut_buttons[index]
		var tower_data: TowerData = TOWER_PROFILES[index]
		var tower_unlocked: bool = bool(MetaProgression.call("is_tower_unlocked", tower_data))
		shortcut_button.visible = tower_unlocked
		var effective_mana_cost: float = tower_data.mana_cost_per_attack
		if effective_mana_cost > 0.0 and _run_card_service != null:
			effective_mana_cost *= float(_run_card_service.call("get_tower_mana_cost_multiplier", tower_data.id))
		var energy_suffix: String = ""
		if tower_data.mana_cost_per_second > 0.0:
			var mana_per_second: float = tower_data.mana_cost_per_second
			if _run_card_service != null:
				mana_per_second *= float(_run_card_service.call("get_tower_mana_cost_multiplier", tower_data.id))
			energy_suffix = " · consume %.1f/s" % mana_per_second
		elif effective_mana_cost > 0.0:
			energy_suffix = " · consume %.1f por ataque" % effective_mana_cost
		var build_cost: int = _build_controller.get_current_build_cost(tower_data)
		_tower_shortcut_prices[index].text = "%d" % build_cost
		var role_summary: String = tower_data.role_summary
		shortcut_button.tooltip_text = "%s\n%s · precio %d%s · %s" % [
			tower_data.display_name,
			role_summary,
			build_cost,
			energy_suffix,
			_tower_attack_description(tower_data),
		]
		var can_afford: bool = bool(_run_economy.call("can_afford_gold", build_cost))
		shortcut_button.disabled = not can_build or not can_afford
		# Los controles personalizados dentro del Button no heredan su estilo disabled.
		shortcut_button.modulate = Color("#778187") if shortcut_button.disabled else Color.WHITE
		if can_build and not can_afford:
			shortcut_button.tooltip_text += "\nNo hay Gold suficiente para comprar esta torre."
		var matches_build_selection: bool = build_mode and TOWER_PROFILES[index] == _selected_tower_data
		var matches_placed_selection: bool = has_selected_tower and selected.get_tower_data().id == tower_data.id
		var is_active_card: bool = matches_build_selection or matches_placed_selection
		shortcut_button.set_pressed_no_signal(is_active_card)
		if is_active_card:
			selected_card_index = index
	_update_tower_card_pulse(selected_card_index)
	_refresh_wave_option_states()
	_wave_selector.disabled = build_mode or not _can_start_wave() or is_run_ended
	_tower_actions.visible = has_selected_tower and not build_mode
	_tower_info_panel.visible = (
		_hud.visible
		and not _terrain_panel.visible
		and (build_mode or has_selected_tower)
	)
	_build_status.visible = (_build_status.get_parsed_text().strip_edges() != "") and (build_mode or has_selected_tower)
	_tower_portrait.visible = build_mode
	_tower_portrait.texture = null
	if build_mode:
		_tower_portrait.texture = _icon_catalog.call("get_tower_icon", StringName(_selected_tower_data.id)) as Texture2D
	_start_wave_button.disabled = (
		build_mode
		or not _path_graph.is_valid
		or not _can_start_selected_wave()
		or is_run_ended
	)
	for selector in _tower_priority_buttons:
		selector.disabled = build_mode or not has_selected_tower or not _build_controller.can_build_in_current_phase()
	_sync_targeting_priority_menu(selected if has_selected_tower else null)
	if _tower_info_panel.visible:
		call_deferred("_fit_tower_info_panel")
	for layer in _tower_upgrade_buttons.size():
		var upgrade_button: Button = _tower_upgrade_buttons[layer]
		var next_upgrade_cost: int = selected.get_next_upgrade_cost(layer) if has_selected_tower else -1
		var layer_level: int = selected.get_layer_upgrade_level(layer) if has_selected_tower else 0
		var max_layer_upgrades: int = selected.get_tower_data().max_layer_upgrades if has_selected_tower else 0
		var xp_value: float = selected.get_targeting_xp(layer) if has_selected_tower else 0.0
		var xp_required: float = selected.get_xp_required_for_next_upgrade(layer) if has_selected_tower else 0.0
		_tower_upgrade_layer_icons[layer].visible = has_selected_tower
		_tower_upgrade_cost_icons[layer].visible = has_selected_tower and next_upgrade_cost >= 0
		_tower_upgrade_effect_labels[layer].visible = has_selected_tower
		_tower_upgrade_level_labels[layer].visible = has_selected_tower
		_tower_upgrade_xp_labels[layer].visible = has_selected_tower
		_tower_upgrade_xp_bars[layer].visible = has_selected_tower and next_upgrade_cost >= 0
		_tower_upgrade_level_labels[layer].text = "NIVEL %d/%d" % [layer_level, max_layer_upgrades]
		if next_upgrade_cost >= 0:
			_tower_upgrade_amounts[layer].text = "%d" % next_upgrade_cost
			_tower_upgrade_xp_labels[layer].text = "XP %.0f / %.0f" % [xp_value, xp_required]
			_tower_upgrade_xp_bars[layer].value = clampf(xp_value / maxf(xp_required, 0.001) * 100.0, 0.0, 100.0)
		else:
			_tower_upgrade_amounts[layer].text = "máx."
			_tower_upgrade_xp_labels[layer].text = "MÁXIMO"
			_tower_upgrade_xp_bars[layer].value = 100.0
		upgrade_button.disabled = build_mode or not has_selected_tower or next_upgrade_cost < 0 or not bool(_run_economy.call("can_afford_gold", next_upgrade_cost)) or not _build_controller.can_build_in_current_phase()
		upgrade_button.tooltip_text = "Nivel %d/%d · cuesta %d Gold · añade +1 al daño base y +1 a %s." % [layer_level, max_layer_upgrades, next_upgrade_cost, _hp_layer_name(layer)] if next_upgrade_cost >= 0 else "%s está al nivel máximo %d/%d." % [_hp_layer_name(layer), layer_level, max_layer_upgrades]
	_demolish_tower_button.disabled = build_mode or not has_selected_tower or not _build_controller.can_build_in_current_phase()
	_demolish_tower_button.tooltip_text = "Retira esta torre sin devolución y reduce el precio siguiente de su tipo."
	if build_mode:
		_set_rich_text_with_currency_icons(_tower_status, _build_tower_description(_selected_tower_data))
	elif not has_selected_tower:
		_tower_status.text = "Torre: ninguna · pulsa 1–7 para construir"
	else:
		_set_rich_text_with_currency_icons(_tower_status, _format_tower_summary(selected.get_summary()))
		_tower_status.tooltip_text = "Consulta F3 para ver el objetivo en alcance, sus capas, regeneración y estados."
	_build_status.tooltip_text = "Estado de construcción, recompensa reciente o motivo por el que una acción no se puede realizar."
	_start_wave_button.tooltip_text = "Inicia la ronda activa. La campaña avanza en orden y termina tras la ronda 45."
	call_deferred("_fit_tower_info_panel")

func _build_tower_description(tower_data: TowerData) -> String:
	var build_cost: int = _build_controller.get_current_build_cost(tower_data)
	var range_bonus: float = tower_data.height_range_bonus_per_level
	var damage_bonus: float = tower_data.elevation_damage_bonus_per_level
	var elevation_text := "Sin bonificación por altura"
	if damage_bonus > 0.0 or range_bonus > 0.0:
		var bonus_parts := PackedStringArray()
		if damage_bonus > 0.0:
			bonus_parts.append("+%.1f Daño" % damage_bonus)
		if range_bonus > 0.0:
			bonus_parts.append("+%.2f hex de alcance" % range_bonus)
		elevation_text = "[b]Mountain vs Grass:[/b] %s" % " · ".join(bonus_parts)
	var energy_text := ""
	if tower_data.mana_cost_per_second > 0.0:
		energy_text = "\nConsumo: %.1f Mana/s" % tower_data.mana_cost_per_second
	elif tower_data.mana_cost_per_attack > 0.0:
		energy_text = "\nConsumo: %.1f Mana/ataque" % tower_data.mana_cost_per_attack
	return "[b]%s[/b]\n%s\n[b]Precio:[/b] %d Gold · [b]Daño:[/b] %d · [b]Rango:[/b] %.1f hex · [b]RPM:[/b] %.0f\n[b][color=#82df8b]Health[/color][/b] [color=#82df8b]×%.1f[/color] · [b][color=#f2bd68]Armor[/color][/b] [color=#f2bd68]×%.1f[/color] · [b][color=#72d5f2]Shield[/color][/b] [color=#72d5f2]×%.1f[/color]\n%s%s" % [
		tower_data.display_name,
		tower_data.role_summary,
		build_cost,
		tower_data.base_damage,
		tower_data.range_hexes,
		tower_data.get_rounds_per_minute(),
		tower_data.health_damage_multiplier,
		tower_data.armor_damage_multiplier,
		tower_data.shield_damage_multiplier,
		elevation_text,
		energy_text,
	]

func _tower_attack_description(tower_data: TowerData) -> String:
	if tower_data.visual_archetype == TowerData.VisualArchetype.FROST:
		return "enemigos en un cuadrado hasta su alcance"
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
			return "Health"
		Enemy.HitPointLayer.ARMOR:
			return "Armor"
		Enemy.HitPointLayer.SHIELD:
			return "Shield"
		_:
			return "Layer"

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
	if not _selected_wave_is_debug:
		_run_economy.call("refill_mana_to_max")
	RunManager.transition_to(RunManager.Phase.COMBAT)
	var round_label: String = "prueba de diagnóstico" if _selected_wave_is_debug else "ronda %d/45" % round_number
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
	if not was_debug_wave:
		_round_progress.call("set_progress", round_number, round_number)
	var return_phase: int = _debug_return_phase
	var round_reward: int = completed_wave.round_reward if completed_wave != null and not was_debug_wave else 0
	_set_rich_text_with_currency_icons(_wave_status, "%s completada · ronda %d · +%d Gold · procesando recompensa…" % [
		_active_wave_name,
		round_number,
		round_reward,
	])
	_set_start_wave_button_text("Procesando…")
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
		_wave_status.text = "Prueba de diagnóstico completada · campaña detenida en ronda %d/45" % _campaign_round_number
		_set_start_wave_button_text("▶ Iniciar prueba")
	else:
		_selected_wave_is_debug = false
		if round_number >= CAMPAIGN_ROUND_COUNT:
			_placement_enabled = false
			_awaiting_campaign_expansion = false
			RunManager.transition_to(RunManager.Phase.RUN_VICTORY)
			_set_rich_text_with_currency_icons(_wave_status, "¡CAMPAÑA COMPLETADA! · 45/45 rondas superadas · +%d Gold" % round_reward)
			_set_start_wave_button_text("DEMO COMPLETADA")
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
		_wave_status.text = "Diagnóstico detenido · %s · campaña en ronda %d/45" % [reason, _campaign_round_number]
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
	for round_index in range(CAMPAIGN_ROUND_COUNT):
		_wave_selector.set_item_disabled(
			round_index,
			round_index + 1 != _campaign_round_number or RunManager.phase != RunManager.Phase.ROUND_PREP
		)
	var diagnostics_available: bool = _can_start_wave() and RunManager.phase != RunManager.Phase.RUN_DEFEAT and RunManager.phase != RunManager.Phase.RUN_VICTORY
	for debug_index in range(DEBUG_WAVE_START_INDEX, DEBUG_WAVE_START_INDEX + 3):
		_wave_selector.set_item_disabled(debug_index, not diagnostics_available)

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
	return total

func _encounter_label(wave: WaveData) -> String:
	if wave == null:
		return "No data"
	match wave.encounter_type:
		WaveData.EncounterType.MINIBOSS:
			return "Miniboss obsoleto"
		WaveData.EncounterType.TIER_2_BOSS:
			return "Tier 2 Boss"
		WaveData.EncounterType.BOSS:
			return "Boss"
		_:
			return "Standard"

func _set_campaign_wave_name() -> void:
	if _selected_wave == null:
		_active_wave_name = "Ronda %02d/45" % _campaign_round_number
		return
	_active_wave_name = "Ronda %02d/45 · %s" % [_campaign_round_number, _encounter_label(_selected_wave)]

func _on_reward_earned(amount: int, reason: int) -> void:
	var economy_reason: StringName = &"kill_reward"
	if reason == WaveDirector.RewardReason.ROUND_CLEAR:
		economy_reason = &"round_reward"
	var accepted: int = int(_run_economy.call("add_gold", amount, economy_reason))
	if accepted <= 0:
		return
	if reason == WaveDirector.RewardReason.ENEMY_KILL:
		_set_rich_text_with_currency_icons(_build_status, "Recompensa por baja: +%d Gold." % accepted)
	elif reason == WaveDirector.RewardReason.ROUND_CLEAR:
		_set_rich_text_with_currency_icons(_build_status, "Recompensa por oleada: +%d Gold." % accepted)

func _on_gold_changed(_current_gold: int, delta: int, _reason: StringName) -> void:
	_refresh_economy_status()
	_refresh_tower_controls()
	if delta != 0:
		_play_gold_feedback(delta > 0)

func _on_mana_changed(_current_mana: float, _maximum_mana: float) -> void:
	_refresh_economy_status()

func _on_damage_resolved(target: Enemy, _packet: RefCounted, result: RefCounted) -> void:
	if target == null or not is_instance_valid(target) or result == null:
		return
	var damage_result := result as DamageResult
	if damage_result == null or not damage_result.is_valid or damage_result.total_damage <= 0:
		return
	var layer: int = damage_result.active_hit_point_layer
	if damage_result.shield_damage > 0:
		layer = Enemy.HitPointLayer.SHIELD
	elif damage_result.armor_damage > 0:
		layer = Enemy.HitPointLayer.ARMOR
	elif damage_result.health_damage > 0:
		layer = Enemy.HitPointLayer.HEALTH
	target.show_damage_feedback(layer, damage_result.total_damage, damage_result.critical_multiplier > 1.0)

func _refresh_economy_status() -> void:
	if _run_economy == null or _gold_status == null or _mana_status == null:
		return
	_gold_status.text = "%d" % int(_run_economy.call("get_gold"))
	_mana_status.text = "%d / %d" % [
		int(roundf(float(_run_economy.call("get_mana")))),
		int(roundf(float(_run_economy.call("get_maximum_mana")))),
	]
	_mana_status.tooltip_text = "Mana disponible · regeneración: %s." % _format_mana_regeneration(
		float(_run_economy.call("get_mana_regen_per_second"))
	)

func _play_gold_feedback(is_reward: bool = true) -> void:
	if _gold_feedback_tween != null and _gold_feedback_tween.is_running():
		_gold_feedback_tween.kill()
	_gold_group.scale = Vector2.ONE
	_gold_group.self_modulate = Color.WHITE
	_gold_icon.rotation = 0.0
	_gold_group.pivot_offset = _gold_group.size * 0.5
	_gold_feedback_tween = create_tween()
	_gold_feedback_tween.set_parallel(true)
	var peak_scale: Vector2 = Vector2(1.48, 1.48) if is_reward else Vector2(1.18, 1.18)
	var flash_color := Color("#fff0a6") if is_reward else Color("#f5e2a8")
	var first_duration: float = 0.18 if is_reward else 0.12
	_gold_feedback_tween.tween_property(_gold_group, "scale", peak_scale, first_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_gold_feedback_tween.tween_property(_gold_group, "self_modulate", flash_color, first_duration * 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if is_reward:
		_gold_feedback_tween.tween_property(_gold_icon, "rotation", 0.16, first_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_gold_feedback_tween.chain().set_parallel(true)
	var squash_scale: Vector2 = Vector2(0.82, 0.82) if is_reward else Vector2(0.94, 0.94)
	var squash_duration: float = 0.12 if is_reward else 0.09
	_gold_feedback_tween.tween_property(_gold_group, "scale", squash_scale, squash_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	if is_reward:
		_gold_feedback_tween.tween_property(_gold_icon, "rotation", -0.10, squash_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_gold_feedback_tween.chain().set_parallel(true)
	var settle_scale: Vector2 = Vector2(1.12, 1.12) if is_reward else Vector2.ONE
	var settle_duration: float = 0.13 if is_reward else 0.14
	_gold_feedback_tween.tween_property(_gold_group, "scale", settle_scale, settle_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_gold_feedback_tween.tween_property(_gold_group, "self_modulate", Color.WHITE, settle_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if is_reward:
		_gold_feedback_tween.tween_property(_gold_icon, "rotation", 0.025, settle_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_gold_feedback_tween.chain().set_parallel(true)
	var final_duration: float = 0.20 if is_reward else 0.14
	_gold_feedback_tween.tween_property(_gold_group, "scale", Vector2.ONE, final_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_gold_feedback_tween.tween_property(_gold_group, "self_modulate", Color.WHITE, final_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_gold_feedback_tween.tween_property(_gold_icon, "rotation", 0.0, final_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _format_mana_regeneration(rate_per_second: float) -> String:
	var numerator: int = int(roundf(maxf(rate_per_second, 0.0) * 100.0))
	if numerator == 0:
		return "0 Mana/s"
	var denominator: int = 100
	var divisor_a: int = numerator
	var divisor_b: int = denominator
	while divisor_b != 0:
		var remainder: int = divisor_a % divisor_b
		divisor_a = divisor_b
		divisor_b = remainder
	var divisor: int = maxi(divisor_a, 1)
	numerator = floori(float(numerator) / float(divisor))
	denominator = floori(float(denominator) / float(divisor))
	if denominator == 1:
		return "%d Mana/s" % numerator
	return "%d Mana cada %d s" % [numerator, denominator]

func _refresh_combat_debug() -> void:
	var tower: Tower = _build_controller.selected_tower
	if tower == null or not is_instance_valid(tower):
		_set_rich_text_with_currency_icons(_combat_debug, "Objetivo: selecciona una torre")
		_tower_status.tooltip_text = "Selecciona una torre para consultar sus estadísticas. F3 abre los controles técnicos."
		return
	var target: Enemy = tower.get_current_target()
	if target == null or not is_instance_valid(target) or target.state != Enemy.State.MOVING:
		var no_target_text: String = "Objetivo: ninguno en alcance"
		if tower.is_mana_blocked():
			no_target_text += " · sin Mana"
		_set_rich_text_with_currency_icons(_combat_debug, no_target_text)
		_tower_status.tooltip_text = no_target_text
		return
	var estimate: Variant = _damage_service.call("preview_damage", target, tower.create_damage_packet(false))
	var status_summaries: PackedStringArray = target.get_active_status_summaries()
	var status_text: String = "Estados: —" if status_summaries.is_empty() else "Estados: %s" % " · ".join(status_summaries)
	var tower_data: TowerData = tower.get_tower_data()
	var damage_tag_name: String = tower.get_damage_tag_name(tower_data.damage_tags)
	var mana_text: String = ""
	if tower.get_mana_cost_per_attack() > 0.0:
		mana_text = " · sin Mana" if tower.is_mana_blocked() else " · consumo %.1f Mana/ataque" % tower.get_mana_cost_per_attack()
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
	var debug_text: String = "%s · Shield %d/%d · Armor %d/%d · Health %d/%d · regen S/A/H %.1f/%.1f/%.1f/s · %s%s\n%s" % [
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
	_set_rich_text_with_currency_icons(_combat_debug, debug_text)
	_tower_status.tooltip_text = "Consulta F3 para ver el objetivo en alcance, sus capas, regeneración y estados."

func _on_base_health_changed(current_health: int, maximum_health: int) -> void:
	var health_ratio: float = float(current_health) / float(maximum_health) if maximum_health > 0 else 0.0
	var health_color: Color = Color("#76bd82")
	if health_ratio <= 0.25:
		health_color = Color("#e27661")
	elif health_ratio <= 0.5:
		health_color = Color("#e5be6a")
	_base_health_bar.call("set_health", current_health, maximum_health, health_color)
	_base_status.text = "%d / %d" % [current_health, maximum_health]
	if current_health <= 0:
		_base_status.text = "DESTRUIDA  ·  0 / %d" % maximum_health

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
	var terrain_counts: String = _piece_terrain_counts(piece)
	return "%s · %d hexágonos\n%s" % [
		piece.display_name,
		piece.cells.size(),
		terrain_counts,
	]

func _piece_terrain_counts(piece: TerrainPieceData) -> String:
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
	var parts: PackedStringArray = PackedStringArray()
	if path_count > 0:
		parts.append("%d Path" % path_count)
	if grass_count > 0:
		parts.append("%d Grass" % grass_count)
	if mountain_count > 0:
		parts.append("%d Mountain" % mountain_count)
	return " ".join(parts)

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
		_terrain_card_counts[index].text = _piece_terrain_counts(piece)
		_terrain_card_previews[index].call("set_piece", piece)
	_set_terrain_card_layout(false)
	_terrain_card_panel.show()
	_placement_enabled = false
	_selected_expansion_piece = null
	_selected_piece = null
	_piece_selector.select(0)
	_refresh_placement()
	_start_wave_button.disabled = true
	_set_start_wave_button_text("Elige terreno")
	_refresh_tower_controls()

func _begin_campaign_terrain_expansion(round_number: int, round_reward: int) -> void:
	_upgrade_card_panel.hide()
	_placement_enabled = false
	_awaiting_campaign_expansion = true
	RunManager.transition_to(RunManager.Phase.TERRAIN_EXPANSION)
	_set_rich_text_with_currency_icons(_wave_status, "Ronda %d/45 completada · +%d Gold · elige una de tres piezas para desbloquear la ronda %d" % [
		round_number,
		round_reward,
		round_number + 1,
	])
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
		_set_rich_text_with_currency_icons(_upgrade_card_titles[index], String(card.get("display_name")))
		_set_rich_text_with_currency_icons(_upgrade_card_descriptions[index], String(card.get("description")))
		_upgrade_card_rarities[index].text = _card_rarity_name(int(card.get("rarity")))
		_upgrade_card_buttons[index].tooltip_text = ""
		var tower_icon_name: StringName = _get_card_tower_icon_name(card)
		_upgrade_card_tower_icons[index].texture = _icon_catalog.call("get_icon", tower_icon_name) as Texture2D if tower_icon_name != &"" else null
		_upgrade_card_tower_icons[index].visible = tower_icon_name != &""
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
	_set_rich_text_with_currency_icons(_wave_status, "Ronda %d/45 completada · +%d Gold · elige una mejora para la run" % [
		round_number,
		_pending_expansion_reward,
	])
	_start_wave_button.disabled = true
	_set_start_wave_button_text("Elige mejora")
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
	_round_progress.call("set_progress", _campaign_round_number, _campaign_round_number - 1)
	_selected_wave = _get_campaign_round(_campaign_round_number)
	_selected_wave_is_debug = false
	if _selected_wave == null:
		_wave_status.text = "Error: no existe la ronda %d de la campaña." % _campaign_round_number
		push_error(_wave_status.text)
		return
	_wave_selector.select(_campaign_round_number - 1)
	_set_campaign_wave_name()
	RunManager.transition_to(RunManager.Phase.ROUND_PREP)
	_wave_status.text = "Preparación · ronda %d/45 · %d enemigos" % [
		_campaign_round_number,
		_get_wave_enemy_count(_selected_wave),
	]
	_set_start_wave_button_text("▶ Iniciar ronda %d/45" % _campaign_round_number)
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
		var tower_icon := TextureRect.new()
		tower_icon.custom_minimum_size = Vector2(50.0, 50.0)
		tower_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tower_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tower_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tower_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tower_icon.hide()
		card_content.add_child(tower_icon)
		var title_label := RichTextLabel.new()
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.fit_content = true
		title_label.scroll_active = false
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_label.add_theme_font_size_override("font_size", 20)
		title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_content.add_child(title_label)
		var description_label := RichTextLabel.new()
		description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		description_label.fit_content = false
		description_label.scroll_active = false
		description_label.add_theme_font_size_override("font_size", 15)
		description_label.add_theme_color_override("font_color", Color("d3dcdf"))
		description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_content.add_child(description_label)
		_upgrade_card_buttons.append(card_button)
		_upgrade_card_titles.append(title_label)
		_upgrade_card_descriptions.append(description_label)
		_upgrade_card_rarities.append(rarity_label)
		_upgrade_card_tower_icons.append(tower_icon)

func _get_card_tower_icon_name(card: Resource) -> StringName:
	if card == null:
		return &""
	var operations: Array = card.get("modifier_operations")
	for operation_variant in operations:
		var operation: Resource = operation_variant as Resource
		if operation == null:
			continue
		var tower_id: StringName = StringName(_icon_catalog.call("normalize_tower_icon_id", StringName(operation.get("affected_tower_id"))))
		if tower_id in [&"ballista", &"mortar", &"tesla_coil", &"frost_keep", &"flame_thrower", &"poison_sprayer", &"shredder"]:
			return tower_id
	return &""

func _set_rich_text_with_currency_icons(label: RichTextLabel, source_text: String) -> void:
	label.clear()
	var currency_pattern := RegEx.new()
	currency_pattern.compile("(?i)\\b(gold|mana|oro|moneda|man[aá])\\b|\\{icon:(gold|mana|health|armor|shield)\\}")
	var matches: Array[RegExMatch] = currency_pattern.search_all(source_text)
	var cursor: int = 0
	for currency_match in matches:
		var match_start: int = currency_match.get_start(0)
		label.append_text(source_text.substr(cursor, match_start - cursor))
		var currency_text: String = currency_match.get_string(1).to_lower()
		var icon_token: String = currency_match.get_string(2).to_lower()
		var icon_name: StringName = StringName(icon_token)
		if icon_token.is_empty():
			icon_name = &"mana" if currency_text.begins_with("man") else &"gold"
		var currency_icon: Texture2D = _icon_catalog.call("get_icon", icon_name) as Texture2D
		if currency_icon != null:
			label.add_image(currency_icon, 17, 17)
		cursor = currency_match.get_end(0)
	label.append_text(source_text.substr(cursor))

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
	_set_start_wave_button_text("Coloca terreno")
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
		_terrain_card_panel.offset_left = -540.0
		_terrain_card_panel.offset_top = -230.0
		_terrain_card_panel.offset_right = 540.0
		_terrain_card_panel.offset_bottom = 230.0
		_terrain_card_panel.custom_minimum_size = Vector2(1080.0, 460.0)
	var margin: MarginContainer = _terrain_card_panel.get_node("Margin") as MarginContainer
	margin.add_theme_constant_override("margin_left", 10 if is_inventory else 18)
	margin.add_theme_constant_override("margin_right", 10 if is_inventory else 18)
	margin.add_theme_constant_override("margin_top", 8 if is_inventory else 14)
	margin.add_theme_constant_override("margin_bottom", 8 if is_inventory else 14)
	var card_size: Vector2 = Vector2(184.0, 126.0) if is_inventory else Vector2(320.0, 420.0)
	var preview_size: Vector2 = Vector2(132.0, 54.0) if is_inventory else Vector2(264.0, 340.0)
	for index in _terrain_card_buttons.size():
		_terrain_card_buttons[index].custom_minimum_size = card_size
		_terrain_card_previews[index].custom_minimum_size = preview_size
		_terrain_card_titles[index].add_theme_font_size_override("font_size", 14 if is_inventory else 18)
		_terrain_card_counts[index].add_theme_font_size_override("font_size", 11 if is_inventory else 13)

func _style_terrain_card_button(button: Button) -> void:
	var normal_style := _make_nine_slice_style(TERRAIN_EXPANSION_CARD_TEXTURE, Color.WHITE)
	var hover_style := _make_nine_slice_style(TERRAIN_EXPANSION_CARD_TEXTURE, Color(1.12, 1.10, 0.92, 1.0))
	var selected_style := _make_nine_slice_style(TERRAIN_EXPANSION_CARD_TEXTURE, Color(1.20, 1.10, 0.78, 1.0))
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", selected_style)
	button.add_theme_stylebox_override("focus", selected_style)
	button.add_theme_stylebox_override("disabled", normal_style)
	button.add_theme_color_override("font_color", Color("#f3edda"))
	button.add_theme_color_override("font_pressed_color", Color("#fff2c2"))

func _style_start_wave_button() -> void:
	var normal_style := _make_start_wave_style(Color.WHITE)
	var hover_style := _make_start_wave_style(Color(1.12, 1.08, 0.88, 1.0))
	var pressed_style := _make_start_wave_style(Color(0.78, 0.72, 0.58, 1.0))
	var disabled_style := _make_start_wave_style(Color(0.54, 0.54, 0.50, 0.85))
	_start_wave_button.add_theme_stylebox_override("normal", normal_style)
	_start_wave_button.add_theme_stylebox_override("hover", hover_style)
	_start_wave_button.add_theme_stylebox_override("pressed", pressed_style)
	_start_wave_button.add_theme_stylebox_override("focus", hover_style)
	_start_wave_button.add_theme_stylebox_override("disabled", disabled_style)
	_start_wave_button.add_theme_color_override("font_color", Color("#342419"))
	_start_wave_button.add_theme_color_override("font_hover_color", Color("#2d2016"))
	_start_wave_button.add_theme_color_override("font_pressed_color", Color("#2d2016"))
	_start_wave_button.custom_minimum_size = Vector2(0.0, 64.0)
	_start_wave_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_update_start_wave_button_size()

func _make_start_wave_style(tint: Color) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = START_ROUND_BUTTON_TEXTURE
	style.content_margin_left = 22.0
	style.content_margin_right = 22.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	style.draw_center = true
	style.modulate_color = tint
	return style

func _set_start_wave_button_text(button_text: String) -> void:
	_start_wave_button.text = button_text
	_update_start_wave_button_size()

func _update_start_wave_button_size() -> void:
	var button_font: Font = _start_wave_button.get_theme_font("font")
	var font_size: int = maxi(_start_wave_button.get_theme_font_size("font_size"), 1)
	var text_width: float = button_font.get_string_size(
		_start_wave_button.text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		font_size
	).x
	var target_width: float = maxf(188.0, text_width + 48.0)
	_start_wave_button.custom_minimum_size = Vector2(target_width, target_width / 3.0)

func _make_nine_slice_style(texture: Texture2D, tint: Color) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 42.0
	style.texture_margin_right = 42.0
	style.texture_margin_top = 42.0
	style.texture_margin_bottom = 42.0
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	style.draw_center = true
	style.modulate_color = tint
	return style

func _on_preview_hover_changed(local_coord: Vector2i, terrain_type: int, elevation: int) -> void:
	_hovered_coord = local_coord
	_has_hovered_cell = true
	_update_hovered_tower(local_coord)
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
	_update_hovered_tower(Vector2i.ZERO, false)
	_base.set_hovered(false)
	_hover_status.text = "Casilla del tablero (q,r): — · hover sobre cara superior"
	_piece_preview.set_tower_build_preview(false)

func _update_hovered_tower(coord: Vector2i, has_cell: bool = true) -> void:
	var next_tower: Tower = _build_controller.get_tower_at(coord) if has_cell else null
	if _hovered_tower == next_tower:
		return
	if _hovered_tower != null and is_instance_valid(_hovered_tower):
		_hovered_tower.set_hovered(false)
	_hovered_tower = next_tower if next_tower != null and is_instance_valid(next_tower) else null
	if _hovered_tower != null:
		_hovered_tower.set_hovered(true)

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
			return "PATH"
		HexCell.TerrainType.GRASS:
			return "GRASS"
		HexCell.TerrainType.MOUNTAIN:
			return "MOUNTAIN"
		_:
			return "UNKNOWN"
