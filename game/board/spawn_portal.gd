class_name SpawnPortal
extends Node2D

const PORTAL_SPRITE_SIZE: Vector2 = Vector2(112.0, 168.0)
const PORTAL_TEXTURE_SIZE: Vector2 = Vector2(1024.0, 1536.0)
const PULSE_SCALE: float = 1.055
const PULSE_DURATION: float = 0.72

@onready var _sprite: Sprite2D = %Sprite

var _pulse_tween: Tween
var _candidate_preview: bool = false

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_sprite.scale = PORTAL_SPRITE_SIZE / PORTAL_TEXTURE_SIZE
	_sprite.position = Vector2(0.0, -80.0)
	_start_pulse()

func _start_pulse() -> void:
	if _pulse_tween != null and _pulse_tween.is_running():
		_pulse_tween.kill()
	_sprite.scale = PORTAL_SPRITE_SIZE / PORTAL_TEXTURE_SIZE
	var base_scale: Vector2 = _sprite.scale
	var resting_color: Color = Color(0.65, 1.0, 0.78, 1.0) if _candidate_preview else Color.WHITE
	var pulse_color: Color = resting_color.lerp(Color.WHITE, 0.22)
	_sprite.modulate = resting_color
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(
		_sprite,
		"scale",
		base_scale * PULSE_SCALE,
		PULSE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.parallel().tween_property(
		_sprite,
		"modulate",
		pulse_color,
		PULSE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(
		_sprite,
		"scale",
		base_scale * 0.96,
		PULSE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.parallel().tween_property(
		_sprite,
		"modulate",
		resting_color,
		PULSE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func set_candidate_preview(is_candidate: bool) -> void:
	if _candidate_preview == is_candidate:
		return
	_candidate_preview = is_candidate
	_start_pulse()
