# ADR-0010: pipeline central de daño y counters M7

- Estado: contrato histórico de M7; fórmula de mitigación plana sustituida por M12A/ADR-0023. Servicio, tags y fixtures de prueba siguen como referencia de la arquitectura original; sus cifras son provisionales. La expectativa de recompensas pendientes de M9 quedó resuelta por ADR-0013.
- Fecha: 2026-10-08.

## Contexto

M7 requiere que salud, armadura, regeneración, tipos/counters configurables y estadísticas de combate usen una sola ruta de resolución. M6 aplicaba el daño directamente desde `Tower`; esa decisión temporal ya no sirve porque repartiría fórmulas al añadir torres especializadas. El juego actual es 2D local, usa Resources para contenido y todavía no tiene modificadores de run, status ni recompensa por kill.

## Decisión

- `DamageService` vive como hijo de `Main` y se inyecta por `BuildController.configure()` a cada torre. No se crea un Autoload global para resolver combate de una run.
- `Tower` construye un `DamagePacket` por impacto con daño, instance ID de origen, bitmask de tags, multiplicadores de armadura/vida y counter anti-regen configurados por `TowerData`.
- El paquete es `RefCounted` transitorio. `DamageResult` registra armor absorbida, multiplicador de tipo, daño calculado/aplicado, fuerza y duración anti-regen y si el objetivo murió. El servicio expone `preview_damage()` para debug sin mutación y `apply_damage()` para resolver y emitir `damage_resolved`.
- Tags iniciales de prototipo: Físico (`1`), Fuego (`2`) y Arcano (`4`). Son categorías técnicas configurables, no catálogo o balance confirmados. Los multiplicadores de daño recibido están en `EnemyData`; los tags múltiples combinan sus multiplicadores por producto.
- Fórmula provisional: `armor_absorbed = min(raw_damage, armor * armor_multiplier)`. Después, `health_damage = floor(max(raw_damage - armor_absorbed, 0) * damage_tag_multiplier * health_multiplier)`. `HealthComponent` limita la aplicación a la vida actual. Un counter del paquete no transforma ni consume armor: modifica la regeneración aparte.
- `Enemy` aplica la regeneración por segundo usando un acumulador fraccional, solo en estado vivo/móvil, y la limita al HP máximo. El counter reduce la tasa por `regen_counter_strength` durante `regen_counter_duration`. Si se vuelve a aplicar antes de expirar, rige la fuerza más alta y el mayor tiempo restante; no hay stacks aditivos.
- El pipeline deja el campo `status_payloads` preparado, pero no lo procesa hasta M8. No hay proveedor de modificadores de run antes de M11; el servicio no inventa una lista de modificadores vacía. La muerte conserva el flujo de señales M5 y las recompensas esperan M9.
- La demo permite seleccionar Basic Bolt, Perforadora y Drenadora y una oleada M7 con un enemigo de prueba para exponer los counters desde HUD. Son fixtures temporales con un único placeholder visual.

## Consecuencias

- Las torres usan el mismo cálculo y pueden diferenciarse con datos sin duplicar código de mitigación.
- Se pueden configurar vulnerabilidades por tipo, resistencia de armor, daño a vida y supresión de regeneración por separado.
- En el contrato histórico M7, Armor era un stat defensivo plano y no una barra consumible. Esa regla quedó sustituida por M12A; la reducción a HP entero truncaba hacia abajo y `DamageResult` hacía observable un impacto de cero daño.
- Los números de la oleada diagnóstica permiten comparar perfiles, pero no fijan la curva de balance. La prueba manual y criterios de cierre están en `docs/rogue_tower/design/10_ACCEPTANCE_TESTS.md`.

## Referencias

- `docs/rogue_tower/design/02_IMPLEMENTATION_ROADMAP.md`, milestones M6–M9, consultado el 2026-10-08.
- `docs/rogue_tower/design/04_DATA_MODELS.md`, `06_COMBAT_SYSTEM.md`, `09_PROGRESS.md` y `10_ACCEPTANCE_TESTS.md`, consultados el 2026-10-08.
- `.agents/skills/godot-master/references/combat-system.md`, `resource-data-patterns.md` y `signal-architecture.md`, consultados el 2026-10-08.

## Cambio posterior en M9

Este ADR describe el pipeline de daño de M7, cuando todavía no había recompensa económica. M9 conecta las muertes de `Enemy` a los pagos de `WaveDirector`; el cálculo de daño sigue sin ser dueño del oro. Ver [ADR-0013](ADR-0013-economia-de-run-y-mana-m9.md).
