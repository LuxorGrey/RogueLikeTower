class_name StatusEffectController
extends Node

class ActiveStatus:
	extends RefCounted

	var data: Resource
	var stacks: int = 1
	var remaining_duration: float = 0.0
	var time_until_tick: float = 0.0
	var source_id: int = 0
	var total_damage_remaining: int = -1
	var total_damage_ticks_remaining: int = 0
	var damage_scale: float = 1.0
	var strength: float = 0.0
	var uses_strength_decay: bool = false

const DAMAGE_PACKET_SCRIPT: Script = preload("res://game/combat/damage_packet.gd")
const STACK_RULE_REFRESH: int = 0
const STACK_RULE_ADD_STACKS: int = 1

signal status_changed(active_ids: PackedStringArray)
signal status_ticked(effect_id: StringName, health_damage: int)

var _enemy: Enemy
var _damage_service: Node
var _active_statuses: Dictionary[StringName, ActiveStatus] = {}

func _ready() -> void:
	_enemy = get_parent() as Enemy
	set_process(false)

func configure_damage_service(damage_service: Node) -> void:
	_damage_service = damage_service

func apply_effect(
	effect_data: Resource,
	source_id: int,
	total_damage_override: int = -1,
	strength_override: float = -1.0
) -> bool:
	if _enemy == null or not is_instance_valid(_enemy) or _enemy.state != Enemy.State.MOVING:
		return false
	if effect_data == null or not effect_data.has_method("validate"):
		return false
	var validation_errors: PackedStringArray = effect_data.call("validate")
	if not validation_errors.is_empty():
		return false
	var strength_cap: float = float(effect_data.get("strength_cap"))
	var strength_decay_per_second: float = float(effect_data.get("strength_decay_per_second"))
	var uses_strength_decay: bool = strength_override >= 0.0 and strength_cap > 0.0 and strength_decay_per_second > 0.0
	if strength_override >= 0.0 and not uses_strength_decay:
		return false
	if uses_strength_decay and strength_override <= 0.0:
		return false

	var effect_id: StringName = effect_data.get("id")
	var active_status: ActiveStatus = _active_statuses.get(effect_id) as ActiveStatus
	if active_status == null:
		active_status = ActiveStatus.new()
		active_status.data = effect_data
		active_status.remaining_duration = float(effect_data.get("duration"))
		active_status.time_until_tick = float(effect_data.get("tick_interval"))
		active_status.source_id = source_id
		_active_statuses[effect_id] = active_status
	else:
		active_status.data = effect_data
		active_status.remaining_duration = float(effect_data.get("duration"))
		active_status.source_id = source_id
		active_status.stacks = mini(active_status.stacks, int(effect_data.get("max_stacks")))
	if uses_strength_decay:
		active_status.uses_strength_decay = true
		active_status.strength = minf(active_status.strength + strength_override, strength_cap)
		active_status.remaining_duration = active_status.strength / strength_decay_per_second
		active_status.stacks = 1
		active_status.total_damage_remaining = -1
		active_status.total_damage_ticks_remaining = 0
	else:
		active_status.uses_strength_decay = false
		active_status.strength = 0.0
		match int(effect_data.get("stack_rule")):
			STACK_RULE_REFRESH:
				active_status.stacks = 1
			STACK_RULE_ADD_STACKS:
				active_status.stacks = mini(active_status.stacks + 1, int(effect_data.get("max_stacks")))
	var tick_count: int = _get_effect_tick_count(effect_data)
	if not uses_strength_decay and total_damage_override >= 0 and tick_count > 0:
		var capped_total_damage: int = total_damage_override * active_status.stacks
		var max_dps: float = float(effect_data.get("max_damage_per_second"))
		if max_dps > 0.0:
			capped_total_damage = mini(capped_total_damage, floori(max_dps * float(effect_data.get("duration"))))
		active_status.total_damage_remaining = capped_total_damage
		active_status.total_damage_ticks_remaining = tick_count
		active_status.damage_scale = 1.0
	elif not uses_strength_decay:
		active_status.total_damage_remaining = -1
		active_status.total_damage_ticks_remaining = 0
		active_status.damage_scale = 1.0

	_recalculate_speed_multiplier()
	set_process(true)
	status_changed.emit(get_active_status_ids())
	return true

func has_status(effect_id: StringName) -> bool:
	return _active_statuses.has(effect_id)

func get_active_status_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for effect_id in _active_statuses:
		ids.append(String(effect_id))
	ids.sort()
	return ids

func get_active_status_summaries() -> PackedStringArray:
	var summaries := PackedStringArray()
	var ids := get_active_status_ids()
	for id_text in ids:
		var effect_id := StringName(id_text)
		var active_status: ActiveStatus = _active_statuses[effect_id]
		var label: String = String(active_status.data.get("display_name"))
		if active_status.stacks > 1:
			label += " ×%d" % active_status.stacks
		summaries.append("%s %.1fs" % [label, active_status.remaining_duration])
	return summaries

func get_active_status_stacks() -> Dictionary:
	var stacks: Dictionary = {}
	for effect_id in _active_statuses:
		var active_status: ActiveStatus = _active_statuses[effect_id] as ActiveStatus
		if active_status != null:
			stacks[String(effect_id)] = active_status.stacks
	return stacks

func get_status_strength(effect_id: StringName) -> float:
	var active_status: ActiveStatus = _active_statuses.get(effect_id) as ActiveStatus
	return active_status.strength if active_status != null else 0.0

func consume_status_damage(effect_id: StringName, fraction: float) -> Dictionary:
	var empty_result: Dictionary = {}
	var active_status: ActiveStatus = _active_statuses.get(effect_id) as ActiveStatus
	if active_status == null or fraction <= 0.0:
		return empty_result
	var remaining_damage: float = 0.0
	if active_status.total_damage_remaining >= 0:
		remaining_damage = float(active_status.total_damage_remaining)
	else:
		var ticks_left: int = maxi(int(ceil(active_status.remaining_duration / maxf(float(active_status.data.get("tick_interval")), 0.001))), 0)
		remaining_damage = float(active_status.data.get("damage_per_tick")) * float(active_status.stacks * ticks_left) * active_status.damage_scale
	var converted_damage: int = floori(remaining_damage * clampf(fraction, 0.0, 1.0))
	if converted_damage <= 0:
		return empty_result
	if active_status.total_damage_remaining >= 0:
		active_status.total_damage_remaining = maxi(active_status.total_damage_remaining - converted_damage, 0)
	else:
		active_status.damage_scale *= 1.0 - clampf(fraction, 0.0, 1.0)
	return {
		"amount": converted_damage,
		"damage_tags": int(active_status.data.get("damage_tags")),
		"health_layer_multiplier": float(active_status.data.get("health_layer_multiplier")),
		"armor_layer_multiplier": float(active_status.data.get("armor_layer_multiplier")),
		"shield_layer_multiplier": float(active_status.data.get("shield_layer_multiplier")),
	}

func clear_all() -> void:
	if _active_statuses.is_empty():
		return
	_active_statuses.clear()
	_recalculate_speed_multiplier()
	set_process(false)
	status_changed.emit(PackedStringArray())

func _process(delta: float) -> void:
	if _enemy == null or not is_instance_valid(_enemy) or _enemy.state != Enemy.State.MOVING:
		clear_all()
		return
	var expired_ids := PackedStringArray()
	var strength_changed: bool = false
	for effect_id in _active_statuses.keys():
		var active_status: ActiveStatus = _active_statuses.get(effect_id) as ActiveStatus
		if active_status == null:
			expired_ids.append(String(effect_id))
			continue
		if active_status.uses_strength_decay:
			var decay_rate: float = float(active_status.data.get("strength_decay_per_second"))
			active_status.strength = maxf(active_status.strength - decay_rate * delta, 0.0)
			active_status.remaining_duration = active_status.strength / maxf(decay_rate, 0.001)
			strength_changed = true
			if active_status.strength <= 0.0:
				expired_ids.append(String(effect_id))
			continue
		var active_delta: float = minf(delta, active_status.remaining_duration)
		active_status.remaining_duration -= delta
		var damage_per_tick: float = float(active_status.data.get("damage_per_tick"))
		var tick_interval: float = float(active_status.data.get("tick_interval"))
		if damage_per_tick > 0.0 and tick_interval > 0.0:
			active_status.time_until_tick -= active_delta
			while active_status.time_until_tick <= 0.0001:
				active_status.time_until_tick += tick_interval
				_apply_damage_tick(effect_id, active_status)
				if not is_instance_valid(_enemy) or _enemy.state != Enemy.State.MOVING:
					return
		if active_status.remaining_duration <= 0.0:
			expired_ids.append(String(effect_id))
	if expired_ids.is_empty():
		if strength_changed:
			_recalculate_speed_multiplier()
		return
	for expired_id in expired_ids:
		_active_statuses.erase(StringName(expired_id))
	_recalculate_speed_multiplier()
	status_changed.emit(get_active_status_ids())
	if _active_statuses.is_empty():
		set_process(false)

func _apply_damage_tick(effect_id: StringName, active_status: ActiveStatus) -> void:
	if _damage_service == null or not is_instance_valid(_damage_service):
		return
	var packet: RefCounted = DAMAGE_PACKET_SCRIPT.new()
	var damage_for_tick: float = float(active_status.data.get("damage_per_tick")) * float(active_status.stacks) * active_status.damage_scale
	if effect_id == &"burn":
		var burn_slow_scaling: float = float(active_status.data.get("slow_damage_scaling"))
		if burn_slow_scaling > 0.0:
			damage_for_tick *= 1.0 + get_status_strength(&"slow") * burn_slow_scaling / 100.0
	var max_damage_per_second: float = float(active_status.data.get("max_damage_per_second"))
	if max_damage_per_second > 0.0:
		damage_for_tick = minf(damage_for_tick, max_damage_per_second * maxf(float(active_status.data.get("tick_interval")), 0.0))
	if active_status.total_damage_remaining >= 0 and active_status.total_damage_ticks_remaining > 0:
		damage_for_tick = float(ceili(
			float(active_status.total_damage_remaining) / float(active_status.total_damage_ticks_remaining)
		))
		active_status.total_damage_remaining = maxi(active_status.total_damage_remaining - int(damage_for_tick), 0)
		active_status.total_damage_ticks_remaining -= 1
	packet.set("raw_damage", damage_for_tick)
	packet.set("source_id", active_status.source_id)
	packet.set("damage_tags", int(active_status.data.get("damage_tags")))
	packet.set("is_status_damage", true)
	packet.set("health_damage_multiplier", float(active_status.data.get("health_layer_multiplier")))
	packet.set("armor_damage_multiplier", float(active_status.data.get("armor_layer_multiplier")))
	packet.set("shield_damage_multiplier", float(active_status.data.get("shield_layer_multiplier")))
	var result: Variant = _damage_service.call("apply_damage", _enemy, packet)
	var applied_damage: int = int(result.get("total_damage")) if result != null else 0
	status_ticked.emit(effect_id, applied_damage)

func _get_effect_tick_count(effect_data: Resource) -> int:
	var tick_interval: float = float(effect_data.get("tick_interval"))
	if tick_interval <= 0.0:
		return 0
	return int(floor(float(effect_data.get("duration")) / tick_interval + 0.0001))

func _recalculate_speed_multiplier() -> void:
	if _enemy == null or not is_instance_valid(_enemy):
		return
	var speed_multiplier: float = 1.0
	for active_status in _active_statuses.values():
		var effect_multiplier: float = float(active_status.data.get("speed_multiplier"))
		if active_status.uses_strength_decay:
			effect_multiplier = clampf(1.0 - active_status.strength / 100.0, 0.05, 1.0)
		speed_multiplier = minf(speed_multiplier, effect_multiplier)
	_enemy.set_status_speed_multiplier(speed_multiplier)
