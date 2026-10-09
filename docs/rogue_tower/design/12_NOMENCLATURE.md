# Nomenclatura canónica

Esta página fija los nombres visibles y términos de juego. Se usa junto con el diseño activo y se actualiza con cualquier decisión que cambie nombres. La autoridad del proyecto está en [el índice](../README.md).

## Regla de asignación

- Se adopta el nombre inglés de Rogue Tower cuando el objeto propio cumple la misma función o el efecto de la carta es equivalente. Una diferencia de balance no cambia por sí sola el nombre; las diferencias de operación, alcance o tipo de efecto sí.
- Se conserva un nombre propio cuando la mecánica no tiene equivalente directo. No se toma prestado un nombre de Rogue Tower solo porque suene apropiado.
- La decisión de compartir un nombre no importa por sí sola estadísticas, habilidades, árbol de mejoras ni comportamiento. Los parámetros base de torres y enemigos normales se promovieron por separado mediante ADR-0035/0036; el diseño y los Resources vigentes especifican esos valores y las excepciones propias.
- El texto explicativo puede seguir en español; los nombres canónicos de entidades, estados, recursos y capas se escriben como en el juego de referencia.
- Los IDs internos, archivos y rutas permanecen estables al cambiar únicamente el nombre visible. Si un perfil genérico se divide en entidades distintas, se crean Resources e IDs separados y se actualizan sus referencias. Las entidades y estados toman sus nombres visibles de `display_name`; las etiquetas de encuentro, terreno y capa se fijan en sus enums/UI.

## Entidades de la demo

Todos los enemigos de la tabla de campaña usan los nombres visibles canónicos del roster seleccionado de Rogue Tower. La equivalencia del nombre no aprueba automáticamente cada habilidad o estadística: el contrato propio está en ADR-0037 y los valores por perfil en 13_CONTENT_ROSTER.md.

| Nombre visible canónico | Tipo | Observación |
|---|---|---|
| Goblin | Enemigo normal | Perfil de Rogue Tower. |
| Orc | Enemigo normal | Perfil de Rogue Tower. |
| Armored Goblin | Enemigo normal | Perfil de Rogue Tower. |
| Troll | Enemigo normal | Perfil de Rogue Tower. |
| Armored Orc | Enemigo normal | Perfil de Rogue Tower. |
| Battering Ram | Enemigo normal | Perfil de Rogue Tower. |
| Cyclops | Enemigo RT normal | No tiene designación propia de Miniboss; aparece solo donde indique la tabla. |
| Ooogie | Jefe Tier 1 | Nombre RT; perfil diferente de Ooogie von Ooogovich. |
| Witch | Enemigo Haunted | Nombre RT. |
| Bat | Enemigo Haunted | Nombre RT; también es fase final propia del jefe Ooogie von Ooogovich. |
| Vampire | Enemigo Haunted | Nombre RT; el Resource adopta su ficha individual seleccionada. |
| Jack'o'Lantern | Enemigo Haunted | Nombre de la tabla aprobada. |
| Werewolf | Enemigo Haunted normal | No tiene designación propia de Miniboss; aparece solo donde indique la tabla. |
| Ooogie von Ooogovich | Enemigo/jefe Haunted | Kit y balance propios; invoca Bats y usa una fase Bat. |
| Imp | Enemigo demonic | Nombre RT. |
| Blink Dog | Enemigo demonic | Nombre RT. |
| Demon | Enemigo demonic | Nombre RT. |
| Manticore | Enemigo demonic | Nombre RT. |
| Succubus | Enemigo demonic | Nombre RT. |
| Fallen Ooogie | Jefe | Se conserva el nombre de la tabla del prompt adjunto. |
| Tetrahedron | Enemigo geométrico | Nombre RT. |
| Hexahedron | Enemigo geométrico | Nombre RT. |
| Octahedron | Enemigo geométrico | Nombre RT. |
| Dodecahedron | Enemigo geométrico | Nombre RT. |
| Icosahedron | Enemigo geométrico | Nombre RT. |
| Ooogiehedron | Jefe final de la tabla | Nombre RT. |

Los 26 perfiles y sus apariciones exactas por ronda se detallan en 13_CONTENT_ROSTER.md y 14_CAMPANA_45_RONDAS.md. Cyclops y Werewolf solo tienen los perfiles normales de la tabla; se retiran las antiguas designaciones especiales de Miniboss para las rondas 17/19. Los tipos visibles de encuentro son Standard, Boss y Tier 2 Boss y se derivan de boss_tier. Ooogie y Ooogie von Ooogovich son Resources distintos.

Los fixtures que solo aparecen mediante DEBUG (dummies, objetivos de entrenamiento y perfiles M7/M8) se identifican como herramientas de prueba. No forman parte del roster de campaña.


## Estados, capas y recursos

| Término canónico | Uso en el proyecto |
|---|---|
| **Bleed** | Estado; corresponde a la capa `Health`. |
| **Burn** | Estado; corresponde a la capa `Armor`. |
| **Poison** | Estado; corresponde a la capa `Shield`. |
| **Slow** | Estado de ralentización. Frost Keep lo aplica con el balance propio de la demo. |
| **Haste** | Estado enemigo de velocidad; lo aplican habilidades de EnemyAbilityData. |
| **Fortification** | Estado enemigo de resistencia; resta cinco al daño base de cada golpe. |
| **Health** | Capa consumible de enemigo y multiplicador de daño de torre. |
| **Armor** | Capa consumible de enemigo y multiplicador de daño de torre. |
| **Shield** | Capa consumible de enemigo y multiplicador de daño de torre. |
| **Gold** | Moneda de la run. |
| **Mana** | Recurso de energía de la run. |
| **Meta Currency** | Moneda propia de progresión permanente; no es el Gold de una run ni un nombre importado de Rogue Tower. |
| **XP** | Experiencia de torre. |
| **Path**, **Grass**, **Mountain** | Tipos de terreno. `Path` no permite construir; `Grass` y `Mountain` son construibles según las reglas propias. |

En texto técnico se usa el orden `Shield → Armor → Health`, también cuando se escribe abreviado `H/A/S` para los multiplicadores. El catálogo activo de nombres incluye Bleed, Burn, Poison, Slow, Haste y Fortification. Freeze y las resistencias de estado no se promueven en este hito.

## Cards y mejoras permanentes

Solo se reutilizan títulos cuando la función coincide: **Blizzard**, **Advanced Circuits**, **Treasury**, **Sourcery** y **Mana Capacity**. Los efectos y cantidades conservan los valores propios del proyecto. Las tablas siguientes enumeran todos los Resources `CardData` y todas las mejoras permanentes actuales. “Propio” significa que no se reutilizó un título de referencia: conserva el nombre actual en español porque su operación o alcance no coincide directamente.

| Resource | Título visible | Decisión de nomenclatura |
|---|---|---|
| `data/cards/archive_burnished_blades.tres` | **Filos bruñidos** | Propio; otorga daño plano global mediante el Archivo. |
| `data/cards/archive_mana_channel.tres` | **Canalización** | Propio; mejora Mana durante la run mediante el Archivo. |
| `data/cards/ballista_calibrated_shot.tres` | **Disparo calibrado** | Propio; bonus de daño específico de Ballista. |
| `data/cards/efficient_circuits.tres` | **Circuitos eficientes** | Propio; reduce el coste de Mana de todas las torres. |
| `data/cards/flame_scorch.tres` | **Quemadura persistente** | Propio; prolonga Burn de Flame Thrower. |
| `data/cards/frost_long_reach.tres` | **Blizzard** | Título equivalente; aumenta el alcance de Frost Keep. |
| `data/cards/long_barrels.tres` | **Cañones largos** | Propio; aumenta el alcance de todas las torres. |
| `data/cards/mana_flow.tres` | **Flujo constante** | Propio; regeneración temporal de Mana durante una run, distinta de la mejora permanente Sourcery. |
| `data/cards/mana_reservoir.tres` | **Depósito de Mana** | Propio; capacidad temporal durante una run, distinta de la mejora permanente Mana Capacity. |
| `data/cards/monster_studies_health.tres` | **Foco de Health** | Propio; suma al multiplicador de Health; Monster Studies suma daño plano. |
| `data/cards/monster_studies_armor.tres` | **Foco de Armor** | Propio; suma al multiplicador de Armor; Monster Studies suma daño plano. |
| `data/cards/monster_studies_shield.tres` | **Foco de Shield** | Propio; suma al multiplicador de Shield; Monster Studies suma daño plano. |
| `data/cards/mortar_wider_blast.tres` | **Explosión amplia** | Propio; suma radio absoluto; Area of Effect lo aumenta en porcentaje. |
| `data/cards/poison_virulent_mix.tres` | **Mezcla virulenta** | Propio; prolonga Poison de Poison Sprayer. |
| `data/cards/precision_calibration.tres` | **Calibración de precisión** | Propio; bonus global de daño configurable. |
| `data/cards/quantity_over_quality.tres` | **Impulso crítico global** | Propio; concede +15% de crítico global; Quality over Quantity escala con el nivel y resta daño base. |
| `data/cards/shredder_sharp_teeth.tres` | **Dientes afilados** | Propio; prolonga Bleed de Shredder. |
| `data/cards/tesla_overcharge.tres` | **Advanced Circuits** | Título equivalente; concede +15% de probabilidad crítica a Tesla Coil. |

| Mejora permanente | Título visible | Decisión de nomenclatura |
|---|---|---|
| `data/meta/upgrades/starting_coffers.tres` | **Treasury** | Título equivalente para Gold inicial. |
| `data/meta/upgrades/mana_wellspring.tres` | **Sourcery** | Título equivalente para regeneración de Mana. |
| `data/meta/upgrades/mana_reservoir.tres` | **Mana Capacity** | Título equivalente para capacidad máxima de Mana. |
| `data/meta/upgrades/card_archive.tres` | **Archivo de cartas** | Propio; desbloquea contenido de cards en la meta-progresión. |
| `data/meta/upgrades/tower_calibration.tres` | **Calibración de torres** | Propio; bonus global de daño persistente. |

Un título compartido indica correspondencia de función, no igualdad de balance. Esta tabla es el mapa vigente para cambiar títulos; si la operación de una carta cambia, revisa su equivalencia antes de conservar el título.

## Fuentes de nombre

La lista de torres, enemigos, estados y cards se contrastó el 2026-10-09 con estas páginas de la wiki comunitaria de Rogue Tower, documentadas también en [Origen y referencias](../references/ORIGEN.md): [Towers](https://rogue-tower.fandom.com/wiki/Towers), [Monsters](https://rogue-tower.fandom.com/wiki/Monsters), [Status Effects](https://rogue-tower.fandom.com/wiki/Status_Effects), [Upgrade Cards](https://rogue-tower.fandom.com/wiki/Upgrade_Cards) y [Permanent Upgrades](https://rogue-tower.fandom.com/wiki/Permanent_Upgrades). La wiki sirve para comprobar escritura, parámetros comunitarios y correspondencia de nombres; los parámetros seleccionados se promueven mediante ADR-0035/0036 y las fuentes oficiales prevalecen ante changelogs más recientes.
