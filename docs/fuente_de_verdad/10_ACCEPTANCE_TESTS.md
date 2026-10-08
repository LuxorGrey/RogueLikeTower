# Acceptance Tests

## Grid
- Rotar un HexCoord 6 veces devuelve la posición original.
- Cada celda tiene exactamente 6 vecinos potenciales.
- Distancia A->B == B->A.

## TerrainPiece
- Toda plantilla cargada contiene 7 celdas únicas, conectadas, con pivote `(0,0)`.
- Se cargan las cinco plantillas M3: `straight`, `gentle_turn`, `hard_turn`, `fork` y `convergence`.
- No se puede confirmar una pieza que solape celdas existentes o no toque el tablero por un borde.
- Rotar 6 veces devuelve la pieza original.
- Path edges y sockets laterales flexibles rotan junto a la geometría.
- Las conexiones internas requieren `path_edges` recíprocos; en el borde entre piezas puede emparejarse un socket explícito con uno flexible o dos sockets flexibles complementarios.
- Un borde explícito sin pareja frente a una celda existente es inválido, una salida flexible puede permanecer abierta, y ninguna salida explícita puede entrar en terreno no PATH.
- La salida externa de una celda PATH abre visualmente los laterales contiguos que también queden fuera de la huella y permite colocar una pieza conectada por cualquiera de esos lados.
- Una pieza expansiva requiere enlazar al menos un PATH existente por un par de sockets compatibles.
- El ghost legal se muestra verde; el ilegal, rojo con el motivo en HUD. Solo la colocación legal confirma.
- Confirmar inserta las siete celdas en el tablero; Cancelar, Esc y clic derecho no alteran el tablero.
- La plantilla inicial admite su socket de salida al exterior sin exigir una conexión entrante.
- La verificación de ruta global spawn-base se realiza con el snapshot M4 de `PathGraph` antes de confirmar una pieza.

## Paths
- Solo se crea arista entre PATH adyacentes si ambos sockets ofrecen caras recíprocas en la unión de máscaras exactas/flexibles.
- Un socket exacto abierto fuera del mapa produce endpoint spawn; una oferta flexible sola no produce endpoint.
- Una salida exacta hacia no-PATH o hacia PATH sin socket complementario invalida el snapshot.
- La base provisional del prototipo está en PATH `(0,0)`; una base ausente invalida el grafo.
- Cada endpoint spawn y cada nodo PATH tiene una ruta a la base; los caminos huérfanos invalidan la colocación candidata.
- Una recta produce ruta válida, bifurcación conserva nodo de grado 3 o mayor y convergencia vuelve a compartir nodos.
- BFS devuelve una ruta mínima por número de enlaces; repetir sobre el mismo estado produce la misma secuencia usando el orden de direcciones como desempate.
- El snapshot se reconstruye al iniciar y al confirmar una pieza, no al mover el ghost ni cada frame.
- No se confirma una pieza que dejaría un endpoint o subred PATH sin ruta a base.
- `D` alterna el overlay con rutas por spawn, candidatos de spawn y marcador de base.
- Ningún spawn activo puede iniciar ronda sin ruta a base; `WaveDirector` selecciona únicamente entre rutas válidas según la política configurada en el grupo.
- Smoke M4: siete escenarios automatizados cubren ruta inicial, pareja exacta-flexible, flexible sin endpoint, salida inválida hacia GRASS, socket exacto sin pareja, PATH desconectado y bifurcación/convergencia con BFS determinista.

## Elevation
- Path = 0.
- Mountain = 2.
- Torre conserva su HexCoord aunque sprite se dibuje elevado.
- Click/selección funciona sobre sprite desplazado.
- Hover sobre una cara superior resalta con un color que distingue PATH, GRASS y MOUNTAIN.
- En el tablero, el HUD superior muestra coordenadas axiales globales `(q,r)`, terreno y altura; al salir del top face se limpia.
- Un cliff no se detecta como cara superior.
- Las caras cliff se dibujan sin avisos de triangulación y conservan el desnivel de cada borde.
- Los hijos del contenedor `Entities` se ordenan por Y.

## Map navigation
- `H` alterna el HUD sin mover ni escalar el mapa.
- Arrastrar con el botón central pannea el tablero y el ghost juntos.
- La rueda acerca/aleja con zoom uniforme y mantiene el punto bajo el cursor.
- El zoom queda acotado entre `0.45×` y `2.5×`.
- `R` centra la cámara sobre las celdas colocadas y restablece zoom `1×`.

## Combat
- La base inicializa vida desde `BaseData`, recibe daño y emite derrota al llegar a 0.
- Enemy acepta `EnemyData` y `PathRoute`, comienza fuera del endpoint y recorre los centros axiales hasta base.
- La muerte de un enemigo detiene su movimiento y lo retira una sola vez.
- La primera oleada genera todos los enemigos configurados y solo termina tras completar los spawns y quedar cero enemigos vivos.
- Cada llegada daña la base por `EnemyData.base_damage`; el HUD refleja vida y enemigos en ruta.
- Durante `COMBAT` no se puede colocar terreno; derrota bloquea la expansión y victoria de la muestra habilita `TERRAIN_EXPANSION`.
- Smoke M5: la oleada provisional de tres enemigos termina con base en 20/50 HP, cero enemigos activos, y se cubren las rutas, la muerte de enemigo y la derrota de base.
- Enemy llega a base y causa daño.
- Tower adquiere target y lo daña.
- Armor/health/regen alteran el resultado.
- Status expira correctamente.
- Matar enemigo entrega recompensa una vez.

## M6 Towers
- `Basic Bolt` carga desde `TowerData`; ID, daño, cadencia, alcance, terreno permitido, prioridades y mejoras están configurados en Resource.
- Build mode se inicia en `ROUND_PREP`, `COMBAT` y `TERRAIN_EXPANSION`, y no en `RUN_SETUP` ni `RUN_DEFEAT`.
- Una torre se coloca en una celda `GRASS` o `MOUNTAIN` construible y libre; PATH, una celda vacía del mapa, terreno no permitido y una celda ocupada se rechazan con explicación en HUD.
- Confirmar construcción marca `HexCell.occupied` y `tower_id`, crea una sola torre en la escena y la selecciona; no cambia el `PathGraph`.
- El preview de construcción aparece en la casilla bajo el cursor: verde si es legal, rojo si no, con el alcance provisional. Al seleccionar una torre, su marcador de alcance coincide con sus estadísticas actuales.
- La UI selecciona cada prioridad: más avanzado, menos avanzado, más vida actual y más armadura. Los empates conservan orden estable por ID de instancia.
- Una torre solo adquiere y ataca enemigos `MOVING` dentro de su alcance durante `COMBAT`; mantiene la cadencia configurada y el daño reduce la vida del objetivo. Fuera de alcance o fuera de combate no ataca.
- La elevación suma el bonus de alcance configurable de TowerData. La elevación no modifica la coordenada ni la ocupación lógica de la torre.
- Mejorar aumenta los stats configurados hasta `max_level`; una mejora posterior se bloquea. En el alcance histórico M6 las mejoras eran gratuitas; el flujo vigente con coste se verifica en la sección M9.
- El placeholder muestra la torre en `Entities` Y-sorted, orientación hacia el objetivo y un flash de ataque; el anillo de alcance se ve al seleccionar.
- El `armor` de `EnemyData` permite ordenar por highest armor y desde M7 mitiga daño en `DamageService`.
- Smoke M6: `tests/m6_tower_smoke.tscn` comprueba fases, Grass/Mountain, rechazo de PATH/ocupado, ocupación axial, niveles/alcance, elevación, las cuatro prioridades, filtro de rango, cooldown/cadencia, daño hitscan y descarte seguro de una referencia a enemigo eliminado.

### Prueba manual de M6 en el juego
1. Ejecutar `game/main/main.tscn`; en `ROUND_PREP` pulsar el botón **1 · BOLT** o la tecla `1` para entrar en modo de construcción.
2. Pasar el cursor por el camino `(0,0)`: el HUD debe explicar que solo vale Grass o Montaña y el preview debe marcarlo rojo. Hacer clic no debe ocupar esa casilla.
3. Pasar el cursor por Grass `(1,-1)`: el preview debe ser verde y mostrar el anillo de alcance. Hacer clic; debe aparecer una torre seleccionada y el resumen compacto de nivel/daño/alcance. Intentar construir otra en el mismo hex debe ser rechazado.
4. Elegir prioridades distintas en el selector; la prioridad elegida debe aplicarse a la torre. Usar **Mejorar** dos veces: nivel 3/3, daño 20 y alcance mayor que en nivel 1; el botón queda deshabilitado al máximo.
5. Iniciar la oleada seleccionada. Enemigos dentro del radio deben perder vida al ritmo de la cadencia, la torre debe girar hacia un objetivo y mostrar el flash de ataque. La oleada termina cuando el director no tiene enemigos activos; no se deben crear recompensas ni cobrarse costes todavía.
6. (Opcional) Repetir la colocación en Montaña `(0,1)`: debe aceptar la casilla y el estado/preview debe reflejar su bonus provisional de elevación.

Para dar M6 por aceptado deben pasar todos los bullets de la sección y la prueba manual debe confirmar el feedback visual e interacción. El smoke prueba reglas deterministas; la prueba manual cubre el render y el input de la escena.

## M7 Damage model
- Cada torre configurada crea un `DamagePacket` con ID de origen, tags, multiplicadores y counter definidos por `TowerData`; las torres no aplican fórmulas propias.
- Todos los impactos de torre pasan por el `DamageService` de `Main`; no es Autoload ni comparte la instancia mutable de `TowerData`.
- La mitigación sigue una fórmula única: `armadura_absorbida = min(daño_bruto, armadura × armor_multiplier)` y `daño_HP = floor(max(daño_bruto - armadura_absorbida, 0) × multiplicador_de_tags × health_multiplier)`, limitado a la vida restante.
- Los tags Físico/Fuego/Arcano/Poison se validan como bitmask; cada enemigo declara sus multiplicadores recibidos y los tags combinados multiplican sus resultados.
- La regeneración por segundo acumula fracciones, no supera la vida máxima y solo corre mientras el enemigo sigue vivo. El counter reduce la regen según su fuerza durante la duración configurada; varios impactos usan la mayor fuerza y el máximo tiempo restante.
- `DamageService.preview_damage()` y `apply_damage()` usan el mismo cálculo; el servicio emite un resultado con armadura absorbida, multiplicador de tipo, HP aplicado y objetivo derrotado.
- El HUD muestra HP, armadura, regen base/efectiva y daño estimado del objetivo de la torre seleccionada; la descripción de torre presenta su perfil configurado.
- Se pueden seleccionar Ballista (6 HP al fixture), Perforadora (9 HP) y Drenadora Arcana (7 HP y 100% de contrarregeneración durante 1.25 s) contra el blindado de armadura 4, regen 2 HP/s y multiplicador arcano 1.25. Estos valores son placeholders.
- Status y sus payloads no se aplicaban en M7; M8/M9 añadieron estados y recompensas en hitos posteriores.

### Prueba manual de M7 en el juego
1. Ejecutar `game/main/main.tscn`. La interfaz principal debe limitarse a base, estado de oleada, selección de oleada, resumen de torre y diagnóstico del objetivo. La cabecera muestra permanentemente **F3 - Terreno   H - Interfaz**; `F3` abre/cierra el panel técnico del terreno y `H` oculta/muestra todo el HUD.
2. Elegir **Diagnóstico · blindado regenerador**. Construir una torre próxima al camino usando `1` (Ballista), `8` (Perforadora) o `9` (Drenadora); las tres opciones deben estar disponibles. Hacer clic en una casilla libre de Grass/Montaña.
3. Iniciar la oleada seleccionada. Seleccionar la torre si hace falta. Cuando el enemigo entre en alcance, el debug compacto debe mostrar vida actual/máxima, armadura, regeneración y daño estimado; si el counter está activo también debe mostrar la regen efectiva reducida.
4. Repetir con cada perfil: Ballista estima 6 HP; Perforadora estima 9 HP porque solo aplica 1 punto de armadura; Drenadora estima 7 HP por vulnerabilidad arcana y, tras impactar, reduce la regen a 0 HP/s durante hasta 1.25 s.
5. Al completar una oleada debe habilitarse la expansión y la selección de oleada. Cambiar a **Oleada básica · 3 enemigos**, iniciar y completarla; después volver a elegir el diagnóstico e iniciarlo de nuevo. Coloca suficientes torres para derrotar enemigos y conservar vida de base durante la prueba: el HP perdido persiste entre fixtures. Repetir oleadas no debe dejar enemigos de la anterior ni bloquear el botón de inicio. Esta repetición sirve para depurar y no sustituye el loop de 20 rondas M10.
6. Con Ballista, observar el HP del blindado entre impactos: la vida perdida debe recuperarse a ritmo de 2 HP/s mientras no haya counter activo, hasta el máximo 60. Con Drenadora, no debe subir durante la contrarregeneración activa.

Para cerrar M7 deben pasar todos los criterios anteriores y la prueba manual debe confirmar que el HUD refleja los valores reales durante combate, que los atajos 1, 8 y 9 funcionan incluso tras usar controles de interfaz y que se pueden iniciar oleadas distintas repetidamente. También se debe revisar que el HUD compacto y el panel F3 caben en la ventana de 1440×900. Los perfiles y cifras no se convierten en balance confirmado.

## M8 Status Effects
- Cada `StatusEffectData` valida ID/nombre, duración, intervalo, regla, límite de stacks, velocidad y perfil DoT; los efectos sin efecto jugable o con tags inválidos se rechazan.
- `TowerData.status_effects` configura los payloads por torre y no admite IDs duplicados en el mismo perfil. El Resource no se modifica al aplicarlo.
- Un impacto válido aplica estados después del daño directo y solo si el objetivo sigue en `MOVING`; si el golpe lo derrota, no recibe estado.
- `REFRESH` conserva una acumulación y reinicia duración; `ADD_STACKS` incrementa hasta `max_stacks` y reinicia duración. Reaplicar conserva la fase del siguiente tick; las diferentes instancias de enemigo mantienen estado independiente.
- Slow cambia realmente la velocidad de `PathFollowerComponent`; los multiplicadores activos se combinan por mínimo y, al expirar/limpiar, la velocidad vuelve a normal.
- Burn/Bleed aplican ticks de daño configurado por `DamageService`, con los tags y mitigación del objetivo. Los ticks no vuelven a aplicar sus propios payloads.
- Al agotarse el tiempo se elimina el estado; muerte o llegada a base limpia todos los estados. El HUD debug enseña el nombre, acumulaciones y tiempo del objetivo de la torre seleccionada; aros del enemigo distinguen Slow, Burn y Bleed.
- La fixture M8 usa un objetivo de 180 HP sin armadura/regen, Sonda de estados a 0.5 ataques/s, Slow refrescable, Burn hasta 3 stacks y Bleed con 0.5 s de ventana observable entre impactos. Es contenido provisional.
- No hay resistencia de estado en M8: no está definida por el diseño fuente.

### Prueba manual de M8 en el juego
1. Ejecutar `game/main/main.tscn`. En el selector de oleada elegir **Estados M8 · objetivo lento**. Para el perfil de diagnóstico, pulsar `0` y colocar **Sonda de estados (M8 prueba)** en Grass `(1,-1)`, que tiene alcance a lo largo de la ruta inicial.
2. Iniciar la oleada seleccionada. La línea de diagnóstico debe identificar **Objetivo de estados (M8 prueba)** y mostrar sus HP, impacto estimado y estados activos. El enemigo debe llevar aros celeste (Lento), naranja (Quemadura) y rojo/rosa (Sangrado).
3. Observar al menos tres impactos: Lento debe mantenerse en una sola acumulación y su duración debe refrescarse; Quemadura debe mostrar `×2` y luego `×3`, sin superar el máximo configurado aunque haya impactos posteriores. El objetivo debe avanzar más despacio mientras Lento esté activo.
4. Sangrado debe hacer bajar HP mediante ticks. Como dura 1.5 s y la torre ataca cada 2 s, su nombre/aro debe desaparecer durante el intervalo entre impactos y volver con el siguiente. Quemadura también debe reducir HP por ticks. Esta comparación comprueba expiración y aplicación del daño por el pipeline común.
5. El objetivo de entrenamiento debe sobrevivir el tiempo suficiente para observar los efectos y finalmente llegar a la base; en ese cambio de estado, sus efectos y aros desaparecen. El HUD deja de mostrar un objetivo cuando ya no hay uno vivo en alcance. La oleada termina con cero enemigos activos y se habilita volver a elegir una oleada.
6. Repetir la oleada M8: los stacks, timers y ticks deben comenzar limpios en la nueva instancia. Elegir después la oleada de diagnóstico M7 para confirmar que los atajos `1`, `8` y `9` y sus perfiles conservan el comportamiento anterior.

Para dar M8 por aceptado deben pasar todos los criterios de la sección y la prueba manual debe verificar velocidad real, refresh, límite de stacks, daño periódico, expiración antes de la llegada, limpieza al finalizar la ruta, HUD y aros. Registrar cualquier ajuste de valores de fixture como provisional; la prueba no convierte Bleed ni estos números en diseño final.

## M9 Economy + Mana
- `Main` configura `RunEconomyService` desde `RunEconomyData`; el perfil de prueba inicia con 150 oro, 30/100 maná y regen de 1.5/s. El HUD muestra ambos saldos y la regen.
- El oro de construcción es runtime de esta run y no altera `MetaProgression.meta_currency` ni se persiste como moneda meta.
- Los siete perfiles principales y sus costes aparecen en la barra: Ballista 30, Mortar 80, Tesla 70, Frost 50, Flame 65, Poison 65 y Shredder 100 oro. Los atajos `8`, `9` y `0` mantienen Perforadora/Drenadora/Sonda a 40 oro; Drenadora indica 4 maná por ataque.
- Una construcción legal cobra una sola vez antes de ocupar la celda. Terreno inválido, casilla ocupada o saldo insuficiente no cobran ni crean torre/ocupación.
- Una mejora cobra `TowerData.get_upgrade_cost(nivel_actual)`: en los fixtures M9, nivel 1→2 cuesta 20 oro y nivel 2→3 cuesta 35. El nivel/stats aumentan una sola vez; tope o fondos insuficientes dejan nivel y saldo intactos.
- Cada enemigo derrotado paga una sola vez el `EnemyData.kill_reward`, también si la muerte procede de DoT. Un enemigo que llega a base no paga recompensa de baja. Repetir callbacks no duplica el pago.
- La recompensa de `WaveData.round_reward` solo se paga una vez cuando acabaron los spawns y no queda enemigo activo. Si una baja ya pagó y luego la oleada falla, esa recompensa por baja se conserva, pero no se concede el bonus de limpieza.
- Una torre con `mana_cost_per_attack` descuenta maná antes de cada impacto; con saldo insuficiente no ejecuta daño/status, no genera saldo negativo y muestra estado sin maná en el debug de la torre seleccionada. Una torre sin coste de maná no consulta ni consume el saldo.
- El maná regenera en preparación, combate, recompensa y expansión; no supera `maximum_mana` y se detiene en setup/derrota/victoria. No existe una fuente de maná de Support Building.
- Al terminar la oleada, `RunManager` entra a `ROUND_REWARD` durante 0.8 s: no se puede iniciar otra oleada, comprar ni colocar terreno. Después pasa a `TERRAIN_EXPANSION`, habilitando replay y compras.
- Los costes, recompensas y tasas actuales son fixtures configurables y provisionales, no balance confirmado.

### Prueba manual de M9 en el juego
1. Ejecutar `game/main/main.tscn`. El HUD debe mostrar **Oro 150 · Maná 30 / 100 · regen 1.5/s**. La barra inferior debe indicar los costes de los siete atajos `1–7`.
2. Pulsar `1` y colocar Ballista en una casilla Grass libre. El oro pasa a 120, la celda queda ocupada y aparece una sola torre. Seleccionarla y mejorarla: el saldo pasa a 100 al llegar a nivel 2 y a 65 al llegar a nivel 3; los stats cambian según el nivel y el botón deja de ofrecer otra mejora. Repetir clic sobre la torre o un terreno no construible no debe cobrar.
3. Iniciar **Oleada básica · 3 enemigos**. El oro sube +5 por cada enemigo derrotado, una vez por baja, y al terminar todos los spawns con cero enemigos activos sube +20 una sola vez. Si todos mueren, desde los 65 restantes debe terminar en 100. El aviso de recompensa y el saldo tienen que coincidir.
4. Reiniciar la escena para disponer otra vez del perfil inicial. Construir tres Drenadoras M7 en celdas construibles próximas al camino (por ejemplo `(1,-1)`, `(1,0)` y `(0,1)`); deben costar 40 cada una usando la tecla `9`. Con los 30 oro restantes, intentar construir la Sonda M8 de 40 (tecla `0`): el preview/HUD explica que faltan fondos, el atajo se deshabilita y el oro se conserva en 30. Pulsar `Esc` para salir del preview rechazado antes de cambiar la oleada.
5. Elegir **Estados M8 · objetivo lento** e iniciar la oleada. Con tres Drenadoras, el saldo de maná debe bajar en pasos de 4 por disparo mientras hay objetivo. Al llegar a cero, la torre seleccionada muestra **sin maná** y deja de disparar; su ataque no reduce HP ni aplica nuevos estados y el maná no queda negativo. El enemigo puede alcanzar la base; el daño de llegada no da recompensa de kill.
6. Tras la oleada, observar el maná durante la expansión: debe aumentar a 1.5/s hasta 100 y nunca superar ese máximo. La barra de estado vuelve a permitir construir/repetir. Confirmar que el bonus de la oleada M8 es +10 cuando el director completa; repetirla debe pagar otra vez solo por la nueva instancia/ronda de prueba.
7. Durante el instante posterior a una victoria, comprobar que aparece `ROUND_REWARD`; el botón de oleada/selector y la colocación permanecen bloqueados esos 0.8 s, y luego se habilitan al entrar en expansión.
8. (Opcional, comprueba fallo) Reiniciar la escena, no construir torres, y dejar que se filtren enemigos en secuencia: oleada básica, diagnóstico M7 y estados M8. La llegada final que destruya la base debe terminar en derrota sin pagar el bonus de limpieza M8. Las recompensas por baja de eventos anteriores permanecen en el saldo.

Para dar M9 por aceptado deben pasar todos los criterios de la sección y la prueba manual debe confirmar saldos y mensajes en pantalla, cobros atómicos, pago único por evento, rechazo sin fondos, bloqueo de disparos sin maná y regeneración acotada. La prueba debe incluir una llegada a base para verificar que no se confunde con una baja; el bonus de ronda se comprueba aparte. El smoke/validación automática de gameplay queda pendiente; la prueba descrita es interactiva.

## Roster jugable M9.5
- La barra principal muestra los siete perfiles en orden y con sus costes actuales: Ballista 30, Mortar 80, Tesla 70, Frost 50, Flame 65, Poison 65 y Shredder 100. Cada botón indica su color, nombre abreviado y coste; el tooltip explica el ataque y el maná.
- Los atajos `1–7` seleccionan el mismo perfil que el botón y permiten construir solo en Grass/Montaña libre. PATH, terreno ocupado o saldo insuficiente no cobran ni crean torre. Cada una de las siete formas placeholder debe distinguirse en el mapa.
- Ballista solo daña el objetivo elegido. Mortar aplica el daño a enemigos agrupados dentro de su radio de impacto; Frost también afecta en área y refresca Slow.
- Tesla puede alcanzar hasta tres enemigos válidos dentro de rango por descarga, gasta 5 maná por ataque y no daña/aplica estado si el saldo no alcanza.
- Flame daña a los enemigos del cono frontal y aplica Burn; Poison hace lo mismo con su tag Poison y aplica el estado Poison. El aro verde Poison aparece y los ticks pasan por `DamageService` y `EnemyData.poison_damage_multiplier`.
- Shredder lanza la hoja desde la torre hasta la posición actual del objetivo, luego avanza por sus waypoints restantes hacia la base. Cada enemigo en el recorrido recibe un impacto como máximo; cada impacto posterior pierde 1 de daño base. El contacto no resta HP directamente: el primer enemigo recibe un presupuesto bruto de 10 como Bleed y el segundo uno de 9, repartidos entre los ticks del efecto. En un objetivo sin armadura y con multiplicador físico 1, esos presupuestos restan exactamente 10 y 9 HP al completarse los ticks; con defensas, cada tick respeta el pipeline central. La hoja desaparece al terminar la ruta o agotar daño.
- Las torres con maná gastan el coste indicado por disparo; al quedar sin saldo esperan y vuelven a atacar al regenerar. Las torres sin coste no lo consumen.
- Los perfiles M7/M8 de diagnóstico siguen disponibles en `8` (Perforadora), `9` (Drenadora) y `0` (Sonda); no ocupan botones del roster principal.
- Daño, costes, cadencias, radios, cono, multiplicadores y efectos son provisionales configurables. No se requiere Shield porque el modelo EnemyData no tiene escudo.

### Prueba manual M9.5 en el juego
1. Abrir `game/main/main.tscn`. Confirmar los siete botones y probar los atajos `1–7`; el perfil elegido y su nombre deben coincidir. En el tooltip revisar rol, coste, patrón y coste de maná.
2. Reiniciar la escena entre perfiles para recuperar los 150 de oro. Construir cada torre una vez cerca del camino y verificar respectivamente los cargos 30/80/70/50/65/65/100, el color y la silueta. Repetir una colocación sobre PATH o terreno ocupado y confirmar que no se cobra.
3. Ejecutar la oleada básica. Ballista debe seguir un único objetivo; Mortar debe mostrar impacto en el objetivo y afectar al menos otro enemigo si están dentro del radio; Tesla debe dibujar/emitir impactos a varios blancos dentro del límite; Frost debe ralentizar y afectar a enemigos dentro de su área.
4. Probar Flame y Poison sobre enemigos alineados delante de la torre. El cono solo afecta enemigos dentro del ángulo y rango; verificar aros Burn naranja y Poison verde, y que el HP cae por ticks. En Poison, el diagnóstico debe identificar `veneno`, no `arcano`.
5. Reiniciar, seleccionar **Estados M8 · objetivo lento** y construir Shredder (`7`) a rango del objetivo. Iniciar la oleada: la hoja debe llegar a la posición del objetivo y seguir sus waypoints restantes. Al contactar, el HP no debe bajar de golpe; debe aparecer Bleed y el HP debe bajar con sus ticks. El objetivo M8 no tiene armadura y recibe daño físico ×1: el primer impacto debe restarle exactamente 10 HP en total al terminar los dos ticks. Para comprobar perforación, usar la oleada básica con varios enemigos vivos en el mismo trazado; cada enemigo debe recibir un único Bleed, y el segundo debe perder 9 HP en total, comprobando la reducción de 1 punto por perforación. La hoja debe continuar hacia la base y desaparecer al terminar la ruta o quedarse sin daño.
6. Dejar que las torres Tesla/Frost/Flame/Poison gasten su maná. Cuando falte, confirmar que se bloquean sin infligir impacto ni aplicar nuevos estados; esperar regeneración y confirmar que reanudan fuego. Ballista, Mortar y Shredder no deben gastar maná.
7. Usar `8`, `9` y `0` para comprobar que los fixtures M7/M8 siguen seleccionables sin aparecer como parte de las siete torres finales.

M9.5 queda aceptado cuando pasan todos los criterios y se observa cada perfil en la ventana del juego. La implementación está en código; la revisión visual/interactiva todavía está pendiente. Registrar cualquier ajuste de balance como provisional.

## Loop
- Al terminar oleada se entra en expansión.
- No empieza siguiente ronda hasta colocar pieza válida.
- Ronda incrementa una sola vez.
- Ronda 20 completada -> victoria.

## Meta
- Derrota -> moneda meta.
- Compra persiste tras reiniciar.
- Torre desbloqueada aparece en siguiente run.
- Save corrupto/versión desconocida falla de forma segura.

## Scope
- No existe support building.
- Mana no depende de support building.
