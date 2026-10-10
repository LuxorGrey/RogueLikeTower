# Texturas de terreno

El juego carga cada textura por separado; no lee los atlas durante el render. Las imágenes recortadas conservan alfa, dimensiones uniformes por categoría y rutas estables para facilitar el reemplazo futuro.

| Objeto lógico | Archivos | Tamaño por archivo | Rectángulo de juego |
|---|---|---:|---:|
| Path, Grass, Mountain | `tiles/{path,grass,mountain}_01..03.png` | 180 × 208 px | 90 × 104 px |
| Roca, esquirla, hierba alta, tótem, piedras | `obstacles/{rock,crystal_shard,tall_grass,totem,stone_pile}.png` | 208 × 208 px | 86 × 86 px, centradas y con desplazamiento leve hacia abajo |

La relación fuente/visual es 2:1 a zoom 1×, con filtrado lineal. Las variantes representan las siluetas recortadas del atlas original para que el arte cubra una cara de hexágono de radio 52 px. Los obstáculos se estiran a una caja cuadrada común (incluido el alfa transparente); el rectángulo común se usa tanto en mapa como en cards.

Las fachadas de altura usan `tiles/mountain_cliff_face.png` (roca) y `tiles/grass_cliff_face.png` (césped sobre tierra). Son sprites generados para este proyecto el 2026-10-10, no proceden de los atlas ni de un pack externo. `TerrainPiecePreview` mapea cada textura a un quad cerrado por arista; una elevación equivale a 18 px de profundidad visual, y no cambia el terreno lógico. Se pueden sustituir estos dos PNG sin modificar el renderer.

Los sprites grandes compactados en esta revisión conservan un muestreo de 2× con respecto al rectángulo lógico dibujado:

| Sprite | Dimensión PNG | Dibujo lógico | Peso antes → después |
|---|---:|---:|---:|
| `assets/base/main_tower.png` | 352 × 352 | 176 × 176 | 1.197.753 → 166.204 bytes |
| `spawn_portal.png` | 224 × 336 | 112 × 168 | 1.824.672 → 97.506 bytes |
| `treasure_chest.png` | 168 × 168 | 84 × 84 | 1.720.318 → 48.033 bytes |
| `assets/ui/tower_card_button.png` | 288 × 296 | 144 × 148 | 2.062.883 → 121.551 bytes |

En conjunto pasan de 6.805.626 a 433.294 bytes (−93,6 %). El cofre se ajusta al rectángulo cuadrado que ya se dibuja en el juego, para mantener 2× píxeles en ambos ejes.

## Fuente y regeneración

`terrain_atlas.png` y `obstacles_atlas.png` quedan junto a este README como fuentes editables. El runtime usa los catorce PNG recortados de esos atlas, además de los dos sprites de fachada descritos arriba. `tools/prepare_runtime_art.ps1` recorta nueve terrenos y cinco obstáculos a sus nombres/tamaños anteriores; también deja los cuatro sprites enumerados en ADR-0045 a sus dimensiones de fuente objetivo, así que úsalo con cuidado si vas a sustituir esos PNG.

El visor/editor genera los `.import` locales de los PNG independientes cuando reimporta el proyecto. Las referencias de runtime a imágenes separadas están centralizadas en `game/board/terrain_visual_catalog.gd`.
