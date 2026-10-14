# ADR-0082: Tinte multiplicativo tenue por elevación

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; renderer integrado, aceptación visual pendiente.
- Añade una señal de profundidad a las tapas del terreno sin cambiar el modelo 2D ni el orden de dibujo definido en [ADR-0073](ADR-0073-elevaciones-y-bonus-de-torre.md) y [ADR-0079](ADR-0079-limites-de-obstaculos-y-cierre-visual-del-terreno.md).

## Contexto

La altura lógica ya desplaza las caras y dibuja fachadas, pero algunos niveles contiguos son difíciles de distinguir. Se pide un filtro multiplicativo muy tenue que preserve la textura y la vista isométrica.

## Decisiones

1. La modulación de las tapas escala el rojo por `1 − 0,01 × h` y el verde por `1 − 0,005 × h`; el azul permanece en 1. La altura usada se limita a 0–3.
2. Altura 0 conserva blanco. La misma función de `TerrainVisualCatalog` se usa para las tapas del preview y sus copias elevadas Y-sorted.
3. El tinte no cambia textura, UV, geometría, cámara, profundidad, navegación, alcance ni posición lógica. No se vuelve a introducir un overlay/shader de sombras.

## Consecuencias

- En altura 3 el multiplicador es `(0,97, 0,985, 1)`; el contraste es intencionalmente leve y la textura original debe seguir leyéndose.
- La aceptación visual debe comparar alturas 0–3 y verificar que no se deforman las texturas ni se altera la oclusión en M36 de `10_ACCEPTANCE_TESTS.md`.

## Referencias

- Petición explícita del usuario, 2026-10-14.
- [ADR-0073](ADR-0073-elevaciones-y-bonus-de-torre.md) y [ADR-0079](ADR-0079-limites-de-obstaculos-y-cierre-visual-del-terreno.md), consultados el 2026-10-14.
