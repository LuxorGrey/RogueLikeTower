# Combat System

## Objetivo
Conservar la lectura estratégica de Rogue Tower: enemigos con defensas distintas y torres que funcionan mejor/peor según el objetivo.

## Enemy survivability
Cada enemigo tiene como mínimo:
- Health.
- Armor.
- Regeneration.

No copiar números de Rogue Tower. Crear sistema propio configurable.

## Damage pipeline
Centralizar el cálculo:
1. torre crea `DamagePacket`;
2. aplicar modificadores de run;
3. resolver counter/perfil contra armor/health;
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
Mínimo:
- first/progress;
- last;
- highest health;
- highest armor.

No implementar 15 modos antes de necesitarlos.

## Height advantage
Framework:
```text
height_delta = tower_elevation - target_elevation
```
Debe existir una función única que traduzca `height_delta` a bonus.

La fórmula final sigue abierta. Para prototipo usar bonus configurable y documentado, por ejemplo rango adicional o multiplicador moderado. No fijarlo como balance definitivo.

## Status framework
Catálogo reducido inicial:
- Slow: modifica velocidad.
- Burn: DoT.
- Bleed: tercer ejemplo DoT provisional; no fija la lista final.

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

La muestra de M8 contiene Slow (`0.55×`, dura 2.5 s y refresca), Burn (2 de daño de Fuego por segundo, dura 5 s y acumula hasta 3) y Bleed (1.5 de daño Físico cada 0.75 s, dura 1.5 s y acumula hasta 4). La Sonda ataca cada 2 s para dejar visible el hueco de expiración de Bleed, mientras Slow se refresca y Burn alcanza el máximo de stacks. No se implementan resistencias de estados: el diseño no ofrece todavía resistencias configurables y el roadmap las deja condicionales. La torre `Sonda de estados M8` y el enemigo lento de 180 HP son solo fixtures de depuración, no balance ni catálogo final. ADR-0012 detalla estas elecciones; `10_ACCEPTANCE_TESTS.md` define los criterios de aceptación manual.

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

M6 añade el primer ciclo defensivo con una torre `Basic Bolt`: se puede colocar en una celda Grass o Mountain libre, seleccionar, cambiar prioridad y mejorar. La prioridad consulta enemigos vivos en alcance cada 0.1 s: primero/último por fracción recorrida de `PathRoute`, mayor vida actual o mayor armadura configurada. El ataque ocurre durante `COMBAT`, dentro del alcance, a la cadencia configurada, y muestra un breve flash vectorial de hitscan. La torre no bloquea PATH ni exige recalcular rutas. M7 enruta el ataque por `DamageService`.

La altura de la torre suma provisionalmente `height_range_bonus_per_level` al alcance por nivel de elevación. Los valores iniciales de Basic Bolt son 10 de daño, 1 ataque/s, 3 hexes de alcance, +5 daño y +0.25 hex por nivel hasta nivel 3; cada nivel de elevación también agrega +0.25 hex. Son datos configurables para validar el sistema, no balance final. Las mejoras no cuestan moneda todavía; M9 añadirá economía. Desde M7 el armor mitiga según el paquete de daño.

## M7 — Pipeline actual

`DamageService` es dueño de la fórmula de combate entre una torre y un enemigo. `Tower` arma un `DamagePacket` a partir de su `TowerData` y no calcula mitigación ni vida por su cuenta. La instancia de servicio pertenece a `Main` y se inyecta a `BuildController`/torres para que no haya un Autoload global con estado de combate.

Orden implementado para esta etapa:
1. construir paquete con daño bruto, ID de origen, tags y counters configurables;
2. dejar preparado el paso de modificadores de run (no hay proveedor de modificadores antes de M11);
3. absorber armor plano: `min(raw_damage, armor * armor_multiplier)`;
4. aplicar el daño restante, el multiplicador recibido por tags de `EnemyData` y `health_multiplier`, redondeando hacia abajo a HP entero;
5. aplicar HP a través de `HealthComponent` y contrarregeneración temporal;
6. emitir `DamageService.damage_resolved`; `Enemy` emite sus señales de vida/muerte existentes;
7. no hay recompensa hasta M9 ni efectos de estado hasta M8.

Tags provisionales: Físico, Fuego y Arcano. Cada enemigo puede definir un multiplicador recibido por tag; varios tags de un paquete se combinan multiplicándose. Regeneración se acumula como fracción por segundo, no supera HP máximo y solo se ejecuta mientras el enemigo vive y avanza. Un counter de fuerza `0..1` reduce proporcionalmente la regen durante una duración configurada; impactos sucesivos mantienen la fuerza más alta y el mayor tiempo restante, sin acumularse por encima de 100%.

El HUD M7 permite elegir Basic Bolt, Perforadora M7 o Drenadora M7 y seleccionar la oleada de diagnóstico con un `Armored Regenerator`. La línea debug muestra HP, armadura, regen base/efectiva y daño estimado para la torre seleccionada. Los tres perfiles y el enemigo diagnóstico son muestras temporales, no contenido o balance confirmados. Ver ADR-0010 y el procedimiento manual de `10_ACCEPTANCE_TESTS.md`.

El contenido M5 continúa siendo una prueba funcional de base 50 HP, enemigo 20 HP, velocidad 90 px/s, daño de llegada 10, tres enemigos con intervalo 1 s y política `FIRST_SORTED`. Con M6 las torres pueden derrotar esos enemigos; M7 añade el pipeline de mitigación, types y regeneración. La demo sigue sin representar balance final ni rondas repetibles. Recompensas permanecen pendientes de M9; la secuencia de rondas corresponde a M10.
