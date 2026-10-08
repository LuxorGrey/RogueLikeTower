# Combat System

## Objetivo
Conservar la lectura estratégica de Rogue Tower: enemigos con defensas distintas y torres que funcionan mejor/peor según el objetivo.

## Enemy survivability
Cada enemigo tiene Health y puede tener Armor y Shield. Se consumen en orden **Shield → Armor → Health**. La barra sobre el enemigo muestra segmentos coloreados para las tres capas y el HUD informa valores actuales/máximos. Bleed contrarresta regeneración de Health, Burn la de Armor y Poison la de Shield. Ver [ADR-0023](../decisiones/ADR-0023-reglas-de-torres-y-capas-de-vida.md).

No copiar números de Rogue Tower. Crear sistema propio configurable.

## Damage pipeline
Centralizar el cálculo:
1. torre crea `DamagePacket`;
2. aplicar modificadores de run;
3. resolver crítico, tag y multiplicador para la capa activa Shield/Armor/Health;
4. aplicar daño;
5. aplicar status;
6. emitir eventos;
7. si health <= 0 -> kill/reward.

No repartir fórmulas entre cada torre.

## Counters
El modelo debe permitir que una torre sea:
- fuerte contra vida;
- fuerte contra armadura;
- anti-regeneración;
- especializada en status;
- generalista.

Los multiplicadores concretos son balance, no arquitectura.

## Regeneración
Regeneración por segundo o tick. Debe poder ser reducida/contrarrestada por efectos o torres si se define una build anti-regen.

## Targeting
Cada torre puede combinar hasta tres criterios únicos: progreso, vida/armadura/escudo altos o bajos, menor HP de la capa activa y velocidad rápida/lenta. El segundo criterio se usa solo si empata el primero; el tercero si ambos empatan.

No implementar 15 modos antes de necesitarlos.

## Height advantage
Framework:
```text
height_delta = tower_elevation - target_elevation
```
Debe existir una función única que traduzca `height_delta` a bonus.

Regla de demo: cada nivel de elevación suma +1 al daño base y +0.5 hex al alcance. Son valores configurables y provisionales.

## Status framework
Catálogo reducido inicial:
- Slow: modifica velocidad.
- Burn: DoT.
- Bleed: DoT que permanece en las pruebas M8 y se asigna a Shredder.
- Poison: DoT/tag de daño añadido para el roster M9.5; parámetros provisionales.

El framework debe soportar:
- duración;
- refresh;
- stack;
- tick;
- source;
- limpieza al morir.

## M8 — Estados implementados

`StatusEffectData` configura ID/nombre, duración, intervalo de tick, máximo de stacks, regla, multiplicador de velocidad, daño por tick y tags del daño periódico. `TowerData.status_effects` adjunta uno o más efectos a cada impacto. El flujo actual en `DamageService` resuelve primero el daño directo y la contrarregeneración; después aplica los payloads a un objetivo que siga `MOVING`. Los DoT construyen un paquete independiente sin payloads, usan el `source_id` almacenado en el estado y regresan a `DamageService`, por lo que respetan armadura y multiplicadores de `EnemyData` como cualquier otro daño.

Reglas runtime: `REFRESH` conserva una acumulación; `ADD_STACKS` incrementa hasta `max_stacks`. En ambos casos la aplicación renueva la duración completa y conserva la fase del próximo tick. Una reaplicación del mismo ID usa los datos y el origen de la aplicación más reciente. Cada enemigo tiene sus propios contadores aunque varios compartan el mismo Resource. Los multiplicadores de velocidad se combinan por mínimo; `1.0` significa velocidad normal. Un estado desaparece al llegar su duración a cero y todos se limpian cuando el enemigo muere o llega a la base. Los ticks aplicados antes de que expire el tiempo restante se resuelven; no hay daño periódico después de la expiración.

La muestra de M8 contiene Slow (`0.5×`, provisional para Frost), Burn y Bleed; la Sonda sigue siendo fixture de depuración. Bleed cancela regeneración de Health, Burn la de Armor y Poison la de Shield. Los DoT usan sus multiplicadores de capa y el pipeline central. No se implementan resistencias de estado. ADR-0012/0023 detallan reglas y provisionalidades; `10_ACCEPTANCE_TESTS.md` define la aceptación manual.

## M9.5 — Roster de siete torres

La demo incorpora Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder antes de las cartas. Los perfiles viven en `TowerData`; los atajos `1–7` muestran nombre, color placeholder y coste. `8`, `9` y `0` retienen Perforadora, Drenadora y Sonda para diagnóstico M7/M8.

Los patrones disponibles son objetivo único, área, cadena, cono, hoja por PATH y todos-en-alcance. Ballista dispara un proyectil; Mortar lanza una granada a la posición seleccionada y explota con daño de área al aterrizar; Tesla descarga sobre todos los enemigos en alcance circular. Shredder lanza una hoja por la ruta actual del objetivo, hace impacto directo y añade Bleed por el 100% del daño base restante, y pierde 1 de daño base por enemigo atravesado. Frost Keep usa un área cuadrada; su cadencia sube con PATH cubierto. Flame/Poison afectan un cono y convierten el 100% del daño base en Burn/Poison. Los estados detienen la regeneración de su capa y aplican multiplicadores H/A/S; no crean una vulnerabilidad adicional oculta. Los detalles de datos están en [11_INITIAL_CONTENT_PLACEHOLDERS.md](11_INITIAL_CONTENT_PLACEHOLDERS.md) y ADR-0023; parámetros no indicados por el usuario siguen siendo provisionales.

Poison es el tag 8 de daño; `EnemyData.poison_damage_multiplier` participa junto con los otros multiplicadores por tag. Shield se implementa en M12A y ocupa la capa superior del enemigo. Los multiplicadores por capa de los siete perfiles parten de la tabla del usuario; otros valores siguen provisionales. Ver [ADR-0014](../decisiones/ADR-0014-roster-jugable-de-siete-torres.md), [ADR-0023](../decisiones/ADR-0023-reglas-de-torres-y-capas-de-vida.md) y [11_INITIAL_CONTENT_PLACEHOLDERS.md](11_INITIAL_CONTENT_PLACEHOLDERS.md).

## Torre
Estados:
- idle;
- acquire target;
- cooldown;
- attack.

Separar:
- datos;
- targeting;
- ataque;
- visual.

## Enemy path movement
Movimiento visual continuo entre centros de hexes de la ruta.
El enemigo conoce:
- path actual;
- índice;
- progress normalizado.

M5 consume la secuencia axial `PathRoute` cacheada por M4 para inicializar el camino del enemigo y conserva sus propios waypoints, índice y progreso. Si cambia el mapa solo entre rondas, no hace falta recalcular rutas con enemigos vivos. `WaveDirector` escoge candidatos spawn según la política de cada grupo; la muestra usa `FIRST_SORTED`, mientras que la configuración final por ronda sigue abierta. M4 expone candidatos y no decide esa política.

La primera integración M5 implementa `HealthComponent`, `GameBase`, `Enemy`, `PathFollowerComponent` y `WaveDirector`. El enemigo se mueve continuamente entre centros de hex, inicia en la coordenada exterior del endpoint y aplica su daño configurado al llegar; el director retira enemigos llegados o derrotados y termina la oleada al concluir los spawns y quedar cero enemigos activos. La UI bloquea la colocación de terreno durante `COMBAT`; una base agotada cambia a `RUN_DEFEAT`, y una oleada superada habilita `TERRAIN_EXPANSION`.

## M10 — Campaña de veinte rondas

`WaveCampaignData` enlaza una entrada `WaveData` para cada ronda consecutiva 1–20. M10 sitúa minijefes placeholder en 17 y 19 y un jefe Tier 2 genérico con variante todavía pendiente en 20, como confirman las reglas propias del borrador del usuario; composición, salud, daño, recompensas, velocidad y arte siguen provisionales y configurables. El escalado temporal usa crecimiento por ronda para salud, daño de llegada y oro por baja; cada enemigo recibe una copia runtime de `EnemyData` para no modificar la configuración de origen. `WaveDirector` informa cantidad pendiente y viva, y la recompensa/fin no se emite hasta acabar todos los grupos con ambos recuentos a cero. En cada pulso de campaña genera un enemigo por todos los endpoints PATH abiertos y alcanzables; los grupos cuentan pulsos por salida. El HUD permite iniciar solo la ronda activa. Después de las rondas 1–19 ofrece tres piezas de terreno distintas; `Esc` durante la colocación devuelve a esa oferta y la próxima ronda queda bloqueada hasta colocar una pieza válida conectada. Los huecos interiores se rellenan al azar con Grass/Montaña sin tapar endpoints PATH. La ronda 20 entra a `RUN_VICTORY` sin expansión. Los fixtures de diagnóstico M7/M8 pueden repetirse en modo aislado sin avanzar campaña, cobrar recompensas ni dañar la base. ADR-0016–0018 registran los compromisos, provisionalidades y aspectos fuera del alcance. No se incorporan todavía las capas Shield/Armor/Health, cartas de mejora, variantes definitivas ni habilidades de referencia.

M6 añade el primer ciclo defensivo con una torre `Basic Bolt`: se puede colocar en una celda Grass o Mountain libre, seleccionar, cambiar prioridad y mejorar. La prioridad consulta enemigos vivos en alcance cada 0.1 s: primero/último por fracción recorrida de `PathRoute`, mayor vida actual o mayor armadura configurada. El ataque ocurre durante `COMBAT`, dentro del alcance, a la cadencia configurada, y muestra un breve flash vectorial de hitscan. La torre no bloquea PATH ni exige recalcular rutas. M7 enruta el ataque por `DamageService`.

La altura de la torre suma provisionalmente `height_range_bonus_per_level` al alcance por nivel de elevación. Los valores iniciales de Basic Bolt son 10 de daño, 1 ataque/s, 3 hexes de alcance, +5 daño y +0.25 hex por nivel hasta nivel 3; cada nivel de elevación también agrega +0.25 hex. Son datos configurables para validar el sistema, no balance final. M9 añade costes configurables de construcción/mejora; desde M7 el armor mitiga según el paquete de daño.

## M7 — Pipeline histórico (sustituido por M12A)

`DamageService` es dueño de la fórmula de combate entre una torre y un enemigo. `Tower` arma un `DamagePacket` a partir de su `TowerData` y no calcula mitigación ni vida por su cuenta. La instancia de servicio pertenece a `Main` y se inyecta a `BuildController`/torres para que no haya un Autoload global con estado de combate.

Orden implementado para esta etapa:
1. construir paquete con daño bruto, ID de origen, tags y counters configurables;
2. dejar preparado el paso de modificadores de run (no hay proveedor de modificadores antes de M11);
3. absorber armor plano: `min(raw_damage, armor * armor_multiplier)`;
4. aplicar el daño restante, el multiplicador recibido por tags de `EnemyData` y `health_multiplier`, redondeando hacia abajo a HP entero;
5. aplicar HP a través de `HealthComponent` y contrarregeneración temporal;
6. emitir `DamageService.damage_resolved`; `Enemy` emite sus señales de vida/muerte existentes;
7. M8 añade efectos de estado después del daño; M9 conecta pagos por baja y por ronda limpia mediante eventos del director de oleada.

Tags provisionales: Físico, Fuego y Arcano. Cada enemigo puede definir un multiplicador recibido por tag; varios tags de un paquete se combinan multiplicándose. Regeneración se acumula como fracción por segundo, no supera HP máximo y solo se ejecuta mientras el enemigo vive y avanza. Un counter de fuerza `0..1` reduce proporcionalmente la regen durante una duración configurada; impactos sucesivos mantienen la fuerza más alta y el mayor tiempo restante, sin acumularse por encima de 100%.

El HUD M7 permite elegir Basic Bolt, Perforadora M7 o Drenadora M7 y seleccionar la oleada de diagnóstico con un `Armored Regenerator`. La línea debug muestra HP, armadura, regen base/efectiva y daño estimado para la torre seleccionada. Los tres perfiles y el enemigo diagnóstico son muestras temporales, no contenido o balance confirmados. Ver ADR-0010 y el procedimiento manual de `10_ACCEPTANCE_TESTS.md`.

El contenido M5 continúa siendo una prueba funcional de base 50 HP, enemigo 20 HP, velocidad 90 px/s, daño de llegada 10, tres enemigos con intervalo 1 s y política `FIRST_SORTED`. Con M6 las torres pueden derrotar esos enemigos; M7 añade el pipeline de mitigación, tipos y regeneración. M9 añade recompensas provisionales por bajas y ronda completada, además de economía de oro/maná; la repetición actual es de diagnóstico y no representa la secuencia de rondas M10 ni balance final.

## M9 — Economía y maná

`TowerData` declara `build_cost`, el coste indexado por nivel en `upgrade_costs` y `mana_cost_per_attack`. `BuildController` rechaza una compra sin oro y solo marca ocupada la celda cuando el cobro se acepta. Una mejora cobra el coste del siguiente nivel; si la torre no puede subir de nivel, no se cobra. La barra de atajos y el botón de mejora muestran el coste y se deshabilitan si no hay saldo; los atajos también atenúan su contenido para que la indisponibilidad sea visible.

Antes de ejecutar el paquete de daño, una torre con coste de maná solicita el gasto al `RunEconomyService`. Sin saldo suficiente no dispara y vuelve a intentarlo después de una espera corta; no se acumula deuda ni se permite saldo negativo. El servicio regenera maná durante las fases activas de run y limita el total a `maximum_mana`. M9 no tiene edificios de soporte ni fuentes de maná por torre.

`WaveDirector` paga `EnemyData.kill_reward` exactamente una vez cuando el enemigo muere, incluidos kills de DoT. Un enemigo que llega a la base no cobra. `WaveData.round_reward` se paga cuando terminaron todos los spawns y no queda ningún enemigo activo; una derrota no da el bonus de limpieza, pero tampoco revierte pagos por bajas ya efectuadas. La UI pasa por `ROUND_REWARD` durante 0.8 s y después habilita `TERRAIN_EXPANSION`. Si el calendario M11 lo indica, al colocar el terreno se abre `CARD_OFFER` y la próxima ronda no pasa a `ROUND_PREP` hasta seleccionar una carta.

La primera configuración arranca con 150 oro y 100/100 maná; su tasa base es 1.5 maná/s (equivalente a 3 maná cada 2 s). Las cifras son provisionales, no balance confirmado. La interfaz presenta las mejoras de regeneración con equivalencias de cantidades enteras por intervalos enteros y sin decimales; conserva internamente la tasa exacta. El oro de run es distinto a la moneda meta que M12 conserva entre runs. Sin economía inyectada, los callers antiguos de `Tower`/`BuildController` mantienen compatibilidad para smokes previos; `Main` siempre inyecta el servicio configurado. Ver ADR-0013, ADR-0030 y el procedimiento manual M9 en `10_ACCEPTANCE_TESTS.md`.

## M11 — Modificadores de carta

`Main` configura un `RunCardService` local desde `CardPoolData` y lo inyecta a `BuildController`, las torres nuevas y `RunEconomyService`. Las torres consultan efectos runtime de daño, alcance, área, coste, crítico, multiplicadores H/A/E y payloads de estado; la cadencia permanece fija salvo la cobertura PATH de Frost Keep. Los payloads se duplican antes de ajustar duración. La economía consulta bonus de maná máximo/regeneración. El pool actual contiene 12 cartas base, dos de Archivo M12, una de crítico y tres de multiplicador H/A/E; calendarios y cifras son provisionales. ADR-0021/0022/0023 registran las decisiones.

## M12A — Stats de torre y capas de HP

`TowerData` contiene valores base/H/A/S/RPM/rango/maná/precio. El precio escala por cantidad del mismo perfil; demoler baja el conteo sin reembolso provisional. Daño por golpe usa el multiplicador de la capa actual y se limita a su HP; no hay overflow de una capa a otra en el mismo hit. Los críticos usan chance en bandas 0–150% y multiplicadores ×2/×3/×4. Upgrades comprados o XP acumulada añaden +1 de daño base y +1 al multiplicador de una sola capa. XP solo se acumula mientras la torre sostiene un objetivo en alcance y va a la capa activa de ese enemigo. Tres selectores de prioridad comparan hasta tres criterios no repetidos. Enemy dibuja Shield azul, Armor beige y Health verde en proporción a sus máximos combinados. Bleed/Burn/Poison bloquean regeneración de Health/Armor/Shield, respectivamente, y cartas globales pueden sumar +1 al multiplicador de una capa elegida. La barra y los stats pueden comprobarse en DEBUG `capas escudo/armadura/vida`; no modifica la campaña. Datos y provisionalidades: [ADR-0023](../decisiones/ADR-0023-reglas-de-torres-y-capas-de-vida.md).
