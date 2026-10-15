@tool
extends Resource

@export_group("Recursos")
@export var gold: Texture2D
@export var mana: Texture2D

@export_group("Efectos de cartas")
@export var damage: Texture2D
@export var critical: Texture2D
@export var range_icon: Texture2D
@export var attack_speed: Texture2D
@export var area: Texture2D
@export var enemy: Texture2D
@export var elevation: Texture2D

@export_group("Capas")
@export var health: Texture2D
@export var armor: Texture2D
@export var shield: Texture2D

@export_group("Torres")
@export var ballista: Texture2D
@export var mortar: Texture2D
@export var tesla_coil: Texture2D
@export var frost_keep: Texture2D
@export var flame_thrower: Texture2D
@export var poison_sprayer: Texture2D
@export var shredder: Texture2D

@export_group("Progresión")
@export var card_archive: Texture2D
@export var profile_currency: Texture2D

@export_group("Estados")
@export var burn: Texture2D
@export var slow: Texture2D
@export var poison: Texture2D
@export var bleed: Texture2D

@export_group("Cursor")
@export var cursor_default: Texture2D
@export var cursor_interact: Texture2D
@export var cursor_invalid: Texture2D
@export var cursor_build: Texture2D

func get_icon(icon_name: StringName) -> Texture2D:
	var icon: Texture2D
	match icon_name:
		&"gold": icon = gold
		&"mana": icon = mana
		&"damage": icon = damage
		&"critical": icon = critical
		&"range": icon = range_icon
		&"attack_speed": icon = attack_speed
		&"area": icon = area
		&"enemy": icon = enemy
		&"elevation": icon = elevation
		&"health": icon = health
		&"armor": icon = armor
		&"shield": icon = shield
		&"ballista": icon = ballista
		&"mortar": icon = mortar
		&"tesla_coil": icon = tesla_coil
		&"frost_keep": icon = frost_keep
		&"flame_thrower": icon = flame_thrower
		&"poison_sprayer": icon = poison_sprayer
		&"shredder": icon = shredder
		&"card_archive": icon = card_archive
		&"profile_currency": icon = profile_currency
		&"burn": icon = burn
		&"slow": icon = slow
		&"poison": icon = poison
		&"bleed": icon = bleed
		&"cursor_default": icon = cursor_default
		&"cursor_interact": icon = cursor_interact
		&"cursor_invalid": icon = cursor_invalid
		&"cursor_build": icon = cursor_build
	if icon == null:
		push_warning("No existe el icono de interfaz '%s'." % icon_name)
	return icon

func normalize_tower_icon_id(tower_id: StringName) -> StringName:
	var icon_name: String = String(tower_id)
	if icon_name.ends_with("_demo"):
		icon_name = icon_name.trim_suffix("_demo")
	return StringName(icon_name)

func get_tower_icon(tower_id: StringName) -> Texture2D:
	return get_icon(normalize_tower_icon_id(tower_id))

func get_permanent_upgrade_icon(upgrade: Resource) -> Texture2D:
	if upgrade == null:
		return get_icon(&"damage")
	var upgrade_id: String = String(upgrade.get("id"))
	for tower_id in ["ballista", "mortar", "tesla_coil", "frost_keep", "flame_thrower", "poison_sprayer", "shredder"]:
		if upgrade_id.begins_with("permanent_%s_" % tower_id):
			return get_tower_icon(StringName(tower_id))
	var operations: Array = upgrade.get("operations_by_level")
	for operation_variant in operations:
		var operation: PermanentUpgradeOperation = operation_variant as PermanentUpgradeOperation
		if operation == null:
			continue
		match operation.effect_type:
			PermanentUpgradeOperation.EffectType.STARTING_GOLD_ADD, PermanentUpgradeOperation.EffectType.CHEST_SPAWN_CHANCE_ADD, PermanentUpgradeOperation.EffectType.GOLD_PER_KILL_ADD:
				return get_icon(&"gold")
			PermanentUpgradeOperation.EffectType.STARTING_MANA_ADD, PermanentUpgradeOperation.EffectType.MAXIMUM_MANA_ADD, PermanentUpgradeOperation.EffectType.MANA_REGEN_ADD:
				return get_icon(&"mana")
			PermanentUpgradeOperation.EffectType.TOWER_DAMAGE_MULTIPLIER:
				return get_icon(&"damage")
			PermanentUpgradeOperation.EffectType.UNLOCK_CONTENT:
				var content_id := String(operation.unlocked_content_id)
				for tower_id in ["ballista", "mortar", "tesla_coil", "frost_keep", "flame_thrower", "poison_sprayer", "shredder"]:
					if content_id.contains(tower_id):
						return get_tower_icon(StringName(tower_id))
				return get_icon(&"card_archive")
			PermanentUpgradeOperation.EffectType.CARD_OFFER_SIZE_ADD:
				return get_icon(&"card_archive")
			PermanentUpgradeOperation.EffectType.BASE_MAX_HEALTH_ADD, PermanentUpgradeOperation.EffectType.BASE_REPAIR_MAX_CHANCE_ADD:
				return get_icon(&"health")
			PermanentUpgradeOperation.EffectType.TOWER_HIT_POINT_MULTIPLIER_ADD:
				return get_tower_icon(operation.affected_tower_id)
	return get_icon(&"damage")

func get_card_icon(card: Resource) -> Texture2D:
	if card == null:
		return damage
	var grant_tower_id: StringName = normalize_tower_icon_id(StringName(card.get("grant_tower_id")))
	if grant_tower_id != &"":
		return get_tower_icon(grant_tower_id)
	var operations: Array = card.get("modifier_operations")
	for operation_variant in operations:
		var operation: Resource = operation_variant as Resource
		if operation == null:
			continue
		var tower_id: StringName = normalize_tower_icon_id(StringName(operation.get("affected_tower_id")))
		if tower_id in [&"ballista", &"mortar", &"tesla_coil", &"frost_keep", &"flame_thrower", &"poison_sprayer", &"shredder"]:
			return get_tower_icon(tower_id)
	for operation_variant in operations:
		var operation: Resource = operation_variant as Resource
		if operation == null:
			continue
		var operation_type: int = int(operation.get("type"))
		var icon_name: StringName = &"damage"
		match operation_type:
			CardModifierOperation.Type.TOWER_CRIT_CHANCE_ADD, CardModifierOperation.Type.STATUS_CRIT_CHANCE_ADD, CardModifierOperation.Type.STATUS_CRIT_DAMAGE_CONVERSION_ADD, CardModifierOperation.Type.TOWER_CRIT_CHANCE_PER_LEVEL_ADD:
				icon_name = &"critical"
			CardModifierOperation.Type.TOWER_RANGE_ADD:
				icon_name = &"range"
			CardModifierOperation.Type.TOWER_ELEVATION_RANGE_BONUS_MULTIPLIER_ADD:
				icon_name = &"elevation"
			CardModifierOperation.Type.TOWER_ATTACK_RATE_MULTIPLIER:
				icon_name = &"attack_speed"
			CardModifierOperation.Type.TOWER_AREA_RADIUS_ADD, CardModifierOperation.Type.TOWER_AREA_RADIUS_MULTIPLIER_ADD:
				icon_name = &"area"
			CardModifierOperation.Type.TOWER_MANA_COST_MULTIPLIER, CardModifierOperation.Type.MANA_MAX_ADD, CardModifierOperation.Type.MANA_REGEN_ADD, CardModifierOperation.Type.TOWER_MANA_COST_DAMAGE_RATIO_ADD, CardModifierOperation.Type.MANA_REGEN_MAX_PERCENT_ADD, CardModifierOperation.Type.MANA_ON_KILL_MAX_PERCENT_ADD:
				icon_name = &"mana"
			CardModifierOperation.Type.TOWER_HIT_POINT_MULTIPLIER_ADD:
				icon_name = [&"health", &"armor", &"shield"][clampi(int(operation.get("affected_hit_point_layer")), 0, 2)]
			CardModifierOperation.Type.BASE_MAX_HEALTH_ADD:
				icon_name = &"health"
			CardModifierOperation.Type.GOLD_PER_KILL_ADD:
				icon_name = &"gold"
			CardModifierOperation.Type.ENEMY_BASE_DAMAGE_ADD:
				icon_name = &"enemy"
			CardModifierOperation.Type.STATUS_DURATION_MULTIPLIER, CardModifierOperation.Type.TOWER_STATUS_DAMAGE_BONUS, CardModifierOperation.Type.STATUS_MAX_DAMAGE_PER_SECOND_ADD, CardModifierOperation.Type.STATUS_CONDITION_LAYER_DAMAGE_ADD, CardModifierOperation.Type.TOWER_SLOW_FRACTION_ADD, CardModifierOperation.Type.STATUS_SLOW_DAMAGE_SCALING_ADD, CardModifierOperation.Type.STATUS_POISON_SLOW_FRACTION_ADD, CardModifierOperation.Type.STATUS_STRENGTH_CAP_ADD:
				var status_id: StringName = StringName(operation.get("affected_status_id"))
				if status_id in [&"burn", &"slow", &"poison", &"bleed"]:
					icon_name = status_id
			CardModifierOperation.Type.TOWER_DAMAGE_ADD, CardModifierOperation.Type.TOWER_DAMAGE_MULTIPLIER:
				icon_name = &"damage"
		var icon: Texture2D = get_icon(icon_name)
		if icon != null:
			return icon
	return damage
