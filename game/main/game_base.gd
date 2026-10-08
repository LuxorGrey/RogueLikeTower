class_name GameBase
extends Node2D

signal health_changed(current_health: int, maximum_health: int)
signal defeated

const BASE_COLOR: Color = Color(0.94, 0.76, 0.28)
const BASE_OUTLINE: Color = Color(0.18, 0.15, 0.08)

@export var base_data: BaseData

@onready var _health: HealthComponent = %Health

func _ready() -> void:
	_health.health_changed.connect(_on_health_changed)
	_health.health_depleted.connect(_on_health_depleted)
	if base_data == null:
		push_error("GameBase necesita BaseData.")
		return
	var validation_errors := base_data.validate()
	if not validation_errors.is_empty():
		push_error("BaseData inválido: %s" % "; ".join(validation_errors))
		return
	_health.initialize(base_data.max_health)
	queue_redraw()

func apply_damage(amount: int) -> int:
	return _health.apply_damage(amount)

func get_current_health() -> int:
	return _health.current_health

func get_maximum_health() -> int:
	return _health.maximum_health

func _draw() -> void:
	draw_circle(Vector2(0.0, -5.0), 20.0, BASE_OUTLINE)
	draw_circle(Vector2(0.0, -5.0), 15.0, BASE_COLOR)
	draw_arc(Vector2(0.0, -5.0), 19.0, 0.0, TAU, 24, Color(1.0, 0.93, 0.62), 2.0, true)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(-6.0, 1.0),
		"B",
		HORIZONTAL_ALIGNMENT_CENTER,
		12.0,
		16,
		BASE_OUTLINE
	)

func _on_health_changed(current_health: int, maximum_health: int) -> void:
	health_changed.emit(current_health, maximum_health)
	queue_redraw()

func _on_health_depleted() -> void:
	defeated.emit()
