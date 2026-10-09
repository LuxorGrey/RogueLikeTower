# ADR-0041: Oclusión, arte de terreno y flujo de rutas

- Fecha: 2026-10-09.
- Estado: aceptado por petición explícita del usuario; código integrado, aceptación visual pendiente.
- Ámbito: orden de dibujo de props y unidades, alineación de atlas, presentación mundial y ruta visible.
- Sustituye parcialmente: ADR-0039 (tamaños de sprites) y ADR-0040 (probabilidad inicial y niveles de cofres).
- La decisión de conservar proporciones para los obstáculos en el punto 3 quedó sustituida por [ADR-0044](ADR-0044-caja-estandar-de-obstaculos.md); el resto de tamaños de entidades y del cofre sigue vigente.

## Contexto

El usuario detectó que las caras de terreno aparecían desplazadas dentro de sus hexágonos y que las torres, los obstáculos, los enemigos y la base se ocultaban entre sí en un orden que no correspondía con su profundidad. También pidió props más legibles, sprites mayores y un indicador animado que recorra las ramas PATH hacia la base. El cofre inicial debe ser raro.

## Decisiones

1. `TerrainVisualCatalog` conserva el atlas, pero cada variante usa su rectángulo de arte visible medido dentro de la celda fuente. El renderer ajusta ese recorte al ancho y alto del hex pointy-top. Esto centra las variantes que tenían padding asimétrico y hace coincidir el borde dibujado con la cara lógica; el borde interactivo y el hover siguen usando los mismos vértices hexagonales.
2. Cada obstáculo/cofre se dibuja como nodo independiente bajo `Entities`, donde ya conviven la base, torres y enemigos con `y_sort_enabled`. Todos mantienen el mismo Z para que el Y-sort pueda compararlos. El renderer del tablero conserva suelo, cliffs y sockets; no dibuja props encima de toda la escena en un único CanvasItem. Los nodos ordenables conservan como posición la coordenada/elevación axial lógica; todo el arte de mundo comparte un desplazamiento visual constante de seis píxeles hacia abajo. Así el punto de ordenación permanece coherente sin cambiar posiciones de gameplay.
3. Las texturas de terreno, torres, enemigos, props, cofres y base usan `TEXTURE_FILTER_LINEAR`. El tamaño se configura por tipo/Resource, no por una escala global: torres 84 px, enemigos estándar 72 px (jefes escalados individualmente en `EnemyData`), base 176×176 px, obstáculos de hasta 92 px de alto con proporción original y cofre 84×84 px. La parte de obstáculos fue sustituida por ADR-0044. Los dibujos de torre/enemigo/base y props bajan 6 px. No se alteran huella lógica, colisiones, selección, movimiento, alcance ni rutas.
4. Las rutas alcanzables muestran una línea tenue con flechas/cheurones animados que avanzan desde cada spawn hacia la base. Se generan desde los segmentos ordenados de `PathGraph.routes`; los segmentos repetidos se dibujan una sola vez y las ramas/convergencias quedan visibles. Con colocación válida se dibuja el grafo candidato; al cancelar se restaura el grafo activo. La tecla `D` conserva el overlay estático de diagnóstico.
5. Se eligió dibujo de flechas por segmento desde `_draw` con actualización de 30 Hz frente a un shader continuo en `Line2D`. Godot ofrece shaders `CanvasItem` y `TIME` para animación, pero las rutas del juego tienen bifurcaciones, aristas compartidas y dirección desde spawn hacia base: dibujarlas desde la ruta real permite deduplicar cada arista y mantener la orientación correcta sin generar texturas/UVs de flujo por rama ni usar un shader de pantalla completa. El coste se limita a los segmentos del tablero y sus cheurones.
6. La generación de cofres baja a 1 % en celdas Grass/Mountain sin obstáculo. «Suerte del explorador» tiene cuatro niveles de +5 puntos porcentuales, con costes 10/20/35/55 y tope absoluto de 20 %. Las probabilidades efectivas son 1 %, 6 %, 11 %, 16 % y 20 %; el cuarto incremento queda limitado por el tope. El premio provisional de 25 Gold no cambia.

## Consecuencias y estado

- Props, actores y base se ordenan desde el anclaje lógico de su celda/movimiento dentro de la capa compartida. Como el offset de arte es uniforme, no cambia el orden relativo; las caras de terreno y las flechas permanecen debajo de ese grupo.
- El recorte fuente se conserva por variante para no deformar el arte ni desplazar una variante respecto a otra. Obstáculos y cofres preservan proporción y usan un anclaje inferior compartido.
- La escala es una propiedad por tipo/perfil. El cuerpo lógico y los rangos siguen usando los valores de gameplay; el aumento visual puede causar solapes estéticos que deben revisarse en juego a zoom normal y reducido.
- El cálculo reproducible por `(seed, coordenada, salt)` sigue igual; solo cambia la tasa de cofre, por lo que las casillas nuevas se determinan según el 1 % y la mejora meta activa.
- Falta revisar manualmente oclusión, bordes del atlas, legibilidad de flechas, solapes y escalas en la ventana del juego. `10_ACCEPTANCE_TESTS.md` registra ese recorrido.

## Referencias

- Petición directa del usuario en la sesión del 2026-10-09 y la imagen adjunta de alineación de Mountain.
- Godot Engine, *CanvasItem*, documentación oficial estable, consultada el 2026-10-09: <https://docs.godotengine.org/en/stable/classes/class_canvasitem.html>. El Y-sort dibuja los CanvasItem con mayor Y delante y solo compara nodos con igual Z.
- Godot Engine, *Using TileMaps*, documentación oficial estable, consultada el 2026-10-09: <https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html>. Referencia de `Y Sort Origin` y organización por capas de terreno.
- Godot Engine, *CanvasItem shaders*, documentación oficial estable, consultada el 2026-10-09: <https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html>. Referencia de CanvasItem 2D y el builtin `TIME`, considerada al evaluar el flujo animado.
- [ADR-0039: escala visual por Resource](ADR-0039-panel-torre-y-escalado-individual.md); [ADR-0040: contenido visual y cofres](ADR-0040-terreno-obstaculos-cofres-y-feedback.md).
