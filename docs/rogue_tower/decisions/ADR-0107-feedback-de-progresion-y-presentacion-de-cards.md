# ADR-0107: Feedback de progresión y presentación de cards

- **Estado:** aceptado e implementado en código; aceptación visual pendiente. La presentación del agua del punto 8 fue sustituida parcialmente por ADR-0108.
- **Fecha:** 2026-10-15.
- **Contexto:** el seguimiento de objetivos hacía que las torres subieran demasiado despacio; los iconos de estado, los controles H/A/S y la tienda necesitaban más legibilidad. Las fachadas elevadas podían ganar empates de profundidad frente a enemigos. El usuario pidió además un feedback común para cards, una acción de demolición compacta y un fondo animado oscuro.

## Decisiones

1. La XP automática por seguimiento de objetivo de todas las torres multiplica por cinco la tasa anterior. Al subir automáticamente, `Tower` emite `level_up_effect_requested`, igual que en una mejora manual, para reutilizar el feedback de nivel existente.
2. Los iconos de estados animados sobre enemigos pasan de 22×22 a 44×44 px. El contador de acumulaciones se mantiene junto al sprite.
3. Las fachadas de terreno conservan su origen de profundidad en la junta inferior. `TerrainCliffOccluder` añade un sesgo local de 1 px solo al Y-sort para resolver coincidencias exactas; no desplaza el polígono, la textura ni los anclajes axiales.
4. Los botones Health/Armor/Shield forman una columna y expanden su ancho al máximo del panel padre. Los iconos de capa aumentan a 52×52 px.
5. Las acciones de demoler torre y retirar obstáculo usan el mismo icono `assets/sprites/ui/demolish_tower_icon.png` en botones cuadrados de 58×58 px. El coste de retirada ocupa un badge pequeño con el icono Gold y su importe; el sprite de demolición conserva el protagonismo.
6. Cada mejora permanente selecciona un icono desde su operación o torre afectada. La moneda persistente se presenta con `assets/sprites/ui/icons/exp.png` junto a los importes; la interfaz de la tienda no muestra los textos «XP», «EXP» ni «experiencia».
7. `BalatroCardHover` aporta inclinación, escala moderada y brillo radial ligado al cursor a cards de mejora de run, terreno y torre. El efecto es visual y no intercepta entrada ni reemplaza la selección existente.
8. **Histórico; presentación sustituida por ADR-0108.** M56 incorporó el agua procedural oscura en `CanvasLayer` -10. La capa inferior y su función de fondo siguen vigentes; paleta, tamaño de las formas y velocidad actuales se rigen por ADR-0108.

## Consecuencias

- La experiencia automática por objetivo es cinco veces más rápida, pero los costes/curvas de nivel no cambian.
- Las mejoras manuales y automáticas presentan el mismo efecto visual.
- La profundidad mantiene el criterio visual por posición; solo se rompe de forma estable un empate de un píxel a favor de la fachada.
- La tienda usa iconografía coherente para cada nodo y para todos los importes de la moneda persistente.
- Los tres tipos de cards responden al hover con el mismo componente y mantienen sus propias acciones.
- El agua permanece limitada al fondo visible detrás del juego. Su presentación vigente y aceptación visual quedan en ADR-0108.

## Referencias

- Petición del usuario sobre XP, iconos, demolición, cards, enemigos y shader de fondo, 2026-10-15.
- [Fuente de verdad de diseño](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [progresión](../design/16_PROGRESION_Y_SELECCION_DE_TORRES.md), [combate](../design/06_COMBAT_SYSTEM.md), [terreno](../design/05_HEX_GRID_AND_TERRAIN.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md).
- [Wind Waker 2D Water Shader (Godot 4)](https://godotshaders.com/shader/wind-waker-2d-water-shader-godot-4/), Godot Shaders; snippet identificado como CC0, consultado el 2026-10-15.

## Extiende

- ADR-0069/0077: moneda persistente, iconografía y tienda permanente.
- ADR-0090/0099: orden/lectura visual de fachadas y capas del tablero.
- ADR-0101/0102/0106: feedback visual, subida de torre y efectos de run.
