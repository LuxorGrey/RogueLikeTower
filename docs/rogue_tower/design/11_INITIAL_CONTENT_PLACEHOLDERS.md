# Placeholder Content for the Vertical Slice

Los nombres visibles siguen la nomenclatura aprobada. Los parámetros base de las siete torres y los perfiles normales de enemigos adoptan los valores publicados de Rogue Tower; las diferencias respecto a la wiki se corrigen con el changelog oficial. El progreso propio, los encuentros especiales y las composiciones de oleada sin dato publicado conservan sus reglas y valores configurables.

## Roster jugable de la DEMO

Por petición del usuario, los seis arquetipos aprobados y Shredder forman el roster jugable de esta demo. Sus parámetros base de Rogue Tower se adoptan según el catálogo y ADR-0036. Las reglas propias de niveles, cartas y costes de mejora que no estén publicadas o aprobadas se mantienen configurables en `data/towers/*.tres`.

| Atajo | Nombre canónico | Gameplay disponible |
|---:|---|---|
| 1 | Ballista | Un objetivo, versátil. |
| 2 | Mortar | Proyectil de largo alcance con explosión de área, mayor respuesta contra `Armor`. |
| 3 | Tesla Coil | Descarga arcana a todos los enemigos dentro del alcance; consume `Mana` por descarga. |
| 4 | Frost Keep | Impacto de área que aplica `Slow` y consume `Mana`. |
| 5 | Flame Thrower | Cono de fuego y `Burn` periódico; consume `Mana`. |
| 6 | Poison Sprayer | Cono de veneno y `Poison` periódico; consume `Mana`. |
| 7 | Shredder | Hoja que alcanza al objetivo, sigue `Path`, golpea cada enemigo una vez, pierde 1 de daño base por impacto y convierte el daño restante en `Bleed`. |

`TowerData` configura patrón de ataque, radio/ángulo/límite de objetivos, cadencia, costes, multiplicadores `Health`/`Armor`/`Shield`, tipo y color placeholder. Ballista usa proyectil de objetivo único; Mortar proyectil con explosión; Tesla Coil descarga contra todos los objetivos en su alcance circular; Frost Keep ataca un área cuadrada y aplica `Slow`; Flame Thrower y Poison Sprayer afectan un cono y convierten el 100% de su daño base en `Burn`/`Poison`; Shredder recorre `Path`. Shredder hace daño directo según la capa activa y además añade `Bleed` por el 100% del daño base restante de la hoja por enemigo (10, 9, 8…), perdiendo 1 de daño base por impacto. Todo pasa por `DamageService`; ADR-0023 documenta las reglas completas y sustituye las partes obsoletas de ADR-0014/0015. Los perfiles de diagnóstico M7/M8 siguen disponibles mediante `8` (Armor Piercing Bolt), `9` (Sapping Bolt) y `0` (Status Probe); son fixtures DEBUG y no forman parte del roster. La oleada DEBUG `Health/Armor/Shield` presenta las tres capas y regeneración independiente. Ooogie von Ooogovich usa su balance propio, convoca dos Bats y entra en su fase Bat al morir; la limpieza de ronda y su recompensa esperan la derrota final. No hay Support Buildings.

### Valores de referencia y adaptación

La tabla de referencia define los perfiles de base adoptados para las siete torres, salvo los nerfs propios seleccionados para Frost Keep y Tesla Coil. Los Resources siguen editables; costes, escalado por niveles, umbrales de XP, áreas y otros valores no fijados permanecen configurables.

| Torre | Daño | Multiplicador H/A/S | Alcance | RPM | Mana | Precio base (+incremento) |
|---|---:|---:|---:|---:|---|---:|
| Ballista | 10 | 10/5/5 | 5 | 20 | — | 10 (+15) |
| Mortar | 20 | 10/15/5 | 10 | 10 | — | 200 (+75) |
| Tesla Coil | 9 | 6/3/10 | 2 | 30 | 5/ataque | 200 (+75) |
| Frost Keep | 2 | 10/5/5 | 2 | 120 + 18 por PATH cubierto | 2/s | 250 (+100) |
| Flame Thrower | 6 | 6/9/3 | 4 | 60 | 1/ataque | 300 (+75) |
| Poison Sprayer | 5 | 6/3/9 | 4 | 60 | 1/ataque | 300 (+75) |
| Shredder | 10 | 20/10/10 | 5 | 5 | — | 500 (+100) |

Frost Keep aplica Slow ×0,85 durante 1 s; el perfil reduce su daño base a 2 y su cadencia a 120 RPM para esta demo. Tesla Coil reduce su daño base a 9. Estos son balances propios provisionales registrados en ADR-0037.

El modelo de cada enemigo contiene `Health`, `Armor` y `Shield`; cada perfil configura los máximos y cero desactiva una capa para esa unidad. El daño directo afecta solo a la capa activa, en orden `Shield → Armor → Health`, con daño base × multiplicador de esa capa; `Bleed`/`Burn`/`Poison` bloquean regeneración y dan +1 al multiplicador de los ataques directos contra su capa asociada. Sus ticks aplican el multiplicador completo en la capa asociada y 50% en las otras. El exceso se descarta en el mismo impacto; esa política sigue provisional porque la referencia no detalla el overkill. Shredder aplica impacto directo y `Bleed` igual al 100% del daño base restante como presupuesto de daño periódico. Los costes de mejora actuales (Ballista/Mortar 10(+10), Tesla Coil/Frost Keep 20(+20), Flame Thrower/Poison Sprayer/Shredder 30(+30)) son placeholders ajustables. El pool ofrece cartas propias y las correspondencias aprobadas `Blizzard` y `Advanced Circuits`; consulta [Nomenclatura](12_NOMENCLATURE.md) para los nombres que deliberadamente difieren de Rogue Tower. La tarjeta de prueba de capas no altera los enemigos de campaña.

El Goblin de ronda 1 tiene 100 Health, 0 Armor y 0 Shield. La Ballista base aplica 10 de daño × multiplicador Health 10 = 100 y lo elimina en un impacto. El exceso al vaciar una capa no se transfiere, decisión provisional de ADR-0023. Los 26 perfiles y sus estadísticas seleccionadas están en 13_CONTENT_ROSTER.md; cantidades y orden de las 45 rondas están únicamente en 14_CAMPANA_45_RONDAS.md. No hay Miniboss especial en 17/19. Ooogie von Ooogovich usa balance propio, invocaciones y fase Bat con espera de recompensa hasta la derrota final.

El tipo `POISON` pasa por `DamageService` y cada `EnemyData` puede definir su multiplicador recibido. Poison es un cuarto tag de daño provisional, además de Physical/Fire/Arcane. No se cambia el catálogo M8: Bleed permanece para las pruebas y para Shredder.

### Fuentes de referencia comunitaria

Consultadas el 2026-10-09. La wiki es una fuente comunitaria cambiante; sus parámetros base se adoptan por petición del usuario y los changelogs oficiales prevalecen si una ficha está obsoleta. Los cambios de balance propios siguen configurables.

- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers)
- [Ballista — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Ballista)
- [Mortar — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Mortar)
- [Tesla Coil — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Tesla_Coil)
- [Frost Keep — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Frost_Keep)
- [Flame Thrower — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Flame_Thrower)
- [Poison Sprayer — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Poison_Sprayer)
- [Shredder — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Shredder)
- [Hit Points — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Hit_Points)

Edición/versionado de la wiki no visible; consulta 2026-10-08. La información compartida por el usuario prevalece; la wiki solo aclara mecánicas no resueltas y no se trata como balance oficial.

M7 expone `Basic Bolt`, `Armor Piercing Bolt` (mitiga menos armor por impacto) y `Sapping Bolt` (tag Arcano y anti-regen temporal) como perfiles placeholder de prueba que comparten el mismo sprite vectorial. El enemigo `Armored Regenerator` y su oleada de diagnóstico también son fixtures; no son aún decisiones del contenido final. Todos los valores están configurados en Resources y detallados en ADR-0010.

M8 añade `Status Probe (DEBUG)`, con daño 1, cadencia 0.5/s y payloads Slow/Burn/Bleed, más `Objetivo de estados (M8 prueba)` (180 HP, velocidad 32, sin Armor ni regen). La oleada `m8_status_test` genera un objetivo. Slow dura provisionalmente 2.5 s y refresca a una acumulación; Burn dura 5 s, hace 2 de daño Fuego por tick de 1 s y acumula hasta 3; Bleed dura 1.5 s, hace 1.5 de daño Físico cada 0.75 s y usa acumulación aditiva hasta 4. El hueco de 0.5 s de Bleed entre impactos de la Status Probe ayuda a observar expiración. M9.5 conserva la oleada y mueve su atajo de diagnóstico a `0`. Son datos de demostración configurables, no balance ni catálogo confirmado; las reglas están en ADR-0012.

## Enemigos de prueba
1. Grunt — baseline.
2. Tank — armor alta.
3. Brute — health alta.
4. Regenerator — regen alta.
5. Runner — rápido/frágil.
6. Armored Regenerator — combinación.
7. Swarm — bajo HP, muchos.
8. Elite — test de presión.

La campaña de 45 rondas usa los 26 perfiles canónicos descritos en [Catálogo y escalado](13_CONTENT_ROSTER.md). La composición directa exacta, el orden y el total 1.093 están en [14 — Campaña de 45 rondas](14_CAMPANA_45_RONDAS.md). Los nombres siguen Rogue Tower; Cyclops/Werewolf no son designaciones Miniboss especiales en rondas 17/19. Ooogie von Ooogovich conserva identidad y habilidades adaptadas: invoca dos Bats cada 2 s y al morir se transforma en Bat con 2.500 Health, balance propio provisional; la oleada y recompensa esperan la derrota final. Todos los sprites se registran por perfil en assets/enemies/. Los perfiles adoptan habilidades y estadísticas individuales seleccionadas de las fichas comunitarias; esas cifras no determinan la tabla de composición.

## Piezas
El milestone M3 creó primero cinco plantillas de conexión para comprobar el contrato de colocación:
- straight;
- gentle_turn;
- hard_turn;
- fork;
- convergence;

M18 amplió el catálogo a quince piezas con seis paisajes Grass/Mountain y cuatro diseños PATH: `meadow_hills`, `mountain_massif`, `open_grassland`, `staggered_ridge`, `mountain_islet`, `twin_peaks`, `dead_end_spur`, `cliff_turn`, `meadow_switchback` y `three_way_ravine`. Quedan como propuestas todavía no implementadas: `mountain_reward`, `long_path` y `build_space`. No son requisitos técnicos nuevos del validador.

Cada pieza = 7 celdas conectadas, con coordenadas locales y sockets PATH configurables en `.tres`. Los sockets laterales opcionales se derivan de las salidas externas según [05_HEX_GRID_AND_TERRAIN.md](05_HEX_GRID_AND_TERRAIN.md). Todas las composiciones y pesos iniciales son temporales; la plantilla inicial del tablero está separada del pool de piezas.

## Cartas M11 de demo
El pool conserva 12 cartas originales más dos desbloqueables M12 y cuatro cartas M12A: `Impulso crítico global` (+15 % crítico global) y tres mejoras globales de multiplicador H/A/S (`Foco de Health`, `Foco de Armor`, `Foco de Shield`); total actual: 18 Resources. `Advanced Circuits` (+15 % crítico a Tesla Coil) y `Blizzard` (+0,5 hex de alcance a Frost Keep) son cartas del pool original con nombres canónicos. Los títulos con correspondencia y los nombres propios se explican en [Nomenclatura](12_NOMENCLATURE.md). El RPM de las torres permanece fijo salvo la cobertura de Frost Keep. Las cartas son una selección pequeña para la demo, no replican árboles completos del juego de referencia.

La oferta provisional muestra tres cartas después de colocar terreno al limpiar 3/6/9/12/15/18. Las cartas elegidas tienen máximo de una copia por run; las que no se eligen pueden aparecer en ofertas futuras. IDs, rarezas, pesos y cifras viven en `.tres` y son placeholders de balance, no cifras aprobadas ni copiadas de juegos de referencia. M12 conecta `unlock_requirement` a desbloqueos persistentes; en esta primera demo, Ballista es la única torre desbloqueada al comenzar; las otras seis se compran en la tienda.
