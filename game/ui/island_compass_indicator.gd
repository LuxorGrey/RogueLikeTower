class_name IslandCompassIndicator
extends Control

const RADAR_CENTER: Vector2 = Vector2(28.0, 29.0)
const RADAR_RADIUS: float = 24.0
const MARKER_RADIUS: float = 17.0

var _target: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

func set_target(target: Dictionary) -> void:
	_target = target.duplicate()
	visible = not _target.is_empty()
	queue_redraw()

func _draw() -> void:
	if _target.is_empty():
		return
	var font: Font = get_theme_font(&"font")
	var outer_ring: PackedVector2Array = _rough_ring(RADAR_CENTER, RADAR_RADIUS, 0.25)
	var inner_ring: PackedVector2Array = _rough_ring(RADAR_CENTER, RADAR_RADIUS - 4.0, 1.1)
	draw_colored_polygon(outer_ring, Color("#c8e8c1"))
	draw_polyline(outer_ring, Color("#283f3d"), 4.0, true)
	draw_polyline(inner_ring, Color("#f5f0d2"), 2.0, true)

	# A few uneven ticks make the scope read like a hand-drawn toy radar.
	for tick_index in 8:
		var angle: float = TAU * float(tick_index) / 8.0
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(
			RADAR_CENTER + direction * 19.0,
			RADAR_CENTER + direction * 22.0,
			Color("#55766b"),
			1.5,
			true
		)
	draw_line(
			RADAR_CENTER + Vector2(-9.0, 1.0),
			RADAR_CENTER + Vector2(9.0, -1.0),
			Color("#7ca38d"),
			1.0,
			true
		)
	draw_line(
			RADAR_CENTER + Vector2(0.0, -8.0),
			RADAR_CENTER + Vector2(1.0, 8.0),
			Color("#7ca38d"),
			1.0,
			true
		)

	var world_position: Vector2 = _target.get("world_position", Vector2.ZERO)
	var camera_position: Vector2 = _target.get("camera_position", Vector2.ZERO)
	var direction: Vector2 = world_position - camera_position
	if direction.length_squared() < 0.001:
		direction = Vector2.UP
	else:
		direction = direction.normalized()
	var marker_position: Vector2 = RADAR_CENTER + direction * MARKER_RADIUS
	draw_line(RADAR_CENTER, marker_position, Color("#334842"), 4.0, true)
	draw_line(RADAR_CENTER, marker_position, Color("#fff3c0"), 1.7, true)
	draw_circle(RADAR_CENTER, 3.5, Color("#fff8dc"))
	draw_circle(RADAR_CENTER, 2.0, Color("#374b42"))
	_draw_treasure_marker(marker_position, direction)

	var distance_hexes: int = ceili(float(_target.get("distance_hexes", 0.0)))
	var spawn_round: int = int(_target.get("spawn_round", 1))
	var campaign_round: int = int(_target.get("campaign_round", spawn_round))
	var island_number: int = int(_target.get("island_number", 1))
	var island_label: String = "ISLA %d" % island_number
	if spawn_round > campaign_round:
		island_label = "ISLA R%d" % spawn_round
	draw_string(font, Vector2(61.0, 25.0), island_label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15, Color("#33463c"))
	draw_string(
		font,
		Vector2(61.0, 45.0),
		"a %d hex" % distance_hexes,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		13,
		Color("#5b7868")
	)

func _draw_treasure_marker(position: Vector2, direction: Vector2) -> void:
	var side := Vector2(-direction.y, direction.x)
	var marker := PackedVector2Array([
		position + direction * 4.5,
		position - direction * 3.0 + side * 4.0,
		position - direction * 2.5 - side * 4.0,
	])
	draw_colored_polygon(marker, Color("#efb75e"))
	draw_polyline(marker, Color("#704d32"), 1.5, true)
	draw_circle(position, 1.4, Color("#fff4c9"))

func _rough_ring(center: Vector2, radius: float, phase: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point_index in 32:
		var angle: float = TAU * float(point_index) / 32.0
		var wobble: float = sin(angle * 3.0 + phase) * 1.15 + cos(angle * 5.0 - phase) * 0.55
		var point_radius: float = radius + wobble
		points.append(center + Vector2(cos(angle), sin(angle)) * point_radius)
	points.append(points[0])
	return points
