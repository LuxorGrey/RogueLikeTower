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
var _obstacle_hovered: bool = false
var _obstacle_hover_sprite: Sprite2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_obstacle_hover_sprite = Sprite2D.new()
	_obstacle_hover_sprite.name = "ObstacleAlphaHoverGlow"
	_obstacle_hover_sprite.centered = true
	_obstacle_hover_sprite.z_index = 1
	_obstacle_hover_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var glow_material := ShaderMaterial.new()
	glow_material.shader = OBSTACLE_HOVER_SHADER
	_obstacle_hover_sprite.material = glow_material
	add_child(_obstacle_hover_sprite)
	_sync_obstacle_hover_sprite()

func configure(obstacle_type: int, chest_available: bool) -> void:
	var chest_appeared: bool = chest_available and not _chest_available
	_obstacle_type = obstacle_type
	_chest_available = chest_available
	_sync_obstacle_hover_sprite()
	if chest_appeared:
		_play_chest_appearance()
	elif not chest_available and _chest_appearance_tween != null and _chest_appearance_tween.is_running():
		_chest_appearance_tween.kill()
		scale = Vector2.ONE
	queue_redraw()

func set_obstacle_hovered(is_hovered: bool) -> void:
	if _obstacle_hovered == is_hovered:
		return
	_obstacle_hovered = is_hovered
	_sync_obstacle_hover_sprite()

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
	elif _chest_available:
		draw_texture_rect(
			TERRAIN_VISUAL_CATALOG_SCRIPT.TREASURE_CHEST,
			Rect2(Vector2(-CHEST_DISPLAY_SIZE.x * 0.5, -CHEST_DISPLAY_SIZE.y + ART_OFFSET_Y), CHEST_DISPLAY_SIZE),
			false
		)

func _get_visual_size() -> Vector2:
	if _obstacle_type >= 0 and _obstacle_type < TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_COUNT:
		return TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_DISPLAY_SIZE
	if _chest_available:
		return CHEST_DISPLAY_SIZE
	return Vector2.ZERO
