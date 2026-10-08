extends Control

const ROUND_COUNT: int = 20
const CLEARED_COLOR: Color = Color("#57966a")
const ACTIVE_COLOR: Color = Color("#e5be6a")
const FUTURE_COLOR: Color = Color("#34464c")
const BOSS_COLOR: Color = Color("#ad6251")

var _current_round: int = 1
var _completed_rounds: int = 0

func _ready() -> void:
	custom_minimum_size = Vector2(custom_minimum_size.x, 10.0)
	tooltip_text = "Progreso de campaña: ronda actual y 20 rondas de la demo."

func set_progress(current_round: int, completed_rounds: int) -> void:
	_current_round = clampi(current_round, 1, ROUND_COUNT)
	_completed_rounds = clampi(completed_rounds, 0, ROUND_COUNT)
	tooltip_text = "Campaña: %d/20 · %d rondas completadas" % [_current_round, _completed_rounds]
	queue_redraw()

func _draw() -> void:
	var gap: float = 3.0
	var segment_width: float = maxf((size.x - gap * float(ROUND_COUNT - 1)) / float(ROUND_COUNT), 1.0)
	var segment_height: float = maxf(size.y - 2.0, 4.0)
	for round_index in range(ROUND_COUNT):
		var round_number: int = round_index + 1
		var color: Color = FUTURE_COLOR
		if round_number <= _completed_rounds:
			color = CLEARED_COLOR
		elif round_number == _current_round:
			color = ACTIVE_COLOR
		elif round_number in [17, 19, 20]:
			color = BOSS_COLOR
		var segment_rect := Rect2(
			Vector2(float(round_index) * (segment_width + gap), 1.0),
			Vector2(segment_width, segment_height)
		)
		draw_rect(segment_rect, color, true)
