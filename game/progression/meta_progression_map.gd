class_name MetaProgressionMap
extends Control

signal node_selected(node_kind: StringName, node_id: StringName, local_position: Vector2)

const NODE_SCENE: PackedScene = preload("res://game/progression/meta_upgrade_node.tscn")
const ICON_CATALOG: Resource = preload("res://game/ui/resources/icon_catalog.tres")
const NODE_WIDTH: float = 236.0
const NODE_HEIGHT: float = 254.0
const NODE_GAP: float = 56.0
const TOWER_CLUSTER_START_X: float = 800.0
const TOWER_CLUSTER_STEP_X: float = 880.0
const TOWER_FIRST_ROW_Y: float = 110.0
const TOWER_ROW_STEP_Y: float = 660.0
const BRANCH_ROW_STEP: float = 280.0
const FIRST_NODE_Y: float = 110.0
const MAP_WIDTH: float = 3560.0
const MAP_HEIGHT: float = 2020.0
const GENERAL_BRANCHES: Array[Array] = [
	[&"starting_coffers", &"gold_drop", &"meta:chest_finder", &"card_archive"],
	[&"mana_reservoir", &"mana_wellspring", &"tower_calibration", &"main_tower_repair", &"main_tower_fortification"],
]

var _tower_profiles: Array[TowerData] = []
var _permanent_upgrades: Array[PermanentUpgradeData] = []
var _tower_nodes: Dictionary[StringName, MetaUpgradeNode] = {}
var _upgrade_nodes: Dictionary[StringName, MetaUpgradeNode] = {}
var _upgrade_by_id: Dictionary[StringName, PermanentUpgradeData] = {}
var _tower_by_unlock_id: Dictionary[StringName, TowerData] = {}
var _edges: Array[Dictionary] = []
var _center_label: Label
var _particle_rng := RandomNumberGenerator.new()

func _ready() -> void:
	custom_minimum_size = Vector2(MAP_WIDTH, MAP_HEIGHT)
	size = custom_minimum_size
	_particle_rng.randomize()
	_build_nodes()

func configure(tower_profiles: Array[TowerData], permanent_upgrades: Array[PermanentUpgradeData]) -> void:
	_tower_profiles = tower_profiles.duplicate()
	_permanent_upgrades = permanent_upgrades.duplicate()
	_tower_by_unlock_id.clear()
	_upgrade_by_id.clear()
	for tower_data in _tower_profiles:
		if tower_data != null:
			_tower_by_unlock_id[tower_data.unlock_id] = tower_data
	for upgrade in _permanent_upgrades:
		if upgrade != null:
			_upgrade_by_id[upgrade.id] = upgrade
	if is_inside_tree():
		_build_nodes()

func refresh() -> void:
	for tower_data in _tower_profiles:
		if tower_data == null:
			continue
		var node := _tower_nodes.get(tower_data.unlock_id) as MetaUpgradeNode
		if node != null:
			_configure_tower_node(node, tower_data)
	for upgrade in _permanent_upgrades:
		if upgrade == null:
			continue
		var node := _upgrade_nodes.get(upgrade.id) as MetaUpgradeNode
		if node != null:
			_configure_upgrade_node(node, upgrade)
	queue_redraw()

func play_unlock_burst(local_position: Vector2) -> void:
	var colors: Array[Color] = [Color("#8de7aa"), Color("#f1cf78"), Color("#e9e4d5"), Color("#78c9d8")]
	for particle_index in range(52):
		var particle := ColorRect.new()
		particle.color = colors[particle_index % colors.size()]
		particle.size = Vector2(_particle_rng.randf_range(2.0, 6.0), _particle_rng.randf_range(2.0, 6.0))
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		particle.position = local_position - particle.size * 0.5
		particle.z_index = 8
		add_child(particle)
		var angle: float = _particle_rng.randf_range(0.0, TAU)
		var distance: float = _particle_rng.randf_range(48.0, 150.0)
		var duration: float = _particle_rng.randf_range(0.42, 0.86)
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", particle.position + Vector2(cos(angle), sin(angle)) * distance, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, duration)
		tween.tween_property(particle, "size", Vector2.ZERO, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback(particle.queue_free)

func _build_nodes() -> void:
	_tower_nodes.clear()
	_upgrade_nodes.clear()
	_edges.clear()
	if _center_label != null and is_instance_valid(_center_label):
		_center_label.queue_free()
	_center_label = Label.new()
	_center_label.text = "CENTRO DE MANDO"
	_center_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_center_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_center_label.add_theme_font_size_override("font_size", 21)
	_center_label.add_theme_color_override("font_color", Color("#f1cf78"))
	_center_label.position = Vector2((MAP_WIDTH - 260.0) * 0.5, 26.0)
	_center_label.size = Vector2(260.0, 48.0)
	_center_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_center_label)
	for child in get_children():
		if child is MetaUpgradeNode or child is Line2D:
			child.queue_free()
	for index in _tower_profiles.size():
		var tower_data: TowerData = _tower_profiles[index]
		if tower_data == null:
			continue
		var grid_position: Vector2i = _tower_grid_position(index)
		var cluster_x: float = TOWER_CLUSTER_START_X + float(grid_position.x) * TOWER_CLUSTER_STEP_X
		var tower_y: float = TOWER_FIRST_ROW_Y + float(grid_position.y) * TOWER_ROW_STEP_Y
		var node := _create_node(&"tower", tower_data.unlock_id)
		node.position = Vector2(cluster_x + NODE_WIDTH + NODE_GAP, tower_y)
		_tower_nodes[tower_data.unlock_id] = node
		_configure_tower_node(node, tower_data)
		_edges.append({"from": _center_label, "to": node})

	var used_global_ids: Dictionary[StringName, bool] = {}
	for branch_index in GENERAL_BRANCHES.size():
		var branch: Array = GENERAL_BRANCHES[branch_index]
		var previous_node: Control = _center_label
		var x_position: float = 36.0 + float(branch_index) * (NODE_WIDTH + 42.0)
		for row_index in branch.size():
			var upgrade_id: StringName = branch[row_index]
			var upgrade := _upgrade_by_id.get(upgrade_id) as PermanentUpgradeData
			if upgrade == null:
				continue
			var node := _create_node(&"upgrade", upgrade_id)
			node.position = Vector2(x_position, FIRST_NODE_Y + float(row_index) * BRANCH_ROW_STEP)
			_upgrade_nodes[upgrade_id] = node
			_configure_upgrade_node(node, upgrade)
			_edges.append({"from": previous_node, "to": node})
			previous_node = node
			used_global_ids[upgrade_id] = true

	for tower_data in _tower_profiles:
		if tower_data == null:
			continue
		var tower_node: MetaUpgradeNode = _tower_nodes[tower_data.unlock_id]
		var branch_upgrades: Array[PermanentUpgradeData] = _get_tower_upgrades(tower_data)
		var tower_index: int = _tower_profiles.find(tower_data)
		var grid_position: Vector2i = _tower_grid_position(tower_index)
		var cluster_x: float = TOWER_CLUSTER_START_X + float(grid_position.x) * TOWER_CLUSTER_STEP_X
		var upgrade_y: float = tower_node.position.y + NODE_HEIGHT + 48.0
		for row_index in branch_upgrades.size():
			var upgrade: PermanentUpgradeData = branch_upgrades[row_index]
			var node := _create_node(&"upgrade", upgrade.id)
			var layer_column: int = _layer_order(upgrade.id)
			node.position = Vector2(
				cluster_x + float(layer_column) * (NODE_WIDTH + NODE_GAP),
				upgrade_y
			)
			_upgrade_nodes[upgrade.id] = node
			_configure_upgrade_node(node, upgrade)
			# Las tres capas salen en paralelo y quedan distribuidas en abanico horizontal.
			_edges.append({"from": tower_node, "to": node})

	var overflow_index: int = 0
	for upgrade in _permanent_upgrades:
		if upgrade == null or _upgrade_nodes.has(upgrade.id) or upgrade.id == &"card_draw":
			continue
		var x_position: float = 36.0 + float(overflow_index % 2) * (NODE_WIDTH + 42.0)
		var row_index: int = floori(float(overflow_index) / 2.0)
		var node := _create_node(&"upgrade", upgrade.id)
		node.position = Vector2(x_position, FIRST_NODE_Y + float(row_index) * BRANCH_ROW_STEP)
		_upgrade_nodes[upgrade.id] = node
		_configure_upgrade_node(node, upgrade)
		overflow_index += 1
	queue_redraw()

func _create_node(node_kind: StringName, node_id: StringName) -> MetaUpgradeNode:
	var node := NODE_SCENE.instantiate() as MetaUpgradeNode
	node.name = "%s_%s" % [node_kind, String(node_id).replace(":", "_")]
	add_child(node)
	node.size = Vector2(NODE_WIDTH, NODE_HEIGHT)
	node.pressed.connect(_emit_node_selected.bind(node_kind, node_id, node))
	return node

func _tower_grid_position(tower_index: int) -> Vector2i:
	# Tres clusters por fila; las dos últimas filas se centran para dejar espacio uniforme.
	if tower_index < 3:
		return Vector2i(tower_index, 0)
	if tower_index < 5:
		return Vector2i((tower_index - 3) * 2, 1)
	return Vector2i((tower_index - 5) * 2, 2)

func _emit_node_selected(node_kind: StringName, node_id: StringName, node: Control) -> void:
	node_selected.emit(node_kind, node_id, node.position + node.size * 0.5)

func _configure_tower_node(node: MetaUpgradeNode, tower_data: TowerData) -> void:
	var unlocked: bool = bool(MetaProgression.call("is_tower_unlocked", tower_data))
	var can_purchase: bool = bool(MetaProgression.call("can_purchase_tower", tower_data.unlock_id))
	var status_text: String = "DESBLOQUEADA" if unlocked else "%d" % tower_data.meta_unlock_cost
	var tooltip: String = "%s\n%s\n" % [tower_data.display_name, tower_data.role_summary]
	if unlocked:
		tooltip += "Disponible para aparecer como card de reclutamiento en futuras runs."
	else:
		tooltip += "Desbloquea esta torre para que pueda aparecer en las cards de run."
	var tower_icon: Texture2D = ICON_CATALOG.call("get_tower_icon", tower_data.id) as Texture2D
	if tower_icon == null:
		tower_icon = ICON_CATALOG.call("get_icon", &"damage") as Texture2D
	var currency_icon: Texture2D = null
	if not unlocked:
		currency_icon = ICON_CATALOG.call("get_icon", &"profile_currency") as Texture2D
	node.configure_node(
		tower_data.display_name,
		tower_data.role_summary,
		status_text,
		tower_icon,
		not can_purchase and not unlocked,
		unlocked,
		tooltip,
		currency_icon
	)

func _configure_upgrade_node(node: MetaUpgradeNode, upgrade: PermanentUpgradeData) -> void:
	var level: int = int(MetaProgression.call("get_upgrade_level", upgrade.id))
	var cost: int = upgrade.get_cost_for_next_level(level)
	var can_buy: bool = bool(MetaProgression.call("can_purchase_upgrade", upgrade.id))
	var has_requirements: bool = _has_upgrade_requirements(upgrade)
	var locked: bool = cost >= 0 and not has_requirements
	var maxed: bool = cost < 0
	var current_xp: int = int(MetaProgression.call("get_meta_currency"))
	var status_text: String
	if maxed:
		status_text = "MÁXIMO · %d/%d" % [level, upgrade.max_level]
	elif locked:
		status_text = "BLOQUEADA"
	elif not can_buy:
		status_text = "FALTAN %d" % maxi(cost - current_xp, 0)
	else:
		status_text = "MEJORAR · %d" % cost
	var title: String = _upgrade_title(upgrade)
	var details: String = _upgrade_summary(upgrade)
	if upgrade.max_level > 1:
		details += " · %d/%d" % [level, upgrade.max_level]
	var tower_data: TowerData = _get_tower_for_upgrade(upgrade)
	var tooltip_title: String = (
		"%s · %s" % [tower_data.display_name, upgrade.display_name]
		if tower_data != null
		else upgrade.display_name
	)
	var tooltip: String = "%s\n%s\n" % [tooltip_title, upgrade.description]
	var requirement_text: String = _upgrade_requirement_text(upgrade)
	if not requirement_text.is_empty():
		tooltip += "\nPara desbloquear: %s" % requirement_text
	if cost >= 0:
		tooltip += "\nNivel %d/%d." % [level, upgrade.max_level]
	var upgrade_icon: Texture2D = ICON_CATALOG.call("get_permanent_upgrade_icon", upgrade) as Texture2D
	if upgrade_icon == null:
		upgrade_icon = ICON_CATALOG.call("get_icon", &"damage") as Texture2D
	var currency_icon: Texture2D = null
	if not locked and not maxed:
		currency_icon = ICON_CATALOG.call("get_icon", &"profile_currency") as Texture2D
	node.configure_node(
		title,
		details,
		status_text,
		upgrade_icon,
		locked or not can_buy or maxed,
		level > 0,
		tooltip,
		currency_icon
	)

func _has_upgrade_requirements(upgrade: PermanentUpgradeData) -> bool:
	for prerequisite in upgrade.prerequisites:
		if int(MetaProgression.call("get_upgrade_level", prerequisite)) <= 0:
			return false
	var unlocked_ids: Array[StringName] = []
	unlocked_ids.assign(MetaProgression.call("get_unlocked_content_ids"))
	for unlock_id in upgrade.prerequisite_unlock_ids:
		if not unlocked_ids.has(unlock_id):
			return false
	return true

func _upgrade_requirement_text(upgrade: PermanentUpgradeData) -> String:
	var requirements: Array[String] = []
	for prerequisite in upgrade.prerequisites:
		if int(MetaProgression.call("get_upgrade_level", prerequisite)) > 0:
			continue
		var prerequisite_upgrade := _upgrade_by_id.get(prerequisite) as PermanentUpgradeData
		requirements.append("comprar %s" % prerequisite_upgrade.display_name if prerequisite_upgrade != null else "comprar %s" % prerequisite)
	for unlock_id in upgrade.prerequisite_unlock_ids:
		if bool(MetaProgression.call("is_content_unlocked", unlock_id)):
			continue
		var tower_data := _tower_by_unlock_id.get(unlock_id) as TowerData
		requirements.append("desbloquear %s" % tower_data.display_name if tower_data != null else "desbloquear %s" % unlock_id)
	return ", ".join(requirements)

func _upgrade_title(upgrade: PermanentUpgradeData) -> String:
	var tower_data: TowerData = _get_tower_for_upgrade(upgrade)
	if tower_data != null:
		var layer_order: int = _layer_order(upgrade.id)
		var layer_name: String = upgrade.display_name
		match layer_order:
			0:
				layer_name = "Health"
			1:
				layer_name = "Armor"
			2:
				layer_name = "Shield"
		return "%s\n%s" % [tower_data.display_name, layer_name]
	return upgrade.display_name

func _upgrade_summary(upgrade: PermanentUpgradeData) -> String:
	var upgrade_id: String = String(upgrade.id)
	if upgrade_id.ends_with("_health"):
		return "+1 al multiplicador de daño contra Health en cada run."
	if upgrade_id.ends_with("_armor"):
		return "+1 al multiplicador de daño contra Armor en cada run."
	if upgrade_id.ends_with("_shield"):
		return "+1 al multiplicador de daño contra Shield en cada run."
	match upgrade_id:
		"starting_coffers":
			return "+100 Gold inicial por nivel en cada run."
		"gold_drop":
			return "+1 Gold por baja y nivel."
		"meta:chest_finder":
			return "Aumenta la probabilidad de encontrar cofres."
		"card_archive":
			return "Añade dos cartas globales a futuras ofertas."
		"mana_reservoir":
			return "Aumenta la reserva máxima de Mana."
		"mana_wellspring":
			return "Aumenta la regeneración de Mana."
		"tower_calibration":
			return "Aumenta el daño base de todas las torres."
		"main_tower_repair":
			return "Puede reparar 1 HP al terminar una ronda."
		"main_tower_fortification":
			return "+1 HP máximo permanente por nivel."
	return upgrade.description

func _get_tower_for_upgrade(upgrade: PermanentUpgradeData) -> TowerData:
	for unlock_id in upgrade.prerequisite_unlock_ids:
		var tower_data := _tower_by_unlock_id.get(unlock_id) as TowerData
		if tower_data != null:
			return tower_data
	return null

func _get_tower_upgrades(tower_data: TowerData) -> Array[PermanentUpgradeData]:
	var branch: Array[PermanentUpgradeData] = []
	for upgrade in _permanent_upgrades:
		if upgrade != null and upgrade.prerequisite_unlock_ids.has(tower_data.unlock_id):
			branch.append(upgrade)
	branch.sort_custom(func(a: PermanentUpgradeData, b: PermanentUpgradeData) -> bool:
		return _layer_order(a.id) < _layer_order(b.id)
	)
	return branch

func _layer_order(upgrade_id: StringName) -> int:
	var value: String = String(upgrade_id)
	if value.ends_with("_health"):
		return 0
	if value.ends_with("_armor"):
		return 1
	if value.ends_with("_shield"):
		return 2
	return 3

func _draw() -> void:
	for edge in _edges:
		var from_node := edge.get("from") as Control
		var to_node := edge.get("to") as Control
		if from_node == null or to_node == null:
			continue
		var from_point := from_node.position + Vector2(from_node.size.x * 0.5, from_node.size.y)
		var to_point := to_node.position + Vector2(to_node.size.x * 0.5, 0.0)
		var midpoint_y: float = (from_point.y + to_point.y) * 0.5
		var curve := PackedVector2Array([
			from_point,
			Vector2(from_point.x, midpoint_y),
			Vector2(to_point.x, midpoint_y),
			to_point,
		])
		draw_polyline(curve, Color("#4e665b"), 3.0, true)
		draw_circle(from_point, 4.0, Color("#86b08e"))
		draw_circle(to_point, 4.0, Color("#86b08e"))
