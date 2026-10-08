extends Node

const STARTING_PIECE: TerrainPieceData = preload("res://data/terrain/starting_terrain_piece.tres")
const BASE_SCENE: PackedScene = preload("res://game/main/game_base.tscn")
const WAVE_DATA: WaveData = preload("res://data/waves/round_01.tres")

var _wave_finished: bool = false
var _wave_failed: bool = false
var _base_was_defeated: bool = false
var _failure_reason: String = ""

func _ready() -> void:
	call_deferred("_run_smoke")

func _run_smoke() -> void:
	var initial_cells := TerrainPlacementValidator.instantiate_cells(STARTING_PIECE, Vector2i.ZERO, 0, 0)
	var graph := PathGraph.new()
	graph.rebuild(initial_cells, Vector2i.ZERO)
	if not graph.is_valid or graph.routes.is_empty():
		_fail("M5 requiere la ruta inicial válida de M4.")
		return

	var enemy_data: EnemyData = WAVE_DATA.groups[0].enemy_data
	if enemy_data == null or enemy_data.scene == null:
		_fail("La oleada no referencia una escena de enemigo cargable.")
		return

	var death_base := BASE_SCENE.instantiate() as GameBase
	add_child(death_base)
	await get_tree().process_frame
	death_base.defeated.connect(_on_test_base_defeated)
	death_base.apply_damage(death_base.get_maximum_health() + 1)
	if not _base_was_defeated or death_base.get_current_health() != 0:
		_fail("La base no emitió derrota al quedarse sin vida.")
		return
	death_base.queue_free()

	var entities := Node2D.new()
	add_child(entities)
	var test_enemy := enemy_data.scene.instantiate() as Enemy
	if test_enemy == null:
		_fail("La escena configurada en EnemyData no crea un Enemy.")
		return
	entities.add_child(test_enemy)
	await get_tree().process_frame
	if not test_enemy.configure(enemy_data, graph.routes[0], Vector2(320.0, 320.0), 52.0):
		_fail("El enemigo no aceptó los datos y la ruta M4.")
		return
	test_enemy.apply_damage(enemy_data.max_health)
	if test_enemy.state != Enemy.State.DEAD or test_enemy.get_current_health() != 0:
		_fail("El enemigo no alcanzó el estado muerto al agotar su vida.")
		return
	var test_follower := test_enemy.get_node("%PathFollower") as PathFollowerComponent
	if not test_enemy.is_queued_for_deletion() or test_follower.is_physics_processing():
		_fail("Un enemigo muerto debe detener su ruta y retirarse del árbol.")
		return

	var base := BASE_SCENE.instantiate() as GameBase
	add_child(base)
	await get_tree().process_frame
	var director := WaveDirector.new()
	add_child(director)
	director.wave_completed.connect(_on_wave_completed)
	director.wave_failed.connect(_on_wave_failed)
	if not director.start_wave(WAVE_DATA, graph, base, entities, Vector2(320.0, 320.0), 52.0):
		_fail("No se pudo iniciar la primera oleada: %s" % director.last_error)
		return

	var elapsed: float = 0.0
	while not _wave_finished and not _wave_failed and elapsed < 25.0:
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1
	if _wave_failed:
		_fail("La oleada terminó en error: %s" % _failure_reason)
		return
	if not _wave_finished:
		_fail("La oleada no terminó dentro del tiempo de prueba.")
		return
	var expected_health: int = base.get_maximum_health() - enemy_data.base_damage * WAVE_DATA.groups[0].count
	if base.get_current_health() != expected_health:
		_fail("Vida de base inesperada: %d; se esperaba %d." % [base.get_current_health(), expected_health])
		return
	if director.get_alive_enemy_count() != 0:
		_fail("La oleada reportó enemigos vivos después de completarse.")
		return
	print("M5 wave smoke: ruta, muerte de enemigo, derrota de base y oleada completa correctos.")
	get_tree().quit()

func _on_test_base_defeated() -> void:
	_base_was_defeated = true

func _on_wave_completed(_round_number: int) -> void:
	_wave_finished = true

func _on_wave_failed(reason: String) -> void:
	_wave_failed = true
	_failure_reason = reason

func _fail(message: String) -> void:
	push_error("M5 wave smoke: %s" % message)
	get_tree().quit(1)
