class_name SpawnPortal
extends Node2D

signal hover_changed(portal: Node2D, hovered: bool)

const PORTAL_SPRITE_SIZE: Vector2 = Vector2(112.0, 168.0)
const PORTAL_TEXTURE_SIZE: Vector2 = Vector2(224.0, 336.0)
const PULSE_PERIOD: float = 3.8
const PULSE_MIN_SCALE: float = 0.96
const PULSE_MAX_SCALE: float = 1.055
const OBSTACLE_HOVER_SHADER: Shader = preload("res://game/board/obstacle_hover_glow.gdshader")
const PREVIEW_LAYER_SCRIPT: Script = preload("res://game/board/spawn_portal_preview_layer.gd")

@onready var _sprite: Sprite2D = %Sprite
@onready var _hover_area: Area2D = %HoverArea

var _candidate_preview: bool = false
var _is_hovered: bool = false
var _pulse_time: float = 0.0
var _pulse_phase: float = 0.0
var _base_sprite_scale: Vector2 = Vector2.ONE
var _outline_sprite: Sprite2D
var _preview_layer: Node2D
var _endpoint_key: String = ""
var _preview_entries: Array[Dictionary] = []
var _preview_wave_number: int = 0
var _preview_enemy_count: int = 0

func _ready() -> void:
	z_as_relative = false
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_base_sprite_scale = PORTAL_SPRITE_SIZE / PORTAL_TEXTURE_SIZE
	_sprite.scale = _base_sprite_scale
	_sprite.position = Vector2(0.0, -80.0)
	_pulse_phase = float(posmod(absi(hash(String(name))), 10000)) / 10000.0 * TAU
	_hover_area.input_pickable = true
	_hover_area.mouse_entered.connect(_on_mouse_entered)
	_hover_area.mouse_exited.connect(_on_mouse_exited)
	_hover_area.input_event.connect(_on_hover_area_input_event)
	_create_hover_outline()
	_create_enemy_preview_layer()
	_update_pulse()
	set_process(true)

func _process(delta: float) -> void:
	_pulse_time += delta
	_update_pulse()

func set_endpoint_key(endpoint_key: String) -> void:
	_endpoint_key = endpoint_key

func get_endpoint_key() -> String:
	return _endpoint_key

func set_wave_preview(entries: Array[Dictionary], wave_number: int) -> void:
	_preview_entries = entries.duplicate()
	_preview_wave_number = maxi(wave_number, 0)
	_preview_enemy_count = 0
	for entry in _preview_entries:
		_preview_enemy_count += maxi(int(entry.get("count", 0)), 0)
	if _preview_layer != null and _preview_layer.has_method("set_entries"):
		_preview_layer.call("set_entries", _preview_entries)
	if _is_hovered:
		hover_changed.emit(self, true)

func get_wave_preview_tooltip_text() -> String:
	var lines := PackedStringArray()
	lines.append("Ronda %02d · %d enemigos" % [_preview_wave_number, _preview_enemy_count])
	if _preview_entries.is_empty():
		lines.append("Ningún enemigo asignado a esta salida.")
		return "\n".join(lines)
	for entry in _preview_entries:
		lines.append("%s ×%d" % [String(entry.get("display_name", "Enemigo")), int(entry.get("count", 0))])
	return "\n".join(lines)

func set_candidate_preview(is_candidate: bool) -> void:
	if _candidate_preview == is_candidate:
		return
	_candidate_preview = is_candidate
	_update_pulse()
	_update_hover_outline()

func _update_pulse() -> void:
	var cycle: float = (_pulse_time / PULSE_PERIOD) * TAU + _pulse_phase
	var pulse: float = 0.5 + 0.5 * sin(cycle)
	var scale_factor: float = lerpf(PULSE_MIN_SCALE, PULSE_MAX_SCALE, pulse)
	_sprite.scale = _base_sprite_scale * scale_factor
	var resting_color: Color = Color(0.65, 1.0, 0.78, 1.0) if _candidate_preview else Color.WHITE
	_sprite.modulate = resting_color.lerp(Color.WHITE, pulse * 0.22)
	if _outline_sprite != null:
		_outline_sprite.scale = _sprite.scale

func _create_hover_outline() -> void:
	_outline_sprite = Sprite2D.new()
	_outline_sprite.name = "PortalAlphaHoverOutline"
	_outline_sprite.centered = true
	_outline_sprite.texture = _sprite.texture
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

func _create_enemy_preview_layer() -> void:
	_preview_layer = PREVIEW_LAYER_SCRIPT.new() as Node2D
	_preview_layer.name = "NextWaveEnemyPreviews"
	_preview_layer.position = Vector2(0.0, -178.0)
	_preview_layer.z_index = 4095
	_preview_layer.z_as_relative = false
	add_child(_preview_layer)

func _update_hover_outline() -> void:
	if _outline_sprite == null:
		return
	_outline_sprite.visible = _is_hovered
	var outline_material := _outline_sprite.material as ShaderMaterial
	if outline_material == null:
		return
	var outline_color: Color = Color("#ffe28a") if _candidate_preview else Color("#89e7ff")
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
		viewport.set_input_as_handled()
