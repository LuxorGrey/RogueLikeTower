extends RefCounted

const ICON_ROOT: String = "res://assets/sprites/ui/icons/"

static func get_definition(tower_id: StringName) -> Dictionary:
	var normalized_id: String = String(tower_id)
	if normalized_id.ends_with("_demo"):
		normalized_id = normalized_id.trim_suffix("_demo")
	match normalized_id:
		"ballista":
			return _definition(
				"ballista", Rect2i(44, 177, 649, 872), Vector2(370.0, 444.0),
				Rect2i(713, 51, 735, 1015), Vector2(1096.0, 1004.0), -1.08
			)
		"mortar":
			return _definition(
				"mortar", Rect2i(13, 35, 711, 1014), Vector2(377.0, 493.0),
				Rect2i(704, 165, 701, 862), Vector2(1148.0, 987.0), -1.36
			)
		"tesla_coil":
			return _definition(
				"tesla_coil", Rect2i(19, 44, 705, 1038), Vector2(374.0, 486.0),
				Rect2i(704, 5, 724, 1069), Vector2(1085.0, 1015.0), 0.0
			)
		"poison_sprayer":
			return _definition(
				"poison_sprayer", Rect2i(0, 93, 723, 934), Vector2(360.0, 488.0),
				Rect2i(736, 82, 700, 826), Vector2(1085.0, 887.0), 0.0
			)
		"flame_thrower":
			return _definition(
				"flame_thrower", Rect2i(19, 30, 705, 1046), Vector2(375.0, 477.0),
				Rect2i(719, 3, 729, 1063), Vector2(1080.0, 1002.0), 0.0
			)
		"frost_keep":
			return _definition(
				"frost_keep", Rect2i(0, 36, 723, 1040), Vector2(393.0, 497.0),
				Rect2i(744, 60, 704, 1026), Vector2(1098.0, 1008.0), -1.08
			)
		"shredder":
			return _definition(
				"shredder", Rect2i(13, 35, 704, 1014), Vector2(362.0, 485.0),
				Rect2i(741, 46, 686, 1020), Vector2(1080.0, 1005.0), 0.0
			)
		_:
			return {}

static func get_part_texture(tower_id: StringName, part_name: StringName) -> AtlasTexture:
	var definition: Dictionary = get_definition(tower_id)
	if definition.is_empty():
		return null
	var region: Rect2i = definition["base_region"] if part_name == &"base" else definition["turret_region"]
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = load(ICON_ROOT + String(definition["icon_file"]) + ".png") as Texture2D
	atlas_texture.region = region
	atlas_texture.filter_clip = true
	return atlas_texture

static func get_part_offset(
	tower_id: StringName,
	part_name: StringName,
	display_height: float
) -> Vector2:
	var definition: Dictionary = get_definition(tower_id)
	if definition.is_empty():
		return Vector2.ZERO
	var region: Rect2i = definition["base_region"] if part_name == &"base" else definition["turret_region"]
	var source_pivot: Vector2 = definition["base_pivot"] if part_name == &"base" else definition["turret_pivot"]
	var pivot_in_region: Vector2 = source_pivot - Vector2(region.position)
	var scale: float = get_component_scale(tower_id, display_height)
	return (Vector2(region.size) * 0.5 - pivot_in_region) * scale

static func get_component_scale(tower_id: StringName, display_height: float) -> float:
	var definition: Dictionary = get_definition(tower_id)
	if definition.is_empty():
		return 1.0
	var base_region: Rect2i = definition["base_region"]
	var turret_region: Rect2i = definition["turret_region"]
	var base_pivot: Vector2 = definition["base_pivot"]
	var turret_pivot: Vector2 = definition["turret_pivot"]
	var lower_extent: float = float(base_region.end.y) - base_pivot.y
	var upper_extent: float = turret_pivot.y - float(turret_region.position.y)
	return maxf(display_height, 1.0) / maxf(lower_extent + upper_extent, 1.0)

static func get_rest_aim_angle(tower_id: StringName) -> float:
	return float(get_definition(tower_id).get("rest_aim_angle", 0.0))

static func _definition(
	icon_file: String,
	base_region: Rect2i,
	base_pivot: Vector2,
	turret_region: Rect2i,
	turret_pivot: Vector2,
	rest_aim_angle: float
) -> Dictionary:
	return {
		"icon_file": icon_file,
		"base_region": base_region,
		"base_pivot": base_pivot,
		"turret_region": turret_region,
		"turret_pivot": turret_pivot,
		"rest_aim_angle": rest_aim_angle,
	}
