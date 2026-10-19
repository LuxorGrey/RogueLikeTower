extends Control

const TOWER_ROSTER: TowerRosterData = preload("res://data/towers/tower_roster.tres")
const ANIMATED_IMPACT_SCRIPT: Script = preload("res://game/vfx/animated_impact.gd")
const GAME_OVER_CONFETTI: Texture2D = preload("res://assets/sprites/ui/Cozy_Chunky/confetti_burst_01.png")
const GAME_SCENE_PATH: String = "res://game/main/main.tscn"

@export_group("Scene transition")
@export_range(0.1, 1.0, 0.01) var play_transition_duration: float = 0.42

@export_group("Run summary feedback")
@export_range(120.0, 600.0, 1.0) var game_over_confetti_display_size: float = 420.0

@onready var _start_button: Button = %StartButton
@onready var _shop_button: Button = %ShopButton
@onready var _exit_button: Button = %ExitButton
@onready var _game_over_effects: Node2D = %GameOverEffects
@onready var _shop_panel: MetaShopPanel = %MetaShopPanel
@onready var _transition_overlay: ColorRect = %TransitionOverlay
@onready var _water_background: ColorRect = %MenuBackground
@onready var _menu_fog_background: ColorRect = %BackgroundFog

var _water_background_material: ShaderMaterial
var _menu_fog_material: ShaderMaterial

var _play_transition_active: bool = false

func _ready() -> void:
	UIButtonHoverInstaller.install(self)
	_water_background_material = _water_background.material as ShaderMaterial
	_menu_fog_material = _menu_fog_background.material as ShaderMaterial
	_sync_water_background_transform()
	get_viewport().size_changed.connect(_sync_water_background_transform)
	var preload_error: Error = ResourceLoader.load_threaded_request(GAME_SCENE_PATH)
	if preload_error != OK and ResourceLoader.load_threaded_get_status(GAME_SCENE_PATH) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		push_warning("No se pudo precargar main.tscn; Play usará la carga de respaldo.")
	MetaProgression.call("configure_tower_catalog", TOWER_ROSTER.profiles)
	_start_button.pressed.connect(_start_run)
	_shop_button.pressed.connect(_open_shop)
	_exit_button.pressed.connect(get_tree().quit)
	_shop_panel.call("configure", TOWER_ROSTER.profiles, MetaProgression.call("get_permanent_upgrades"))
	_shop_panel.connect("close_requested", _on_shop_closed)
	var pending_summary: Dictionary = GameState.pending_run_summary.duplicate(true)
	if not pending_summary.is_empty():
		_play_game_over_confetti()
		GameState.pending_run_summary.clear()
		_shop_panel.call("present", pending_summary)

func _process(delta: float) -> void:
	GameState.water_background_time += delta
	var water_time: float = GameState.water_background_time
	if _water_background_material != null:
		_water_background_material.set_shader_parameter("water_time", water_time)
	if _menu_fog_material != null:
		_menu_fog_material.set_shader_parameter("water_time", water_time)

func _sync_water_background_transform() -> void:
	if _water_background_material == null:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var viewport_center: Vector2 = viewport_size * 0.5
	_water_background_material.set_shader_parameter("parallax_origin", viewport_center)
	_water_background_material.set_shader_parameter("camera_world_position", viewport_center)
	_water_background_material.set_shader_parameter("viewport_size", viewport_size)
	_water_background_material.set_shader_parameter("camera_zoom", 1.0)
	_water_background_material.set_shader_parameter("water_time", GameState.water_background_time)
	if _menu_fog_material != null:
		_menu_fog_material.set_shader_parameter("camera_world_position", viewport_center)
		_menu_fog_material.set_shader_parameter("fog_center_world_position", viewport_center)
		_menu_fog_material.set_shader_parameter("viewport_size", viewport_size)
		_menu_fog_material.set_shader_parameter("camera_zoom", 1.0)
		_menu_fog_material.set_shader_parameter("water_time", GameState.water_background_time)

func _play_game_over_confetti() -> void:
	var effect := ANIMATED_IMPACT_SCRIPT.new() as Sprite2D
	if effect == null:
		return
	_game_over_effects.add_child(effect)
	var viewport_center: Vector2 = get_viewport_rect().size * 0.5
	var configured: bool = bool(effect.call(
		"configure",
		GAME_OVER_CONFETTI,
		40,
		20.0,
		game_over_confetti_display_size,
		viewport_center,
		false,
		8,
		Vector2i(256, 256),
		10,
		1
	))
	if not configured:
		effect.queue_free()

func _open_shop() -> void:
	_shop_panel.call("present", {"outcome": "MENU", "reached_round": 1, "completed_rounds": 0, "meta_reward": 0})

func _on_shop_closed() -> void:
	_shop_button.grab_focus()

func _start_run() -> void:
	if _play_transition_active:
		return
	_play_transition_active = true
	_start_button.disabled = true
	GameState.pending_run_summary.clear()
	_transition_overlay.visible = true
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween().set_ignore_time_scale(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_transition_overlay, "modulate:a", 0.18, play_transition_duration)
	await tween.finished
	var load_status: int = ResourceLoader.load_threaded_get_status(GAME_SCENE_PATH)
	while load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		load_status = ResourceLoader.load_threaded_get_status(GAME_SCENE_PATH)
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var game_scene := ResourceLoader.load_threaded_get(GAME_SCENE_PATH) as PackedScene
		if game_scene != null and get_tree().change_scene_to_packed(game_scene) == OK:
			return
	if load_status == ResourceLoader.THREAD_LOAD_FAILED:
		push_warning("La precarga de main.tscn falló; Play usará la carga de respaldo.")
	var fallback_error: Error = get_tree().change_scene_to_file(GAME_SCENE_PATH)
	if fallback_error != OK:
		_transition_overlay.visible = false
		_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_transition_overlay.modulate = Color(1, 1, 1, 0)
		_start_button.disabled = false
		_play_transition_active = false
		push_error("No se pudo abrir la escena de partida: %s" % error_string(fallback_error))
