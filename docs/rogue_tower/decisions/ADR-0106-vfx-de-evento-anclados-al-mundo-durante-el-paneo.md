# ADR-0106: VFX de evento anclados al mundo durante el paneo

- **Estado:** aceptado e implementado en código; aceptación visual pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** al emitir VFX de baja, disparo, impacto y otros eventos del juego, `Main` convertía una vez la posición del mundo a coordenadas de viewport. `FeedbackVfxLayer` no seguía la transformación de `Camera2D`, por lo que el efecto quedaba en pantalla mientras el terreno y los actores se desplazaban al paneo.

## Decisiones

1. `FeedbackVfxLayer` conserva su CanvasLayer superior y `PROCESS_MODE_ALWAYS`, pero activa `follow_viewport_enabled` para seguir la transformación de cámara sin perder el orden visual sobre HUD, cards y preview.
2. `Main._spawn_impact_vfx` pasa la posición del mundo directamente a `AnimatedImpact` para los eventos del juego; ya no la convierte a viewport ni compensa manualmente el tamaño por el zoom.
3. Los VFX de juego se dibujan y escalan mediante la transformación de la cámara durante toda su animación. Paneo y zoom los mueven junto con la celda o actor que originó el evento.
4. `ui_click` conserva su semántica de cursor en un CanvasLayer separado sin seguimiento de viewport; por eso permanece sobre el cursor aunque el usuario panee.
5. El glow del cofre y los iconos de estado mantienen su lógica persistente en las entidades del mundo; no se trasladan al overlay de eventos.

## Consecuencias

- Disparos, impactos, bajas, daño a base, cofres, subida de nivel y colocación de terreno permanecen en sus coordenadas de mundo mientras se panea; el marcador `ui_click` sigue al cursor.
- Los efectos siguen mostrándose por encima de la interfaz y siguen animándose durante pausa y selección.
- El tamaño aparente de los efectos responde al zoom como el de cualquier otro objeto del mundo.
- La compilación de escena y la revisión visual/interactiva quedan pendientes; el criterio incluye paneo y zoom mientras cada animación está activa.

## Referencias

- Petición del usuario sobre el anclaje de partículas al mover la cámara, 2026-10-14.
- [Arquitectura técnica](../design/03_TECHNICAL_ARCHITECTURE.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md).

## Corrige

- Corrige el posicionamiento de coordenadas de viewport descrito en [ADR-0101](ADR-0101-vfx-animados-de-cozy-chunky-por-evento.md). Conserva el catálogo de efectos, eventos, capa superior y proceso ALWAYS establecidos por ese ADR.
