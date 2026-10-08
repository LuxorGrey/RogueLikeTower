# Placeholder Content for the Vertical Slice

Estos nombres/números son temporales y NO diseño final.

## Roster jugable de la DEMO

Por petición del usuario, los seis arquetipos aprobados y Shredder forman el roster jugable de esta demo. Los nombres y roles están confirmados; los valores de la tabla compartida se usan como estadísticas iniciales de demo, no como balance final. Parámetros no especificados (costes de upgrade, áreas, velocidades y números de estado) siguen provisionales y configurables en `data/towers/*.tres`.

| Atajo | Nombre de trabajo | Paralelo de rol | Gameplay disponible |
|---:|---|---|---|
| 1 | Ballesta | Ballista | Un objetivo, versátil. |
| 2 | Mortero | Mortar | Proyectil de largo alcance con explosión de área, mayor respuesta ante armadura. |
| 3 | Bobina Tesla | Tesla Coil | Descarga arcana a todos los enemigos dentro del alcance, consume maná por descarga. |
| 4 | Guardafría | Frost Keep | Impacto de área que aplica Slow y consume maná. |
| 5 | Lanzallamas | Flame Thrower | Cono de Fuego y Burn periódico, consume maná. |
| 6 | Pulverizador venenoso | Poison Sprayer | Cono de Veneno y Poison periódico, consume maná. |
| 7 | Trituradora | Shredder | Hoja que alcanza al objetivo, sigue PATH, golpea cada enemigo una vez, pierde 1 daño base por impacto y convierte el daño restante en Bleed. |

`TowerData` configura patrón de ataque, radio/ángulo/límite de objetivos, cadencia, costes, multiplicadores H/A/S, tipo y color placeholder. Ballista usa proyectil de objetivo único; Mortar proyectil con explosión; Tesla descarga contra todos los objetivos en su alcance circular; Frost ataca un área cuadrada y ralentiza; Flame/Poison afectan un cono y convierten el 100% de su daño base en estado; Shredder recorre PATH. Shredder hace daño directo según la capa activa y además añade Bleed por el 100% del daño base restante de la hoja por enemigo (10, 9, 8…), perdiendo 1 de daño base por impacto. Todo pasa por `DamageService`; ADR-0023 documenta las reglas completas y sustituye las partes obsoletas de ADR-0014/0015. Los perfiles de diagnóstico M7/M8 siguen disponibles mediante `8` (Perforadora), `9` (Drenadora) y `0` (Sonda de estados). La oleada DEBUG adicional `Capas H/A/E` presenta un enemigo con Shield, Armor y Health y regeneración por capa. No hay Support Buildings.

### Valores de referencia y adaptación

La tabla que compartió el usuario se adopta como perfil estadístico inicial de la demo, no como balance final: los Resources son editables. El precio se expresa como base (+incremento por torre adicional del mismo tipo). `Frost Keep` empieza en 180 RPM y suma provisionalmente 18 RPM por cada celda PATH cubierta. Las mejoras de nivel, los umbrales de XP, áreas y velocidades no fijados en la tabla permanecen provisionales.

| Torre | Daño | Multiplicador H/A/E | Alcance | RPM | Maná | Precio base (+incremento) |
|---|---:|---:|---:|---:|---|---:|
| Ballista | 10 | 10/5/5 | 5 | 20 | — | 10 (+15) |
| Mortar | 20 | 10/15/5 | 10 | 10 | — | 200 (+75) |
| Tesla Coil | 10 | 6/3/10 | 1.5 | 30 | 5/ataque | 200 (+75) |
| Frost Keep | 6 | 10/5/5 | 2 | 180 + 18 por PATH cubierto | 2/s | 250 (+100) |
| Flame Thrower | 5 | 6/9/3 | 4 | 60 | 1/ataque | 300 (+75) |
| Poison Sprayer | 5 | 6/3/9 | 4 | 60 | 1/ataque | 300 (+75) |
| Shredder | 10 | 20/10/10 | 5 | 5 | — | 500 (+100) |

Las capas se resuelven Shield→Armor→Health; un golpe solo daña la capa activa y el exceso se descarta provisionalmente porque el material no define overkill. Shredder aplica impacto directo y Bleed igual al 100% del daño base restante como presupuesto de daño periódico. Los costes de upgrade actuales (Ballista/Mortar 10(+10), Tesla/Frost 20(+20), Flame/Poison/Shredder 30(+30)) son placeholders ajustables a partir de las páginas comunitarias. El pool de cartas ofrece una selección pequeña: mejoras por torre, crítico, maná, alcance/área/estado y +1 a cada multiplicador H/A/S global; no replica todos los árboles del juego de referencia. La tarjeta de prueba de capas no altera los enemigos de campaña.

El Asaltante básico de la ronda 1 tiene 100 Health, 0 Armor y 0 Shield. La Ballista inicial aplica 10 de daño base × 10 de multiplicador de Health = 100 y debe eliminarlo de un impacto. En enemigos con Armor o Shield, primero se consume solo la capa activa con el multiplicador propio de cada torre; el daño sobrante no se transfiere. El resto del balance de enemigos de campaña continúa siendo configurable y provisional.

El tipo `POISON` pasa por `DamageService` y cada `EnemyData` puede definir su multiplicador recibido. Poison es un cuarto tag de daño provisional, además de Physical/Fire/Arcane. No se cambia el catálogo M8: Bleed permanece para las pruebas y para Shredder.

### Fuentes de referencia comunitaria

Consultadas el 2026-10-08. La wiki es contexto comunitario y puede cambiar; la petición del usuario sí adopta la tabla numérica que pegó como base provisional para estos siete Resources. Los siguientes cambios de balance siguen siendo propios y configurables.

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

## Cartas M11 de demo
El pool conserva 12 cartas originales más dos desbloqueables M12, Cantidad sobre calidad (+15 % crítico global) y tres mejoras globales de multiplicador H/A/S; total actual: 18 Resources. Bobina sobrecargada añade +15 % crítico a Tesla Coil; el RPM de las torres permanece fijo salvo la cobertura de Frost Keep. Las cartas son una selección pequeña para la demo, no replican árboles completos del juego de referencia.

La oferta provisional muestra tres cartas después de colocar terreno al limpiar 3/6/9/12/15/18. Las cartas elegidas tienen máximo de una copia por run; las que no se eligen pueden aparecer en ofertas futuras. IDs, rarezas, pesos y cifras viven en `.tres` y son placeholders de balance, no cifras aprobadas ni copiadas de juegos de referencia. M12 conectará `unlock_requirement` a desbloqueos persistentes; en esta primera demo, los siete perfiles jugables actuales se consideran desbloqueados.
