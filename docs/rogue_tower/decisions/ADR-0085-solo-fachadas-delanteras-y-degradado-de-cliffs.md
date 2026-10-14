# ADR-0085: Solo fachadas delanteras y degradado de cliffs

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; el usuario aprobó el aspecto actual como referencia visual. La revisión de todas las combinaciones de altura, vecinos y oclusión sigue pendiente.
- Ajusta la presentación 2D de elevación de [ADR-0084](ADR-0084-render-axial-de-terreno-y-profundidad-por-celda.md). Conserva la retícula axial, el orden por celda y la cámara fija.

## Contexto

Las capturas mostraron tiras de color y vértices laterales que aparecían al cerrar esquinas con polígonos añadidos y al dar profundidad radial a paredes casi paralelas a la extrusión vertical. El usuario pidió que no se dibuje profundidad en los laterales del hex, que se conserve la silueta axial y que Grass/Mountain tengan un degradado oscuro hacia abajo solo en sus fachadas.

## Decisiones

1. En el hex pointy-top actual, solo las aristas axiales 1 y 2 son fachadas delanteras. Únicamente esas dos aristas generan paredes; las dos laterales y las dos traseras no producen geometría de altura.
2. Cada fachada es un quad cuyos dos vértices inferiores son la copia vertical de la arista superior. Su extrusión mide `elevación × HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET` (28 px por nivel) hasta el nivel de suelo. No se añade espesor lateral, desplazamiento radial, triángulo de cierre ni ningún vértice de unión.
3. Se mantiene el painter order por anclaje de suelo: fachada del hex y después tapa. Una tapa delantera oculta la parte de las fachadas que cae bajo su superficie; la geometría no depende de construir sólidos cerrados.
4. `TerrainVisualCatalog` mantiene las texturas PNG actuales de Grass/Mountain y define un tinte inferior multiplicativo para cada material. Los valores actuales son `#263b2b` para Grass y `#24242a` para Mountain; se consideran ajustes visuales provisionales sujetos a aceptación. Las paredes se modulan con blanco en el borde superior y ese tinte en el inferior; la tapa superior, sus UV y sus tintes por elevación no cambian.
5. El mismo trazado de dos fachadas y el mismo degradado se usan en el tablero, ghost y miniaturas. La escala UV se deriva del largo de la arista y de la elevación renderizada para que la textura no se estire.

## Consecuencias

- Se elimina del renderer toda fuente de paredes laterales, tapas de esquina y parches sólidos marrones; las esquinas visibles resultan únicamente de las dos fachadas que comparten los vértices axiales de la tapa.
- La elevación se representa como terreno 2D con falsa profundidad y oclusión, no como un prisma cerrado. Las cuatro caras que el usuario no quiere ver quedan fuera del render.
- La inspección visual inicial en Godot 4.7 no encontró errores GDScript/runtime y el usuario confirmó que el aspecto actual es el deseado. Falta revisar manualmente alturas 1–3, vecinos con elevaciones distintas y zoom alto; esa matriz no cambia la referencia aprobada.
- Para el contrato completo de alturas y bonos de torre sigue vigente [ADR-0073](ADR-0073-elevaciones-y-bonus-de-torre.md); este ADR solo cambia la representación de las paredes.

## Referencias

- Petición explícita y capturas del terreno con defectos en las esquinas laterales, 2026-10-14.
- [Hex Grid & Terrain](../design/05_HEX_GRID_AND_TERRAIN.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md), consultados el 2026-10-14.
