# Placeholder Content for the Vertical Slice

Estos nombres/números son temporales y NO diseño final.

## Roster jugable de la DEMO

Por petición del usuario, los seis arquetipos aprobados y Shredder forman ahora el roster jugable antes de las cartas de mejora. Sus nombres y roles están confirmados para esta demo; costes, daño, alcance, cadencia y parámetros de estado son provisionales y se editan en `data/towers/*.tres`.

| Atajo | Nombre de trabajo | Paralelo de rol | Gameplay disponible |
|---:|---|---|---|
| 1 | Ballesta | Ballista | Un objetivo, versátil. |
| 2 | Mortero | Mortar | Área de impacto, largo alcance y mayor respuesta ante armadura. El impacto es hitscan en este prototipo. |
| 3 | Bobina Tesla | Tesla Coil | Cadena arcana de hasta tres objetivos, consume maná por descarga. |
| 4 | Guardafría | Frost Keep | Impacto de área que aplica Slow y consume maná. |
| 5 | Lanzallamas | Flame Thrower | Cono de Fuego y Burn periódico, consume maná. |
| 6 | Pulverizador venenoso | Poison Sprayer | Cono de Veneno y Poison periódico, consume maná. |
| 7 | Trituradora | Shredder | Hoja que alcanza al objetivo, sigue PATH, golpea cada enemigo una vez, pierde 1 daño base por impacto y convierte el daño restante en Bleed. |

`TowerData` configura patrón de ataque, radio/ángulo/límite de objetivos, tipo y color de placeholder. La hoja de Shredder vuela a la posición actual de su objetivo y luego recorre sus waypoints restantes; velocidad, radio de impacto y pérdida de daño por perforación también se configuran en su Resource. No hace daño directo: convierte todo su daño base restante por enemigo en un presupuesto bruto de Bleed repartido entre los ticks, que siguen usando `DamageService` y sus mitigaciones. ADR-0015 documenta el comportamiento. Los perfiles de diagnóstico M7/M8 siguen disponibles mediante `8` (Perforadora), `9` (Drenadora) y `0` (Sonda de estados), fuera de los siete botones principales. No hay Support Buildings.

### Valores de referencia y adaptación

La tabla de la imagen adjunta enumera daño, multiplicadores de Health/Armor/Shield, alcance, RPM, maná y precio para los siete arquetipos. Es contexto para los roles, no balance final del proyecto. Shredder usa 10 de daño base, alcance 5, 5 disparos/minuto y cero coste de maná; su primer enemigo recibe 10 de daño bruto como Bleed, no 20 de daño directo. La pérdida de 1 por cada enemigo perforado reduce el siguiente presupuesto. Su precio de compra del proyecto es 100 (la imagen muestra 500) para que pueda construirse con los 150 de oro iniciales de M9; las mejoras cuestan `[100, 200]`, frente al incremento orientativo de +100 de la imagen. Armor ×1 se conserva como mitigación del modelo local. Shield y las tres capas defensivas están confirmados como diseño futuro del usuario, aunque M9.5/M10 todavía usan el modelo implementado; ver [01_GAME_DESIGN_SOURCE_OF_TRUTH.md](01_GAME_DESIGN_SOURCE_OF_TRUTH.md). El resto de cifras vive en Resources y se ajusta a los roles/economía propios; no se copian precios ni multiplicadores de Rogue Tower.

El tipo `POISON` pasa por `DamageService` y cada `EnemyData` puede definir su multiplicador recibido. Poison es un cuarto tag de daño provisional, además de Physical/Fire/Arcane. No se cambia el catálogo M8: Bleed permanece para las pruebas y para Shredder.

### Fuentes de referencia comunitaria

Consultadas el 2026-10-08. La wiki es contexto comunitario y puede cambiar; sus números, costes, multipliers y reglas no se usan como balance de este proyecto.

- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers)
- [Ballista — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Ballista)
- [Mortar — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Mortar)
- [Tesla Coil — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Tesla_Coil)
- [Frost Keep — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Frost_Keep)
- [Flame Thrower — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Flame_Thrower)
- [Poison Sprayer — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Poison_Sprayer)
- [Shredder — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Shredder)

Edición/versionado de la wiki no visible; consulta 2026-10-08. Se toman los roles y la mecánica general como referencia comunitaria, no sus cifras de balance.

M7 expone `Basic Bolt`, `Perforadora M7` (mitiga menos armor por impacto) y `Drenadora M7` (tag Arcano y anti-regen temporal) como perfiles placeholder de prueba que comparten el mismo sprite vectorial. El enemigo `Armored Regenerator` y su oleada de diagnóstico también son fixtures; no son aún decisiones del contenido final. Todos los valores están configurados en Resources y detallados en ADR-0010.

M8 añade `Sonda de estados (M8 prueba)`, con daño 1, cadencia 0.5/s y payloads Slow/Burn/Bleed, más `Objetivo de estados (M8 prueba)` (180 HP, velocidad 32, sin armadura ni regen). La oleada `m8_status_test` genera un objetivo. Slow dura provisionalmente 2.5 s y refresca a una acumulación; Burn dura 5 s, hace 2 de daño Fuego por tick de 1 s y acumula hasta 3; Bleed dura 1.5 s, hace 1.5 de daño Físico cada 0.75 s y usa acumulación aditiva hasta 4. El hueco de 0.5 s de Bleed entre impactos de la Sonda ayuda a observar expiración. M9.5 conserva la oleada y mueve su atajo de diagnóstico a `0`. Son datos de demostración configurables, no balance ni catálogo confirmado; las reglas están en ADR-0012.

## Enemigos de prueba
1. Grunt — baseline.
2. Tank — armor alta.
3. Brute — health alta.
4. Regenerator — regen alta.
5. Runner — rápido/frágil.
6. Armored Regenerator — combinación.
7. Swarm — bajo HP, muchos.
8. Elite — test de presión.

M10 selecciona provisionalmente cuatro perfiles de campaña además del asaltante básico: acorazado, regenerador, minijefe genérico y jefe Tier 2 genérico. La composición y los stats configurables están en `data/enemies/campaign_*.tres`; los valores base y su crecimiento se registran en [ADR-0016](../decisiones/ADR-0016-campana-de-veinte-rondas.md). El jefe no representa una de las variantes comunitarias pendientes ni copia sus habilidades.

## Piezas
El milestone M3 crea primero cinco plantillas de conexión para comprobar el contrato de colocación:
- straight;
- gentle_turn;
- hard_turn;
- fork;
- convergence;

Quedan reservadas para expansión del pool de contenido: `mountain_reward`, `long_path` y `build_space`. Son propuestas de contenido placeholder, no requisitos técnicos nuevos de M3.

Cada pieza = 7 celdas conectadas, con coordenadas locales y sockets PATH configurables en `.tres`. Los sockets laterales opcionales se derivan de las salidas externas según [05_HEX_GRID_AND_TERRAIN.md](05_HEX_GRID_AND_TERRAIN.md). Todas las composiciones y pesos iniciales son temporales; la plantilla inicial del tablero está separada del pool de piezas.

## Cartas
Ejemplos de sistema:
- +mana max.
- +mana regen.
- +damage a familia.
- +range.
- +Burn duration.
- +Slow potency.
- +anti-regen.
- +economy.

Los valores concretos deben vivir en `.tres`.
