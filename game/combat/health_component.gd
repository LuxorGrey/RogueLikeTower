class_name HealthComponent
extends Node

signal health_changed(current_health: int, maximum_health: int)
signal health_depleted

var maximum_health: int = 1
var current_health: int = 1
var _depleted: bool = false

func initialize(health_value: int) -> bool:
	if health_value <= 0:
		push_error("HealthComponent requiere un máximo de Health mayor que cero.")
		return false
	maximum_health = health_value
	current_health = health_value
	_depleted = false
	health_changed.emit(current_health, maximum_health)
	return true

func apply_damage(amount: int) -> int:
	if amount <= 0 or _depleted:
		return 0
	var applied_amount: int = mini(amount, current_health)
	current_health -= applied_amount
	health_changed.emit(current_health, maximum_health)
	if current_health == 0:
		_depleted = true
		health_depleted.emit()
	return applied_amount

func heal(amount: int) -> int:
	if amount <= 0 or current_health >= maximum_health:
		return 0
	var healed_amount: int = mini(amount, maximum_health - current_health)
	current_health += healed_amount
	_depleted = false
	health_changed.emit(current_health, maximum_health)
	return healed_amount

func get_health_ratio() -> float:
	if maximum_health <= 0:
		return 0.0
	return float(current_health) / float(maximum_health)
