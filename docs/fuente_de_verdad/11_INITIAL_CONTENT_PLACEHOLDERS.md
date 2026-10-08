# Placeholder Content for the Vertical Slice

Estos nombres/números son temporales y NO diseño final.

## Torres de prueba
1. Basic Bolt — generalista. M6 implementa la primera versión vectorial con estadísticas configurables en `data/towers/basic_bolt.tres`; M7 lo enruta por `DamageService`.
2. Breaker — mejor contra armor.
3. Executioner — mejor contra health.
4. Hexfire — Burn.
5. Frost — Slow.
6. Suppressor — anti-regen.

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
