class_name PathRoute
extends RefCounted

var spawn_endpoint: PathEndpoint
var base_endpoint: PathEndpoint
var cells: Array[Vector2i] = []
var is_reachable: bool = false

func get_edge_count() -> int:
	return maxi(cells.size() - 1, 0)
