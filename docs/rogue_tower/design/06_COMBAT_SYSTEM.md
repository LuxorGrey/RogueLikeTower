# Combat System

## Objetivo
Conservar la lectura estratégica de Rogue Tower: enemigos con defensas distintas y torres que funcionan mejor/peor según el objetivo.

## Enemy survivability
El modelo de cada enemigo contiene pools de Health, Armor y Shield; cada perfil configura sus máximos y cero desactiva una capa para esa unidad. Se consumen en orden **Shield → Armor → Health**. La barra sobre el enemigo muestra una fila por cada capa activa, con Health fragmentada, y el HUD informa valores actuales/máximos. Bleed contrarresta regeneración de Health, Burn la de Armor y Poison la de Shield. Ver [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md).

La campaña usa 26 enemigos hasta la ronda 45 según la composición aprobada en [14 — Campaña de 45 rondas](14_CAMPANA_45_RONDAS.md). Los datos individuales seleccionados, las habilidades y el escalado están en [13 — Catálogo de contenido](13_CONTENT_ROSTER.md) y ADR-0037. La velocidad RT se convierte a 45 px/s por unidad. No se añade crecimiento global por ronda. La wiki aporta fichas individuales; la tabla adjunta del usuario es la fuente de cantidades y orden.

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

### Feedback visual de impacto

Un impacto válido muestra su daño en un número flotante con entrada de escala rápida (`punch`), desplazamiento ascendente en arco que alterna izquierda/derecha, contorno oscuro y desvanecimiento. Tres alturas de salida ayudan a que golpes seguidos no coincidan exactamente. Health conserva texto rojo, Armor ámbar y Shield cian. El tamaño se ajusta con límites respecto a la media móvil de daño de ese enemigo; un crítico añade `CRIT`, crece más y conserva el color de la capa afectada. El sprite del enemigo recibe un breve flash del color de la capa. Todo es presentación y no modifica `DamageResult`, HP ni la cadencia de combate. Referencia visual: reel de CapyEmber, «How I make damage numbers that feel good, with hundreds of enemies on screen», Instagram, consultado 2026-10-10; ver [ADR-0052](../decisions/ADR-0052-numeros-de-dano-animados-y-legibles.md).

## Counters
El modelo debe permitir que una torre sea:
- fuerte contra Health;
- fuerte contra Armor;
- anti-regeneración;
- especializada en status;
- generalista.

Los multiplicadores concretos son balance, no arquitectura.

## Regeneración
Regeneración por segundo o tick. Debe poder ser reducida/contrarrestada por efectos o torres si se define una build anti-regen.

## Targeting
Cada torre puede combinar hasta tres criterios únicos: progreso, Health/Armor/Shield altos o bajos, menor HP de la capa activa y velocidad rápida/lenta. El segundo criterio se usa solo si empata el primero; el tercero si ambos empatan.

No implementar 15 modos antes de necesitarlos.

## Height advantage
Framework:
```text
height_delta = tower_elevation - target_elevation
```
Debe existir una función única que traduzca `height_delta` a bonus.

Regla de demo: cada nivel de elevación suma +1 al daño base y +0.5 hex al alcance. Son valores configurables y provisionales.

## Auditoría del sistema de torres

La implementación de los siete perfiles, sus fórmulas, límites del sistema de niveles, XP, Mana, críticos, estados y discrepancias con la referencia externa está desglosada en [15 — Auditoría del sistema de torres](15_AUDITORIA_SISTEMA_DE_TORRES.md). Esa auditoría describe código y Resources; por sí sola no aprueba balance nuevo.

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

`StatusEffectData` configura ID/nombre, duración, intervalo de tick, máximo de stacks, regla, multiplicador de velocidad, daño por tick y tags del daño periódico. `TowerData.status_effects` adjunta uno o más efectos a cada impacto. El flujo actual en `DamageService` resuelve primero el daño directo y la contrarregeneración; después aplica los payloads a un objetivo que siga `MOVING`. Los DoT construyen un paquete independiente sin payloads, usan el `source_id` almacenado en el estado y regresan a `DamageService`, por lo que respetan Armor y multiplicadores de `EnemyData` como cualquier otro daño.

Reglas runtime: `REFRESH` conserva una acumulación; `ADD_STACKS` incrementa hasta `max_stacks`. En ambos casos la aplicación renueva la duración completa y conserva la fase del próximo tick. Una reaplicación del mismo ID usa los datos y el origen de la aplicación más reciente. Cada enemigo tiene sus propios contadores aunque varios compartan el mismo Resource. Los multiplicadores de velocidad se combinan por mínimo; `1.0` significa velocidad normal. Un estado desaparece al llegar su duración a cero y todos se limpian cuando el enemigo muere o llega a la base. Los ticks aplicados antes de que expire el tiempo restante se resuelven; no hay daño periódico después de la expiración.

La muestra DEBUG de M8 conserva Slow, Burn y Bleed; la Status Probe sigue siendo fixture de depuración. Frost Keep aplica Slow ×0,85 durante 1 s y hace 2 de daño base a 120 RPM; Tesla Coil hace 9 de daño base.

## M9.5 — Roster de siete torres

La demo incorpora Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder antes de las cartas. Los perfiles viven en `TowerData`; los atajos `1–7` muestran nombre, color placeholder y coste. `8`, `9` y `0` retienen Armor Piercing Bolt, Sapping Bolt y Status Probe para diagnóstico M7/M8.

Los patrones disponibles son objetivo único, área, cadena, cono, hoja por PATH y todos-en-alcance. Ballista dispara un proyectil; Mortar lanza una granada a la posición seleccionada y explota con daño de área al aterrizar; Tesla descarga sobre todos los enemigos en alcance circular. Shredder lanza una hoja por la ruta actual del objetivo, hace impacto directo, añade Bleed por el 100% del daño base restante y pierde 1 de daño base por enemigo atravesado. Frost Keep selecciona y alcanza objetivos por un cuadrado alineado a pantalla cuyo semilado es su alcance; aumenta RPM por cobertura PATH, con valores base propios de 2 daño y 120 RPM; aplica Slow ×0,85 durante 1 s. Flame/Poison afectan un cono y convierten el 100% del daño base en Burn/Poison. Bleed/Burn/Poison detienen la regeneración de su capa y dan +1 al multiplicador de ataques directos contra esa capa; los ticks aplican daño 100%/50% según su capa. Ver 11_INITIAL_CONTENT_PLACEHOLDERS.md y ADR-0023.

Regla especial de Ballista: cada torre conserva su propio cooldown de ataque. Si el enemigo objetivo muere por otra fuente mientras su proyectil sigue en vuelo, esa Ballista recupera el 33 % del cooldown completo del disparo (se resta del tiempo restante, hasta cero). El disparo que mata al objetivo no da reembolso; tampoco se aplica después de que el proyectil ya impactó o si el enemigo alcanza la base. Cada proyectil solo puede reembolsar una vez. Ver [ADR-0034](../decisions/ADR-0034-reembolso-de-cooldown-ballista.md).

Poison es el tag 8 de daño; `EnemyData.poison_damage_multiplier` participa junto con los otros multiplicadores por tag. Shield se implementa en M12A y ocupa la capa superior del enemigo. Los multiplicadores por capa de los siete perfiles parten de la tabla del usuario; otros valores siguen provisionales. Ver [ADR-0014](../decisions/ADR-0014-roster-jugable-de-siete-torres.md), [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md) y [11_INITIAL_CONTENT_PLACEHOLDERS.md](11_INITIAL_CONTENT_PLACEHOLDERS.md).

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

## Habilidades enemigas de campaña

EnemyData declara habilidades tipadas con triggers de aparición, cercanía a la base, agotamiento de Armor/Shield, muerte o temporizador. Haste suma movimiento hasta 60% y decae 6 puntos por segundo; Fortification resta 5 al daño base recibido por golpe, con la misma fuerza máxima y decaimiento. La cercanía a base activa dentro de 5 hexágonos y las auras afectan un radio de 2. Las invocaciones cuentan por encima de los 1.093 enemigos directos de la campaña; transformaciones conservan la instancia y la recompensa de baja, y WaveDirector no termina hasta su derrota final. Los valores y habilidades por perfil están en 13_CONTENT_ROSTER.md y ADR-0037.

Los PNG de enemigos miran a la derecha por defecto. PathFollowerComponent emite cambios de dirección horizontal y Enemy refleja el sprite al moverse a la izquierda; al dirigirse a la derecha restablece el sprite sin reflejar.
## Enemy path movement
Movimiento visual continuo entre centros de hexes de la ruta.
El enemigo conoce:
- path actual;
- índice;
- progress normalizado.

M5 consume la secuencia axial `PathRoute` cacheada por M4 para inicializar el camino del enemigo y conserva sus propios waypoints, índice y progreso. Si cambia el mapa solo entre rondas, no hace falta recalcular rutas con enemigos vivos. `WaveDirector` escoge candidatos spawn según la política de cada grupo; la muestra usa `FIRST_SORTED`, mientras que la configuración final por ronda sigue abierta. M4 expone candidatos y no decide esa política.

La primera integración M5 implementa `HealthComponent`, `GameBase`, `Enemy`, `PathFollowerComponent` y `WaveDirector`. El enemigo se mueve continuamente entre centros de hex, inicia en la coordenada exterior del endpoint y aplica su daño configurado al llegar; el director retira enemigos llegados o derrotados y termina la oleada al concluir los spawns y quedar cero enemigos activos. La UI bloquea la colocación de terreno durante `COMBAT`; una base agotada cambia a `RUN_DEFEAT`, y una oleada superada habilita `TERRAIN_EXPANSION`.

## M10 — Campaña de 45 rondas

La campaña M10 tiene 45 WaveData consecutivas y valida el total directo 1.093 según la tabla de 14_CAMPANA_45_RONDAS.md. WaveEnemyGroupData.count es cantidad real y no se multiplica por endpoints; WaveDirector distribuye los enemigos por round-robin. El contador activo incluye invocaciones y transformaciones. Cyclops/Werewolf no son Minibosses especiales en 17/19. Ooogie von Ooogovich invoca dos Bats cada 2 s y se transforma en Bat con 2.500 Health; la recompensa se conserva hasta la derrota final. La demo termina al limpiar ronda 45. Los perfiles, habilidades y velocidades adoptados están en ADR-0037/13_CONTENT_ROSTER.md; salud, daño y Gold por baja no escalan por ronda. Tras 1–44 se ofrece expansión y M11 puede abrir una card después de colocar terreno. Los fixtures M7/M8 se pueden repetir aislados. El calendario previo se conserva solo en los ADR históricos sustituidos.

M6 añadió el primer ciclo defensivo con una torre `Basic Bolt`, nombre del prototipo que hoy solo se conserva como fixture `Basic Bolt (DEBUG)`; no forma parte del roster actual. La aceptación de ese prototipo es histórica: para los nombres y comportamiento del roster vigente, consulta M9.5 y la nomenclatura canónica. En su primera etapa se podía colocar en una celda Grass o Mountain libre, seleccionar, cambiar prioridad y mejorar. La prioridad consultaba enemigos vivos en alcance cada 0.1 s: primero/último por fracción recorrida de `PathRoute`, mayor Health actual o mayor Armor configurada. El ataque ocurría durante `COMBAT`, dentro del alcance, a la cadencia configurada, y mostraba un breve flash vectorial de hitscan. La torre no bloqueaba PATH ni exigía recalcular rutas. M7 enrutó el ataque por `DamageService`.

La altura de la torre sumaba provisionalmente `height_range_bonus_per_level` al alcance por nivel de elevación. Los valores iniciales del prototipo Basic Bolt eran 10 de daño, 1 ataque/s, 3 hexes de alcance, +5 daño y +0.25 hex por nivel hasta nivel 3; cada nivel de elevación también agregaba +0.25 hex. Eran datos configurables para validar el sistema, no balance final. M9 añadió costes configurables de construcción/mejora; desde M7 el armor mitigaba según el paquete de daño.

## M7 — Pipeline histórico (sustituido por M12A)

Esta sección conserva el comportamiento de M7 para registrar su evolución. Su fórmula plana de Armor y los daños esperados en la prueba manual inferior ya no describen el combate vigente; usa los criterios M12A para verificar las capas y el daño actual.

`DamageService` es dueño de la fórmula de combate entre una torre y un enemigo. `Tower` arma un `DamagePacket` a partir de su `TowerData` y no calcula mitigación ni Health por su cuenta. La instancia de servicio pertenece a `Main` y se inyecta a `BuildController`/torres para que no haya un Autoload global con estado de combate.

Orden implementado para esta etapa:
1. construir paquete con daño bruto, ID de origen, tags y counters configurables;
2. dejar preparado el paso de modificadores de run (no hay proveedor de modificadores antes de M11);
3. absorber armor plano: `min(raw_damage, armor * armor_multiplier)`;
4. aplicar el daño restante, el multiplicador recibido por tags de `EnemyData` y `health_multiplier`, redondeando hacia abajo a HP entero;
5. aplicar HP a través de `HealthComponent` y contrarregeneración temporal;
6. emitir `DamageService.damage_resolved`; `Enemy` emite sus señales de Health/muerte existentes;
7. M8 añade efectos de estado después del daño; M9 conecta pagos por baja y por ronda limpia mediante eventos del director de oleada.

Tags provisionales: Físico, Fuego y Arcano. Cada enemigo puede definir un multiplicador recibido por tag; varios tags de un paquete se combinan multiplicándose. Regeneración se acumula como fracción por segundo, no supera HP máximo y solo se ejecuta mientras el enemigo vive y avanza. Un counter de fuerza `0..1` reduce proporcionalmente la regen durante una duración configurada; impactos sucesivos mantienen la fuerza más alta y el mayor tiempo restante, sin acumularse por encima de 100%.

El HUD M7 permite elegir Basic Bolt, Armor Piercing Bolt o Sapping Bolt y seleccionar la oleada de diagnóstico con un `Armored Regenerator`. La línea debug muestra HP, Armor, regen base/efectiva y daño estimado para la torre seleccionada. Los tres perfiles y el enemigo diagnóstico son muestras temporales, no contenido o balance confirmados. Ver ADR-0010 y el procedimiento manual de `10_ACCEPTANCE_TESTS.md`.

El contenido M5 continúa siendo una prueba funcional de base 50 HP, enemigo 20 HP, velocidad 90 px/s, daño de llegada 10, tres enemigos con intervalo 1 s y política `FIRST_SORTED`. Con M6 las torres pueden derrotar esos enemigos; M7 añade el pipeline de mitigación, tipos y regeneración. M9 añade recompensas provisionales por bajas y ronda completada, además de economía de Gold/Mana; la repetición actual es de diagnóstico y no representa la secuencia de rondas M10 ni balance final.

## M9 — Economía y Mana

`TowerData` declara `build_cost`, el coste base por capa `upgrade_base_cost_by_layer`, el factor exponencial de coste y `mana_cost_per_attack`. `BuildController` rechaza una compra sin Gold y solo marca ocupada la celda cuando el cobro se acepta. Una mejora cobra `round(coste_base_de_capa × factor_coste^nivel_de_capa)`; si la capa está en el máximo de 15 o falta saldo, no se cobra. La barra de atajos y cada botón H/A/S muestran el coste correspondiente y se deshabilitan si no hay saldo; los atajos también atenúan su contenido para que la indisponibilidad sea visible.

Antes de ejecutar el paquete de daño, una torre con coste de Mana solicita el gasto al `RunEconomyService`. Sin saldo suficiente no dispara y vuelve a intentarlo después de una espera corta; no se acumula deuda ni se permite saldo negativo. El servicio regenera Mana durante las fases activas de run y limita el total a `maximum_mana`. M9 no tiene edificios de soporte ni fuentes de Mana por torre.

`WaveDirector` paga `EnemyData.kill_reward` exactamente una vez cuando el enemigo muere, incluidos kills de DoT. Un enemigo que llega a la base no cobra. `WaveData.round_reward` se paga cuando terminaron todos los spawns y no queda ningún enemigo activo; una derrota no da el bonus de limpieza, pero tampoco revierte pagos por bajas ya efectuadas. La UI pasa por `ROUND_REWARD` durante 0.8 s y después habilita `TERRAIN_EXPANSION`. Si el calendario M11 lo indica, al colocar el terreno se abre `CARD_OFFER` y la próxima ronda no pasa a `ROUND_PREP` hasta seleccionar una carta.

La primera configuración arranca con 150 Gold y 100/100 Mana; su tasa base es 1.5 Mana/s (equivalente a 3 Mana cada 2 s). Las cifras son provisionales, no balance confirmado. La interfaz presenta las mejoras de regeneración con equivalencias de cantidades enteras por intervalos enteros y sin decimales; conserva internamente la tasa exacta. El Gold de run es distinto a la moneda meta que M12 conserva entre runs. Sin economía inyectada, los callers antiguos de `Tower`/`BuildController` mantienen compatibilidad para smokes previos; `Main` siempre inyecta el servicio configurado. Ver ADR-0013, ADR-0030 y el procedimiento manual M9 en `10_ACCEPTANCE_TESTS.md`.

## M11 — Modificadores de carta

`Main` configura un `RunCardService` local desde `CardPoolData` y lo inyecta a `BuildController`, las torres nuevas y `RunEconomyService`. Las torres consultan efectos runtime de daño, alcance, área, coste, crítico, multiplicadores H/A/S, duración de estados y payloads de estado. `Tower` admite multiplicador de cadencia, pero el pool actual de 18 cards no define esa operación; Frost Keep aumenta RPM por cobertura PATH. Los payloads se duplican antes de ajustar duración. La economía consulta bonus de Mana máximo/regeneración. El calendario y cifras son provisionales. ADR-0021/0022/0023 registran las decisiones.

## M12A — Stats de torre y capas de HP

`TowerData` contiene valores base/Health/Armor/Shield/RPM/rango/Mana/precio. El precio escala por cantidad del mismo perfil; demoler baja el conteo sin reembolso provisional. Daño por golpe usa el multiplicador de la capa activa y se limita a su HP; no hay overflow de una capa a otra en el mismo hit. Los críticos usan chance en bandas 0–150% y multiplicadores ×2/×3/×4. Upgrades comprados o XP acumulada añaden +1 de daño base y +1 al multiplicador de una sola capa; cada capa progresa de forma independiente de 0 a 15 mejoras (45 totales por torre). Costes Gold y XP escalan por capa con factores exponenciales configurables; parten de los valores base del Resource. XP solo se acumula mientras la torre sostiene un objetivo en alcance y va a la capa activa de ese enemigo. Tres selectores numerados muestran los criterios 1–3; al elegir un criterio ya usado en otra posición, se intercambia con el criterio desplazado. Los botones de mejora muestran nivel, XP actual/umbral en una barra teñida por la capa, coste y efecto. Enemy dibuja filas Shield azul, Armor beige y Health verde cuando el máximo de esa capa es positivo; la barra Health está fragmentada. Bleed/Burn/Poison bloquean regeneración Health/Armor/Shield y añaden +1 al multiplicador de ataque de la capa correspondiente; los ticks hacen daño completo a su capa y mitad a las otras. Cartas globales pueden sumar +1 adicional a un multiplicador de capa. La barra y los stats pueden comprobarse en DEBUG `capas Shield/Armor/Health`; los perfiles de campaña con Shield también muestran esa barra durante las 45 rondas. Ver [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md) y [ADR-0046](../decisions/ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md).
