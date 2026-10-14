# ADR-0084: Retícula axial compartida y profundidad de fachadas por celda

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; retícula axial y orden por celda vigentes. El cierre de esquinas y el cálculo visual de pared quedan sustituidos parcialmente por [ADR-0085](ADR-0085-solo-fachadas-delanteras-y-degradado-de-cliffs.md).
- Amplía el renderer 2D de [ADR-0043](ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md) y [ADR-0079](ADR-0079-limites-de-obstaculos-y-cierre-visual-del-terreno.md). Conserva la elevación lógica, el movimiento axial, los UV y la cámara fija definidos por [ADR-0073](ADR-0073-elevaciones-y-bonus-de-torre.md).

## Contexto

La revisión de una captura real mostró dos fallos que sobrevivieron al primer arreglo: fachadas elevadas podían quedar tapadas demasiado pronto por tapas dibujadas en una pasada global posterior, y algunas uniones seguían mostrando huecos. La causa era una combinación de fases de dibujo separadas y vértices calculados individualmente con seno/coseno, mientras las tapas, miniaturas, copias Y-sorted y cierres de esquina no compartían una única clave geométrica.

## Decisiones

1. `HexMath` es la autoridad de los vértices pointy-top y del desplazamiento vertical visual de 28 px por nivel. Calcula cada esquina desde una clave entera de la retícula axial; dos celdas que comparten vértice obtienen el mismo punto de pantalla sin redondeos ni trigonometría independiente.
2. Tablero, ghost, miniaturas, hover y copias elevadas usan esta función geométrica común. La elevación solo desplaza la superficie en pantalla; no cambia coordenada axial, ocupación ni orden del grid.
3. El terreno se pinta por celda en orden back-to-front del anclaje de suelo. Para cada celda se dibujan las fachadas expuestas, sus cierres locales por clave axial/altura y luego la tapa texturada. Así una tapa posterior no cubre una fachada de una celda que está delante.
4. La profundidad de una fachada es `max(altura_celda − altura_vecina, 0) × 28 px`. En miniaturas o bordes de pieza sin vecina se usa altura 0. Se conservan los PNG intercambiables y el mapeo UV que repite el patrón con densidad estable.
5. Una tapa sigue siendo un polígono de seis vértices con UV propios. No se deforma la textura en un rectángulo para compensar la elevación. La cámara top-down isométrica permanece fija y las fachadas continúan debajo de actores/props.

## Consecuencias

- La geometría base del tablero ya no depende de aproximaciones trigonométricas separadas entre celdas; los vértices compartidos se identifican en el espacio axial entero.
- Se unifica el orden de terreno del tablero y de las cards, con el painter pass intercalando pared y tapa por celda según la profundidad del grid.
- La regla de elevación y el bonus de torre no cambian. La aceptación visual sigue pendiente hasta recorrer alturas 0–3, desniveles mixtos y vértices aislados en la escena.
- El punto 6 de [ADR-0079](ADR-0079-limites-de-obstaculos-y-cierre-visual-del-terreno.md), que agrupaba puntos redondeados en pantalla, queda sustituido para el renderer de fachadas. Sus límites de obstáculos y demás decisiones siguen vigentes.

## Referencias

- Petición explícita y captura adjunta del terreno con fachadas truncadas y vértices abiertos, 2026-10-14.
- [Hex Grid & Terrain](../design/05_HEX_GRID_AND_TERRAIN.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md), consultados el 2026-10-14.
