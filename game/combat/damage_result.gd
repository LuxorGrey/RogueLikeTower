class_name DamageResult
extends RefCounted

var is_valid: bool = false
var blocked_reason: String = ""
var raw_damage: float = 0.0
var armor_before: int = 0
var armor_absorbed: float = 0.0
var damage_tag_multiplier: float = 1.0
var health_multiplier: float = 1.0
var calculated_health_damage: int = 0
var health_damage: int = 0
var regen_counter_strength: float = 0.0
var regen_counter_duration: float = 0.0
var target_killed: bool = false
var applied_status_ids: PackedStringArray = PackedStringArray()

func get_summary() -> String:
	if not is_valid:
		return "Daño no aplicado: %s" % blocked_reason
	var summary: String = "bruto %.1f · armadura −%.1f · tipo ×%.2f · vida ×%.2f · aplicado %d · anti-regen %.0f%%/%.1fs" % [
		raw_damage,
		armor_absorbed,
		damage_tag_multiplier,
		health_multiplier,
		health_damage,
		regen_counter_strength * 100.0,
		regen_counter_duration,
	]
	if not applied_status_ids.is_empty():
		summary += " · estados: %s" % ", ".join(applied_status_ids)
	return summary
