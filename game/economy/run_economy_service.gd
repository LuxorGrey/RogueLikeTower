class_name RunEconomyService
extends Node

signal gold_changed(current_gold: int, delta: int, reason: StringName)
signal mana_changed(current_mana: float, maximum_mana: float)

const MANA_SIGNAL_INTERVAL: float = 0.1

var last_error: String = ""
var _gold: int = 0
var _mana: float = 0.0
var _maximum_mana: float = 0.0
var _mana_regen_per_second: float = 0.0
var _mana_signal_timer: float = 0.0
var _is_configured: bool = false

func _ready() -> void:
	set_process(false)

func configure(economy_data: Resource) -> bool:
	last_error = ""
	if economy_data == null or not economy_data.has_method("validate"):
		last_error = "RunEconomyService requiere RunEconomyData válido."
		return false
	var errors: PackedStringArray = economy_data.call("validate")
	if not errors.is_empty():
		last_error = "; ".join(errors)
		return false
	_gold = int(economy_data.get("starting_gold"))
	_maximum_mana = float(economy_data.get("maximum_mana"))
	_mana = float(economy_data.get("starting_mana"))
	_mana_regen_per_second = float(economy_data.get("mana_regen_per_second"))
	_mana_signal_timer = 0.0
	_is_configured = true
	set_process(true)
	gold_changed.emit(_gold, 0, &"run_start")
	mana_changed.emit(_mana, _maximum_mana)
	return true

func get_gold() -> int:
	return _gold

func get_mana() -> float:
	return _mana

func get_maximum_mana() -> float:
	return _maximum_mana

func get_mana_regen_per_second() -> float:
	return _mana_regen_per_second

func can_afford_gold(amount: int) -> bool:
	return amount >= 0 and _is_configured and _gold >= amount

func try_spend_gold(amount: int, reason: StringName = &"spend") -> bool:
	if amount < 0 or not _is_configured or _gold < amount:
		return false
	if amount == 0:
		return true
	_gold -= amount
	gold_changed.emit(_gold, -amount, reason)
	return true

func add_gold(amount: int, reason: StringName = &"reward") -> int:
	if amount <= 0 or not _is_configured:
		return 0
	var previous_gold: int = _gold
	_gold = mini(_gold + amount, 1000000000)
	var accepted_amount: int = _gold - previous_gold
	if accepted_amount > 0:
		gold_changed.emit(_gold, accepted_amount, reason)
	return accepted_amount

func try_spend_mana(amount: float) -> bool:
	if amount < 0.0 or not _is_configured or _mana + 0.0001 < amount:
		return false
	if amount == 0.0:
		return true
	_mana = maxf(_mana - amount, 0.0)
	mana_changed.emit(_mana, _maximum_mana)
	return true

func _process(delta: float) -> void:
	if not _is_configured or delta <= 0.0 or _mana_regen_per_second <= 0.0:
		return
	if RunManager.phase == RunManager.Phase.RUN_SETUP or RunManager.phase == RunManager.Phase.RUN_DEFEAT or RunManager.phase == RunManager.Phase.RUN_VICTORY:
		return
	if _mana >= _maximum_mana:
		return
	var previous_mana: float = _mana
	_mana = minf(_mana + _mana_regen_per_second * delta, _maximum_mana)
	if is_equal_approx(previous_mana, _mana):
		return
	_mana_signal_timer -= delta
	if _mana_signal_timer > 0.0:
		return
	_mana_signal_timer = MANA_SIGNAL_INTERVAL
	mana_changed.emit(_mana, _maximum_mana)
