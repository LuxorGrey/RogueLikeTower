# ADR-0022: Meta-progresión persistente entre runs

- Estado: Aceptada para implementación M12. M12A/ADR-0023 amplían después el pool de 14 cartas a 18.
- Fecha: 2026-10-08.
- Contexto: M9/M10/M11 ya implementan oro/maná temporales, una campaña de 20 rondas y cartas de mejora de run. El diseño confirma meta-moneda al perder o completar, tienda permanente, desbloqueos y el ciclo morir→mejorar→nueva run. Las cantidades y el catálogo siguen abiertos.

## Decisiones

1. `MetaProgression` conserva moneda, torres desbloqueadas, niveles permanentes, contadores y último resumen en un Autoload que sobrevive al reinicio de la escena. `RunEconomyService` sigue siendo el dueño de oro/maná temporales.
2. `finish_run()` solo puede cerrar/recompensar una run activa una vez. La fórmula de demo se configura en `MetaProgressionData`: `base + rondas completas × incremento`, más bonus de victoria y con tope. La primera pérdida entrega una cantidad mínima, pero avanzar rondas aumenta la recompensa. La fórmula demo actual es 5 + 5 por ronda completa + 30 por vencer, máximo 1000.
3. Ballista es el único unlock inicial provisional. Los otros seis perfiles tienen `unlock_id` estable y coste meta configurable en `TowerData`. El HUD oculta los perfiles bloqueados y `BuildController` también rechaza su construcción. Los mismos IDs alimentan `RunCardService`.
4. `PermanentUpgradeData` guarda costes por nivel, prerrequisitos y una operación por nivel. La demo ofrece bonos de oro inicial, capacidad/regeneración de maná, multiplicador global de daño y una mejora de pool de cartas. Sus efectos se calculan desde el estado meta al preparar la siguiente run; no editan Resources compartidos.
5. La tienda aparece sobre la escena terminal y permite comprar y luego recargar la escena para iniciar una nueva run. En M12 el pool M11 mantenía 12 opciones base y añadía dos cartas filtradas por `meta:card_archive` después de comprar el Archivo; el pool actual de 18 está descrito en ADR-0023.
6. `SaveData` usa JSON primitivo versionado bajo `user://rogue_tower_meta.json`; escribe temporal, rota el save anterior a `.bak` y reemplaza el principal. No guarda Nodes/Resources/runtime de la run. La versión 0 (incluido un `version` ausente) y la versión actual 1 se cargan/migran si el resto del esquema es válido; campos enteros del JSON (versión, moneda, contadores y niveles) aceptan valores numéricos finitos sin parte decimal aunque Godot los entregue como `float`. La migración escribe versión 1 y conserva el original como `.bak`. JSON corrupto o una versión futura desconocida cae a defaults de sesión, conserva el archivo y bloquea operaciones de compra/guardado.
7. La seed de run se registra en resumen y alimenta los RNG locales de oferta de cartas y selección/relleno del terreno para poder reproducir la secuencia al repetir las mismas acciones.

## Consecuencias

- El flujo técnico `RUN_VICTORY`/`RUN_DEFEAT` pasa a resumen/tienda y «Empezar nueva run» conserva el progreso comprado.
- La barra de construcción puede mostrar menos de siete torres hasta adquirir unlocks; las pruebas de diagnóstico con `unlock_id` vacío siguen disponibles en sus atajos.
- Los valores iniciales, recompensas, costes de desbloqueo y upgrades son placeholders editables y no balance final. El refinamiento visual de tienda queda para M13.
- La prueba manual de guardado, compras, filtros, bonus y recuperación está pendiente y se especifica en `docs/fuente_de_verdad/10_ACCEPTANCE_TESTS.md`.
- Las seis rotaciones del tablero inicial siguen el contador persistente de runs; el contador ya guardado también evita que al reiniciar la aplicación se repita la orientación anterior.
