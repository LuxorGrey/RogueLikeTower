class_name FrostSnowflake
extends Node2D

const FLAKE_SPRITE: Texture2D = preload("res://assets/sprites/vfx/towers/shot_frost.png")
const FLAKE_DISPLAY_SIZE: float = 28.0

var _landing_position: Vector2 = Vector2.ZERO
var _fall_speed: float = 0.0
var _hit_radius: float = 0.0
var _damage_packet: RefCounted
var _damage_service: Node
var _source_tower: Node
var _rotation_speed: float = 0.0
var _flake_sprite: Sprite2D

func configure(
	landing_position: Vector2,
	fall_height: float,
	fall_speed: float,
	hit_radius: float,
	damage_packet: RefCounted,
	damage_service: Node,
	source_tower: Node,
	rotation_speed: float
) -> bool:
	if (
		fall_height <= 0.0 or fall_speed <= 0.0 or hit_radius <= 0.0
		or damage_packet == null or damage_service == null or source_tower == null
	):
		return false
	_landing_position = landing_position
	_fall_speed = fall_speed
	_hit_radius = hit_radius
	_damage_packet = damage_packet
	_damage_service = damage_service
	_source_tower = source_tower
	_rotation_speed = rotation_speed
	_flake_sprite = Sprite2D.new()
	_flake_sprite.name = "SnowflakeSprite"
	_flake_sprite.texture = FLAKE_SPRITE
	_flake_sprite.centered = true
	_flake_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_flake_sprite.scale = Vector2.ONE * (FLAKE_DISPLAY_SIZE / float(FLAKE_SPRITE.get_width()))
	add_child(_flake_sprite)
	global_position = landing_position - Vector2(0.0, fall_height)
	z_index = 5
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return true

func _process(delta: float) -> void:
	if RunManager.phase != RunManager.Phase.COMBAT:
		queue_free()
		return
	if not is_instance_valid(_damage_service) or not is_instance_valid(_source_tower):
		queue_free()
		return
	rotation += _rotation_speed * delta
	var previous_position: Vector2 = global_position
	global_position += Vector2(0.0, _fall_speed * delta)
	if _try_hit_enemy(previous_position, global_position):
		return
	if global_position.y >= _landing_position.y:
		queue_free()
		return

func _try_hit_enemy(segment_start: Vector2, segment_end: Vector2) -> bool:
	var segment: Vector2 = segment_end - segment_start
	var segment_length_squared: float = maxf(segment.length_squared(), 0.0001)
	var hit_radius_squared: float = _hit_radius * _hit_radius
	for node: Node in get_tree().get_nodes_in_group(&"enemies"):
		var enemy := node as Enemy
		if enemy == null or not is_instance_valid(enemy) or enemy.state != Enemy.State.MOVING:
			continue
		if not bool(_source_tower.call("is_enemy_within_current_range", enemy)):
			continue
		var projection: float = clampf(
			(enemy.global_position - segment_start).dot(segment) / segment_length_squared,
			0.0,
			1.0
		)
		var closest_point: Vector2 = segment_start + segment * projection
		if closest_point.distance_squared_to(enemy.global_position) > hit_radius_squared:
			continue
		var result: Variant = _damage_service.call("apply_damage", enemy, _damage_packet)
		if result == null or not bool(result.get("is_valid")):
			continue
		_source_tower.call("on_frost_snowflake_hit", enemy, result)
		queue_free()
		return true
	return false
