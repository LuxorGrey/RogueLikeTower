class_name MetaProgressionMap
extends Control

signal node_selected(node_kind: StringName, node_id: StringName, local_position: Vector2)

const NODE_SCENE: PackedScene = preload("res://game/progression/meta_upgrade_node.tscn")
const ICON_CATALOG: Resource = preload("res://game/ui/resources/icon_catalog.tres")
const GENERAL_BRANCHES: Array[Array] = [
	[&"starting_coffers", &"gold_drop", &"meta:chest_finder", &"card_archive"],
	[&"mana_reservoir", &"mana_wellspring", &"tower_calibration", &"main_tower_repair", &"main_tower_fortification"],
]

@export_group("Map node layout")
@export_range(120.0, 480.0, 1.0) var node_width: float = 236.0
@export_range(160.0, 520.0, 1.0) var node_height: float = 282.0
@export_range(0.0, 240.0, 1.0) var node_gap: float = 56.0
@export_range(0.0, 2400.0, 1.0) var tower_cluster_start_x: float = 800.0
@export_range(120.0, 2400.0, 1.0) var tower_cluster_step_x: float = 880.0
@export_range(0.0, 1200.0, 1.0) var tower_first_row_y: float = 110.0
@export_range(160.0, 1600.0, 1.0) var tower_row_step_y: float = 660.0
@export_range(120.0, 1000.0, 1.0) var branch_row_step: float = 280.0
@export_range(0.0, 1200.0, 1.0) var first_node_y: float = 110.0
@export_range(0.0, 1200.0, 1.0) var branch_start_x: float = 36.0
@export_range(0.0, 600.0, 1.0) var branch_column_gap: float = 42.0
@export_range(0.0, 600.0, 1.0) var tower_upgrade_row_offset: float = 48.0

@export_group("Map links")
@export var link_color: Color = Color("#4e665b")
@export var link_endpoint_color: Color = Color("#86b08e")
@export_range(0.5, 12.0, 0.5) var link_width: float = 3.0
@export_range(1.0, 16.0, 0.5) var link_endpoint_radius: float = 4.0

@export_group("Unlock burst feedback")
@export var unlock_burst_colors: Array[Color] = [
	Color("#8de7aa"), Color("#f1cf78"), Color("#e9e4d5"), Color("#78c9d8"),
]
@export_range(1, 160, 1) var unlock_burst_particle_count: int = 52
@export var unlock_burst_particle_size_range: Vector2 = Vector2(2.0, 6.0)
@export var unlock_burst_distance_range: Vector2 = Vector2(48.0, 150.0)
@export var unlock_burst_duration_range: Vector2 = Vector2(0.42, 0.86)

var _tower_profiles: Array[TowerData] = []
var _permanent_upgrades: Array[PermanentUpgradeData] = []
var _tower_nodes: Dictionary[StringName, MetaUpgradeNode] = {}
var _upgrade_nodes: Dictionary[StringName, MetaUpgradeNode] = {}
var _upgrade_by_id: Dictionary[StringName, PermanentUpgradeData] = {}
var _tower_by_unlock_id: Dictionary[StringName, TowerData] = {}
var _edges: Array[Dictionary] = []
var _particle_rng := RandomNumberGenerator.new()
@onready var _center_label: Label = %CenterLabel

func _ready() -> void:
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
	if unlock_burst_colors.is_empty():
		return
	var minimum_particle_size: float = minf(unlock_burst_particle_size_range.x, unlock_burst_particle_size_range.y)
	var maximum_particle_size: float = maxf(unlock_burst_particle_size_range.x, unlock_burst_particle_size_range.y)
	var minimum_distance: float = minf(unlock_burst_distance_range.x, unlock_burst_distance_range.y)
	var maximum_distance: float = maxf(unlock_burst_distance_range.x, unlock_burst_distance_range.y)
	var minimum_duration: float = minf(unlock_burst_duration_range.x, unlock_burst_duration_range.y)
	var maximum_duration: float = maxf(unlock_burst_duration_range.x, unlock_burst_duration_range.y)
	for particle_index in range(unlock_burst_particle_count):
		var particle := ColorRect.new()
		particle.color = unlock_burst_colors[particle_index % unlock_burst_colors.size()]
		particle.size = Vector2(
			_particle_rng.randf_range(minimum_particle_size, maximum_particle_size),
			_particle_rng.randf_range(minimum_particle_size, maximum_particle_size)
		)
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		particle.position = local_position - particle.size * 0.5
		particle.z_index = 8
		add_child(particle)
		var angle: float = _particle_rng.randf_range(0.0, TAU)
		var distance: float = _particle_rng.randf_range(minimum_distance, maximum_distance)
		var duration: float = _particle_rng.randf_range(minimum_duration, maximum_duration)
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
	for child in get_children():
		if child is MetaUpgradeNode or child is Line2D:
			child.queue_free()
	for index in _tower_profiles.size():
		var tower_data: TowerData = _tower_profiles[index]
		if tower_data == null:
			continue
		var grid_position: Vector2i = _tower_grid_position(index)
		var cluster_x: float = tower_cluster_start_x + float(grid_position.x) * tower_cluster_step_x
		var tower_y: float = tower_first_row_y + float(grid_position.y) * tower_row_step_y
		var node := _create_node(&"tower", tower_data.unlock_id)
		node.position = Vector2(cluster_x + node_width + node_gap, tower_y)
		_tower_nodes[tower_data.unlock_id] = node
		_configure_tower_node(node, tower_data)
		_edges.append({"from": _center_label, "to": node})

	var used_global_ids: Dictionary[StringName, bool] = {}
	for branch_index in GENERAL_BRANCHES.size():
		var branch: Array = GENERAL_BRANCHES[branch_index]
		var previous_node: Control = _center_label
		var x_position: float = branch_start_x + float(branch_index) * (node_width + branch_column_gap)
		for row_index in branch.size():
			var upgrade_id: StringName = branch[row_index]
			var upgrade := _upgrade_by_id.get(upgrade_id) as PermanentUpgradeData
			if upgrade == null:
				continue
			var node := _create_node(&"upgrade", upgrade_id)
			node.position = Vector2(x_position, first_node_y + float(row_index) * branch_row_step)
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
		var cluster_x: float = tower_cluster_start_x + float(grid_position.x) * tower_cluster_step_x
		var upgrade_y: float = tower_node.position.y + node_height + tower_upgrade_row_offset
		for row_index in branch_upgrades.size():
			var upgrade: PermanentUpgradeData = branch_upgrades[row_index]
			var node := _create_node(&"upgrade", upgrade.id)
			var layer_column: int = _layer_order(upgrade.id)
			node.position = Vector2(
				cluster_x + float(layer_column) * (node_width + node_gap),
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
		var x_position: float = branch_start_x + float(overflow_index % 2) * (node_width + branch_column_gap)
		var row_index: int = floori(float(overflow_index) / 2.0)
		var node := _create_node(&"upgrade", upgrade.id)
		node.position = Vector2(x_position, first_node_y + float(row_index) * branch_row_step)
		_upgrade_nodes[upgrade.id] = node
		_configure_upgrade_node(node, upgrade)
		overflow_index += 1
	queue_redraw()

func _create_node(node_kind: StringName, node_id: StringName) -> MetaUpgradeNode:
	var node := NODE_SCENE.instantiate() as MetaUpgradeNode
	node.name = "%s_%s" % [node_kind, String(node_id).replace(":", "_")]
	add_child(node)
	node.custom_minimum_size = Vector2(node_width, node_height)
	node.size = Vector2(node_width, node_height)
	node.pressed.connect(_emit_node_selected.bind(node_kind, node_id, node))
	return node

func _tower_grid_position(tower_index: int) -> Vector2i:
	# Todos los desbloqueos de torre comparten una fila; sus tres mejoras quedan debajo en paralelo.
	return Vector2i(tower_index, 0)

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
	if tower_icon == null:
		tower_icon = ICON_CATALOG.call("get_icon", &"profile_currency") as Texture2D
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
	var status_text: String = "MÁXIMO" if maxed else "%d" % cost
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
		upgrade_icon = ICON_CATALOG.call("get_icon", &"profile_currency") as Texture2D
	if upgrade_icon == null:
		upgrade_icon = ICON_CATALOG.call("get_icon", &"damage") as Texture2D
	var currency_icon: Texture2D = null
	if not maxed:
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
		draw_polyline(curve, link_color, link_width, true)
		draw_circle(from_point, link_endpoint_radius, link_endpoint_color)
		draw_circle(to_point, link_endpoint_radius, link_endpoint_color)
