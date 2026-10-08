class_name Enemy
extends Node2D

signal health_changed(current_health: int, maximum_health: int)
signal reached_base(base_damage: int)
signal defeated
signal state_changed(new_state: int)

enum State { UNCONFIGURED, MOVING, REACHED_BASE, DEAD }

const BODY_COLOR: Color = Color(0.82, 0.30, 0.27)
const BODY_OUTLINE: Color = Color(0.16, 0.07, 0.07)
const HEALTH_BACK_COLOR: Color = Color(0.12, 0.13, 0.14)
const HEALTH_FILL_COLOR: Color = Color(0.36, 0.86, 0.40)

var state: State = State.UNCONFIGURED
var _enemy_data: EnemyData

@onready var _health: HealthComponent = %Health
@onready var _path_follower: PathFollowerComponent = %PathFollower

func _ready() -> void:
	_health.health_changed.connect(_on_health_changed)
	_health.health_depleted.connect(_on_health_depleted)
	_path_follower.route_completed.connect(_on_route_completed)

func configure(
	enemy_data: EnemyData,
	route: PathRoute,
	map_origin: Vector2,
	hex_radius: float
) -> bool:
	if not is_node_ready() or enemy_data == null or route == null:
		return false
	var data_errors := enemy_data.validate()
	if not data_errors.is_empty() or not route.is_reachable or route.spawn_endpoint == null:
		return false
	if route.cells.is_empty() or route.base_endpoint == null or hex_radius <= 0.0:
		return false
	_enemy_data = enemy_data
	if not _health.initialize(enemy_data.max_health):
		return false
	var waypoints: Array[Vector2] = []
	for coord in route.cells:
		var hex_coord := HexCoord.new(coord.x, coord.y)
		waypoints.append(map_origin + HexMath.axial_to_world(hex_coord, hex_radius))
	var outside_coord: Vector2i = route.spawn_endpoint.outside_coord
	var outside_hex := HexCoord.new(outside_coord.x, outside_coord.y)
	var start_position: Vector2 = map_origin + HexMath.axial_to_world(outside_hex, hex_radius)
	if not _path_follower.configure(self, start_position, waypoints, enemy_data.move_speed):
		return false
	_change_state(State.MOVING)
	queue_redraw()
	return true

func apply_damage(amount: int) -> int:
	if state != State.MOVING:
		return 0
	return _health.apply_damage(amount)

func get_current_health() -> int:
	return _health.current_health

func get_maximum_health() -> int:
	return _health.maximum_health

func _draw() -> void:
	draw_circle(Vector2.ZERO, 13.0, BODY_OUTLINE)
	draw_circle(Vector2.ZERO, 10.0, BODY_COLOR)
	draw_arc(Vector2.ZERO, 12.0, 0.0, TAU, 20, Color(1.0, 0.72, 0.60), 1.5, true)
	if _enemy_data == null:
		return
	var ratio: float = _health.get_health_ratio()
	draw_rect(Rect2(-13.0, -21.0, 26.0, 4.0), HEALTH_BACK_COLOR)
	draw_rect(Rect2(-13.0, -21.0, 26.0 * ratio, 4.0), HEALTH_FILL_COLOR)

func _on_health_changed(current_health: int, maximum_health: int) -> void:
	health_changed.emit(current_health, maximum_health)
	queue_redraw()

func _on_health_depleted() -> void:
	if state != State.MOVING:
		return
	_path_follower.stop()
	_change_state(State.DEAD)
	defeated.emit()
	queue_free()

func _on_route_completed() -> void:
	if state != State.MOVING or _enemy_data == null:
		return
	_change_state(State.REACHED_BASE)
	reached_base.emit(_enemy_data.base_damage)
	queue_free()

func _change_state(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	state_changed.emit(state)
