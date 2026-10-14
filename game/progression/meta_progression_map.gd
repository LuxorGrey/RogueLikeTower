class_name MetaProgressionMap
extends Control

signal node_selected(node_kind: StringName, node_id: StringName, local_position: Vector2)

const NODE_SCENE: PackedScene = preload("res://game/progression/meta_upgrade_node.tscn")
const ICON_CATALOG: Resource = preload("res://game/ui/resources/icon_catalog.tres")
const NODE_WIDTH: float = 172.0
const NODE_HEIGHT: float = 188.0
const TOWER_COLUMN_STEP: float = 190.0
const BRANCH_ROW_STEP: float = 218.0
const FIRST_NODE_Y: float = 94.0
const MAP_WIDTH: float = 1740.0
const MAP_HEIGHT: float = 1180.0
const GENERAL_BRANCHES: Array[Array] = [
	[&"starting_coffers", &"gold_drop", &"meta:chest_finder", &"card_archive", &"card_draw"],
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
	_center_label.add_theme_font_size_override("font_size", 16)
	_center_label.add_theme_color_override("font_color", Color("#f1cf78"))
	_center_label.position = Vector2((MAP_WIDTH - 190.0) * 0.5, 26.0)
	_center_label.size = Vector2(190.0, 40.0)
	_center_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_center_label)
	for child in get_children():
		if child is MetaUpgradeNode or child is Line2D:
			child.queue_free()
	for index in _tower_profiles.size():
		var tower_data: TowerData = _tower_profiles[index]
		if tower_data == null:
			continue
		var node := _create_node(&"tower", tower_data.unlock_id)
		node.position = Vector2(24.0 + float(index) * TOWER_COLUMN_STEP, FIRST_NODE_Y)
		_tower_nodes[tower_data.unlock_id] = node
		_configure_tower_node(node, tower_data)
		_edges.append({"from": _center_label, "to": node})

	var used_global_ids: Dictionary[StringName, bool] = {}
	for branch_index in GENERAL_BRANCHES.size():
		var branch: Array = GENERAL_BRANCHES[branch_index]
		var previous_node: Control = _center_label
		var x_position: float = MAP_WIDTH - 2.0 * NODE_WIDTH - 28.0 + float(branch_index) * (NODE_WIDTH + 14.0)
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
		for row_index in branch_upgrades.size():
			var upgrade: PermanentUpgradeData = branch_upgrades[row_index]
			var node := _create_node(&"upgrade", upgrade.id)
			node.position = Vector2(tower_node.position.x, FIRST_NODE_Y + BRANCH_ROW_STEP * float(row_index + 1))
			_upgrade_nodes[upgrade.id] = node
			_configure_upgrade_node(node, upgrade)
			# Health, Armor y Shield se habilitan en paralelo al desbloquear la torre.
			_edges.append({"from": tower_node, "to": node})

	var overflow_index: int = 0
	for upgrade in _permanent_upgrades:
		if upgrade == null or _upgrade_nodes.has(upgrade.id):
			continue
		var x_position: float = MAP_WIDTH - NODE_WIDTH - 18.0 - float(overflow_index % 2) * (NODE_WIDTH + 14.0)
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

func _emit_node_selected(node_kind: StringName, node_id: StringName, node: Control) -> void:
	node_selected.emit(node_kind, node_id, node.position + node.size * 0.5)

func _configure_tower_node(node: MetaUpgradeNode, tower_data: TowerData) -> void:
	var unlocked: bool = bool(MetaProgression.call("is_tower_unlocked", tower_data))
	var can_purchase: bool = bool(MetaProgression.call("can_purchase_tower", tower_data.unlock_id))
	var status_text: String = "DESBLOQUEADA" if unlocked else "%d XP" % tower_data.meta_unlock_cost
	var tooltip: String = "%s\n%s\n" % [tower_data.display_name, tower_data.role_summary]
	if unlocked:
		tooltip += "Disponible para aparecer como card de reclutamiento en futuras runs."
	else:
		tooltip += "Desbloquea esta torre para que pueda aparecer en las cards de run. Coste: %d XP." % tower_data.meta_unlock_cost
	node.configure_node(
		tower_data.display_name,
		tower_data.role_summary,
		status_text,
		ICON_CATALOG.call("get_tower_icon", tower_data.id) as Texture2D,
		not can_purchase and not unlocked,
		unlocked,
		tooltip
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
		status_text = "FALTAN %d XP" % maxi(cost - current_xp, 0)
	else:
		status_text = "MEJORAR · %d XP" % cost
	var title: String = _upgrade_title(upgrade)
	var details: String = upgrade.description
	if upgrade.max_level > 1:
		details += " · %d/%d" % [level, upgrade.max_level]
	var tooltip: String = "%s\n%s\n" % [title.replace("\n", " · "), upgrade.description]
	var requirement_text: String = _upgrade_requirement_text(upgrade)
	if not requirement_text.is_empty():
		tooltip += "\nPara desbloquear: %s" % requirement_text
	if cost >= 0:
		tooltip += "\nNivel %d/%d · coste %d XP · saldo %d XP." % [level, upgrade.max_level, cost, current_xp]
	node.configure_node(
		title,
		details,
		status_text,
		ICON_CATALOG.call("get_permanent_upgrade_icon", upgrade) as Texture2D,
		locked or not can_buy or maxed,
		level > 0,
		tooltip
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
		return "%s\n%s" % [tower_data.display_name, upgrade.display_name]
	return upgrade.display_name

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
