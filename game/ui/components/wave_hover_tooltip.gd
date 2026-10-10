class_name WaveHoverTooltip
extends PanelContainer

const ENEMY_ROW_SCENE: PackedScene = preload("res://game/ui/components/wave_enemy_row.tscn")

@onready var heading_label: Label = %HeadingLabel
@onready var enemy_rows: VBoxContainer = %EnemyRows
@onready var empty_note: Label = %EmptyNote

func set_summary(round_number: int, total_enemies: int) -> void:
	heading_label.text = "Oleada %02d · %d unidades" % [round_number, total_enemies]

func add_enemy_row(display_name: String, enemy_count: int, portrait: Texture2D) -> void:
	var row := ENEMY_ROW_SCENE.instantiate() as HBoxContainer
	var portrait_view := row.get_node("Portrait") as TextureRect
	var enemy_label := row.get_node("EnemyLabel") as Label
	portrait_view.texture = portrait
	enemy_label.text = "%s × %d" % [display_name, enemy_count]
	enemy_rows.add_child(row)

func show_empty_note() -> void:
	empty_note.visible = true
