# ADR-0086: Oferta de cards y cierre de derrota

- Fecha: 2026-10-14
- Estado: Correcciones integradas; smokes de UI, M4, M5 y M6 pasan en Godot 4.7. La aceptación interactiva de campaña completa sigue pendiente.
- Relacionado: [M11 Cards](../design/02_IMPLEMENTATION_ROADMAP.md), [M38 fachadas delanteras](ADR-0085-solo-fachadas-delanteras-y-degradado-de-cliffs.md).

## Contexto

Al completar nueve rondas no aparecía la selección de mejoras. El log mostraba `No se pudo crear oferta M11:` sin detalle. `RunCardService` devolvía las tres opciones configuradas correctamente, pero `Main` solo las aceptaba si la lista llenaba las seis ranuras máximas del panel. La comparación confundía el tamaño de la oferta con la capacidad de la interfaz y hacía avanzar la campaña sin elección.

Al perder, `_show_run_end` cambiaba de escena y `_on_wave_failed` continuaba actualizando la colocación en la escena que se desmontaba. El preview consultaba la posición del ratón con su `Viewport` ya desconectado.

## Decisiones

1. La cantidad de cartas se valida contra la capacidad máxima del panel: una oferta válida no vacía de hasta seis opciones se presenta, aunque use menos ranuras. El tamaño por defecto sigue siendo tres y Card Draw puede ampliarlo.
2. La ruta de oferta programada se resuelve antes de preparar la siguiente ronda. Si no se puede crear una oferta válida, se conserva el bloqueo de la ronda y se muestra el motivo; nunca se omite silenciosamente la selección obligatoria.
3. La derrota es terminal para `Main`: después de solicitar el cambio al menú, no se ejecutan actualizaciones de HUD/preview. El preview comprueba que sigue dentro del árbol y tiene un `Viewport` antes de consultar el ratón.
4. El aspecto del terreno de M38 aprobado por el usuario se conserva como referencia visual en ADR-0085; esta corrección no cambia el renderer.

## Consecuencias

- `ui_migration_smoke` comprueba que las ofertas configuradas de tres cartas en las rondas 3, 6 y 9 entran en `CARD_OFFER` y muestran tres cards pese a las seis ranuras disponibles; también llama al preview separado del árbol para cubrir la guarda de `Viewport` nulo.
- Los smokes M4, M5 y M6 se ejecutaron correctamente tras alinear sus expectativas de fase y el límite de mejora de su fixture con el comportamiento vigente.
- La aceptación completa de M11 sigue requiriendo jugar la campaña y comprobar rondas 3, 6, 9 y 42, filtros de cartas y efectos.
- El flujo de derrota deja de llamar al preview tras iniciar el cambio de escena; la guarda del preview también cubre llamadas tardías.

## Referencias

- Reporte de juego del usuario: oferta ausente tras nueve rondas y error de `get_viewport()` al perder, 2026-10-14.
- [Diseño de cartas](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [aceptación M11/M38](../design/10_ACCEPTANCE_TESTS.md), [progreso](../design/09_PROGRESS.md).
