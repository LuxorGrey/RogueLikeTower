extends RefCounted

const ICON_ROOT: String = "res://assets/sprites/ui/icons/"
const DISPLAY_HEIGHT_MULTIPLIER: float = 1.12
const TOWER_FILES: Dictionary = {
	"ballista": "ballista.png",
	"mortar": "mortar.png",
	"tesla_coil": "tesla_coil.png",
	"poison_sprayer": "poison_sprayer.png",
	"flame_thrower": "flame_thrower.png",
	"frost_keep": "frost_keep.png",
	"shredder": "shredder.png",
}

static var _tower_texture_cache: Dictionary[StringName, Texture2D] = {}

static func get_definition(tower_id: StringName) -> Dictionary:
	var normalized_id: String = String(tower_id)
	if normalized_id.ends_with("_demo"):
		normalized_id = normalized_id.trim_suffix("_demo")
	if not TOWER_FILES.has(normalized_id):
		return {}
	return {"icon_file": String(TOWER_FILES[normalized_id]).trim_suffix(".png")}

static func get_tower_texture(tower_id: StringName) -> Texture2D:
	var definition: Dictionary = get_definition(tower_id)
	if definition.is_empty():
		return null
	var normalized_id: StringName = StringName(definition["icon_file"])
	if _tower_texture_cache.has(normalized_id):
		return _tower_texture_cache[normalized_id]
	var texture_path: String = ICON_ROOT + String(TOWER_FILES[String(normalized_id)])
	var texture: Texture2D = ResourceLoader.load(texture_path) as Texture2D
	if texture == null:
		push_error("No se pudo cargar el sprite completo de torre: %s" % texture_path)
		return null
	_tower_texture_cache[normalized_id] = texture
	return texture

static func get_tower_anchor_offset(_tower_id: StringName) -> Vector2:
	return Vector2.ZERO
