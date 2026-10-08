# ADR-0012 — Framework de efectos de estado M8

- Estado: aceptada provisionalmente para implementar y verificar M8.
- Fecha: 2026-10-08.
- Contexto: el roadmap M8 exige Slow, Burn y un tercer ejemplo provisional, además de duración, ticks, origen y reglas configurables de acumulación. El diseño no confirma catálogo ni resistencias.

## Decisiones

1. `StatusEffectData` es un Resource de contenido. `TowerData.status_effects` lista los efectos que entrega cada impacto; no se mutan los Resources compartidos durante el combate.
2. Cada `Enemy` tiene un `StatusEffectController` que conserva duración restante, acumulaciones, reloj del próximo tick y `source_id` por estado. Los efectos con el mismo ID se combinan dentro del mismo objetivo.
3. `REFRESH` deja una acumulación y reinicia la duración. `ADD_STACKS` añade una acumulación hasta `max_stacks` y reinicia la duración. Ambas reglas conservan la fase del próximo tick. La última aplicación del mismo ID define los datos y el origen activos.
4. Slow modifica el movimiento con `speed_multiplier`. Varios estados de movimiento se combinan usando el mínimo multiplicador activo y la velocidad vuelve a `1.0` al expirar o limpiar esos estados.
5. Burn y Bleed causan daño por tick. Cada tick crea un `DamagePacket` sin payloads de estado y usa el `DamageService` local a `Main`; sus tags pasan por la misma mitigación de armadura y multiplicadores de `EnemyData` que el daño directo.
6. Un efecto se elimina al agotarse su duración. Muerte y llegada a base limpian todos los estados. No se añade resistencia de estado hasta que exista una regla de diseño y datos que lo justifiquen.
7. Bleed se elige como tercer ejemplo para esta etapa, sin cerrar el catálogo. Los valores de Slow/Burn/Bleed, la Sonda de estados, el objetivo y la oleada de diagnóstico son fixtures provisionales.

## Consecuencias

- Los perfiles de torre pueden aplicar varios estados a la vez; el resultado de daño registra los IDs aceptados.
- El HUD de depuración muestra los estados y tiempos del objetivo de la torre seleccionada; el enemigo muestra un aro de color por los IDs temporales de esta demo.
- `Sonda de estados M8` y su oleada permiten comprobar refresco, acumulación limitada, daño periódico, expiración observable de Bleed y limpieza del ciclo de vida desde la escena principal.
- Los efectos de estado todavía no modifican la regeneración; anti-regen sigue siendo una capacidad separada de `DamagePacket`/`TowerData` de M7.
- Si una futura regla requiere acumulaciones con relojes u orígenes independientes por stack, se debe revisar el modelo antes de implementarla.

## Artefactos afectados

- `game/combat/status_effect_data.gd`
- `game/combat/status_effect_controller.gd`
- `game/combat/damage_packet.gd`, `game/combat/damage_result.gd`, `game/combat/damage_service.gd`
- `data/towers/tower_data.gd`, `game/towers/tower.gd`, `game/enemies/enemy.gd`, `game/enemies/path_follower_component.gd`
- `docs/fuente_de_verdad/02_IMPLEMENTATION_ROADMAP.md`, `03_TECHNICAL_ARCHITECTURE.md`, `04_DATA_MODELS.md`, `06_COMBAT_SYSTEM.md`, `09_PROGRESS.md`, `10_ACCEPTANCE_TESTS.md`, `11_INITIAL_CONTENT_PLACEHOLDERS.md`, `project_spec.json`
