# ADR-0078: Ventana ampliada del timeline de rondas

- Fecha: 2026-10-14
- Estado: Sustituido por [ADR-0083](ADR-0083-timeline-fijo-de-quince-rondas-y-preview-fiel.md) en el tamaño de ventana y el selector; se conserva como historial el uso de una ventana móvil con círculos, hover y datos de campaña.
- Sustituía la vista fija completa de 45 rondas descrita por [ADR-0048](ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md).

## Contexto

El timeline de 45 puntos y su tooltip resultan útiles, pero la vista completa deja cada ronda demasiado pequeña para leerla durante la partida.

## Decisiones

1. El HUD muestra una ventana móvil de 10 o 15 rondas, elegible desde la propia interfaz. La ronda actual queda en el borde inicial; al avanzar una ronda, la ventana se desplaza manteniendo el mismo tamaño.
2. Los círculos y el área interactiva se amplían. Se conserva el tooltip con iconos y cantidades de enemigos al pasar el cursor.
3. El extremo futuro de la ventana se desvanece progresivamente para indicar que hay más rondas fuera de vista. El total de campaña continúa siendo 45.

## Consecuencias

- Historial: `RoundProgressStrip` conservó la fuente de datos y el hover, pero calculó las posiciones respecto a una ventana.
- Los dos modos de zoom se retiraron por petición explícita; la decisión vigente está en ADR-0083.

## Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño activo](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [campaña](../design/14_CAMPANA_45_RONDAS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md), consultados el 2026-10-14.
