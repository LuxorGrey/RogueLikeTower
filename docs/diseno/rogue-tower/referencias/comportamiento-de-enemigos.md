# Rogue Tower Wiki: comportamiento de enemigos

El usuario pide revisar habilidades y comportamiento del catálogo de enemigos a fondo. Esta ficha es el registro incremental de extracción; no es todavía una exportación completa de todas las páginas individuales. Fuente general: [Monsters](https://rogue-tower.fandom.com/wiki/Monsters), con ficha específica enlazada en cada entrada cuando se verifique. Wiki comunitaria CC BY-SA salvo indicación distinta. Consulta: 2026-10-06.

## Reglas de referencia confirmadas en el artículo general

- El artículo general explica velocidad hacia la torre base, capas Health/Armor/Shield, regeneración, oro, minijefes y jefes. No especifica que las especies cambien su algoritmo de ruta.
- La wiki no documenta decisiones de bifurcación por especie: *Rogue Tower* hace que los monstruos avancen hacia una base por los caminos generados y sus fichas describen sobre todo estadísticas, resistencias, buffs e interacciones temporales. Por tanto, no se puede atribuir a la wiki una preferencia de «camino más largo/corto» por enemigo. Para este juego, cualquier preferencia por rama será una regla nueva, explícita y fija; no se presentará como dato importado.
- Shield se agota antes que Armor; Armor antes que Health. Bleed detiene regeneración de Health, Burn la de Armor y Poison la de Shield.
- En la referencia, los monstruos hacen 1 de daño a la torre base; los jefes pueden destruirla de inmediato. Para el proyecto se adopta 1 de daño para una fuga ordinaria, fuga letal para jefe y 20 puntos de integridad inicial de la base. La cantidad 20 es decisión propia: el artículo general no da un valor universal de inicio.
- El artículo de wiki general no contiene todas las habilidades especiales individuales; por ello no se debe inventar un perfil por familia solo a partir de sus nombres.

## Habilidades individuales verificadas hasta ahora

| Enemigo | Habilidad descrita en la ficha | Lectura de diseño (no balance propio) | Estado de ruta |
|---|---|---|---|
| Goblin | Sin ataque especial | Enemigo básico, poca salud y gran amenaza por número | No se encontró cambio de ruta en la ficha consultada |
| Armored Goblin | Al aparecer, se da a sí mismo y a monstruos cercanos 30 de Fortification | Refuerza grupos cercanos; contrarrestar acumulación con daño enfocado | No se encontró cambio de ruta en la ficha consultada |
| Troll | Regenera 25 Health por segundo; sin ataques especiales | Es lento y resistente; Bleed frena su regeneración de Health | No se encontró cambio de ruta en la ficha consultada |
| Zombie | Al aparecer se otorga 30 de Fortification | Refuerzo defensivo propio al inicio; tiene Health y Shield | No se encontró cambio de ruta en la ficha consultada |
| Witch | Cerca de la torre base se otorga 60 de Haste | Aceleración tardía para castigar rutas largas y torres tardías | No se encontró cambio de ruta en la ficha consultada |
| Imp | Al aparecer, se da a sí mismo y a monstruos cercanos 60 de Haste | La oleada gana velocidad en grupo | No se encontró cambio de ruta en la ficha consultada |
| Jack'o'Lantern | Al aparecer se da 60 de Haste; al perder la armadura, vuelve a darse 60 de Haste a sí mismo y al grupo cercano | La pérdida de la primera capa puede acelerar de golpe a la formación | No se encontró cambio de ruta en la ficha consultada |
| Orb | Cuando pierde el escudo, se teletransporta 15 losetas hacia delante | Cruza distancia sobre el avance; para nuestro mapa debe saltar solo a un punto válido del mismo camino abierto | Teletransporte al frente al perder escudo |
| Sovereign Mind | Se teletransporta 6 losetas hacia delante cada 3 segundos | Movimiento de salto temporal; aplicar sobre la secuencia válida de camino | Teletransporte periódico hacia delante |
| Succubus | Cuando pierde Shield, se teletransporta 8 losetas hacia delante | Salto activado por capa; conservar la ruta asignada y avanzar dentro de esa secuencia | Teletransporte al frente al perder Shield |
| Fire Elemental | Inmune a Burn | Contrarresta defensas que dependen de aplicar Burn | No se encontró cambio de ruta en la ficha consultada |
| [Vampire](https://rogue-tower.fandom.com/wiki/Vampire) | Regenera 100 Health/s; al morir se transforma en un Bat | La muerte del cuerpo no elimina la amenaza; la forma resultante conserva el concepto de avance rápido | La ruta asignada al Vampire debe heredarse por el Bat invocado (adaptación propuesta) |
| [Lich](https://rogue-tower.fandom.com/wiki/Lich) | Cada 3 s elimina Bleed y cura 400 HP a monstruos cercanos | Apoyo de grupo que contrarresta Bleed y prolonga la supervivencia de aliados | No se encontró cambio de ruta en la ficha consultada |
| [Missile](https://rogue-tower.fandom.com/wiki/Missile) | Al aparecer obtiene 60 Haste | Unidad de aparición/ataque rápido; su Haste refuerza el movimiento | No se encontró cambio de ruta en la ficha consultada |
| [Eye](https://rogue-tower.fandom.com/wiki/Eye) | Al aparecer obtiene 60 Haste y 60 Fortification | Entra veloz y reduce el daño base recibido mientras se disipan los estados | No se encontró cambio de ruta en la ficha consultada |
| Ooogie (jefe) | Al aparecer obtiene 60 Haste; a 20 bloques de la base obtiene 60 Fortification | Fases espaciales basadas en distancia a la base | Mantiene avance hacia la base; no se encontró cambio de ruta |
| 6th Element Ooogie (jefe) | Inmune a Bleed/Burn/Poison; aparece con 60 Fortification; al perder Shield invoca cinco elementales y da 60 Haste/Fortification a sí mismo y enemigos cercanos | Jefe por fases de capa de vida que refuerza escolta | Habilidad documentada por HP, sin selección alternativa de ruta descrita |
| Robo Ooogie (jefe) | Invoca dos Missiles cada 5 s; al romper Shield/Armor invoca misiles y da 60 Haste/Fortification al grupo | Presión periódica más fases de armadura/escudo | Habilidad documentada por tiempo/capa, sin selección alternativa de ruta descrita |
| Ooogiehedron (jefe) | Aparece con 60 Fortification; al morir se divide en dos Dodeca-Ooogies, que a su vez se dividen en Octa-, Hexa- y Tetra-Ooogies | Eliminar el jefe no acaba instantáneamente con la presión: deja una cadena de unidades | Todas las fases heredan el mismo trayecto válido del jefe, recomendación de adaptación |
| Invader Ooogie (jefe) | Cada 5 s genera tres Dark Missiles; al perder Shield/Armor genera tropas y aplica 60 Haste/Fortification al grupo | Jefe de invocación recurrente y fases por capas | Habilidad documentada por tiempo/capa, sin selección alternativa de ruta descrita |
| Big Brain Ooogie (jefe) | Aparece con 60 Haste/Fortification; al perder Shield/Armor genera grupos distintos y vuelve a reforzar a los cercanos | Jefe con fases múltiples y refuerzos | Habilidad documentada por capas, sin selección alternativa de ruta descrita |

## Regla del proyecto para importar comportamientos

- Cada especie/familia tendrá un criterio de ruta **fijo, explícito y predecible**; no cambiará durante una run ni como reacción dinámica a las torres.
- Las habilidades de combate (regeneración, estados, buffs, invocación, vuelo/teletransporte u otras que documenten las fichas) se extraerán de la wiki una por una. La clasificación de ruta se mapeará por separado y solo se añadirá cuando exista respaldo concreto.
- Un salto o teletransporte de la referencia se adaptará como avance hacia delante en la secuencia de un camino abierto; nunca elegirá una rama distinta salvo que la ficha demuestre que esa especie cambia de ruta.
- Todos los enemigos del proyecto avanzan por caminos abiertos; campamentos cierran rutas. No hay cambios topológicos durante la oleada. La regla confirmada es que ningún enemigo se quede en bucle; si se permiten circuitos físicos, antes de la oleada se precomputará y fijará un recorrido sin nodos repetidos que acabe en la base.
- Los enemigos entran desde todos los extremos de camino abiertos, excepto el extremo ocupado por la base. El mapa empieza con loseta de base + loseta de camino y cada loseta nueva que contenga camino debe conectarse con la red existente; un camino abierto que no alcance la red de base es un estado inválido.
- Deben mostrarse antes de la oleada tanto la composición como las preferencias de ruta aplicables, para que el jugador pueda diseñar contra reglas invariables.

## Propuesta de preferencias de ruta por tipo

**Esta tabla es una propuesta de diseño, no un dato de la wiki.** La wiki de *Rogue Tower* no publica una selección de ramales por especie. Se propone asignar la política al tipo de enemigo por su perfil publicado (velocidad, capas, regeneración, movilidad y rol); la política permanece fija durante la run. “Más corta” presiona rutas rápidas y castiga defensas tardías; “más larga” fuerza a resistencias pesadas a recorrer más cobertura. Los teletransportes avanzan por la ruta seleccionada sin cambiar de rama. Se desempata con orden cardinal fijo N→E→S→O y se enseña la ruta elegida antes de la oleada.

| Política propuesta | Tipos del roster de referencia |
|---|---|
| Ruta más corta | Goblin, Orc, Witch, Bat, Ghoul, Spirit, Shadow, Orb, Ghost, Imp, Blink Dog, Succubus, Killbot, Wheelbot, Delivery Drone, Missile, Fire Elemental, Air Elemental, Tetrahedron, Hexahedron, Octahedron, Invader, Flying Saucer, Dark Missile, Cranial Carnivore, Ocular Observer, Hovering Portal, Sovereign Mind, Eye |
| Ruta más larga | Armored Goblin, Troll, Armored Orc, Battering Ram, Cyclops; todos los jefes: Ooogie, Ooogie von Ooogovich, God King Ooogie, Soul Shepherd Ooogie, Fallen Ooogie, Robo Ooogie, 6th Element Ooogie, Ooogiehedron, Invader Ooogie y Big Brain Ooogie; Vampire, Jack'o'Lantern, Werewolf; Zombie, Skeleton, Lich, Mummy; Phantom Warrior; Demon, Manticore; Technomancer, Tankbot; Earth Elemental, Water Elemental, Boron Elemental; Dodecahedron, Icosahedron; Tank, Mole Man, Death Walker; Assimilator |

El usuario aprobó esta asignación como base de balance. La política “rápido/móvil = corta; pesado/resistente/jefe = larga” es del proyecto y no está publicada por la wiki. Cada enemigo recibe una ruta cerrada de waypoints calculada antes del combate; se desempata de forma estable. Los circuitos físicos están permitidos, pero la ruta de movimiento es simple (sin nodos repetidos) y queda congelada durante la oleada. Si el prototipo hace costosa la búsqueda de rutas máximas, limitar el conjunto de candidatos de forma determinista sin cambiar el perfil asignado.

## Pendiente de extracción

Ver el índice [indice-y-cobertura.md](indice-y-cobertura.md). Faltan las habilidades y excepciones de las páginas individuales de monstruos/jefes, sus cambios de versión y si alguna habilidad afecta directamente el movimiento o la entrada/fuga. La tabla de estadísticas, por ahora, está en [monstruos-y-jefes.md](monstruos-y-jefes.md).

Fuentes específicas leídas: [Goblin](https://rogue-tower.fandom.com/wiki/Goblin), [Armored Goblin](https://rogue-tower.fandom.com/wiki/Armored_Goblin), [Witch](https://rogue-tower.fandom.com/wiki/Witch), [Imp](https://rogue-tower.fandom.com/wiki/Imp), [Jack'o'Lantern](https://rogue-tower.fandom.com/wiki/Jack%27o%27Lantern), [Orb](https://rogue-tower.fandom.com/wiki/Orb), [Sovereign Mind](https://rogue-tower.fandom.com/wiki/Sovereign_Mind), [Ooogie](https://rogue-tower.fandom.com/wiki/Ooogie), [6th Element Ooogie](https://rogue-tower.fandom.com/wiki/6th_Element_Ooogie), [Robo Ooogie](https://rogue-tower.fandom.com/wiki/Robo_Ooogie), [Ooogiehedron](https://rogue-tower.fandom.com/wiki/Ooogiehedron), [Invader Ooogie](https://rogue-tower.fandom.com/wiki/Invader_Ooogie), [Big Brain Ooogie](https://rogue-tower.fandom.com/wiki/Big_Brain_Oogie), [Monsters](https://rogue-tower.fandom.com/wiki/Monsters).
