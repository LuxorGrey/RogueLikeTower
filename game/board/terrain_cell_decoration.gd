class_name TerrainCellDecoration
extends Node2D

const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")
const OBSTACLE_HOVER_SHADER: Shader = preload("res://game/board/obstacle_hover_glow.gdshader")
const INTERACTABLE_OUTLINE_SHADER: Shader = preload("res://game/board/interactable_outline.gdshader")

const CHEST_DISPLAY_SIZE: Vector2 = Vector2(84.0, 84.0)
const ART_OFFSET_Y: float = 6.0
const OBSTACLE_CENTER_OFFSET: Vector2 = Vector2.ZERO

var _obstacle_type: int = HexCell.ObstacleType.NONE
var _chest_available: bool = false
var _decorative_prop_ids: Array[StringName] = []
var _chest_appearance_tween: Tween
var _chest_hover_tween: Tween
var _obstacle_hovered: bool = false
var _chest_hovered: bool = false
var _obstacle_sprite: Sprite2D
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
	_obstacle_sprite = Sprite2D.new()
	_obstacle_sprite.name = "ObstacleOutlinedSprite"
	_obstacle_sprite.centered = true
	_obstacle_sprite.position = OBSTACLE_CENTER_OFFSET
	_obstacle_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var obstacle_outline_material := ShaderMaterial.new()
	obstacle_outline_material.shader = INTERACTABLE_OUTLINE_SHADER
	obstacle_outline_material.set_shader_parameter("outline_color", Color.WHITE)
	obstacle_outline_material.set_shader_parameter("outline_size_px", 3.0)
	_obstacle_sprite.material = obstacle_outline_material
	add_child(_obstacle_sprite)
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
	glow_material.set_shader_parameter("outline_color", Color.WHITE)
	_obstacle_hover_sprite.material = glow_material
	add_child(_obstacle_hover_sprite)
	_sync_chest_sprite()
	_sync_chest_hover_sprite()
	_sync_obstacle_hover_sprite()

func configure(
	obstacle_type: int,
	chest_available: bool,
	decorative_prop_ids: Array[StringName] = []
) -> void:
	var chest_appeared: bool = chest_available and not _chest_available
	_obstacle_type = obstacle_type
	_chest_available = chest_available
	_decorative_prop_ids = decorative_prop_ids.duplicate()
	_sync_chest_sprite()
	_sync_chest_hover_sprite()
	_sync_obstacle_hover_sprite()
	if chest_appeared:
		_play_chest_appearance()
	elif not chest_available and _chest_appearance_tween != null and _chest_appearance_tween.is_running():
		_chest_appearance_tween.kill()
		_chest_sprite.position = _chest_base_position
		_chest_sprite.scale = _chest_base_scale
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
	if _obstacle_hover_sprite == null or _obstacle_sprite == null:
		return
	var has_obstacle: bool = _obstacle_type >= 0 and _obstacle_type < TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_COUNT
	_obstacle_sprite.visible = has_obstacle
	_obstacle_hover_sprite.visible = _obstacle_hovered and has_obstacle
	if not has_obstacle:
		_obstacle_sprite.texture = null
		_obstacle_hover_sprite.texture = null
		return
	var texture: Texture2D = TERRAIN_VISUAL_CATALOG_SCRIPT.get_obstacle_texture(_obstacle_type)
	_obstacle_sprite.texture = texture
	_obstacle_sprite.position = OBSTACLE_CENTER_OFFSET
	_obstacle_sprite.scale = TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_DISPLAY_SIZE / Vector2(texture.get_width(), texture.get_height())
	_obstacle_hover_sprite.texture = texture
	_obstacle_hover_sprite.position = OBSTACLE_CENTER_OFFSET
	_obstacle_hover_sprite.scale = TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_DISPLAY_SIZE / Vector2(texture.get_width(), texture.get_height())

func _sync_chest_hover_sprite() -> void:
	if _chest_hover_sprite == null:
		return
	_chest_hover_sprite.visible = _chest_available and _chest_hovered

func _play_chest_appearance() -> void:
	if _chest_appearance_tween != null and _chest_appearance_tween.is_running():
		_chest_appearance_tween.kill()
	_chest_sprite.position = _chest_base_position + Vector2(0.0, 14.0)
	_chest_sprite.scale = _chest_base_scale * 0.55
	_chest_appearance_tween = create_tween()
	_chest_appearance_tween.tween_property(
		_chest_sprite,
		"position",
		_chest_base_position + Vector2(0.0, -20.0),
		0.34
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_chest_appearance_tween.parallel().tween_property(
		_chest_sprite,
		"scale",
		_chest_base_scale * 1.16,
		0.34
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_chest_appearance_tween.tween_property(
		_chest_sprite,
		"position",
		_chest_base_position + Vector2(0.0, 2.0),
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_chest_appearance_tween.parallel().tween_property(
		_chest_sprite,
		"scale",
		_chest_base_scale * 0.94,
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_chest_appearance_tween.tween_property(
		_chest_sprite,
		"position",
		_chest_base_position,
		0.18
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_chest_appearance_tween.parallel().tween_property(
		_chest_sprite,
		"scale",
		_chest_base_scale,
		0.18
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	var prop_offsets: Array[Vector2] = _prop_offsets(_decorative_prop_ids.size())
	for prop_index in _decorative_prop_ids.size():
		var prop_texture: Texture2D = TERRAIN_VISUAL_CATALOG_SCRIPT.get_prop_texture(
			_decorative_prop_ids[prop_index]
		)
		if prop_texture == null:
			continue
		var prop_size: Vector2 = TERRAIN_VISUAL_CATALOG_SCRIPT.PROP_DISPLAY_SIZE
		var prop_center: Vector2 = prop_offsets[prop_index]
		draw_texture_rect(prop_texture, Rect2(prop_center - prop_size * 0.5, prop_size), false)

func _prop_offsets(prop_count: int) -> Array[Vector2]:
	var offsets: Array[Vector2] = []
	if prop_count >= 2:
		offsets.append(Vector2(-22.0, 5.0))
		offsets.append(Vector2(22.0, 5.0))
	elif prop_count == 1:
		offsets.append(Vector2(0.0, 5.0))
	return offsets

func _sync_chest_sprite() -> void:
	if _chest_sprite == null:
		return
	_chest_sprite.visible = _chest_available
