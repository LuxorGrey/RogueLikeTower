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

	var raw_damage: float = float(packet.get("raw_damage")) * float(packet.get("critical_multiplier"))
	var fortification_reduction: float = target.get_fortification_damage_reduction()
	raw_damage = maxf(raw_damage - fortification_reduction, 0.0)
	var damage_tag_multiplier: float = target.get_damage_tag_multiplier(int(packet.get("damage_tags")))
	var active_layer: int = target.get_active_hit_point_layer()
	var layer_status_bonus: float = 0.0
	if not bool(packet.get("is_status_damage")):
		layer_status_bonus = target.get_layer_status_damage_bonus(active_layer)
	var layer_damage: Dictionary = _calculate_layer_damage(target, packet, raw_damage, damage_tag_multiplier)
	var final_damage: int = int(layer_damage.get("health", 0)) + int(layer_damage.get("armor", 0)) + int(layer_damage.get("shield", 0))
	result.set("is_valid", true)
	result.set("raw_damage", float(packet.get("raw_damage")))
	result.set("critical_multiplier", float(packet.get("critical_multiplier")))
	result.set("active_hit_point_layer", active_layer)
	result.set("health_before", target.get_current_health())
	result.set("armor_before", target.get_armor_value())
	result.set("shield_before", target.get_shield_value())
	result.set("armor_absorbed", 0.0)
	result.set("damage_tag_multiplier", damage_tag_multiplier)
	result.set("fortification_reduction", fortification_reduction)
	result.set("health_multiplier", float(packet.call("get_hit_point_multiplier", active_layer)))
	result.set("layer_status_bonus", layer_status_bonus)
	result.set("calculated_health_damage", final_damage)
	result.set("total_damage", final_damage)
	result.set("health_damage", int(layer_damage.get("health", 0)))
	result.set("armor_damage", int(layer_damage.get("armor", 0)))
	result.set("shield_damage", int(layer_damage.get("shield", 0)))
	result.set("regen_counter_strength", float(packet.get("regen_counter_strength")))
	result.set("regen_counter_duration", float(packet.get("regen_counter_duration")))
	return result

func _calculate_layer_damage(
	target: Enemy,
	packet: RefCounted,
	raw_damage: float,
	damage_tag_multiplier: float
) -> Dictionary:
	var layer_damage := {"health": 0, "armor": 0, "shield": 0}
	var active_layer: int = target.get_active_hit_point_layer()
	var current_value: int = target.get_hit_point_value(active_layer)
	if current_value <= 0:
		return layer_damage
	var layer_multiplier: float = float(packet.call("get_hit_point_multiplier", active_layer))
	if not bool(packet.get("is_status_damage")):
		layer_multiplier += target.get_layer_status_damage_bonus(active_layer)
	var effective_multiplier: float = layer_multiplier * damage_tag_multiplier
	var layer_damage_budget: int = int(floor(raw_damage * effective_multiplier))
	if layer_damage_budget <= 0:
		return layer_damage
	var applied_damage: int = mini(current_value, layer_damage_budget)
	match active_layer:
		Enemy.HitPointLayer.SHIELD:
			layer_damage["shield"] = applied_damage
		Enemy.HitPointLayer.ARMOR:
			layer_damage["armor"] = applied_damage
		Enemy.HitPointLayer.HEALTH:
			layer_damage["health"] = applied_damage
	return layer_damage

func apply_damage(target: Enemy, packet: RefCounted) -> RefCounted:
	var result: RefCounted = preview_damage(target, packet)
	if not bool(result.get("is_valid")):
		return result
	var calculated_damage: int = int(result.get("calculated_health_damage"))
	if calculated_damage > 0:
		var applied: Dictionary = target._apply_layer_damage({
			"health": int(result.get("health_damage")),
			"armor": int(result.get("armor_damage")),
			"shield": int(result.get("shield_damage")),
		})
		result.set("health_damage", int(applied.get("health", 0)))
		result.set("armor_damage", int(applied.get("armor", 0)))
		result.set("shield_damage", int(applied.get("shield", 0)))
		result.set("total_damage", int(applied.get("health", 0)) + int(applied.get("armor", 0)) + int(applied.get("shield", 0)))
		result.set("calculated_health_damage", int(result.get("total_damage")))
	var counter_strength: float = float(packet.get("regen_counter_strength"))
	var counter_duration: float = float(packet.get("regen_counter_duration"))
	if counter_strength > 0.0 and counter_duration > 0.0:
		target.apply_regen_counter(counter_strength, counter_duration)
	var applied_status_ids := PackedStringArray()
	if is_instance_valid(target) and target.state == Enemy.State.MOVING:
		var status_payloads: Array[Resource] = packet.get("status_payloads")
		var total_damage_overrides: Dictionary[StringName, int] = packet.get("status_total_damage_overrides")
		var source_id: int = int(packet.get("source_id"))
		for effect_data in status_payloads:
			var effect_id: StringName = StringName(effect_data.get("id"))
			var total_damage_override: int = int(total_damage_overrides.get(effect_id, -1))
			if target.apply_status_effect(effect_data, source_id, total_damage_override):
				applied_status_ids.append(String(effect_data.get("id")))
	result.set("applied_status_ids", applied_status_ids)
	result.set("target_killed", target.state == Enemy.State.DEAD)
	last_result_summary = "%s · %s" % [target.get_display_name(), result.call("get_summary")]
	damage_resolved.emit(target, packet, result)
	return result
