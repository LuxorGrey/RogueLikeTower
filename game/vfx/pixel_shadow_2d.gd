extends Sprite2D

const SHADOW_SHADER: Shader = preload("res://game/vfx/pixel_shadow_2d.gdshader")
const VERTICAL_SQUASH: float = 0.22
const ROTATION_SPEED: float = 0.11
const ELEVATION_SHADOW_LENGTH: float = 8.0

static var _alpha_bounds_cache: Dictionary = {}
static var _shared_material: ShaderMaterial

var _contact_point: Vector2 = Vector2.ZERO
var _base_cast_distance_px: float = 0.0
var _base_shadow_scale_y: float = 0.0
var _elevation: int = 0
var _lift_height_px: float = 0.0
var _opacity: float = 0.27

func configure_from_texture(
	source_texture: Texture2D,
	display_size: Vector2,
	source_center: Vector2,
	base_cast_distance_px: float,
	elevation: int = 0,
	shadow_opacity: float = 0.27,
	behind_parent: bool = true
) -> void:
	if source_texture == null or display_size.x <= 0.0 or display_size.y <= 0.0:
		visible = false
		set_process(false)
		return

	var texture_size: Vector2i = source_texture.get_size()
	if texture_size.x <= 0 or texture_size.y <= 0:
		visible = false
		set_process(false)
		return

	var alpha_bounds: Rect2i = _get_alpha_bounds(source_texture)
	var alpha_center_x: float = float(alpha_bounds.position.x) + float(alpha_bounds.size.x) * 0.5
	var alpha_bottom_y: float = float(alpha_bounds.position.y + alpha_bounds.size.y)
	var display_scale := Vector2(
		display_size.x / float(texture_size.x),
		display_size.y / float(texture_size.y)
	)

	texture = source_texture
	centered = false
	flip_h = false
	offset = Vector2(-alpha_center_x, -alpha_bottom_y)
	scale = Vector2(display_scale.x, display_scale.y * VERTICAL_SQUASH)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	material = _get_shared_material()
	use_parent_material = false
	self_modulate = Color(1.0, 1.0, 1.0, clampf(shadow_opacity, 0.0, 0.8))
	show_behind_parent = behind_parent
	z_as_relative = true
	z_index = 0
	visible = true

	_contact_point = source_center + Vector2(
		(alpha_center_x - float(texture_size.x) * 0.5) * display_scale.x,
		(alpha_bottom_y - float(texture_size.y) * 0.5) * display_scale.y
	)
	_base_cast_distance_px = maxf(base_cast_distance_px, 0.0)
	_base_shadow_scale_y = scale.y
	_elevation = clampi(elevation, 0, 2)
	_lift_height_px = 0.0
	_opacity = clampf(shadow_opacity, 0.0, 0.8)
	set_process(true)
	_update_light_projection()

func set_source_flipped(is_flipped: bool) -> void:
	flip_h = is_flipped

func set_lift_height_px(lift_height_px: float) -> void:
	_lift_height_px = maxf(lift_height_px, 0.0)

func _process(_delta: float) -> void:
	_update_light_projection()

func _update_light_projection() -> void:
	# All casters share one slowly rotating screen-space light direction. This
	# keeps the shadows coherent while making height visible through cast length.
	var angle: float = float(Time.get_ticks_msec()) * 0.001 * ROTATION_SPEED
	rotation = angle
	var light_direction := Vector2(cos(angle), sin(angle))
	var cast_distance: float = (
		_base_cast_distance_px
		+ float(_elevation) * ELEVATION_SHADOW_LENGTH
		+ _lift_height_px * 1.15
	)
	position = _contact_point + light_direction * cast_distance
	var lift_softening: float = clampf(_lift_height_px / 60.0, 0.0, 0.35)
	scale.y = _base_shadow_scale_y * (1.0 - lift_softening)
	self_modulate.a = _opacity * (1.0 - lift_softening * 0.55)

static func _get_alpha_bounds(source_texture: Texture2D) -> Rect2i:
	var texture_id: int = source_texture.get_instance_id()
	if _alpha_bounds_cache.has(texture_id):
		var cached_bounds: Rect2i = _alpha_bounds_cache[texture_id]
		return cached_bounds

	var texture_size: Vector2i = source_texture.get_size()
	var bounds := Rect2i(Vector2i.ZERO, texture_size)
	var source_image: Image = source_texture.get_image()
	if source_image != null:
		var used_rect: Rect2i = source_image.get_used_rect()
		if used_rect.size.x > 0 and used_rect.size.y > 0:
			bounds = used_rect
	_alpha_bounds_cache[texture_id] = bounds
	return bounds

static func _get_shared_material() -> ShaderMaterial:
	if _shared_material == null:
		_shared_material = ShaderMaterial.new()
		_shared_material.shader = SHADOW_SHADER
	return _shared_material
