class_name SpawnPortal
extends Node2D

signal hover_changed(portal: Node2D, hovered: bool)
signal selected(portal: Node2D)

const PORTAL_SPRITE_SHEET: Texture2D = preload("res://assets/sprites/terrain/spawn_portal_SpriteSheet.png")
const PORTAL_ANIMATION_NAME: StringName = &"portal"
const PORTAL_FRAME_COLUMNS: int = 4
const PORTAL_FRAME_ROWS: int = 2
const PORTAL_FRAME_COUNT: int = PORTAL_FRAME_COLUMNS * PORTAL_FRAME_ROWS - 1
const PORTAL_ANIMATION_FPS: float = 10.0
const OBSTACLE_HOVER_SHADER: Shader = preload("res://game/board/obstacle_hover_glow.gdshader")
const INTERACTABLE_OUTLINE_SHADER: Shader = preload("res://game/board/interactable_outline.gdshader")

@export_group("Portal appearance")
@export var portal_sprite_size: Vector2 = Vector2(96.0, 96.0)
@export_range(-160.0, 0.0, 1.0) var portal_sprite_offset_y: float = -44.0
@export_range(0.2, 16.0, 0.1) var pulse_period: float = 3.8
@export_range(0.5, 1.5, 0.005) var pulse_min_scale: float = 0.96
@export_range(0.5, 1.5, 0.005) var pulse_max_scale: float = 1.055
@export_range(0.0, 12.0, 0.5) var portal_outline_size_px: float = 3.0

@onready var _sprite: AnimatedSprite2D = %Sprite
@onready var _hover_area: Area2D = %HoverArea
@onready var _closing_marker: Label = %ClosingSpawnMarker

var _candidate_preview: bool = false
var _closing_preview: bool = false
var _is_hovered: bool = false
var _pulse_time: float = 0.0
var _pulse_phase: float = 0.0
var _base_sprite_scale: Vector2 = Vector2.ONE
var _outline_sprite: Sprite2D
var _interactable_outline_sprite: Sprite2D
var _endpoint_key: String = ""
var _preview_entries: Array[Dictionary] = []
var _preview_wave_number: int = 0
var _preview_enemy_count: int = 0
var _animation_phase: float = -1.0

func _ready() -> void:
	z_as_relative = false
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_configure_looping_animation()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_sprite.play(PORTAL_ANIMATION_NAME)
	var starting_phase: float = float(posmod(hash(String(name)), 10000)) / 10000.0
	set_animation_phase(starting_phase)
	var frame_texture: Texture2D = _get_current_frame_texture()
	if frame_texture != null:
		_base_sprite_scale = portal_sprite_size / Vector2(frame_texture.get_size())
	_sprite.scale = _base_sprite_scale
	_sprite.position = Vector2(0.0, portal_sprite_offset_y)
	_pulse_phase = float(posmod(absi(hash(String(name))), 10000)) / 10000.0 * TAU
	_hover_area.input_pickable = true
	_hover_area.mouse_entered.connect(_on_mouse_entered)
	_hover_area.mouse_exited.connect(_on_mouse_exited)
	_hover_area.input_event.connect(_on_hover_area_input_event)
	_sprite.frame_changed.connect(_sync_hover_outline_texture)
	_create_interactable_outline()
	_create_hover_outline()
	_update_pulse()
	set_process(true)

func _exit_tree() -> void:
	clear_hover()

func _process(delta: float) -> void:
	_pulse_time += delta
	_update_pulse()

func set_endpoint_key(endpoint_key: String) -> void:
	_endpoint_key = endpoint_key

func get_endpoint_key() -> String:
	return _endpoint_key

func set_animation_phase(phase: float) -> void:
	if _sprite == null or _sprite.sprite_frames == null:
		return
	var normalized_phase: float = fposmod(phase, 1.0)
	if is_equal_approx(_animation_phase, normalized_phase):
		return
	_animation_phase = normalized_phase
	var frame_count: int = _sprite.sprite_frames.get_frame_count(PORTAL_ANIMATION_NAME)
	if frame_count <= 0:
		return
	var frame_position: float = normalized_phase * float(frame_count)
	var frame_index: int = mini(int(floor(frame_position)), frame_count - 1)
	_sprite.set_frame_and_progress(frame_index, frame_position - float(frame_index))

func _configure_looping_animation() -> void:
	var frames := SpriteFrames.new()
	frames.add_animation(PORTAL_ANIMATION_NAME)
	frames.set_animation_loop(PORTAL_ANIMATION_NAME, true)
	frames.set_animation_speed(PORTAL_ANIMATION_NAME, PORTAL_ANIMATION_FPS)
	var frame_size: Vector2 = Vector2(PORTAL_SPRITE_SHEET.get_size()) / Vector2(
		float(PORTAL_FRAME_COLUMNS),
		float(PORTAL_FRAME_ROWS)
	)
	for frame_index in range(PORTAL_FRAME_COUNT):
		var frame_texture := AtlasTexture.new()
		frame_texture.atlas = PORTAL_SPRITE_SHEET
		var frame_coordinate := Vector2(
			float(frame_index % PORTAL_FRAME_COLUMNS),
			floorf(float(frame_index) / float(PORTAL_FRAME_COLUMNS))
		)
		frame_texture.region = Rect2(frame_coordinate * frame_size, frame_size)
		frames.add_frame(PORTAL_ANIMATION_NAME, frame_texture)
	_sprite.sprite_frames = frames
	_sprite.animation = PORTAL_ANIMATION_NAME
	_sprite.centered = true

func _get_current_frame_texture() -> Texture2D:
	if _sprite == null or _sprite.sprite_frames == null:
		return null
	var frame_count: int = _sprite.sprite_frames.get_frame_count(PORTAL_ANIMATION_NAME)
	if frame_count <= 0:
		return null
	var frame_index: int = clampi(_sprite.frame, 0, frame_count - 1)
	return _sprite.sprite_frames.get_frame_texture(PORTAL_ANIMATION_NAME, frame_index)

func _sync_hover_outline_texture() -> void:
	var current_frame: Texture2D = _get_current_frame_texture()
	if _outline_sprite != null and is_instance_valid(_outline_sprite):
		_outline_sprite.texture = current_frame
	if _interactable_outline_sprite != null and is_instance_valid(_interactable_outline_sprite):
		_interactable_outline_sprite.texture = current_frame

func set_wave_preview(entries: Array[Dictionary], wave_number: int) -> void:
	_preview_entries = entries.duplicate()
	_preview_wave_number = maxi(wave_number, 0)
	_preview_enemy_count = 0
	for entry in _preview_entries:
		_preview_enemy_count += maxi(int(entry.get("count", 0)), 0)
	if _is_hovered:
		hover_changed.emit(self, true)

func clear_hover() -> void:
	if not _is_hovered:
		return
	_is_hovered = false
	_update_hover_outline()
	hover_changed.emit(self, false)

func get_wave_preview_tooltip_text() -> String:
	var lines := PackedStringArray()
	if _closing_preview:
		lines.append("¡ESTE SPAWN SE CERRARÁ SI CONFIRMAS LA PIEZA!")
	lines.append("Ronda %02d · %d enemigos" % [_preview_wave_number, _preview_enemy_count])
	return "\n".join(lines)

func get_wave_preview_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry in _preview_entries:
		entries.append(entry.duplicate())
	return entries

func get_wave_preview_round_number() -> int:
	return _preview_wave_number

func get_wave_preview_enemy_count() -> int:
	return _preview_enemy_count

func set_candidate_preview(is_candidate: bool) -> void:
	if _candidate_preview == is_candidate:
		return
	_candidate_preview = is_candidate
	_update_pulse()
	_update_hover_outline()

func set_closing_preview(is_closing: bool) -> void:
	if _closing_preview == is_closing:
		return
	_closing_preview = is_closing
	if _closing_marker != null:
		_closing_marker.visible = _closing_preview
	_update_pulse()
	_update_hover_outline()

func _update_pulse() -> void:
	var cycle: float = (_pulse_time / pulse_period) * TAU + _pulse_phase
	var pulse: float = 0.5 + 0.5 * sin(cycle)
	var scale_factor: float = lerpf(pulse_min_scale, pulse_max_scale, pulse)
	_sprite.scale = _base_sprite_scale * scale_factor
	var resting_color: Color = Color("#ff7770") if _closing_preview else (
		Color(0.65, 1.0, 0.78, 1.0) if _candidate_preview else Color.WHITE
	)
	_sprite.modulate = resting_color.lerp(Color.WHITE, pulse * 0.22)
	if _outline_sprite != null:
		_outline_sprite.scale = _sprite.scale
	if _interactable_outline_sprite != null:
		_interactable_outline_sprite.scale = _sprite.scale

func _create_interactable_outline() -> void:
	_interactable_outline_sprite = Sprite2D.new()
	_interactable_outline_sprite.name = "PortalInteractableOutline"
	_interactable_outline_sprite.centered = true
	_interactable_outline_sprite.texture = _get_current_frame_texture()
	_interactable_outline_sprite.position = _sprite.position
	_interactable_outline_sprite.scale = _sprite.scale
	_interactable_outline_sprite.z_index = _sprite.z_index - 1
	_interactable_outline_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var outline_material := ShaderMaterial.new()
	outline_material.shader = INTERACTABLE_OUTLINE_SHADER
	outline_material.set_shader_parameter("outline_only", true)
	outline_material.set_shader_parameter("outline_color", Color.WHITE)
	outline_material.set_shader_parameter("outline_size_px", portal_outline_size_px)
	_interactable_outline_sprite.material = outline_material
	_interactable_outline_sprite.visible = true
	add_child(_interactable_outline_sprite)
	move_child(_interactable_outline_sprite, _sprite.get_index())

func _create_hover_outline() -> void:
	_outline_sprite = Sprite2D.new()
	_outline_sprite.name = "PortalAlphaHoverOutline"
	_outline_sprite.centered = true
	_outline_sprite.texture = _get_current_frame_texture()
	_outline_sprite.position = _sprite.position
	_outline_sprite.scale = _sprite.scale
	_outline_sprite.z_index = _sprite.z_index - 1
	_outline_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var outline_material := ShaderMaterial.new()
	outline_material.shader = OBSTACLE_HOVER_SHADER
	_outline_sprite.material = outline_material
	_outline_sprite.visible = false
	add_child(_outline_sprite)
	move_child(_outline_sprite, _sprite.get_index())
	_update_hover_outline()

func _update_hover_outline() -> void:
	if _outline_sprite == null:
		return
	_outline_sprite.visible = _is_hovered
	var outline_material := _outline_sprite.material as ShaderMaterial
	if outline_material == null:
		return
	var outline_color: Color = Color("#ff5d58") if _closing_preview else (
		Color("#ffe28a") if _candidate_preview else Color("#89e7ff")
	)
	outline_material.set_shader_parameter("outline_color", outline_color)

func _on_mouse_entered() -> void:
	_is_hovered = true
	_update_hover_outline()
	hover_changed.emit(self, true)

func _on_mouse_exited() -> void:
	_is_hovered = false
	_update_hover_outline()
	hover_changed.emit(self, false)

func _on_hover_area_input_event(viewport: Node, event: InputEvent, _shape_index: int) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			selected.emit(self)
		viewport.set_input_as_handled()
