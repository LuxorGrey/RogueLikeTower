# ADR-0056: Sombras pixel art proyectadas en 2D

- Fecha: 2026-10-10.
- Estado: implementación integrada en la rama `Pixel-Change`; aceptación visual/manual pendiente.
- Contexto relacionado: [ADR-0041](ADR-0041-occlusion-arte-terreno-y-flujo-de-rutas.md), [ADR-0043](ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md), [ADR-0053](ADR-0053-interfaz-plana-y-feedback-contextual.md) y [ADR-0055](ADR-0055-assets-pixel-art-nativo-y-muestreo-nearest.md).
- Sustituye: ninguna decisión anterior.

## Contexto

El usuario pidió sombras animadas coherentes con el pixel art, que comuniquen tanto la forma de los objetos como su altura y respeten la cámara cenital proyectada/isométrica. El juego es 2D: su altura lógica va de 0 a 2 y se representa desplazando la superficie 18 px por nivel. No usa meshes 3D para el tablero y el HUD vigente debe seguir plano.

## Decisiones

1. `PixelShadow2D` reutiliza la textura de cada objeto y calcula una caja alfa visible para alinear la sombra con el apoyo real, no con el rectángulo transparente completo del PNG. Un shader `CanvasItem` convierte esa alfa en una silueta azul carbón uniforme, unshaded y sin blur; la interpolación continúa en nearest.
2. La sombra se aplasta sobre el plano XY y comparte una dirección de luz de pantalla que rota despacio. Cada caster permanece unido a su entidad y conserva su orden de mundo/Y-sort. No se añaden luces ni geometría 3D, un pase de pantalla, outlines ni paneles de HUD.
3. Base, torres, enemigos, obstáculos y cofres reciben sombras derivadas de su propio sprite. La longitud parte de la altura visual configurada, aumenta 8 px por nivel de elevación y, durante el salto reactivo de un enemigo, crece con su altura temporal; en ese salto la silueta también se aplasta un poco más.
4. Los portales emisivos no reciben sombra de objeto: son aberturas luminosas en el terreno y no una unidad elevada. La interfaz, proyectiles y cursores tampoco reciben sombras en esta iteración para conservar legibilidad y jerarquía.
5. Las fuentes originales siguen siendo la autoridad del arte. La sombra es una capa de presentación reutilizable y no modifica el PNG, el balance, la elevación lógica, las reglas de oclusión ni la selección.

## Consecuencias

- El jugador distingue mejor el contacto con el suelo y percibe movimiento/altura en el tablero, sin convertir el plano 2D en una escena 3D.
- El shader solo cambia el color de los píxeles opacos; rotación, aplastamiento y desplazamiento usan el transform del CanvasItem. La caja alfa por textura se cachea para no volver a leer cada sprite por cada enemigo.
- La rotación del sprite con muestreo nearest produce escalones intencionales en el borde. Hay que inspeccionarla en movimiento y con el zoom del juego; no se debe suavizar con un filtro lineal.
- La dirección usa tiempo de motor y gira en el espacio 2D proyectado. Es un efecto visual, no una simulación física de luz o una sombra que siga obstáculos/oclusiones de forma volumétrica.

## Verificación

- La escena principal arrancó en Godot 4.7 sin errores de parseo, carga de recursos o compilación del shader. Se mantienen tres avisos no relacionados que ya existían en `wave_director.gd` y `main.gd`.
- Queda pendiente la revisión visual/manual M26 de [Aceptación](../design/10_ACCEPTANCE_TESTS.md), especialmente silueta, oclusión, elevaciones 0/1/2 y salto de enemigo. No se ha cambiado el tamaño o disposición de los paneles.

## Referencias

- Godot Engine 4.7, [CanvasItem shaders](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/canvas_item_shader.html), consultado el 2026-10-10.
- Godot Engine 4.7, [CanvasItem: show_behind_parent y orden de dibujo 2D](https://docs.godotengine.org/en/4.7/classes/class_canvasitem.html), consultado el 2026-10-10.
- Godot Engine 4.7, [GDScript: variables estáticas](https://docs.godotengine.org/en/4.7/tutorials/scripting/gdscript/gdscript_basics.html#static-variables), consultado el 2026-10-10.
