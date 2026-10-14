# ADR-0096: Sprite de base más alto y visible

- **Estado:** aceptado por petición explícita del usuario; código/documentación integrados, aceptación visual pendiente.
- **Fecha:** 2026-10-14.
- **Alcance:** representación visual del sprite de `GameBase`.
- **Parámetros:** provisionales hasta la revisión visual.

## Contexto

El usuario quiere localizar la base con más facilidad y pidió hacer el sprite más grande y alto. Autorizó estirarlo aunque pierda su proporción mientras se calibra el tamaño definitivo.

## Decisiones

1. El PNG fuente de 270×352 px no se remuestrea ni reemplaza.
2. Para `footprint_radius = r`, el sprite se dibuja en una caja de `1.8r` de ancho por `2.8r` de alto mediante escalas X/Y independientes. Con el radio actual de 52 px equivale aproximadamente a 94×146 px.
3. El centro visual sube la mitad del incremento de altura para conservar fijo el borde inferior del sprite. La base queda más alta hacia arriba y no cambia la celda que ocupa.
4. La huella lógica, las reglas, las colisiones, la vida y el Y-sort del nodo de base no cambian. La deformación visual es temporal y queda sujeta a aceptación.

## Consecuencias

- La base sobresale más de su hexágono y resulta más fácil de identificar en el tablero.
- La proporción del PNG se distorsiona intencionadamente. El tamaño y el ajuste final pueden revisarse tras observarlo en ventana.

## Sustituye

La escala uniforme y caja máxima de 86×86 px definidas para la presentación en ADR-0089 quedan sustituidas. Se conserva su resolución fuente y la separación entre el sprite visual y la huella lógica.
