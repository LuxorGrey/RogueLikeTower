extends Button

const SPEED_SCALES: Array[float] = [1.0, 2.0, 3.0]

var _speed_index: int = 0

func _ready() -> void:
	pressed.connect(_on_pressed)
	_update_speed_display()

func _on_pressed() -> void:
	_speed_index = (_speed_index + 1) % SPEED_SCALES.size()
	_update_speed_display()

func _update_speed_display() -> void:
	var current_speed: int = roundi(SPEED_SCALES[_speed_index])
	var next_index: int = (_speed_index + 1) % SPEED_SCALES.size()
	var next_speed: int = roundi(SPEED_SCALES[next_index])
	Engine.time_scale = SPEED_SCALES[_speed_index]
	text = "×%d" % current_speed
	tooltip_text = "Velocidad actual ×%d · Pulsa para ×%d" % [current_speed, next_speed]
