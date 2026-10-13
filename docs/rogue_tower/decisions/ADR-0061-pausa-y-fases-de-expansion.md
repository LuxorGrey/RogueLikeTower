# ADR-0061 — Pausa y exclusividad de las fases de expansión

- Estado: decisión aprobada por petición del usuario; código integrado; aceptación interactiva pendiente.
- Fecha: 2026-10-13.
- Contexto: el jugador necesita poder pausar durante la partida, y las fases que esperan una card/pieza de terreno no deben admitir acciones de torres, cofres o inicio de ronda.

## Decisiones

1. `P` y el botón `PauseButton` bajo la barra de vida alternan `SceneTree.paused`. El control de pausa procesa siempre y refleja «Pausar»/«Reanudar» según el estado real.
2. `StartWave` puede recibir clic durante la pausa. Si la fase es `ROUND_PREP` y la ronda es válida, el controlador despeja la pausa antes de iniciar. En `TERRAIN_EXPANSION` y `CARD_OFFER`, el inicio de ronda no está disponible y no elimina la pausa.
3. Durante una oferta o colocación de terreno se bloquean selección/construcción/mejora/demolición de torres, apertura de cofres, controles de depuración y cambio de HUD. Se mantienen selección de card, rotación, colocación, cancelación y pausa.
4. `BuildController` no permite construir ni seleccionar torres durante expansión. `Main` bloquea también los atajos y clics de mundo para que no haya una ruta alternativa de entrada a acciones de torre.
5. El hover de un cofre cerrado activa bote cíclico y contorno/resplandor dorado; el efecto termina al salir del hex o abrir el cofre.

## Consecuencias y aceptación

- Los controles de pausa permanecen visibles bajo la vida y el botón de inicio se vuelve a sincronizar al despausar desde código.
- La oferta de terreno es la única interacción de tablero durante la fase de expansión; pausar sigue permitido en cualquier fase.
- La aceptación manual M25 verifica teclado, botón, inicio de ronda pausada, exclusividad de fases y ciclo de hover del cofre.

## Fuentes y ADR relacionados

- Solicitud del usuario de 2026-10-13 sobre pausa, inicio de ronda y restricción de acciones durante selección de terreno.
- El efecto de cofre complementa [ADR-0040](ADR-0040-terreno-obstaculos-cofres-y-feedback.md); se documenta en [GDD](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md).
