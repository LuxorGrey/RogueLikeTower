# Monstruos — borrador personal

> **Estado:** referencia comunitaria e histórica. Sus tablas describen el snapshot consultado, no el contenido ejecutable propio. La composición de campaña vigente está en [la tabla exacta de 45 rondas](../design/14_CAMPANA_45_RONDAS.md); los perfiles, nombres y habilidades promovidos están en [el catálogo activo](../design/13_CONTENT_ROSTER.md). Wiki Fandom consultada el 2026-10-09; edición/changelog de la página no indicados.

> **Nota de autoridad:** la antigua campaña de veinte rondas, los Minibosses propios de 17/19 y las cantidades inferidas de esta ficha quedaron sustituidos por ADR-0037. La tabla de usuario manda sobre número y orden; la wiki sirve para los perfiles individuales seleccionados.
## Reglas propias confirmadas en el diseño activo

- El modelo de cada enemigo implementa Health, Armor y Shield, agotados en orden Shield → Armor → Health; los perfiles configurables determinan máximos y regeneración.
- Bleed detiene la regeneración de Health y añade +1 al multiplicador de ataques directos contra esa capa; Burn lo hace para Armor y Poison para Shield. Los ticks aplican daño completo en su capa y la mitad en las otras.
- La demo usa los 26 perfiles y 1.093 enemigos directos de la tabla adjunta; ver 14_CAMPANA_45_RONDAS.md. Esta elección sustituye el alcance anterior de veinte rondas.
- Ooogie von Ooogovich (Haunted) conserva identidad propia, invoca dos Bats cada 2 s y se transforma en Bat con balance propio provisional. La ronda espera su derrota final.
- La composición seleccionada no designa Minibosses especiales en las rondas 17 ni 19. Cyclops y Werewolf son enemigos normales cuando aparecen en la tabla.
- Haste y Fortification se aplican por habilidades enemigas: fuerza máxima 60, decaimiento 6/s, radio de aura 2 hexágonos y trigger cerca de la base a 5 hexágonos. Sus reglas y triggers por perfil están en 13_CONTENT_ROSTER.md.

## Reglas generales de la referencia

- Un monstruo puede tener Health, Armor y Shield; se agotan en ese orden. Bleed contrarresta regeneración de Health, Burn la de Armor y Poison la de Shield.
- La velocidad de las tablas es el valor publicado por la wiki, no una unidad compatible directamente con la velocidad del juego.
- Los monstruos normales hacen 1 de daño a la base; los jefes pueden destruirla de un golpe.
- El oro suele equivaler a la ronda en que empieza a aparecer; Goblin da 4. Los jefes dan más, y cada tipo de torre que haya dañado al enemigo añade 1 oro.
- La wiki también cita mejoras permanentes y cartas Banditry/Gold Rush! como fuentes de oro extra.
- La información de reglas/modos de Rogue Tower que sigue es contexto de referencia y no define las reglas del juego propio.
- En la referencia, tras la ronda 15 cada ronda impar genera un mini-jefe con el doble de vida de un monstruo normal, daño alto a la base y posibilidad de dejar cofre. El usuario confirma apariciones en las rondas 17 y 19; el resto de esas mecánicas sigue siendo solo referencia.
- La wiki indica cofres de jefe con 1–3 extracciones en Single, 1–4 en Double y 1–5 en Triple Defense; cada extracción ofrece la mitad de cartas normales, redondeada hacia arriba. Solo Single Defense coincide con el alcance del proyecto.
- Solo aparece una familia de Tier 2 por partida: Haunted, Undead o Ephemerald.

## Tier 1 — rondas 1–15

Valores de la tabla que aportó el usuario. `H/A/S` = Health/Armor/Shield; `+n/s` indica regeneración.

| Monstruo | Desde | Vel. | H / A / S | Gold |
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

La wiki sitúa Tier 2 entre las rondas 16–25. `—` = 0 en la tabla aportada. Este párrafo conserva el estado de promoción anterior a ADR-0037: entonces se había limitado la familia Haunted a la ronda 20 y se había propuesto una colocación fija para `Ooogie von Ooogovich`. Ambas limitaciones quedaron sustituidas; consulta el [roster activo](../design/13_CONTENT_ROSTER.md) y la [tabla exacta](../design/14_CAMPANA_45_RONDAS.md).

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

## Límites y discrepancias de la referencia

- La página general Monsters publica apariciones iniciales, parámetros base y lista de unidades, pero no cantidades/grupos exactos por oleada. La composición propia procede exclusivamente de la tabla adjunta seleccionada por el usuario.
- Vampire tiene valores diferentes entre la tabla general y su ficha individual. El Resource propio adopta la ficha individual de 5.000 Health sin Shield; la decisión está registrada en ADR-0037.
- Las habilidades individuales de jefes y de los polígonos pueden incluir estados, invocaciones, fases y overrides. El catálogo activo detalla qué mecánicas se implementan y qué balance es propio.
- El daño sobrante al vaciar una capa no tiene regla confirmada por el artículo; el proyecto lo descarta provisionalmente según ADR-0023.
- Esta referencia no reemplaza la nomenclatura visible de 12_NOMENCLATURE.md ni la composición de 14_CAMPANA_45_RONDAS.md.
## Fuentes

- [Monsters — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Monsters) y fichas individuales enlazadas en las tablas; comunidad Fandom, consulta: 2026-10-09.
- Los datos base se transcriben del extracto proporcionado por el usuario; las notas de comportamiento son resúmenes de fichas individuales consultables. Contenido comunitario CC BY-SA salvo indicación distinta; conservar atribución al reutilizarlo.
