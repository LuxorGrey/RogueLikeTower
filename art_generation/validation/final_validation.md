# Validación final de assets

**Fecha:** 2026-10-13\
**Resultado:** 23/23 destinos coinciden con su arte; 23/23 originales respaldados.\
**Método:** canvas y modo RGBA cotejados; píxeles runtime cotejados byte a byte con el arte asignado; canal alfa runtime cotejado byte a byte con el original respaldado.

Las tres variantes Dirt se asignan a los tres destinos PATH por decisión explícita del usuario. Se adaptó el canal alfa de cada salida Dirt a la silueta del Path original. El tipo PATH, los sockets, el grafo y las flechas de flujo no cambiaron.

| Asset | Destino runtime | Arte instalado | Original respaldado | Canvas | Modo | Alfa original | Coincide con arte | Nota | Estado |
|---|---|---|---|---:|---|---|---|---|---|
| PATH_01 ← DIRT_01 | `assets/terrain/tiles/path_01.png` | `art_generation/integration/path_01.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/path_01.png` | 180×208 | RGBA | idéntica | idéntico | Dirt aplicado a PATH | OK |
| PATH_02 ← DIRT_02 | `assets/terrain/tiles/path_02.png` | `art_generation/integration/path_02.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/path_02.png` | 180×208 | RGBA | idéntica | idéntico | Dirt aplicado a PATH | OK |
| PATH_03 ← DIRT_03 | `assets/terrain/tiles/path_03.png` | `art_generation/integration/path_03.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/path_03.png` | 180×208 | RGBA | idéntica | idéntico | Dirt aplicado a PATH | OK |
| GRASS_01 | `assets/terrain/tiles/grass_01.png` | `art_generation/generated/samples/grass_01.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/grass_01.png` | 180×208 | RGBA | idéntica | idéntico | — | OK |
| GRASS_02 | `assets/terrain/tiles/grass_02.png` | `art_generation/generated/terrain/grass_02.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/grass_02.png` | 180×208 | RGBA | idéntica | idéntico | — | OK |
| GRASS_03 | `assets/terrain/tiles/grass_03.png` | `art_generation/generated/terrain/grass_03.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/grass_03.png` | 180×208 | RGBA | idéntica | idéntico | — | OK |
| MOUNTAIN_01 | `assets/terrain/tiles/mountain_01.png` | `art_generation/generated/samples/mountain_01.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/mountain_01.png` | 180×208 | RGBA | idéntica | idéntico | — | OK |
| MOUNTAIN_02 | `assets/terrain/tiles/mountain_02.png` | `art_generation/generated/terrain/mountain_02.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/mountain_02.png` | 180×208 | RGBA | idéntica | idéntico | — | OK |
| MOUNTAIN_03 | `assets/terrain/tiles/mountain_03.png` | `art_generation/generated/terrain/mountain_03.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/tiles/mountain_03.png` | 180×208 | RGBA | idéntica | idéntico | — | OK |
| OBSTACLE_CRYSTAL | `assets/terrain/obstacles/crystal_shard.png` | `art_generation/generated/obstacles/crystal.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/obstacles/crystal_shard.png` | 208×208 | RGBA | idéntica | idéntico | — | OK |
| OBSTACLE_ROCK | `assets/terrain/obstacles/rock.png` | `art_generation/generated/samples/rock.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/obstacles/rock.png` | 208×208 | RGBA | idéntica | idéntico | — | OK |
| OBSTACLE_GRASS | `assets/terrain/obstacles/tall_grass.png` | `art_generation/generated/obstacles/grass.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/obstacles/tall_grass.png` | 208×208 | RGBA | idéntica | idéntico | — | OK |
| OBSTACLE_TOTEM | `assets/terrain/obstacles/totem.png` | `art_generation/generated/obstacles/totem.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/obstacles/totem.png` | 208×208 | RGBA | idéntica | idéntico | — | OK |
| OBSTACLE_BONES | `assets/terrain/obstacles/stone_pile.png` | `art_generation/generated/obstacles/bones.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/obstacles/stone_pile.png` | 208×208 | RGBA | idéntica | idéntico | — | OK |
| BASE | `assets/base/main_tower.png` | `art_generation/generated/structures/base.png` | `art_generation/originals_replaced/2026-10-13/assets/base/main_tower.png` | 352×352 | RGBA | idéntica | idéntico | — | OK |
| SPAWN_PORTAL | `assets/terrain/spawn_portal.png` | `art_generation/generated/structures/spawn_portal.png` | `art_generation/originals_replaced/2026-10-13/assets/terrain/spawn_portal.png` | 1024×1536 | RGBA | idéntica | idéntico | — | OK |
| TOWER_BALLISTA | `game/ui/icons/ballista.png` | `art_generation/generated/samples/ballista.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/ballista.png` | 256×256 | RGBA | idéntica | idéntico | — | OK |
| TOWER_MORTAR | `game/ui/icons/mortar.png` | `art_generation/generated/towers/mortar.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/mortar.png` | 256×256 | RGBA | idéntica | idéntico | — | OK |
| TOWER_TESLA_COIL | `game/ui/icons/tesla_coil.png` | `art_generation/generated/towers/tesla_coil.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/tesla_coil.png` | 256×256 | RGBA | idéntica | idéntico | — | OK |
| TOWER_FROST_KEEP | `game/ui/icons/frost_keep.png` | `art_generation/generated/towers/frost_keep.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/frost_keep.png` | 256×256 | RGBA | idéntica | idéntico | — | OK |
| TOWER_FLAMETHROWER | `game/ui/icons/flame_thrower.png` | `art_generation/generated/towers/flame_thrower.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/flame_thrower.png` | 256×256 | RGBA | idéntica | idéntico | — | OK |
| TOWER_SHREDDER | `game/ui/icons/shredder.png` | `art_generation/generated/towers/shredder.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/shredder.png` | 256×256 | RGBA | idéntica | idéntico | — | OK |
| TOWER_POISON_SPRAYER | `game/ui/icons/poison_sprayer.png` | `art_generation/generated/towers/poison_sprayer.png` | `art_generation/originals_replaced/2026-10-13/game/ui/icons/poison_sprayer.png` | 256×256 | RGBA | idéntica | idéntico | — | OK |

## Revisión visual

La composición estática conjunta permite revisar las superficies, obstáculos, torres, base y portal. No contiene el grafo runtime ni las flechas, que siguen dibujándose desde la lógica existente.

[Abrir la composición conjunta](../previews/full_asset_composition.png). La aceptación artística del conjunto puede revisarse en juego.

Los sprites finales se instalaron en las rutas runtime existentes. Los 23 originales se conservaron en `art_generation/originals_replaced/2026-10-13/`.
