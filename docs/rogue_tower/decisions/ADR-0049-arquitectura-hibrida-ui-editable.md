# ADR-0049: Arquitectura híbrida y editable para la UI

- Fecha: 2026-10-10
- Estado: implementación integrada; aceptación visual e interactiva pendiente.
- Ámbito: presentación UI existente de `Main`, ofertas de mejora, tienda terminal y menú de hacks.
- Sustituye: la construcción programática de jerarquías visuales de estos componentes. No sustituye ADR-0026 ni decisiones de layout/arte posteriores.

## Contexto y auditoría

El proyecto ya tenía la mayor parte del HUD y del panel de selección colocados en `game/main/main.tscn`, con `main.gd` como coordinador de partida y presentación. Sin embargo, algunas interfaces carecían de escena propia: `MetaShopPanel` y `DebugHacksPanel` construían sus árboles completos desde GDScript; las tarjetas de oferta y las filas/controles repetidos dependían del árbol de `Main`; y el tooltip de ronda creaba filas visuales al vuelo. Un helper aplicaba estilos parecidos, pero no había un recurso `Theme` compartido.

El inventario de pantallas y responsabilidades encontrado fue:

| Interfaz | Escena y controlador | Datos, contratos e interacción | Riesgo y tratamiento |
|---|---|---|---|
| HUD de partida y paneles de construcción/selección | `game/main/main.tscn`, coordinado por `game/main/main.gd` | Servicios de run, selección, terreno, recursos, torre y estado de campaña; los atajos existentes y las señales de sistemas se mantienen en `Main`. | Alto por su acoplamiento con partida. Se conserva la escena raíz y el coordinador; solo se convierten controles repetidos y el panel de cartas en escenas. |
| Progreso de ronda y tooltip | `game/ui/round_progress_strip.gd` y sus nuevas escenas de tooltip/fila | Recibe `WaveData`; presenta el dibujo procedural de los 45 puntos y agrupaciones derivadas de `EnemyData`. | Medio. El dibujo y sus datos no cambian; la estructura del tooltip ahora es una escena y las filas se instancian desde una escena reutilizable. |
| Oferta de mejoras de run | `UpgradeOfferPanel` y `UpgradeOfferCard`; `main.gd` sigue atendiendo la selección | `RunCardService` determina los datos/ofertas; se conservan cantidad configurable, orden y manejadores existentes. | Medio. Vista y cartas son `.tscn`; el controlador de partida sigue aplicando las reglas y la oferta dimensiona las instancias según `offer_size`. |
| Tienda terminal de meta-progresión | `game/progression/meta_shop_panel.tscn/.gd` y `meta_shop_row.tscn` | `MetaProgression`, perfiles de torre y upgrades; conserva pestañas, compras, moneda, `configure`, `present`, `is_open` y `new_run_requested`. | Alto por el guardado y flujo de nueva run. El script de presentación mantiene esos contratos y las filas visuales pasan a `PackedScene`. |
| Menú de hacks de depuración | `game/ui/debug_hacks_panel.tscn/.gd` | Conserva acciones `StringName` hacia `Main`, el atajo `Ctrl+K`, la capa y el cierre tras acciones no toggle. | Bajo/medio. Se añade escena editable; la ejecución de los hacks queda en `Main` como antes. |
| Controles repetidos del HUD | `TowerShortcutCard`, `TowerLayerUpgradeButton` | Los siete perfiles de `TowerData`, iconos existentes, economía y progresión de capas alimentan sus vistas; las señales y handlers de botones siguen conectados por `Main`. | Medio. La jerarquía es editable por escena, y el comportamiento/datos continúan en el coordinador existente. |

No se encontraron pantallas de título, ajustes o navegación independientes en el estado actual. El `Label.new()` en `game/enemies/enemy.gd` representa daño flotante ligado al mundo y la entidad; se conserva fuera de la migración de UI de presentación. `RoundProgressStrip` mantiene su dibujo procedural porque representa una secuencia de datos y no una jerarquía de controles. El HUD F3 y las cards de terreno ya existentes también permanecen en sus escenas actuales.

## Decisión

1. Las jerarquías visuales persistentes y repetibles se definen en escenas `.tscn` bajo las carpetas actuales `game/ui/components`, `game/ui/themes` y `game/progression`; no se mueven escenas de gameplay sin necesidad.
2. Los scripts de componentes muestran datos, actualizan controles e informan interacciones. `Main`, `RunCardService`, `MetaProgression` y los servicios existentes conservan selección, reglas, compras, guardado y efectos de gameplay.
3. Los elementos cuyo número depende de recursos/datos se instancian desde escenas reutilizables. La cantidad de cartas continúa derivando de `DEMO_CARD_POOL.offer_size`; filas de tienda y enemigos del tooltip continúan naciendo de sus listas/datos existentes.
4. `game/ui/themes/rogue_hud_theme.tres` centraliza estilos base compartidos y se asigna localmente a las raíces relevantes. No se asigna como Theme global del proyecto, por lo que no altera controles ajenos a estos paneles.
5. Los recursos y valores de muestra de las escenas hacen que sus árboles puedan previsualizarse en el editor. El código sustituye esos valores con los datos runtime; no son contenido de gameplay.
6. No se cambia el layout global, resolución, atajos, fases, persistencia, contenido, balance, contratos de señales ni lógica de combate. No se extrae `Main` como parte de esta migración para evitar mezclar el cambio visual con una refactorización de gameplay.

## Escenas añadidas o adaptadas

- `game/ui/themes/rogue_hud_theme.tres`
- `game/ui/components/tower_shortcut_card.tscn` y `.gd`
- `game/ui/components/tower_layer_upgrade_button.tscn` y `.gd`
- `game/ui/components/upgrade_offer_panel.tscn` y `.gd`
- `game/ui/components/upgrade_offer_card.tscn` y `.gd`
- `game/ui/components/wave_hover_tooltip.tscn` y `.gd`
- `game/ui/components/wave_enemy_row.tscn`
- `game/progression/meta_shop_panel.tscn`, `meta_shop_panel.gd` y `meta_shop_row.tscn`
- `game/ui/debug_hacks_panel.tscn` y `debug_hacks_panel.gd`

## Validación y consecuencias

`tests/ui_migration_smoke.tscn` corre en Godot 4.7 headless. Comprueba carga de `Main`, el contrato de acción del panel debug, configuración de tarjetas, variación del número de ofertas, filas de tienda, señal de nueva run y creación del tooltip de ronda. La ejecución del 2026-10-10 pasó. Godot mostró el aviso del almacén de certificados raíz del host, sin errores de scripts/escenas en el resultado del smoke.

La validación automatizada no compara píxeles ni recorre la partida con ratón/teclado. Por ello no demuestra equivalencia visual a 1280×720 y 1440×900 ni reemplaza la inspección manual de hover, foco, propagación, scroll, compras y transiciones. Esos criterios quedan pendientes en `design/10_ACCEPTANCE_TESTS.md`.

Beneficio: distribución, tamaños, márgenes, estilos base, contenidos de muestra y jerarquía de componentes pueden modificarse en el editor visual. Consecuencia: la previsualización aislada de una escena no refleja sus texturas y datos reales hasta configurarla desde el juego.

## Referencias

- [ADR-0026: jerarquía UX/UI](ADR-0026-jerarquia-ux-ui.md)
- [ADR-0048: HUD, oleadas, cards y fachadas](ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md)
- [Arquitectura técnica](../design/03_TECHNICAL_ARCHITECTURE.md)
- [Pruebas de aceptación](../design/10_ACCEPTANCE_TESTS.md)
