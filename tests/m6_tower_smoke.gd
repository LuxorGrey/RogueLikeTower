extends Node

const DAMAGE_SERVICE_SCRIPT: Script = preload("res://game/combat/damage_service.gd")

const STARTING_PIECE: TerrainPieceData = preload("res://data/terrain/starting_terrain_piece.tres")
const BASIC_BOLT: TowerData = preload("res://data/towers/basic_bolt.tres")
const WAVE_DATA: WaveData = preload("res://data/waves/round_01.tres")
const HEX_RADIUS: float = 52.0
const MAP_ORIGIN: Vector2 = Vector2(320.0, 320.0)

var _entities: Node2D
var _attack_count: int = 0

func _ready() -> void:
	call_deferred("_run_smoke")

func _run_smoke() -> void:
	var cells := TerrainPlacementValidator.instantiate_cells(STARTING_PIECE, Vector2i.ZERO, 0, 0)
	var grid := HexGrid.new()
	if not grid.add_cells(cells):
		_fail("No se pudo preparar el tablero M6 de siete hexágonos.")
		return
	_entities = Node2D.new()
	add_child(_entities)
	var controller := BuildController.new()
	add_child(controller)
	var damage_service: Node = DAMAGE_SERVICE_SCRIPT.new()
	add_child(damage_service)
	if not controller.configure(grid, _entities, MAP_ORIGIN, HEX_RADIUS, damage_service):
		_fail("BuildController no aceptó el grid de prueba.")
		return
	if controller.begin_build(BASIC_BOLT):
		_fail("Se permitió activar construcción durante RUN_SETUP.")
		return
	RunManager.transition_to(RunManager.Phase.ROUND_PREP)
	if not controller.begin_build(BASIC_BOLT):
		_fail("No se pudo iniciar Build mode: %s" % controller.last_error)
		return
	if controller.place_tower(Vector2i.ZERO):
		_fail("Se permitió construir sobre PATH (0,0).")
		return
	if not controller.place_tower(Vector2i(1, -1)):
		_fail("No se pudo construir Basic Bolt en Grass: %s" % controller.last_error)
		return
	var grass_tower: Tower = controller.get_tower_at(Vector2i(1, -1))
	if grass_tower == null or not grid.cells[Vector2i(1, -1)].occupied:
		_fail("La torre de Grass no reservó su celda axial.")
		return
	if controller.place_tower(Vector2i(1, -1)):
		_fail("Se permitió construir dos torres en la misma celda.")
		return
	var level_one_range: float = grass_tower.get_current_range_hexes()
	if not controller.upgrade_selected_tower() or not controller.upgrade_selected_tower():
		_fail("No se pudieron realizar las mejoras configuradas.")
		return
	# The active M12A rule adds +1 base damage per level and +1 elevation
	# damage at elevation 1: 10 + 2 upgrades + 1 elevation = 13.
	if grass_tower.level != 3 or grass_tower.get_current_damage() != 13:
		_fail("Los niveles no aplicaron la regla vigente de daño y elevación.")
		return
	# M12A levels improve damage and one HP-layer multiplier; range comes
	# from terrain elevation/cards, not the retired M6 upgrade_range field.
	if not is_equal_approx(grass_tower.get_current_range_hexes(), level_one_range):
		_fail("Las mejoras de nivel alteraron un alcance que no escala en M12A.")
		return
	if controller.upgrade_selected_tower():
		_fail("La torre superó su nivel máximo configurado.")
		return
	controller.cancel_build_mode()
	if not controller.begin_build(BASIC_BOLT) or not controller.place_tower(Vector2i(0, 1)):
		_fail("No se pudo construir Basic Bolt en Montaña: %s" % controller.last_error)
		return
	controller.cancel_build_mode()
	var mountain_tower: Tower = controller.get_tower_at(Vector2i(0, 1))
	if mountain_tower == null or mountain_tower.elevation != 2:
		_fail("La torre de montaña no conservó la altura lógica de su celda.")
		return
	if mountain_tower.get_current_range_hexes() <= BASIC_BOLT.range_hexes:
		_fail("La altura de montaña no aplicó el bonus de alcance provisional.")
		return

	var graph := PathGraph.new()
	graph.rebuild(cells, Vector2i.ZERO)
	if not graph.is_valid or graph.routes.is_empty():
		_fail("No se pudo reutilizar una ruta M4 para los objetivos de la torre.")
		return
	var enemy_data: EnemyData = WAVE_DATA.groups[0].enemy_data.duplicate(true) as EnemyData
	enemy_data.max_health = 100
	var first_enemy := await _spawn_stopped_enemy(enemy_data, graph.routes[0], Vector2(20.0, 0.0), 1, 0.2)
	var last_enemy := await _spawn_stopped_enemy(enemy_data, graph.routes[0], Vector2(24.0, 0.0), 0, 0.2)
	if first_enemy == null or last_enemy == null:
		_fail("No se pudieron preparar enemigos de prueba para targeting.")
		return
	first_enemy.apply_damage(5)
	var armored_data: EnemyData = enemy_data.duplicate(true) as EnemyData
	armored_data.id = &"m6_armored_test"
	armored_data.armor = 8
	var armored_enemy := await _spawn_stopped_enemy(armored_data, graph.routes[0], Vector2(28.0, 0.0), 0, 0.5)
	if armored_enemy == null:
		_fail("No se pudo preparar el objetivo con armadura.")
		return
	var distant_data: EnemyData = enemy_data.duplicate(true) as EnemyData
	distant_data.id = &"m6_out_of_range_test"
	distant_data.armor = 99
	var distant_enemy := await _spawn_stopped_enemy(distant_data, graph.routes[0], Vector2(500.0, 0.0), 0, 0.1)
	if distant_enemy == null:
		_fail("No se pudo preparar el objetivo fuera de alcance.")
		return
	RunManager.transition_to(RunManager.Phase.COMBAT)
	if not controller.begin_build(BASIC_BOLT) or not controller.place_tower(Vector2i(-1, 1)):
		_fail("No se permitió construir durante COMBAT: %s" % controller.last_error)
		return
	controller.cancel_build_mode()
	grass_tower.set_targeting_mode(TowerData.TargetingMode.FIRST_PROGRESS)
	grass_tower._acquire_target()
	if grass_tower.get_current_target() != first_enemy:
		_fail("First progress no seleccionó al enemigo más avanzado.")
		return
	grass_tower.set_targeting_mode(TowerData.TargetingMode.LAST_PROGRESS)
	grass_tower._acquire_target()
	if grass_tower.get_current_target() != last_enemy:
		_fail("Last progress no seleccionó al enemigo más retrasado.")
		return
	grass_tower.set_targeting_mode(TowerData.TargetingMode.HIGHEST_HEALTH)
	grass_tower._acquire_target()
	if grass_tower.get_current_target() != last_enemy:
		_fail("Highest health no eligió la mayor vida actual.")
		return

	grass_tower.set_targeting_mode(TowerData.TargetingMode.HIGHEST_ARMOR)
	grass_tower._acquire_target()
	if grass_tower.get_current_target() != armored_enemy:
		_fail("Highest armor no eligió al objetivo blindado en alcance.")
		return
	if grass_tower._is_target_in_range(distant_enemy):
		_fail("El alcance incluyó un enemigo situado fuera del radio.")
		return
	grass_tower.attack_fired.connect(_on_attack_fired)
	grass_tower.set_physics_process(false)
	var health_before: int = armored_enemy.get_current_health()
	var armor_before: int = armored_enemy.get_armor_value()
	grass_tower._fire_at_target()
	await get_tree().create_timer(0.1).timeout
	if armored_enemy.get_armor_value() >= armor_before or armored_enemy.get_current_health() != health_before:
		_fail("El proyectil no respetó la capa Armor activa del objetivo.")
		return
	grass_tower._physics_process(0.5)
	if _attack_count != 1:
		_fail("La torre superó su cadencia antes de un segundo.")
		return
	grass_tower._physics_process(0.51)
	await get_tree().create_timer(0.1).timeout
	if _attack_count != 2:
		_fail("La torre no volvió a disparar al cumplirse su cooldown.")
		return
	grass_tower.set_physics_process(false)
	grass_tower._current_target = first_enemy
	first_enemy.queue_free()
	await get_tree().process_frame
	grass_tower.set_physics_process(true)
	grass_tower._physics_process(0.01)
	var recovered_target: Enemy = grass_tower.get_current_target()
	if recovered_target != null and not is_instance_valid(recovered_target):
		_fail("La torre conservó la referencia al objetivo eliminado.")
		return

	RunManager.transition_to(RunManager.Phase.TERRAIN_EXPANSION)
	if not controller.begin_build(BASIC_BOLT):
		_fail("No se permitió construir durante TERRAIN_EXPANSION.")
		return
	controller.cancel_build_mode()
	RunManager.transition_to(RunManager.Phase.RUN_DEFEAT)
	if controller.begin_build(BASIC_BOLT):
		_fail("Se permitió activar construcción durante RUN_DEFEAT.")
		return
	print("M6 tower smoke: build, fases, prioridades, rango/cadencia, daño y limpieza de objetivo liberado correctos.")
	get_tree().quit()

func _spawn_stopped_enemy(
	data: EnemyData,
	route: PathRoute,
	position_offset: Vector2,
	waypoint_index: int,
	current_progress: float
) -> Enemy:
	var enemy := data.scene.instantiate() as Enemy
	if enemy == null:
		return null
	_entities.add_child(enemy)
	await get_tree().process_frame
	if not enemy.configure(data, route, MAP_ORIGIN, HEX_RADIUS):
		enemy.queue_free()
		return null
	var follower := enemy.get_node("%PathFollower") as PathFollowerComponent
	follower.stop()
	follower._waypoint_index = waypoint_index
	follower.current_progress = current_progress
	var grass_tower_position: Vector2 = (
		MAP_ORIGIN
		+ HexMath.axial_to_world(HexCoord.new(1, -1), HEX_RADIUS)
		- Vector2(0.0, 18.0)
	)
	enemy.global_position = grass_tower_position + position_offset
	return enemy

func _on_attack_fired(_target: Enemy, _damage: int) -> void:
	_attack_count += 1

func _fail(message: String) -> void:
	push_error("M6 tower smoke: %s" % message)
	get_tree().quit(1)
