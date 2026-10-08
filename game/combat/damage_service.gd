class_name DamageService
extends Node

const DAMAGE_RESULT_SCRIPT: Script = preload("res://game/combat/damage_result.gd")

signal damage_resolved(target: Enemy, packet: RefCounted, result: RefCounted)

var last_result_summary: String = "Pipeline de daño listo; esperando un impacto."

func preview_damage(target: Enemy, packet: RefCounted) -> RefCounted:
	var result: RefCounted = DAMAGE_RESULT_SCRIPT.new()
	if target == null or not is_instance_valid(target):
		result.set("blocked_reason", "el objetivo ya no existe")
		return result
	if packet == null:
		result.set("blocked_reason", "falta DamagePacket")
		return result
	var packet_errors: PackedStringArray = packet.call("validate")
	if not packet_errors.is_empty():
		result.set("blocked_reason", "; ".join(packet_errors))
		return result
	if target.state != Enemy.State.MOVING:
		result.set("blocked_reason", "el objetivo no está en movimiento")
		return result

	var raw_damage: float = float(packet.get("raw_damage"))
	var armor_absorbed: float = minf(
		raw_damage,
		float(target.get_armor_value()) * float(packet.get("armor_multiplier"))
	)
	var damage_tag_multiplier: float = target.get_damage_tag_multiplier(int(packet.get("damage_tags")))
	var health_multiplier: float = float(packet.get("health_multiplier"))
	var damage_after_armor: float = maxf(raw_damage - armor_absorbed, 0.0)
	var final_damage: float = damage_after_armor * damage_tag_multiplier * health_multiplier
	result.set("is_valid", true)
	result.set("raw_damage", raw_damage)
	result.set("armor_before", target.get_armor_value())
	result.set("armor_absorbed", armor_absorbed)
	result.set("damage_tag_multiplier", damage_tag_multiplier)
	result.set("health_multiplier", health_multiplier)
	result.set("calculated_health_damage", int(floor(final_damage)))
	result.set("regen_counter_strength", float(packet.get("regen_counter_strength")))
	result.set("regen_counter_duration", float(packet.get("regen_counter_duration")))
	return result

func apply_damage(target: Enemy, packet: RefCounted) -> RefCounted:
	var result: RefCounted = preview_damage(target, packet)
	if not bool(result.get("is_valid")):
		return result
	var calculated_damage: int = int(result.get("calculated_health_damage"))
	if calculated_damage > 0:
		result.set("health_damage", target._apply_resolved_damage(calculated_damage))
	var counter_strength: float = float(packet.get("regen_counter_strength"))
	var counter_duration: float = float(packet.get("regen_counter_duration"))
	if counter_strength > 0.0 and counter_duration > 0.0:
		target.apply_regen_counter(counter_strength, counter_duration)
	var applied_status_ids := PackedStringArray()
	if is_instance_valid(target) and target.state == Enemy.State.MOVING:
		var status_payloads: Array[Resource] = packet.get("status_payloads")
		var source_id: int = int(packet.get("source_id"))
		for effect_data in status_payloads:
			if target.apply_status_effect(effect_data, source_id):
				applied_status_ids.append(String(effect_data.get("id")))
	result.set("applied_status_ids", applied_status_ids)
	result.set("target_killed", target.state == Enemy.State.DEAD)
	last_result_summary = "%s · %s" % [target.get_display_name(), result.call("get_summary")]
	damage_resolved.emit(target, packet, result)
	return result
