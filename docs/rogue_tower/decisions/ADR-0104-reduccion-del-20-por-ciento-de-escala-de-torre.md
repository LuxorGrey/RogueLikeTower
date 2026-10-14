# ADR-0104: Reducción del 20 % de escala de torre

- **Estado:** implementado; escala de mundo/ghost supersedida por ADR-0105. La aceptación visual de M54 sigue pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** incluso con el ajuste de margen M53, las torres colocadas seguían ocupando demasiado espacio visual. El usuario pide reducirlas otro 20 % en el tablero.

## Decisiones

1. Reducir `Tower.TOWER_VISUAL_SCALE` exactamente un 20 % respecto a 1,32: el valor nuevo es 1,056.
2. Mantener sincronizada la escala del ghost con la torre colocada; conservar `DISPLAY_HEIGHT_MULTIPLIER = 1,12`, el offset visual de +8 px y la textura PNG completa.
3. Limitar este ajuste al mundo y su preview. Los iconos de la barra de selección y Tower Info mantienen sus tamaños actuales.

## Consecuencias

- Las torres colocadas son un 20 % menores que con la escala anterior; preview y resultado siguen coincidiendo.
- No cambia la huella hexagonal, colisiones, alcance, daño ni selección lógica.
- La comprobación visual en Godot queda pendiente.

## Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño del juego](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md).

## Sustituye

- Sustituye el valor 1,32 de tablero/ghost de [ADR-0103](ADR-0103-escala-de-torre-sin-recorte.md). Los tamaños UI y demás reglas de sprites completos de ADR-0102/0103 siguen vigentes.
- M55/ADR-0105 reduce posteriormente esta escala de 1,056 a 0,9504; esta página conserva el valor de M54 como historial.
