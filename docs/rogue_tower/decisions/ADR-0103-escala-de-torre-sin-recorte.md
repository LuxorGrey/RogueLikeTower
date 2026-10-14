# ADR-0103: Escala de torre sin recorte

- **Estado:** aceptado e implementado en código; aceptación visual pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** después de cargar los sprites completos de torre con la escala ampliada de M52, algunas torres se veían cortadas al colocarse. La reducción debe preservar la coincidencia entre preview y torre final, y dejar intactos los retratos de interfaz.

## Decisiones

1. Reducir `Tower.TOWER_VISUAL_SCALE` de 1,44 a 1,32. Este valor alimenta el sprite colocado y el tamaño del ghost, por lo que ambos conservan la misma escala y anclaje.
2. Mantener `TowerArtCatalog.DISPLAY_HEIGHT_MULTIPLIER = 1,12`, el offset visual de +8 px y el sprite PNG completo sin recortes ni composición por regiones.
3. No cambiar los tamaños de las cards ni de Tower Info: este ajuste afecta al arte de mundo/preview, no a los iconos UI.

## Consecuencias

- La escala mundial conserva una ampliación visible, pero deja más margen alrededor del sprite para reducir cortes al colocarlo.
- No cambia el hex ocupado, las colisiones, el alcance, el daño ni las reglas de selección.
- La reducción debe aceptarse visualmente en Godot con las siete torres, terreno plano y elevado; no se realizó esa revisión en esta actualización.

## Referencias

- Petición explícita del usuario y sprites completos en `assets/sprites/ui/icons/`, 2026-10-14.
- [Diseño del juego](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md).

## Sustituye

- Sustituye únicamente la escala de tablero/ghost 1,44 de [ADR-0102](ADR-0102-sprites-completos-de-torre-escala-y-feedback.md). Los PNG completos, offset, tamaño UI, mirror, contorno y cadencia de VFX siguen vigentes.
