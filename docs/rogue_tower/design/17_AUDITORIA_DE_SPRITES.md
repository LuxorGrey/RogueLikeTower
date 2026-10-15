# Auditoría de sprites

- Fecha de revisión: 2026-10-15.
- Alcance: los 131 archivos PNG bajo assets/sprites/, incluidos Tiny Swords y Cozy Chunky.
- Método: búsqueda por nombre de archivo en scripts, escenas, Resources y configuración del proyecto (*.gd, *.tscn, *.tres, *.gdshader, *.godot, *.cfg, *.cs). Las coincidencias de TerrainVisualCatalog y los catálogos de iconos son referencias de runtime directas, aunque el contenido se seleccione por ID.
- Resultado: 130 PNG tienen referencia de runtime localizada. Uno no aparece en el flujo actual: un sprite histórico de UI. Se conserva como candidato a legado.

| PNG | Estado de runtime | Referencias / observación |
|---|---|---|
| assets/sprites/base/main_tower.png | Usado | data/base/base_data.tres |
| assets/sprites/enemies/armored_goblin.png | Usado | data/enemies/campaign_armored_raider.tres |
| assets/sprites/enemies/armored_orc.png | Usado | data/enemies/campaign_armored_orc.tres |
| assets/sprites/enemies/bat.png | Usado | data/enemies/campaign_bat.tres |
| assets/sprites/enemies/battering_ram.png | Usado | data/enemies/campaign_battering_ram.tres |
| assets/sprites/enemies/blink_dog.png | Usado | data/enemies/campaign_blink_dog.tres |
| assets/sprites/enemies/cyclops.png | Usado | data/enemies/campaign_cyclops.tres, data/enemies/cyclops_demo.tres |
| assets/sprites/enemies/demon.png | Usado | data/enemies/campaign_demon.tres |
| assets/sprites/enemies/dodecahedron.png | Usado | data/enemies/campaign_dodecahedron.tres |
| assets/sprites/enemies/fallen_oogie.png | Usado | data/enemies/campaign_fallen_oogie.tres |
| assets/sprites/enemies/goblin.png | Usado | data/enemies/campaign_armored_raider.tres, data/enemies/basic_enemy.tres |
| assets/sprites/enemies/hexahedron.png | Usado | data/enemies/campaign_hexahedron.tres |
| assets/sprites/enemies/icosahedron.png | Usado | data/enemies/campaign_icosahedron.tres |
| assets/sprites/enemies/imp.png | Usado | data/enemies/campaign_imp.tres |
| assets/sprites/enemies/jack_o_lantern.png | Usado | data/enemies/campaign_jack_o_lantern.tres |
| assets/sprites/enemies/manticore.png | Usado | data/enemies/campaign_manticore.tres |
| assets/sprites/enemies/octahedron.png | Usado | data/enemies/campaign_octahedron.tres |
| assets/sprites/enemies/oogie_von_oogovich_haunted.png | Usado | data/enemies/campaign_tier2_boss.tres |
| assets/sprites/enemies/oogie.png | Usado | data/enemies/campaign_fallen_oogie.tres, data/enemies/campaign_oogie.tres |
| assets/sprites/enemies/oogiehedron.png | Usado | data/enemies/campaign_oogiehedron.tres |
| assets/sprites/enemies/orc.png | Usado | data/enemies/campaign_armored_orc.tres, data/enemies/campaign_orc.tres |
| assets/sprites/enemies/succubus.png | Usado | data/enemies/campaign_succubus.tres |
| assets/sprites/enemies/tetrahedron.png | Usado | data/enemies/campaign_tetrahedron.tres |
| assets/sprites/enemies/troll.png | Usado | data/enemies/campaign_regenerator.tres |
| assets/sprites/enemies/vampire.png | Usado | data/enemies/campaign_vampire.tres |
| assets/sprites/enemies/werewolf.png | Usado | data/enemies/werewolf_demo.tres, data/enemies/campaign_werewolf.tres |
| assets/sprites/enemies/witch.png | Usado | data/enemies/campaign_witch.tres |
| assets/sprites/terrain/obstacles/obstacle_bramble_bush.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/obstacles/obstacle_branch_pile.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/obstacles/obstacle_exposed_roots.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/obstacles/obstacle_fallen_log.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/obstacles/obstacle_mossy_rock_cluster.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/obstacles/obstacle_rock_and_wood.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/obstacles/obstacle_supply_crate.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/obstacles/obstacle_tree_stump.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/grass/prop_grass_flower_yellow.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/grass/prop_grass_mushroom_amber.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/grass/prop_grass_mushroom_red.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/grass/prop_grass_rock.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/grass/prop_grass_sprout.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/grass/prop_grass_stone_cluster.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/grass/prop_grass_tuft_small.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/grass/prop_grass_tuft_wide.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/mountain/prop_mountain_mossy_rock.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/mountain/prop_mountain_rock_cluster.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/mountain/prop_mountain_rock_small.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/mountain/prop_mountain_stone_scatter.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/mountain/prop_mountain_tuft_grass.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/path/prop_path_amber_stones.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/path/prop_path_dry_grass.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/path/prop_path_gold_pebbles.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/path/prop_path_sand_pile.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/random_props/path/prop_path_stone_scatter.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/spawn_portal_SpriteSheet.png | Usado | game/board/spawn_portal.gd |
| assets/sprites/terrain/spawn_portal.png | Usado | game/main/main.gd |
| assets/sprites/terrain/tiles/grass_01.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/tiles/grass_02.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/tiles/grass_03.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/tiles/grass_cliff_face.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/tiles/mountain_01.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/tiles/mountain_02.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/tiles/mountain_03.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/tiles/mountain_cliff_face.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/tiles/path_01.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/tiles/path_02.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/tiles/path_03.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/terrain/treasure_chest.png | Usado | game/board/terrain_visual_catalog.gd |
| assets/sprites/ui/demolish_tower_icon.png | Usado | `game/main/main.tscn`: acciones de demoler torre y retirar obstáculo. |
| assets/sprites/ui/icons/area.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/armor.png | Usado | game/ui/resources/icon_catalog.tres, game/main/main.tscn |
| assets/sprites/ui/icons/attack_speed.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/ballista.png | Usado | `game/towers/tower_art_catalog.gd` carga el PNG completo; icon catalog y retratos/cards lo comparten. |
| assets/sprites/ui/icons/bleed.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/burn.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/card_archive.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/critical.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/damage.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/elevation.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/enemy.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/exp.png | Usado | `game/ui/resources/icon_catalog.tres`, `game/progression/meta_shop_panel.tscn` y resumen BBCode de run. |
| assets/sprites/ui/icons/flame_thrower.png | Usado | `game/towers/tower_art_catalog.gd` carga el PNG completo; icon catalog y retratos/cards lo comparten. |
| assets/sprites/ui/icons/frost_keep.png | Usado | `game/towers/tower_art_catalog.gd` carga el PNG completo; icon catalog y retratos/cards lo comparten. |
| assets/sprites/ui/icons/gold.png | Usado | game/ui/resources/icon_catalog.tres, game/ui/components/tower_shortcut_card.tscn, game/ui/components/tower_layer_upgrade_button.tscn, game/main/main.tscn |
| assets/sprites/ui/icons/health.png | Usado | game/ui/resources/icon_catalog.tres, game/main/main.tscn |
| assets/sprites/ui/icons/mana.png | Usado | game/main/main.tscn, game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/mortar.png | Usado | `game/towers/tower_art_catalog.gd` carga el PNG completo; icon catalog y retratos/cards lo comparten. |
| assets/sprites/ui/icons/poison_sprayer.png | Usado | `game/towers/tower_art_catalog.gd` carga el PNG completo; icon catalog y retratos/cards lo comparten. |
| assets/sprites/ui/icons/poison.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/range.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/shield.png | Usado | game/main/main.tscn, game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/shredder.png | Usado | `game/towers/tower_art_catalog.gd` carga el PNG completo; icon catalog y retratos/cards lo comparten. |
| assets/sprites/ui/icons/slow.png | Usado | game/ui/resources/icon_catalog.tres |
| assets/sprites/ui/icons/tesla_coil.png | Usado | `game/towers/tower_art_catalog.gd` carga el PNG completo; icon catalog y retratos/cards lo comparten. |
| assets/sprites/ui/start_round_button.png | Usado | game/main/main.tscn |
| assets/sprites/ui/tower_card_button.png | Usado | game/ui/components/tower_shortcut_card.tscn |
| assets/sprites/ui/tower_info_panel_frame.png | Sin uso localizado | Solo figura en ADR-0051 histórico; sin uso runtime localizado. Candidato a legado. |

## Cozy Chunky y dependencia de cursores

M51 añadió 41 PNG locales de Cozy Chunky. El código usa directamente estos recursos:

| PNG | Estado de runtime | Referencias / observación |
|---|---|---|
| assets/sprites/ui/Cozy_Chunky/confetti_burst_01.png | Usado | `game/menu/main_menu.gd`: Game Over al presentar el resumen de run. |
| assets/sprites/ui/Cozy_Chunky/sparkle_twinkle_white_loop.png | Usado | `game/main/main.gd`: confirmación de pieza de terreno. |
| assets/sprites/ui/Cozy_Chunky/tap_ripple.png | Usado | `game/main/main.gd`: marca del objetivo previsto al disparar Mortar. |
| assets/sprites/ui/Cozy_Chunky/Rewards/coin_burst_gold.png | Usado | `game/main/main.gd`: cofre abierto. |
| assets/sprites/ui/Cozy_Chunky/Rewards/star_burst_gold.png | Usado | `game/main/main.gd`: cualquier nivel nuevo de torre. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/ballista_impact.png | Usado | `game/main/main.gd`: impacto de Ballista. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/ballista_shoot.png | Usado | `game/main/main.gd`: disparo de Ballista. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/base_hit.png | Usado | `game/main/main.gd`: daño recibido por la base. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/fire_impact.png | Usado | `game/main/main.gd`: impacto de Flame Thrower. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/fire_shoot.png | Usado | `game/main/main.gd`: disparo de Flame Thrower. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/ice_impact.png | Usado | `game/main/main.gd`: impacto de Frost Keep. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/ice_shoot.png | Usado | `game/main/main.gd`: disparo de Frost Keep. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/mortar_impact.png | Usado | `game/main/main.gd`: explosión de área de Mortar. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/mortar_shoot.png | Usado | `game/main/main.gd`: disparo de Mortar. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/poisonSprayer_impact.png | Usado | `game/main/main.gd`: impacto de Poison Sprayer. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/poisonSprayer_shoot.png | Usado | `game/main/main.gd`: disparo de Poison Sprayer. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/shredder_impact.png | Usado | `game/main/main.gd`: impacto de Shredder. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/shredder_shoot.png | Usado | `game/main/main.gd`: disparo de Shredder. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/teslaCoil_impact.png | Usado | `game/main/main.gd`: impacto de Tesla Coil. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/teslaCoil_shoot.png | Usado | `game/main/main.gd`: disparo de Tesla Coil. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/pickup_ui/coins_top.png | Usado | `game/main/main.gd`: feedback “Coin stomp” proporcionado para una baja final. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/pickup_ui/item_glow.png | Usado | `game/board/terrain_cell_decoration.gd`: loop detrás de cofres disponibles. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/pickup_ui/level_up.png | Usado | `game/main/main.gd`: subida manual o automática de torre. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/pickup_ui/pickup.png | Usado | `game/main/main.gd`: apertura de cofre, construcción de torre y retirada de obstáculo. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/pickup_ui/ui_click.png | Usado | `game/main/main.gd`: clic sobre objetos interactuables, en el cursor. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/status/bleed.png | Usado | `game/enemies/enemy.gd`: estado Bleed. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/status/buff.png | Usado | `game/enemies/enemy.gd`: Haste y Fortification. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/status/burn.png | Usado | `game/enemies/enemy.gd`: estado Burn. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/status/frost.png | Usado | `game/enemies/enemy.gd`: estado Slow. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/status/poison.png | Usado | `game/enemies/enemy.gd`: estado Poison. |
| assets/sprites/ui/Cozy_Chunky/PNG_1x/status/stun.png | Usado | `game/enemies/enemy.gd`: mapeo de estado Stun, si se activa en runtime. |
| assets/sprites/third_party/tiny_swords/cursors/Cursor_01.png | Usado | `game/ui/resources/icon_catalog.tres`: cursor normal. |
| assets/sprites/third_party/tiny_swords/cursors/Cursor_02.png | Usado | `game/ui/resources/icon_catalog.tres`: cursor interactivo. |
| assets/sprites/third_party/tiny_swords/cursors/Cursor_03.png | Usado | `game/ui/resources/icon_catalog.tres`: cursor de acción inválida. |
| assets/sprites/third_party/tiny_swords/cursors/Cursor_04.png | Usado | `game/ui/resources/icon_catalog.tres`: cursor de construcción. |

## Conclusión

Los demás PNG tienen referencias explícitas en el proyecto, normalmente en Resources (.tres), escenas (.tscn) o catálogos de arte. No se han detectado sprites usados por runtime que estén fuera de esta raíz. `tower_info_panel_frame.png` es el único PNG histórico sin referencia runtime localizada. Los efectos Tiny Swords y las diez hojas Cozy Chunky sin uso se eliminaron del checkout el 2026-10-15.

Esta es una auditoría estática del código y Resources actuales; no infiere usos externos a Godot ni recursos cargados desde rutas construidas dinámicamente. El inventario debe actualizarse al agregar, mover o retirar sprites.
