extends Control

const ROUND_COUNT: int = 45
const TRACK_INSET: float = 7.0
const CLEARED_COLOR: Color = Color("#7cae81")
const ACTIVE_COLOR: Color = Color("#f1cf78")
const FUTURE_COLOR: Color = Color("#74817f")
const SPECIAL_COLOR: Color = Color("#d98963")
const WAVE_HOVER_TOOLTIP_SCENE: PackedScene = preload("res://game/ui/components/wave_hover_tooltip.tscn")

var _current_round: int = 1
var _completed_rounds: int = 0
var _campaign_waves: Array[WaveData] = []
var _hovered_round: int = -1
var _tooltip_panel: WaveHoverTooltip

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(custom_minimum_size.x, 42.0)
	mouse_exited.connect(_on_track_mouse_exited)

func set_campaign_waves(waves: Array[WaveData]) -> void:
	_campaign_waves = waves.duplicate()
	queue_redraw()

func set_progress(current_round: int, completed_rounds: int) -> void:
	_current_round = clampi(current_round, 1, ROUND_COUNT)
	_completed_rounds = clampi(completed_rounds, 0, ROUND_COUNT)
	queue_redraw()

func _draw() -> void:
	var track_y: float = size.y * 0.5
	var track_width: float = maxf(size.x - TRACK_INSET * 2.0, 1.0)
	var spacing: float = track_width / float(ROUND_COUNT - 1)
	var track_start := Vector2(TRACK_INSET, track_y)
	var track_end := Vector2(size.x - TRACK_INSET, track_y)
	draw_line(track_start, track_end, Color("#344246"), 3.0, true)
	var completed_end_x: float = TRACK_INSET + spacing * float(maxi(_completed_rounds - 1, 0))
	if _completed_rounds > 1:
		draw_line(track_start, Vector2(completed_end_x, track_y), Color("#54775e"), 3.0, true)
	for wave_index in range(ROUND_COUNT):
		var round_number: int = wave_index + 1
		var point := Vector2(TRACK_INSET + spacing * float(wave_index), track_y)
		var wave: WaveData = _wave_for_round(round_number)
		var special: bool = _is_special_wave(wave)
		var color: Color = SPECIAL_COLOR if special else FUTURE_COLOR
		if round_number <= _completed_rounds:
			color = CLEARED_COLOR
		elif round_number == _current_round:
			color = ACTIVE_COLOR
		var radius: float = _difficulty_radius(wave, special)
		if special:
			draw_circle(point, radius + 2.0, Color("#65433b"))
		draw_circle(point, radius, color)
		if round_number == _current_round:
			draw_arc(point, radius + 2.4, 0.0, TAU, 32, Color("#fff3c9"), 1.4, true)

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
	var mouse_event := event as InputEventMouseMotion
	var track_width: float = maxf(size.x - TRACK_INSET * 2.0, 1.0)
	var spacing: float = track_width / float(ROUND_COUNT - 1)
	var wave_index: int = clampi(roundi((mouse_event.position.x - TRACK_INSET) / spacing), 0, ROUND_COUNT - 1)
	var point_x: float = TRACK_INSET + spacing * float(wave_index)
	if absf(mouse_event.position.x - point_x) > maxf(3.0, spacing * 0.48):
		_hide_wave_tooltip()
		return
	if _hovered_round != wave_index:
		_show_wave_tooltip(wave_index)

func _wave_for_round(round_number: int) -> WaveData:
	var index: int = round_number - 1
	if index < 0 or index >= _campaign_waves.size():
		return null
	return _campaign_waves[index]

func _is_special_wave(wave: WaveData) -> bool:
	if wave == null:
		return false
	if wave.encounter_type in [WaveData.EncounterType.MINIBOSS, WaveData.EncounterType.TIER_2_BOSS, WaveData.EncounterType.BOSS]:
		return true
	for group in wave.groups:
		if group != null and group.enemy_data != null and group.enemy_data.boss_tier > 0:
			return true
	return false

func _difficulty_radius(wave: WaveData, special: bool) -> float:
	var enemy_count: int = 0
	if wave != null:
		for group in wave.groups:
			if group != null:
				enemy_count += group.count
	var largest_wave_count: int = 1
	for campaign_wave in _campaign_waves:
		if campaign_wave == null:
			continue
		var count: int = 0
		for group in campaign_wave.groups:
			if group != null:
				count += group.count
		largest_wave_count = maxi(largest_wave_count, count)
	var difficulty: float = sqrt(float(enemy_count) / float(largest_wave_count))
	return 2.3 + difficulty * 3.0 + (1.4 if special else 0.0)

func _show_wave_tooltip(wave_index: int) -> void:
	_hide_wave_tooltip()
	_hovered_round = wave_index
	var wave: WaveData = _wave_for_round(wave_index + 1)
	if wave == null:
		return
	var total_enemies: int = 0
	var counts_by_enemy: Dictionary = {}
	var enemy_data_by_id: Dictionary = {}
	var enemy_order: Array[StringName] = []
	for group in wave.groups:
		if group == null or group.enemy_data == null:
			continue
		total_enemies += group.count
		var enemy_id: StringName = group.enemy_data.id
		if not counts_by_enemy.has(enemy_id):
			counts_by_enemy[enemy_id] = 0
			enemy_data_by_id[enemy_id] = group.enemy_data
			enemy_order.append(enemy_id)
		counts_by_enemy[enemy_id] = int(counts_by_enemy[enemy_id]) + group.count

	var panel := WAVE_HOVER_TOOLTIP_SCENE.instantiate() as WaveHoverTooltip
	panel.mouse_exited.connect(_hide_wave_tooltip)
	add_child(panel)
	_tooltip_panel = panel
	panel.set_summary(wave_index + 1, total_enemies)
	var repeated_type_count: int = 0
	for enemy_id in enemy_order:
		var enemy_count: int = int(counts_by_enemy[enemy_id])
		if enemy_count <= 1:
			continue
		repeated_type_count += 1
		var enemy_data: EnemyData = enemy_data_by_id[enemy_id] as EnemyData
		panel.add_enemy_row(enemy_data.display_name, enemy_count, enemy_data.sprite_texture)
	if repeated_type_count == 0:
		panel.show_empty_note()
	var tooltip_minimum_size: Vector2 = panel.get_combined_minimum_size()
	panel.size = Vector2(maxf(226.0, tooltip_minimum_size.x), tooltip_minimum_size.y)
	var track_width: float = maxf(size.x - TRACK_INSET * 2.0, 1.0)
	var point_x: float = TRACK_INSET + track_width * float(wave_index) / float(ROUND_COUNT - 1)
	panel.position = Vector2(
		clampf(point_x - panel.size.x * 0.5, 0.0, maxf(0.0, size.x - panel.size.x)),
		size.y + 5.0
	)

func _hide_wave_tooltip() -> void:
	_hovered_round = -1
	if is_instance_valid(_tooltip_panel):
		_tooltip_panel.queue_free()
	_tooltip_panel = null

func _on_track_mouse_exited() -> void:
	if is_instance_valid(_tooltip_panel) and _tooltip_panel.get_global_rect().has_point(get_global_mouse_position()):
		return
	_hide_wave_tooltip()
