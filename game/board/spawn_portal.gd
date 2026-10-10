class_name SpawnPortal
extends Node2D

const PORTAL_SPRITE_SIZE: Vector2 = Vector2(112.0, 168.0)
const PORTAL_TEXTURE_SIZE: Vector2 = Vector2(224.0, 336.0)
const PULSE_PERIOD: float = 3.8
const PULSE_MIN_SCALE: float = 0.96
const PULSE_MAX_SCALE: float = 1.055

@onready var _sprite: Sprite2D = %Sprite

var _candidate_preview: bool = false
var _pulse_time: float = 0.0
var _pulse_phase: float = 0.0
var _base_sprite_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_base_sprite_scale = PORTAL_SPRITE_SIZE / PORTAL_TEXTURE_SIZE
	_sprite.scale = _base_sprite_scale
	_sprite.position = Vector2(0.0, -80.0)
	_pulse_phase = float(posmod(absi(hash(String(name))), 10000)) / 10000.0 * TAU
	_update_pulse()
	set_process(true)

func _process(delta: float) -> void:
	_pulse_time += delta
	_update_pulse()

func _update_pulse() -> void:
	var cycle: float = (_pulse_time / PULSE_PERIOD) * TAU + _pulse_phase
	var pulse: float = 0.5 + 0.5 * sin(cycle)
	var scale_factor: float = lerpf(PULSE_MIN_SCALE, PULSE_MAX_SCALE, pulse)
	_sprite.scale = _base_sprite_scale * scale_factor
	var resting_color: Color = Color(0.65, 1.0, 0.78, 1.0) if _candidate_preview else Color.WHITE
	_sprite.modulate = resting_color.lerp(Color.WHITE, pulse * 0.22)

func set_candidate_preview(is_candidate: bool) -> void:
	if _candidate_preview == is_candidate:
		return
	_candidate_preview = is_candidate
