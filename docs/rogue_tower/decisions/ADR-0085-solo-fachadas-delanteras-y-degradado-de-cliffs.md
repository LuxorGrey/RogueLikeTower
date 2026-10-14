# ADR-0085: Solo fachadas delanteras y degradado de cliffs

- Fecha: 2026-10-14
- Estado: Aceptado parcialmente. La selección de fachadas delanteras y el degradado siguen vigentes; el tramo de pared hasta el suelo y la regla de oclusión por tapas quedan sustituidos por [ADR-0090](ADR-0090-fachadas-limitadas-a-la-diferencia-de-elevacion.md). La inspección visual completa sigue pendiente.
- Ajusta la presentación 2D de elevación de [ADR-0084](ADR-0084-render-axial-de-terreno-y-profundidad-por-celda.md). Conserva la retícula axial, el orden por celda y la cámara fija.

## Contexto

Las capturas mostraron tiras de color y vértices laterales que aparecían al cerrar esquinas con polígonos añadidos y al dar profundidad radial a paredes casi paralelas a la extrusión vertical. El usuario pidió que no se dibuje profundidad en los laterales del hex, que se conserve la silueta axial y que Grass/Mountain tengan un degradado oscuro hacia abajo solo en sus fachadas.

## Decisiones

1. En el hex pointy-top actual, solo las aristas axiales 1 y 2 son fachadas delanteras. Únicamente esas dos aristas generan paredes; las dos laterales y las dos traseras no producen geometría de altura.
2. Cada fachada es un quad cuyos dos vértices inferiores son la copia vertical de la arista superior. Su extensión vertical se limita a la diferencia de altura con la celda vecina; si no hay celda, llega hasta el suelo. El detalle vigente está en ADR-0090. No se añade espesor lateral, desplazamiento radial, triángulo de cierre ni ningún vértice de unión.
3. La tapa superior conserva sus seis vértices axiales completos y ninguna pared se prolonga por encima de ella. El anclaje Y-sorted de cada fachada coincide con su borde inferior; la profundidad resultante se describe en ADR-0090.
4. `TerrainVisualCatalog` mantiene las texturas PNG actuales de Grass/Mountain y define un tinte inferior multiplicativo para cada material. Los valores actuales son `#263b2b` para Grass y `#24242a` para Mountain; se consideran ajustes visuales provisionales sujetos a aceptación. Las paredes se modulan con blanco en el borde superior y ese tinte en el inferior; la tapa superior, sus UV y sus tintes por elevación no cambian.
5. El mismo trazado de dos fachadas y el mismo degradado se usan en el tablero, ghost y miniaturas. La escala UV se deriva del largo de la arista y de la elevación renderizada para que la textura no se estire.

## Consecuencias

- Se elimina del renderer toda fuente de paredes laterales, tapas de esquina y parches sólidos marrones; las esquinas visibles resultan únicamente de las dos fachadas que comparten los vértices axiales de la tapa.
- La elevación se representa como terreno 2D con falsa profundidad, no como un prisma cerrado. Las cuatro caras que el usuario no quiere ver quedan fuera del render. El cálculo de la parte visible de las paredes se sustituye por ADR-0090.
- La inspección visual inicial en Godot 4.7 no encontró errores GDScript/runtime. La aprobación visual inicial quedó limitada por la petición posterior de conservar siempre completas las tapas hexagonales; esa corrección se registra en ADR-0090. Falta revisar manualmente alturas 1–3, vecinos con elevaciones distintas y zoom alto.
- Para el contrato completo de alturas y bonos de torre sigue vigente [ADR-0073](ADR-0073-elevaciones-y-bonus-de-torre.md); este ADR solo cambia la representación de las paredes.

## Referencias

- Petición explícita y capturas del terreno con defectos en las esquinas laterales, 2026-10-14.
- [Hex Grid & Terrain](../design/05_HEX_GRID_AND_TERRAIN.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md), consultados el 2026-10-14.
