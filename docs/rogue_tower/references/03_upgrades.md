# Upgrades — borrador personal

> **Estado:** resumen histórico de mejoras de referencia, no balance ni progresión aprobada. Las mejoras permanentes y las cartas durante una run son sistemas distintos. El proyecto actual implementa una demo de 45 rondas y una meta-progresión propia; véase [la fuente de verdad](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md). Las cifras de abajo provienen del material aportado por el usuario y no constituyen un calendario activo.

## Mejoras permanentes entre partidas

La referencia indica que ganar la partida concede **450 XP extra**. Los XP y umbrales siguientes pertenecen a Rogue Tower, no a la economía/meta moneda actual del proyecto.

El extracto deja vacío el XP base recibido al terminar la partida; solo especifica el extra por ganar. Las parejas de requisitos abreviadas como `cartas/XP` indican cartas desbloqueadas y experiencia necesaria.

| Rama | Progresión resumida | Requisitos aportados |
|---|---|---|
| **Card Draw I–III** | +1 carta por selección de mejora en cada nivel; total de 4, 5 y 6 opciones. | I: 25 XP. II: 20 cartas desbloqueadas contando I y 50 XP. III: 30 cartas contando II y 75 XP. |
| **Treasure!** | +1 carta por cofre de tesoro. | 45 cartas desbloqueadas contando Card Draw III y 100 XP. |
| **Draw Frequency I–II** | Ofrece cartas cada 2 rondas; luego cada ronda. | I: 30 cartas y 50 XP. II: 60 cartas contando I y 100 XP. |
| **Gold Drop I–V** | +1 oro por enemigo y nivel; máximo +5. | I: 15 XP. II–V: 5/30, 10/60, 20/120 y 49/240 cartas/XP, incluyendo el nivel anterior. |
| **Treasury I–X** | +100 oro inicial por nivel; máximo +1000. | I: 20 XP. II–X: 10/40 XP, 20/60, 30/80, 40/100, 50/120, 60/140, 70/160, 80/180 y 90/200. Cada pareja es cartas desbloqueadas/XP y requiere el nivel anterior. |
| **Sourcery I–III** | +1 maná/s por nivel; máximo +3/s. | I: 10 XP. II: 5 cartas y 25 XP. III: 10 cartas y 50 XP. |
| **Mana Capacity I–V** | +20 de capacidad máxima por nivel; máximo +100. | I: 25 XP. II–V: 5/50, 10/75, 20/100 y 30/125 cartas/XP; requiere el nivel anterior. |

## Cartas de torres durante la run

La mayoría de ramas repiten una estructura: tres mejoras por capa de vida que suman **+6** (incrementos de +1, +2 y +3), una mejora crítica de **+15%**, y una carta **Monster Studies** que da +1 al daño de esa capa para todas las torres. Las mejoras permanentes propias de cada torre dan +1 a una capa por 120 XP.

Las cartas específicas suelen requerir escoger la torre y avanzar por la carta previa de la rama; el extracto muestra costes por carta variables y a veces vacíos, así que aquí se resume el árbol y no se normaliza ese coste individual.

| Torre de referencia | Resumen de ramas y cartas características |
|---|---|
| **Ballista** | Broadhead Bolts (salud); Jagged Heads (Bleed); Frost Bolts (Slow) y Freezing Bolts (3% de congelar); Heavy Shafts (armadura), Flamming Bolts (Burn) y Longbow (multiplica la bonificación de alcance por elevación); Enchanted Bolts (escudo), Poison Bolts y Mana Bolts (+4 de daño por nivel, a cambio de 10/20/25% del daño base en maná por disparo). Better Bolts: +1 permanente por capa. |
| **Mortar** | HE Shells (salud), Fragmentation (Bleed) y Long Range Ballistics (+5 de alcance por nivel); Concussive Shells (armadura), Incendiary Rounds (Burn) y Area of Effect (+50% de radio por nivel, hasta +150%); EMP (escudo), Gas Shells (Poison) y Mana Bombs (+4 de daño por nivel y coste de maná creciente). Better Bombs: +1 permanente por capa. |
| **Tesla Coil** | Power Surge (salud) + Bleed; Plasmatics (armadura) + Burn; Static Permeation (escudo) + Poison. Cada rama suma daño por capa; Advanced Circuits da +15% crítico. Better Electricity: +1 permanente por capa. |
| **Frost Keep** | Frostbite/Dehydration/Conductive Snow aumentan daño por capa; Vampiric Snow añade Bleed, Flammable Snow Burn, Yellow Snow Poison. Deep Freeze suma 5% de congelación de 1 s por nivel (hasta 15%); Ice Breaker añade +1 de daño contra congelados por nivel (hasta +3); Blizzard da +1 alcance por nivel; Absolute Zero sube el límite de Slow en +10. Better Snow: +1 permanente por capa. |
| **Flame Thrower** | Napalm/Nitric Acid/White Phosphorus aumentan daño por capa. Fuel Saturation añade +50% Burn por nivel (hasta +200%); Everything Burns aumenta el límite de Burn/s en 100. Better Fire: +1 permanente por capa. |
| **Poison Sprayer** | Infection/Corrosion/Fumigation aumentan daño por capa. Spores añade +50% Poison por nivel (hasta +200%); Pandemic aumenta el límite de Poison/s en 100. Better Poison: +1 permanente por capa. |
| **Shredder** | Sharpened/Hardened/Magnetic Blades aumentan daño por capa. Thrashing añade +50% Bleed por nivel (hasta +200%); Everything Bleeds aumenta el límite de Bleed/s en 100. Better Sawblades: +1 permanente por capa. |

Las cartas de estado de la referencia pueden aumentar daño del equipo contra enemigos afectados y elevar límites de DoT; los detalles están en [Status Effects](04_status_effects.md). El proyecto implementa el bonus de +1 al multiplicador de Health/Armor/Shield para ataques contra enemigos con Bleed/Burn/Poison, además de los ticks y counters de regeneración. Ese multiplicador propio difiere del daño plano de las cartas Monster Studies de Rogue Tower. El pool M11 contiene solo un subconjunto configurable de las ramas de referencia; los nombres que sí se adoptaron están listados en [Nomenclatura](../design/12_NOMENCLATURE.md).

## Encaje con Rogue Tower

- El proyecto tiene un multiplicador Shield y una barra visual para esa capa. Cuando un perfil tiene Shield máximo mayor que cero, la barra azul se dibuja sobre Armor y Health; el dummy DEBUG y el perfil actual de Ooogie von Ooogovich permiten comprobarlo.
- La wiki también nombra Banditry y Gold Rush! como cartas de run que aumentan el oro; el extracto recibido no aporta sus valores ni condiciones.
- Las cards de la demo y sus correspondencias de nombre están decididas en Resources y ADR-0033; esta lista sigue siendo una descripción de la referencia.
- Las torres, sus cards, la economía y XP de la referencia son contenido comunitario. No importar cifras o progresión como balance vigente sin decisión de diseño.

## Fuentes

- Extractos aportados por el usuario: Single Defense, permanent upgrades y pools simplificados de cartas de las siete torres.
- [Permanent Upgrades](https://rogue-tower.fandom.com/wiki/Permanent_Upgrades), [Upgrade Cards](https://rogue-tower.fandom.com/wiki/Upgrade_Cards) y fichas de torres enlazadas en [01_torres.md](01_torres.md), Rogue Tower Wiki, consulta: 2026-10-08.
- Rogue Tower Wiki es contenido comunitario CC BY-SA salvo indicación distinta; este texto lo resume y debe conservar atribución si se reutiliza.
