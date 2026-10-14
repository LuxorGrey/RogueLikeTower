# Auditoría del sistema de torres

**Corte de implementación:** 2026-10-13. Esta página es una auditoría comparativa del código y los Resources cargados; los valores promovidos para Frost Keep quedan registrados en ADR-0059. La autoridad propia sigue siendo [el diseño del juego](01_GAME_DESIGN_SOURCE_OF_TRUTH.md), sus ADR y los Resources. La referencia de comportamiento es una wiki comunitaria y no el código fuente de Rogue Tower.

## Resumen de hallazgos

- El daño por nivel y la selección de la capa que recibe +1 multiplicador coinciden en forma con la descripción de Rogue Tower. La implementación propia permite 15 mejoras independientes por capa (45 total), con costes Gold y requisitos de XP exponenciales configurables. Los factores actuales 1,15 son propios y provisionales; no replican los árboles de investigación/cartas del original. Este estado sustituye el corte previo de esta auditoría según [ADR-0046](../decisions/ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md).
- La wiki enumera 15 torres; la demo propia expone siete perfiles jugables. Las ocho entradas restantes son alcance externo y no se agregan aquí, en línea con el roster aprobado y la exclusión de edificios de soporte.
- Rango y altura comparten la regla descrita por la wiki (+0,5 hex y +1 daño base por nivel de elevación). Los upgrades comprados no aumentan alcance ni RPM.
- Ballista, Mortar, Tesla Coil, Flame Thrower, Poison Sprayer y Shredder mantienen cadencia fija. Frost Keep empieza en 180 RPM y gana 18 RPM por cada celda PATH dentro de una caja cuadrada. Su cobertura y las posiciones de caída de copos usan esa caja.
- Frost Keep drena 2 Mana/s continuamente durante combate, aunque no encuentre objetivos; los perfiles con coste por ataque se cobran solo al disparar. Si falta Mana, Frost se bloquea y reanuda cuando hay saldo suficiente.
- Los críticos ejecutan hasta tres tiradas ordenadas ×4, ×3, ×2. El máximo configurable es 150 %, pero, como cada banda se prueba de forma condicional, la probabilidad efectiva de no crítico en el tope es 12,5 %. La wiki describe las bandas y el orden, pero no publica suficiente detalle de implementación para certificar que use exactamente la misma probabilidad condicional.
- El patrón antiguo `ALL_IN_RANGE` hacía un impacto garantizado en cada enemigo del cuadrado a cada disparo, distinto de la lluvia de copos descrita por Rogue Tower. Frost ahora deja caer copos sobre PATH; cada copo puede impactar como máximo a un enemigo y solo aplica daño/Slow al contacto. El campo `max_targets` sigue sin limitar Tesla, que mantiene `ALL_IN_RANGE`.

## Fórmulas implementadas

Sea `B` el daño base del Resource, `L` el nivel, `E` la elevación, `C+` el daño plano de cartas, `C×` el producto de multiplicadores de daño de run y `M×` el multiplicador permanente:

```text
daño bruto de la torre = round((B + (L - 1) + E × bonus_daño_altura + C+) × C× × M×)
RPM efectivo = (RPM base + bonus Frost por Path) × multiplicador de cadencia de cartas
alcance efectivo = alcance base + E × bonus_alcance_altura + bonus de alcance de cartas
```

Los Resources activos tienen `bonus_daño_altura = 1` y `bonus_alcance_altura = 0,5`. El multiplicador de cadencia ahora se consulta en runtime; ninguna de las 190 cards combinadas lo usa.

Para un ataque directo a la capa activa:

```text
crudo tras crítico y fortificación = max(daño bruto × crítico - reducción plana de Fortification, 0)
daño aplicado = min(HP de la capa, floor(crudo × (multiplicador torre + bonus estado coincidente + cartas H/A/S) × producto de tags del enemigo))
```

El paquete solo daña una capa por impacto: Shield → Armor → Health; cualquier exceso se descarta. Bleed suma +1 al multiplicador de ataques directos contra Health, Burn contra Armor y Poison contra Shield. Ese bonus no se aplica a los propios ticks de estado. Los tags del enemigo pueden aumentar o reducir daño y, si coinciden varios, sus factores se multiplican.

## Perfiles activos y cifras

Multiplicadores en el orden Health / Armor / Shield. La columna de mejora indica coste Gold inicial por capa; el siguiente coste de esa misma capa crece por su factor exponencial configurado. El máximo propio es 15 niveles por capa.

| Torre | Daño; H/A/S | Alcance | RPM | Mana | Construcción; mejora base/capa |
|---|---:|---:|---:|---:|---:|
| Ballista | 10; 10/5/5 | 5 | 20 | — | 10 (+15 por cada Ballista previa); 10 por capa |
| Mortar | 20; 10/15/5 | 10 | 10 | — | 200 (+75); 10 por capa |
| Tesla Coil | 9; 6/3/10 | 2 | 30 | 5 por disparo × daño actual / 9 | 200 (+75); 20 por capa |
| Frost Keep | 6; 10/5/5 | 2, geometría cuadrada | 180 + 18 por Path cubierto | 2/s continuo durante combate | 250 (+100); 20 por capa |
| Flame Thrower | 6; 6/9/3 | 4 | 60 | 1 por disparo × daño actual / 6 | 300 (+75); 30 por capa |
| Poison Sprayer | 5; 6/3/9 | 4 | 60 | 1 por disparo × daño actual / 5 | 300 (+75); 30 por capa |
| Shredder | 10; 20/10/10 | 5 | 5 | — | 500 (+100); 30 por capa |

La tabla no incorpora elevación, cartas, estados en el objetivo, críticos, fortificación ni resistencia por tags. Tesla usa `ALL_IN_RANGE`: el campo `max_targets` no limita la cantidad alcanzada.

Potencia teórica contra un único enemigo que permanece en rango, sin cartas ni modificadores de objetivo:

| Torre | Daño bruto por segundo | Health/s | Armor/s | Shield/s |
|---|---:|---:|---:|---:|
| Ballista | 3,33 | 33,33 | 16,67 | 16,67 |
| Mortar | 3,33 | 33,33 | 50,00 | 16,67 |
| Tesla Coil | 4,50 | 27,00 | 13,50 | 45,00 |
| Frost Keep (si todos los copos impactan el mismo objetivo) | 18,00 | 180,00 | 90,00 | 90,00 |
| Flame Thrower | 6,00 | 36,00 | 54,00 | 18,00 |
| Poison Sprayer | 5,00 | 30,00 | 15,00 | 45,00 |
| Shredder | 0,83 | 16,67 | 8,33 | 8,33 |

Es `daño_base × RPM / 60 × multiplicador_capa` antes del `floor` por impacto. Son techos de un solo objetivo, con 100% de contacto y sin overkill; Frost no aplica un golpe a todos los objetivos: los copos pueden fallar y cada impacto alcanza como máximo a uno. No comparan el valor de área, conos, todos-en-rango, Bleed/Burn/Poison, objetivos moviéndose fuera de alcance ni coste de Mana. Cada PATH adicional añade 0,3 intentos de copo/s (18 RPM), pero el daño real depende de los contactos.

## Mejoras y progresión

### Mejora manual

`BuildController` comprueba fase, Gold y nivel de la capa, cobra `round(base_cost[layer] × factor_coste^nivel_de_capa)` y llama a `Tower.upgrade(capa)`. Esa función sube solo la capa elegida y el total agregado, y da **+1 daño base y +1 a esa capa**. Si la llamada falla después del cobro, el controlador devuelve el Gold. No hay reembolso al demoler, aunque demoler reduce el conteo usado para calcular el próximo coste de construcción. Los valores base por torre están en [Catálogo y escalado](13_CONTENT_ROSTER.md); el factor actual 1,15 es provisional.

El bonus de daño y el de multiplicador se combinan; la ganancia puede ser mayor que el +1 nominal. Ejemplos sin elevación, crítico, carta, estado, Fortification ni tag:

| Mejora en nivel 1 | Antes | Después | Cambio bruto |
|---|---:|---:|---:|
| Ballista contra Health | 10 × 10 = 100 | 11 × 11 = 121 | +21 % |
| Ballista contra Armor | 10 × 5 = 50 | 11 × 6 = 66 | +32 % |
| Mortar contra Armor | 20 × 15 = 300 | 21 × 16 = 336 | +12 % |
| Tesla contra Shield | 9 × 10 = 90 | 10 × 11 = 110 | +22,2 % |
| Shredder contra Health | 10 × 20 = 200 | 11 × 21 = 231 | +15,5 % |

Estas comparaciones muestran por qué elegir la capa es una decisión de daño y no un simple atributo secundario. El valor final en combate lleva `floor`, límites por HP disponible y modificadores adicionales.

### XP automática

Durante `COMBAT`, una torre gana XP mientras mantiene un objetivo válido en alcance, aunque ese objetivo no reciba daño. La capa de HP activa del objetivo determina qué reserva recibe la XP. La tasa implementada es `0,5 + 1 / (2 × rango_en_hexes)` XP/s: a rango 2 da 0,75 XP/s (100 XP en ~133 s); a rango 5 da 0,6 XP/s (~167 s); a rango 10 da 0,55 XP/s (~182 s). Cada capa tiene su XP y contador de nivel independientes. El requisito siguiente es `base_xp × factor_xp^nivel_de_capa`, inicialmente 100 XP con factor provisional 1,15. Al reunirlo, sube esa capa y da el mismo +1 daño base y +1 multiplicador. Se deja de acumular XP únicamente cuando esa capa llega a nivel 15.

La fórmula de XP coincide con la publicada por la wiki; el máximo 15 por capa y el umbral exponencial son reglas de progresión propias/configurables. Las tres prioridades cambian qué objetivo sostiene la XP y por tanto a qué capa se asigna.

Hay una diferencia funcional de targeting: el proyecto trata las prioridades de forma lexicográfica: la segunda solo desempata la primera, y la tercera solo se consulta si también empata la segunda. Las notas oficiales 1.0.12.0 de Rogue Tower describen pesos ×3/×2/×1 según el orden de prioridad. No se cambió porque afecta qué enemigos se atacan y, por ello, también a qué capa va la XP automática.

### Diferencias de diseño

La referencia describe que construir más torres iguales encarece la siguiente y que demoler recupera el coste futuro; el cálculo del proyecto sigue esa estructura, aunque el perfil de costes actual es provisional. El proyecto permite 15 compras por capa con curva exponencial configurable; no importa los factores de progresión como si fueran datos de Rogue Tower. Se representan las 173 cartas compatibles con las siete torres activas y efectos generales mediante 172 Resources nuevos y la Advanced Circuits existente, junto a las otras 17 cards propias y 31 mejoras permanentes. Se ofrecen cartas cada tres rondas tras colocar terreno, en 3–42; las ofertas base son tres y Card Draw puede ampliarlas hasta seis. Los efectos no reproducen exactamente el árbol de investigación/desbloqueo del original y el balance sigue siendo propio/provisional. Ver ADR-0062.

Los campos antiguos `upgrade_damage_per_level`, `upgrade_range_per_level` y `upgrade_attack_rate_per_level` se retiraron de `TowerData` y de los Resources porque no gobernaban el runtime. `frost_slow_fraction` convierte el daño aplicado por el copo en fuerza Slow; `max_targets` se usa en `CHAIN`, no en `ALL_IN_RANGE`.

## Rango, RPM y Mana

- Las torres ordinarias comprueban un círculo euclídeo en píxeles usando el alcance convertido desde hex. Frost Keep usa límites cuadrados alineados a pantalla tanto para selección como para agrupar objetivos. Esto puede hacer que la distancia a una esquina de la caja exceda el alcance radial.
- Elevación aumenta tanto alcance como daño bruto. Las cards añaden rango; las mejoras manuales no lo hacen. Los upgrades no modifican RPM.
- La cadencia se convierte a cooldown `60 / RPM` segundos. Frost suma 18 RPM por celda Path bajo su caja de cobertura; una celda cuenta, sin ponderación por distancia dentro de esa caja.
- Tesla, Flame y Poison multiplican su coste por disparo por el cociente entre daño actual y daño base; los modificadores de coste de Mana de cards se aplican después. Tesla parte de 5/impacto; Flame y Poison de 1/ataque.
- Frost mantiene el coste nominal de 2 Mana/s como drenaje continuo durante `COMBAT`, incluso entre objetivos. Las mejoras de coste de Mana de run multiplican la tasa. Con Mana insuficiente la torre deja de disparar hasta que pueda pagar el siguiente paso de drenaje.
- El pool global de run empieza con 100 Mana máximo y 1,5 Mana/s base; cards/mejoras permanentes pueden ampliar capacidad o regeneración. Al comenzar cada ronda de campaña se rellena al máximo efectivo. Una torre sin Mana suficiente no ejecuta el ataque ni gasta saldo: reintenta tras 0,25 s. No hay edificios de soporte ni Mana por torre regenerándose fuera del pool global.
- La cadencia es fija para las otras seis torres. El código admite un multiplicador de cadencia de cards, pero el pool vigente no contiene esa operación. Frost también cambia su RPM por cobertura PATH según la regla propia de la demo.

## Críticos

Todos los perfiles comienzan en 0 %; las cards aportan puntos porcentuales y el valor se limita a 150 %. Por disparo se prueba primero ×4 (`clamp(chance - 1, 0, 0,5)`), luego ×3 (`clamp(chance - 0,5, 0, 0,5)`) y después ×2 (`clamp(chance, 0, 0,5)`); un éxito para el multiplicador más alto para las pruebas inferiores. A 75 %, las probabilidades efectivas según el código son 25 % ×3, 37,5 % ×2 y 37,5 % sin crítico. A 150 % son 50 % ×4, 25 % ×3, 12,5 % ×2 y 12,5 % sin crítico.

La descripción de Rogue Tower organiza la estadística en tres tramos de 50 puntos, de ×2 a ×4, y dice que se lanzan tiradas desde el multiplicador mayor al menor. No aclara en pseudocódigo si los tramos son tiradas condicionales como las del proyecto o una distribución de probabilidad diferente. No afirmamos equivalencia matemática exacta hasta contrastar ese punto contra el juego original. Un paquete de ataque se crea una sola vez, de modo que objetivos alcanzados por el mismo ataque de área/cono/Tesla comparten la tirada crítica.

## Estados y daño periódico

| Estado | Datos activos | Regla práctica |
|---|---|---|
| Slow | Fuerza máxima 60; decae 6/s | Frost suma por impacto el 50% del daño realmente aplicado, convierte la fuerza en reducción porcentual de velocidad y suma nuevos impactos hasta 60. |
| Burn | 5 s; tick 1 s; máximo 3; suma acumulaciones | Detiene regeneración de Armor mientras está activo. Da +1 al multiplicador de ataques directos contra Armor. Flame distribuye el daño bruto de su golpe crítico entre los ticks; aplica el multiplicador Burn de Armor 1, Health/Shield 0,5. |
| Poison | 4 s; tick 1 s; máximo 3; suma acumulaciones | Detiene regeneración de Shield. Da +1 al multiplicador de ataques directos contra Shield. Poison Sprayer distribuye el daño bruto del golpe crítico entre ticks; aplica el multiplicador Poison de Shield 1, Health/Armor 0,5. |
| Bleed | 1,5 s; tick 0,75 s; máximo 4; suma acumulaciones | Detiene regeneración de Health. Da +1 al multiplicador de ataques directos contra Health. Shredder tiene cálculo propio que reparte el presupuesto de daño de sangrado a lo largo de la ruta impactada; los ticks usan Health 1, Armor/Shield 0,5. |

Burn y Poison vuelven a pasar por `DamageService`, por lo que crítico, multiplicador H/A/S del origen y tags del enemigo determinan su daño. No reciben el bonus +1 de estado para ataques directos. Los factores de velocidad activos se combinan tomando el menor, no multiplicando estados entre sí. Las acumulaciones máximas y parámetros numéricos son Resources del proyecto y varios son balance provisional.

La wiki describe el daño de estados como un porcentaje del daño de torre habilitado por cards. El catálogo añadido incluye modificadores directos de daño/cap de DoT, Slow, conversión de DoT a daño crítico y condiciones por capa; Flame y Poison siguen distribuyendo su presupuesto de daño entre los ticks y Shredder usa su presupuesto por impacto. La adaptación implementa estas familias con las reglas y límites de estado propios del proyecto.

## Efecto de cards y permanente

Las 190 cards del pool pueden sumar daño, multiplicar daño, ampliar alcance/radio, modificar coste y regeneración de Mana, crítico, capas H/A/S, estados, Gold, vida de base y daño que recibe la base. Los nombres y operaciones ejecutables están en el [roster activo](13_CONTENT_ROSTER.md). Los valores aditivos se suman; los multiplicadores se multiplican. Una card no muta el Resource compartido. Los prerrequisitos y unlocks de cartas adaptan las ramas al roster propio. Para torres sí se adopta el principio de gastar XP de perfil en unlocks: arsenal inicial Ballista/Mortar/Tesla Coil, costes 50 XP para Frost Keep/Flame Thrower/Poison Sprayer y 100 XP para Shredder. La fórmula de recompensa XP sigue siendo propia/configurable. Las mejoras permanentes compradas después de una run se aplican desde la siguiente; ver ADR-0069.

## Diferencias de diseño abiertas

1. **Costes y curvas de nivel.** El límite vigente ya está decidido: 15 compras independientes por capa Health/Armor/Shield (45 por torre), según ADR-0046. Los costes y sus factores exponenciales siguen siendo valores provisionales configurables; no queda pendiente decidir el número de niveles de la demo.
2. **XP automática.** Elegir si se conserva XP por mantener un objetivo en alcance; es un sistema de identidad propia y puede subir torres sin gasto de Gold.
3. **Peso de prioridades.** Decidir si se conserva el desempate lexicográfico o se adopta el peso RT ×3/×2/×1; el cambio alteraría targeting y asignación de XP.
4. **Críticos.** Contrastar las probabilidades condicionales contra un build/version concreto del juego original antes de modificar una fórmula que afecta todos los ataques multiobjetivo.

Frost Keep ya adopta daño 6, 180 RPM, Slow proporcional y coste 2 Mana/s durante combate. La altura, velocidad y radio de contacto de las partículas siguen configurables y requieren aceptación manual; ver ADR-0059.

## Fuentes y método

| Fuente | Uso | Consulta |
|---|---|---|
| [Rogue Tower Wiki — Towers](https://rogue-tower.fandom.com/wiki/Towers) | Fórmulas publicadas de daño, elevación, rango, cadencia, Mana, críticos, XP y economía de upgrades; tabla comunitaria de perfiles. La página no especifica todas las convenciones del runtime. | 2026-10-09; copia indexada por buscador, revisión de página no identificada. |
| [Rogue Tower — anuncios oficiales de Steam](https://steamcommunity.com/app/1843760/announcements/) | Patches 1.0.12.0 (2022-02-17), con pesos de targeting y cambios de Mana; y 1.1.2.0 (2022-09-08), con rango/daño de Tesla y daño de Flame/Frost. | 2026-10-09. |
| [Frost Keep — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Frost_Keep) | Comportamiento: copos sobre PATH, impacto individual, alcance cuadrado, 50% del daño aplicado como Slow, coste 2 Mana/s y +18 RPM por PATH cubierto. La ficha indexada conserva daño 5; se usa 6 por el changelog oficial posterior 1.1.2.0. | 2026-10-13. |
| [Status Effects — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Status_Effects) y [discusión de Steam sobre Slow](https://steamcommunity.com/app/1843760/discussions/0/3182358518959301391/) | Slow escala con daño, llega hasta 60 y decae 6/s; la respuesta del desarrollador explica que los copos aplican el efecto al contacto y que la cadencia aumenta al cubrir más terreno. | 2026-10-13. |
| Código y Resources de este checkout | Estado implementado revisado en `game/towers/tower.gd`, `game/combat/damage_service.gd`, `game/combat/status_effect_controller.gd`, `game/cards/run_card_service.gd`, `data/towers/*.tres` y `data/cards/*.tres`. | 2026-10-09. |

El código y los Resources son la evidencia de lo que ejecuta este proyecto, pero no demuestran por sí solos que la mecánica del juego original sea idéntica. Para el changelog histórico, la fuente oficial prevalece sobre el resumen comunitario.
