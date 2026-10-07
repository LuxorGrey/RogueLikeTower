extends Node2D

const STARTING_PIECE: TerrainPieceData = preload("res://data/terrain/starting_terrain_piece.tres")

var _rotation_steps: int = 0

@onready var _piece_preview: TerrainPiecePreview = %PiecePreview
@onready var _piece_status: Label = %PieceStatus
@onready var _rotation_status: Label = %RotationStatus
@onready var _hover_status: Label = %HoverStatus
@onready var _rotate_left: Button = %RotateLeft
@onready var _rotate_right: Button = %RotateRight

func _ready() -> void:
	_rotate_left.pressed.connect(_rotate_by.bind(-1))
	_rotate_right.pressed.connect(_rotate_by.bind(1))
	_piece_preview.hover_changed.connect(_on_preview_hover_changed)
	_piece_preview.hover_cleared.connect(_on_preview_hover_cleared)
	var validation_errors := STARTING_PIECE.validate()
	if not validation_errors.is_empty():
		_piece_status.text = "Plantilla inválida: %s" % "; ".join(validation_errors)
		push_error(_piece_status.text)
		return

	_piece_preview.set_piece(STARTING_PIECE)
	_update_status()

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return

	match key_event.keycode:
		KEY_Q:
			_rotate_by(-1)
		KEY_E:
			_rotate_by(1)

func _rotate_by(step_delta: int) -> void:
	_rotation_steps = posmod(_rotation_steps + step_delta, 6)
	_piece_preview.set_rotation_steps(_rotation_steps)
	_update_status()

func _update_status() -> void:
	var path_count: int = 0
	var grass_count: int = 0
	var mountain_count: int = 0
	for cell in STARTING_PIECE.cells:
		match cell.terrain_type:
			HexCell.TerrainType.PATH:
				path_count += 1
			HexCell.TerrainType.GRASS:
				grass_count += 1
			HexCell.TerrainType.MOUNTAIN:
				mountain_count += 1
	_piece_status.text = "%s · %d hexágonos\nCamino %d · Grass %d · Montaña %d" % [
		STARTING_PIECE.display_name,
		STARTING_PIECE.cells.size(),
		path_count,
		grass_count,
		mountain_count,
	]
	_rotation_status.text = "Orientación: %d° · posición %d/6" % [
		_rotation_steps * 60,
		_rotation_steps + 1,
	]

func _on_preview_hover_changed(local_coord: Vector2i, terrain_type: int, elevation: int) -> void:
	_hover_status.text = "Casilla local (q,r): (%d, %d) · %s · h%d" % [
		local_coord.x,
		local_coord.y,
		_terrain_display_name(terrain_type),
		elevation,
	]

func _on_preview_hover_cleared() -> void:
	_hover_status.text = "Casilla local (q,r): — · hover sobre cara superior"

func _terrain_display_name(terrain_type: int) -> String:
	match terrain_type:
		HexCell.TerrainType.PATH:
			return "CAMINO"
		HexCell.TerrainType.GRASS:
			return "GRASS"
		HexCell.TerrainType.MOUNTAIN:
			return "MONTAÑA"
		_:
			return "DESCONOCIDO"
