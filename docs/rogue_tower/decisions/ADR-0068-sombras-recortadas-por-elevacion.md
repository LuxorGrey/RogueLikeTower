# ADR-0068: Sombras de losetas recortadas por altura receptora

- Fecha: 2026-10-13
- Estado: Sustituido; el overlay y el shader fueron eliminados por ADR-0070.
- Reemplazó temporalmente: la técnica de sombra de losetas de [ADR-0066](ADR-0066-cofres-al-colocar-y-sombras-de-elevacion.md). Su alcance fue cancelado por la petición posterior de no mostrar sombras generadas.

## Contexto

La primera sombra de M27 estampaba la silueta de cada loseta encima de la propia casilla. Eso oscurecía terreno de la misma altura y creaba marcas sin relación con los desniveles. La cámara es 2D top-down con elevación isométrica simulada y niveles lógicos 0–2.

## Decisiones

1. En la implementación temporal, solo las celdas con elevación mayor que 0 proyectaban sombra de loseta. Un receptor solo recibía la sombra de un caster si su elevación era menor.
2. La silueta hexagonal del caster se desplaza según la diferencia de altura y la dirección lenta de luz. El resultado se recorta contra el hexágono de cada receptor inferior cercano, de modo que la marca permanece dentro de la cara superior que la recibe.
3. Las sombras de terreno se dibujan encima de las caras del suelo y debajo del flujo de flechas y las entidades. Las sombras de obstáculos conservan su silueta alfa actual.
4. La sombra visual no altera elevación lógica, oclusión Y-sort, PathGraph ni fachadas.

## Consecuencias

- Esta implementación quedó retirada; el estado vigente elimina las sombras de todas las celdas y obstáculos.
- ADR-0070 registra la retirada y el trabajo visual de PATH asociado.
