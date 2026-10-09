# ADR-0031: PNG independientes para cada icono

- Estado: Aceptada e implementada.
- Fecha: 2026-10-08.
- Contexto: el HUD, las torres, las mejoras y las barras de enemigos consumían regiones de un único atlas PNG. El usuario pidió explícitamente que cada objeto tuviese su propio archivo PNG y que no se use un atlas compartido.

## Decisiones

1. Se conserva el arte placeholder existente y se exporta cada una de sus 16 celdas como un PNG RGBA transparente de 256×256 en `game/ui/icons/`.
2. Los IDs de archivo son `gold`, `mana`, `health`, `armor`, `shield`, `ballista`, `mortar`, `tesla_coil`, `frost_keep`, `flame_thrower`, `poison_sprayer`, `shredder`, `burn`, `slow`, `poison` y `bleed`.
3. `IconCatalog` resuelve cada ID a un `Texture2D` PNG independiente. Los botones, previews, torres colocadas, HUD, cards, barras y estados continúan usando estos IDs y sprites.
4. Se elimina `game/ui/tower_defense_icons.png` y su archivo `.import`. No se generan atlas ni se agrupan los sprites en una textura común.

## Consecuencias y aceptación

- Un objeto puede reemplazarse o editarse sin recortar ni volver a exportar los demás.
- La forma cuadrada 256×256 y el canal alfa mantienen una escala de origen uniforme y los fondos transparentes que espera la UI.
- La inspección de los PNG debe confirmar que cada archivo contiene solo su objeto, conserva transparencia y no pierde detalles en los límites de la celda original. La aceptación visual dentro de Godot se mantiene pendiente junto con M13.

## Referencias

- Sustituye la decisión de atlas PNG del [ADR-0028](ADR-0028-iconos-png-y-feedback-visual.md).
- [Arquitectura técnica](../design/03_TECHNICAL_ARCHITECTURE.md).
- [Especificación del proyecto](../archive/initial_import/project_spec.json).
- [Pruebas de aceptación](../design/10_ACCEPTANCE_TESTS.md).

## Extensión del roster de enemigos (2026-10-09)

Los sprites de enemigos siguen el mismo contrato de PNG independiente: `EnemyData.sprite_texture` referencia un archivo RGBA individual en `assets/enemies/`. El juego no carga un atlas de enemigos; el arte fuente se separa antes de incorporarse al roster.
