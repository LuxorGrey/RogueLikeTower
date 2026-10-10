class_name Tower
extends Node2D

signal attack_fired(target: Enemy, damage: int)
signal impact_effect_requested(effect_id: StringName, world_position: Vector2)
signal stats_changed(level: int)

const ELEVATION_PIXEL_OFFSET: float = 18.0
const VISUAL_ART_OFFSET_Y: float = 6.0
const SCAN_INTERVAL: float = 0.1
const SHOT_FLASH_DURATION: float = 0.12
const BALLISTA_MISSED_TARGET_COOLDOWN_REFUND: float = 0.33
const RANGE_COLOR: Color = Color(0.30, 0.80, 1.0, 0.48)
const SHOT_COLOR: Color = Color(1.0, 0.91, 0.46, 0.96)
const DAMAGE_PACKET_SCRIPT: Script = preload("res://game/combat/damage_packet.gd")
const SAWBLADE_SCRIPT: Script = preload("res://game/towers/sawblade_projectile.gd")
const TOWER_PROJECTILE_SCRIPT: Script = preload("res://game/towers/tower_projectile.gd")
const ICON_CATALOG_SCRIPT: Script = preload("res://game/ui/icon_catalog.gd")
const DAMAGE_TAG_PHYSICAL: int = 1
const DAMAGE_TAG_FIRE: int = 2
const DAMAGE_TAG_ARCANE: int = 4
const DAMAGE_TAG_POISON: int = 8

var cell_coord: Vector2i = Vector2i.ZERO
var elevation: int = 0
var level: int = 1
var last_error: String = ""

var _tower_data: TowerData
var _damage_service: Node
var _run_economy: Node
var _run_card_service: Node
var _meta_progression: Node
var _board_grid: HexGrid
var _hex_radius: float = 52.0
var _is_selected: bool = false
var _is_hovered: bool = false
var _icon_catalog: RefCounted
var _tower_icon: Texture2D
var _current_target: Enemy
var _targeting_mode: int = TowerData.TargetingMode.FIRST_PROGRESS
var _targeting_priorities: Array[int] = [TowerData.TargetingMode.FIRST_PROGRESS, -1, -1]
var _targeting_xp_by_layer: Dictionary[int, float] = {}
var _layer_upgrade_levels: Dictionary[int, int] = {}
var _scan_timer: float = 0.0
var _attack_cooldown: float = 0.0
var _ballista_shot_cycle_id: int = 0
var _active_ballista_reload_cycle_id: int = 0
var _active_ballista_reload_duration: float = 0.0
var _shot_flash_timer: float = 0.0
var _shot_target_position: Vector2 = Vector2.ZERO
var _shot_target_positions: Array[Vector2] = []
var _turret_angle: float = -PI * 0.5
var _is_mana_blocked: bool = false
var _selection_pulse_time: float = 0.0
var _critical_rng := RandomNumberGenerator.new()

func configure(
	tower_data: TowerData,
	coord: Vector2i,
	cell_elevation: int,
	map_origin: Vector2,
	hex_radius: float,
	damage_service: Node,
	run_economy: Node = null,
	run_card_service: Node = null,
	meta_progression: Node = null,
	board_grid: HexGrid = null
) -> bool:
	last_error = ""
	if tower_data == null or damage_service == null or hex_radius <= 0.0 or cell_elevation < 0 or cell_elevation > 2:
		last_error = "La torre recibió datos inválidos o no tiene DamageService."
		return false
	set_process(false)
	var errors := tower_data.validate()
	if not errors.is_empty():
		last_error = "; ".join(errors)
		return false
	_tower_data = tower_data
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_icon_catalog = ICON_CATALOG_SCRIPT.new() as RefCounted
	_tower_icon = _icon_catalog.call("get_tower_icon", StringName(tower_data.id)) as Texture2D
	_damage_service = damage_service
	_run_economy = run_economy
	_run_card_service = run_card_service
	_meta_progression = meta_progression
	_board_grid = board_grid
	if _run_card_service != null and _run_card_service.has_signal("modifiers_changed"):
		_run_card_service.connect(&"modifiers_changed", _on_run_card_modifiers_changed)
	cell_coord = coord
	elevation = cell_elevation
	_hex_radius = hex_radius
	_targeting_mode = tower_data.targeting_mode
	_targeting_priorities = [tower_data.targeting_mode, -1, -1]
	_critical_rng.seed = int(GameState.run_seed) ^ int(get_instance_id())
	_targeting_xp_by_layer = {
		Enemy.HitPointLayer.HEALTH: 0.0,
		Enemy.HitPointLayer.ARMOR: 0.0,
		Enemy.HitPointLayer.SHIELD: 0.0,
	}
	_layer_upgrade_levels = {
		Enemy.HitPointLayer.HEALTH: 0,
		Enemy.HitPointLayer.ARMOR: 0,
		Enemy.HitPointLayer.SHIELD: 0,
	}
	global_position = map_origin + HexMath.axial_to_world(
		HexCoord.new(coord.x, coord.y),
		hex_radius
	) - Vector2(0.0, float(cell_elevation) * ELEVATION_PIXEL_OFFSET)
	queue_redraw()
	return true

func _on_run_card_modifiers_changed() -> void:
	_scan_timer = 0.0
	queue_redraw()
	stats_changed.emit(level)

func set_selected(is_selected: bool) -> void:
	if _is_selected == is_selected:
		return
	_is_selected = is_selected
	_selection_pulse_time = 0.0
	set_process(is_selected)
	z_as_relative = not is_selected
	z_index = 100 if is_selected else 0
	queue_redraw()

func set_hovered(is_hovered: bool) -> void:
	if _is_hovered == is_hovered:
		return
	_is_hovered = is_hovered
	queue_redraw()

func set_targeting_mode(mode: int) -> bool:
	if _tower_data == null:
		return false
	if mode < TowerData.TargetingMode.FIRST_PROGRESS or mode > TowerData.TargetingMode.FASTEST:
		return false
	_targeting_mode = mode
	_targeting_priorities = [mode, -1, -1]
	_current_target = null
	_scan_timer = 0.0
	return true

func set_targeting_priority(slot: int, mode: int) -> bool:
	if _tower_data == null or slot < 0 or slot >= 3:
		return false
	if mode < -1 or mode > TowerData.TargetingMode.FASTEST:
		return false
	if slot == 0 and mode < 0:
		return false
	if mode >= 0:
		for existing_slot in _targeting_priorities.size():
			if existing_slot != slot and _targeting_priorities[existing_slot] == mode:
				return false
	while _targeting_priorities.size() <= slot:
		_targeting_priorities.append(-1)
	_targeting_priorities[slot] = mode
	if slot == 0:
		_targeting_mode = mode if mode >= 0 else TowerData.TargetingMode.FIRST_PROGRESS
	_current_target = null
	_scan_timer = 0.0
	return true

func get_targeting_priorities() -> Array[int]:
	return _targeting_priorities.duplicate()

func set_targeting_priorities(priorities: Array[int]) -> bool:
	if _tower_data == null or priorities.size() != 3:
		return false
	if priorities[0] < 0:
		return false
	var seen_modes: Dictionary[int, bool] = {}
	for mode in priorities:
		if mode < -1 or mode > TowerData.TargetingMode.FASTEST:
			return false
		if mode < 0:
			continue
		if seen_modes.has(mode):
			return false
		seen_modes[mode] = true
	_targeting_priorities = priorities.duplicate()
	_targeting_mode = _targeting_priorities[0] if _targeting_priorities[0] >= 0 else _tower_data.targeting_mode
	_current_target = null
	_scan_timer = 0.0
	return true

func upgrade(hit_point_layer: int = Enemy.HitPointLayer.HEALTH) -> bool:
	if _tower_data == null or hit_point_layer < Enemy.HitPointLayer.HEALTH or hit_point_layer > Enemy.HitPointLayer.SHIELD:
		return false
	if get_layer_upgrade_level(hit_point_layer) >= _tower_data.max_layer_upgrades:
		return false
	level += 1
	_layer_upgrade_levels[hit_point_layer] = get_layer_upgrade_level(hit_point_layer) + 1
	stats_changed.emit(level)
	queue_redraw()
	return true

func get_tower_data() -> TowerData:
	return _tower_data

func get_next_upgrade_cost(hit_point_layer: int) -> int:
	if _tower_data == null or hit_point_layer < Enemy.HitPointLayer.HEALTH or hit_point_layer > Enemy.HitPointLayer.SHIELD:
		return -1
	return _tower_data.get_upgrade_cost(hit_point_layer, get_layer_upgrade_level(hit_point_layer))

func get_layer_upgrade_level(hit_point_layer: int) -> int:
	return int(_layer_upgrade_levels.get(hit_point_layer, 0))

func get_xp_required_for_next_upgrade(hit_point_layer: int) -> float:
	if _tower_data == null or hit_point_layer < Enemy.HitPointLayer.HEALTH or hit_point_layer > Enemy.HitPointLayer.SHIELD:
		return 0.0
	return _tower_data.get_targeting_xp_required_for_upgrade(get_layer_upgrade_level(hit_point_layer))

func get_max_total_upgrades() -> int:
	return _tower_data.get_max_total_upgrades() if _tower_data != null else 0

func get_mana_cost_per_attack() -> float:
	return get_current_mana_cost()

func is_mana_blocked() -> bool:
	return _is_mana_blocked

func get_current_target() -> Enemy:
	return _current_target

func get_current_damage() -> int:
	if _tower_data == null:
		return 0
	var damage: float = float(
		_tower_data.base_damage
		+ (level - 1)
		+ elevation * _tower_data.elevation_damage_bonus_per_level
	)
	if _run_card_service != null and is_instance_valid(_run_card_service):
		damage += float(_run_card_service.call("get_tower_damage_add", _tower_data.id, _tower_data.damage_tags))
		damage *= float(_run_card_service.call("get_tower_damage_multiplier", _tower_data.id, _tower_data.damage_tags))
	if _meta_progression != null and is_instance_valid(_meta_progression):
		damage *= float(_meta_progression.call("get_tower_damage_multiplier", _tower_data.id))
	return maxi(roundi(damage), 0)

func get_hit_point_damage_multiplier(layer: int) -> float:
	if _tower_data == null:
		return 0.0
	var multiplier: float = 0.0
	match layer:
		Enemy.HitPointLayer.HEALTH:
			multiplier = _tower_data.health_damage_multiplier
		Enemy.HitPointLayer.ARMOR:
			multiplier = _tower_data.armor_damage_multiplier
		Enemy.HitPointLayer.SHIELD:
			multiplier = _tower_data.shield_damage_multiplier
	multiplier += float(get_layer_upgrade_level(layer))
	if _run_card_service != null and is_instance_valid(_run_card_service) and _run_card_service.has_method("get_tower_hit_point_multiplier_add"):
		multiplier += float(_run_card_service.call("get_tower_hit_point_multiplier_add", _tower_data.id, layer))
	return maxf(multiplier, 0.0)

func get_current_crit_chance() -> float:
	if _tower_data == null:
		return 0.0
	var chance: float = _tower_data.base_crit_chance
	if _run_card_service != null and is_instance_valid(_run_card_service) and _run_card_service.has_method("get_tower_crit_chance_add"):
		chance += float(_run_card_service.call("get_tower_crit_chance_add", _tower_data.id))
	return clampf(chance, 0.0, 1.5)

func get_current_mana_cost() -> float:
	if _tower_data == null:
		return 0.0
	var mana_cost: float = _tower_data.mana_cost_per_attack
	if _tower_data.mana_cost_scales_with_damage and _tower_data.base_damage > 0:
		mana_cost *= float(get_current_damage()) / float(_tower_data.base_damage)
	if _tower_data.mana_cost_per_second > 0.0:
		mana_cost += _tower_data.mana_cost_per_second / maxf(get_current_attack_rate(), 0.001)
	if _run_card_service != null and is_instance_valid(_run_card_service):
		mana_cost *= float(_run_card_service.call("get_tower_mana_cost_multiplier", _tower_data.id))
	return maxf(mana_cost, 0.0)

func create_damage_packet(include_critical_roll: bool = true) -> RefCounted:
	var packet: RefCounted = DAMAGE_PACKET_SCRIPT.new()
	if _tower_data == null:
		return packet
	var crit_multiplier: float = _roll_critical_multiplier() if include_critical_roll else 1.0
	packet.set("raw_damage", float(get_current_damage()))
	packet.set("critical_multiplier", crit_multiplier)
	packet.set("source_id", get_instance_id())
	packet.set("damage_tags", _tower_data.damage_tags)
	packet.set("health_damage_multiplier", get_hit_point_damage_multiplier(Enemy.HitPointLayer.HEALTH))
	packet.set("armor_damage_multiplier", get_hit_point_damage_multiplier(Enemy.HitPointLayer.ARMOR))
	packet.set("shield_damage_multiplier", get_hit_point_damage_multiplier(Enemy.HitPointLayer.SHIELD))
	if _tower_data.attack_pattern == TowerData.AttackPattern.CONE:
		packet.set("health_damage_multiplier", 0.0)
		packet.set("armor_damage_multiplier", 0.0)
		packet.set("shield_damage_multiplier", 0.0)
	packet.set("regen_counter_strength", _tower_data.regen_counter_strength)
	packet.set("regen_counter_duration", _tower_data.regen_counter_duration)
	var status_payloads: Array[Resource] = []
	for status_effect in _tower_data.status_effects:
		if status_effect == null:
			continue
		var runtime_effect: Resource = status_effect.duplicate(true)
		var effect_id: StringName = StringName(runtime_effect.get("id"))
		var tick_interval: float = float(runtime_effect.get("tick_interval"))
		runtime_effect.set(
			"health_layer_multiplier",
			get_hit_point_damage_multiplier(Enemy.HitPointLayer.HEALTH) * float(runtime_effect.get("health_layer_multiplier"))
		)
		runtime_effect.set(
			"armor_layer_multiplier",
			get_hit_point_damage_multiplier(Enemy.HitPointLayer.ARMOR) * float(runtime_effect.get("armor_layer_multiplier"))
		)
		runtime_effect.set(
			"shield_layer_multiplier",
			get_hit_point_damage_multiplier(Enemy.HitPointLayer.SHIELD) * float(runtime_effect.get("shield_layer_multiplier"))
		)
		if _run_card_service != null and is_instance_valid(_run_card_service):
			var duration_multiplier: float = float(_run_card_service.call(
				"get_status_duration_multiplier",
				_tower_data.id,
				StringName(runtime_effect.get("id"))
			))
			runtime_effect.set("duration", minf(float(runtime_effect.get("duration")) * duration_multiplier, 60.0))
		if tick_interval > 0.0 and effect_id in [&"burn", &"poison"]:
			var tick_count: int = maxi(int(floor(float(runtime_effect.get("duration")) / tick_interval + 0.0001)), 1)
			runtime_effect.set("damage_per_tick", float(get_current_damage()) * crit_multiplier / float(tick_count))
		status_payloads.append(runtime_effect)
	packet.set("status_payloads", status_payloads)
	return packet

func get_current_attack_rate() -> float:
	if _tower_data == null:
		return 0.0
	return get_current_rounds_per_minute() / 60.0

func get_current_rounds_per_minute() -> float:
	if _tower_data == null:
		return 0.0
	var rounds_per_minute: float = _tower_data.get_rounds_per_minute()
	if _tower_data.visual_archetype == TowerData.VisualArchetype.FROST:
		rounds_per_minute += float(get_covered_path_cell_count()) * _tower_data.frost_rpm_per_path_cell
	if _run_card_service != null and is_instance_valid(_run_card_service) and _run_card_service.has_method("get_tower_attack_rate_multiplier"):
		rounds_per_minute *= float(_run_card_service.call("get_tower_attack_rate_multiplier", _tower_data.id))
	return maxf(rounds_per_minute, 0.0)

func get_current_range_hexes() -> float:
	if _tower_data == null:
		return 0.0
	var range_hexes: float = (
		_tower_data.range_hexes
		+ elevation * _tower_data.height_range_bonus_per_level
	)
	if _run_card_service != null and is_instance_valid(_run_card_service):
		range_hexes += float(_run_card_service.call("get_tower_range_add", _tower_data.id))
	return maxf(range_hexes, 0.0)

func get_current_area_radius_hexes() -> float:
	if _tower_data == null:
		return 0.0
	var radius: float = _tower_data.attack_area_radius_hexes
	if _run_card_service != null and is_instance_valid(_run_card_service):
		radius += float(_run_card_service.call("get_tower_area_radius_add", _tower_data.id))
	return maxf(radius, 0.0)

func get_covered_path_cell_count() -> int:
	if _board_grid == null or _tower_data == null:
		return 0
	var range_pixels: float = get_current_range_pixels()
	var covered_count: int = 0
	for cell_variant in _board_grid.cells.values():
		var cell := cell_variant as HexCell
		if cell == null or cell.terrain_type != HexCell.TerrainType.PATH:
			continue
		var cell_position: Vector2 = HexMath.axial_to_world(cell.coord, _hex_radius)
		var tower_position: Vector2 = HexMath.axial_to_world(HexCoord.new(cell_coord.x, cell_coord.y), _hex_radius)
		var elevation_offset: Vector2 = Vector2(0.0, float(cell.elevation - elevation) * ELEVATION_PIXEL_OFFSET)
		var offset: Vector2 = cell_position - tower_position - elevation_offset
		if absf(offset.x) <= range_pixels and absf(offset.y) <= range_pixels:
			covered_count += 1
	return covered_count

func get_targeting_xp(layer: int) -> float:
	return float(_targeting_xp_by_layer.get(layer, 0.0))

func get_current_range_pixels() -> float:
	var neighbor_distance: float = HexMath.axial_to_world(HexCoord.new(1, 0), _hex_radius).length()
	return get_current_range_hexes() * neighbor_distance

func get_targeting_mode() -> int:
	return _targeting_mode

func get_summary() -> String:
	if _tower_data == null:
		return "Torre sin configurar."
	var mana_summary: String = ""
	if _tower_data.mana_cost_per_second > 0.0:
		var current_mana_per_second: float = _tower_data.mana_cost_per_second
		if _run_card_service != null and is_instance_valid(_run_card_service):
			current_mana_per_second *= float(_run_card_service.call("get_tower_mana_cost_multiplier", _tower_data.id))
		mana_summary = " · %.1f Mana/s" % current_mana_per_second
	elif get_current_mana_cost() > 0.0:
		mana_summary = " · %.1f Mana/ataque" % get_current_mana_cost()
	return "%s · MEJORAS %d/%d\nDaño %d · Rango %.1f hex · %.0f RPM\nHealth {icon:health} %.1f · %s\nArmor {icon:armor} %.1f · %s\nShield {icon:shield} %.1f · %s\nCrítico %.0f%% · %s%s" % [
		_tower_data.display_name,
		level - 1,
		get_max_total_upgrades(),
		get_current_damage(),
		get_current_range_hexes(),
		get_current_rounds_per_minute(),
		get_hit_point_damage_multiplier(Enemy.HitPointLayer.HEALTH),
		_get_layer_progress_summary(Enemy.HitPointLayer.HEALTH),
		get_hit_point_damage_multiplier(Enemy.HitPointLayer.ARMOR),
		_get_layer_progress_summary(Enemy.HitPointLayer.ARMOR),
		get_hit_point_damage_multiplier(Enemy.HitPointLayer.SHIELD),
		_get_layer_progress_summary(Enemy.HitPointLayer.SHIELD),
		get_current_crit_chance() * 100.0,
		get_attack_pattern_name(),
		mana_summary,
	]

func _get_layer_progress_summary(layer: int) -> String:
	var layer_level: int = get_layer_upgrade_level(layer)
	var maximum: int = _tower_data.max_layer_upgrades
	if layer_level >= maximum:
		return "Nv %d/%d · MÁX" % [layer_level, maximum]
	return "Nv %d/%d · XP %.0f/%.0f" % [
		layer_level,
		maximum,
		get_targeting_xp(layer),
		get_xp_required_for_next_upgrade(layer),
	]

func get_attack_pattern_name() -> String:
	if _tower_data == null:
		return "sin ataque"
	if _tower_data.visual_archetype == TowerData.VisualArchetype.FROST:
		return "todos los enemigos en cuadrado de alcance"
	match _tower_data.attack_pattern:
		TowerData.AttackPattern.SINGLE_TARGET:
			return "objetivo único"
		TowerData.AttackPattern.AREA:
			return "área %.2f hex" % get_current_area_radius_hexes()
		TowerData.AttackPattern.CHAIN:
			return "hasta %d objetivos" % _tower_data.max_targets
		TowerData.AttackPattern.ALL_IN_RANGE:
			return "todos los enemigos en alcance"
		TowerData.AttackPattern.CONE:
			return "cono %.0f°" % _tower_data.cone_angle_degrees
		TowerData.AttackPattern.SAWBLADE:
			return "hoja perforante · Bleed"
		_:
			return "desconocido"

func get_damage_tag_name(tags: int) -> String:
	var names := PackedStringArray()
	if (tags & DAMAGE_TAG_PHYSICAL) != 0:
		names.append("Physical")
	if (tags & DAMAGE_TAG_FIRE) != 0:
		names.append("Fire")
	if (tags & DAMAGE_TAG_ARCANE) != 0:
		names.append("Arcane")
	if (tags & DAMAGE_TAG_POISON) != 0:
		names.append("Poison")
	return " + ".join(names) if not names.is_empty() else "sin tipo"

func get_targeting_mode_name(mode: int = -1) -> String:
	var active_mode: int = _targeting_mode if mode < 0 else mode
	match active_mode:
		TowerData.TargetingMode.FIRST_PROGRESS:
			return "más avanzado"
		TowerData.TargetingMode.LAST_PROGRESS:
			return "menos avanzado"
		TowerData.TargetingMode.LOWEST_TOTAL_HIT_POINTS:
			return "casi muerto"
		TowerData.TargetingMode.HIGHEST_HEALTH:
			return "más Health"
		TowerData.TargetingMode.HIGHEST_ARMOR:
			return "más Armor"
		TowerData.TargetingMode.HIGHEST_SHIELD:
			return "más Shield"
		TowerData.TargetingMode.LOWEST_HEALTH:
			return "menos Health"
		TowerData.TargetingMode.LOWEST_ARMOR:
			return "menos Armor"
		TowerData.TargetingMode.LOWEST_SHIELD:
			return "menos Shield"
		TowerData.TargetingMode.SLOWEST:
			return "más lento"
		TowerData.TargetingMode.FASTEST:
			return "más rápido"
		_:
			return "Desconocido"

func _physics_process(delta: float) -> void:
	if _tower_data == null:
		return
	if _shot_flash_timer > 0.0:
		_shot_flash_timer = maxf(_shot_flash_timer - delta, 0.0)
		queue_redraw()
	if RunManager.phase != RunManager.Phase.COMBAT:
		return
	if _current_target != null and not is_instance_valid(_current_target):
		_current_target = null
		_is_mana_blocked = false
		_scan_timer = 0.0
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_acquire_target()
		_scan_timer = SCAN_INTERVAL
	if _current_target == null:
		_is_mana_blocked = false
		return
	if not _is_target_in_range(_current_target):
		_current_target = null
		_is_mana_blocked = false
		return
	_gain_targeting_xp(_current_target, delta)
	_turret_angle = global_position.direction_to(_current_target.global_position).angle()
	_attack_cooldown = maxf(_attack_cooldown - delta, 0.0)
	if _attack_cooldown <= 0.0:
		_fire_at_target()

func _acquire_target() -> void:
	var best_target: Enemy = null
	for node in get_tree().get_nodes_in_group(&"enemies"):
		var candidate := node as Enemy
		if candidate == null or not is_instance_valid(candidate):
			continue
		if candidate.state != Enemy.State.MOVING or not _is_target_in_range(candidate):
			continue
		if best_target == null or _target_precedes(candidate, best_target):
			best_target = candidate
	_current_target = best_target

func _target_precedes(candidate: Enemy, incumbent: Enemy) -> bool:
	for mode in _targeting_priorities:
		if mode < 0:
			continue
		var candidate_value: float = _get_priority_value(candidate, mode)
		var incumbent_value: float = _get_priority_value(incumbent, mode)
		if is_equal_approx(candidate_value, incumbent_value):
			continue
		if mode in [
			TowerData.TargetingMode.FIRST_PROGRESS,
			TowerData.TargetingMode.HIGHEST_HEALTH,
			TowerData.TargetingMode.HIGHEST_ARMOR,
			TowerData.TargetingMode.HIGHEST_SHIELD,
			TowerData.TargetingMode.FASTEST,
		]:
			return candidate_value > incumbent_value
		return candidate_value < incumbent_value
	return candidate.get_instance_id() < incumbent.get_instance_id()

func _get_priority_value(target: Enemy, mode: int) -> float:
	match mode:
		TowerData.TargetingMode.FIRST_PROGRESS, TowerData.TargetingMode.LAST_PROGRESS:
			return target.get_route_progress()
		TowerData.TargetingMode.LOWEST_TOTAL_HIT_POINTS:
			return float(
				target.get_current_health()
				+ target.get_armor_value()
				+ target.get_shield_value()
			)
		TowerData.TargetingMode.HIGHEST_HEALTH, TowerData.TargetingMode.LOWEST_HEALTH:
			return float(target.get_current_health())
		TowerData.TargetingMode.HIGHEST_ARMOR, TowerData.TargetingMode.LOWEST_ARMOR:
			return float(target.get_armor_value())
		TowerData.TargetingMode.HIGHEST_SHIELD, TowerData.TargetingMode.LOWEST_SHIELD:
			return float(target.get_shield_value())
		TowerData.TargetingMode.SLOWEST, TowerData.TargetingMode.FASTEST:
			return target.get_current_move_speed()
		_:
			return 0.0

func _is_target_in_range(target: Enemy) -> bool:
	if target == null or not is_instance_valid(target) or target.state != Enemy.State.MOVING:
		return false
	var effective_range: float = get_current_range_pixels()
	if _tower_data != null and _tower_data.visual_archetype == TowerData.VisualArchetype.FROST:
		var square_offset: Vector2 = target.global_position - global_position
		return absf(square_offset.x) <= effective_range and absf(square_offset.y) <= effective_range
	return global_position.distance_squared_to(target.global_position) <= effective_range * effective_range

func _fire_at_target() -> void:
	if _damage_service == null or not _is_target_in_range(_current_target):
		return
	var mana_cost: float = get_current_mana_cost()
	if mana_cost > 0.0 and _run_economy != null:
		if not bool(_run_economy.call("try_spend_mana", mana_cost)):
			_is_mana_blocked = true
			_attack_cooldown = 0.25
			return
	_is_mana_blocked = false
	var target: Enemy = _current_target
	_attack_cooldown = 1.0 / maxf(get_current_attack_rate(), 0.001)
	if _tower_data.attack_pattern == TowerData.AttackPattern.SAWBLADE:
		if not _launch_sawblade(target):
			_attack_cooldown = 0.25
			return
		_shot_target_position = target.global_position - global_position
		_shot_target_positions = [_shot_target_position]
		_shot_flash_timer = SHOT_FLASH_DURATION
		attack_fired.emit(target, get_current_damage())
		queue_redraw()
		return
	if _tower_data.visual_archetype in [TowerData.VisualArchetype.BALLISTA, TowerData.VisualArchetype.MORTAR]:
		var cooldown_cycle_id: int = 0
		if _tower_data.visual_archetype == TowerData.VisualArchetype.BALLISTA:
			_ballista_shot_cycle_id += 1
			_active_ballista_reload_cycle_id = _ballista_shot_cycle_id
			_active_ballista_reload_duration = _attack_cooldown
			cooldown_cycle_id = _active_ballista_reload_cycle_id
		if not _launch_tower_projectile(target, cooldown_cycle_id):
			_attack_cooldown = 0.25
			if cooldown_cycle_id == _active_ballista_reload_cycle_id:
				_active_ballista_reload_cycle_id = 0
				_active_ballista_reload_duration = 0.0
		return
	var packet: RefCounted = create_damage_packet()
	var targets: Array[Enemy] = _get_attack_targets(target)
	var did_hit: bool = false
	_shot_target_positions.clear()
	for affected_target in targets:
		if affected_target == null or not is_instance_valid(affected_target):
			continue
		if affected_target.state != Enemy.State.MOVING:
			continue
		var result: Variant = _damage_service.call("apply_damage", affected_target, packet)
		if result == null or not bool(result.get("is_valid")):
			continue
		_emit_impact_effect(affected_target.global_position)
		var target_offset: Vector2 = affected_target.global_position - global_position
		_shot_target_positions.append(target_offset)
		if not did_hit:
			_shot_target_position = target_offset
			did_hit = true
		attack_fired.emit(affected_target, int(result.get("total_damage")))
	if not did_hit:
		return
	_shot_flash_timer = SHOT_FLASH_DURATION
	queue_redraw()

func _launch_tower_projectile(target: Enemy, cooldown_cycle_id: int = 0) -> bool:
	if target == null or not is_instance_valid(target):
		return false
	var projectile := TOWER_PROJECTILE_SCRIPT.new() as Node2D
	var entities: Node = get_parent()
	if projectile == null or entities == null:
		if projectile != null:
			projectile.free()
		return false
	entities.add_child(projectile)
	var impact_mode: int = 0
	var splash_radius: float = 0.0
	if _tower_data.visual_archetype == TowerData.VisualArchetype.MORTAR:
		impact_mode = 1
		splash_radius = get_current_area_radius_hexes() * _hex_neighbor_distance()
	return bool(projectile.call(
		"configure",
		global_position,
		target,
		target.global_position,
		create_damage_packet(),
		_damage_service,
		self,
		_tower_data.projectile_speed,
		_tower_data.projectile_hit_radius,
		splash_radius,
		impact_mode,
		cooldown_cycle_id
	))

func on_projectile_hit(target: Enemy, total_damage: int) -> void:
	if target == null or not is_instance_valid(target):
		return
	if _tower_data.visual_archetype == TowerData.VisualArchetype.BALLISTA:
		_emit_impact_effect(target.global_position)
	_shot_target_position = target.global_position - global_position
	_shot_target_positions = [_shot_target_position]
	_shot_flash_timer = SHOT_FLASH_DURATION
	attack_fired.emit(target, total_damage)
	queue_redraw()

func on_projectile_area_impact(world_position: Vector2) -> void:
	if _tower_data != null and _tower_data.visual_archetype == TowerData.VisualArchetype.MORTAR:
		_emit_impact_effect(world_position)

func on_sawblade_hit(target: Enemy) -> void:
	if target != null and is_instance_valid(target) and _tower_data != null:
		_emit_impact_effect(target.global_position)

func on_projectile_target_died_before_impact(target: Enemy, cooldown_cycle_id: int) -> void:
	if (
		target == null or not is_instance_valid(target)
		or _tower_data == null
		or _tower_data.visual_archetype != TowerData.VisualArchetype.BALLISTA
		or cooldown_cycle_id <= 0
		or cooldown_cycle_id != _active_ballista_reload_cycle_id
		or _attack_cooldown <= 0.0
	):
		return
	_attack_cooldown = maxf(
		_attack_cooldown - _active_ballista_reload_duration * BALLISTA_MISSED_TARGET_COOLDOWN_REFUND,
		0.0
	)
	_active_ballista_reload_cycle_id = 0
	_active_ballista_reload_duration = 0.0

func _get_attack_targets(primary_target: Enemy) -> Array[Enemy]:
	var targets: Array[Enemy] = [primary_target]
	match _tower_data.attack_pattern:
		TowerData.AttackPattern.SINGLE_TARGET:
			return targets
		TowerData.AttackPattern.AREA:
			var radius: float = get_current_area_radius_hexes() * _hex_neighbor_distance()
			var radius_squared: float = radius * radius
			for node in get_tree().get_nodes_in_group(&"enemies"):
				var candidate := node as Enemy
				if candidate == null or not is_instance_valid(candidate) or candidate == primary_target:
					continue
				var in_area: bool = candidate.global_position.distance_squared_to(primary_target.global_position) <= radius_squared
				if _tower_data.visual_archetype == TowerData.VisualArchetype.FROST:
					var square_offset: Vector2 = candidate.global_position - global_position
					var range_pixels: float = get_current_range_pixels()
					in_area = absf(square_offset.x) <= range_pixels and absf(square_offset.y) <= range_pixels
				if candidate.state == Enemy.State.MOVING and in_area:
					targets.append(candidate)
			return targets
		TowerData.AttackPattern.CHAIN:
			var candidates: Array[Enemy] = []
			for node in get_tree().get_nodes_in_group(&"enemies"):
				var candidate := node as Enemy
				if candidate == null or not is_instance_valid(candidate) or candidate == primary_target:
					continue
				if candidate.state == Enemy.State.MOVING and _is_target_in_range(candidate):
					candidates.append(candidate)
			candidates.sort_custom(func(a: Enemy, b: Enemy) -> bool:
				return primary_target.global_position.distance_squared_to(a.global_position) < primary_target.global_position.distance_squared_to(b.global_position)
			)
			for index in mini(candidates.size(), _tower_data.max_targets - 1):
				targets.append(candidates[index])
			return targets
		TowerData.AttackPattern.ALL_IN_RANGE:
			for node in get_tree().get_nodes_in_group(&"enemies"):
				var candidate := node as Enemy
				if candidate == null or not is_instance_valid(candidate) or candidate == primary_target:
					continue
				if candidate.state == Enemy.State.MOVING and _is_target_in_range(candidate):
					targets.append(candidate)
			return targets
		TowerData.AttackPattern.CONE:
			var forward: Vector2 = global_position.direction_to(primary_target.global_position)
			var half_angle: float = deg_to_rad(_tower_data.cone_angle_degrees * 0.5)
			var range_squared: float = get_current_range_pixels() * get_current_range_pixels()
			for node in get_tree().get_nodes_in_group(&"enemies"):
				var candidate := node as Enemy
				if candidate == null or not is_instance_valid(candidate) or candidate == primary_target:
					continue
				if candidate.state != Enemy.State.MOVING:
					continue
				var offset: Vector2 = candidate.global_position - global_position
				if offset.length_squared() <= range_squared and absf(forward.angle_to(offset.normalized())) <= half_angle:
					targets.append(candidate)
	return targets

func _gain_targeting_xp(target: Enemy, delta: float) -> void:
	if _tower_data == null or target == null or not is_instance_valid(target) or delta <= 0.0:
		return
	var layer: int = target.get_active_hit_point_layer()
	if get_layer_upgrade_level(layer) >= _tower_data.max_layer_upgrades:
		return
	var range_hexes: float = maxf(get_current_range_hexes(), 0.25)
	var earned_xp: float = (0.5 + 1.0 / (2.0 * range_hexes)) * delta
	var new_total: float = float(_targeting_xp_by_layer.get(layer, 0.0)) + earned_xp
	while get_layer_upgrade_level(layer) < _tower_data.max_layer_upgrades:
		var required_xp: float = get_xp_required_for_next_upgrade(layer)
		if required_xp <= 0.0 or new_total < required_xp:
			break
		new_total -= required_xp
		level += 1
		_layer_upgrade_levels[layer] = get_layer_upgrade_level(layer) + 1
		stats_changed.emit(level)
		queue_redraw()
	_targeting_xp_by_layer[layer] = new_total

func _roll_critical_multiplier() -> float:
	var chance: float = get_current_crit_chance()
	if chance <= 0.0:
		return 1.0
	if _critical_rng.randf() < clampf(chance - 1.0, 0.0, 0.5):
		return 4.0
	if _critical_rng.randf() < clampf(chance - 0.5, 0.0, 0.5):
		return 3.0
	if _critical_rng.randf() < clampf(chance, 0.0, 0.5):
		return 2.0
	return 1.0

func _launch_sawblade(target: Enemy) -> bool:
	if target == null or not is_instance_valid(target) or not target.has_method("get_remaining_route_waypoints"):
		return false
	var route: Array[Vector2] = target.call("get_remaining_route_waypoints")
	if route.size() < 2:
		return false
	var projectile := SAWBLADE_SCRIPT.new() as Node2D
	if projectile == null:
		return false
	var entities: Node = get_parent()
	if entities == null:
		projectile.free()
		return false
	entities.add_child(projectile)
	if not bool(projectile.call(
		"configure",
		global_position,
		route,
		create_damage_packet(),
		_damage_service,
		_tower_data.projectile_speed,
		_tower_data.projectile_hit_radius,
		_tower_data.pierce_damage_loss_per_hit,
		self
	)):
		projectile.queue_free()
		return false
	return true

func _emit_impact_effect(world_position: Vector2) -> void:
	if _tower_data == null:
		return
	var effect_id: StringName = &""
	match _tower_data.visual_archetype:
		TowerData.VisualArchetype.BALLISTA:
			effect_id = &"dust_01"
		TowerData.VisualArchetype.MORTAR:
			effect_id = &"explosion_01"
		TowerData.VisualArchetype.TESLA:
			effect_id = &"tesla_coil"
		TowerData.VisualArchetype.FROST:
			effect_id = &"ice_01"
		TowerData.VisualArchetype.FLAME:
			effect_id = &"fire_03"
		TowerData.VisualArchetype.POISON:
			effect_id = &"poison"
		TowerData.VisualArchetype.SHREDDER:
			effect_id = &"blood"
	if effect_id != &"":
		impact_effect_requested.emit(effect_id, world_position)

func _hex_neighbor_distance() -> float:
	return HexMath.axial_to_world(HexCoord.new(1, 0), _hex_radius).length()

func _process(delta: float) -> void:
	if not _is_selected:
		return
	_selection_pulse_time += delta
	queue_redraw()

func _draw() -> void:
	if _tower_data == null:
		return
	var pulse: float = 0.5 + 0.5 * sin(_selection_pulse_time * TAU / 1.15) if _is_selected else 0.0
	if _is_hovered and not _is_selected:
		draw_arc(Vector2.ZERO, get_current_range_pixels(), 0.0, TAU, 72, Color(0.65, 0.9, 1.0, 0.2), 1.4, true)
	var icon_scale: float = 1.0 + pulse * 0.055 if _is_selected else 1.0
	var visual_scale: float = _tower_data.visual_icon_size * icon_scale / 54.0
	var pedestal := PackedVector2Array([
		Vector2(-16.0, -2.0),
		Vector2(-11.0, -12.0),
		Vector2(11.0, -12.0),
		Vector2(16.0, -2.0),
		Vector2(10.0, 5.0),
		Vector2(-10.0, 5.0),
	])
	for point_index in range(pedestal.size()):
		pedestal[point_index] = pedestal[point_index] * visual_scale + Vector2(0.0, VISUAL_ART_OFFSET_Y)
	var body_color: Color = _tower_data.visual_color
	var dark_color: Color = body_color.darkened(0.55)
	var icon_size: float = _tower_data.visual_icon_size * icon_scale
	var icon_center := Vector2(0.0, -icon_size * 0.5 + VISUAL_ART_OFFSET_Y)
	draw_colored_polygon(pedestal, dark_color)
	if _tower_icon != null:
		var icon_rect := Rect2(icon_center - Vector2.ONE * icon_size * 0.5, Vector2.ONE * icon_size)
		if _is_selected:
			var glow_size: Vector2 = icon_rect.size * (1.075 + pulse * 0.035)
			var glow_alpha: float = 0.075 + pulse * 0.055
			for glow_index in range(16):
				var angle: float = TAU * float(glow_index) / 16.0
				var glow_offset := Vector2(cos(angle), sin(angle)) * (2.5 + pulse * 2.0)
				draw_texture_rect(
					_tower_icon,
					Rect2(icon_center + glow_offset - glow_size * 0.5, glow_size),
					false,
					Color(0.42, 0.78, 1.0, glow_alpha)
				)
		elif _is_hovered:
			var hover_size: Vector2 = icon_rect.size * 1.045
			draw_texture_rect(
				_tower_icon,
				Rect2(icon_center - hover_size * 0.5, hover_size),
				false,
				Color(0.82, 0.94, 1.0, 0.18)
			)
		if _is_hovered and not _is_selected:
			draw_arc(icon_center, icon_size * 0.56, 0.0, TAU, 48, Color(0.82, 0.94, 1.0, 0.68), 1.6, true)
		draw_texture_rect(_tower_icon, icon_rect, false)
	if _shot_flash_timer > 0.0:
		for target_offset in _shot_target_positions:
			draw_line(icon_center, target_offset, SHOT_COLOR, 2.0, true)
