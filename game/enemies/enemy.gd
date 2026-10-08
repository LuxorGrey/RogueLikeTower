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
var _regen_fraction: float = 0.0
var _regen_counter_strength: float = 0.0
var _regen_counter_time_left: float = 0.0

@onready var _health: HealthComponent = %Health
@onready var _path_follower: PathFollowerComponent = %PathFollower

func _ready() -> void:
	add_to_group(&"enemies")
	_health.health_changed.connect(_on_health_changed)
	_health.health_depleted.connect(_on_health_depleted)
	_path_follower.route_completed.connect(_on_route_completed)

func _process(delta: float) -> void:
	if state != State.MOVING or _enemy_data == null or delta <= 0.0:
		return
	var counter_time: float = minf(_regen_counter_time_left, delta)
	var uncountered_time: float = maxf(delta - counter_time, 0.0)
	var effective_regen_amount: float = _enemy_data.regen_per_second * (
		uncountered_time + counter_time * (1.0 - _regen_counter_strength)
	)
	if _regen_counter_time_left > 0.0:
		_regen_counter_time_left = maxf(_regen_counter_time_left - delta, 0.0)
		if _regen_counter_time_left <= 0.0:
			_regen_counter_strength = 0.0
	if _health.current_health >= _health.maximum_health:
		_regen_fraction = 0.0
		return
	if effective_regen_amount <= 0.0:
		return
	_regen_fraction += effective_regen_amount
	var heal_amount: int = int(floor(_regen_fraction))
	if heal_amount <= 0:
		return
	var actual_healing: int = _health.heal(heal_amount)
	_regen_fraction = maxf(_regen_fraction - float(actual_healing), 0.0)
	if actual_healing < heal_amount:
		_regen_fraction = 0.0

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
	_regen_fraction = 0.0
	_regen_counter_strength = 0.0
	_regen_counter_time_left = 0.0
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
	# Compatibilidad del smoke M5; el combate de juego debe pasar por DamageService.
	return _apply_resolved_damage(amount)

func _apply_resolved_damage(amount: int) -> int:
	if state != State.MOVING:
		return 0
	return _health.apply_damage(amount)

func apply_regen_counter(strength: float, duration: float) -> void:
	if state != State.MOVING or strength <= 0.0 or duration <= 0.0:
		return
	_regen_counter_strength = maxf(_regen_counter_strength, clampf(strength, 0.0, 1.0))
	_regen_counter_time_left = maxf(_regen_counter_time_left, duration)

func get_display_name() -> String:
	return _enemy_data.display_name if _enemy_data != null else "Enemigo"

func get_current_health() -> int:
	return _health.current_health

func get_maximum_health() -> int:
	return _health.maximum_health

func get_armor_value() -> int:
	return _enemy_data.armor if _enemy_data != null else 0

func get_regen_per_second() -> float:
	return _enemy_data.regen_per_second if _enemy_data != null else 0.0

func get_regen_counter_strength() -> float:
	return _regen_counter_strength if _regen_counter_time_left > 0.0 else 0.0

func get_regen_counter_time_left() -> float:
	return _regen_counter_time_left

func get_effective_regen_per_second() -> float:
	return get_regen_per_second() * (1.0 - get_regen_counter_strength())

func get_damage_tag_multiplier(damage_tags: int) -> float:
	return _enemy_data.get_damage_tag_multiplier(damage_tags) if _enemy_data != null else 1.0

func get_route_progress() -> float:
	return _path_follower.get_progress_ratio()

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
