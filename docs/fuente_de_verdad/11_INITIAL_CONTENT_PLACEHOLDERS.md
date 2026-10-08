# Placeholder Content for the Vertical Slice

Estos nombres/números son temporales y NO diseño final.

## Propuesta de torres para la DEMO M14

La lista de seis perfiles es una propuesta de roster para orientar el vertical slice, no confirma que las seis ya existan ni fija sus estadísticas. Los paralelos con Rogue Tower son de rol; no se copian cifras ni reglas de balance.

1. **Ballesta** — paralelo de rol: **Ballista**; torre generalista de objetivo único. `Basic Bolt` es el placeholder funcional más cercano, pero no es arte ni nombre final.
2. **Mortero** — paralelo: **Mortar**; largo alcance, cadencia lenta y daño de área con enfoque antiarmadura.
3. **Bobina Tesla** — paralelo: **Tesla Coil**; ataque de maná con potencial multiobjetivo.
4. **Guardafría** — paralelo: **Frost Keep**; usa maná para aplicar Slow.
5. **Lanzallamas** — paralelo: **Flame Thrower**; especialización en daño de Fuego/Burn periódico.
6. **Pulverizador venenoso** — paralelo: **Poison Sprayer**; especialización de daño periódico de veneno. El status Poison todavía no está implementado; queda para contenido posterior.

La implementación de M9 solo habilita economía/maná en el prototipo. Las únicas cuatro opciones disponibles en el HUD son Basic Bolt y tres perfiles de diagnóstico M7/M8; estos últimos no cuentan como roster final. No hay Support Buildings: ninguna torre de la propuesta requiere añadir edificios de soporte.

### Fuentes de referencia comunitaria

Consultadas el 2026-10-08. La wiki es contexto comunitario y puede cambiar; sus números, costes, multipliers y reglas no se usan como balance de este proyecto.

- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers)
- [Ballista — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Ballista)
- [Mortar — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Mortar)
- [Tesla Coil — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Tesla_Coil)
- [Frost Keep — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Frost_Keep)
- [Flame Thrower — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Flame_Thrower)
- [Poison Sprayer — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Poison_Sprayer)

Edición/versionado de la wiki no visible en las páginas consultadas; solo se tomaron los arquetipos/roles descritos.

M7 expone `Basic Bolt`, `Perforadora M7` (mitiga menos armor por impacto) y `Drenadora M7` (tag Arcano y anti-regen temporal) como perfiles placeholder de prueba que comparten el mismo sprite vectorial. El enemigo `Armored Regenerator` y su oleada de diagnóstico también son fixtures; no son aún decisiones del contenido final. Todos los valores están configurados en Resources y detallados en ADR-0010.

M8 añade `Sonda de estados (M8 prueba)`, con daño 1, cadencia 0.5/s y payloads Slow/Burn/Bleed, más `Objetivo de estados (M8 prueba)` (180 HP, velocidad 32, sin armadura ni regen). La oleada `m8_status_test` genera un objetivo. Slow dura provisionalmente 2.5 s y refresca a una acumulación; Burn dura 5 s, hace 2 de daño Fuego por tick de 1 s y acumula hasta 3; Bleed dura 1.5 s, hace 1.5 de daño Físico cada 0.75 s y usa acumulación aditiva hasta 4. El hueco de 0.5 s de Bleed entre impactos de la Sonda ayuda a observar expiración. Son datos de demostración configurables, no balance ni catálogo confirmado; las reglas están en ADR-0012.

## Enemigos de prueba
1. Grunt — baseline.
2. Tank — armor alta.
3. Brute — health alta.
4. Regenerator — regen alta.
5. Runner — rápido/frágil.
6. Armored Regenerator — combinación.
7. Swarm — bajo HP, muchos.
8. Elite — test de presión.

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
