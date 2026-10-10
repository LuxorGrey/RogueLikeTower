extends RefCounted

const ICON_CATALOG_DATA: Resource = preload("res://game/ui/resources/icon_catalog.tres")

func get_icon(icon_name: StringName) -> Texture2D:
	return ICON_CATALOG_DATA.call("get_icon", icon_name) as Texture2D

func normalize_tower_icon_id(tower_id: StringName) -> StringName:
	return StringName(ICON_CATALOG_DATA.call("normalize_tower_icon_id", tower_id))

func get_tower_icon(tower_id: StringName) -> Texture2D:
	return ICON_CATALOG_DATA.call("get_tower_icon", tower_id) as Texture2D
