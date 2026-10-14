# Manifiesto de sustitución de assets

> **Histórico:** describe la instalación del 2026-10-13. Los obstáculos de esa lista fueron sustituidos en M39 y no corresponden al pool activo. Para nombres, dimensiones y rutas vigentes consulta [assets/sprites/terrain/README.md](../assets/sprites/terrain/README.md).

**Estado:** los 23 PNG de este lote ya sustituyeron sus equivalentes runtime. Los 23 originales están respaldados y la validación compara cada destino con su arte asignado y con el canal alfa original. El proyecto no recibió cambios de lógica, escenas ni Resources.

## Decisiones de integración

- No existían texturas ni una categoría runtime Dirt. Por decisión explícita del usuario, Dirt_01/02/03 sustituyen visualmente Path_01/02/03. Solo se adaptó la alfa a la silueta del Path correspondiente; PATH conserva tipo lógico, sockets, grafo y flechas.
- Los PNG se instalaron en las rutas ya cargadas por los sistemas actuales. No se renombraron los destinos ni se añadieron categorías al catálogo.
- Los originales se conservaron en `art_generation/originals_replaced/2026-10-13/`, con su estructura de carpetas original.
- La integración no incorporó assets de terceros. La guía y las salidas están en [dirección artística](style_guide/rogue_tower_art_direction.md), [galería](previews/full_asset_gallery.md) y [composición](previews/full_asset_composition.png).

## Inventario integrado

| Equivalente | Canvas fuente conservado | Uso runtime | Salida instalada | Estado |
|---|---:|---|---|---|
| PATH_01 (arte Dirt_01) | 180×208 RGBA | Tile de terreno; render 90×104 | `integration/path_01.png` | Integrado |
| PATH_02 (arte Dirt_02) | 180×208 RGBA | Tile de terreno; render 90×104 | `integration/path_02.png` | Integrado |
| PATH_03 (arte Dirt_03) | 180×208 RGBA | Tile de terreno; render 90×104 | `integration/path_03.png` | Integrado |
| GRASS_01 | 180×208 RGBA | Tile de terreno; render 90×104 | `generated/samples/grass_01.png` | Integrado |
| GRASS_02 | 180×208 RGBA | Tile de terreno; render 90×104 | `generated/terrain/grass_02.png` | Integrado |
| GRASS_03 | 180×208 RGBA | Tile de terreno; render 90×104 | `generated/terrain/grass_03.png` | Integrado |
| MOUNTAIN_01 | 180×208 RGBA | Tile de terreno; render 90×104 | `generated/samples/mountain_01.png` | Integrado |
| MOUNTAIN_02 | 180×208 RGBA | Tile de terreno; render 90×104 | `generated/terrain/mountain_02.png` | Integrado |
| MOUNTAIN_03 | 180×208 RGBA | Tile de terreno; render 90×104 | `generated/terrain/mountain_03.png` | Integrado |
| OBSTACLE_CRYSTAL | 208×208 RGBA | Sprite transparente; caja común 86×86, Y=+6 | `generated/obstacles/crystal.png` | Integrado |
| OBSTACLE_ROCK | 208×208 RGBA | Sprite transparente; caja común 86×86, Y=+6 | `generated/samples/rock.png` | Integrado |
| OBSTACLE_GRASS | 208×208 RGBA | Sprite transparente; caja común 86×86, Y=+6 | `generated/obstacles/grass.png` | Integrado |
| OBSTACLE_TOTEM | 208×208 RGBA | Sprite transparente; caja común 86×86, Y=+6 | `generated/obstacles/totem.png` | Integrado |
| OBSTACLE_BONES | 208×208 RGBA | Sprite transparente; caja común 86×86, Y=+6 | `generated/obstacles/bones.png` | Integrado |
| BASE | 352×352 RGBA | Base escalada a 176×176; nodo en Y=-12 | `generated/structures/base.png` | Integrado |
| SPAWN_PORTAL | 1024×1536 RGBA | Portal escalado a 64×96; posición Y=-44 | `generated/structures/spawn_portal.png` | Integrado |
| TOWER_BALLISTA | 256×256 RGBA | Icono de torre, normalmente 84×84 | `generated/samples/ballista.png` | Integrado |
| TOWER_MORTAR | 256×256 RGBA | Icono de torre, normalmente 84×84 | `generated/towers/mortar.png` | Integrado |
| TOWER_TESLA_COIL | 256×256 RGBA | Icono de torre, normalmente 84×84 | `generated/towers/tesla_coil.png` | Integrado |
| TOWER_FROST_KEEP | 256×256 RGBA | Icono de torre, normalmente 84×84 | `generated/towers/frost_keep.png` | Integrado |
| TOWER_FLAMETHROWER | 256×256 RGBA | Icono de torre, normalmente 84×84 | `generated/towers/flame_thrower.png` | Integrado |
| TOWER_SHREDDER | 256×256 RGBA | Icono de torre, normalmente 84×84 | `generated/towers/shredder.png` | Integrado |
| TOWER_POISON_SPRAYER | 256×256 RGBA | Icono de torre, normalmente 84×84 | `generated/towers/poison_sprayer.png` | Integrado |

La tabla con las 23 rutas runtime exactas, fuentes artísticas y copias originales está en [mapa de sustitución](replacement_map.md). Los PNG Dirt siguen también en `generated/samples/dirt_01.png` y `generated/terrain/dirt_02.png`, `dirt_03.png` como arte fuente; el export preparado para Path está en `integration/`.

## Encaje y render

- Grass y Mountain conservan el canvas de 180×208 px y se dibujan en el rectángulo 90×104 de la celda. La imagen no define colisión ni construcción.
- Los obstáculos conservan 208×208 px; el renderer los presenta en una caja de 86×86 unidades, centrados en la celda con offset Y=+6. No llevan suelo debajo.
- Los iconos de torre conservan 256×256 px. `Tower.gd` usa el icono de `TowerData`, normalmente a 84×84; el offset visual es +6 respecto al anclaje del nodo.
- La base conserva 352×352 px y usa el escalado actual de `BaseData`.
- El portal conserva 1024×1536 px y la escala/posición definida en la escena actual.
- Los PNG siguen siendo imágenes individuales y mantienen canal alfa. No se cambiaron colisiones, celdas, anchors, Y-sort ni escalas.

## Validación

[Validación final](validation/final_validation.md) confirma canvas, modo RGBA, píxeles instalados idénticos a la salida asignada, canal alfa idéntico al original y presencia de 23 copias. La [validación de muestras](validation/sample_validation.md) registra las cinco muestras revisadas; la [composición conjunta](previews/full_asset_composition.png) muestra la dirección de arte en los tamaños actuales.
