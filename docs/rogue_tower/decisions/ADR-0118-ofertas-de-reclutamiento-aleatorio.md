# ADR-0118 — Reclutamiento garantizado y aleatorio en las ofertas

- Fecha: 2026-10-15.
- Estado: integrado en código y documentación; aceptación interactiva pendiente.
- Decisiones relacionadas: ADR-0062 define el catálogo y filtros de cards; ADR-0076 fija el roster de run; ADR-0093 conserva exactamente tres opciones.

## Contexto

`RunCardService` insertaba primero todos los reclutamientos elegibles y podía llenar con ellos los tres espacios. El jugador necesita poder reclutar una torre cuando tenga una disponible, pero las otras opciones deben seguir permitiendo mejoras globales y pasivas de torres que ya forman parte de la run.

## Decisiones

1. Mantener las ofertas programadas en exactamente tres cartas distintas.
2. Cuando haya al menos una torre desbloqueada que aún no se haya reclutado, seleccionar por peso y garantizar un reclutamiento en la oferta.
3. Sortear por peso y sin reemplazo los espacios restantes entre todas las cartas elegibles, incluidos otros reclutamientos. Limitar a dos el número total de reclutamientos de una oferta.
4. Mantener los filtros actuales de unlock permanente, roster de run para pasivas específicas, prerequisitos, peso y máximo por run. Las cartas de reclutamiento no elegidas continúan disponibles en futuras ofertas.
5. Si no hay reclutamientos elegibles, sortear los tres espacios normalmente entre las cartas elegibles.

## Consecuencias

- Una oferta con torres pendientes siempre permite incorporar una; nunca queda ocupada por tres reclutamientos.
- Las pasivas globales y las de torres ya reclutadas compiten aleatoriamente por los demás espacios con el resto del pool elegible.
- Los pesos y la semilla de la run siguen controlando el sorteo; no se mutan Resources compartidos.
- La aceptación de la distribución en una partida queda pendiente; no se ejecutó Godot ni se añadió una prueba automatizada en este cambio.

## Implementación

- `game/cards/run_card_service.gd`
- `docs/rogue_tower/design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md`
- `docs/rogue_tower/design/07_ROGUELIKE_PROGRESSION.md`
- `docs/rogue_tower/design/13_CONTENT_ROSTER.md`
- `docs/rogue_tower/design/10_ACCEPTANCE_TESTS.md`
