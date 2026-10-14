class_name TerrainRegionOutline
extends RefCounted

static func draw_contour(
	canvas: CanvasItem,
	corners: PackedVector2Array,
	edge_indices: PackedInt32Array,
	color: Color,
	width: float
) -> void:
	if canvas == null or corners.size() != 6 or edge_indices.is_empty():
		return
	var cap_radius: float = width * 0.5
	var keyline_color := Color(0.012, 0.018, 0.02, 0.76)
	var keyline_width: float = width + 2.2
	for direction_variant in edge_indices:
		var direction_index: int = int(direction_variant)
		var edge_start: Vector2 = corners[posmod(direction_index + 1, 6)]
		var edge_end: Vector2 = corners[posmod(direction_index + 2, 6)]
		# Trazo oscuro y color centrado imitan el outline de objetos sin alterar
		# la geometría axial ni introducir juntas entre celdas de una región.
		canvas.draw_line(edge_start, edge_end, keyline_color, keyline_width, true)
		canvas.draw_circle(edge_start, keyline_width * 0.5, keyline_color)
		canvas.draw_circle(edge_end, keyline_width * 0.5, keyline_color)
		canvas.draw_line(edge_start, edge_end, color, width, true)
		canvas.draw_circle(edge_start, cap_radius, color)
		canvas.draw_circle(edge_end, cap_radius, color)

static func get_exposed_edges(
	region_ids_by_coord: Dictionary[Vector2i, Vector2i]
) -> Dictionary[Vector2i, PackedInt32Array]:
	var exposed_edges_by_coord: Dictionary[Vector2i, PackedInt32Array] = {}
	for coord in region_ids_by_coord:
		var region_id: Vector2i = region_ids_by_coord[coord]
		var edge_indices := PackedInt32Array()
		for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
			var neighbor_coord: Vector2i = coord + HexCoord.DIRECTION_OFFSETS[direction_index]
			if not region_ids_by_coord.has(neighbor_coord):
				edge_indices.append(direction_index)
				continue
			if region_ids_by_coord[neighbor_coord] != region_id:
				edge_indices.append(direction_index)
		exposed_edges_by_coord[coord] = edge_indices
	return exposed_edges_by_coord
