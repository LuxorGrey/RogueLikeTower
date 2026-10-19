@tool
class_name TowerLevelUpFeedback
extends Node2D

const PARTICLE_COUNT: int = 18

@export_group("Level-up text")
@export var level_text_format: String = "¡NIVEL {level}!":
	set(value):
		level_text_format = value
		_update_label_text()
@export_range(1, 99, 1) var preview_level: int = 2:
	set(value):
		preview_level = maxi(value, 1)
		_update_label_text()
@export var text_box_size: Vector2 = Vector2(232.0, 44.0):
	set(value):
		text_box_size = value
		_apply_label_geometry()
@export var text_start_offset: Vector2 = Vector2(-116.0, -126.0):
	set(value):
		text_start_offset = value
		_apply_label_geometry()
@export var text_end_offset: Vector2 = Vector2(-116.0, -186.0)
@export_range(0.2, 4.0, 0.05) var text_duration: float = 1.65

@onready var _level_label: Label = %LevelUpText

var _elapsed: float = 0.0
var _new_level: int = 1

func configure(new_level: int) -> void:
	_new_level = maxi(new_level, 1)
	_update_label_text()

func _ready() -> void:
	z_index = 140
	_update_label_text()
	_apply_label_geometry()
	if Engine.is_editor_hint():
		set_process(false)
		queue_redraw()
		return
	var text_tween: Tween = create_tween().set_parallel(true)
	text_tween.tween_property(_level_label, "position", text_end_offset, text_duration)
	text_tween.tween_property(_level_label, "modulate:a", 0.0, text_duration).set_delay(0.28)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_elapsed += delta
	if _elapsed >= text_duration:
		queue_free()
		return
	queue_redraw()

func _update_label_text() -> void:
	var label := get_node_or_null("LevelUpText") as Label
	if label == null:
		return
	var visible_level: int = preview_level if Engine.is_editor_hint() else _new_level
	label.text = level_text_format.replace("{level}", str(visible_level))

func _apply_label_geometry() -> void:
	var label := get_node_or_null("LevelUpText") as Label
	if label == null:
		return
	label.position = text_start_offset
	label.size = text_box_size

func _draw() -> void:
	var progress: float = clampf(_elapsed / text_duration, 0.0, 1.0)
	var fade: float = 1.0 - smoothstep(0.58, 1.0, progress)
	var pulse: float = sin(clampf(progress / 0.46, 0.0, 1.0) * PI)
	var halo_alpha: float = lerpf(0.34, 0.10, progress) * fade
	draw_circle(Vector2(0.0, 4.0), 30.0 + pulse * 16.0, Color(1.0, 0.77, 0.28, halo_alpha))

	var ring_radius: float = lerpf(28.0, 58.0, ease(progress, 0.55))
	draw_set_transform(Vector2(0.0, 8.0), 0.0, Vector2(1.45, 0.55))
	draw_arc(
		Vector2.ZERO,
		ring_radius,
		0.0,
		TAU,
		56,
		Color(1.0, 0.84, 0.43, fade * 0.76),
		5.5 * (1.0 - progress * 0.35),
		true
	)
	draw_arc(
		Vector2.ZERO,
		maxf(ring_radius - 5.0, 1.0),
		0.2,
		TAU - 0.2,
		48,
		Color(1.0, 0.97, 0.74, fade * 0.46),
		2.0,
		true
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for particle_index in PARTICLE_COUNT:
		var seed: float = float(particle_index) / float(PARTICLE_COUNT)
		var particle_progress: float = fposmod(_elapsed * 0.58 + seed, 1.0)
		var angle: float = seed * TAU + _elapsed * (0.72 if particle_index % 2 == 0 else -0.58)
		var orbit_radius: float = lerpf(18.0, 66.0, particle_progress)
		var particle_position := Vector2(
			cos(angle) * orbit_radius,
			12.0 - particle_progress * 93.0 + sin(angle * 2.0) * 5.0
		)
		var particle_alpha: float = (1.0 - particle_progress) * fade
		var particle_size: float = lerpf(4.8, 1.8, particle_progress)
		var particle_color: Color = Color("#fff0a0") if particle_index % 3 == 0 else Color("#ffc755")
		particle_color.a = particle_alpha
		_draw_sparkle(particle_position, particle_size, particle_color)

func _draw_sparkle(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array()
	for point_index in 8:
		var angle: float = -PI * 0.5 + TAU * float(point_index) / 8.0
		var point_radius: float = radius if point_index % 2 == 0 else radius * 0.32
		points.append(center + Vector2(cos(angle), sin(angle)) * point_radius)
	draw_colored_polygon(points, color)
