class_name TerrainPieceCellData
extends Resource

@export var local_coord: Vector2i = Vector2i.ZERO
@export_enum("PATH", "GRASS", "MOUNTAIN") var terrain_type: int = HexCell.TerrainType.PATH
@export_range(0, 2, 1) var elevation: int = 0
@export_range(0, 63, 1) var path_edges: int = 0
@export var visual_variant: StringName = &""

# Derivada al preparar la pieza: abre los laterales contiguos a una salida externa.
var flexible_path_edges: int = 0
