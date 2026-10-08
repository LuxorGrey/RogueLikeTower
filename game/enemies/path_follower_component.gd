class_name PathFollowerComponent
extends Node

signal route_completed

var _actor: Node2D
var _waypoints: Array[Vector2] = []
var _waypoint_index: int = 0
var _move_speed: float = 0.0
var _speed_multiplier: float = 1.0
var _is_following: bool = false
var _segment_start_position: Vector2 = Vector2.ZERO
var current_progress: float = 0.0

func get_waypoint_index() -> int:
	return _waypoint_index

func get_waypoints() -> Array[Vector2]:
	return _waypoints.duplicate()

func get_remaining_route_waypoints() -> Array[Vector2]:
	if _actor == null or not is_instance_valid(_actor) or _waypoints.is_empty():
		return []
	var remaining: Array[Vector2] = [_actor.global_position]
	for index in range(_waypoint_index, _waypoints.size()):
		remaining.append(_waypoints[index])
	return remaining

func get_progress_ratio() -> float:
	if _waypoints.is_empty():
		return 0.0
	return clampf((float(_waypoint_index) + current_progress) / float(_waypoints.size()), 0.0, 1.0)

func stop() -> void:
	_is_following = false
	set_physics_process(false)

func set_speed_multiplier(multiplier: float) -> void:
	_speed_multiplier = clampf(multiplier, 0.05, 1.0)

func _ready() -> void:
	set_physics_process(false)

func configure(
	actor: Node2D,
	start_position: Vector2,
	waypoints: Array[Vector2],
	move_speed: float
) -> bool:
	if actor == null or waypoints.is_empty() or move_speed <= 0.0:
		return false
	_actor = actor
	_actor.global_position = start_position
	_waypoints = waypoints.duplicate()
	_waypoint_index = 0
	_segment_start_position = start_position
	current_progress = 0.0
	_move_speed = move_speed
	_speed_multiplier = 1.0
	_is_following = true
	set_physics_process(true)
	return true

func _physics_process(delta: float) -> void:
	if not _is_following or not is_instance_valid(_actor):
		return
	var distance_budget: float = _move_speed * _speed_multiplier * delta
	while distance_budget > 0.0 and _waypoint_index < _waypoints.size():
		var destination: Vector2 = _waypoints[_waypoint_index]
		var displacement: Vector2 = destination - _actor.global_position
		var remaining_distance: float = displacement.length()
		if remaining_distance <= 0.001:
			_actor.global_position = destination
			_segment_start_position = destination
			current_progress = 0.0
			_waypoint_index += 1
			continue
		if remaining_distance <= distance_budget:
			_actor.global_position = destination
			_segment_start_position = destination
			current_progress = 0.0
			_waypoint_index += 1
			distance_budget -= remaining_distance
		else:
			_actor.global_position += displacement / remaining_distance * distance_budget
			distance_budget = 0.0
			var segment_length: float = _segment_start_position.distance_to(destination)
			current_progress = 1.0 - remaining_distance / segment_length if segment_length > 0.001 else 0.0

	if _waypoint_index >= _waypoints.size():
		current_progress = 1.0
		_is_following = false
		set_physics_process(false)
		route_completed.emit()
