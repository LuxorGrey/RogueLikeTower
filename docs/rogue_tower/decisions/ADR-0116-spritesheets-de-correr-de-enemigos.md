# ADR-0116: Spritesheets de correr de enemigos

- Estado: aceptado por petición explícita del usuario; integración de arte completada, aceptación visual pendiente.
- Fecha: 2026-10-15.
- Sustituye: el arte estático anterior de los 26 enemigos canónicos.
- Fuentes: 26 imágenes PNG proporcionadas por el usuario en `assets/sprites/enemies/new/`; identidades del roster confirmadas en su mensaje del 2026-10-15.

## Contexto

El juego necesita mostrar a todos los enemigos con su ciclo de correr desde que aparecen en el camino. Los nuevos archivos contienen cuatro poses por personaje en una cuadrícula 2×2. `EnemyData` ya reconoce una hoja horizontal de cuatro cuadros y `Enemy` ya los recorre a 8 FPS durante el estado `MOVING`.

## Decisiones

1. Sustituir el contenido de los 26 PNG de `assets/sprites/enemies/` por hojas de 512×128 px con cuatro cuadros de 128×128 px, transparencia, base común y escala uniforme por personaje.
2. Mantener los nombres y rutas canónicos que ya leen los `EnemyData`; así las 26 hojas quedan conectadas directamente a campaña, retratos y visuales de enemigos.
3. Conservar intactos los PNG fuente 1254×1254 en `assets/sprites/enemies/new/` como material de origen, sin cargarlos desde runtime.
4. Mantener el arte orientado a la derecha y usar el espejo horizontal que ya aplica `Enemy` cuando la ruta avanza hacia la izquierda.
5. Mantener los valores existentes de `sprite_extent` por enemigo y la cadencia de animación de 8 FPS. Son decisiones de presentación configurables, no cambios de balance.
6. Mantener la animación activa mientras el enemigo está en `MOVING`, incluido desde el primer momento tras `configure()`; las fases de derrota o llegada al portal no reproducen la carrera.

## Consecuencias

- Los 26 recursos canónicos muestran animación de cuatro cuadros sin cambios en los datos de combate, velocidad o composición de oleadas.
- Cada frame tiene lienzo idéntico y el personaje se centra y alinea con una base común para evitar saltos de tamaño y posición entre poses.
- La reimportación de texturas y la aceptación visual/interactiva en ventana Godot siguen pendientes; no se ejecutaron pruebas en esta actualización.

## Mapeo de entrada

Según el orden de la lámina de contacto indicado por el usuario, de izquierda a derecha y de arriba abajo:

| Índice fuente | EnemyData / archivo de salida |
|---:|---|
| 1 | `tetrahedron` |
| 2 | `hexahedron` |
| 3 | `octahedron` |
| 4 | `dodecahedron` |
| 5 | `icosahedron` |
| 6 | `oogiehedron` |
| 7 | `vampire` |
| 8 | `jack_o_lantern` |
| 9 | `werewolf` |
| 10 | `oogie_von_oogovich_haunted` |
| 11 | `imp` |
| 12 | `blink_dog` |
| 13 | `demon` |
| 14 | `manticore` |
| 15 | `succubus` |
| 16 | `fallen_oogie` |
| 17 | `goblin` |
| 18 | `orc` |
| 19 | `armored_goblin` |
| 20 | `troll` |
| 21 | `armored_orc` |
| 22 | `battering_ram` |
| 23 | `cyclops` |
| 24 | `oogie` |
| 25 | `witch` |
| 26 | `bat` |
