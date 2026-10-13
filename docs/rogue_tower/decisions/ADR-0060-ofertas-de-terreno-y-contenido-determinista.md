# ADR-0060 — Ofertas de terreno variables y contenido visual determinista

- Estado: decisión aprobada por petición del usuario; código integrado; aceptación interactiva pendiente.
- Fecha: 2026-10-13.
- Contexto: una oferta siempre mostraba una pieza recta `ALARGA CAMINO`, incluso cuando el jugador podía tomar una ruta distinta. Además, las cards generaban props ilustrativos por separado del roll aplicado al colocar, por lo que la miniatura y el tablero podían discrepar.

## Decisiones

1. La oferta conserva al menos una colocación real que puede prolongar una ruta alcanzable y deja otra continuación legal. La búsqueda prueba geometrías, anclas y rotaciones del catálogo con orden aleatorio de run, por lo que la pieza marcada `EXTIENDE RUTA` puede ser recta, curva o bifurcada.
2. Si la pieza sugerida de continuidad no es recta, las otras dos opciones excluyen la recta. Así hay ofertas donde el jugador no puede elegir un camino recto. La ubicación y orientación válidas se preseleccionan como sugerencia; otras cards siguen disponibles si su colocación respeta las reglas y conserva una expansión legal posterior.
3. Las piezas de una oferta son copias runtime de los Resources de catálogo. `TerrainVisualCatalog` asigna obstáculos/cofres a las celdas locales de cada copia usando seed, ronda/índice de oferta, ID de pieza y coordenada local. La copia original compartida nunca se modifica.
4. La card dibuja esos datos fijados. El ghost de colocación y la pieza confirmada trasladan las mismas celdas al tablero, rotando junto con el terreno. Al cancelar o volver a la oferta no se vuelven a tirar obstáculos/cofres. Al confirmar, solo se calcula la variante del suelo según la coordenada axial final; no se sobrescribe el contenido de la oferta.
5. Se mantienen las tasas configurables vigentes: Grass 25 % para obstáculos, Mountain 15 %, cinco tipos de obstáculo y cofres en celdas sin obstáculo con la probabilidad de run/meta-progresión.

## Consecuencias y aceptación

- La regla de continuidad de ADR-0057 sigue vigente, pero ya no reserva siempre la pieza recta ni etiqueta la card como `ALARGA CAMINO`.
- Una expansión que no deje una opción posterior para extender una ruta sigue siendo inválida; los spawns que se cierran siguen visibles y contados antes de confirmar.
- La prueba manual M10/M14 debe comparar miniatura, ghost rotado y tablero confirmado, además de completar ofertas sin recta y verificar que el ghost mantiene las tiradas tras cancelar.
- El cambio se integra en los docs activos de [diseño](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [terreno](../design/05_HEX_GRID_AND_TERRAIN.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md).

## Fuentes y ADR relacionados

- Solicitud del usuario de 2026-10-13: la oferta no debe asegurar siempre un camino recto y el contenido de la card debe coincidir con lo que se coloca.
- Actualiza parcialmente [ADR-0057](ADR-0057-expansion-con-prolongacion-garantizada.md); mantiene la validación de continuidad y el aviso previo de cierre de spawns.
