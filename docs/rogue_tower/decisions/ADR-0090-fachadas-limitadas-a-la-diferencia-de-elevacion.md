# ADR-0090: Fachadas limitadas a la diferencia de elevación

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; implementación integrada, aceptación visual en Godot pendiente.
- Ajusta la geometría de fachadas de [ADR-0085](ADR-0085-solo-fachadas-delanteras-y-degradado-de-cliffs.md). Mantiene la retícula, el material y las dos direcciones delanteras.

## Contexto

La captura más reciente muestra fachadas opacas y continuas, pero algunas se dibujan por encima de las tapas hexagonales vecinas. Las tapas deben conservar siempre su polígono axial completo. El terreno sigue siendo 2D con elevación visual; no se introducen sólidos 3D.

## Decisiones

1. Una fachada delantera solo dibuja la parte expuesta entre la elevación de su hexágono y la elevación del hexágono que comparte ese borde. La altura visible es `max(elevación_actual − elevación_vecina, 0) × 28 px`.
2. Si no hay celda vecina, se considera elevación 0 y la fachada llega al suelo. A igual altura no se dibuja pared entre las tapas; si la celda vecina está más alta, no se dibuja pared desde la celda baja.
3. El borde inferior de cada quad coincide con la arista superior de la celda vecina (o con el suelo). La pared conserva textura opaca y degradado, pero nunca ocupa el interior de una tapa hexagonal. Cada arista delantera tiene su ancla Y-sort en ese borde inferior.
4. La misma regla geométrica se aplica al tablero confirmado, el ghost y las miniaturas. Las tapas siguen siendo polígonos cerrados de seis vértices calculados desde la retícula axial común.
5. Se mantienen las aristas delanteras 1 y 2, sin caras laterales/traseras, espesor radial ni cierres de esquina.

## Consecuencias

- Las caras superiores vuelven a mostrar la silueta hexagonal completa aunque una pared vecina atraviese su zona proyectada.
- Las paredes siguen siendo sólidas en la altura realmente expuesta; las fachadas entre hexágonos contiguos a igual altura desaparecen como corresponde a una superficie continua.
- La textura de pared se escala según la altura visible y el Y-sort puede resolver cada borde por separado.
- Falta inspeccionar en Godot 4.7 alturas 1–3, vecinos a la misma altura, desniveles mixtos, borde vacío, ghost y miniaturas. Esta decisión no se considera aceptación visual.

## Referencias

- Petición explícita y captura adjunta sobre tapas hexagonales cubiertas por paredes, 2026-10-14.
- [Hex Grid & Terrain](../design/05_HEX_GRID_AND_TERRAIN.md), [aceptación](../design/10_ACCEPTANCE_TESTS.md) y ADR-0085, consultados el 2026-10-14.
