extends RefCounted

const ICONS: Dictionary = {
	&"gold": preload("res://game/ui/icons/gold.png"),
	&"mana": preload("res://game/ui/icons/mana.png"),
	&"health": preload("res://game/ui/icons/health.png"),
	&"armor": preload("res://game/ui/icons/armor.png"),
	&"shield": preload("res://game/ui/icons/shield.png"),
	&"ballista": preload("res://game/ui/icons/ballista.png"),
	&"mortar": preload("res://game/ui/icons/mortar.png"),
	&"tesla_coil": preload("res://game/ui/icons/tesla_coil.png"),
	&"frost_keep": preload("res://game/ui/icons/frost_keep.png"),
	&"flame_thrower": preload("res://game/ui/icons/flame_thrower.png"),
	&"poison_sprayer": preload("res://game/ui/icons/poison_sprayer.png"),
	&"shredder": preload("res://game/ui/icons/shredder.png"),
	&"burn": preload("res://game/ui/icons/burn.png"),
	&"slow": preload("res://game/ui/icons/slow.png"),
	&"poison": preload("res://game/ui/icons/poison.png"),
	&"bleed": preload("res://game/ui/icons/bleed.png"),
}

func get_icon(icon_name: StringName) -> Texture2D:
	var icon: Texture2D = ICONS.get(icon_name) as Texture2D
	if icon == null:
		push_warning("No existe el icono de interfaz '%s'." % icon_name)
	return icon

func normalize_tower_icon_id(tower_id: StringName) -> StringName:
	var icon_name: String = String(tower_id)
	if icon_name.ends_with("_demo"):
		icon_name = icon_name.trim_suffix("_demo")
	return StringName(icon_name)

func get_tower_icon(tower_id: StringName) -> Texture2D:
	return get_icon(normalize_tower_icon_id(tower_id))
