extends Node2D

const BLADE_COLOR: Color = Color(0.84, 0.86, 0.78)
const BLADE_DARK_COLOR: Color = Color(0.16, 0.20, 0.19)

var _route: Array[Vector2] = []
var _route_index: int = 1
var _damage_packet: RefCounted
var _damage_service: Node
var _remaining_damage: float = 0.0
var _hit_radius: float = 16.0
var _travel_speed: float = 560.0
var _damage_loss_per_hit: float = 1.0
var _hit_enemy_ids: Dictionary[int, bool] = {}
var _blade_angle: float = 0.0

func _ready() -> void:
	set_physics_process(false)

func configure(
	launch_position: Vector2,
	enemy_route: Array[Vector2],
	damage_packet: RefCounted,
	damage_service: Node,
	travel_speed: float,
	hit_radius: float,
	damage_loss_per_hit: float
) -> bool:
	if enemy_route.size() < 2 or damage_packet == null or damage_service == null or travel_speed <= 0.0 or hit_radius <= 0.0:
		return false
	_damage_packet = damage_packet
	_damage_service = damage_service
	_remaining_damage = float(_damage_packet.get("raw_damage"))
	_travel_speed = travel_speed
	_hit_radius = hit_radius
	_damage_loss_per_hit = maxf(damage_loss_per_hit, 0.0)
	_route = enemy_route.duplicate()
	if _route.size() < 2:
		return false
	_route_index = 0
	global_position = launch_position
	set_physics_process(true)
	return true

func _physics_process(delta: float) -> void:
	if delta <= 0.0 or _remaining_damage <= 0.0 or _route_index >= _route.size():
		queue_free()
		return
	var distance_budget: float = _travel_speed * delta
	_blade_angle += delta * 14.0
	while distance_budget > 0.0 and _route_index < _route.size():
		var destination: Vector2 = _route[_route_index]
		var displacement: Vector2 = destination - global_position
		var remaining_distance: float = displacement.length()
		if remaining_distance <= 0.001:
			global_position = destination
			_route_index += 1
			if _route_index == 1:
				_hit_enemies_along_segment(global_position, global_position)
			if _remaining_damage <= 0.0:
				queue_free()
				return
			continue
		var direction: Vector2 = displacement / remaining_distance
		var segment_start: Vector2 = global_position
		var travel_distance: float = minf(remaining_distance, distance_budget)
		global_position += direction * travel_distance
		distance_budget -= travel_distance
		rotation = direction.angle()
		if _route_index > 0:
			_hit_enemies_along_segment(segment_start, global_position)
		if travel_distance >= remaining_distance - 0.001:
			global_position = destination
			_route_index += 1
			if _route_index == 1:
				_hit_enemies_along_segment(global_position, global_position)
		if _remaining_damage <= 0.0:
			queue_free()
			return
	queue_redraw()
	if _route_index >= _route.size():
		queue_free()

func _hit_enemies_along_segment(segment_start: Vector2, segment_end: Vector2) -> void:
	var radius_squared: float = _hit_radius * _hit_radius
	for node in get_tree().get_nodes_in_group(&"enemies"):
		var enemy := node as Enemy
		if enemy == null or not is_instance_valid(enemy) or enemy.state != Enemy.State.MOVING:
			continue
		var enemy_id: int = enemy.get_instance_id()
		if _hit_enemy_ids.has(enemy_id):
			continue
		if _distance_squared_to_segment(enemy.global_position, segment_start, segment_end) > radius_squared:
			continue
		_hit_enemy_ids[enemy_id] = true
		_damage_packet.set("raw_damage", _remaining_damage)
		var bleed_damage: int = int(floor(_remaining_damage))
		var total_damage_overrides: Dictionary[StringName, int] = {}
		total_damage_overrides[&"bleed"] = bleed_damage
		_damage_packet.set("status_total_damage_overrides", total_damage_overrides)
		_damage_service.call("apply_damage", enemy, _damage_packet)
		_remaining_damage = maxf(_remaining_damage - _damage_loss_per_hit, 0.0)
		if _remaining_damage <= 0.0:
			queue_free()
			return

func _distance_squared_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment: Vector2 = end - start
	var length_squared: float = segment.length_squared()
	if length_squared <= 0.001:
		return point.distance_squared_to(start)
	var fraction: float = clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_squared_to(start + segment * fraction)

func _draw() -> void:
	var teeth := PackedVector2Array()
	for tooth in 16:
		var angle: float = float(tooth) * TAU / 16.0 + _blade_angle
		var radius: float = 12.0 if tooth % 2 == 0 else 8.0
		teeth.append(Vector2.RIGHT.rotated(angle) * radius)
	draw_colored_polygon(teeth, BLADE_COLOR)
	draw_circle(Vector2.ZERO, 4.0, BLADE_DARK_COLOR)
	draw_circle(Vector2.ZERO, 1.5, Color(0.83, 0.34, 0.35))
