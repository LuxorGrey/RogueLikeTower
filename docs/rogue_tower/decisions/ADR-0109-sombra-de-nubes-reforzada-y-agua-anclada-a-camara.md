# ADR-0109: Sombra de nubes reforzada y agua anclada a cámara

- Fecha: 2026-10-15
- Estado: Implementado en código; aceptación visual pendiente.
- Refina: [ADR-0099](ADR-0099-tinte-de-altura-y-sombra-animada-de-nubes.md) para la opacidad de nubes y [ADR-0108](ADR-0108-agua-wind-waker-y-explosion-pixel-de-enemigo.md) para el movimiento del patrón de agua.

## Contexto

El sombreado móvil de nubes apenas se percibía y el agua del fondo se quedaba fija respecto a la pantalla mientras el tablero se desplazaba al panear la cámara. El usuario pidió reforzar ligeramente la sombra y que el agua acompañe el movimiento del mundo.

## Decisiones

1. `CloudShadowOverlay.shadow_opacity` pasa de `0,16` a `0,20`. Se conservan el color, la forma procedural, la velocidad, el área afectada y su posición bajo el HUD.
2. `WaterBackgroundLayer` conserva el `CanvasLayer -10` y el `ColorRect` a pantalla completa. El shader recibe posición mundial de cámara, tamaño del viewport y zoom; deriva desde ellos la coordenada del mundo visible para generar el patrón. Así el agua acompaña paneo y zoom sin mover ni escalar el panel que cubre la pantalla.
3. Los parámetros de cámara se actualizan en el mismo ciclo que los del sombreado de nubes. El patrón continúa animándose en coordenadas del mundo; no cambia la simulación, el terreno ni la entrada.

## Consecuencias

- La sombra debe resultar algo más visible sin ocultar la lectura de los sprites.
- El agua conserva su escala de pantalla y su cobertura completa, y deja de parecer una capa flotante al desplazar el tablero.
- La aceptación visual tras paneo y zoom queda pendiente.

## Fuentes

- Solicitud del usuario en Codex, 2026-10-15.
- Implementación del shader de agua y la sombra en el proyecto, 2026-10-15.
