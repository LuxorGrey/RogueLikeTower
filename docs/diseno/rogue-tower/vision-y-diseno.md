# Rogue Tower (nombre provisional): visión y diseño

> Documento vivo. Las reglas del terreno se mantienen en un documento fuente, enlazado aquí para evitar copias divergentes. Las decisiones explícitas del usuario prevalecen sobre los sistemas de referencia.

## Resumen

Roguelite de defensa de torres basado en *Rogue Tower*: el jugador prepara defensas, amplía y organiza el mapa, y sobrevive a oleadas automáticas. La colocación de chunks y sus rutas es una adaptación propia. Godot 4.7, presentación 2D isométrica fija 2:1.

## Fuente de verdad del terreno

La creación de terreno se define íntegramente en [Sistema de losetas isométricas](sistemas/sistema-losetas-isometricas.md), adoptado de la especificación DOCX del usuario y registrado en [ADR-0013](decisiones/ADR-0013-sistema-de-losetas-isometricas.md). Resumen:

- Un chunk contiene una cuadrícula lógica exacta de 3×3 celdas. No es un volumen de 3×3×3 sprites.
- Tipos: `PATH` (altura 0, transitable, no construible), `GRASS` (altura 0, construible) y `STONE` (altura 1, construible, multiplicador inicial/configurable de alcance 1.15).
- `ChunkDefinition` aporta nueve datos de celda y puertos N/E/S/W; la colocación valida cada vecino.
- `TileMapLayer` solo dibuja. Pathfinding, ocupación y construcción usan datos lógicos.
- Variantes visuales se seleccionan de forma determinista a partir de semilla y coordenadas.

Los documentos anteriores describían CellTile 3×3×3, piezas prefabricadas como escenas autoritativas y reglas de ciudad/montaña/monasterio. Esas reglas de creación de terreno están sustituidas. La proyección isométrica fija 2:1 permanece vigente. Las letras A–Y siguen como referencia topológica/visual hasta que sus datos propios estén vectorizados.

## Intención de diseño

Cada expansión debe mostrar claramente dos decisiones: cómo encaja la topología y dónde quedan las superficies para colocar defensas. Antes de confirmar, el jugador debe entender puertos incompatibles y efecto en PATH. Las ofertas deben permitir expansiones legales.

## Bucle de partida

Durante preparación, el jugador expande el mapa, construye/mejora defensas y administra recursos. Al iniciar la oleada, las construcciones se bloquean; los enemigos recorren rutas calculadas y las defensas actúan automáticamente. Al terminar, se liquidan recompensas y elecciones antes de la siguiente preparación.

## Duración y victoria

- Campaña objetivo de 20 rondas; mini-jefes en 5, 10 y 15; victoria al derrotar al jefe de la 20.
- Duración objetivo: 30–45 minutos.
- La base empieza con 20 de integridad. Una fuga normal quita 1 y la fuga de un jefe es letal; llegar a cero termina la partida.

## Topología de mapa

La cuadrícula de chunks es ortogonal; las piezas pueden girarse en cuartos de vuelta y no se reflejan. Cada lado se conecta según los puertos explícitos de la definición. PATH constituye el grafo de movimiento; el arte no crea caminos. Los detalles históricos de campamentos, monasterios y patrones A–Y requieren una adaptación específica antes de incorporarlos a reglas actuales.

Los enemigos usan reglas de ruta deterministas. La propuesta de balance favorece recorridos cortos para rápidos y largos para pesados/jefes. Esta pauta se conserva separada de la definición visual del terreno.

## Defensas, recursos y cartas

Se construye y mejora solo durante preparación. Cada celda GRASS/STONE libre es construible; PATH y ocupación bloquean. STONE da una bonificación de alcance inicial configurable, sin apilar el antiguo bono de daño por nivel de montaña. Oro y maná son recursos distintos; XP alimenta metaprogresión. Las cartas entre oleadas y recompensas de jefe toman el baseline de *Rogue Tower*. Costes, frecuencias y balances siguen pendientes.

## Presentación

La vista es 2D isométrica fija 2:1. TileMapLayer dibuja terreno desde el modelo lógico. La región, el punto de apoyo, altura y orden por profundidad deben ajustarse a los PNG realmente usados; sus dimensiones no se fuerzan a un lienzo universal. No se deducen reglas ni colisiones de los píxeles.

## Primera beta

La beta conserva veinte rondas y todas las familias de sistemas previstas (mapa/rutas, combate, defensas, oro/maná, cartas, edificios, estados, jefes y metaprogresión) con un catálogo compacto.

## Registro de decisiones

| ID | Regla | Estado |
|---|---|---|
| D-001 | Gameplay general toma *Rogue Tower* como baseline; las excepciones expresas del usuario prevalecen | ADR-0006 |
| D-002 | 20 rondas, mini-jefes 5/10/15 y jefe final 20 | Confirmada |
| D-003 | Oro y maná separados; XP para metaprogresión | ADR-0008; cifras abiertas |
| D-004 | Beta compacta conserva todas las familias de sistemas | ADR-0010 |
| D-005 | Presentación fija 2D isométrica 2:1 | ADR-0009, vigente solo en esa parte |
| D-006 | Chunk de nueve celdas con PATH/GRASS/STONE, puertos y datos separados de TileMapLayer | ADR-0013; regla de terreno vigente |
| D-007 | Stone con alcance configurable, 1.15 como valor inicial | ADR-0013; balance abierto |

## Preguntas abiertas

Persisten: balance del alcance Stone; catálogo/vectorización A–Y; la oferta/inicio de campaña; economía, cartas, roster y metaprogresión; licencia de los assets antes de distribuirlos. Ver [preguntas abiertas](../../OPEN_QUESTIONS.md).
