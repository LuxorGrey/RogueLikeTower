extends Node2D

const ICON_SIZE: float = 22.0
const ICON_GAP: float = 3.0
const ITEMS_PER_ROW: int = 4

var _entries: Array[Dictionary] = []

func set_entries(entries: Array[Dictionary]) -> void:
	_entries = entries.duplicate()
	queue_redraw()

func _draw() -> void:
	if _entries.is_empty():
		return
	for index in _entries.size():
		var entry: Dictionary = _entries[index]
		var texture := entry.get("texture") as Texture2D
		if texture == null:
			continue
		var row_index: int = floori(float(index) / float(ITEMS_PER_ROW))
		var first_in_row: int = row_index * ITEMS_PER_ROW
		var row_item_count: int = mini(ITEMS_PER_ROW, _entries.size() - first_in_row)
		var column_index: int = index - first_in_row
		var row_width: float = float(row_item_count) * ICON_SIZE + float(row_item_count - 1) * ICON_GAP
		var rect_position := Vector2(
			-row_width * 0.5 + float(column_index) * (ICON_SIZE + ICON_GAP),
			float(row_index) * (ICON_SIZE + ICON_GAP)
		)
		var icon_rect := Rect2(rect_position, Vector2.ONE * ICON_SIZE)
		draw_rect(icon_rect.grow(1.0), Color("#15202a"), true)
		draw_texture_rect(texture, icon_rect, false)
		var enemy_count: int = maxi(int(entry.get("count", 0)), 0)
		if enemy_count > 1:
			var badge_center: Vector2 = icon_rect.position + Vector2(ICON_SIZE - 1.0, 1.0)
			draw_circle(badge_center, 7.0, Color("#15202a"))
			draw_circle(badge_center, 5.5, Color("#d9b35d"))
			var count_text: String = str(enemy_count)
			var font: Font = ThemeDB.fallback_font
			var text_width: float = font.get_string_size(count_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9).x
			draw_string(
				font,
				Vector2(badge_center.x - text_width * 0.5, badge_center.y + 3.0),
				count_text,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1.0,
				9,
				Color("#17212b")
			)
