# Inventario de assets CellTile

Inventario del estado del directorio `assets/CellTile` revisado el 2026-10-07. Este catálogo describe archivos reales; la lógica se asigna mediante definiciones/datos de terreno y no se infiere del PNG durante el juego.

| Prefijo | Archivos presentes | Función visual prevista |
|---|---|---|
| `grass` | `grass1.png`–`grass10.png` | Variantes de césped. `grass1`–`grass7` incluyen laterales de bloque; `grass8`–`grass10` son superficies/detalles sin el mismo volumen lateral. Hay flores y hierba alta entre las variaciones. |
| `path` | `path_1.png`, `path_2.png` | Variantes gráficas para celdas lógicas `PATH`. |
| `stone` | `stone1.png`–`stone4.png` | Variantes de bloque de piedra para celdas `STONE`. |
| Hoja de referencia | `spritesheet_nature-blocks.png` | Hoja de sprites sin mapa de regiones aprobado; no usar posiciones de atlas implícitas. |

En este inventario actual no existen `dirt2.png`, `dirt3.png`, `path_variant_1.png` ni `stair_stone1.png`; documentos y escenas no deben referenciarlos. Las texturas tienen tamaños fuente distintos, por lo que la región, el anclaje y el orden visual se validan según su huella real, sin escalar indiscriminadamente a un lienzo común.

Los PNG proceden del usuario y se mantienen como material del proyecto. La licencia para redistribuirlos en una build todavía debe confirmarse antes de publicar el juego.
