extends Node2D

const HEX_RADIUS: float = 52.0
const CAMPAIGN_ROUND_COUNT: int = 45
const DEBUG_WAVE_START_INDEX: int = CAMPAIGN_ROUND_COUNT
const SPAWN_PORTAL_TEXTURE: Texture2D = preload("res://assets/sprites/terrain/spawn_portal.png")
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
const META_SHOP_PANEL_SCENE: PackedScene = preload("res://game/progression/meta_shop_panel.tscn")
const PAUSE_MENU_SCENE: PackedScene = preload("res://game/menu/pause_menu.tscn")
const MAIN_MENU_PATH: String = "res://game/menu/main_menu.tscn"
const DEBUG_HACKS_PANEL_SCENE: PackedScene = preload("res://game/ui/debug_hacks_panel.tscn")
const ICON_CATALOG_RESOURCE: Resource = preload("res://game/ui/resources/icon_catalog.tres")
const IMPACT_VFX_SCRIPT: Script = preload("res://game/vfx/animated_impact.gd")
const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")
const TOWER_ART_CATALOG_SCRIPT: Script = preload("res://game/towers/tower_art_catalog.gd")
const TOWER_ROSTER: TowerRosterData = preload("res://data/towers/tower_roster.tres")
const BALLISTA_TOWER: TowerData = preload("res://data/towers/ballista.tres")
const ARMOR_PIERCING_BOLT: TowerData = preload("res://data/towers/armor_piercing_bolt.tres")
const SAPPING_BOLT: TowerData = preload("res://data/towers/sapping_bolt.tres")
const STATUS_PROBE: TowerData = preload("res://data/towers/status_probe_m8.tres")
var TOWER_PROFILES: Array[TowerData] = []
const MIN_CAMERA_ZOOM: float = 0.45
const MAX_CAMERA_ZOOM: float = 2.5
const CAMERA_ZOOM_STEP: float = 1.12
const CAMERA_KEYBOARD_PAN_SPEED: float = 620.0
const CAMERA_PAN_KEYS: Array[int] = [KEY_W, KEY_A, KEY_S, KEY_D]
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
var _camera_pan_keys: Dictionary[int, bool] = {}
var _path_graph := PathGraph.new()
var _removed_spawn_endpoint_keys: Dictionary[String, bool] = {}
var _obstacles_removed_count: int = 0
var _selected_world_object_kind: StringName = &""
var _selected_obstacle_coord: Vector2i = Vector2i.ZERO
var _selected_spawn_endpoint_key: String = ""
var _path_debug_visible: bool = false
var _placement_enabled: bool = false
var _selected_wave: WaveData = FIRST_WAVE
var _active_wave_name: String = "Oleada básica"
var _campaign_round_number: int = 1
var _campaign_is_valid: bool = true
var _selected_wave_is_debug: bool = false
var _debug_return_phase: int = RunManager.Phase.ROUND_PREP
var _awaiting_campaign_expansion: bool = false
var _selected_tower_data: TowerData = BALLISTA_TOWER
var _combat_debug_timer: float = 0.0
var _hovered_coord: Vector2i = Vector2i.ZERO
var _has_hovered_cell: bool = false
var _terrain_rng := RandomNumberGenerator.new()
var _run_seed: int = 0
var _chest_spawn_chance: float = TERRAIN_VISUAL_CATALOG_SCRIPT.BASE_CHEST_CHANCE
var _offered_terrain_pieces: Array[TerrainPieceData] = []
var _offered_path_extension: Dictionary = {}
var _selected_expansion_piece: TerrainPieceData
var _placement_preview_board: Dictionary[Vector2i, HexCell] = {}
var _placement_blocks_future_path: bool = false
var _pending_expansion_round: int = 0
var _pending_expansion_reward: int = 0
var _upgrade_card_buttons: Array[Button] = []
var _upgrade_card_titles: Array[RichTextLabel] = []
var _upgrade_card_descriptions: Array[RichTextLabel] = []
var _upgrade_card_heading: Label
var _meta_shop_panel: CanvasLayer
@export var ui_icon_catalog: Resource = ICON_CATALOG_RESOURCE

var _icon_catalog: Resource
var _gold_feedback_tween: Tween
var _gold_feedback_direction: float = 1.0
var _camera_shake_tween: Tween
var _camera_shake_origin: Vector2 = Vector2.ZERO
var _cursor_textures: Dictionary[int, Texture2D] = {}
var _native_cursor_kind: int = -1
var _hovered_interactable_control: Control
var _tower_shortcut_names: Array[Label] = []
var _tower_shortcut_prices: Array[Label] = []
var _tower_shortcut_icons: Array[TextureRect] = []
var _tower_shortcut_icon_tweens: Dictionary[int, Tween] = {}
var _tower_upgrade_amounts: Array[Label] = []
var _tower_upgrade_effect_labels: Array[Label] = []
var _tower_upgrade_cost_icons: Array[TextureRect] = []
var _tower_upgrade_layer_icons: Array[TextureRect] = []
var _tower_upgrade_level_labels: Array[RichTextLabel] = []
var _tower_upgrade_xp_labels: Array[Label] = []
var _tower_upgrade_xp_bars: Array[ProgressBar] = []
var _tower_card_pulse_tween: Tween
var _tower_card_pulsing_index: int = -1
var _hovered_tower: Tower
var _debug_hacks_panel: CanvasLayer
@onready var _portal_wave_tooltip: PanelContainer = %PortalWaveTooltip
@onready var _portal_wave_tooltip_label: Label = %PortalWaveTooltipLabel
@onready var _portal_wave_tooltip_entries: VBoxContainer = %PortalWaveTooltipEntries
@onready var _cell_hover_tooltip: PanelContainer = %CellHoverTooltip
@onready var _cell_hover_tooltip_label: Label = %CellHoverTooltipLabel
var _hovered_spawn_portal: SpawnPortal
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
@onready var _tower_title: Label = %TowerTitle
@onready var _tower_level_label: RichTextLabel = %TowerLevel
@onready var _tower_portrait: TextureRect = %TowerPortrait
@onready var _hud: CanvasLayer = %HUD
@onready var _selection_backdrop: ColorRect = %SelectionBackdrop
@onready var _upgrade_card_panel: UpgradeOfferPanel = %UpgradeCardPanel
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
@onready var _feedback_vfx: Node2D = %FeedbackVfx
var _cursor_feedback_vfx: Node2D
@onready var _cloud_shadow_material: ShaderMaterial = %CloudShadowOverlay.material as ShaderMaterial
@onready var _rotate_left: Button = %RotateLeft
@onready var _rotate_right: Button = %RotateRight
@onready var _entities: Node2D = %Entities
@onready var _base: GameBase = %GameBase
@onready var _wave_director: WaveDirector = %WaveDirector
@onready var _base_health_bar: Control = %BaseHealthBar
@onready var _pause_button: Button = %PauseButton
@onready var _base_status: Label = %BaseStatus
@onready var _resources_row: Control = %ResourcesRow
@onready var _gold_icon: TextureRect = %GoldIcon
@onready var _gold_group: HBoxContainer = %GoldGroup
@onready var _gold_status: Label = %GoldStatus
@onready var _mana_status: Label = %ManaStatus
@onready var _wave_status: RichTextLabel = %WaveStatus
@onready var _round_progress: Control = %RoundProgress
@onready var _start_wave_button: Button = %StartWave
@onready var _build_controller: BuildController = %BuildController
@onready var _build_status: RichTextLabel = %BuildStatus
@onready var _tower_status: RichTextLabel = %TowerStatus
@onready var _combat_debug: RichTextLabel = %CombatDebug
@onready var _tower_actions: VBoxContainer = %TowerActions
@onready var _world_object_actions: VBoxContainer = %WorldObjectActions
@onready var _world_object_description: Label = %WorldObjectDescription
@onready var _world_object_enemy_scroll: ScrollContainer = %WorldObjectEnemyScroll
@onready var _world_object_enemy_list: VBoxContainer = %WorldObjectEnemyList
@onready var _remove_world_object_button: Button = %RemoveWorldObject
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
var _applied_run_card_base_health_bonus: int = 0
var _base_repair_rng := RandomNumberGenerator.new()
var _pause_menu: Node
var _run_end_in_progress: bool = false

func _ready() -> void:
	_ensure_cursor_feedback_layer()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	TOWER_PROFILES.assign(TOWER_ROSTER.profiles)
	_base_coord = STARTING_BOARD.get("base_coord")
	MetaProgression.call("configure_tower_catalog", TOWER_PROFILES)
	MetaProgression.call("set_debug_unlock_all_enabled", false)
	var current_run_seed: int = int(MetaProgression.call("begin_run"))
	RunManager.begin_run()
	_run_seed = current_run_seed
	_base_repair_rng.seed = current_run_seed ^ 728219
	_base.increase_maximum_health(int(MetaProgression.call("get_base_max_health_bonus")))
	_chest_spawn_chance = float(MetaProgression.call("get_chest_spawn_chance"))
	GameState.run_seed = current_run_seed
	GameState.current_round = 1
	_terrain_rng.seed = current_run_seed
	var run_number: int = int(MetaProgression.call("get_total_runs_started"))
	var starting_board_rotation_steps: int = posmod(run_number - 1, HexCoord.DIRECTION_OFFSETS.size())
	_camera.position = get_viewport_rect().size * 0.5
	_camera.make_current()
	_camera_shake_origin = _camera.offset
	_update_cloud_shadow_transform()
	_pieces = [
		STRAIGHT_PIECE, GENTLE_TURN_PIECE, HARD_TURN_PIECE, FORK_PIECE, CONVERGENCE_PIECE,
		MEADOW_HILLS_PIECE, MOUNTAIN_MASSIF_PIECE, OPEN_GRASSLAND_PIECE, STAGGERED_RIDGE_PIECE,
		MOUNTAIN_ISLET_PIECE, TWIN_PEAKS_PIECE, DEAD_END_SPUR_PIECE, CLIFF_TURN_PIECE,
		MEADOW_SWITCHBACK_PIECE, THREE_WAY_RAVINE_PIECE,
	]
	_rotate_left.pressed.connect(_rotate_by.bind(-1))
	_rotate_right.pressed.connect(_rotate_by.bind(1))
	_configure_hud_visuals()
	_terrain_card_panel.visibility_changed.connect(_sync_selection_backdrop)
	_upgrade_card_panel.visibility_changed.connect(_sync_selection_backdrop)
	_configure_cursors()
	_configure_hud_tooltips()
	for index in _terrain_card_buttons.size():
		_terrain_card_buttons[index].pressed.connect(_on_terrain_card_selected.bind(index))
	_configure_upgrade_card_panel()
	_meta_shop_panel = META_SHOP_PANEL_SCENE.instantiate() as MetaShopPanel
	_meta_shop_panel.call(
		"configure",
		TOWER_PROFILES,
		MetaProgression.call("get_permanent_upgrades")
	)
	add_child(_meta_shop_panel)
	_wire_interactable_cursors(_meta_shop_panel)
	_debug_hacks_panel = DEBUG_HACKS_PANEL_SCENE.instantiate() as DebugHacksPanel
	add_child(_debug_hacks_panel)
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
	_wave_director.enemy_killed.connect(_on_enemy_killed)
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
	_remove_world_object_button.pressed.connect(_on_remove_world_object_pressed)
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
	if not bool(_run_card_service.call(
		"configure",
		DEMO_CARD_POOL,
		unlocked_content_ids,
		current_run_seed,
		true,
		RunManager.get_run_tower_ids()
	)):
		push_error("No se pudo configurar el pool de cartas M11: %s" % _run_card_service.get("last_error"))
	_run_card_service.connect(&"modifiers_changed", _on_run_card_modifiers_changed)
	_pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(_pause_menu)
	_pause_menu.call("set_paused", false)
	_pause_menu.connect("resume_requested", _resume_from_pause)
	_pause_menu.connect("menu_requested", _return_to_menu_from_pause)
	_run_economy.call("set_run_card_service", _run_card_service)
	_sync_run_card_side_effects()
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
		TERRAIN_VISUAL_CATALOG_SCRIPT.set_random_cell_contents(
			cell_variant as HexCell,
			_run_seed,
			_chest_spawn_chance,
			_base_coord
		)
	TERRAIN_VISUAL_CATALOG_SCRIPT.enforce_starting_board_obstacles(starting_cells, _base_coord)
	_path_graph.rebuild(_board_grid.cells, _base_coord, int(STARTING_BOARD.get("minimum_spawn_route_cells")))
	_apply_removed_spawn_endpoints(_path_graph)
	if not _path_graph.is_valid:
		push_error("Grafo PATH inicial inválido: %s" % "; ".join(_path_graph.errors))

	_piece_preview.set_decoration_parent(_entities)
	_piece_preview.set_board_cells(_board_grid.cells)
	_piece_preview.set_path_graph(_path_graph)
	_populate_wave_options()
	_refresh_spawn_portal_previews()
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
	_sync_selection_backdrop()

func _sync_selection_backdrop() -> void:
	if _selection_backdrop == null:
		return
	var choosing_terrain: bool = _terrain_card_panel.visible and _selected_expansion_piece == null
	_selection_backdrop.visible = choosing_terrain or _upgrade_card_panel.visible

func _ensure_cursor_feedback_layer() -> void:
	if is_instance_valid(_cursor_feedback_vfx):
		return
	var cursor_layer := get_node_or_null("CursorFeedbackVfxLayer") as CanvasLayer
	if cursor_layer == null:
		cursor_layer = CanvasLayer.new()
		cursor_layer.name = "CursorFeedbackVfxLayer"
		cursor_layer.layer = 131
		cursor_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(cursor_layer)
	var cursor_vfx := cursor_layer.get_node_or_null("CursorFeedbackVfx") as Node2D
	if cursor_vfx == null:
		cursor_vfx = Node2D.new()
		cursor_vfx.name = "CursorFeedbackVfx"
		cursor_vfx.process_mode = Node.PROCESS_MODE_ALWAYS
		cursor_layer.add_child(cursor_vfx)
	_cursor_feedback_vfx = cursor_vfx

func _process(_delta: float) -> void:
	_update_camera_keyboard_pan(_delta)
	_update_cloud_shadow_transform()
	_position_portal_wave_tooltip()
	_update_cell_hover_tooltip()
	_combat_debug_timer -= _delta
	if _combat_debug_timer <= 0.0:
		_refresh_combat_debug()
		_refresh_tower_controls()
		_combat_debug_timer = 0.2
	_refresh_pointer_cursor()
	if _is_panning or not _placement_enabled or _build_controller.is_build_mode():
		return
	_update_anchor_from_mouse()

func _update_cloud_shadow_transform() -> void:
	if _cloud_shadow_material == null or _camera == null:
		return
	_cloud_shadow_material.set_shader_parameter("camera_world_position", _camera.global_position)
	_cloud_shadow_material.set_shader_parameter("viewport_size", get_viewport_rect().size)
	_cloud_shadow_material.set_shader_parameter("camera_zoom", _camera.zoom.x)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		_track_camera_pan_key(event as InputEventKey)
	if _is_terrain_selection_locked():
		if event is InputEventKey:
			var restricted_key := event as InputEventKey
			if restricted_key.pressed and not restricted_key.echo:
				if restricted_key.keycode in [KEY_H, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]:
					get_viewport().set_input_as_handled()
					return
				if restricted_key.ctrl_pressed and restricted_key.keycode in [KEY_K, KEY_D]:
					get_viewport().set_input_as_handled()
					return
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
			var shortcut_number: int = _tower_shortcut_number_for_keycode(int(key_event.keycode))
			if shortcut_number > 0:
				var profile_index: int = _tower_profile_index_for_shortcut(shortcut_number)
				if profile_index >= 0:
					_select_tower_and_build(profile_index)
					get_viewport().set_input_as_handled()
					return
				if shortcut_number <= 7:
					get_viewport().set_input_as_handled()
					return
			match key_event.keycode:
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
		if _meta_shop_panel != null and bool(_meta_shop_panel.call("is_open")):
			get_viewport().set_input_as_handled()
			return
		_toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event == null or not key_event.pressed or key_event.echo:
			return
		if key_event.ctrl_pressed and key_event.keycode == KEY_D:
			if _is_terrain_selection_locked():
				get_viewport().set_input_as_handled()
				return
			_toggle_path_debug()
			get_viewport().set_input_as_handled()
			return
		match key_event.keycode:
			KEY_Q:
				_rotate_by(-1)
				get_viewport().set_input_as_handled()
			KEY_E:
				_rotate_by(1)
				get_viewport().set_input_as_handled()
			KEY_T:
				_place_selected_piece_automatically()
				get_viewport().set_input_as_handled()
			KEY_R:
				_reset_camera()
				get_viewport().set_input_as_handled()
			KEY_F3:
				if _is_terrain_selection_locked():
					get_viewport().set_input_as_handled()
					return
				_toggle_terrain_panel()
				get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event == null:
			return
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if _is_terrain_piece_placement_active() and mouse_event.ctrl_pressed:
				_rotate_by(-1)
			else:
				_zoom_at_cursor(CAMERA_ZOOM_STEP)
			get_viewport().set_input_as_handled()
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if _is_terrain_piece_placement_active() and mouse_event.ctrl_pressed:
				_rotate_by(1)
			else:
				_zoom_at_cursor(1.0 / CAMERA_ZOOM_STEP)
			get_viewport().set_input_as_handled()
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_handle_board_click()
			get_viewport().set_input_as_handled()
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_active_tool()
			get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_camera_pan_keys.clear()

func _track_camera_pan_key(key_event: InputEventKey) -> void:
	var physical_key: int = int(key_event.physical_keycode)
	if physical_key == 0:
		physical_key = int(key_event.keycode)
	if not CAMERA_PAN_KEYS.has(physical_key) or key_event.echo:
		return
	if key_event.ctrl_pressed:
		_camera_pan_keys.erase(physical_key)
		return
	_camera_pan_keys[physical_key] = key_event.pressed

func _update_camera_keyboard_pan(delta: float) -> void:
	if _camera_pan_keys.is_empty():
		return
	if _meta_shop_panel != null and bool(_meta_shop_panel.call("is_open")):
		return
	if _debug_hacks_panel != null and _debug_hacks_panel.visible:
		return
	var focus_owner: Control = get_viewport().gui_get_focus_owner() as Control
	if focus_owner is LineEdit or focus_owner is TextEdit:
		return
	var direction := Vector2(
		float(int(_camera_pan_keys.get(KEY_D, false)) - int(_camera_pan_keys.get(KEY_A, false))),
		float(int(_camera_pan_keys.get(KEY_S, false)) - int(_camera_pan_keys.get(KEY_W, false)))
	)
	if direction.is_zero_approx():
		return
	_camera.position += direction.normalized() * CAMERA_KEYBOARD_PAN_SPEED * delta / _camera.zoom.x

func _toggle_hud() -> void:
	_hud.visible = not _hud.visible
	if not _hud.visible:
		_hide_portal_wave_tooltip()
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
		&"skip_to_cards":
			_debug_skip_to_next_card_offer()
		&"open_general_upgrades":
			if _meta_shop_panel != null:
				_meta_shop_panel.call("present_for_debug")
		&"start_wave":
			_start_selected_wave()
		&"restart_run":
			_on_new_run_requested()
		&"restart_clean_run":
			var refunded_meta: int = int(MetaProgression.call("reset_permanent_upgrades_for_clean_run"))
			if refunded_meta < 0:
				_wave_status.text = "No se pudo iniciar una run limpia: %s" % String(MetaProgression.call("get_save_error"))
			else:
				get_tree().reload_current_scene()
	_refresh_tower_controls()

func _debug_skip_to_next_card_offer() -> void:
	if _selected_wave_is_debug or RunManager.phase not in [RunManager.Phase.ROUND_PREP, RunManager.Phase.TERRAIN_EXPANSION]:
		_wave_status.text = "El salto a cards solo está disponible entre rondas de campaña."
		return
	var offer_round: int = -1
	for candidate_round in range(maxi(_campaign_round_number, 1), CAMPAIGN_ROUND_COUNT):
		if bool(_run_card_service.call("should_offer_after", candidate_round)):
			offer_round = candidate_round
			break
	if offer_round < 0:
		_wave_status.text = "No quedan ofertas de cartas en esta campaña."
		return
	var offer_wave: WaveData = _get_campaign_round(offer_round)
	var upgrade_cards: Array[Resource] = _run_card_service.call("create_offer", offer_round)
	if (
		offer_wave == null
		or upgrade_cards.size() != CardPoolData.FIXED_OFFER_SIZE
		or _upgrade_card_buttons.size() < CardPoolData.FIXED_OFFER_SIZE
	):
		_wave_status.text = "No se pudo crear la oferta de depuración: %s" % String(_run_card_service.get("last_error"))
		return
	if _build_controller.is_build_mode():
		_build_controller.cancel_build_mode()
	_campaign_round_number = offer_round
	_selected_wave = offer_wave
	_selected_wave_is_debug = false
	_set_campaign_wave_name()
	_wave_selector.select(offer_round - 1)
	_round_progress.call("set_progress", offer_round, offer_round - 1)
	GameState.current_round = offer_round
	_pending_expansion_round = offer_round
	_pending_expansion_reward = 0
	_awaiting_campaign_expansion = false
	_placement_enabled = false
	_selected_expansion_piece = null
	_offered_terrain_pieces.clear()
	_offered_path_extension.clear()
	_terrain_card_panel.hide()
	_present_upgrade_card_offer(offer_round, upgrade_cards)

func _configure_hud_visuals() -> void:
	_icon_catalog = ui_icon_catalog
	_configure_tower_shortcut_visuals()
	_configure_tower_upgrade_visuals()
	_gold_group.pivot_offset = _gold_group.size * 0.5

func _configure_cursors() -> void:
	var cursor_icon_ids: Array[StringName] = [
		&"cursor_default",
		&"cursor_interact",
		&"cursor_invalid",
		&"cursor_build",
	]
	for cursor_index in cursor_icon_ids.size():
		_cursor_textures[cursor_index] = _icon_catalog.call("get_icon", cursor_icon_ids[cursor_index]) as Texture2D
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
		return
	_build_cursor_overlay.call("deactivate")
	if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if cursor_texture == null:
		return
	if cursor_kind == _native_cursor_kind:
		return
	var hotspot := Vector2(13.0, 11.0)
	if cursor_kind == CursorKind.TOWER_PLACEMENT:
		hotspot = cursor_texture.get_size() * 0.5
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
	_native_cursor_kind = cursor_kind

func _configure_tower_shortcut_visuals() -> void:
	_tower_shortcut_names.clear()
	_tower_shortcut_prices.clear()
	_tower_shortcut_icons.clear()
	for index in _tower_shortcut_buttons.size():
		var shortcut_button: Button = _tower_shortcut_buttons[index]
		var shortcut_card := shortcut_button as TowerShortcutCard
		shortcut_card.tower_icon_texture = _get_tower_display_texture(StringName(TOWER_PROFILES[index].id))
		shortcut_card.set_tower_visuals(
			TOWER_PROFILES[index].display_name,
			TOWER_PROFILES[index].visual_color
		)
		_tower_shortcut_icons.append(shortcut_card.tower_icon)
		_tower_shortcut_names.append(shortcut_card.name_label)
		_tower_shortcut_prices.append(shortcut_card.price_label)

func _get_tower_display_texture(tower_id: StringName) -> Texture2D:
	var tower_texture: Texture2D = TOWER_ART_CATALOG_SCRIPT.get_tower_texture(tower_id)
	if tower_texture != null:
		return tower_texture
	return _icon_catalog.call("get_tower_icon", tower_id) as Texture2D

func _configure_tower_upgrade_visuals() -> void:
	_tower_upgrade_amounts.clear()
	_tower_upgrade_effect_labels.clear()
	_tower_upgrade_cost_icons.clear()
	_tower_upgrade_layer_icons.clear()
	_tower_upgrade_level_labels.clear()
	_tower_upgrade_xp_labels.clear()
	_tower_upgrade_xp_bars.clear()
	var layer_names: Array[String] = ["Health", "Armor", "Shield"]
	for layer in _tower_upgrade_buttons.size():
		var button := _tower_upgrade_buttons[layer] as TowerLayerUpgradeButton
		button.text = ""
		button.custom_minimum_size = Vector2(96.0, 98.0)
		var layer_icon: TextureRect = button.layer_icon
		layer_icon.custom_minimum_size = Vector2(32.0, 32.0)
		var level_label: RichTextLabel = button.level_label
		level_label.add_theme_color_override("default_color", _hp_layer_color(layer))
		var xp_bar: ProgressBar = button.xp_bar
		var xp_background := StyleBoxFlat.new()
		xp_background.bg_color = Color("#1c252b")
		xp_background.set_corner_radius_all(4)
		var xp_fill := StyleBoxFlat.new()
		xp_fill.bg_color = _hp_layer_color(layer)
		xp_fill.set_corner_radius_all(4)
		xp_bar.add_theme_stylebox_override("background", xp_background)
		xp_bar.add_theme_stylebox_override("fill", xp_fill)
		var xp_label: Label = button.xp_label
		var effect_label: Label = button.effect_label
		effect_label.text = "+1 %s" % layer_names[layer]
		effect_label.add_theme_color_override("font_color", _hp_layer_color(layer))
		var cost_icon: TextureRect = button.cost_icon
		var amount_label: Label = button.amount_label
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

func _fit_tower_info_panel() -> void:
	if not is_instance_valid(_tower_info_panel) or not _tower_info_panel.visible:
		return
	var viewport_size: Vector2 = _tower_info_panel.get_viewport_rect().size
	var panel_top: float = 76.0
	var panel_width: float = minf(460.0, maxf(280.0, viewport_size.x - 48.0))
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
	_rotate_left.tooltip_text = "Gira la pieza 60 grados en sentido antihorario. Atajo: Q; también Ctrl+rueda arriba."
	_rotate_right.tooltip_text = "Gira la pieza 60 grados en sentido horario. Atajo: E; también Ctrl+rueda abajo."
	_confirm_button.tooltip_text = "Confirma la pieza si el preview indica que su posición es válida."
	_cancel_button.tooltip_text = "Cancela la colocación activa. También puedes pulsar Esc o clic derecho."
	_combat_debug.tooltip_text = "Inspección técnica de capas, regeneración, daño previsto y estados del objetivo."
	_build_status.tooltip_text = "Estado de construcción, recompensa reciente o motivo de rechazo."
	_start_wave_button.tooltip_text = "Inicia la ronda activa de la campaña."
	for slot in _tower_priority_buttons.size():
		_tower_priority_buttons[slot].tooltip_text = "Criterio de prioridad %d. El siguiente criterio solo decide empates." % (slot + 1)
	for layer in _tower_upgrade_buttons.size():
		_tower_upgrade_buttons[layer].tooltip_text = "Mejora el multiplicador de daño de %s." % _hp_layer_name(layer)
	_demolish_tower_button.tooltip_text = "Retira la torre seleccionada y devuelve Gold según el precio de su tipo y cuántas haya en el mapa. No reembolsa niveles ni mejoras."

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
		var center: Vector2 = _piece_preview.to_global(
			HexMath.axial_to_world(HexCoord.new(coord.x, coord.y), HEX_RADIUS)
		)
		center.y -= float(cell.elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
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

func _is_terrain_piece_placement_active() -> bool:
	return _placement_enabled and _selected_piece != null and not _build_controller.is_build_mode()

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
	_placement_status.remove_theme_color_override("font_color")
	if RunManager.phase == RunManager.Phase.CARD_OFFER:
		_latest_placement = null
		_placement_path_graph = null
		_placement_preview_board.clear()
		_placement_blocks_future_path = false
		_piece_preview.set_placement_preview(null, _anchor_coord, _rotation_steps, false, false)
		_refresh_spawn_portal_previews()
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
		_placement_preview_board.clear()
		_placement_blocks_future_path = false
		_piece_preview.set_placement_preview(null, _anchor_coord, _rotation_steps, false, false)
		_refresh_spawn_portal_previews()
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
	_placement_preview_board.clear()
	_placement_blocks_future_path = false
	var placement_is_valid: bool = _latest_placement.is_valid
	if placement_is_valid and can_edit_terrain:
		_placement_path_graph = _build_placement_preview_graph()
		placement_is_valid = _placement_path_graph.is_valid
		if placement_is_valid and is_campaign_card_placement:
			_placement_blocks_future_path = _find_path_extension_option(
				_placement_preview_board,
				_placement_path_graph,
				null,
				false
			).is_empty()
			placement_is_valid = not _placement_blocks_future_path
	_piece_preview.set_placement_preview(
		_selected_piece,
		_anchor_coord,
		_rotation_steps,
		placement_is_valid,
		can_edit_terrain,
		_placement_path_graph,
		_base_coord,
		_run_seed,
		_placement_preview_board
	)
	_refresh_spawn_portal_previews()
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
		if _placement_path_graph != null:
			placement_message += " · " + _spawn_preview_summary(_placement_path_graph)
		if _placement_blocks_future_path:
			placement_message += " · No deja ninguna pieza legal para alargar el camino; cambia la posición."
	var closes_spawn: bool = (
		_latest_placement.is_valid
		and _placement_path_graph != null
		and _get_closed_spawn_count(_placement_path_graph) > 0
	)
	if closes_spawn or _placement_blocks_future_path:
		_placement_status.add_theme_color_override("font_color", Color("#ff8178"))
	else:
		_placement_status.remove_theme_color_override("font_color")
	_placement_status.text = "%s · conexiones: %d" % [
		placement_message,
		_latest_placement.path_connection_count,
	]

func _place_selected_piece_automatically() -> void:
	if (
		not _placement_enabled
		or _selected_piece == null
		or _build_controller.is_build_mode()
		or RunManager.phase == RunManager.Phase.CARD_OFFER
	):
		return
	var candidate: Dictionary = _find_automatic_placement_candidate()
	if candidate.is_empty():
		var no_position_message: String = "Q no encontró una posición válida. Coloca la pieza manualmente."
		_placement_status.text = no_position_message
		_placement_status.add_theme_color_override("font_color", Color("#ff8178"))
		_wave_status.text = no_position_message
		return
	_anchor_coord = candidate.get("anchor_coord", _anchor_coord)
	_rotation_steps = int(candidate.get("rotation_steps", _rotation_steps))
	_refresh_placement()
	if (
		_latest_placement != null
		and _latest_placement.is_valid
		and _placement_path_graph != null
		and _placement_path_graph.is_valid
		and not _placement_blocks_future_path
	):
		_confirm_placement()
	elif _placement_enabled and _selected_piece != null:
		_wave_status.text = "Q no pudo confirmar la pieza. Ajusta la posición manualmente."

func _find_automatic_placement_candidate() -> Dictionary:
	if _selected_piece == null or _board_grid.cells.is_empty():
		return {}
	var candidates: Array[Dictionary] = []
	var seen_candidates: Dictionary[String, bool] = {}
	for rotation_step in range(6):
		for piece_cell in _selected_piece.rotated_cells(rotation_step):
			for board_coord in _board_grid.cells:
				for neighbor_offset in HexCoord.DIRECTION_OFFSETS:
					var candidate_anchor: Vector2i = board_coord + neighbor_offset - piece_cell.local_coord
					var candidate_key: String = "%d:%d:%d" % [rotation_step, candidate_anchor.x, candidate_anchor.y]
					if seen_candidates.has(candidate_key):
						continue
					seen_candidates[candidate_key] = true
					candidates.append({
						"anchor_coord": candidate_anchor,
						"rotation_steps": rotation_step,
					})
	for index in range(candidates.size() - 1, 0, -1):
		var swap_index: int = _terrain_rng.randi_range(0, index)
		var candidate_to_swap: Dictionary = candidates[index]
		candidates[index] = candidates[swap_index]
		candidates[swap_index] = candidate_to_swap
	var is_campaign_card_placement: bool = (
		_awaiting_campaign_expansion
		and RunManager.phase == RunManager.Phase.TERRAIN_EXPANSION
		and _selected_expansion_piece != null
	)
	var minimum_route_cells: int = int(STARTING_BOARD.get("minimum_spawn_route_cells"))
	for candidate in candidates:
		var candidate_anchor: Vector2i = candidate.get("anchor_coord", Vector2i.ZERO)
		var candidate_rotation: int = int(candidate.get("rotation_steps", 0))
		var placement: TerrainPlacementResult = TerrainPlacementValidator.evaluate(
			_selected_piece,
			candidate_anchor,
			candidate_rotation,
			_board_grid.cells
		)
		if not placement.is_valid:
			continue
		var candidate_board: Dictionary[Vector2i, HexCell] = _build_candidate_board(
			_board_grid.cells,
			_selected_piece,
			candidate_anchor,
			candidate_rotation
		)
		var candidate_graph := PathGraph.new()
		candidate_graph.rebuild(candidate_board, _base_coord, minimum_route_cells)
		_apply_removed_spawn_endpoints(candidate_graph)
		if not candidate_graph.is_valid:
			continue
		if is_campaign_card_placement and _find_path_extension_option(
			candidate_board,
			candidate_graph,
			null,
			false
		).is_empty():
			continue
		return candidate
	return {}

func _build_placement_preview_graph() -> PathGraph:
	_placement_preview_board = _build_candidate_board(
		_board_grid.cells,
		_selected_piece,
		_anchor_coord,
		_rotation_steps,
		_next_piece_instance_id,
		_awaiting_campaign_expansion
	)
	var candidate_graph := PathGraph.new()
	candidate_graph.rebuild(
		_placement_preview_board,
		_base_coord,
		int(STARTING_BOARD.get("minimum_spawn_route_cells"))
	)
	_apply_removed_spawn_endpoints(candidate_graph)
	return candidate_graph

func _build_candidate_board(
	board_cells: Dictionary[Vector2i, HexCell],
	piece: TerrainPieceData,
	anchor_coord: Vector2i,
	rotation_steps: int,
	piece_instance_id: int = -1,
	campaign_expansion: bool = false
) -> Dictionary[Vector2i, HexCell]:
	var candidate_board: Dictionary[Vector2i, HexCell] = {}
	for coord in board_cells:
		candidate_board[coord] = board_cells[coord]
	var piece_cells: Dictionary[Vector2i, HexCell] = TerrainPlacementValidator.instantiate_cells(
		piece,
		anchor_coord,
		rotation_steps,
		piece_instance_id
	)
	for coord in piece_cells:
		var placed_cell: HexCell = piece_cells[coord]
		TERRAIN_VISUAL_CATALOG_SCRIPT.constrain_base_adjacent_cell(
			placed_cell,
			_base_coord,
			_run_seed
		)
		if campaign_expansion:
			TERRAIN_VISUAL_CATALOG_SCRIPT.set_random_visual_variant(placed_cell, _run_seed)
			TERRAIN_VISUAL_CATALOG_SCRIPT.roll_chest_at_placement(
				placed_cell,
				_run_seed,
				_chest_spawn_chance
			)
		else:
			TERRAIN_VISUAL_CATALOG_SCRIPT.set_random_cell_contents(
				placed_cell,
				_run_seed,
				_chest_spawn_chance,
				_base_coord
			)
	TERRAIN_VISUAL_CATALOG_SCRIPT.limit_hex_cell_obstacles(piece_cells, 2)
	for coord in piece_cells:
		candidate_board[coord] = piece_cells[coord]
	var candidate_grid := HexGrid.new()
	candidate_grid.cells = candidate_board
	for hole_coord in candidate_grid.get_enclosed_void_coords():
		# El tipo de relleno no cambia el grafo porque solo PATH tiene conexiones.
		var preview_fill: HexCell = _create_auto_fill_cell(hole_coord)
		candidate_board[hole_coord] = preview_fill
	return candidate_board

func _find_path_extension_option(
	board_cells: Dictionary[Vector2i, HexCell],
	source_graph: PathGraph,
	piece_filter: TerrainPieceData = null,
	require_followup: bool = false
) -> Dictionary:
	var option: Dictionary = {}
	if source_graph == null or not source_graph.is_valid:
		return option
	var source_endpoint_keys: Dictionary = _get_spawn_endpoint_keys(source_graph)
	var pieces_to_check: Array[TerrainPieceData] = []
	if piece_filter != null:
		pieces_to_check.append(piece_filter)
	else:
		pieces_to_check.append_array(_pieces)
		_shuffle_piece_candidates(pieces_to_check)
	var minimum_route_cells: int = int(STARTING_BOARD.get("minimum_spawn_route_cells"))
	for source_route in source_graph.routes:
		if source_route == null or not source_route.is_reachable or source_route.spawn_endpoint == null:
			continue
		var source_endpoint: PathEndpoint = source_route.spawn_endpoint
		var target_coord: Vector2i = source_endpoint.outside_coord
		var incoming_direction: int = posmod(source_endpoint.edge_direction + 3, 6)
		for piece in pieces_to_check:
			if piece == null:
				continue
			var rotations: Array[int] = [0, 1, 2, 3, 4, 5]
			_shuffle_int_candidates(rotations)
			for rotation_step in rotations:
				for rotated_cell in piece.rotated_cells(rotation_step):
					if rotated_cell.terrain_type != HexCell.TerrainType.PATH:
						continue
					if not _piece_cell_offers_path_edge(rotated_cell, incoming_direction):
						continue
					var anchor_coord: Vector2i = target_coord - rotated_cell.local_coord
					var placement: TerrainPlacementResult = TerrainPlacementValidator.evaluate(
						piece,
						anchor_coord,
						rotation_step,
						board_cells
					)
					if not placement.is_valid:
						continue
					var candidate_board: Dictionary[Vector2i, HexCell] = _build_candidate_board(
						board_cells,
						piece,
						anchor_coord,
						rotation_step
					)
					var candidate_graph := PathGraph.new()
					candidate_graph.rebuild(candidate_board, _base_coord, minimum_route_cells)
					_apply_removed_spawn_endpoints(candidate_graph)
					if not candidate_graph.is_valid:
						continue
					var extension_route: PathRoute
					for candidate_route in candidate_graph.get_active_routes():
						if candidate_route == null or not candidate_route.is_reachable or candidate_route.spawn_endpoint == null:
							continue
						var candidate_endpoint: PathEndpoint = candidate_route.spawn_endpoint
						var candidate_key: String = _get_spawn_endpoint_key(candidate_endpoint)
						if source_endpoint_keys.has(candidate_key):
							continue
						if not candidate_route.cells.has(target_coord):
							continue
						if candidate_route.cells.size() <= source_route.cells.size():
							continue
						extension_route = candidate_route
						break
					if extension_route == null:
						continue
					if require_followup:
						var followup_option: Dictionary = _find_path_extension_option(
							candidate_board,
							candidate_graph,
							null,
							false
						)
						if followup_option.is_empty():
							continue
					return {
						"piece": piece,
						"anchor_coord": anchor_coord,
						"rotation_steps": rotation_step,
						"connected_coord": target_coord,
						"route_length": extension_route.cells.size(),
					}
	return option

func _shuffle_piece_candidates(values: Array[TerrainPieceData]) -> void:
	for index in range(values.size() - 1, 0, -1):
		var swap_index: int = _terrain_rng.randi_range(0, index)
		var piece: TerrainPieceData = values[index]
		values[index] = values[swap_index]
		values[swap_index] = piece

func _shuffle_int_candidates(values: Array[int]) -> void:
	for index in range(values.size() - 1, 0, -1):
		var swap_index: int = _terrain_rng.randi_range(0, index)
		var value: int = values[index]
		values[index] = values[swap_index]
		values[swap_index] = value

func _piece_cell_offers_path_edge(cell: TerrainPieceCellData, direction_index: int) -> bool:
	return (
		(cell.path_edges & (1 << direction_index)) != 0
		or (cell.flexible_path_edges & (1 << direction_index)) != 0
	)

func _get_closed_spawn_count(candidate_graph: PathGraph) -> int:
	var current_keys: Dictionary = _get_spawn_endpoint_keys(_path_graph)
	var candidate_keys: Dictionary = _get_spawn_endpoint_keys(candidate_graph)
	var closed_count: int = 0
	for key in current_keys:
		if not candidate_keys.has(key):
			closed_count += 1
	return closed_count

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
	if closed_count > 0:
		return "¡AVISO! Se cerrarán %d spawns; quedarán %d. Las X rojas indican cuáles." % [
			closed_count,
			candidate_keys.size(),
		]
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
	for route in graph.get_active_routes():
		var endpoint: PathEndpoint = route.spawn_endpoint
		keys[_get_spawn_endpoint_key(endpoint)] = true
	return keys

func _apply_removed_spawn_endpoints(graph: PathGraph) -> void:
	if graph == null:
		return
	for endpoint_key in _removed_spawn_endpoint_keys:
		graph.set_spawn_endpoint_removed(endpoint_key, true)

func _get_spawn_endpoint_key(endpoint: PathEndpoint) -> String:
	return PathGraph.get_spawn_endpoint_key(endpoint)

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
	var confirmed_campaign_expansion: bool = (
		_awaiting_campaign_expansion
		and RunManager.phase == RunManager.Phase.TERRAIN_EXPANSION
	)
	if _placement_preview_board.is_empty():
		_placement_status.text = "No se confirma: falta el snapshot exacto de la vista previa."
		return
	var candidate_board: Dictionary[Vector2i, HexCell] = {}
	for coord in _placement_preview_board:
		candidate_board[coord] = _placement_preview_board[coord]
	var cells_to_add: Dictionary[Vector2i, HexCell] = {}
	for coord in candidate_board:
		if not _board_grid.cells.has(coord):
			cells_to_add[coord] = candidate_board[coord]
	var candidate_graph := PathGraph.new()
	candidate_graph.rebuild(candidate_board, _base_coord, int(STARTING_BOARD.get("minimum_spawn_route_cells")))
	_apply_removed_spawn_endpoints(candidate_graph)
	if not candidate_graph.is_valid:
		_placement_status.text = "No se confirma: red PATH inválida · %s" % "; ".join(candidate_graph.errors)
		return
	if confirmed_campaign_expansion:
		var next_path_option: Dictionary = _find_path_extension_option(
			candidate_board,
			candidate_graph,
			null,
			false
		)
		if next_path_option.is_empty():
			_placement_blocks_future_path = true
			_placement_status.add_theme_color_override("font_color", Color("#ff8178"))
			_placement_status.text = "No se confirma: esta posición te dejaría sin ninguna pieza para alargar el camino. Cambia la posición."
			return
	if not _board_grid.add_cells(cells_to_add):
		_placement_status.text = "La pieza dejó de encajar antes de confirmar."
		return
	_spawn_impact_vfx(&"terrain_piece_placed", _cells_centroid_world(cells_to_add, candidate_board))
	_path_graph = candidate_graph
	_next_piece_instance_id += 1
	_piece_preview.set_board_cells(_board_grid.cells)
	_piece_preview.set_path_graph(_path_graph)
	_refresh_path_status()
	_refresh_campaign_option_counts()
	if confirmed_campaign_expansion:
		_awaiting_campaign_expansion = false
		_selected_expansion_piece = null
		_offered_terrain_pieces.clear()
		_offered_path_extension.clear()
		_terrain_card_panel.hide()
	_cancel_placement()
	if confirmed_campaign_expansion:
		_placement_enabled = false
		if _offer_campaign_upgrade_cards_if_scheduled(_pending_expansion_round):
			return
		_prepare_next_campaign_round()
		return

func _offer_campaign_upgrade_cards_if_scheduled(round_number: int) -> bool:
	if not bool(_run_card_service.call("should_offer_after", round_number)):
		return false
	var upgrade_cards: Array[Resource] = _run_card_service.call("create_offer", round_number)
	if (
		upgrade_cards.size() != CardPoolData.FIXED_OFFER_SIZE
		or _upgrade_card_buttons.size() < CardPoolData.FIXED_OFFER_SIZE
	):
		var offer_error: String = String(_run_card_service.get("last_error"))
		if offer_error.is_empty():
			offer_error = "Se recibieron %d cartas; la oferta requiere exactamente %d." % [
				upgrade_cards.size(),
				CardPoolData.FIXED_OFFER_SIZE,
			]
		push_error("No se pudo crear oferta M11: %s" % offer_error)
		_wave_status.text = "No se pudo preparar la oferta de mejoras · %s" % offer_error
		_start_wave_button.disabled = true
		return true
	_present_upgrade_card_offer(round_number, upgrade_cards)
	_refresh_placement()
	_refresh_tower_controls()
	return true

func _create_auto_fill_cell(coord: Vector2i) -> HexCell:
	var fill_rng := RandomNumberGenerator.new()
	fill_rng.seed = hash("%d:%d:%d:101" % [_run_seed, coord.x, coord.y])
	var fill_mountain: bool = fill_rng.randi_range(0, 1) == 1
	var cell := HexCell.new(HexCoord.new(coord.x, coord.y))
	cell.terrain_type = HexCell.TerrainType.MOUNTAIN if fill_mountain else HexCell.TerrainType.GRASS
	cell.elevation = 2 if fill_mountain else 1
	cell.buildable = true
	cell.visual_variant = &"auto_filled_void"
	TERRAIN_VISUAL_CATALOG_SCRIPT.set_random_cell_contents(
		cell,
		_run_seed,
		_chest_spawn_chance,
		_base_coord
	)
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
	if _is_terrain_selection_locked():
		if _placement_enabled and _selected_expansion_piece != null:
			_confirm_placement()
		return
	if not _placement_enabled and _has_hovered_cell:
		var object_cell: HexCell = _board_grid.cells.get(_hovered_coord) as HexCell
		if object_cell != null and object_cell.obstacle_type != HexCell.ObstacleType.NONE:
			_select_obstacle(_hovered_coord)
			return
	if not _placement_enabled and _has_hovered_cell:
		var hovered_cell: HexCell = _board_grid.cells.get(_hovered_coord) as HexCell
		if hovered_cell != null and hovered_cell.chest_available:
			_clear_selected_world_object()
			_open_treasure_chest(hovered_cell)
			return
	if not _placement_enabled and _has_hovered_cell and _hovered_coord == _base_coord:
		_play_ui_click_vfx()
	if _build_controller.is_build_mode():
		if not _has_hovered_cell:
			_build_status.text = "Coloca el cursor sobre una casilla existente."
			return
		if _build_controller.get_tower_at(_hovered_coord) != null:
			_play_ui_click_vfx()
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
			_play_ui_click_vfx()
			_clear_selected_world_object()
			if _selected_expansion_piece == null:
				_cancel_placement()
			_build_controller.select_tower_at(_hovered_coord)
			_refresh_tower_controls()
			return
	if _selected_world_object_kind != &"":
		_clear_selected_world_object()
		_refresh_tower_controls()
	if _build_controller.selected_tower != null:
		_build_controller.clear_selection()
		_refresh_tower_controls()
	if _placement_enabled:
		_confirm_placement()

func _open_treasure_chest(cell: HexCell) -> void:
	if cell == null or not cell.chest_available:
		return
	var chest_position: Vector2 = _get_cell_world_position(_hovered_coord, cell)
	_play_ui_click_vfx()
	_spawn_impact_vfx(&"coin_burst_gold", chest_position)
	_spawn_impact_vfx(&"chest_pickup", chest_position)
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
	if gold_awarded <= 0:
		_play_gold_feedback(true)
	_piece_preview.refresh_cell_decorations()
	_piece_preview.queue_redraw()
	_refresh_tower_controls()

func _select_obstacle(coord: Vector2i) -> void:
	var cell: HexCell = _board_grid.cells.get(coord) as HexCell
	if cell == null or cell.obstacle_type == HexCell.ObstacleType.NONE:
		return
	_play_ui_click_vfx()
	_selected_world_object_kind = &"obstacle"
	_selected_obstacle_coord = coord
	_selected_spawn_endpoint_key = ""
	if _build_controller.selected_tower != null:
		_build_controller.clear_selection()
	_refresh_tower_controls()

func _on_spawn_portal_selected(portal_node: Node2D) -> void:
	var portal := portal_node as SpawnPortal
	if portal == null or not is_instance_valid(portal) or _is_terrain_selection_locked():
		return
	_play_ui_click_vfx()
	_selected_world_object_kind = &"portal"
	_selected_spawn_endpoint_key = portal.get_endpoint_key()
	_selected_obstacle_coord = Vector2i.ZERO
	if _build_controller.selected_tower != null:
		_build_controller.clear_selection()
	_populate_spawn_enemy_list(portal.get_wave_preview_entries())
	_refresh_tower_controls()

func _clear_selected_world_object() -> void:
	_selected_world_object_kind = &""
	_selected_obstacle_coord = Vector2i.ZERO
	_selected_spawn_endpoint_key = ""
	_populate_spawn_enemy_list([])

func _has_selected_world_object() -> bool:
	match _selected_world_object_kind:
		&"obstacle":
			var cell: HexCell = _board_grid.cells.get(_selected_obstacle_coord) as HexCell
			return cell != null and cell.obstacle_type != HexCell.ObstacleType.NONE
		&"portal":
			return (
				not _selected_spawn_endpoint_key.is_empty()
				and not _removed_spawn_endpoint_keys.has(_selected_spawn_endpoint_key)
				and _path_graph.get_active_spawn_count() > 0
				and _get_spawn_portal_by_key(_selected_spawn_endpoint_key) != null
			)
	return false

func _get_spawn_portal_by_key(endpoint_key: String) -> SpawnPortal:
	for portal in _piece_preview.get_spawn_portals():
		if portal.get_endpoint_key() == endpoint_key:
			return portal
	return null

func _next_obstacle_removal_cost() -> int:
	var next_removal_number: int = _obstacles_removed_count + 1
	return 25 * next_removal_number * next_removal_number

func _world_object_removal_cost() -> int:
	var obstacle_cost: int = _next_obstacle_removal_cost()
	return obstacle_cost * 2 if _selected_world_object_kind == &"portal" else obstacle_cost

func _refresh_world_object_controls() -> void:
	var has_world_object: bool = _has_selected_world_object()
	_world_object_actions.visible = has_world_object
	if not has_world_object:
		return
	var removal_cost: int = _world_object_removal_cost()
	var can_remove_now: bool = RunManager.phase == RunManager.Phase.ROUND_PREP and not _is_terrain_selection_locked()
	var can_afford: bool = bool(_run_economy.call("can_afford_gold", removal_cost))
	var removal_label: String = "Quitar obstáculo" if _selected_world_object_kind == &"obstacle" else "Quitar portal"
	_remove_world_object_button.text = "%s · %d Gold" % [removal_label, removal_cost]
	_remove_world_object_button.disabled = not can_remove_now or not can_afford
	if _selected_world_object_kind == &"obstacle":
		var cell: HexCell = _board_grid.cells.get(_selected_obstacle_coord) as HexCell
		var obstacle_name: String = TERRAIN_VISUAL_CATALOG_SCRIPT.get_obstacle_display_name(cell.obstacle_type)
		_world_object_description.text = "%s · %s · altura h%d\nRetirada n.º %d · coste progresivo." % [
			obstacle_name,
			_terrain_display_name(cell.terrain_type),
			cell.elevation,
			_obstacles_removed_count + 1,
		]
		_world_object_enemy_scroll.hide()
		_remove_world_object_button.tooltip_text = "Cada obstáculo retirado sube el precio: 25, 100, 225, 400…"
	else:
		var portal: SpawnPortal = _get_spawn_portal_by_key(_selected_spawn_endpoint_key)
		var wave_number: int = portal.get_wave_preview_round_number() if portal != null else _campaign_round_number
		var enemy_count: int = portal.get_wave_preview_enemy_count() if portal != null else 0
		_world_object_description.text = "Ronda %02d · %d enemigos asignados a esta salida · %d spawns activos." % [
			wave_number,
			enemy_count,
			_path_graph.get_active_spawn_count(),
		]
		_world_object_enemy_scroll.show()
		var can_remove_portal: bool = _path_graph.get_active_spawn_count() > 3
		_remove_world_object_button.disabled = not can_remove_now or not can_afford or not can_remove_portal
		if not can_remove_portal:
			_remove_world_object_button.tooltip_text = "Deben quedar al menos tres portales activos."
		elif not can_afford:
			_remove_world_object_button.tooltip_text = "No hay Gold suficiente."
		else:
			_remove_world_object_button.tooltip_text = "El portal cuesta el doble del precio actual de retirada de obstáculos."
	if not can_remove_now:
		_remove_world_object_button.tooltip_text = "Puedes retirar obstáculos y portales durante la preparación de ronda."
	elif not can_afford:
		_remove_world_object_button.tooltip_text = "No hay Gold suficiente."

func _populate_spawn_enemy_list(entries: Array[Dictionary]) -> void:
	for child in _world_object_enemy_list.get_children():
		_world_object_enemy_list.remove_child(child)
		child.queue_free()
	for entry in entries:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row.custom_minimum_size = Vector2(0.0, 34.0)
		var portrait := TextureRect.new()
		portrait.custom_minimum_size = Vector2(30.0, 30.0)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		portrait.texture = entry.get("texture") as Texture2D
		row.add_child(portrait)
		var enemy_label := Label.new()
		enemy_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		enemy_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		enemy_label.add_theme_font_size_override("font_size", 13)
		enemy_label.text = "%s  ×%d" % [
			String(entry.get("display_name", "Enemigo")),
			int(entry.get("count", 0)),
		]
		row.add_child(enemy_label)
		_world_object_enemy_list.add_child(row)
	if entries.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Sin enemigos asignados."
		empty_label.add_theme_font_size_override("font_size", 12)
		_world_object_enemy_list.add_child(empty_label)

func _populate_portal_wave_tooltip_entries(entries: Array[Dictionary]) -> void:
	for child in _portal_wave_tooltip_entries.get_children():
		_portal_wave_tooltip_entries.remove_child(child)
		child.queue_free()
	for entry in entries:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row.custom_minimum_size = Vector2(0.0, 30.0)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var portrait := TextureRect.new()
		portrait.custom_minimum_size = Vector2(26.0, 26.0)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		portrait.texture = entry.get("texture") as Texture2D
		row.add_child(portrait)
		var enemy_label := Label.new()
		enemy_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		enemy_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		enemy_label.add_theme_font_size_override("font_size", 13)
		enemy_label.text = "%s  ×%d" % [
			String(entry.get("display_name", "Enemigo")),
			int(entry.get("count", 0)),
		]
		enemy_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(enemy_label)
		_portal_wave_tooltip_entries.add_child(row)
	if entries.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Sin enemigos asignados."
		empty_label.add_theme_font_size_override("font_size", 12)
		_portal_wave_tooltip_entries.add_child(empty_label)

func _on_remove_world_object_pressed() -> void:
	if not _has_selected_world_object() or RunManager.phase != RunManager.Phase.ROUND_PREP:
		return
	if _selected_world_object_kind == &"portal" and _path_graph.get_active_spawn_count() <= 3:
		_refresh_tower_controls()
		return
	var removal_cost: int = _world_object_removal_cost()
	var obstacle_cell: HexCell = null
	var obstacle_world_position: Vector2 = Vector2.ZERO
	if _selected_world_object_kind == &"obstacle":
		obstacle_cell = _board_grid.cells.get(_selected_obstacle_coord) as HexCell
		if obstacle_cell == null or obstacle_cell.obstacle_type == HexCell.ObstacleType.NONE:
			return
		obstacle_world_position = _get_cell_world_position(_selected_obstacle_coord, obstacle_cell)
	if not bool(_run_economy.call("try_spend_gold", removal_cost, &"remove_terrain_object")):
		_refresh_tower_controls()
		return
	if _selected_world_object_kind == &"obstacle":
		obstacle_cell.obstacle_type = HexCell.ObstacleType.NONE
		_obstacles_removed_count += 1
		_spawn_impact_vfx(&"obstacle_removed", obstacle_world_position)
		_clear_selected_world_object()
		_piece_preview.set_board_cells(_board_grid.cells)
		_piece_preview.queue_redraw()
	else:
		_removed_spawn_endpoint_keys[_selected_spawn_endpoint_key] = true
		_path_graph.set_spawn_endpoint_removed(_selected_spawn_endpoint_key, true)
		_clear_selected_world_object()
		_piece_preview.set_path_graph(_path_graph)
		_refresh_spawn_portal_previews()
	_refresh_path_status()
	_refresh_tower_controls()

func _select_tower_and_build(index: int) -> void:
	if index < 0 or index >= TOWER_PROFILES.size():
		return
	_select_tower_profile_and_build(TOWER_PROFILES[index])

func _select_debug_tower_and_build(tower_data: TowerData) -> void:
	_select_tower_profile_and_build(tower_data, true)

func _select_tower_profile_and_build(chosen_tower: TowerData, allow_debug_profile: bool = false) -> void:
	if chosen_tower == null or _is_terrain_selection_locked():
		return
	if not allow_debug_profile and not RunManager.has_tower_in_run(chosen_tower.id):
		_build_status.text = "Recluta esta torre con una card antes de construirla."
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
		_get_tower_display_texture(StringName(_selected_tower_data.id)),
		_selected_tower_data.visual_icon_size * Tower.TOWER_VISUAL_SCALE,
		_selected_tower_data.elevation_damage_bonus_per_level,
		StringName(_selected_tower_data.id)
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
	_selected_tower_data = BALLISTA_TOWER
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
	_refresh_spawn_portal_previews()
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
	var tower_data: TowerData = tower.get_tower_data()
	if tower_data != null:
		RunManager.record_tower_built(tower.get_instance_id(), tower_data.id)
	tower.impact_effect_requested.connect(_spawn_impact_vfx)
	tower.level_up_effect_requested.connect(_on_tower_level_up_vfx)
	_spawn_impact_vfx(&"tower_built", tower.global_position + Tower.TOWER_CELL_VISUAL_OFFSET)
	_animate_tower_shortcut_icon(tower_data.id)

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
	var frame_count: int = 0
	var columns: int = 0
	var source_frame_size: Vector2i = Vector2i.ZERO
	var frames_per_second: float = 12.0
	var display_size: float = 72.0
	match effect_id:
		&"shot_ballista", &"impact_ballista":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/ballista_%s.png" % ("shoot" if effect_id == &"shot_ballista" else "impact")
			display_size = 78.0 if effect_id == &"shot_ballista" else 68.0
		&"shot_mortar", &"impact_mortar":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/mortar_%s.png" % ("shoot" if effect_id == &"shot_mortar" else "impact")
			display_size = 90.0 if effect_id == &"shot_mortar" else 128.0
		&"shot_tesla", &"impact_tesla":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/teslaCoil_%s.png" % ("shoot" if effect_id == &"shot_tesla" else "impact")
			display_size = 88.0 if effect_id == &"shot_tesla" else 90.0
		&"shot_frost", &"impact_frost":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/ice_%s.png" % ("shoot" if effect_id == &"shot_frost" else "impact")
			display_size = 86.0
		&"shot_flame", &"impact_flame":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/fire_%s.png" % ("shoot" if effect_id == &"shot_flame" else "impact")
			display_size = 92.0
		&"shot_poison", &"impact_poison":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/poisonSprayer_%s.png" % ("shoot" if effect_id == &"shot_poison" else "impact")
			display_size = 88.0
		&"shot_shredder", &"impact_shredder":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/shredder_%s.png" % ("shoot" if effect_id == &"shot_shredder" else "impact")
			display_size = 84.0
		&"mortar_target_ripple":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/tap_ripple.png"
			frame_count = 16
			columns = 8
			source_frame_size = Vector2i(192, 192)
			frames_per_second = 24.0
			display_size = 108.0
		&"star_burst_gold":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/Rewards/star_burst_gold.png"
			frame_count = 24
			columns = 8
			source_frame_size = Vector2i(192, 192)
			frames_per_second = 20.0
			display_size = 156.0
		&"coin_burst_gold":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/Rewards/coin_burst_gold.png"
			frame_count = 32
			columns = 8
			source_frame_size = Vector2i(256, 256)
			frames_per_second = 20.0
			display_size = 152.0
		&"terrain_piece_placed":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/sparkle_twinkle_white_loop.png"
			frame_count = 24
			columns = 8
			source_frame_size = Vector2i(192, 192)
			frames_per_second = 18.0
			display_size = 126.0
		&"enemy_killed":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/pickup_ui/coins_top.png"
			display_size = 86.0
		&"tower_level_up":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/pickup_ui/level_up.png"
			display_size = 78.0
		&"chest_pickup", &"tower_built", &"obstacle_removed":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/pickup_ui/pickup.png"
			display_size = 96.0
		&"ui_click":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/pickup_ui/ui_click.png"
			display_size = 52.0
		&"base_hit":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/base_hit.png"
			display_size = 148.0
		&"game_over_confetti":
			sheet_path = "res://assets/sprites/ui/Cozy_Chunky/confetti_burst_01.png"
			frame_count = 40
			columns = 8
			source_frame_size = Vector2i(256, 256)
			frames_per_second = 20.0
			display_size = 420.0
		_:
			return
	if not ResourceLoader.exists(sheet_path):
		return
	var sprite_sheet := load(sheet_path) as Texture2D
	if sprite_sheet == null:
		return
	if source_frame_size == Vector2i.ZERO:
		source_frame_size = Vector2i(128, 128)
		if sprite_sheet.get_width() % source_frame_size.x != 0:
			return
		frame_count = int(float(sprite_sheet.get_width()) / float(source_frame_size.x))
		columns = frame_count
	var effect := IMPACT_VFX_SCRIPT.new() as Sprite2D
	if effect == null:
		return
	var effect_parent: Node2D = _feedback_vfx
	var effect_position: Vector2 = world_position
	if effect_id == &"ui_click":
		# El marcador de click sigue al cursor en viewport; los VFX de juego siguen el mundo.
		_ensure_cursor_feedback_layer()
		effect_parent = _cursor_feedback_vfx
		effect_position = get_viewport().get_canvas_transform() * world_position
	if effect_parent == null:
		effect.queue_free()
		return
	effect_parent.add_child(effect)
	var repeat_count: int = 2 if effect_id == &"terrain_piece_placed" else 1
	var z_order: int = 120 if effect_id == &"star_burst_gold" else 130
	if effect_id == &"ui_click":
		z_order = 180
	if not bool(effect.call(
		"configure",
		sprite_sheet,
		frame_count,
		frames_per_second,
		display_size,
		effect_position,
		false,
		columns,
		source_frame_size,
		z_order,
		repeat_count
	)):
		effect.queue_free()

func _play_ui_click_vfx() -> void:
	if not is_inside_tree():
		return
	_spawn_impact_vfx(&"ui_click", get_global_mouse_position())

func _on_enemy_killed(world_position: Vector2) -> void:
	_spawn_impact_vfx(&"enemy_killed", world_position)

func _on_tower_level_up_vfx(world_position: Vector2) -> void:
	_spawn_impact_vfx(&"star_burst_gold", world_position)
	_spawn_impact_vfx(&"tower_level_up", world_position + Vector2(0.0, -108.0))

func _get_cell_world_position(coord: Vector2i, cell: HexCell = null) -> Vector2:
	var world_position: Vector2 = _piece_preview.to_global(
		HexMath.axial_to_world(HexCoord.new(coord.x, coord.y), HEX_RADIUS)
	)
	var resolved_cell: HexCell = cell if cell != null else _board_grid.cells.get(coord) as HexCell
	if resolved_cell != null:
		world_position.y -= float(resolved_cell.elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
	return world_position

func _cells_centroid_world(cells: Dictionary[Vector2i, HexCell], board: Dictionary[Vector2i, HexCell]) -> Vector2:
	if cells.is_empty():
		return _piece_preview.global_position
	var position_sum: Vector2 = Vector2.ZERO
	for coord in cells:
		var cell: HexCell = board.get(coord) as HexCell
		position_sum += _get_cell_world_position(coord, cell)
	return position_sum / float(cells.size())

func _on_tower_demolished(_tower_data: TowerData, _next_build_cost: int, refunded_gold: int) -> void:
	_set_rich_text_with_currency_icons(
		_tower_status,
		"Torre demolida · devolución de %d Gold · los niveles no se reembolsan" % refunded_gold
	)
	_refresh_tower_controls()

func _on_tower_selected(tower: Tower, _coord: Vector2i) -> void:
	if tower == null or not is_instance_valid(tower):
		return
	_sync_targeting_priority_menu(tower)
	_refresh_combat_debug()
	_refresh_tower_controls()

func _on_tower_upgraded(tower: Tower, _new_level: int) -> void:
	_on_tower_selected(tower, tower.cell_coord)

func _tower_shortcut_number_for_keycode(keycode: int) -> int:
	match keycode:
		KEY_1:
			return 1
		KEY_2:
			return 2
		KEY_3:
			return 3
		KEY_4:
			return 4
		KEY_5:
			return 5
		KEY_6:
			return 6
		KEY_7:
			return 7
		KEY_8:
			return 8
		KEY_9:
			return 9
		KEY_0:
			return 10
	return 0

func _tower_profile_index_for_shortcut(shortcut_number: int) -> int:
	if shortcut_number <= 0:
		return -1
	var available_number: int = 0
	for profile_index in TOWER_PROFILES.size():
		var tower_data: TowerData = TOWER_PROFILES[profile_index]
		if not RunManager.has_tower_in_run(tower_data.id):
			continue
		available_number += 1
		if available_number == shortcut_number:
			return profile_index
	return -1

func _refresh_tower_controls() -> void:
	var build_mode: bool = _build_controller.is_build_mode()
	var selected: Tower = _build_controller.selected_tower
	var has_selected_tower: bool = selected != null and is_instance_valid(selected)
	var demolition_refund: int = _build_controller.get_demolition_refund(selected) if has_selected_tower else -1
	var has_selected_world_object: bool = _has_selected_world_object()
	var waiting_for_terrain_card: bool = _awaiting_campaign_expansion and _selected_expansion_piece == null
	var terrain_selection_locked: bool = _is_terrain_selection_locked()
	var can_build: bool = _build_controller.can_build_in_current_phase() and not waiting_for_terrain_card and not terrain_selection_locked
	var is_run_ended: bool = RunManager.phase == RunManager.Phase.RUN_DEFEAT or RunManager.phase == RunManager.Phase.RUN_VICTORY
	var selected_card_index: int = -1
	var visible_shortcut_number: int = 0
	for index in _tower_shortcut_buttons.size():
		var shortcut_button: Button = _tower_shortcut_buttons[index]
		var tower_data: TowerData = TOWER_PROFILES[index]
		var tower_available: bool = RunManager.has_tower_in_run(tower_data.id)
		shortcut_button.visible = tower_available
		var shortcut_card := shortcut_button as TowerShortcutCard
		if tower_available:
			visible_shortcut_number += 1
			shortcut_card.set_shortcut_number(visible_shortcut_number)
		else:
			shortcut_card.set_shortcut_number(0)
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
		shortcut_button.tooltip_text = "Atajo %d · %s\n%s · precio %d%s · %s" % [
			visible_shortcut_number,
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
	_tower_toolbar.visible = _hud.visible and not terrain_selection_locked
	_refresh_wave_option_states()
	_wave_selector.disabled = build_mode or not _can_start_wave() or is_run_ended
	_tower_actions.visible = has_selected_tower and not build_mode and not has_selected_world_object
	_world_object_actions.visible = has_selected_world_object
	_tower_info_panel.visible = (
		_hud.visible
		and not terrain_selection_locked
		and not _terrain_panel.visible
		and (build_mode or has_selected_tower or has_selected_world_object)
	)
	_build_status.visible = (_build_status.get_parsed_text().strip_edges() != "") and (build_mode or has_selected_tower) and not has_selected_world_object
	_tower_portrait.visible = build_mode or has_selected_tower or has_selected_world_object
	_tower_portrait.texture = null
	_tower_level_label.visible = has_selected_tower and not build_mode and not has_selected_world_object
	_tower_status.visible = not has_selected_world_object
	if has_selected_world_object:
		if _selected_world_object_kind == &"obstacle":
			var selected_cell: HexCell = _board_grid.cells.get(_selected_obstacle_coord) as HexCell
			_tower_title.text = TERRAIN_VISUAL_CATALOG_SCRIPT.get_obstacle_display_name(selected_cell.obstacle_type)
			_tower_portrait.texture = TERRAIN_VISUAL_CATALOG_SCRIPT.get_obstacle_texture(selected_cell.obstacle_type)
		else:
			_tower_title.text = "Portal de spawn"
			_tower_portrait.texture = SPAWN_PORTAL_TEXTURE
		_tower_level_label.text = ""
		_refresh_world_object_controls()
	elif build_mode:
		_tower_title.text = _selected_tower_data.display_name
		_tower_portrait.texture = _get_tower_display_texture(StringName(_selected_tower_data.id))
	elif has_selected_tower:
		var selected_data: TowerData = selected.get_tower_data()
		_tower_title.text = selected_data.display_name
		_tower_portrait.texture = _get_tower_display_texture(StringName(selected_data.id))
		var total_upgrades: int = mini(maxi(selected.level - 1, 0), selected.get_max_total_upgrades())
		_tower_level_label.text = "[b]NIVEL %d DE %d[/b]" % [total_upgrades, selected.get_max_total_upgrades()]
	else:
		_tower_title.text = ""
		_tower_level_label.text = ""
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
		_tower_upgrade_xp_labels[layer].visible = false
		_tower_upgrade_xp_bars[layer].visible = has_selected_tower and next_upgrade_cost >= 0
		_tower_upgrade_level_labels[layer].text = "[b]NIVEL %d/%d[/b]" % [layer_level, max_layer_upgrades]
		if next_upgrade_cost >= 0:
			_tower_upgrade_amounts[layer].text = "%d" % next_upgrade_cost
			_tower_upgrade_xp_bars[layer].value = clampf(xp_value / maxf(xp_required, 0.001) * 100.0, 0.0, 100.0)
		else:
			_tower_upgrade_amounts[layer].text = "máx."
			_tower_upgrade_xp_bars[layer].value = 100.0
		upgrade_button.disabled = build_mode or not has_selected_tower or next_upgrade_cost < 0 or not bool(_run_economy.call("can_afford_gold", next_upgrade_cost)) or not _build_controller.can_build_in_current_phase()
		if next_upgrade_cost >= 0:
			upgrade_button.tooltip_text = "Nivel %d/%d · XP %.0f/%.0f · cuesta %d Gold · añade +1 al daño base y +1 a %s." % [
				layer_level,
				max_layer_upgrades,
				xp_value,
				xp_required,
				next_upgrade_cost,
				_hp_layer_name(layer),
			]
		else:
			upgrade_button.tooltip_text = "%s está al nivel máximo %d/%d." % [
				_hp_layer_name(layer),
				layer_level,
				max_layer_upgrades,
			]
	_demolish_tower_button.disabled = build_mode or not has_selected_tower or not _build_controller.can_build_in_current_phase()
	_demolish_tower_button.tooltip_text = (
		"Retira esta torre y devuelve %d Gold. El reembolso depende del precio del tipo y la cantidad en el mapa; no cubre niveles ni mejoras."
		% demolition_refund
		if demolition_refund >= 0
		else "Selecciona una torre para consultar su devolución."
	)
	if has_selected_world_object:
		pass
	elif build_mode:
		_set_rich_text_with_currency_icons(_tower_status, _build_tower_description(_selected_tower_data))
	elif not has_selected_tower:
		_tower_status.text = "Torre: ninguna · pulsa 1–7 para construir"
	else:
		_set_rich_text_with_currency_icons(_tower_status, _format_selected_tower_summary(selected))
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
		elevation_text = "[b]Bonus por elevación:[/b] %s" % " · ".join(bonus_parts)
	var energy_text := ""
	if tower_data.mana_cost_per_second > 0.0:
		energy_text = "\nConsumo: %.1f Mana/s" % tower_data.mana_cost_per_second
	elif tower_data.mana_cost_per_attack > 0.0:
		energy_text = "\nConsumo: %.1f Mana/ataque" % tower_data.mana_cost_per_attack
	return "%s\n[b]Precio:[/b] %d Gold · [b]Daño:[/b] %d · [b]Rango:[/b] %.1f hex · [b]RPM:[/b] %.0f\n%s%s" % [
		tower_data.role_summary,
		build_cost,
		tower_data.base_damage,
		tower_data.range_hexes,
		tower_data.get_rounds_per_minute(),
		elevation_text,
		energy_text,
	]

func _format_selected_tower_summary(tower: Tower) -> String:
	var tower_data: TowerData = tower.get_tower_data()
	var mana_summary: String = ""
	var elevation_summary: String = ""
	if tower_data.mana_cost_per_second > 0.0:
		mana_summary = " · %.1f Mana/s" % (tower_data.mana_cost_per_second * float(_run_card_service.call("get_tower_mana_cost_multiplier", tower_data.id)))
	elif tower.get_mana_cost_per_attack() > 0.0:
		mana_summary = " · %.1f Mana/ataque" % tower.get_mana_cost_per_attack()
	if tower.elevation > 0:
		var bonus_damage: float = float(tower.elevation) * tower_data.elevation_damage_bonus_per_level
		var bonus_range: float = float(tower.elevation) * tower_data.height_range_bonus_per_level
		var damage_text: String = "+%d" % roundi(bonus_damage) if is_equal_approx(bonus_damage, roundf(bonus_damage)) else "+%.1f" % bonus_damage
		elevation_summary = "\n[b]ALTURA h%d[/b] · %s daño base · +%.1f hex alcance" % [
			tower.elevation,
			damage_text,
			bonus_range,
		]
	return "[b]Daño[/b] %d · [b]Rango[/b] %.1f hex · [b]RPM[/b] %.0f\n[b]Crítico[/b] %.0f%% · %s%s%s" % [
		tower.get_current_damage(),
		tower.get_current_range_hexes(),
		tower.get_current_rounds_per_minute(),
		tower.get_current_crit_chance() * 100.0,
		tower.get_attack_pattern_name(),
		mana_summary,
		elevation_summary,
	]

func _tower_attack_description(tower_data: TowerData) -> String:
	if tower_data.attack_pattern == TowerData.AttackPattern.FROST_SNOWFALL:
		return "copos sobre los Path del cuadrado; solo dañan al impactar"
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
	if (
		_is_terrain_selection_locked()
		or RunManager.phase == RunManager.Phase.CARD_OFFER
		or not _path_graph.is_valid
		or not _can_start_selected_wave()
	):
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
	get_tree().paused = false
	_pause_button.call("sync_pause_state")
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
		_attempt_base_repair_for_round()
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
		return
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
	return RunManager.phase == RunManager.Phase.ROUND_PREP

func _is_terrain_selection_locked() -> bool:
	return (
		_awaiting_campaign_expansion
		or RunManager.phase == RunManager.Phase.TERRAIN_EXPANSION
		or RunManager.phase == RunManager.Phase.CARD_OFFER
	)

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

func _refresh_spawn_portal_previews() -> void:
	if _piece_preview == null or not is_instance_valid(_piece_preview):
		return
	var portals: Array[SpawnPortal] = _piece_preview.get_spawn_portals()
	if portals.is_empty():
		_hide_portal_wave_tooltip()
		return
	var preview_wave: WaveData = _selected_wave if _selected_wave != null else _get_campaign_round(_campaign_round_number)
	var preview_graph: PathGraph = _path_graph
	if (
		_placement_enabled
		and _latest_placement != null
		and _latest_placement.is_valid
		and _placement_path_graph != null
		and _placement_path_graph.is_valid
	):
		preview_graph = _placement_path_graph
	var reachable_routes: Array[PathRoute] = []
	if preview_graph != null and preview_graph.is_valid:
		for route in preview_graph.get_active_routes():
			reachable_routes.append(route)
	var entries_by_endpoint: Dictionary = {}
	var campaign_spawn_index: int = 0
	if preview_wave != null and not reachable_routes.is_empty():
		for group in preview_wave.groups:
			if group == null or group.enemy_data == null:
				continue
			for enemy_index in range(group.count):
				var route_index: int = 0
				if not _selected_wave_is_debug:
					route_index = posmod(campaign_spawn_index, reachable_routes.size())
					campaign_spawn_index += 1
				elif group.spawn_endpoint_policy == WaveEnemyGroupData.SpawnEndpointPolicy.ROUND_ROBIN:
					route_index = posmod(enemy_index, reachable_routes.size())
				var route: PathRoute = reachable_routes[route_index]
				var endpoint: PathEndpoint = route.spawn_endpoint
				var endpoint_key: String = "%d,%d,%d" % [
					endpoint.cell_coord.x,
					endpoint.cell_coord.y,
					endpoint.edge_direction,
				]
				var endpoint_entries: Array = entries_by_endpoint.get(endpoint_key, [])
				var entry_index: int = -1
				for current_index in endpoint_entries.size():
					var current_entry: Dictionary = endpoint_entries[current_index] as Dictionary
					if current_entry.get("enemy_id") == group.enemy_data.id:
						entry_index = current_index
						break
				if entry_index < 0:
					endpoint_entries.append({
						"enemy_id": group.enemy_data.id,
						"display_name": group.enemy_data.display_name,
						"texture": group.enemy_data.sprite_texture,
						"count": 1,
					})
				else:
					var updated_entry: Dictionary = endpoint_entries[entry_index] as Dictionary
					updated_entry["count"] = int(updated_entry.get("count", 0)) + 1
					endpoint_entries[entry_index] = updated_entry
				entries_by_endpoint[endpoint_key] = endpoint_entries
	for portal in portals:
		if not portal.hover_changed.is_connected(_on_spawn_portal_hover_changed):
			portal.hover_changed.connect(_on_spawn_portal_hover_changed)
		if not portal.selected.is_connected(_on_spawn_portal_selected):
			portal.selected.connect(_on_spawn_portal_selected)
		var portal_entries: Array[Dictionary] = []
		var raw_entries: Variant = entries_by_endpoint.get(portal.get_endpoint_key(), [])
		if raw_entries is Array:
			for entry_variant in raw_entries:
				if entry_variant is Dictionary:
					portal_entries.append(entry_variant as Dictionary)
		portal.set_wave_preview(portal_entries, preview_wave.round_number if preview_wave != null else 0)
		if _selected_world_object_kind == &"portal" and portal.get_endpoint_key() == _selected_spawn_endpoint_key:
			_populate_spawn_enemy_list(portal.get_wave_preview_entries())
	if _hovered_spawn_portal != null and not is_instance_valid(_hovered_spawn_portal):
		_hide_portal_wave_tooltip()
	if _selected_world_object_kind == &"portal":
		_refresh_world_object_controls()

func _on_spawn_portal_hover_changed(portal_node: Node2D, is_hovered: bool) -> void:
	var portal := portal_node as SpawnPortal
	if portal == null or not is_instance_valid(portal):
		return
	if not is_hovered:
		if _hovered_spawn_portal == portal:
			_hide_portal_wave_tooltip()
		return
	_hovered_spawn_portal = portal
	if _portal_wave_tooltip_label != null:
		_portal_wave_tooltip_label.text = portal.get_wave_preview_tooltip_text()
	if _portal_wave_tooltip_entries != null:
		_populate_portal_wave_tooltip_entries(portal.get_wave_preview_entries())
	if _portal_wave_tooltip != null:
		_portal_wave_tooltip.show()
		_position_portal_wave_tooltip()

func _hide_portal_wave_tooltip() -> void:
	_hovered_spawn_portal = null
	if _portal_wave_tooltip != null:
		_portal_wave_tooltip.hide()

func _position_portal_wave_tooltip() -> void:
	if _portal_wave_tooltip == null or not _portal_wave_tooltip.visible:
		return
	if _hovered_spawn_portal == null:
		return
	if not is_instance_valid(_hovered_spawn_portal):
		_hide_portal_wave_tooltip()
		return
	var anchor: Vector2 = _hovered_spawn_portal.get_global_transform_with_canvas() * Vector2(68.0, -150.0)
	var viewport_size: Vector2 = get_viewport_rect().size
	var tooltip_size: Vector2 = _portal_wave_tooltip.get_combined_minimum_size()
	_portal_wave_tooltip.size = tooltip_size
	var tooltip_position := anchor + Vector2(12.0, -tooltip_size.y * 0.5)
	tooltip_position.x = clampf(tooltip_position.x, 8.0, maxf(8.0, viewport_size.x - tooltip_size.x - 8.0))
	tooltip_position.y = clampf(tooltip_position.y, 8.0, maxf(8.0, viewport_size.y - tooltip_size.y - 8.0))
	_portal_wave_tooltip.position = tooltip_position

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
	var adjusted_amount: int = amount
	if reason == WaveDirector.RewardReason.ROUND_CLEAR:
		economy_reason = &"round_reward"
	else:
		adjusted_amount += int(_run_card_service.call("get_gold_per_kill_bonus"))
		adjusted_amount += int(MetaProgression.call("get_gold_per_kill_bonus"))
		var mana_steal_fraction: float = float(_run_card_service.call("get_mana_on_kill_max_percent_bonus"))
		if mana_steal_fraction > 0.0:
			var mana_reward: float = float(_run_economy.call("get_maximum_mana")) * mana_steal_fraction
			_run_economy.call("add_mana", mana_reward, &"mana_on_kill")
	var accepted: int = int(_run_economy.call("add_gold", adjusted_amount, economy_reason))
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
	if _packet != null:
		RunManager.record_tower_damage(int(_packet.get("source_id")), damage_result.total_damage)
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
	if _gold_group == null or _gold_icon == null:
		return
	if _gold_feedback_tween != null and _gold_feedback_tween.is_running():
		_gold_feedback_tween.kill()
	_gold_feedback_direction *= -1.0
	_gold_group.pivot_offset = _gold_group.size * 0.5
	var peak_scale: Vector2 = Vector2(1.34, 1.34) if is_reward else Vector2(1.14, 1.14)
	var shake_angle: float = 0.065 if is_reward else 0.03
	var flash_color := Color("#fff0a6") if is_reward else Color("#f5e2a8")
	_gold_group.scale = peak_scale
	_gold_group.rotation = shake_angle * _gold_feedback_direction
	_gold_group.self_modulate = flash_color
	_gold_icon.rotation = 0.14 * _gold_feedback_direction if is_reward else 0.06 * _gold_feedback_direction
	_gold_feedback_tween = create_tween()
	_gold_feedback_tween.set_parallel(true)
	var squash_scale: Vector2 = Vector2(0.88, 0.88) if is_reward else Vector2(0.96, 0.96)
	var squash_duration: float = 0.10 if is_reward else 0.08
	_gold_feedback_tween.tween_property(_gold_group, "scale", squash_scale, squash_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_gold_feedback_tween.tween_property(_gold_group, "rotation", -shake_angle * 0.72 * _gold_feedback_direction, squash_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_gold_feedback_tween.tween_property(_gold_group, "self_modulate", Color.WHITE, squash_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_gold_feedback_tween.tween_property(_gold_icon, "rotation", -0.08 * _gold_feedback_direction, squash_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_gold_feedback_tween.chain().set_parallel(true)
	var settle_scale: Vector2 = Vector2(1.08, 1.08) if is_reward else Vector2.ONE
	var settle_duration: float = 0.11 if is_reward else 0.10
	_gold_feedback_tween.tween_property(_gold_group, "scale", settle_scale, settle_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_gold_feedback_tween.tween_property(_gold_group, "rotation", shake_angle * 0.28 * _gold_feedback_direction, settle_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_gold_feedback_tween.tween_property(_gold_icon, "rotation", 0.025 * _gold_feedback_direction, settle_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_gold_feedback_tween.chain().set_parallel(true)
	var final_duration: float = 0.16 if is_reward else 0.12
	_gold_feedback_tween.tween_property(_gold_group, "scale", Vector2.ONE, final_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_gold_feedback_tween.tween_property(_gold_group, "rotation", 0.0, final_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
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
	var estimate: Variant = _damage_service.call("preview_damage", target, tower.create_damage_packet(null, false))
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

func _on_run_card_modifiers_changed() -> void:
	_sync_run_card_side_effects()
	_refresh_tower_controls()

func _sync_run_card_side_effects() -> void:
	if _run_card_service == null or not is_instance_valid(_run_card_service):
		return
	var desired_health_bonus: int = int(_run_card_service.call("get_base_max_health_bonus"))
	var health_bonus_delta: int = desired_health_bonus - _applied_run_card_base_health_bonus
	if health_bonus_delta > 0 and _base != null and is_instance_valid(_base):
		_base.increase_maximum_health(health_bonus_delta)
	_applied_run_card_base_health_bonus = desired_health_bonus
	_wave_director.call("set_enemy_base_damage_bonus", int(_run_card_service.call("get_enemy_base_damage_bonus")))

func _attempt_base_repair_for_round() -> void:
	var maximum_chance: float = float(MetaProgression.call("get_base_repair_max_chance"))
	if maximum_chance <= 0.0 or _base == null or not is_instance_valid(_base):
		return
	var maximum_health: int = _base.get_maximum_health()
	var missing_health: int = maximum_health - _base.get_current_health()
	if missing_health <= 0 or maximum_health <= 0:
		return
	var chance: float = maximum_chance * float(missing_health) / float(maximum_health)
	if _base_repair_rng.randf() < chance:
		_base.heal(1)

func _show_run_end(outcome: StringName, reached_round: int) -> void:
	if _run_end_in_progress:
		return
	_run_end_in_progress = true
	var summary: Dictionary = MetaProgression.call("finish_run", outcome, reached_round, GameState.run_seed)
	var unlocked_tower_ids: Array[StringName] = []
	unlocked_tower_ids.assign(MetaProgression.call("get_unlocked_tower_ids"))
	summary["tower_summary"] = RunManager.get_tower_run_summary(unlocked_tower_ids)
	GameState.pending_run_summary = summary
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _on_new_run_requested() -> void:
	GameState.pending_run_summary.clear()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/main/main.tscn")

func _toggle_pause() -> void:
	if _pause_menu == null:
		return
	if get_tree().paused:
		_resume_from_pause()
	else:
		get_tree().paused = true
		_pause_menu.call("set_paused", true)

func _resume_from_pause() -> void:
	get_tree().paused = false
	if _pause_menu != null:
		_pause_menu.call("set_paused", false)

func _return_to_menu_from_pause() -> void:
	get_tree().paused = false
	MetaProgression.call("abandon_run")
	GameState.pending_run_summary.clear()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _on_base_damaged(amount: int, current_health: int, maximum_health: int) -> void:
	_on_base_health_changed(current_health, maximum_health)
	if amount > 0:
		_spawn_impact_vfx(&"base_hit", _base.global_position + Vector2(0.0, -100.0))
		_base.show_damage_feedback()
		_play_camera_shake(amount)
		_wave_status.text = "La base recibió %d de daño · enemigos en ruta: %d" % [
			amount,
			_wave_director.get_alive_enemy_count(),
		]

func _play_camera_shake(damage_amount: int) -> void:
	if _camera == null:
		return
	if _camera_shake_tween != null and _camera_shake_tween.is_running():
		_camera_shake_tween.kill()
	_camera.offset = _camera_shake_origin
	var amplitude: float = clampf(4.0 + float(damage_amount) * 0.35, 4.0, 10.0)
	_camera_shake_tween = create_tween()
	for pulse_index in range(6):
		var decay: float = 1.0 - float(pulse_index) / 6.0
		var shake_offset := _camera_shake_origin + Vector2(
			randf_range(-amplitude, amplitude) * decay,
			randf_range(-amplitude, amplitude) * decay
		)
		_camera_shake_tween.tween_property(_camera, "offset", shake_offset, 0.035).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_camera_shake_tween.tween_property(_camera, "offset", _camera_shake_origin, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

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
	if _build_controller.is_build_mode():
		_build_controller.cancel_build_mode()
	_build_controller.clear_selection()
	_refresh_build_preview()
	if _offered_terrain_pieces.is_empty():
		_offered_path_extension.clear()
		_offered_path_extension = _find_path_extension_option(
			_board_grid.cells,
			_path_graph,
			null,
			true
		)
		if _offered_path_extension.is_empty():
			_placement_status.add_theme_color_override("font_color", Color("#ff8178"))
			_placement_status.text = "Error: no se encontró una pieza colocable que permita alargar el camino."
			push_error(_placement_status.text)
			return
		var extension_source: TerrainPieceData = _offered_path_extension.get("piece") as TerrainPieceData
		var candidates: Array[TerrainPieceData] = []
		for piece in _pieces:
			if piece == null or piece.id == extension_source.id:
				continue
			# Cuando la pieza de continuidad hace una curva o bifurca, esta oferta
			# no añade también una recta como alternativa automática.
			if extension_source.id != STRAIGHT_PIECE.id and piece.id == STRAIGHT_PIECE.id:
				continue
			candidates.append(piece)
		for index in range(candidates.size() - 1, 0, -1):
			var swap_index: int = _terrain_rng.randi_range(0, index)
			var piece_to_swap: TerrainPieceData = candidates[index]
			candidates[index] = candidates[swap_index]
			candidates[swap_index] = piece_to_swap
		var selected_sources: Array[TerrainPieceData] = [extension_source]
		for index in range(mini(_terrain_card_buttons.size() - 1, candidates.size())):
			selected_sources.append(candidates[index])
		for index in range(selected_sources.size() - 1, 0, -1):
			var swap_index: int = _terrain_rng.randi_range(0, index)
			var piece_to_swap: TerrainPieceData = selected_sources[index]
			selected_sources[index] = selected_sources[swap_index]
			selected_sources[swap_index] = piece_to_swap
		for index in selected_sources.size():
			var offer_piece: TerrainPieceData = TERRAIN_VISUAL_CATALOG_SCRIPT.create_piece_offer(
				selected_sources[index],
				_run_seed,
				_pending_expansion_round * 10 + index
			) as TerrainPieceData
			if offer_piece == null:
				push_error("No se pudo preparar la pieza de terreno de la oferta.")
				return
			_offered_terrain_pieces.append(offer_piece)
			if selected_sources[index].id == extension_source.id:
				_offered_path_extension["piece"] = offer_piece
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
		var is_path_extension: bool = piece == _offered_path_extension.get("piece")
		_terrain_card_counts[index].text = (
			"EXTIENDE RUTA · %s" % _piece_terrain_counts(piece)
			if is_path_extension
			else _piece_terrain_counts(piece)
		)
		if is_path_extension:
			_terrain_card_counts[index].add_theme_color_override("font_color", Color("#8de7aa"))
			_terrain_card_buttons[index].tooltip_text = "Pieza de continuidad verificada. Su colocación sugerida puede extender una ruta; la geometría varía entre rectas, curvas y bifurcaciones."
		else:
			_terrain_card_counts[index].remove_theme_color_override("font_color")
			_terrain_card_buttons[index].tooltip_text = "La posición solo se confirma si conserva una continuación legal del camino."
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
	_sync_selection_backdrop()

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
	if (
		cards.size() != CardPoolData.FIXED_OFFER_SIZE
		or _upgrade_card_buttons.size() < CardPoolData.FIXED_OFFER_SIZE
	):
		push_error("La oferta M11 debe contener exactamente tres cards.")
		return
	_upgrade_card_panel.set_card_count(CardPoolData.FIXED_OFFER_SIZE)
	if _build_controller.is_build_mode():
		_build_controller.cancel_build_mode()
	_build_controller.clear_selection()
	_upgrade_card_heading.text = "MEJORAS DE RUN · RONDA %02d" % round_number
	for index in cards.size():
		var card: Resource = cards[index]
		_set_rich_text_with_currency_icons(_upgrade_card_titles[index], String(card.get("display_name")))
		_set_rich_text_with_currency_icons(_upgrade_card_descriptions[index], String(card.get("description")))
		_upgrade_card_buttons[index].tooltip_text = ""
		var card_icon: Texture2D = _icon_catalog.call("get_card_icon", card) as Texture2D
		_upgrade_card_buttons[index].call("configure_visuals", card_icon, int(card.get("rarity")))
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
	_sync_selection_backdrop()

func _on_upgrade_card_selected(index: int) -> void:
	if RunManager.phase != RunManager.Phase.CARD_OFFER:
		return
	var current_offer: Array[Resource] = []
	current_offer.assign(_run_card_service.call("get_current_offer"))
	if index < 0 or index >= current_offer.size():
		return
	var selected_card: Resource = current_offer[index]
	if not bool(_run_card_service.call("select_card", index)):
		push_error("No se pudo seleccionar la carta: %s" % _run_card_service.get("last_error"))
		return
	var granted_tower_id: StringName = StringName(selected_card.get("grant_tower_id"))
	if granted_tower_id != &"":
		RunManager.grant_tower(granted_tower_id)
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

func _configure_upgrade_card_panel() -> void:
	_upgrade_card_heading = _upgrade_card_panel.heading_label
	_upgrade_card_panel.set_card_count(CardPoolData.FIXED_OFFER_SIZE)
	_upgrade_card_buttons.clear()
	_upgrade_card_titles.clear()
	_upgrade_card_descriptions.clear()
	for card in _upgrade_card_panel.cards:
		_upgrade_card_buttons.append(card)
		_upgrade_card_titles.append(card.title_label)
		_upgrade_card_descriptions.append(card.description_label)
	_upgrade_card_panel.hide()

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
	var selected_path_extension: bool = _selected_piece == _offered_path_extension.get("piece")
	if selected_path_extension:
		var suggested_anchor: Variant = _offered_path_extension.get("anchor_coord", _anchor_coord)
		if suggested_anchor is Vector2i:
			_anchor_coord = suggested_anchor
		_rotation_steps = int(_offered_path_extension.get("rotation_steps", 0))
	_placement_enabled = true
	_piece_selector.select(_find_catalog_piece_index(_selected_piece) + 1)
	_piece_status.text = _piece_summary(_selected_piece)
	for card_index in _terrain_card_buttons.size():
		_terrain_card_buttons[card_index].set_pressed_no_signal(card_index == index)
	_set_terrain_card_layout(true)
	_terrain_card_panel.show()
	var placement_prompt: String = (
		"posición sugerida: extiende una ruta"
		if selected_path_extension
		else "coloca en una posición válida"
	)
	_wave_status.text = "Expansión · %s seleccionada · %s\nT · Auto-colocar (no recomendado) · Q/E o Ctrl+rueda: girar" % [
		_selected_piece.display_name,
		placement_prompt,
	]
	_start_wave_button.disabled = true
	_set_start_wave_button_text("Coloca terreno")
	_refresh_placement()
	_refresh_tower_controls()
	_sync_selection_backdrop()

func _find_catalog_piece_index(piece: TerrainPieceData) -> int:
	if piece == null:
		return -1
	for index in _pieces.size():
		if _pieces[index].id == piece.id:
			return index
	return -1

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
	_update_cell_hover_tooltip()

func _on_preview_hover_cleared() -> void:
	_has_hovered_cell = false
	_update_hovered_tower(Vector2i.ZERO, false)
	_base.set_hovered(false)
	_hover_status.text = "Casilla del tablero (q,r): — · hover sobre cara superior"
	_piece_preview.set_tower_build_preview(false)
	_cell_hover_tooltip.hide()

func _update_cell_hover_tooltip() -> void:
	if not _has_hovered_cell or not _can_show_cell_hover_tooltip():
		_cell_hover_tooltip.hide()
		return
	var cell: HexCell = _board_grid.cells.get(_hovered_coord) as HexCell
	if cell == null:
		_cell_hover_tooltip.hide()
		return
	var next_text: String = _format_cell_hover_tooltip(cell)
	if _cell_hover_tooltip_label.text != next_text:
		_cell_hover_tooltip_label.text = next_text
		_cell_hover_tooltip.reset_size()
	_cell_hover_tooltip.show()
	var tooltip_size: Vector2 = _cell_hover_tooltip.get_combined_minimum_size()
	_cell_hover_tooltip.size = tooltip_size
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var viewport_size: Vector2 = get_viewport_rect().size
	var tooltip_position := mouse_position + Vector2(24.0, 14.0)
	if tooltip_position.x + tooltip_size.x > viewport_size.x - 8.0:
		tooltip_position.x = mouse_position.x - tooltip_size.x - 24.0
	if tooltip_position.y + tooltip_size.y > viewport_size.y - 8.0:
		tooltip_position.y = mouse_position.y - tooltip_size.y - 14.0
	var maximum_position := Vector2(
		maxf(8.0, viewport_size.x - tooltip_size.x - 8.0),
		maxf(8.0, viewport_size.y - tooltip_size.y - 8.0)
	)
	_cell_hover_tooltip.position = tooltip_position.clamp(Vector2(8.0, 8.0), maximum_position)

func _can_show_cell_hover_tooltip() -> bool:
	if (
		not _hud.visible
		or _selected_piece != null
		or _build_controller.is_build_mode()
		or _build_controller.selected_tower != null
		or _has_selected_world_object()
		or _hovered_spawn_portal != null
		or _terrain_card_panel.visible
		or _upgrade_card_panel.visible
		or (_debug_hacks_panel != null and _debug_hacks_panel.visible)
		or (_meta_shop_panel != null and bool(_meta_shop_panel.call("is_open")))
	):
		return false
	return not _is_mouse_over_hud(get_viewport().get_mouse_position())

func _format_cell_hover_tooltip(cell: HexCell) -> String:
	var terrain_name: String = _terrain_display_name(cell.terrain_type)
	var terrain_state: String
	if cell.terrain_type == HexCell.TerrainType.PATH:
		terrain_state = "Ruta · no construible"
	elif cell.obstacle_type != HexCell.ObstacleType.NONE:
		terrain_state = "Bloqueada · obstáculo"
	elif cell.chest_available:
		terrain_state = "Cofre pendiente"
	elif cell.occupied:
		terrain_state = "Torre colocada"
	elif not cell.buildable:
		terrain_state = "No construible"
	else:
		terrain_state = "Construible"
	return "%s · %s\nh%d · %s" % [
		terrain_name,
		terrain_state,
		cell.elevation,
		_format_cell_height_bonus(cell),
	]

func _format_cell_height_bonus(cell: HexCell) -> String:
	if cell.terrain_type == HexCell.TerrainType.PATH:
		return "sin bonus de torre"
	if cell.elevation <= 0:
		return "sin bonus por altura"
	var terrain_flag: int = TowerData.GRASS_FLAG if cell.terrain_type == HexCell.TerrainType.GRASS else TowerData.MOUNTAIN_FLAG
	var min_damage: float = INF
	var max_damage: float = -INF
	var min_range: float = INF
	var max_range: float = -INF
	for tower_data in TOWER_PROFILES:
		if tower_data == null or (tower_data.allowed_terrain_mask & terrain_flag) == 0:
			continue
		var damage_bonus: float = float(cell.elevation) * tower_data.elevation_damage_bonus_per_level
		var range_bonus: float = float(cell.elevation) * tower_data.height_range_bonus_per_level
		min_damage = minf(min_damage, damage_bonus)
		max_damage = maxf(max_damage, damage_bonus)
		min_range = minf(min_range, range_bonus)
		max_range = maxf(max_range, range_bonus)
	if is_inf(min_damage) or is_inf(min_range):
		return "sin torres compatibles"
	var damage_text: String = _format_tooltip_number(min_damage) if is_equal_approx(min_damage, max_damage) else "%s–%s" % [_format_tooltip_number(min_damage), _format_tooltip_number(max_damage)]
	var range_text: String = _format_tooltip_number(min_range) if is_equal_approx(min_range, max_range) else "%s–%s" % [_format_tooltip_number(min_range), _format_tooltip_number(max_range)]
	return "Torres +%s daño / +%s hex" % [damage_text, range_text]

func _format_tooltip_number(value: float) -> String:
	return "%d" % roundi(value) if is_equal_approx(value, roundf(value)) else "%.1f" % value

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
	_path_status.text = "M4 PATH: %d · spawns %d · ramas %d · base* %s · %s · Ctrl+D:%s" % [
		_path_graph.nodes.size(),
		_path_graph.get_active_spawn_count(),
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
