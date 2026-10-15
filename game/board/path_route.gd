class_name PathRoute
extends RefCounted

var spawn_endpoint: PathEndpoint
var base_endpoint: PathEndpoint
var cells: Array[Vector2i] = []
var is_reachable: bool = false
