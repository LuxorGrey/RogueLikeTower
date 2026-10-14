class_name TerrainRegionOutline
extends RefCounted

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
