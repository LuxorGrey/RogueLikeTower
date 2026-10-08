# Monstruos — borrador personal

> **Estado:** datos de una wiki comunitaria usados como referencia, separados de las reglas propias confirmadas por el usuario. La demo tiene 20 rondas. Se añadirán salud, armadura y escudo en ese orden de daño (escudo → armadura → salud), conservando lo que ya funciona. No se incluye Tier 3.

## Reglas propias confirmadas por el usuario

- El juego tendrá capas de salud, armadura y escudo, agotadas en orden **escudo → armadura → salud**.
- Bleed detendrá la regeneración de salud, Burn la de armadura y Poison la de escudo, conservando el comportamiento actual de los estados.
- Vampire empieza en la ronda **23** en el diseño propio; queda fuera de la demo de 20 rondas. La cifra de la tabla de referencia (20) se conserva solo como dato de esa fuente.
- Habrá un jefe fijo de Tier 2 en la ronda **20**. Está pendiente elegir cuál de las tres variantes de la referencia será ese jefe.
- Aparecerán minijefes en las rondas **17 y 19**. Esta confirmación fija sus rondas; sus estadísticas y habilidades aún son provisionales.
- Las torres usarán multiplicadores de salud, armadura y escudo: daño base × multiplicador de la capa activa. Se preservará el comportamiento actual. Falta decidir qué pasa con el daño sobrante cuando una capa llega a cero.

## Reglas generales de la referencia

- Un monstruo puede tener salud, armadura y escudo; se agotan en ese orden. Bleed contrarresta regeneración de salud, Burn la de armadura y Poison la de escudo.
- La velocidad de las tablas es el valor publicado por la wiki, no una unidad compatible directamente con la velocidad del juego.
- Los monstruos normales hacen 1 de daño a la base; los jefes pueden destruirla de un golpe.
- El oro suele equivaler a la ronda en que empieza a aparecer; Goblin da 4. Los jefes dan más, y cada tipo de torre que haya dañado al enemigo añade 1 oro.
- La wiki también cita mejoras permanentes y cartas Banditry/Gold Rush! como fuentes de oro extra.
- En Single Defense hay un solo camino y 20 rondas. Los jefes aparecen en las rondas 15/25/35/45 y suelen dejar un cofre al morir; Big Brain Ooogie es la excepción. En esta demo solo cabe el jefe de la ronda 15.
- En la referencia, tras la ronda 15 cada ronda impar genera un mini-jefe con el doble de vida de un monstruo normal, daño alto a la base y posibilidad de dejar cofre. El usuario confirma apariciones en las rondas 17 y 19; el resto de esas mecánicas sigue siendo solo referencia.
- La wiki indica cofres de jefe con 1–3 extracciones en Single, 1–4 en Double y 1–5 en Triple Defense; cada extracción ofrece la mitad de cartas normales, redondeada hacia arriba. Solo Single Defense coincide con el alcance del proyecto.
- Solo aparece una familia de Tier 2 por partida: Haunted, Undead o Ephemerald.

## Tier 1 — rondas 1–15

Valores de la tabla que aportó el usuario. `H/A/E` = salud/armadura/escudo; `+n/s` indica regeneración.

| Monstruo | Desde | Vel. | H / A / E | Oro |
|---|---:|---:|---:|---:|
| [Goblin](https://rogue-tower.fandom.com/wiki/Goblin) | 1 | 2 | 100 / 0 / 0 | 4 |
| Orc | 3 | 2 | 300 / 0 / 0 | 3 |
| [Armored Goblin](https://rogue-tower.fandom.com/wiki/Armored_Goblin) | 5 | 1,75 | 400 / 200 / 0 | 5 |
| [Troll](https://rogue-tower.fandom.com/wiki/Troll) | 7 | 1,75 | 800 (+25/s) / 0 / 0 | 7 |
| Armored Orc | 9 | 1,75 | 400 / 600 / 0 | 9 |
| Battering Ram | 11 | 1 | 300 / 1500 / 0 | 11 |
| [Cyclops](https://rogue-tower.fandom.com/wiki/Cyclops) | 13 | 1,25 | 2000 / 0 / 0 | 13 |
| [Ooogie](https://rogue-tower.fandom.com/wiki/Ooogie), jefe | 15 | 1 | 20000 / 0 / 0 | 315 |

**Comportamientos distintivos consultados:** Armored Goblin concede 30 de Fortification a sí mismo y a monstruos cercanos al aparecer; Troll regenera 25 de salud/s; Cyclops concede 20 de Fortification a enemigos cercanos al morir; Ooogie obtiene 60 de Haste al aparecer y 60 de Fortification al quedar a 20 bloques de la base. Goblin se describe como enemigo básico sin ataque especial.

## Tier 2 — referencia completa hasta la familia que comienza en la ronda 25

La wiki sitúa Tier 2 entre las rondas 16–25. `—` = 0 en la tabla aportada. Las cifras y rondas de las tablas siguientes son las de referencia. Para el juego propio, Vampire empezará en la ronda 23 y quedará fuera de la demo; un jefe fijo de Tier 2 aparecerá en la ronda 20.

### Haunted

| Monstruo | Desde | Vel. | H / A / E |
|---|---:|---:|---:|
| [Witch](https://rogue-tower.fandom.com/wiki/Witch) | 16 | 3 | 1000 / — / 1000 |
| Bat | 18 | 3,6 | 2000 / — / — |
| [Vampire](https://rogue-tower.fandom.com/wiki/Vampire) | 20 | 2 | 3000 (+100/s) / — / 1000 |
| [Jack'o'Lantern](https://rogue-tower.fandom.com/wiki/Jack%27o%27Lantern) | 22 | 1,5 | 1000 / 5000 / — |
| [Werewolf](https://rogue-tower.fandom.com/wiki/Werewolf) | 24 | 2 | 3000 (+100/s) / — / 2000 |
| [Ooogie von Ooogovich](https://rogue-tower.fandom.com/wiki/Ooogie_von_Ooogovich), jefe | 25 | 1,1 | 40000 (+100/s) / — / — |

**Comportamientos:** Witch se acelera cerca de la base; Vampire regenera y al morir se convierte en Bat; Jack'o'Lantern aparece con Haste y, al perder su armadura, acelera a enemigos cercanos; Werewolf regenera, aparece con Haste y obtiene Fortification cerca de la base. Ooogie von Ooogovich invoca dos Bats cada 2 s y, al morir, se convierte en un Bat de 10000 de salud.

### Undead

| Monstruo | Desde | Vel. | H / A / E |
|---|---:|---:|---:|
| [Zombie](https://rogue-tower.fandom.com/wiki/Zombie) | 16 | 1 | 2000 / — / 4000 |
| Skeleton | 18 | 1,5 | 1000 / 4000 / — |
| [Lich](https://rogue-tower.fandom.com/wiki/Lich) | 20 | 1,75 | 4000 / — / 1000 |
| [Ghoul](https://rogue-tower.fandom.com/wiki/Ghoul) | 22 | 2,25 | 1000 / 3000 / — |
| Mummy | 24 | 1,25 | 1000 / 6000 (+100/s) / 1000 |
| [God King Ooogie](https://rogue-tower.fandom.com/wiki/God_King_Ooogie), jefe | 25 | 1,1 | 10000 (+100/s) / 60000 (+100/s) / — |

**Comportamientos:** Zombie aparece con Fortification; Lich cada 3 s elimina Bleed y cura 400 de salud a aliados cercanos; Ghoul aparece con Haste y al perder armadura gana Haste y Fortification; Mummy regenera armadura. God King Ooogie aparece con Haste y al perder armadura invoca cuatro Mummies.

### Ephemerald

| Monstruo | Desde | Vel. | H / A / E |
|---|---:|---:|---:|
| [Spirit](https://rogue-tower.fandom.com/wiki/Spirit) | 16 | 2 | 1000 / — / 2000 |
| Shadow | 18 | 1,75 | 1000 / — / 3000 |
| [Orb](https://rogue-tower.fandom.com/wiki/Orb) | 20 | 1 | 2000 / — / 6000 |
| [Ghost](https://rogue-tower.fandom.com/wiki/Ghost) | 22 | 2,25 | 4000 / — / — |
| [Phantom Warrior](https://rogue-tower.fandom.com/wiki/Phantom_Warrior) | 24 | 2 | 1000 / 1000 / 3000 |
| [Soul Shepherd Ooogie](https://rogue-tower.fandom.com/wiki/Soul_Shepherd_Ooogie), jefe | 25 | 1,1 | 10000 (+100/s) / — / 40000 (+100/s) |

**Comportamientos:** Spirit obtiene Haste al perder escudo; Orb se teletransporta 15 casillas al perderlo; Ghost no tiene ataque especial en su ficha; Phantom Warrior al perder escudo otorga Haste y Fortification a sí mismo y a enemigos cercanos. Soul Shepherd Ooogie aparece con Haste y, al perder escudo, invoca cuatro Ghosts y acelera a los cercanos.

## Pendiente antes de incorporar

- **Alcance de la demo:** Vampire comienza en ronda 23, según la aclaración del usuario, así que queda fuera de la demo. También quedan fuera las apariciones normales de Tier 2 que comienzan después de la ronda 20. El jefe fijo de Tier 2 y los minijefes de las rondas 17 y 19 sí forman parte del diseño confirmado.
- **Datos discrepantes de Vampire:** la tabla general aportada dice ronda 20 y 3000 de salud; la ficha individual consultada dice ronda 23 y 5000. La ronda queda resuelta por el usuario (23); la salud continúa pendiente de decidir si se usa ese enemigo en otro alcance.
- **Jefe de Tier 2:** la referencia lo sitúa en ronda 25; el usuario fija el jefe propio en ronda 20. Está pendiente elegir la variante fija entre Ooogie von Ooogovich, God King Ooogie y Soul Shepherd Ooogie.
- **Daño entre capas:** están confirmados el orden escudo → armadura → salud y el multiplicador de la capa activa. Falta decidir si el exceso de daño al vaciar una capa se transfiere a la siguiente o se pierde.
- **Páginas no legibles en esta consulta:** [Orc](https://rogue-tower.fandom.com/wiki/Orc), [Armored Orc](https://rogue-tower.fandom.com/wiki/Armored_Orc), [Battering Ram](https://rogue-tower.fandom.com/wiki/Battering_Ram), [Bat](https://rogue-tower.fandom.com/wiki/Bat), [Skeleton](https://rogue-tower.fandom.com/wiki/Skeleton), [Mummy](https://rogue-tower.fandom.com/wiki/Mummy) y [Shadow](https://rogue-tower.fandom.com/wiki/Shadow). No añado habilidades a esos monstruos sin poder verificar sus fichas individuales.
- Escudo, Haste, Fortification, teletransporte, invocaciones y habilidades de jefe requieren sistemas que el modelo actual del proyecto no confirma. No copiarlos como comportamiento definitivo.

## Fuentes

- [Monsters — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Monsters) y fichas individuales enlazadas en las tablas; comunidad Fandom, consulta: 2026-10-08.
- Los datos base se transcriben del extracto proporcionado por el usuario; las notas de comportamiento son resúmenes de fichas individuales consultables. Contenido comunitario CC BY-SA salvo indicación distinta; conservar atribución al reutilizarlo.
