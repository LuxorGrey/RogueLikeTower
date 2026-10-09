extends Control

@export_range(1, 100, 1) var health_per_segment: int = 10
@export_range(0.0, 8.0, 0.5) var segment_gap: float = 2.0

var current_health: int = 0
var maximum_health: int = 1
var fill_color: Color = Color("#76bd82")

func set_health(current: int, maximum: int, color: Color) -> void:
	current_health = maxi(current, 0)
	maximum_health = maxi(maximum, 1)
	fill_color = color
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	var segment_count: int = ceili(float(maximum_health) / float(maxi(health_per_segment, 1)))
	if segment_count <= 0 or size.x <= 0.0 or size.y <= 0.0:
		return
	var gap_total: float = segment_gap * float(maxi(segment_count - 1, 0))
	var segment_width: float = maxf((size.x - gap_total) / float(segment_count), 0.0)
	for segment_index in range(segment_count):
		var segment_health: int = mini(health_per_segment, maximum_health - segment_index * health_per_segment)
		if segment_health <= 0:
			continue
		var x: float = float(segment_index) * (segment_width + segment_gap)
		var rect := Rect2(x, 0.0, segment_width, size.y)
		draw_rect(rect, Color("#253238"), true)
		var health_before_segment: int = segment_index * health_per_segment
		var health_in_segment: float = clampf(float(current_health - health_before_segment), 0.0, float(segment_health))
		var fill_width: float = segment_width * health_in_segment / float(segment_health)
		if fill_width > 0.0:
			draw_rect(Rect2(x, 0.0, fill_width, size.y), fill_color, true)
		draw_rect(rect, Color("#11191d"), false, 1.0, true)
