# ADR-0037: Campaña de 45 rondas, roster y habilidades enemigas

- Fecha: 2026-10-09
- Estado: Aceptado por elección explícita del usuario; implementación integrada, aceptación de gameplay pendiente.
- Sustituye parcialmente: ADR-0016, ADR-0018, ADR-0032, ADR-0033, ADR-0035 y ADR-0036.
- Fuente de autoridad: el prompt adjunto del hito, las aclaraciones directas del usuario y los Resources activos. La wiki es referencia de parámetros individuales, no reemplaza las decisiones propias.

## Contexto

La especificación vigente tenía 20 rondas y designaba Cyclops y Werewolf como Minibosses en las rondas 17 y 19. El nuevo prompt entregó una tabla de 45 rondas, 26 tipos y 1.093 enemigos directos. La tabla no contiene Cyclops en la 17 ni Werewolf en la 19, y el usuario indicó que prevaleciera la tabla exacta. El calendario anterior no puede convivir como segunda autoridad.

El proyecto ya separaba los recursos de oleada, pero contaba pulsos replicados por endpoint. Con varias rutas, el total real cambiaba según el mapa; eso contradice la cantidad fija de la tabla.

La implementación previa tampoco modelaba muchas habilidades ligadas por el usuario a páginas individuales de Monsters. El Frost Keep era dominante y Tesla Coil debía recibir un recorte menor.

## Decisiones

1. La campaña contiene exactamente 45 recursos de oleada. La tabla de [14 — Campaña de 45 rondas](../design/14_CAMPANA_45_RONDAS.md) es la autoridad de orden y composición. Hay exactamente 1.093 enemigos directos; invocaciones de habilidades y fases transformadas son adicionales y no se incluyen en esa cifra.
2. WaveEnemyGroupData.count significa cantidad directa de ese tipo. WaveDirector genera uno por vez y rota entre rutas alcanzables. Cambiar cuántos endpoints están abiertos no cambia la cantidad total.
3. Las rondas 17 y 19 son encuentros `Boss` porque la tabla incluye Ooogie, cuyo perfil tiene `boss_tier = 1`. Cyclops y Werewolf siguen como unidades RT normales en las rondas donde aparecen; se retiran sus antiguas designaciones propias de Miniboss en 17/19.
4. Los 26 perfiles adoptan el nombre, las estadísticas individuales y las habilidades del roster indicado en el prompt cuando esas páginas dan el dato. La velocidad RT se convierte con el factor ya usado de 45 px/s. No se añade crecimiento por ronda. Datos de la wiki comunitaria quedan configurables y su versión/changelog oficial no se conoce; no se presentan como balance oficial actualizado.
5. Vampire adopta la ficha individual (5.000 Health, sin Armor/Shield, +100 Health/s, 1,75 velocidad, 23 Gold) aunque la tabla general Monsters consultada muestra otro bloque de HP. La ficha individual es la fuente elegida por el usuario para esa discrepancia.
6. Haste acumula hasta 60 y se degrada a 6 por segundo; mientras está activo aumenta la velocidad de movimiento en tantos puntos porcentuales como su fuerza. Fortification acumula hasta 60 y decae a 6 por segundo; mientras está activo resta 5 al daño base de cada ataque. Se usan 5 hex desde la base para triggers de cercanía y radio 2 alrededor del emisor para auras, según decisiones explícitas del usuario.
7. El jefe de balance propio es Ooogie von Ooogovich (Haunted). Invoca dos Bats cada 2 s y al morir se transforma en Bat con 2.500 Health. La transformación conserva una sola instancia activa y el pago por baja original; la oleada y su recompensa esperan la derrota de Bat. Health 8.000, Armor 1.500, Shield 2.000, regen 25 Health/s y 10 Shield/s, velocidad 26 px/s, daño a base 50 y 200 Gold son valores propios **provisionales**.
8. Se implementan las habilidades de invocación, transformación, teletransporte, Haste y Fortification declaradas por el roster. El árbol de Ooogiehedron crea Dodecahedron con 30.000 Shield, Octahedron con 20.000 Armor, Hexahedron con 10.000 Health y Tetrahedron con 10.000 Health; las variantes usan velocidad 1,3 RT. Las apariciones adicionales cuentan para la vida de la oleada.
9. Se conservan las recompensas de limpieza de rondas 1–20 de sus Resources antiguos. De la 21 a la 45 se asigna provisionalmente 100 + 5 × (ronda − 20), es decir, 105–225 Gold. Los intervalos 1–20 reutilizan el intervalo del primer grupo antiguo de cada ronda; las antiguas pausas de Miniboss en 17/19 se quitan. Las rondas 21–45 usan 0,5 s provisional. Grupos y tipos aparecen secuencialmente en el orden de la tabla.
10. Frost Keep queda en daño base 2, 120 RPM y Slow ×0,85 durante 1 s. En nivel 1 baja de 18 a 4 de daño por segundo antes de cobertura y cartas. Tesla Coil baja de daño base 10 a 9. Son nerfs propios provisionales.
11. Todo enemigo con sprite mira inicialmente hacia la derecha; el renderizado refleja el sprite horizontalmente al navegar hacia la izquierda y restaura su orientación al dirigirse hacia la derecha. Los 12 PNG nuevos se generan como arte original transparente de 256×256; no se importan assets de terceros.
12. Todo contenido que no se promovió queda en [Backlog de candidatos](../backlog/CONTENT_CANDIDATES.md). La tabla de composición no se duplica en otros documentos: deben enlazar a la campaña para conservar una autoridad.

## Consecuencias

- La dificultad total incluye enemigos directos y adicionales generados por habilidades. No debe confundirse el 1.093 de la tabla con el total final de apariciones.
- Las recompensas de baja son por instancia derrotada; un enemigo que transforma paga al final, mientras que sus invocaciones pueden pagar sus propias bajas.
- El escalado de Health, daño a base y Gold por baja permanece a 0. Las recompensas por limpiar 21–45 son provisionales y pueden cambiar.
- El Frost Keep conserva su carta Blizzard y sinergia de Path, pero su daño y Slow dejan de trivializar el recorrido; Tesla Coil solo pierde 10% de daño.
- Cada WaveData se valida en orden; WaveCampaignData comprueba 45 entradas, coincidencia entre tipo de encuentro y boss_tier y exactamente 1.093 enemigos directos.
- La progresión del terreno sigue entre las rondas 1–44; después de limpiar la 45, la run termina en victoria.
- Las decisiones históricas que mencionaban el calendario previo se conservan como antecedente y no describen ya el diseño activo.

## Fuentes

- Prompt de hito proporcionado por el usuario: prompt_codex_roguetower_45_oleadas.md, sección tabla de oleadas y páginas individuales, consultado el 2026-10-09.
- [Monsters — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Monsters), comunidad Fandom, consultada el 2026-10-09; sin edición oficial indicada.
- [Status Effects — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Status_Effects), comunidad Fandom, consultada el 2026-10-09.
- Aclaraciones explícitas del usuario: prioridad de la tabla exacta, nombre del jefe, invocación y transformación adaptadas, radios de 5/2 hex, y cierre de ronda tras la forma final.
