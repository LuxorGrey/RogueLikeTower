# Mapa de sustitución de sprites

**Aplicado:** 2026-10-13. Los 23 PNG siguientes ya ocupan su ruta runtime existente. Cada original está guardado en `art_generation/originals_replaced/2026-10-13/`, conservando su ruta relativa al proyecto.

| Equivalente lógico | Ruta runtime sustituida | Sprite instalado | Copia del original |
|---|---|---|---|
| Path variante 1, arte Dirt_01 | `assets/terrain/tiles/path_01.png` | `art_generation/integration/path_01.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/path_01.png` |
| Path variante 2, arte Dirt_02 | `assets/terrain/tiles/path_02.png` | `art_generation/integration/path_02.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/path_02.png` |
| Path variante 3, arte Dirt_03 | `assets/terrain/tiles/path_03.png` | `art_generation/integration/path_03.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/path_03.png` |
| Grass variante 1 | `assets/terrain/tiles/grass_01.png` | `art_generation/generated/samples/grass_01.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/grass_01.png` |
| Grass variante 2 | `assets/terrain/tiles/grass_02.png` | `art_generation/generated/terrain/grass_02.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/grass_02.png` |
| Grass variante 3 | `assets/terrain/tiles/grass_03.png` | `art_generation/generated/terrain/grass_03.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/grass_03.png` |
| Mountain variante 1 | `assets/terrain/tiles/mountain_01.png` | `art_generation/generated/samples/mountain_01.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/mountain_01.png` |
| Mountain variante 2 | `assets/terrain/tiles/mountain_02.png` | `art_generation/generated/terrain/mountain_02.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/mountain_02.png` |
| Mountain variante 3 | `assets/terrain/tiles/mountain_03.png` | `art_generation/generated/terrain/mountain_03.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/mountain_03.png` |
| Obstáculo cristal | `assets/terrain/obstacles/crystal_shard.png` | `art_generation/generated/obstacles/crystal.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/obstacles/crystal_shard.png` |
| Obstáculo roca | `assets/terrain/obstacles/rock.png` | `art_generation/generated/samples/rock.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/obstacles/rock.png` |
| Obstáculo hierba alta | `assets/terrain/obstacles/tall_grass.png` | `art_generation/generated/obstacles/grass.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/obstacles/tall_grass.png` |
| Obstáculo tótem | `assets/terrain/obstacles/totem.png` | `art_generation/generated/obstacles/totem.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/obstacles/totem.png` |
| Obstáculo piedras | `assets/terrain/obstacles/stone_pile.png` | `art_generation/generated/obstacles/bones.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/obstacles/stone_pile.png` |
| Base | `assets/base/main_tower.png` | `art_generation/generated/structures/base.png` | `art_generation/originals_replaced/2026-10-13/assets/base/main_tower.png` |
| Portal de aparición | `assets/terrain/spawn_portal.png` | `art_generation/generated/structures/spawn_portal.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/spawn_portal.png` |
| Ballista | `game/ui/icons/ballista.png` | `art_generation/generated/samples/ballista.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/ballista.png` |
| Mortar | `game/ui/icons/mortar.png` | `art_generation/generated/towers/mortar.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/mortar.png` |
| Tesla Coil | `game/ui/icons/tesla_coil.png` | `art_generation/generated/towers/tesla_coil.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/tesla_coil.png` |
| Frost Keep | `game/ui/icons/frost_keep.png` | `art_generation/generated/towers/frost_keep.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/frost_keep.png` |
| Flamethrower | `game/ui/icons/flame_thrower.png` | `art_generation/generated/towers/flame_thrower.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/flame_thrower.png` |
| Shredder | `game/ui/icons/shredder.png` | `art_generation/generated/towers/shredder.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/shredder.png` |
| Poison Sprayer | `game/ui/icons/poison_sprayer.png` | `art_generation/generated/towers/poison_sprayer.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/poison_sprayer.png` |

## Alcance

El proyecto no tenía categoría Dirt ni texturas Dirt originales. Por elección explícita del usuario, Dirt_01/02/03 reemplazan visualmente las texturas Path_01/02/03. Se ajustó únicamente el canal alfa de esas tres salidas a la silueta del PNG Path correspondiente. PATH sigue siendo el mismo tipo lógico: topología, sockets, rutas y flechas animadas siguen en sus sistemas actuales.

No se cambiaron scripts, escenas, Resources, nombres de destinos ni configuración de importación. La tabla de equivalencias se comprueba en [validación final](validation/final_validation.md).
