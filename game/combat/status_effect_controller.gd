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

func apply_effect(effect_data: Resource, source_id: int, total_damage_override: int = -1) -> bool:
	if _enemy == null or not is_instance_valid(_enemy) or _enemy.state != Enemy.State.MOVING:
		return false
	if effect_data == null or not effect_data.has_method("validate"):
		return false
	var validation_errors: PackedStringArray = effect_data.call("validate")
	if not validation_errors.is_empty():
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
		match int(effect_data.get("stack_rule")):
			STACK_RULE_REFRESH:
				active_status.stacks = 1
			STACK_RULE_ADD_STACKS:
				active_status.stacks = mini(active_status.stacks + 1, int(effect_data.get("max_stacks")))
	var tick_count: int = _get_effect_tick_count(effect_data)
	if total_damage_override >= 0 and tick_count > 0:
		active_status.total_damage_remaining = total_damage_override * active_status.stacks
		active_status.total_damage_ticks_remaining = tick_count
	else:
		active_status.total_damage_remaining = -1
		active_status.total_damage_ticks_remaining = 0

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
	for effect_id in _active_statuses.keys():
		var active_status: ActiveStatus = _active_statuses.get(effect_id) as ActiveStatus
		if active_status == null:
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
	var damage_for_tick: float = float(active_status.data.get("damage_per_tick")) * float(active_status.stacks)
	if active_status.total_damage_remaining >= 0 and active_status.total_damage_ticks_remaining > 0:
		damage_for_tick = float(ceili(
			float(active_status.total_damage_remaining) / float(active_status.total_damage_ticks_remaining)
		))
		active_status.total_damage_remaining = maxi(active_status.total_damage_remaining - int(damage_for_tick), 0)
		active_status.total_damage_ticks_remaining -= 1
	packet.set("raw_damage", damage_for_tick)
	packet.set("source_id", active_status.source_id)
	packet.set("damage_tags", int(active_status.data.get("damage_tags")))
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
		speed_multiplier = minf(
			speed_multiplier,
			float(active_status.data.get("speed_multiplier"))
		)
	_enemy.set_status_speed_multiplier(speed_multiplier)
