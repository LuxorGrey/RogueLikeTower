# ADR-0050: Recursos visuales de UI editables en el Inspector

- Fecha: 2026-10-10
- Estado: catálogo editable de iconos y componentes vigente; el uso de marcos texturizados en botones/cards fue sustituido parcialmente por ADR-0053. Aceptación visual pendiente.
- Ámbito: texturas existentes de HUD, cartas, iconos de torre/capa y recursos de estilo de botones.
- Relación: amplía ADR-0049; mantiene su límite de no cambiar lógica ni datos de gameplay.

## Contexto

La primera etapa migró jerarquías a escenas, pero algunas texturas aún se asignaban a los controles desde `Main` y `IconCatalog.gd` solo contenía rutas en código. Al cambiar un icono no resultaba evidente qué nodo o recurso debía abrirse, y el inspector de la escena no mostraba esas asignaciones.

La petición es poder inspeccionar y sustituir cómodamente los sprites existentes, incluidos iniciar ronda, marcos de panel/card, iconos de recursos y torre. No se deben cambiar diseños, controles o contenido de gameplay.

## Decisión

1. No se añaden campos visuales a `TowerData`, `WaveData` ni otros Resources de gameplay. Los iconos de interfaz se configuran en recursos y escenas de `game/ui/`.
2. `game/ui/resources/icon_catalog.tres` es el catálogo editable: al abrirlo en Godot muestra texturas agrupadas para recursos, capas, torres, estados y los cuatro cursores. `Main` expone la referencia `ui_icon_catalog` en el Inspector y los consumidores existentes consultan el mismo recurso, conservando sus IDs y la asociación actual.
3. Cada instancia de `TowerShortcutCard` y `TowerLayerUpgradeButton` en `main.tscn` expone `tower_icon_texture` o `layer_icon_texture`. Sus scripts `@tool` reflejan esa propiedad en el `TextureRect` hijo para que la asignación también se vea al editar la escena. Solo sincronizan un recurso visual; no ejecutan gameplay.
4. Las texturas de Gold/Mana están asignadas en sus `TextureRect` de escena. (Sustituido parcialmente por ADR-0053.) Las texturas decorativas de iniciar ronda, expansión, Tower Info y toolbar ya no están referenciadas desde esas escenas; el jugador puede cambiar su estilo con el Theme plano en `game/ui/themes/rogue_hud_theme.tres`. El icono de Demoler y los iconos variables siguen editables como recursos.
5. Los paneles generales y botones usan `StyleBoxFlat` compartidos del Theme local [Rogue HUD](../../../game/ui/themes/rogue_hud_theme.tres), con esquinas rectas y sin marco decorativo. Color y márgenes se editan desde el recurso Theme o sus overrides.
6. Se retiran de `Main` las asignaciones de sprites y creación de StyleBoxTexture para iniciar ronda, cards de expansión, tarjetas de torre, iconos de recursos y capas. Se conserva el cálculo dinámico de anchura del botón de ronda y la selección runtime de iconos para tarjetas que representan datos variables.

## Ubicaciones de edición

| Qué se quiere cambiar | Selección en Godot |
|---|---|
| Icono usado por retratos, ofertas, tienda, estados y cursores | `game/ui/resources/icon_catalog.tres`, expandir la propiedad del icono |
| Icono de una tarjeta de torre | Instancia `TowerShortcut1…7` en `game/main/main.tscn`, propiedad `tower_icon_texture` |
| Icono de Health/Armor/Shield | Instancia `UpgradeHealth`, `UpgradeArmor` o `UpgradeShield`, propiedad `layer_icon_texture` |
| Sprite Gold/Mana del HUD | `HUD/ResourcesRow/GoldGroup/GoldIcon` o `HUD/ResourcesRow/ManaGroup/ManaIcon` en `main.tscn` |
| Fondo/hover/pressed del botón de ronda y cards de terreno | `game/main/main.tscn`, `Theme Overrides > Styles`; todos usan StyleBoxFlat rectangular |
| Fondo/hover/pressed de las tarjetas de torre y botones H/A/S | `game/ui/themes/rogue_hud_theme.tres`, estilos compartidos de `Button` |
| Apariencia base de paneles, tienda y tooltips | `game/ui/themes/rogue_hud_theme.tres`, estilos `Panel`, `PanelContainer` y `Button` |

## Validación

El smoke headless de Godot 4.7 pasó tras verificar las 20 texturas del catálogo, el StyleBox con sprite del botón de ronda y la presencia/propagación al `TextureRect` de los iconos exportados de torre y Health. Un escaneo headless del editor completó la inicialización y el registro de clases. Ambos mostraron únicamente el aviso del host por el almacén de certificados raíz. La vista manual de los nodos en el Inspector y la comparación visual en ventana siguen pendientes.

## Referencias

- [ADR-0049: arquitectura híbrida y editable para la UI](ADR-0049-arquitectura-hibrida-ui-editable.md)
- [Arquitectura técnica](../design/03_TECHNICAL_ARCHITECTURE.md)
- [Aceptación de UI](../design/10_ACCEPTANCE_TESTS.md)
