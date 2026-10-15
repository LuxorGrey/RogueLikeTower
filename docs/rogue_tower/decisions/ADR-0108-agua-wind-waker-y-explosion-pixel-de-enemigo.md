# ADR-0108: Agua Wind Waker y explosión pixel de enemigo

- **Estado:** aceptado e implementado en código; aceptación visual y revisión de rendimiento pendientes.
- **Fecha:** 2026-10-15.
- **Contexto:** el fondo oscuro de M56 no se parecía a la imagen de agua suministrada. La muerte de enemigos solo mostraba `coins_top`; el usuario pidió que el sprite se descompusiera en píxeles con el shader enlazado.

## Decisiones

1. `WaterBackgroundLayer` conserva `CanvasLayer -10`, bajo mundo, efectos y HUD. Su shader usa la composición de agua animada de Wind Waker con espuma casi blanca, masas azules redondeadas, patrón de escala grande y desplazamiento lento. Es un fondo visual de pantalla y no afecta a terreno, selección ni reglas de juego.
2. Al producirse una baja final, `WaveDirector` emite la instancia de `Enemy` a su listener local en `Main`. Antes de liberar al enemigo, `Main` obtiene una instantánea de su sprite dibujado: textura, frame, orientación horizontal, modulación y escala efectiva, además de la posición visual que incluye salto y offset artístico.
3. `EnemyDeathParticlePool.emit_death_particles_at(coords, sprite)` configura una `GPUParticles2D` one-shot con `amount = texture.width × texture.height`, muestreo nearest del frame indicado, escala del sprite y orientación espejada. Los emisores se reutilizan después de terminar; cada instancia duplica su material para que bajas simultáneas no compartan parámetros de textura.
4. El estallido se crea en `FeedbackVfxLayer` 130, con coordenadas locales del emisor, para que siga anclado a la posición del mundo durante paneo/zoom. Procesa `ALWAYS` y queda visible al abrir cards o terreno. La explosión de píxeles complementa `coins_top`; no lo reemplaza.
5. Las duraciones, velocidades y escala aleatoria del shader de partículas son parámetros visuales configurables. El número de partículas sigue la resolución de la textura de origen, tal como pidió el usuario; el pool evita recrear emisores en cada baja.

## Consecuencias

- El fondo actual es brillante y de alto contraste con grandes manchas animadas; sustituye la paleta oscura provisional de M56.
- La muerte reproduce la apariencia y el tamaño del sprite visible, incluso cuando el enemigo va espejado o está en el punto alto de un salto.
- El `coins_top` anterior y las recompensas de baja continúan ejecutándose una sola vez por muerte final.
- Falta comprobar visualmente la escala de las gotas/píxeles, el aspecto del fondo a distintas resoluciones y la carga de GPU en oleadas con bajas simultáneas.

## Referencias

- Petición e imagen de referencia del usuario, shader pegado y configuración solicitada para `emit_death_particles_at`, 2026-10-15.
- [Wind Waker 2D Water Shader (Godot 4)](https://godotshaders.com/shader/wind-waker-2d-water-shader-godot-4/), Godot Shaders; snippet CC0, consultado el 2026-10-15.
- [Improved Sprite Pixel Explosion Shader](https://godotshaders.com/shader/improved-sprite-pixel-explosion-shader/), Mopifish / m o r b o; shader Godot 4.7.1 y código CC0, consultado el 2026-10-15.
- [VFX anclados al mundo](ADR-0106-vfx-de-evento-anclados-al-mundo-durante-el-paneo.md), [combate](../design/06_COMBAT_SYSTEM.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md).

## Extiende y sustituye

- Extiende ADR-0101 y ADR-0106 para añadir el burst de píxeles al evento de baja, conservando las capas y el anclaje de los VFX de juego.
- Sustituye únicamente la paleta y presentación del agua del punto 8 de ADR-0107; conserva su posición en `CanvasLayer -10`.
