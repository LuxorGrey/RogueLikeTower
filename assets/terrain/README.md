# Texturas de terreno

El juego carga cada textura por separado; no lee los atlas durante el render. Las imágenes recortadas conservan alfa, dimensiones uniformes por categoría y rutas estables para facilitar el reemplazo futuro.

| Objeto lógico | Archivos | Tamaño por archivo | Rectángulo de juego |
|---|---|---:|---:|
| Path, Grass, Mountain | `tiles/{path,grass,mountain}_01..03.png` | 180 × 208 px | 90 × 104 px |
| Obstáculos | `obstacles/obstacle_<nombre>.png` (8 sprites) | 208 × 208 px | 86 × 86 px, centradas en la celda |
| Props decorativos | `random_props/{grass,mountain,path}/prop_<terreno>_<nombre>.png` (18 sprites) | 96 × 96 px | 36 × 36 px; hasta dos por celda |

Obstáculos activos: `obstacle_bramble_bush.png`, `obstacle_fallen_log.png`, `obstacle_branch_pile.png`, `obstacle_tree_stump.png`, `obstacle_rock_and_wood.png`, `obstacle_supply_crate.png`, `obstacle_exposed_roots.png` y `obstacle_mossy_rock_cluster.png`.

Props activos por carpeta:
- `grass`: `prop_grass_tuft_small`, `prop_grass_tuft_wide`, `prop_grass_sprout`, `prop_grass_stone_cluster`, `prop_grass_rock`, `prop_grass_mushroom_red`, `prop_grass_mushroom_amber`, `prop_grass_flower_yellow`.
- `mountain`: `prop_mountain_rock_cluster`, `prop_mountain_mossy_rock`, `prop_mountain_tuft_grass`, `prop_mountain_stone_scatter`, `prop_mountain_rock_small`.
- `path`: `prop_path_gold_pebbles`, `prop_path_amber_stones`, `prop_path_dry_grass`, `prop_path_stone_scatter`, `prop_path_sand_pile`.

Las variantes de suelo representan las siluetas recortadas del atlas original para que el arte cubra una cara de hexágono de radio 52 px. Los obstáculos se estiran a una caja cuadrada común (incluido el alfa transparente); el mismo rectángulo centrado se usa en mapa, ghost y cards. Los props conservan el alfa, se recortan al contenido visible y se normalizan a una caja 96×96 antes de dibujarlos a 36×36. Cada asset elegible tiene una probabilidad independiente del 10 % por celda; cada celda conserva un máximo de dos props distintos, con separación suficiente para no solaparse, y el obstáculo queda por delante.

Los portales del mapa usan `spawn_portal_SpriteSheet.png` (1774×887 px), recortado en ocho frames de 443×443 en una cuadrícula 4×2. Cada portal reproduce los ocho frames en bucle continuo a 10 FPS y recibe una fase determinista distinta según el endpoint. `spawn_portal.png` se conserva como icono estático del panel de selección.

Las fachadas de altura usan `tiles/mountain_cliff_face.png` (roca) y `tiles/grass_cliff_face.png` (césped sobre tierra). Son sprites generados para este proyecto el 2026-10-10, no proceden de los atlas ni de un pack externo. `TerrainPiecePreview` mapea cada textura a uno de los dos quads delanteros por celda; una elevación equivale a 28 px de profundidad visual, y no cambia el terreno lógico. Solo las fachadas reciben el degradado inferior oscuro; las tapas conservan su textura. Se pueden sustituir estos dos PNG sin modificar el renderer.

Dimensiones fuente y tamaño de representación en runtime:

| Sprite | Dimensión PNG | Dibujo lógico |
|---|---:|---:|
| `assets/base/main_tower.png` | 270 × 352 | 66 × 86 dentro de una caja uniforme de 86 × 86; PNG intacto |
| `spawn_portal_SpriteSheet.png` | 1774 × 887 | 8 frames de 443 × 443; cada portal se dibuja a 96 × 96 |
| `spawn_portal.png` | 293 × 292 | Icono estático del panel de selección |
| `treasure_chest.png` | 168 × 168 | 84 × 84 |
| `assets/ui/tower_card_button.png` | 288 × 296 | 144 × 148 |

El sprite de Main Tower conserva su resolución PNG y se escala uniformemente para caber dentro de un hexágono. El cofre se ajusta al rectángulo cuadrado que ya se dibuja en el juego, para mantener 2× píxeles en ambos ejes.

## Fuente y regeneración

`terrain_atlas.png` queda como fuente editable de las nueve variantes de terreno. `obstacles_atlas.png` se conserva solo como material histórico de las ilustraciones sustituidas; el runtime usa los ocho PNG nuevos nombrados de forma uniforme y los 18 props normalizados, además de los dos sprites de fachada descritos arriba. `tools/prepare_runtime_art.ps1` solo vuelve a exportar las nueve variantes de suelo y ajusta los cuatro sprites enumerados en ADR-0045; no recrea ni sobrescribe los obstáculos actuales.

El visor/editor genera los `.import` locales de los PNG independientes cuando reimporta el proyecto. Las referencias de runtime a imágenes separadas están centralizadas en `game/board/terrain_visual_catalog.gd`.
