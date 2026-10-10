extends Control

const MAIN_SCENE: PackedScene = preload("res://game/main/main.tscn")
const DEBUG_PANEL_SCENE: PackedScene = preload("res://game/ui/debug_hacks_panel.tscn")
const META_SHOP_SCENE: PackedScene = preload("res://game/progression/meta_shop_panel.tscn")
const TOWER_CARD_SCENE: PackedScene = preload("res://game/ui/components/tower_shortcut_card.tscn")
const LAYER_BUTTON_SCENE: PackedScene = preload("res://game/ui/components/tower_layer_upgrade_button.tscn")
const UPGRADE_PANEL_SCENE: PackedScene = preload("res://game/ui/components/upgrade_offer_panel.tscn")
const SHOP_ROW_SCENE: PackedScene = preload("res://game/progression/meta_shop_row.tscn")
const WAVE_TOOLTIP_SCENE: PackedScene = preload("res://game/ui/components/wave_hover_tooltip.tscn")
const ROUND_PROGRESS_SCRIPT: Script = preload("res://game/ui/round_progress_strip.gd")
const ICON_CATALOG_SCRIPT: Script = preload("res://game/ui/icon_catalog.gd")
const BALLISTA: TowerData = preload("res://data/towers/ballista.tres")
const STARTING_COFFERS: PermanentUpgradeData = preload("res://data/meta/upgrades/starting_coffers.tres")
const FIRST_WAVE: WaveData = preload("res://data/waves/round_01.tres")

func _ready() -> void:
	call_deferred("_run_smoke")

func _run_smoke() -> void:
	var main_instance := MAIN_SCENE.instantiate()
	add_child(main_instance)
	await get_tree().process_frame
	assert(main_instance.get_node_or_null("HUD/UpgradeCardPanel") != null, "Main must instance the visual upgrade offer scene.")
	assert(main_instance.get_node_or_null("MetaShopPanel") is MetaShopPanel, "Main must add the terminal shop scene during setup.")
	assert(main_instance.get_node_or_null("DebugHacksPanel") is DebugHacksPanel, "Main must add the debug scene during setup.")
	var icon_catalog: Resource = main_instance.get("ui_icon_catalog") as Resource
	var icon_ids: Array[StringName] = [
		&"gold", &"mana", &"health", &"armor", &"shield", &"ballista", &"mortar",
		&"tesla_coil", &"frost_keep", &"flame_thrower", &"poison_sprayer", &"shredder",
		&"burn", &"slow", &"poison", &"bleed", &"cursor_default", &"cursor_interact",
		&"cursor_invalid", &"cursor_build",
	]
	for icon_id in icon_ids:
		assert(icon_catalog.call("get_icon", icon_id) is Texture2D, "The inspector icon catalog must provide %s." % icon_id)
	var legacy_icon_catalog := ICON_CATALOG_SCRIPT.new() as RefCounted
	assert(legacy_icon_catalog.call("get_tower_icon", &"ballista_demo") is Texture2D, "The legacy tower icon API must continue to resolve tower icons.")
	var start_round_button := main_instance.get_node("HUD/RoundPanel/Margin/Content/StartWave") as Button
	var start_round_style := start_round_button.get_theme_stylebox("normal") as StyleBoxTexture
	assert(start_round_style != null and start_round_style.texture != null, "The round button sprite must be authored on its scene style resource.")
	var toolbar_card := main_instance.get_node("HUD/TowerToolbar/Buttons/TowerShortcut1") as TowerShortcutCard
	assert(toolbar_card.tower_icon_texture != null and toolbar_card.tower_icon.texture == toolbar_card.tower_icon_texture)
	var health_upgrade := main_instance.get_node("HUD/TowerInfoPanel/Margin/TowerInfoContent/TowerActions/UpgradeRow/UpgradeHealth") as TowerLayerUpgradeButton
	assert(health_upgrade.layer_icon_texture != null and health_upgrade.layer_icon.texture == health_upgrade.layer_icon_texture)
	main_instance.free()

	var debug_panel := DEBUG_PANEL_SCENE.instantiate() as DebugHacksPanel
	add_child(debug_panel)
	var debug_actions: Array[StringName] = []
	debug_panel.action_requested.connect(func(action_id: StringName) -> void: debug_actions.append(action_id))
	debug_panel.get_node("Root/Center/Panel/Margin/Content/StartWaveButton").emit_signal("pressed")
	assert(debug_actions == [&"start_wave"], "The debug panel must preserve its action signal contract.")

	var tower_card := TOWER_CARD_SCENE.instantiate() as TowerShortcutCard
	add_child(tower_card)
	tower_card.set_tower_visuals("Smoke Tower", Color.WHITE)
	tower_card.set_build_cost(42)
	assert(tower_card.name_label.text == "Smoke Tower" and tower_card.price_label.text == "42")

	var layer_button := LAYER_BUTTON_SCENE.instantiate() as TowerLayerUpgradeButton
	add_child(layer_button)
	assert(layer_button.get_node_or_null("Content/XPBar") != null, "The layer upgrade control must expose its authored XP view.")

	var upgrade_panel := UPGRADE_PANEL_SCENE.instantiate() as UpgradeOfferPanel
	add_child(upgrade_panel)
	assert(upgrade_panel.cards.size() == 3, "The authored offer preview must contain three cards.")
	upgrade_panel.set_card_count(5)
	assert(upgrade_panel.cards.size() == 5, "Offer size must remain data-configurable above the preview count.")
	upgrade_panel.set_card_count(3)

	var shop_row := SHOP_ROW_SCENE.instantiate() as PanelContainer
	add_child(shop_row)
	assert(shop_row.get_node_or_null("Body/Labels/Title") is RichTextLabel)
	shop_row.queue_free()

	var shop := META_SHOP_SCENE.instantiate() as MetaShopPanel
	shop.configure([BALLISTA], [STARTING_COFFERS])
	add_child(shop)
	var tower_list := shop.get_node("MetaShopRoot/MetaShop/Margin/Content/Scroll/Lists/TowerList") as VBoxContainer
	var upgrade_list := shop.get_node("MetaShopRoot/MetaShop/Margin/Content/Scroll/Lists/UpgradeList") as VBoxContainer
	assert(tower_list.get_child_count() == 2, "The tower tab must add one reusable shop row after its heading.")
	assert(upgrade_list.get_child_count() == 2, "The upgrade tab must add one reusable shop row after its heading.")
	var new_run_requests: Array[int] = [0]
	shop.new_run_requested.connect(func() -> void: new_run_requests[0] += 1)
	shop.get_node("MetaShopRoot/MetaShop/Margin/Content/NewRunButton").emit_signal("pressed")
	assert(new_run_requests[0] == 1, "The terminal shop must preserve its new-run signal.")

	var tooltip := WAVE_TOOLTIP_SCENE.instantiate() as WaveHoverTooltip
	add_child(tooltip)
	tooltip.set_summary(1, 3)
	tooltip.add_enemy_row("Smoke Enemy", 3, null)
	assert(tooltip.get_node("Rows/EnemyRows").get_child_count() == 1)

	var progress_strip := Control.new()
	progress_strip.set_script(ROUND_PROGRESS_SCRIPT)
	progress_strip.custom_minimum_size = Vector2(500.0, 42.0)
	add_child(progress_strip)
	var smoke_waves: Array[WaveData] = [FIRST_WAVE]
	progress_strip.call("set_campaign_waves", smoke_waves)
	progress_strip.call("_show_wave_tooltip", 0)
	assert(progress_strip.get_node_or_null("WaveHoverTooltip") != null, "The round strip must instantiate its tooltip scene.")

	print("UI migration smoke: PASS")
	get_tree().quit()
