class_name TerrainCellDecoration
extends Node2D

const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")
const OBSTACLE_HOVER_SHADER: Shader = preload("res://game/board/obstacle_hover_glow.gdshader")

const CHEST_DISPLAY_SIZE: Vector2 = Vector2(84.0, 84.0)
const ART_OFFSET_Y: float = 6.0
const OBSTACLE_CENTER_OFFSET: Vector2 = Vector2.ZERO

var _obstacle_type: int = HexCell.ObstacleType.NONE
var _chest_available: bool = false
var _chest_appearance_tween: Tween
var _chest_hover_tween: Tween
var _obstacle_hovered: bool = false
var _chest_hovered: bool = false
var _obstacle_hover_sprite: Sprite2D
var _chest_sprite: Sprite2D
var _chest_hover_sprite: Sprite2D
var _chest_base_position: Vector2 = Vector2.ZERO
var _chest_base_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_chest_sprite = Sprite2D.new()
	_chest_sprite.name = "TreasureChestSprite"
	_chest_sprite.centered = true
	_chest_sprite.texture = TERRAIN_VISUAL_CATALOG_SCRIPT.TREASURE_CHEST
	_chest_sprite.position = Vector2(0.0, -CHEST_DISPLAY_SIZE.y * 0.5 + ART_OFFSET_Y)
	_chest_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var chest_texture_size := Vector2(
		_chest_sprite.texture.get_width(),
		_chest_sprite.texture.get_height()
	)
	var chest_scale: float = minf(
		CHEST_DISPLAY_SIZE.x / chest_texture_size.x,
		CHEST_DISPLAY_SIZE.y / chest_texture_size.y
	)
	_chest_sprite.scale = Vector2.ONE * chest_scale
	_chest_base_position = _chest_sprite.position
	_chest_base_scale = _chest_sprite.scale
	add_child(_chest_sprite)
	_chest_hover_sprite = Sprite2D.new()
	_chest_hover_sprite.name = "TreasureChestHoverGlow"
	_chest_hover_sprite.centered = true
	_chest_hover_sprite.texture = TERRAIN_VISUAL_CATALOG_SCRIPT.TREASURE_CHEST
	_chest_hover_sprite.scale = Vector2.ONE * 1.16
	_chest_hover_sprite.z_index = 1
	_chest_hover_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var chest_glow_material := ShaderMaterial.new()
	chest_glow_material.shader = OBSTACLE_HOVER_SHADER
	chest_glow_material.set_shader_parameter("outline_color", Color("#ffd56b"))
	_chest_hover_sprite.material = chest_glow_material
	_chest_sprite.add_child(_chest_hover_sprite)
	_obstacle_hover_sprite = Sprite2D.new()
	_obstacle_hover_sprite.name = "ObstacleAlphaHoverGlow"
	_obstacle_hover_sprite.centered = true
	_obstacle_hover_sprite.z_index = 1
	_obstacle_hover_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var glow_material := ShaderMaterial.new()
	glow_material.shader = OBSTACLE_HOVER_SHADER
	_obstacle_hover_sprite.material = glow_material
	add_child(_obstacle_hover_sprite)
	_sync_chest_sprite()
	_sync_chest_hover_sprite()
	_sync_obstacle_hover_sprite()

func configure(obstacle_type: int, chest_available: bool) -> void:
	var chest_appeared: bool = chest_available and not _chest_available
	_obstacle_type = obstacle_type
	_chest_available = chest_available
	_sync_chest_sprite()
	_sync_chest_hover_sprite()
	_sync_obstacle_hover_sprite()
	if chest_appeared:
		_play_chest_appearance()
	elif not chest_available and _chest_appearance_tween != null and _chest_appearance_tween.is_running():
		_chest_appearance_tween.kill()
		scale = Vector2.ONE
	if not chest_available:
		set_chest_hovered(false)
	queue_redraw()

func set_obstacle_hovered(is_hovered: bool) -> void:
	if _obstacle_hovered == is_hovered:
		return
	_obstacle_hovered = is_hovered
	_sync_obstacle_hover_sprite()

func set_chest_hovered(is_hovered: bool) -> void:
	var should_hover: bool = is_hovered and _chest_available
	if _chest_hovered == should_hover:
		return
	_chest_hovered = should_hover
	_sync_chest_hover_sprite()
	if _chest_hover_tween != null and _chest_hover_tween.is_running():
		_chest_hover_tween.kill()
	_chest_sprite.position = _chest_base_position
	_chest_sprite.scale = _chest_base_scale
	_chest_sprite.modulate = Color.WHITE
	if not _chest_hovered:
		return
	_chest_sprite.modulate = Color("#fff0bd")
	_chest_hover_tween = create_tween().set_loops()
	_chest_hover_tween.tween_property(
		_chest_sprite,
		"position:y",
		_chest_base_position.y - 6.0,
		0.18
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_chest_hover_tween.parallel().tween_property(
		_chest_sprite,
		"scale",
		_chest_base_scale * 1.06,
		0.18
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_chest_hover_tween.tween_property(
		_chest_sprite,
		"position:y",
		_chest_base_position.y,
		0.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_chest_hover_tween.parallel().tween_property(
		_chest_sprite,
		"scale",
		_chest_base_scale,
		0.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _sync_obstacle_hover_sprite() -> void:
	if _obstacle_hover_sprite == null:
		return
	var has_obstacle: bool = _obstacle_type >= 0 and _obstacle_type < TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_COUNT
	_obstacle_hover_sprite.visible = _obstacle_hovered and has_obstacle
	if not has_obstacle:
		_obstacle_hover_sprite.texture = null
		return
	var texture: Texture2D = TERRAIN_VISUAL_CATALOG_SCRIPT.get_obstacle_texture(_obstacle_type)
	_obstacle_hover_sprite.texture = texture
	_obstacle_hover_sprite.position = Vector2(0.0, ART_OFFSET_Y)
	_obstacle_hover_sprite.scale = TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_DISPLAY_SIZE / Vector2(texture.get_width(), texture.get_height())

func _sync_chest_hover_sprite() -> void:
	if _chest_hover_sprite == null:
		return
	_chest_hover_sprite.visible = _chest_available and _chest_hovered

func _play_chest_appearance() -> void:
	if _chest_appearance_tween != null and _chest_appearance_tween.is_running():
		_chest_appearance_tween.kill()
	scale = Vector2(0.32, 0.32)
	_chest_appearance_tween = create_tween()
	_chest_appearance_tween.tween_property(self, "scale", Vector2(1.18, 1.18), 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_chest_appearance_tween.tween_property(self, "scale", Vector2(0.94, 0.94), 0.11).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_chest_appearance_tween.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	var visual_size: Vector2 = _get_visual_size()
	if visual_size == Vector2.ZERO:
		return
	if _obstacle_type >= 0 and _obstacle_type < TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_COUNT:
		draw_texture_rect(
			TERRAIN_VISUAL_CATALOG_SCRIPT.get_obstacle_texture(_obstacle_type),
			Rect2(-visual_size * 0.5 + OBSTACLE_CENTER_OFFSET + Vector2(0.0, ART_OFFSET_Y), visual_size),
			false
		)

func _sync_chest_sprite() -> void:
	if _chest_sprite == null:
		return
	_chest_sprite.visible = _chest_available

func _get_visual_size() -> Vector2:
	if _obstacle_type >= 0 and _obstacle_type < TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_COUNT:
		return TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_DISPLAY_SIZE
	if _chest_available:
		return CHEST_DISPLAY_SIZE
	return Vector2.ZERO
