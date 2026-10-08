class_name PathEndpoint
extends RefCounted

enum Role { SPAWN, BASE }

var role: int = Role.SPAWN
var cell_coord: Vector2i = Vector2i.ZERO
var edge_direction: int = -1
var outside_coord: Vector2i = Vector2i.ZERO

func _init(
	endpoint_role: int = Role.SPAWN,
	path_cell_coord: Vector2i = Vector2i.ZERO,
	direction_index: int = -1,
	external_coord: Vector2i = Vector2i.ZERO
) -> void:
	role = endpoint_role
	cell_coord = path_cell_coord
	edge_direction = direction_index
	outside_coord = external_coord
