extends Control

const TOWER_ROSTER: TowerRosterData = preload("res://data/towers/tower_roster.tres")
const META_SHOP_SCENE: PackedScene = preload("res://game/progression/meta_shop_panel.tscn")
const GAME_SCENE_PATH: String = "res://game/main/main.tscn"

@onready var _start_button: Button = %StartButton
@onready var _shop_button: Button = %ShopButton
@onready var _exit_button: Button = %ExitButton

var _shop_panel: MetaShopPanel

func _ready() -> void:
	MetaProgression.call("configure_tower_catalog", TOWER_ROSTER.profiles)
	_start_button.pressed.connect(_start_run)
	_shop_button.pressed.connect(_open_shop)
	_exit_button.pressed.connect(get_tree().quit)
	_shop_panel = META_SHOP_SCENE.instantiate() as MetaShopPanel
	_shop_panel.call("configure", TOWER_ROSTER.profiles, MetaProgression.call("get_permanent_upgrades"))
	add_child(_shop_panel)
	_shop_panel.connect("close_requested", _on_shop_closed)
	var pending_summary: Dictionary = GameState.pending_run_summary.duplicate(true)
	if not pending_summary.is_empty():
		GameState.pending_run_summary.clear()
		_shop_panel.call("present", pending_summary)

func _open_shop() -> void:
	_shop_panel.call("present", {"outcome": "MENU", "reached_round": 1, "completed_rounds": 0, "meta_reward": 0})

func _on_shop_closed() -> void:
	_shop_button.grab_focus()

func _start_run() -> void:
	GameState.pending_run_summary.clear()
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
