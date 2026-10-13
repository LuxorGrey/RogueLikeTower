# ADR-0054: Prueba visual pixel art de 32 px

- Fecha: 2026-10-10.
- Estado: histórico y superado por [ADR-0055](ADR-0055-assets-pixel-art-nativo-y-muestreo-nearest.md). El shader de pantalla descrito aquí se retiró.
- Contexto relacionado: [ADR-0031](ADR-0031-png-individuales-por-objeto.md), [ADR-0041](ADR-0041-occlusion-arte-terreno-y-flujo-de-rutas.md), [ADR-0049](ADR-0049-arquitectura-hibrida-ui-editable.md) y [ADR-0053](ADR-0053-interfaz-plana-y-feedback-contextual.md).
- Sustituye: nada.

## Contexto

Se solicitó probar cómo se leería Rogue Tower si el juego completo adoptara una estética pixel art de 32 × 32 px. La petición es una comparación visual rápida sobre una rama temporal, no una decisión que cambie la fantasía visual confirmada ni un encargo para reemplazar el arte fuente.

## Decisiones históricas

1. La escena principal añade una única capa `CanvasLayer` con un shader de lectura de pantalla. Cuantiza la imagen completa sobre una cuadrícula de muestreo de 32 px para un sprite de referencia de 72 unidades lógicas (el tamaño habitual de los enemigos).
2. El pase incluye mundo, torres, enemigos, terreno, VFX y HUD. El overlay ignora el ratón, no cubre las entradas y no crea un panel ni un menú.
3. El filtro global de texturas pasa a nearest y se activa el ajuste de vértices y transformaciones 2D a píxeles para que la prueba conserve bordes y coordenadas nítidos.
4. Los PNG originales no se reescalan ni se reemplazan; no se descartan fuentes editables y el cambio se puede retirar eliminando el nodo de pase y restaurando los tres ajustes gráficos.
5. La interfaz y sus dimensiones permanecen intactas. El coste visual esperado es que textos pequeños y gradientes se vean más gruesos por el muestreo compartido de pantalla.
6. Este efecto aproxima una lectura pixelada de 32 muestras sobre el sprite de referencia; no equivale a redibujar cada sprite a mano en una cuadrícula de 32 × 32 ni a adoptar una paleta pixel-art final.

## Consecuencias

- Permite juzgar rápidamente la silueta, paleta y densidad visual del juego entero usando los assets actuales.
- El pase añade una lectura de pantalla a resolución completa; se debe inspeccionar legibilidad de HUD y coste en tiempo de render antes de considerar cualquier versión permanente.
- La prueba no convierte este pase de pantalla en dirección aprobada. El experimento se sustituyó por variantes de textura dedicadas según ADR-0055.
- Los parámetros de balance, alcance, movimiento, daño, economía y flujo de construcción no cambian.

## Verificación

- En la revisión posterior, la cuantización global hacía que texto pequeño y gradientes de HUD perdieran legibilidad, y no cumplía el requisito de que cada PNG tuviera píxeles propios. Se retiraron el shader y su `CanvasLayer`; ADR-0055 registra el reemplazo.
- `PixelGridOverlay.mouse_filter` se fija en `MOUSE_FILTER_IGNORE` para no consumir entrada; la validación de clics con ratón queda pendiente.
- Godot conserva tres warnings de GDScript por símbolos sin uso en `wave_director.gd` y `main.gd`, ajenos a este pase.

## Referencias

- [Godot 4.7: Screen-reading shaders](https://docs.godotengine.org/en/4.7/tutorials/shaders/screen-reading_shaders.html), consultado el 2026-10-10.
- Skill local `godot-master`, módulo `references/2d-animation-expert-techniques.md`: filtro Nearest y ajuste de sprites pixel art a píxeles.
