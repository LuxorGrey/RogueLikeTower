extends RefCounted

const TOWER_ART_ROOT: String = "res://assets/sprites/towers/"
const DISPLAY_HEIGHT_MULTIPLIER: float = 1.12
const IDLE_FRAME_RATE: float = 2.4
const ATTACK_FRAME_RATE: float = 12.0
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
static var _tower_sprite_frames_cache: Dictionary[StringName, SpriteFrames] = {}

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
	var texture_path: String = TOWER_ART_ROOT + String(TOWER_FILES[String(normalized_id)])
	var texture: Texture2D = ResourceLoader.load(texture_path) as Texture2D
	if texture == null:
		push_error("No se pudo cargar el sprite completo de torre: %s" % texture_path)
		return null
	_tower_texture_cache[normalized_id] = texture
	return texture

static func get_tower_sprite_frames(tower_id: StringName) -> SpriteFrames:
	var definition: Dictionary = get_definition(tower_id)
	if definition.is_empty():
		return null
	var normalized_id: StringName = StringName(definition["icon_file"])
	if _tower_sprite_frames_cache.has(normalized_id):
		return _tower_sprite_frames_cache[normalized_id]
	var sheet_path: String = TOWER_ART_ROOT + String(normalized_id) + "_animations.png"
	var sheet: Texture2D = ResourceLoader.load(sheet_path) as Texture2D
	if sheet == null:
		push_warning("No se pudo cargar el spritesheet animado de torre: %s" % sheet_path)
		return null
	var sheet_width: int = sheet.get_width()
	var sheet_height: int = sheet.get_height()
	if sheet_width < 2 or sheet_height < 2:
		push_warning("El spritesheet de torre debe tener una cuadrícula 2x2: %s" % sheet_path)
		return null
	var frame_size := Vector2(float(sheet_width) / 2.0, float(sheet_height) / 2.0)
	var sprite_frames := SpriteFrames.new()
	sprite_frames.add_animation(&"idle")
	sprite_frames.set_animation_speed(&"idle", IDLE_FRAME_RATE)
	sprite_frames.set_animation_loop(&"idle", true)
	sprite_frames.add_animation(&"attack")
	sprite_frames.set_animation_speed(&"attack", ATTACK_FRAME_RATE)
	sprite_frames.set_animation_loop(&"attack", false)
	for frame_index in range(4):
		var atlas_frame := AtlasTexture.new()
		atlas_frame.atlas = sheet
		var frame_position := Vector2(
			float(frame_index % 2),
			float(floori(float(frame_index) / 2.0))
		) * frame_size
		atlas_frame.region = Rect2(frame_position, frame_size)
		atlas_frame.filter_clip = true
		var animation_name: StringName = &"idle" if frame_index < 2 else &"attack"
		sprite_frames.add_frame(animation_name, atlas_frame)
	_tower_sprite_frames_cache[normalized_id] = sprite_frames
	return sprite_frames

static func get_tower_anchor_offset(_tower_id: StringName) -> Vector2:
	return Vector2.ZERO
