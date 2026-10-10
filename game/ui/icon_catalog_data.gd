@tool
extends Resource

@export_group("Recursos")
@export var gold: Texture2D
@export var mana: Texture2D

@export_group("Capas")
@export var health: Texture2D
@export var armor: Texture2D
@export var shield: Texture2D

@export_group("Torres")
@export var ballista: Texture2D
@export var mortar: Texture2D
@export var tesla_coil: Texture2D
@export var frost_keep: Texture2D
@export var flame_thrower: Texture2D
@export var poison_sprayer: Texture2D
@export var shredder: Texture2D

@export_group("Estados")
@export var burn: Texture2D
@export var slow: Texture2D
@export var poison: Texture2D
@export var bleed: Texture2D

@export_group("Cursor")
@export var cursor_default: Texture2D
@export var cursor_interact: Texture2D
@export var cursor_invalid: Texture2D
@export var cursor_build: Texture2D

func get_icon(icon_name: StringName) -> Texture2D:
	var icon: Texture2D
	match icon_name:
		&"gold": icon = gold
		&"mana": icon = mana
		&"health": icon = health
		&"armor": icon = armor
		&"shield": icon = shield
		&"ballista": icon = ballista
		&"mortar": icon = mortar
		&"tesla_coil": icon = tesla_coil
		&"frost_keep": icon = frost_keep
		&"flame_thrower": icon = flame_thrower
		&"poison_sprayer": icon = poison_sprayer
		&"shredder": icon = shredder
		&"burn": icon = burn
		&"slow": icon = slow
		&"poison": icon = poison
		&"bleed": icon = bleed
		&"cursor_default": icon = cursor_default
		&"cursor_interact": icon = cursor_interact
		&"cursor_invalid": icon = cursor_invalid
		&"cursor_build": icon = cursor_build
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
