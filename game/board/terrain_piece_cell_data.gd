class_name TerrainPieceCellData
extends Resource

@export var local_coord: Vector2i = Vector2i.ZERO
@export_enum("PATH", "GRASS", "MOUNTAIN") var terrain_type: int = HexCell.TerrainType.PATH
@export_range(0, 3, 1) var elevation: int = 0
@export_range(0, 63, 1) var path_edges: int = 0
@export var visual_variant: StringName = &""

# Derivada al preparar la pieza: abre los laterales contiguos a una salida externa.
var flexible_path_edges: int = 0

# Contenido asignado a una oferta concreta. Las plantillas del catálogo los dejan vacíos.
var obstacle_type: int = HexCell.ObstacleType.NONE
var chest_available: bool = false
var decorative_prop_ids: Array[StringName] = []
