# ADR-0017 — Oferta de terreno y cierre de huecos

- Estado: aceptado para M10, 2026-10-08.
- Contexto: la expansión existente habilitaba la selección directa de cualquier Resource de terreno. El mapa podía conservar vacíos interiores incómodos y el loop no ofrecía una elección acotada después de cada ronda.

## Decisiones

1. Tras las rondas 1–19, `TERRAIN_EXPANSION` ofrece tres `TerrainPieceData` diferentes elegidas sin reemplazo del pool configurado. Son ofertas de expansión, no `CardData` de mejoras M11.
2. Elegir una card fija esa pieza para el ghost de siete hexágonos. La colocación válida continúa exigiendo los contratos actuales de solapamiento, adyacencia y conectividad PATH. `Esc`, clic derecho o el botón de volver abandona el ghost y muestra las mismas tres opciones. Confirmar una pieza válida limpia la oferta y desbloquea una sola ronda. La presentación visual de cards y su inventario inferior se concreta en ADR-0020.
3. Tras construir el tablero candidato, se buscan vacíos dentro de la envolvente axial de sus límites q/r/s. Un vacío solo se rellena si no está conectado a la frontera de esa envolvente ni a una salida PATH explícita que deba seguir funcionando como spawn.
4. Cada vacío interior protegido se convierte al azar, 50/50, en Grass (altura 1) o Montaña (altura 2); la celda es construible y no pertenece a una pieza colocada por el jugador. El relleno se añade al mismo commit lógico que la pieza; se valida el `PathGraph` con el tablero completo antes de aceptarlo.
5. Las opciones de cards se conservan si se ejecuta un fixture DEBUG desde expansión. Un diagnóstico no consume una elección ni adelanta la campaña.

## Consecuencias

- La expansión de terreno requiere seleccionar una de tres opciones y colocarla antes de iniciar la siguiente ronda.
- Las áreas cerradas quedan cubiertas por terreno construible; las aberturas de spawn permanecen vacías para no bloquear rutas.
- Los posibles enemigos siguen viniendo de todos los endpoints PATH activos según ADR-0018.
- La cantidad de opciones (tres), el muestreo uniforme y la mezcla de terrenos de relleno son parámetros provisionales de presentación, no balance final.
- Ver criterios manuales en [M10 de aceptación](../fuente_de_verdad/10_ACCEPTANCE_TESTS.md#prueba-manual-m10-en-el-juego).
