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
var _run_card_service: Node

func _ready() -> void:
	set_process(false)

func configure(economy_data: Resource, permanent_bonuses: Dictionary = {}) -> bool:
	last_error = ""
	if economy_data == null or not economy_data.has_method("validate"):
		last_error = "RunEconomyService requiere RunEconomyData válido."
		return false
	var errors: PackedStringArray = economy_data.call("validate")
	if not errors.is_empty():
		last_error = "; ".join(errors)
		return false
	_gold = maxi(int(economy_data.get("starting_gold")) + int(permanent_bonuses.get("starting_gold", 0)), 0)
	_maximum_mana = maxf(float(economy_data.get("maximum_mana")) + float(permanent_bonuses.get("maximum_mana", 0.0)), 1.0)
	_mana = clampf(
		float(economy_data.get("starting_mana")) + float(permanent_bonuses.get("starting_mana", 0.0)),
		0.0,
		_maximum_mana
	)
	_mana_regen_per_second = maxf(
		float(economy_data.get("mana_regen_per_second")) + float(permanent_bonuses.get("mana_regen_per_second", 0.0)),
		0.0
	)
	_mana_signal_timer = 0.0
	_is_configured = true
	set_process(true)
	gold_changed.emit(_gold, 0, &"run_start")
	mana_changed.emit(_mana, get_maximum_mana())
	return true

func set_run_card_service(run_card_service: Node) -> void:
	if _run_card_service == run_card_service:
		return
	if _run_card_service != null and is_instance_valid(_run_card_service) and _run_card_service.has_signal("modifiers_changed"):
		var previous_callback := Callable(self, "_on_run_card_modifiers_changed")
		if _run_card_service.is_connected(&"modifiers_changed", previous_callback):
			_run_card_service.disconnect(&"modifiers_changed", previous_callback)
	_run_card_service = run_card_service
	if _run_card_service != null and _run_card_service.has_signal("modifiers_changed"):
		_run_card_service.connect(&"modifiers_changed", _on_run_card_modifiers_changed)
	if _is_configured:
		_on_run_card_modifiers_changed()

func get_gold() -> int:
	return _gold

func get_mana() -> float:
	return _mana

func get_maximum_mana() -> float:
	var bonus: float = 0.0
	if _run_card_service != null and is_instance_valid(_run_card_service):
		bonus = float(_run_card_service.call("get_mana_max_bonus"))
	return maxf(_maximum_mana + bonus, 0.0)

func get_mana_regen_per_second() -> float:
	var bonus: float = 0.0
	if _run_card_service != null and is_instance_valid(_run_card_service):
		bonus = float(_run_card_service.call("get_mana_regen_bonus"))
	return maxf(_mana_regen_per_second + bonus, 0.0)

func refill_mana_to_max() -> void:
	if not _is_configured:
		return
	var effective_maximum: float = get_maximum_mana()
	if is_equal_approx(_mana, effective_maximum):
		return
	_mana = effective_maximum
	_mana_signal_timer = 0.0
	mana_changed.emit(_mana, effective_maximum)

func debug_add_mana(amount: float) -> float:
	if not _is_configured or amount <= 0.0:
		return 0.0
	var previous_mana: float = _mana
	_mana = minf(_mana + amount, get_maximum_mana())
	var accepted_amount: float = _mana - previous_mana
	if accepted_amount > 0.0:
		mana_changed.emit(_mana, get_maximum_mana())
	return accepted_amount

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
	mana_changed.emit(_mana, get_maximum_mana())
	return true

func _process(delta: float) -> void:
	var effective_regen: float = get_mana_regen_per_second()
	var effective_maximum: float = get_maximum_mana()
	if not _is_configured or delta <= 0.0 or effective_regen <= 0.0:
		return
	if RunManager.phase == RunManager.Phase.RUN_SETUP or RunManager.phase == RunManager.Phase.RUN_DEFEAT or RunManager.phase == RunManager.Phase.RUN_VICTORY:
		return
	if _mana >= effective_maximum:
		return
	var previous_mana: float = _mana
	_mana = minf(_mana + effective_regen * delta, effective_maximum)
	if is_equal_approx(previous_mana, _mana):
		return
	_mana_signal_timer -= delta
	if _mana_signal_timer > 0.0:
		return
	_mana_signal_timer = MANA_SIGNAL_INTERVAL
	mana_changed.emit(_mana, get_maximum_mana())

func _on_run_card_modifiers_changed() -> void:
	if not _is_configured:
		return
	_mana = minf(_mana, get_maximum_mana())
	mana_changed.emit(_mana, get_maximum_mana())
