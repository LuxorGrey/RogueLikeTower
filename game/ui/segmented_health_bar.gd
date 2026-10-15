extends Control

@export_range(1, 100, 1) var health_per_segment: int = 10
@export_range(0.0, 8.0, 0.5) var segment_gap: float = 2.0
@export var segment_background_color: Color = Color("#253238")
@export var segment_border_color: Color = Color("#11191d")
@export_range(0.0, 4.0, 0.25) var segment_border_width: float = 1.0
@export_range(0.05, 1.0, 0.05) var segment_loss_animation_seconds: float = 0.28

var current_health: int = 0
var maximum_health: int = 1
var fill_color: Color = Color("#76bd82")
var _loss_animations: Array[Dictionary] = []

func _ready() -> void:
	set_process(false)

func set_health(current: int, maximum: int, color: Color) -> void:
	var next_health: int = maxi(current, 0)
	if next_health < current_health:
		var segment_size: int = maxi(health_per_segment, 1)
		var first_lost_segment: int = floori(float(next_health) / float(segment_size))
		var last_lost_segment: int = floori(float(current_health - 1) / float(segment_size))
		for segment_index in range(first_lost_segment, last_lost_segment + 1):
			var health_before_segment: int = segment_index * segment_size
			var segment_health: int = mini(segment_size, maximum_health - health_before_segment)
			var old_fill: float = clampf(
				float(current_health - health_before_segment),
				0.0,
				float(maxi(segment_health, 0))
			)
			if old_fill > 0.0:
				_loss_animations.append({
					"segment_index": segment_index,
					"elapsed": 0.0,
					"fill_fraction": old_fill / float(maxi(segment_health, 1)),
				})
		if not _loss_animations.is_empty():
			set_process(true)
	elif next_health > current_health and not _loss_animations.is_empty():
		_loss_animations.clear()
		set_process(false)
	current_health = next_health
	maximum_health = maxi(maximum, 1)
	fill_color = color
	queue_redraw()

func _process(delta: float) -> void:
	for animation_index in range(_loss_animations.size() - 1, -1, -1):
		var animation: Dictionary = _loss_animations[animation_index]
		animation["elapsed"] = float(animation["elapsed"]) + delta
		if float(animation["elapsed"]) >= segment_loss_animation_seconds:
			_loss_animations.remove_at(animation_index)
		else:
			_loss_animations[animation_index] = animation
	queue_redraw()
	if _loss_animations.is_empty():
		set_process(false)

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
		draw_rect(rect, segment_background_color, true)
		var health_before_segment: int = segment_index * health_per_segment
		var health_in_segment: float = clampf(float(current_health - health_before_segment), 0.0, float(segment_health))
		var fill_width: float = segment_width * health_in_segment / float(segment_health)
		if fill_width > 0.0:
			draw_rect(Rect2(x, 0.0, fill_width, size.y), fill_color, true)
		draw_rect(rect, segment_border_color, false, segment_border_width, true)
	for animation in _loss_animations:
		var segment_index: int = int(animation["segment_index"])
		if segment_index < 0 or segment_index >= segment_count:
			continue
		var progress: float = clampf(
			float(animation["elapsed"]) / maxf(segment_loss_animation_seconds, 0.01),
			0.0,
			1.0
		)
		var ghost_x: float = float(segment_index) * (segment_width + segment_gap)
		var ghost_width: float = segment_width * (1.0 - progress * 0.82)
		var ghost_height: float = size.y * (1.0 - progress * 0.62)
		var ghost_rect := Rect2(
			ghost_x + (segment_width - ghost_width) * 0.5,
			(size.y - ghost_height) * 0.5,
			ghost_width * float(animation["fill_fraction"]),
			ghost_height
		)
		var ghost_color: Color = Color("#fff0bd").lerp(fill_color, progress)
		ghost_color.a = 1.0 - progress
		draw_rect(ghost_rect, ghost_color, true)
		draw_rect(
			Rect2(ghost_x, 0.0, segment_width, size.y),
			segment_border_color,
			false,
			segment_border_width,
			true
		)
