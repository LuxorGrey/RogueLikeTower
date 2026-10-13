class_name PermanentUpgradeCatalogData
extends Resource

@export var upgrades: Array[PermanentUpgradeData] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	var ids: Dictionary[StringName, bool] = {}
	for upgrade in upgrades:
		if upgrade == null:
			errors.append("El catálogo permanente contiene una mejora vacía.")
			continue
		if ids.has(upgrade.id):
			errors.append("El catálogo permanente repite el ID %s." % upgrade.id)
		ids[upgrade.id] = true
		errors.append_array(upgrade.validate())
	return errors
