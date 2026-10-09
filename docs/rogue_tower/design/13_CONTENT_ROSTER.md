# Catálogo activo de torres, mejoras, enemigos y estados

Este catálogo resume el contenido ejecutable. Los Resources enlazados son la configuración numérica cargada; las reglas de campaña están en [45 rondas](14_CAMPANA_45_RONDAS.md), el vocabulario en [Nomenclatura](12_NOMENCLATURE.md), las fuentes en [Referencias](../references/02_monstruos.md) y los cambios aprobados en [ADR-0037](../decisions/ADR-0037-campana-de-45-rondas-y-habilidades.md). Los datos copiados de la wiki son referencia comunitaria configurable. El balance propio está marcado **provisional**.

## Torres

Multiplicadores en orden Health / Armor / Shield. El coste de construcción es Gold base más el incremento por cada torre previa del mismo tipo. Todas tienen nivel máximo 3. Cada nivel añade +1 daño base y +1 a un multiplicador de capa elegido; la elevación añade +1 daño base y +0,5 hex de alcance por nivel de altura.

| Torre | Función | Daño base; H/A/S | Alcance; cadencia | Mana | Construcción; mejora manual 2/3 |
|---|---|---:|---:|---:|---:|
| Ballista | Proyectil de objetivo único | 10; 10/5/5 | 5 hex; 20 RPM | — | 10 (+15); 10 / 20 |
| Mortar | Proyectil explosivo, radio 1,6 hex | 20; 10/15/5 | 10 hex; 10 RPM | — | 200 (+75); 10 / 20 |
| Tesla Coil | Descarga a todos los objetivos en rango | **9**; 6/3/10 | 2 hex; 30 RPM | 5 por ataque | 200 (+75); 20 / 40 |
| Frost Keep | Área de 1,2 hex; aplica Slow | **2**; 10/5/5 | 2 hex; **120 RPM** base | 2/s | 250 (+100); 20 / 40 |
| Flame Thrower | Cono de fuego de 58°; aplica Burn | 6; 6/9/3 | 4 hex; 60 RPM | 1 por ataque | 300 (+75); 30 / 60 |
| Poison Sprayer | Cono de veneno de 48°; aplica Poison | 5; 6/3/9 | 4 hex; 60 RPM | 1 por ataque | 300 (+75); 30 / 60 |
| Shredder | Hoja por Path; perfora y aplica Bleed | 10; 20/10/10 | 5 hex; 5 RPM | — | 500 (+100); 30 / 60 |

Frost Keep reduce su daño por segundo de 18 a 4 en nivel 1, antes de upgrades y cobertura Path: base 6→2 y cadencia 180→120 RPM. Su Slow pasa de 50% durante 2,5 s a **15% durante 1 s** (multiplicador 0,85). Tesla Coil baja el daño base de 10 a 9 (−10%). Estos son balances propios provisionales; ver ADR-0037. Frost Keep suma provisionalmente 18 RPM por cada celda Path cubierta. Tesla Coil, Flame Thrower y Poison Sprayer escalan el gasto de Mana con el daño.

Regla propia de Ballista: cada torre conserva su cooldown por disparo. Si el objetivo muere por otra fuente antes de que llegue el proyectil, esa Ballista recupera el 33% del cooldown completo del disparo; el impacto propio no reembolsa. Ver [ADR-0034](../decisions/ADR-0034-reembolso-de-cooldown-ballista.md).

## Mejoras durante la run: cards

Los nombres canónicos se reutilizan cuando la operación coincide con Rogue Tower. Las cartas con efecto distinto conservan nombre propio. Cada carta tiene un máximo de una copia por run.

| Card | Efecto runtime |
|---|---|
| Filos bruñidos | Todas las torres: +1 daño; desbloqueada por Archivo de cartas. |
| Canalización | +0,25 Mana/s; desbloqueada por Archivo de cartas. |
| Disparo calibrado | Ballista: +2 daño. |
| Circuitos eficientes | Todas las torres: coste de Mana ×0,85 (−15%). |
| Quemadura persistente | Burn de Flame Thrower: duración ×1,20. |
| Blizzard | Frost Keep: +0,5 hex de alcance. |
| Cañones largos | Todas las torres: +0,25 hex de alcance. |
| Flujo constante | +0,5 Mana/s. |
| Depósito de Mana | +20 Mana máximo. |
| Foco de Health | Todas las torres: +1 al multiplicador Health. |
| Foco de Armor | Todas las torres: +1 al multiplicador Armor. |
| Foco de Shield | Todas las torres: +1 al multiplicador Shield. |
| Explosión amplia | Mortar: +0,25 hex al radio. |
| Mezcla virulenta | Poison de Poison Sprayer: duración ×1,20. |
| Calibración de precisión | Todas las torres: daño ×1,10. |
| Impulso crítico global | Todas las torres: +15 puntos porcentuales de probabilidad crítica. |
| Dientes afilados | Bleed de Shredder: duración ×1,20. |
| Advanced Circuits | Tesla Coil: +15 puntos porcentuales de probabilidad crítica. |

El pool contiene 18 cards; el calendario y las rarezas siguen siendo provisionales. Los Resources individuales están en [data/cards](../../../data/cards/).

## Mejoras permanentes

Se aplican al comenzar cada run. Costes en Meta Currency por nivel.

| Mejora | Efecto por nivel | Niveles y costes |
|---|---|---|
| Treasury | +20 Gold inicial | 3; 10 / 20 / 35 |
| Sourcery | +0,25 Mana/s | 2; 15 / 30 |
| Mana Capacity | +15 Mana máximo | 2; 15 / 30 |
| Archivo de cartas | +2 cartas globales al pool | 1; 25 |
| Calibración de torres | Daño global ×1,05 | 3; 20 / 35 / 50 |

## Enemigos de campaña

Los valores se guardan en los perfiles enlazados de [data/enemies](../../../data/enemies/). Health / Armor / Shield; la velocidad ya está convertida a px/s con el factor configurado de 45 px/s por unidad de velocidad RT. Los enemigos normales hacen 1 de daño a la base. Los tres jefes de tabla que usan daño técnico de 100.000 representan “destruye la base de un golpe”. Los perfiles no ganan Health, daño a base o Gold por ronda; las tasas globales están en cero.

| Enemigo | Rondas en la tabla | Health / Armor / Shield | Velocidad | Daño base | Gold | Regeneración; habilidad |
|---|---|---:|---:|---:|---:|---|
| Goblin | 1–2, 3–4, 5–7, 11, 15–16, 23, 27, 45 | 100 / 0 / 0 | 90 | 1 | 4 | — |
| Orc | 3–4, 6–8, 12 | 300 / 0 / 0 | 90 | 1 | 3 | A 5 hex de base: Haste 15 propio y radio 2. |
| Armored Goblin | 5–8, 12–17, 20, 33 | 400 / 200 / 0 | 78,75 | 1 | 5 | Al aparecer: Fortification 30 propio y radio 2. |
| Troll | 7–10, 13, 18, 22, 31 | 800 / 0 / 0 | 78,75 | 1 | 7 | Health +25/s. |
| Armored Orc | 14–15, 28, 39 | 400 / 600 / 0 | 78,75 | 1 | 9 | A 5 hex de base: Fortification 30 propio y radio 2. |
| Battering Ram | 11–12, 14–17, 19, 21, 41 | 300 / 1500 / 0 | 45 | 1 | 11 | Al vaciar Armor: Haste 15 propio. Al morir: 1 Armored Goblin + 4 Goblins. |
| Cyclops | 13–16, 18, 26, 36 | 2.000 / 0 / 0 | 56,25 | 1 | 13 | Al morir: Fortification 20 a enemigos en radio 2. Es unidad normal en la tabla. |
| Ooogie | 15, 17–19, 25, 29, 37, 42 | 20.000 / 0 / 0 | 45 | 100.000* | 315 | Al aparecer: Haste 60 propio. A 5 hex de base: Fortification 60 propio. |
| Witch | 16–18, 20, 22, 24, 30, 32, 40 | 1.000 / 0 / 1.000 | 135 | 1 | 16 | A 5 hex de base: Haste 60 propio. |
| Bat | 19–21, 34, 38 | 2.000 / 0 / 0 | 162 | 1 | 18 | — |
| Vampire | 19–20, 22, 26, 31, 35 | 5.000 / 0 / 0 | 78,75 | 1 | 23 | Health +100/s. Al morir se transforma en Bat. |
| Jack'o'Lantern | 21, 23–25, 28, 33, 43 | 1.000 / 5.000 / 0 | 67,5 | 1 | 22 | Al aparecer: Haste 60 propio. Al vaciar Armor: Haste 60 propio y radio 2. |
| Werewolf | 21–24, 27, 33, 44 | 3.000 / 0 / 2.000 | 90 | 1 | 24 | Health +100/s. Al aparecer: Haste 60 propio. A 5 hex de base: Fortification 60 propio. |
| Ooogie von Ooogovich (Haunted) | 24–26, 29, 35, 41 | **8.000 / 1.500 / 2.000** | 26 | 50 | 200 | Health +25/s; Shield +10/s. Balance propio: Haste 60; 2 Bats cada 2 s; al morir pasa a Bat con 2.500 Health. |
| Imp | 28, 31–32 | 7.000 / 0 / 0 | 90 | 1 | 26 | Health +200/s. Al aparecer: Haste 60 propio y radio 2. |
| Blink Dog | 23, 25–27, 30, 33, 39 | 6.000 / 0 / 2.000 | 90 | 1 | 28 | Health +200/s. Cada 6 s se teletransporta 5 hex hacia delante. |
| Demon | 28–29, 31, 36, 45 | 6.000 / 0 / 4.000 | 78,75 | 1 | 30 | Health +200/s; Shield +200/s. Al vaciar Shield: Fortification 30 propio y radio 2. |
| Manticore | 27, 30, 34–35, 38, 40 | 12.000 / 4.000 / 0 | 56,25 | 1 | 32 | Health +200/s. |
| Succubus | 29–30, 32, 37, 39, 42–43 | 4.000 / 0 / 6.000 | 90 | 1 | 34 | Health +200/s. Al vaciar Shield: se teletransporta 8 hex hacia delante. |
| Fallen Ooogie | 34, 36, 41 | 100.000 / 0 / 40.000 | 54 | 100.000* | 2.035 | Health +200/s; Shield +200/s. Al aparecer: Haste 60 propio. Cada 3 s: Fortification 20 en radio 2. Al vaciar Shield: 3 Blink Dogs + Fortification 60 propio y radio 2. |
| Tetrahedron | 33, 38 | 7.000 / 2.000 / 0 | 90 | 1 | 36 | Health +300/s; Armor +300/s. |
| Hexahedron | 35–37, 40, 42, 44 | 11.000 / 0 / 0 | 72 | 1 | 38 | Health +300/s. Al morir: Tetrahedron variante. |
| Octahedron | 38–40, 43–45 | 13.000 / 0 / 3.000 | 72 | 1 | 40 | Health +300/s; Shield +300/s. Cada 5 s salta 7 hex. Al morir: Hexahedron variante. |
| Dodecahedron | 37, 43–44 | 15.000 / 3.000 / 3.000 | 63 | 1 | 42 | Health, Armor y Shield +300/s. Al aparecer: Fortification 30. Al morir: Octahedron variante. |
| Icosahedron | 41–42 | 9.000 / 9.000 / 9.000 | 54 | 1 | 44 | Las tres capas +300/s. Al aparecer: Haste 60. Al morir: Dodecahedron. |
| Ooogiehedron | 45 | 70.000 / 70.000 / 70.000 | 58,5 | 100.000* | 5.045 | Las tres capas +300/s. Al aparecer: Fortification 60. Al morir: 2 Dodecahedron variantes. |

*Las cantidades y el orden exactos por ronda están en [14 — Campaña de 45 rondas](14_CAMPANA_45_RONDAS.md). Los grupos de variantes del Ooogiehedron heredan el perfil ordinario y aplican el stat override que publica la página: Dodecahedron con Shield 30.000; luego Octahedron con Armor 20.000; Hexahedron con Health 10.000; Tetrahedron con Health 10.000. Todas esas formas usan velocidad 1,3 RT (58,5 px/s). Los atributos no indicados por la página los hereda cada perfil base. Los jefes Tier 1/Tier 2 y los grupos añadidos por habilidades no multiplican el conteo directo de la tabla.

Los valores del roster normal copian las páginas individuales de la wiki indicadas por el usuario. **Vampire** usa la ficha individual (5.000 Health, sin Shield); difiere de la tabla general Monsters consultada, que muestra 3.000 Health y 1.000 Shield. Se eligió la ficha individual para esta implementación y se registra la discrepancia en [Referencias](../references/02_monstruos.md). Fallen Ooogie conserva los datos de la página vinculada en el prompt adjunto; ese nombre puede aparecer como alias histórico en la wiki. La tabla adjunta manda sobre el nombre de su grupo y su cantidad.

El jefe Ooogie von Ooogovich usa parámetros propios provisionales, no la ficha genérica de la wiki. Su muerte transforma la misma instancia a Bat con 2.500 Health. El conteo activo no baja en la transición: no se paga la baja ni se completa la ronda hasta derrotar Bat. Se paga una baja del jefe original al final; Bats invocados y otros enemigos invocados sí tienen sus recompensas individuales.

## Escalado

No se añade crecimiento global por ronda a los perfiles RT. Las tasas Health, daño base y Gold por ronda de WaveCampaignData son 0.

| Atributo | Fórmula en campaña | Factor |
|---|---|---:|
| Health máximo | base × (1 + 0 × (ronda − 1)) | ×1,00 |
| Daño a base | base × (1 + 0 × (ronda − 1)) | ×1,00 |
| Recompensa por baja | base × (1 + 0 × (ronda − 1)) | ×1,00 |

Los premios por limpiar rondas 1–20 conservan sus datos previos. Para 21–45 se usa un crecimiento propio provisional de 100 + 5 × (ronda − 20). No modifica el Gold de las bajas.

## Estados

| Estado | Configuración del juego | Efecto / escalado |
|---|---|---|
| Bleed | 1,5 s; tick cada 0,75 s; 1,5 Physical por tick; máximo 4 acumulaciones | Detiene regeneración Health; ataques directos reciben +1 al multiplicador Health. El tick hace 100% en Health y 50% en Armor/Shield. |
| Burn | 5 s; tick cada 1 s; 2 Fire por tick; máximo 3 acumulaciones | Detiene regeneración Armor; ataques directos reciben +1 al multiplicador Armor. El tick hace 100% en Armor y 50% en Health/Shield. |
| Poison | 4 s; tick cada 1 s; 2 Poison por tick; máximo 3 acumulaciones | Detiene regeneración Shield; ataques directos reciben +1 al multiplicador Shield. El tick hace 100% en Shield y 50% en Health/Armor. |
| Slow | 1 s; no causa daño; una acumulación | Multiplicador de movimiento 0,85: ralentiza 15%. |
| Haste | EnemyData: fuerza 0–60; decae a 6/s | Aumenta movimiento hasta 60%; máximo 10 s a fuerza 60. Nuevas aplicaciones suman hasta el máximo. |
| Fortification | EnemyData: fuerza 0–60; decae a 6/s | Mientras su fuerza es positiva, reduce en 5 el daño base bruto de cada ataque; máximo 10 s a fuerza 60. Nuevas aplicaciones suman hasta el máximo. |

Los estados Bleed, Burn, Poison y Slow provienen de los payloads de torre; Haste y Fortification son estados de enemigos aplicados por sus habilidades. Sus fuentes de referencia y la selección propia están en [Status Effects](https://rogue-tower.fandom.com/wiki/Status_Effects) y ADR-0037. No se implementan Freeze ni resistencias de estado en este hito.
