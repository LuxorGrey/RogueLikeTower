class_name ExplorationIslandData
extends RefCounted

var island_index: int = 0
var island_id: StringName = &""
var spawn_round: int = 1
var anchor_coord: Vector2i = Vector2i.ZERO
var treasure_coord: Vector2i = Vector2i.ZERO
var cells: Array[TerrainPieceCellData] = []
var discovered: bool = false
var treasure_claimed: bool = false
