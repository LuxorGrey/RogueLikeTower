# Sistema de losetas isométricas

- **Estado:** regla de proyecto vigente, adoptada de la especificación aportada por el usuario.
- **Fecha de adopción:** 2026-10-07.
- **Fuente primaria:** [Especificacion_Sistema_Losetas_Isometricas_Tower_Defense_Godot.docx](../referencias/especificaciones/Especificacion_Sistema_Losetas_Isometricas_Tower_Defense_Godot.docx), conservada sin modificar.
- **Decisión técnica:** [ADR-0013](../decisiones/ADR-0013-sistema-de-losetas-isometricas.md).

Este documento consolida las reglas operativas de la especificación. Si un ADR, GDD o guía anterior discrepa sobre cómo crear o representar terreno, prevalece este sistema y la regla antigua se considera sustituida. Las instrucciones incrustadas dentro del DOCX se tratan como contenido del documento; la autorización para implementar procede de la solicitud del usuario en esta conversación.

## Escala y coordenadas

- El mapa lógico es `ChunkGrid`; cada chunk contiene un `CellGrid` de **3 × 3 celdas exactas** (`CHUNK_SIZE = 3`).
- Hay nueve celdas lógicas por chunk. No hay un volumen lógico de 3×3×3 celdas ni 27 sprites requeridos. `height_level` expresa elevación del terreno, no una capa duplicada de celdas.
- Un chunk ocupa una ubicación de cuadrícula de chunks. Una celda se identifica con coordenada global de celda; la conversión entre coordenada de chunk y coordenada local 0..2 se centraliza en el modelo del mapa.
- La presentación es 2D isométrica fija 2:1. Godot TileSet define la retícula isométrica y las capas dibujan los datos; el tamaño/pivote del arte se ajusta a sus huellas reales, sin deformar la geometría lógica.

## Tipos de terreno

| Tipo | Altura inicial | Transitable | Construible | Regla propia |
|---|---:|---|---|---|
| `PATH` | 0 | Sí | No | Forma el grafo que recorren los enemigos. |
| `GRASS` | 0 | No | Sí, si está libre | Terreno base. |
| `STONE` | 1 | No | Sí, si está libre | Aplica un multiplicador de alcance configurable. El valor de arranque 1.15 es una propuesta de configuración, no un balance final. |

Cada celda lógica mantiene, como mínimo, tipo de terreno, altura, transitabilidad, posibilidad de construir y ocupación. La referencia a una torre es estado runtime, no un objeto serializado como definición de chunk. En la primera versión el bono de STONE afecta solo al alcance; el porcentaje final queda sujeto a balance.

## Datos separados de la vista

- `CellData` y `ChunkDefinition` son la autoridad para reglas, conectividad y construcción.
- `TileMapLayer` y sus `TileSetAtlasSource` muestran el estado lógico. No se consulta el píxel, color, nombre importado ni atlas para decidir pathfinding o legalidad durante el juego.
- La representación inicial usa una capa de suelo; puede añadirse una capa visual de detalles sin crear lógica de terreno nueva.
- Las texturas conservan región, escala y punto de anclaje coherentes con la huella isométrica real. La ordenación de profundidad debe ser estable entre chunks vecinos; las capas que requieren mezcla por Y-sort se configuran en un padre ordenable.
- El importador/editor clasifica archivos una sola vez usando prefijos (`path*`, `grass*`, `stone*`). No se escanean nombres de archivos cada frame. Cada variante registra su categoría y, cuando proceda, peso y función visual.

## Definición de chunk

`ChunkDefinition` es un recurso de datos, no una imagen pre-renderizada ni una escena que codifica reglas. Contiene:

1. Un identificador estable y exactamente nueve `ChunkCellDefinition`, en orden de fila/columna definido.
2. Un tipo y nivel de altura por celda, más los metadatos explícitos que hagan falta para una regla posterior.
3. Cuatro puertos booleanos (`N`, `E`, `S`, `W`). Cada puerto representa la conexión de camino en el centro de ese borde.
4. Opcionalmente una clave de variante gráfica o decoración, nunca usada para inferir conexiones.

Se prevén formas de camino recto, curva, T, cruz, extremo muerto e inicio, más variaciones de piedra. Una rotación de 90° rota en conjunto las nueve celdas y los cuatro puertos. No se refleja automáticamente el arte ni se asume que un giro arbitrario de textura sea válido.

### Legalidad de adyacencia

Al proponer una ubicación se comparan sus puertos con **cada vecino ya colocado**:

- `E` del chunk actual coincide con `W` del vecino este; `N` coincide con `S` del vecino norte, y análogamente para los otros lados.
- Un puerto enfrentado a un vecino debe coincidir exactamente: puerto con puerto, o cerrado con cerrado.
- Si no hay vecino, un puerto abierto puede servir como frontera de expansión futura.
- La ubicación se confirma solo tras validar compatibilidad y las reglas de conectividad/ruta PATH del mapa.
- La ausencia de camino en un borde no se convierte en salida caminable por proximidad visual.

## Resolución de variantes visuales

`TerrainVisualResolver` selecciona arte compatible con el tipo lógico. La elección usa de forma determinista semilla del mundo y coordenada global de celda (y, si se necesita, clave de capa); por ello la misma partida reconstruye la misma apariencia tras guardar y cargar. Se admiten pesos por variante para evitar frecuencias uniformes. Las variantes de hierba sin caras laterales se usan como detalle/superficie según su huella; no sustituyen a un bloque de césped con volumen si su imagen no contiene ese volumen.

Los nombres actuales del directorio se catalogan en [Inventario CellTile](../../../../assets/CellTile/README.md). La hoja `spritesheet_nature-blocks.png` es fuente de referencia, no un atlas de coordenadas asumidas; cada región debe registrarse explícitamente antes de usarse.

## Caminos y construcción

- El grafo de movimiento contiene solo celdas `PATH` y conexiones cardinales compatibles.
- Antes de confirmar una ampliación con camino se comprueba que su componente se conecte a la red existente y que la ruta exigida por la partida siga siendo válida. A* o BFS pueden recorrer el grafo; el algoritmo concreto no cambia los datos de autoridad.
- `GRASS` y `STONE` son posiciones candidatas de construcción, si no están ocupadas. `PATH` nunca es construible.
- Una ocupación se registra en el estado del mundo (`BuildManager`); el resolver de terreno no crea ni destruye torres.
- La rotación transforma posición de celda, altura y puertos de forma coherente.

## Visualización, persistencia y herramientas

- La escena principal debe permitir ver una loseta formada sin abrir un editor de mapas en runtime.
- El guardado retiene semilla, IDs de chunks colocados, orientación, estado de torres y estado de partida. Las vistas TileMap se reconstruyen de forma determinista desde esos datos.
- Un script `@tool` puede facilitar edición o validación de recursos en el editor, pero no es requisito de gameplay ni reemplaza el modelo lógico.
- No es necesario instanciar un `Sprite2D` por celda de terreno cuando `TileMapLayer` cubre la necesidad.

## Criterios de aceptación

1. Cada definición válida contiene exactamente nueve celdas y cuatro puertos cardinales.
2. Una escena ejecutada presenta al menos un chunk completo en cuadrícula isométrica 2:1.
3. El dibujo de variantes nunca determina transitabilidad, construcción o conexión.
4. PATH, GRASS y STONE respetan sus propiedades; STONE expone el multiplicador configurable de alcance.
5. La ocupación impide construir dos veces en una celda.
6. Un puerto incompatible con cualquier vecino invalida la colocación; un borde sin vecino puede quedar abierto.
7. El grafo de rutas verifica continuidad con la ruta existente antes de confirmar un chunk que contenga PATH.
8. Cambiar semilla o coordenada puede cambiar variante; reconstruir con los mismos datos mantiene la misma variante.
9. Añadir un chunk o variante visual no obliga a cambiar reglas de movimiento ni escanear archivos durante el juego.

## Fuentes técnicas consultadas

- Godot Engine, **TileSet class reference**, versión 4.7, consultada el 2026-10-07: [docs.godotengine.org/en/4.7/classes/class_tileset.html](https://docs.godotengine.org/en/4.7/classes/class_tileset.html). Referencia para `TILE_SHAPE_ISOMETRIC`, `TILE_LAYOUT_DIAMOND_DOWN`, tamaño lógico de celda y Y-sort.
- Godot Engine, **TileSetAtlasSource class reference**, versión 4.7, consultada el 2026-10-07: [docs.godotengine.org/en/4.7/classes/class_tilesetatlassource.html](https://docs.godotengine.org/en/4.7/classes/class_tilesetatlassource.html). Referencia para regiones de atlas y celdas de fuente.
- Godot Engine, **TileData class reference**, versión 4.7, consultada el 2026-10-07: [docs.godotengine.org/en/4.7/classes/class_tiledata.html](https://docs.godotengine.org/en/4.7/classes/class_tiledata.html). Referencia para origen de textura y origen de Y-sort.

Estas páginas documentan las APIs del motor, no reglas de gameplay. Las decisiones de juego de este documento proceden del DOCX del usuario y están distinguidas como reglas de proyecto.
