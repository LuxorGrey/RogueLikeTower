# ADR-0013: chunks lógicos y terreno isométrico

- **Estado:** Aceptada por instrucción explícita del usuario.
- **Fecha:** 2026-10-07.
- **Fuente de verdad:** [Sistema de losetas isométricas](../sistemas/sistema-losetas-isometricas.md), derivado del DOCX del usuario.
- **Sustituye:** las reglas de creación/representación de terreno de ADR-0009, ADR-0011 y ADR-0012; las reglas de terreno incompatibles de ADR-0001 y ADR-0007.

## Contexto

Las decisiones históricas describían cada loseta como un volumen de 3×3×3 sprites, escenas prefabricadas con lógica implícita en sus nodos, nombres de PNG obsoletos y reglas de ciudad/montaña/monasterio. El usuario entregó una especificación de sistema más reciente y pidió que fuera la verdad absoluta para crear terreno. Esta especificación define un chunk lógico 3×3 con datos y representación separados.

## Decisión

- El mapa se compone de chunks; cada chunk es exactamente una cuadrícula de 3×3 `CellData`.
- Los terrenos base son `PATH`, `GRASS` y `STONE`. PATH es transitable/no construible/altura 0; GRASS es construible/altura 0; STONE es construible/altura 1 con bonificación configurable de alcance (1.15 inicial, pendiente de balance).
- `ChunkDefinition` es un Resource de datos con nueve celdas y cuatro puertos centrales cardinales. Se validan todos los vecinos, y una celda lógica independiente alimenta pathfinding y construcción.
- `TileMapLayer` es vista. No se usa textura, nombre de sprite ni píxel para decidir terreno, paso o construcción. Las variantes visuales se resuelven por semilla y coordenada de modo determinista.
- PATH forma el grafo de rutas. Una colocación con camino se valida contra el mapa/ruta antes de confirmarse.
- Godot presenta el mundo en 2D isométrico fijo 2:1. TileSet/TileMapLayer configura cuadrícula, región, origen y orden visual según las APIs de Godot 4.7.
- La escena principal de prueba muestra una loseta ya formada al pulsar Play. La edición de recursos puede hacerse en el editor; no hace falta un constructor dentro de la partida.

## Consecuencias

- La cuadrícula de nueve celdas también ofrece ubicaciones lógicas de construcción, condicionadas por tipo y ocupación.
- Dejan de aplicar para creación de terreno el volumen 3×3×3, la composición obligatoria de 27 Sprite2D, el antiguo camino `path_variant_1`, el bloque `dirt`, la escalera y las reglas de elevación/monasterio derivadas de la ficción antigua.
- Se conserva la proyección 2:1 y el uso del arte CellTile compatible disponible, sujeto a confirmar licencia antes de distribuirlo en builds.
- La escena visible es una demostración del render y los datos, no una definición de autoridad para los tipos ni conectores.
- La implementación y los criterios de aceptación viven en el documento del sistema; los ADR y el GDD enlazan a esa fuente para evitar divergencia.

## Fuentes

- Usuario, *Especificacion_Sistema_Losetas_Isometricas_Tower_Defense_Godot.docx*, adjunto el 2026-10-07.
- Godot 4.7, documentación oficial TileSet/TileSetAtlasSource/TileData enlazada en el documento de sistema, consultada el 2026-10-07.
