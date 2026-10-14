# ADR-0079: Límites de obstáculos y cierre visual del terreno elevado

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código integrado, aceptación visual pendiente.
- Amplía las reglas de terreno de [ADR-0043](ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md) y la distribución de props de [ADR-0060](ADR-0060-ofertas-de-terreno-y-contenido-determinista.md), sin alterar el modelo lógico de elevación de [ADR-0073](ADR-0073-elevaciones-y-bonus-de-torre.md).

## Contexto

La variación de altura reveló texturas de cliff estiradas, un borde abierto con cara violeta, puntas sin cerrar cuando una fachada terminaba sola en un vértice y un orden visual que mezclaba la profundidad axial con el desplazamiento de altura. La distribución aleatoria también necesita límites alrededor de la base.

## Decisiones

1. Una pieza de expansión de siete hexes puede contener como máximo dos obstáculos por celda. En el tablero inicial hay como máximo un obstáculo en total; la celda de base y sus seis vecinas axiales no admiten obstáculos.
2. La tapa de cada hex debe ser un polígono cerrado de seis vértices. La textura se recorta a ese polígono mediante UV por vértice; no se dibuja como rectángulo que sobresalga o se deforme.
3. Las fachadas de desnivel usan repetición/recorte de UV para preservar la escala de la textura al variar la altura. No se permite que el UV fuera del rango pinte una franja ajena (por ejemplo, el tramo violeta de una textura).
4. La lectura de profundidad conserva la cámara top-down isométrica fija. Las tapas del tablero se dibujan back-to-front por la Y proyectada del anclaje axial de suelo; la altura desplaza su imagen, pero no cambia la prioridad frontal de la celda. Las copias elevadas participan en el Y-sort de `Entities` en la posición proyectada de su superficie y se colocan antes de actores/props en empates.
5. Durante el modo de colocación de Ballista, el ghost de hover muestra el mismo bonus de daño de elevación que recibe una torre construida.
6. Cada fachada conserva el descenso vertical real hasta el vecino y solo añade espesor lateral donde la proyección colapsaría la cara. En cada vértice, una envolvente convexa entre los puntos de apoyo y los extremos extruidos cierra las uniones, incluidos los extremos aislados de una sola fachada.
7. La miniatura de cada oferta usa las mismas caras hexagonales texturadas, fachadas de Grass/Mountain y tapas de vértice que el tablero. Su Y-sort se calcula con el anclaje axial de suelo, y la altura solo desplaza las superficies; se muestran las elevaciones de la oferta que se va a colocar. El detalle de geometría, clave de vértice y orden de pintura de las fachadas quedó reemplazado por [ADR-0084](ADR-0084-render-axial-de-terreno-y-profundidad-por-celda.md), después de que la primera versión todavía permitiera paredes recortadas y juntas abiertas.

## Consecuencias

- La corrección de superficie y fachadas queda en los componentes 2D del terreno; no se añaden mallas 3D ni se cambia la cámara. Las cards dejan de usar caras laterales lisas y no calculan su propio orden de profundidad basado en altura. El cierre por envolvente de puntos de pantalla descrito en el punto 6 y el dibujo global de fachadas/tapas son antecedentes: ADR-0084 fija la clave axial entera y el pase de dibujo local por celda.
- Los límites se aplican a los rolls iniciales y a cada pieza de expansión. La unión de extremos ahora incluye tanto el apoyo vertical como el espesor de pantalla y las tapas base usan profundidad axial; la aceptación visual de geometría, escala de textura y oclusión sigue pendiente en M35.

## Referencias

- Petición explícita del usuario y capturas de defectos de terreno, 2026-10-14.
- [Hex Grid & Terrain](../design/05_HEX_GRID_AND_TERRAIN.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md), consultados el 2026-10-14.
