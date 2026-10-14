# ADR-0091: Contornos compartidos por región de terreno y elevación

- Fecha: 2026-10-14
- Estado: Geometría/agrupación aceptadas y vigentes; la paleta y el estilo del trazo fueron sustituidos parcialmente por ADR-0095. Aceptación visual pendiente.
- Alcance: presentación 2D de celdas del tablero y miniaturas de piezas.
- Sustituye: no sustituye decisiones anteriores; añade una regla visual al renderer de terreno.

## Contexto

El usuario pide que las celdas del mismo nivel no muestren un borde individual por hexágono. Cada región debe leerse como una forma continua, con su color asociado al tipo de terreno. La elevación y la lectura de qué región queda delante o detrás deben seguir la geometría axial y el orden visual existentes.

## Decisiones

1. Una región está formada por celdas conectadas con el mismo tipo de terreno y la misma elevación lógica.
2. No se dibujan aristas internas entre vecinos de la misma región. Se dibuja cada arista que limita con otra región o con una coordenada vacía; el vacío cuenta como elevación 0 para esta silueta visual.
3. En una frontera entre regiones, ambos lados conservan su propio trazo, desplazado ligeramente hacia dentro de su tapa: verde para Grass, gris para Mountain y amarillo para Path.
4. Las tapas superiores permanecen hexagonales y completas. El contorno se coloca sobre las superficies, respeta las elevaciones y copias superiores Y-sorted, y no altera fachadas, selección, conectividad, ocupación ni navegación.
5. Tablero, superficies elevadas, preview y miniaturas usan la misma regla. El hover puede seguir resaltando temporalmente su celda y sus anillos, y el ghost conserva los colores de validez de colocación.

## Consecuencias

- Las superficies amplias de un mismo terreno/altura se leen como una sola región y pierden la retícula interna persistente.
- Cambios de tipo o elevación quedan visibles incluso cuando las celdas comparten la misma altura.
- Los bordes contra vacío cierran la silueta exterior de cada región.
- Se requiere una revisión visual de juntas, grosor de trazo, miniaturas y oclusión con alturas 1–3.

## Referencias

- [Diseño de terreno hexagonal](../design/05_HEX_GRID_AND_TERRAIN.md)
- [Aceptación visual M42](../design/10_ACCEPTANCE_TESTS.md)
