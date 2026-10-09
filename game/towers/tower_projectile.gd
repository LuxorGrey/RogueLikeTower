extends Node2D

enum ImpactMode { SINGLE_TARGET, AREA }

const BOLT_COLOR: Color = Color("f2d894")
const SHELL_COLOR: Color = Color("d99b62")

var _target: Enemy
var _impact_position: Vector2 = Vector2.ZERO
var _damage_packet: RefCounted
var _damage_service: Node
var _source_tower: Node2D
var _speed: float = 560.0
var _hit_radius: float = 12.0
var _splash_radius: float = 0.0
var _impact_mode: int = ImpactMode.SINGLE_TARGET
var _ballista_cooldown_cycle_id: int = 0
var _is_resolving_impact: bool = false

func configure(
	launch_position: Vector2,
	target: Enemy,
	impact_position: Vector2,
	damage_packet: RefCounted,
	damage_service: Node,
	source_tower: Node2D,
	speed: float,
	hit_radius: float,
	splash_radius: float,
	impact_mode: int,
	ballista_cooldown_cycle_id: int = 0
) -> bool:
	if target == null or damage_packet == null or damage_service == null or source_tower == null:
		return false
	if speed <= 0.0 or hit_radius <= 0.0 or splash_radius < 0.0:
		return false
	if impact_mode < ImpactMode.SINGLE_TARGET or impact_mode > ImpactMode.AREA:
		return false
	_target = target
	_impact_position = impact_position
	_damage_packet = damage_packet
	_damage_service = damage_service
	_source_tower = source_tower
	_speed = speed
	_hit_radius = hit_radius
	_splash_radius = splash_radius
	_impact_mode = impact_mode
	_ballista_cooldown_cycle_id = ballista_cooldown_cycle_id
	global_position = launch_position
	if _ballista_cooldown_cycle_id > 0:
		_target.state_changed.connect(_on_target_state_changed)
	set_process(true)
	return true

func _process(delta: float) -> void:
	if delta <= 0.0:
		queue_free()
		return
	if not is_instance_valid(_source_tower):
		queue_free()
		return
	if _impact_mode == ImpactMode.SINGLE_TARGET and (not is_instance_valid(_target) or _target.state != Enemy.State.MOVING):
		queue_free()
		return
	if _impact_mode == ImpactMode.SINGLE_TARGET:
		_impact_position = _target.global_position
	var travel_step: float = _speed * delta
	var displacement: Vector2 = _impact_position - global_position
	var distance: float = displacement.length()
	if distance <= travel_step or distance <= _hit_radius:
		global_position = _impact_position
		_apply_impact()
		return
	var direction: Vector2 = displacement / distance
	var previous_position: Vector2 = global_position
	global_position += direction * travel_step
	rotation = direction.angle()
	if _impact_mode == ImpactMode.SINGLE_TARGET and _distance_squared_to_segment(_target.global_position, previous_position, global_position) <= _hit_radius * _hit_radius:
		_apply_impact()
		return
	queue_redraw()

func _apply_impact() -> void:
	if _impact_mode == ImpactMode.SINGLE_TARGET:
		if is_instance_valid(_target) and _target.state == Enemy.State.MOVING and _target.global_position.distance_squared_to(global_position) <= _hit_radius * _hit_radius:
			_is_resolving_impact = true
			var result: Variant = _damage_service.call("apply_damage", _target, _damage_packet)
			_is_resolving_impact = false
			if result != null and bool(result.get("is_valid")):
				_source_tower.call("on_projectile_hit", _target, int(result.get("total_damage")))
		else:
			queue_free()
			return
	else:
		var impacted_primary: bool = false
		for enemy_variant in get_tree().get_nodes_in_group(&"enemies"):
			var enemy := enemy_variant as Enemy
			if enemy == null or not is_instance_valid(enemy) or enemy.state != Enemy.State.MOVING:
				continue
			if enemy.global_position.distance_squared_to(_impact_position) > _splash_radius * _splash_radius:
				continue
			var result: Variant = _damage_service.call("apply_damage", enemy, _damage_packet)
			if result == null or not bool(result.get("is_valid")):
				continue
			if enemy == _target:
				impacted_primary = true
			_source_tower.call("on_projectile_hit", enemy, int(result.get("total_damage")))
		if not impacted_primary and is_instance_valid(_target):
			_source_tower.call("on_projectile_hit", _target, 0)
	queue_free()

func _on_target_state_changed(new_state: int) -> void:
	if new_state != Enemy.State.DEAD or _is_resolving_impact:
		return
	if is_instance_valid(_source_tower) and _source_tower.has_method("on_projectile_target_died_before_impact"):
		_source_tower.call("on_projectile_target_died_before_impact", _target, _ballista_cooldown_cycle_id)
	queue_free()

func _distance_squared_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment: Vector2 = end - start
	var length_squared: float = segment.length_squared()
	if length_squared <= 0.001:
		return point.distance_squared_to(start)
	var fraction: float = clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_squared_to(start + segment * fraction)

func _draw() -> void:
	if _impact_mode == ImpactMode.AREA:
		draw_circle(Vector2.ZERO, 7.0, SHELL_COLOR)
		draw_circle(Vector2(-2.0, -2.0), 2.2, Color("ffe4ad"))
	else:
		draw_line(Vector2(-8.0, 0.0), Vector2(5.0, 0.0), BOLT_COLOR, 3.0, true)
		draw_colored_polygon(PackedVector2Array([Vector2(5.0, 0.0), Vector2(1.0, -3.0), Vector2(1.0, 3.0)]), Color("fff2c7"))
