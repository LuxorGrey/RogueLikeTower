# Placeholder Content for the Vertical Slice

Estos nombres/números son temporales y NO diseño final.

## Torres de prueba
1. Basic Bolt — generalista. M6 implementa la primera versión vectorial con estadísticas configurables en `data/towers/basic_bolt.tres`; sus cifras son placeholders de sistema, no balance ni arte final.
2. Breaker — mejor contra armor.
3. Executioner — mejor contra health.
4. Hexfire — Burn.
5. Frost — Slow.
6. Suppressor — anti-regen.

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
