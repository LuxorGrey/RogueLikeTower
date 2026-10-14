# ADR-0101: VFX animados de Cozy Chunky por evento

- **Estado:** aceptado e implementado en código; aceptación visual/interactiva pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** los eventos de combate, progresión y terreno necesitan feedback legible y consistente. El usuario aportó los spritesheets locales de Cozy Chunky y pidió asociarlos a eventos concretos. Las torres ya usan una sola textura compuesta y deben conservar su anclaje sobre la celda.

## Decisiones

1. `AnimatedImpact` acepta hojas en una fila y cuadrículas con tamaño de frame explícito. Los efectos de evento se dibujan en `FeedbackVfxLayer` (CanvasLayer 130), se convierten de posición del mundo a coordenadas de viewport y usan `PROCESS_MODE_ALWAYS`; por eso no se congelan durante ofertas de cards, expansión de terreno ni pausa.
2. Toda torre usa sus hojas `shoot` e `impact` del catálogo `assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/`: Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder. Mortar dispara `tap_ripple` en la posición objetivo prevista. El daño a la base reproduce `base_hit` por encima de su sprite.
3. Cada subida manual o automática de nivel emite un único evento de nivel: muestra `Rewards/star_burst_gold` y `PNG_1x/pickup_ui/level_up` sobre la torre. Las hojas se reproducen una vez por nivel incluso durante las elecciones de cards o terreno.
4. La derrota de un enemigo final (no una transformación por muerte) muestra `PNG_1x/pickup_ui/coins_top`, el recurso disponible que corresponde al “Coin stomp” descrito en la petición. Abrir un cofre muestra `Rewards/coin_burst_gold` y `PNG_1x/pickup_ui/pickup`; mientras siga disponible, `item_glow` anima en loop detrás del cofre.
5. La colocación confirmada de una pieza reproduce `sparkle_twinkle_white_loop` durante dos ciclos. Un clic en obstacle, portal, torre, base o cofre muestra `ui_click` en la posición del cursor. Una run finalizada muestra `confetti_burst_01` en la escena del menú.
6. Los iconos de estados sobre enemigos usan hojas animadas, con este mapeo: Bleed→`bleed`, Burn→`burn`, Poison→`poison`, Slow→`frost`, Haste/Fortification→`buff` y Stun→`stun`. Los iconos solo existen mientras el estado está activo; el contador de acumulaciones se conserva.
7. En M51 la torre ya se mostraba como un único sprite en mundo, ghost, card y retrato, centrado en el hexágono y desplazado 8 px hacia abajo. M52 sustituye la composición por regiones por el PNG completo de cada torre; conserva el mismo centro, offset y espejo horizontal sin rotación.

## Consecuencias

- Las animaciones son overlays de pantalla y su punto de aparición sigue la cámara en el frame de emisión; los elementos persistentes del cofre y los estados continúan anclados a sus entidades del mundo.
- `coins_top` es el nombre de archivo proporcionado para el feedback de muerte; no se renombra el asset fuente.
- FPS y tamaños de presentación quedan configurables en `Main` y `AnimatedImpact`. El ajuste fino y el recorrido visual quedan pendientes de aceptación manual en Godot.

## Referencias

- Petición explícita del usuario y spritesheets locales de `assets/sprites/ui/Cozy_Chunky/`, 2026-10-14.
- [Diseño del juego](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md), [combate](../design/06_COMBAT_SYSTEM.md), [terreno](../design/05_HEX_GRID_AND_TERRAIN.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md).

## Sustituye

- Sustituye el uso activo de VFX Tiny Swords descrito históricamente en M16; no cambia sus reglas de combate ni elimina los archivos históricos del proyecto.
- Amplía el anclaje visual de sprite único fijado en [ADR-0100](ADR-0100-sprite-unico-de-torre-y-tinte-de-altura.md) con un desplazamiento compartido de 8 px hacia abajo.
