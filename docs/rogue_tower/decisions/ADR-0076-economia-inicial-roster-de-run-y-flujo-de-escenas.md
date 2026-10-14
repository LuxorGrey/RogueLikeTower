# ADR-0076: Oro inicial, reclutamiento de torres y flujo de run

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código integrado, aceptación interactiva pendiente.
- Actualiza la implementación de economía y tienda de [ADR-0022](ADR-0022-meta-progression-y-guardado.md) y el roster inicial de [ADR-0069](ADR-0069-desbloqueos-xp-y-feedback-de-altura.md).

## Contexto

El roster persistente y el roster disponible para construir durante una run son conceptos distintos. La campaña también necesita una entrada de menú, pausa y retorno consistentes, junto a un resumen breve al terminar.

## Decisiones

1. Una run nueva inicia con 1.000 Gold. Starting Coffers añade 100 Gold por nivel, hasta diez niveles y un máximo de 2.000 Gold. El Gold sigue siendo temporal de run.
2. El roster construible al comenzar una run contiene únicamente Ballista. Mortar y Tesla Coil están desbloqueadas inicialmente y aparecen como cartas de reclutamiento en la primera oferta programada; torres que se desbloqueen de forma permanente podrán aparecer como reclutamientos en runs posteriores. Reclutar añade esa torre al roster de la run; no reclutarla impide construirla aunque tenga atajo.
3. La oferta de reclutamiento sigue el calendario general de cards, tras las expansiones de terreno de las rondas 3, 6, …, 42. Los filtros de cartas específicas respetan las torres ya reclutadas.
4. El menú principal, la partida y la pausa usan escenas distintas. El menú ofrece iniciar run y abrir la tienda. Tras victoria o derrota, el resultado vuelve al menú con la tienda abierta. Escape abre la pausa; desde allí se reanuda o se vuelve al menú. Volver al menú desde pausa abandona la run sin recompensa de derrota.
5. Game Over muestra un resumen compacto por tipo de torre con cantidad construida y daño acumulado. Solo se muestran tipos desbloqueados de forma permanente.

## Consecuencias

- `RunManager` conserva roster, construcciones y daño atribuido por tipo durante la run; `RunEconomyData` define el saldo inicial y Starting Coffers aporta el bonus persistente.
- El estado de victoria/derrota se conserva al cambiar a la escena de menú para presentar el resumen y abrir la tienda. Abandonar desde pausa limpia el estado temporal sin sumar recompensa ni contar la run como completada.
- La aceptación de saldo, reclutamiento, pausa, derrota y resumen está pendiente en M35 de `10_ACCEPTANCE_TESTS.md`.

## Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño activo](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [progresión](../design/07_ROGUELIKE_PROGRESSION.md) y [progreso](../design/09_PROGRESS.md), consultados el 2026-10-14.
