class_name IslandCompassIndicator
extends Control

const DIRECTION_GLYPHS: Array[String] = ["→", "↘", "↓", "↙", "←", "↖", "↑", "↗"]

var _targets: Array[Dictionary] = []
var _badge_style := StyleBoxFlat.new()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge_style.bg_color = Color("#102a33e8")
	_badge_style.border_color = Color("#70ded2")
	_badge_style.set_border_width_all(1)
	_badge_style.set_corner_radius_all(8)
	visible = false

func set_targets(targets: Array[Dictionary]) -> void:
	_targets = targets.duplicate()
	visible = not _targets.is_empty()
	queue_redraw()

func _draw() -> void:
	if _targets.is_empty():
		return
	draw_string(
		get_theme_font("font"),
		Vector2(0.0, 13.0),
		"BRÚJULA · ISLAS",
		HORIZONTAL_ALIGNMENT_CENTER,
		size.x,
		11,
		Color("#c8e6df")
	)
	var gap: float = 5.0
	var column_count: int = mini(3, _targets.size())
	var badge_width: float = minf(168.0, (size.x - gap * float(column_count - 1)) / float(column_count))
	var badge_height: float = 27.0
	var row_gap: float = 4.0
	for target_index in _targets.size():
		var target: Dictionary = _targets[target_index]
		var row_index: int = floori(float(target_index) / 3.0)
		var column_index: int = target_index % 3
		var row_target_count: int = mini(3, _targets.size() - row_index * 3)
		var row_width: float = float(row_target_count) * badge_width + gap * float(row_target_count - 1)
		var start_x: float = (size.x - row_width) * 0.5
		var badge_rect := Rect2(
			start_x + float(column_index) * (badge_width + gap),
			17.0 + float(row_index) * (badge_height + row_gap),
			badge_width,
			badge_height
		)
		draw_style_box(_badge_style, badge_rect)
		var world_position: Vector2 = target.get("world_position", Vector2.ZERO)
		var camera_position: Vector2 = target.get("camera_position", Vector2.ZERO)
		var direction: Vector2 = world_position - camera_position
		var octant: int = posmod(roundi(direction.angle() / (TAU / 8.0)), DIRECTION_GLYPHS.size())
		var distance_hexes: int = ceili(float(target.get("distance_hexes", 0.0)))
		var island_number: int = int(target.get("island_number", target_index + 1))
		var prefix: String = "COFRE" if bool(target.get("discovered", false)) else "ISLA"
		var marker_text: String = "%s %d %s %d hex" % [
			prefix,
			island_number,
			DIRECTION_GLYPHS[octant],
			distance_hexes,
		]
		draw_string(
			get_theme_font("font"),
			Vector2(badge_rect.position.x, badge_rect.position.y + size.y * 0.66),
			marker_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			badge_width,
			12,
			Color("#effffd")
		)
