class_name HexCell
extends RefCounted

enum TerrainType { PATH, GRASS, MOUNTAIN }
enum ObstacleType {
	NONE = -1,
	BRAMBLE_BUSH,
	FALLEN_LOG,
	BRANCH_PILE,
	TREE_STUMP,
	ROCK_AND_WOOD,
	SUPPLY_CRATE,
	EXPOSED_ROOTS,
	MOSSY_ROCK_CLUSTER,
}

var coord: HexCoord
var terrain_type: int = TerrainType.PATH
var elevation: int = 0
var buildable: bool = false
var occupied: bool = false
var tower_id: StringName = &""
var obstacle_type: int = ObstacleType.NONE
var chest_available: bool = false
var decorative_prop_ids: Array[StringName] = []
var piece_instance_id: int = -1
var path_edges: int = 0
var flexible_path_edges: int = 0
var visual_variant: StringName = &""

func _init(cell_coord: HexCoord) -> void:
	coord = cell_coord

static func is_valid_terrain_elevation(terrain: int, cell_elevation: int) -> bool:
	match terrain:
		TerrainType.PATH:
			return cell_elevation == 0
		TerrainType.GRASS:
			return cell_elevation == 1 or cell_elevation == 2
		TerrainType.MOUNTAIN:
			return cell_elevation == 2 or cell_elevation == 3
	return false
