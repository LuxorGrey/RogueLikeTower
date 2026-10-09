class_name PathFlowOverlay
extends Node2D

const HEX_RADIUS: float = 52.0
const FLOW_SPEED: float = 54.0
const ARROW_SPACING: float = 40.0
const REDRAW_INTERVAL: float = 1.0 / 30.0

const PATH_LINE_SHADOW: Color = Color(0.015, 0.045, 0.025, 0.46)
const PATH_LINE_GLOW: Color = Color("#43cf55", 0.56)
const ARROW_SHADOW: Color = Color(0.015, 0.035, 0.02, 0.92)
const ARROW_FILL: Color = Color("#52ec62")
const ARROW_HIGHLIGHT: Color = Color("#d6ffd1")

var _active_graph: PathGraph
var _candidate_graph: PathGraph
var _flow_time: float = 0.0
var _redraw_timer: float = 0.0

func set_path_graphs(active_graph: PathGraph, candidate_graph: PathGraph = null) -> void:
	_active_graph = active_graph
	_candidate_graph = candidate_graph if candidate_graph != null and candidate_graph.is_valid else null
	queue_redraw()

func _process(delta: float) -> void:
	if _active_graph == null:
		return
	_flow_time += delta
	_redraw_timer -= delta
	if _redraw_timer <= 0.0:
		_redraw_timer = REDRAW_INTERVAL
		queue_redraw()

func _draw() -> void:
	var graph: PathGraph = _candidate_graph if _candidate_graph != null else _active_graph
	if graph == null:
		return
	var drawn_edges: Dictionary[String, bool] = {}
	for route in graph.routes:
		if not route.is_reachable or route.cells.size() < 2:
			continue
		for segment_index in range(route.cells.size() - 1):
			var from_coord: Vector2i = route.cells[segment_index]
			var to_coord: Vector2i = route.cells[segment_index + 1]
			var edge_key: String = "%d,%d>%d,%d" % [from_coord.x, from_coord.y, to_coord.x, to_coord.y]
			if drawn_edges.has(edge_key):
				continue
			drawn_edges[edge_key] = true
			var from_center: Vector2 = _cell_center(from_coord)
			var to_center: Vector2 = _cell_center(to_coord)
			var edge_length: float = from_center.distance_to(to_center)
			var remaining_edges: int = route.cells.size() - 1 - segment_index
			_draw_flow_segment(from_center, to_center, float(remaining_edges) * edge_length)

func _draw_flow_segment(from_center: Vector2, to_center: Vector2, distance_to_base: float) -> void:
	var segment: Vector2 = to_center - from_center
	var segment_length: float = segment.length()
	if segment_length <= 0.0:
		return
	var direction: Vector2 = segment / segment_length
	draw_line(from_center, to_center, PATH_LINE_SHADOW, 13.0, true)
	draw_line(from_center, to_center, PATH_LINE_GLOW, 6.0, true)
	var arrow_distance: float = fposmod(
		_flow_time * FLOW_SPEED + distance_to_base,
		ARROW_SPACING
	)
	while arrow_distance < segment_length:
		if arrow_distance >= 12.0 and arrow_distance <= segment_length - 12.0:
			_draw_arrow(from_center + direction * arrow_distance, direction)
		arrow_distance += ARROW_SPACING

func _draw_arrow(center: Vector2, direction: Vector2) -> void:
	var perpendicular: Vector2 = direction.orthogonal()
	var points := PackedVector2Array([
		center + direction * 10.0,
		center - direction * 2.0 + perpendicular * 8.0,
		center - direction * 2.0 + perpendicular * 3.2,
		center - direction * 11.0 + perpendicular * 3.2,
		center - direction * 11.0 - perpendicular * 3.2,
		center - direction * 2.0 - perpendicular * 3.2,
		center - direction * 2.0 - perpendicular * 8.0,
	])
	var shadow_points := PackedVector2Array()
	for point in points:
		shadow_points.append(point + Vector2(1.5, 2.0))
	draw_colored_polygon(shadow_points, ARROW_SHADOW)
	draw_colored_polygon(points, ARROW_FILL)
	var closed_points := points.duplicate()
	closed_points.append(points[0])
	draw_polyline(closed_points, ARROW_HIGHLIGHT, 1.25, true)

func _cell_center(coord: Vector2i) -> Vector2:
	return HexMath.axial_to_world(HexCoord.new(coord.x, coord.y), HEX_RADIUS)
