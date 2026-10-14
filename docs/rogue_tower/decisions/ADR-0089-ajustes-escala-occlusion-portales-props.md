# ADR-0089: Ajustes de escala, oclusión, portales y props

- Fecha: 2026-10-14
- Estado: Aceptado parcialmente; portales y props siguen vigentes. La regla de escala visual de la base fue sustituida por [ADR-0096](ADR-0096-base-mas-alta-y-visible.md); el alcance geométrico de fachadas y tapas se ajusta por [ADR-0090](ADR-0090-fachadas-limitadas-a-la-diferencia-de-elevacion.md). Aceptación visual pendiente.
- Decisión de usuario: mensaje del 2026-10-14 en esta conversación
- Sustituye parcialmente: [ADR-0055](ADR-0055-feedback-base-seleccion-y-recompensas.md) (tamaño de portal) y [ADR-0087](ADR-0087-props-obstaculos-y-altura-junto-a-base.md) (tamaño de base y parámetros de props)

## Contexto

La resolución fuente de la base se había confundido con su tamaño dibujado. La oclusión actual dejaba las fachadas elevadas en una capa fija detrás de los enemigos. El usuario también indicó que los portales debían animarse con el spritesheet ya presente en el proyecto y que los props eran demasiado pequeños y poco frecuentes. `TerrainPiecePreview` tenía además una llamada multilínea en el anillo de base que impedía cargar la clase en el editor informado por el usuario.

## Decisiones

1. `assets/base/main_tower.png` conserva su PNG original de 270×352 px. La escala uniforme de hasta 86×86 px fue la regla anterior; ADR-0096 la sustituye por una presentación estirada más alta sin cambiar la celda lógica.
2. Cada fachada expuesta obtiene un nodo propio bajo `Entities.y_sort_enabled`, anclado en su borde inferior para ocluir actores detrás y quedar detrás de actores delante. La altura de la pared y la prioridad completa de las tapas se definen en ADR-0090.
3. `spawn_portal_SpriteSheet.png` se interpreta como ocho frames de 443×443 px en una cuadrícula 4×2. Los portales animan los ocho frames en bucle continuo a 10 FPS. Cada endpoint recibe y conserva una fase determinista única durante la run; añadir o retirar otros endpoints no reinicia la animación ya visible. `spawn_portal.png` permanece como icono estático del panel de selección.
4. Los props compatibles con cada terreno tienen un 10 % de probabilidad independiente por asset y celda, mantienen un máximo de dos elementos únicos y pasan de 30×30 a 36×36 px. Sus offsets se separan para que dos props no se solapen; un obstáculo sigue dibujándose delante.
5. La asignación de variante visual y props al anillo de base se expresa con llamadas simples en `_apply_base_ring_elevation`, eliminando la indentación que impedía analizar el script.

## Consecuencias

- La resolución de imagen y el tamaño visual de la base quedan documentados como valores distintos.
- Los actores y las fachadas comparten el orden Y de `Entities`; las miniaturas y ghosts conservan el render de preview.
- Los valores de props y la animación de portales quedan centralizados en el código de terreno/portal y descritos en la página activa [Hex grid y terreno](../design/05_HEX_GRID_AND_TERRAIN.md).
- La implementación está integrada, pero necesita aceptación visual en ventana, especialmente para la oclusión de enemigos detrás/delante y la continuidad del atlas animado.

## Fuentes

- Solicitud directa del usuario, 2026-10-14.
- PNGs del proyecto: `assets/base/main_tower.png`, `assets/terrain/spawn_portal_SpriteSheet.png` y `assets/terrain/spawn_portal.png`.
