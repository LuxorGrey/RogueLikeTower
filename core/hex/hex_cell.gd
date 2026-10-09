class_name HexCell
extends RefCounted

enum TerrainType { PATH, GRASS, MOUNTAIN }
enum ObstacleType { NONE = -1, ROCK, SHARD, TALL_GRASS, TOTEM, STONE_CLUSTER }

var coord: HexCoord
var terrain_type: int = TerrainType.PATH
var elevation: int = 0
var buildable: bool = false
var occupied: bool = false
var tower_id: StringName = &""
var obstacle_type: int = ObstacleType.NONE
var chest_available: bool = false
var piece_instance_id: int = -1
var path_edges: int = 0
var flexible_path_edges: int = 0
var visual_variant: StringName = &""

func _init(cell_coord: HexCoord) -> void:
	coord = cell_coord
