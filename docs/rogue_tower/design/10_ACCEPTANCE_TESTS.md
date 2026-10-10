# Acceptance Tests

## Grid
- Rotar un HexCoord 6 veces devuelve la posición original.
- Cada celda tiene exactamente 6 vecinos potenciales.
- Distancia A->B == B->A.

## TerrainPiece
- Toda plantilla cargada contiene 7 celdas únicas, conectadas, con pivote `(0,0)`.
- Se cargan las cinco plantillas originales M3 (`straight`, `gentle_turn`, `hard_turn`, `fork`, `convergence`) y las diez piezas añadidas en M18; el catálogo suma 15 piezas.
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
- El snapshot activo se reconstruye al iniciar y confirmar. Al mover un ghost legal, se deriva un snapshot candidato independiente para actualizar en vivo la vista previa de spawns; no muta ni sustituye el snapshot activo hasta confirmar.
- No se confirma una pieza que dejaría un endpoint o subred PATH sin ruta a base.
- Cada endpoint spawn alcanzable muestra siempre un portal PNG pulsante en su coordenada exterior, sin texto `SPAWN`; debe coincidir con los lugares de aparición de enemigos.
- `Ctrl+D` alterna el overlay con rutas por spawn y marcador de base; los portales y el flujo de flechas permanecen visibles con el overlay apagado.
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
- La base inicializa Health desde `BaseData`, recibe daño y emite derrota al llegar a 0.
- Enemy acepta `EnemyData` y `PathRoute`, comienza fuera del endpoint y recorre los centros axiales hasta base.
- La muerte de un enemigo detiene su movimiento y lo retira una sola vez.
- La primera oleada genera todos los enemigos configurados y solo termina tras completar los spawns y quedar cero enemigos vivos.
- Cada llegada daña la base por `EnemyData.base_damage`; el HUD refleja Health y enemigos en ruta.
- Durante `COMBAT` no se puede colocar terreno; derrota bloquea la expansión y victoria de la muestra habilita `TERRAIN_EXPANSION`.
- Smoke M5: la oleada provisional de tres enemigos termina con base en 20/50 HP, cero enemigos activos, y se cubren las rutas, la muerte de enemigo y la derrota de base.
- Enemy llega a base y causa daño.
- Tower adquiere target y lo daña.
- Armor/health/regen alteran el resultado.
- Status expira correctamente.
- Matar enemigo entrega recompensa una vez.

## M6 Towers

> Se conserva este procedimiento como registro del prototipo `Basic Bolt`. El perfil ahora se llama `Basic Bolt (DEBUG)` y el roster visible vigente está en M9.5; estos pasos ya no son la aceptación manual actual de la interfaz. Sigue las pruebas M9.5/M12A/M13 para comprobar las torres y el HUD activos.

- `Basic Bolt` carga desde `TowerData`; ID, daño, cadencia, alcance, terreno permitido, prioridades y mejoras están configurados en Resource.
- Build mode se inicia en `ROUND_PREP`, `COMBAT` y `TERRAIN_EXPANSION`, y no en `RUN_SETUP` ni `RUN_DEFEAT`.
- Una torre se coloca en una celda `GRASS` o `MOUNTAIN` construible y libre; PATH, una celda vacía del mapa, terreno no permitido y una celda ocupada se rechazan con explicación en HUD.
- Confirmar construcción marca `HexCell.occupied` y `tower_id`, crea una sola torre en la escena y la selecciona; no cambia el `PathGraph`.
- El preview de construcción aparece en la casilla bajo el cursor: verde si es legal, rojo si no, con el alcance provisional. Al seleccionar una torre, su marcador de alcance coincide con sus estadísticas actuales.
- La UI selecciona cada prioridad: más avanzado, menos avanzado, más Health actual y más Armor. Los empates conservan orden estable por ID de instancia.
- Una torre solo adquiere y ataca enemigos `MOVING` dentro de su alcance durante `COMBAT`; mantiene la cadencia configurada y el daño reduce la Health del objetivo. Fuera de alcance o fuera de combate no ataca.
- La elevación suma el bonus de alcance configurable de TowerData. La elevación no modifica la coordenada ni la ocupación lógica de la torre.
- Mejorar aumenta los stats configurados hasta `max_level`; una mejora posterior se bloquea. En el alcance histórico M6 las mejoras eran gratuitas; el flujo vigente con coste se verifica en la sección M9.
- El placeholder muestra la torre en `Entities` Y-sorted, orientación hacia el objetivo y un flash de ataque; el anillo de alcance se ve al seleccionar.
- El `armor` de `EnemyData` permite ordenar por highest armor. La mitigación plana de M7 es histórica y fue sustituida por las capas consumibles de M12A.
- Smoke M6: `tests/m6_tower_smoke.tscn` comprueba fases, Grass/Mountain, rechazo de PATH/ocupado, ocupación axial, niveles/alcance, elevación, las cuatro prioridades, filtro de rango, cooldown/cadencia, daño hitscan y descarte seguro de una referencia a enemigo eliminado.

### Prueba manual de M6 en el juego
1. Ejecutar `game/main/main.tscn`; en `ROUND_PREP` pulsar el botón **1 · BOLT** o la tecla `1` para entrar en modo de construcción.
2. Pasar el cursor por el camino `(0,0)`: el HUD debe explicar que solo vale Grass o Mountain y el preview debe marcarlo rojo. Hacer clic no debe ocupar esa casilla.
3. Pasar el cursor por Grass `(1,-1)`: el preview debe ser verde y mostrar el anillo de alcance. Hacer clic; debe aparecer una torre seleccionada y el resumen compacto de nivel/daño/alcance. Intentar construir otra en el mismo hex debe ser rechazado.
4. Elegir prioridades distintas en el selector; la prioridad elegida debe aplicarse a la torre. Usar **Mejorar** dos veces: nivel 3/3, daño 20 y alcance mayor que en nivel 1; el botón queda deshabilitado al máximo.
5. Iniciar la oleada seleccionada. Enemigos dentro del radio deben perder Health al ritmo de la cadencia, la torre debe girar hacia un objetivo y mostrar el flash de ataque. La oleada termina cuando el director no tiene enemigos activos; no se deben crear recompensas ni cobrarse costes todavía.
6. (Opcional) Repetir la colocación en Mountain `(0,1)`: debe aceptar la casilla y el estado/preview debe reflejar su bonus provisional de elevación.

Para dar M6 por aceptado deben pasar todos los bullets de la sección y la prueba manual debe confirmar el feedback visual e interacción. El smoke prueba reglas deterministas; la prueba manual cubre el render y el input de la escena.

## M7 Damage model (contrato histórico, sustituido por M12A)

Los criterios y daños calculados de esta sección registran la fórmula plana que existía al cerrar M7. No describen el combate actual: para verificar Health/Armor/Shield y el daño vigente, usa la prueba manual M12A.
- Cada torre configurada crea un `DamagePacket` con ID de origen, tags, multiplicadores y counter definidos por `TowerData`; las torres no aplican fórmulas propias.
- Todos los impactos de torre pasan por el `DamageService` de `Main`; no es Autoload ni comparte la instancia mutable de `TowerData`.
- La mitigación sigue una fórmula única: `armadura_absorbida = min(daño_bruto, Armor × armor_multiplier)` y `daño_HP = floor(max(daño_bruto - armadura_absorbida, 0) × multiplicador_de_tags × health_multiplier)`, limitado a la Health restante.
- Los tags Físico/Fuego/Arcano/Poison se validan como bitmask; cada enemigo declara sus multiplicadores recibidos y los tags combinados multiplican sus resultados.
- La regeneración por segundo acumula fracciones, no supera la Health máxima y solo corre mientras el enemigo sigue vivo. El counter reduce la regen según su fuerza durante la duración configurada; varios impactos usan la mayor fuerza y el máximo tiempo restante.
- `DamageService.preview_damage()` y `apply_damage()` usan el mismo cálculo; el servicio emite un resultado con Armor absorbida, multiplicador de tipo, HP aplicado y objetivo derrotado.
- El inspector técnico disponible con `F3` muestra HP, Armor, regen base/efectiva y daño estimado del objetivo de la torre seleccionada; el resumen de torre conserva sus stats de perfil en el HUD habitual.
- Se pueden seleccionar Ballista (6 HP al fixture), Armor Piercing Bolt (9 HP) y Sapping Bolt (7 HP y 100% de contrarregeneración durante 1.25 s) contra el blindado de Armor 4, regen 2 HP/s y multiplicador arcano 1.25. Estos valores son placeholders.
- Status y sus payloads no se aplicaban en M7; M8/M9 añadieron estados y recompensas en hitos posteriores.

### Prueba manual de M7 en el juego
1. Ejecutar `game/main/main.tscn`. La interfaz habitual debe mostrar base, economía de run, estado de oleada, resumen de torre y acciones disponibles. La cabecera mantiene **F3 - Terreno   H - Interfaz**; el selector de perfiles y la inspección técnica de objetivo se ven al abrir F3, y `H` oculta/muestra el HUD completo.
2. Abrir F3 y elegir **DEBUG · Armored Regenerator**. Construir una torre próxima al camino usando `1` (Ballista), `8` (Armor Piercing Bolt) o `9` (Sapping Bolt); las tres opciones deben estar disponibles. Hacer clic en una casilla libre de Grass/Mountain.
3. Iniciar la oleada seleccionada. Seleccionar la torre si hace falta. Cuando el enemigo entre en alcance, el panel técnico F3 debe mostrar Health actual/máxima, Armor, regeneración y daño estimado; el tooltip del resumen de torre debe informar ese objetivo. Si el counter está activo también debe mostrar la regen efectiva reducida.
4. Repetir con cada perfil: Ballista estima 6 HP; Armor Piercing Bolt estima 9 HP porque solo aplica 1 punto de Armor; Sapping Bolt estima 7 HP por vulnerabilidad arcana y, tras impactar, reduce la regen a 0 HP/s durante hasta 1.25 s.
5. Una prueba `DEBUG` debe volver a la misma fase de campaña sin cambiar ronda, Gold ni Health de base. Cambiar a **Ronda 01/45 · Standard · 1 enemigo**, completarla y comprobar que abre expansión; desde expansión se puede volver a seleccionar un diagnóstico y, al terminar, continuar la colocación pendiente. No deben quedar enemigos de la prueba anterior. La ronda real no se puede repetir ni saltar.
6. Con Ballista, observar el HP del blindado entre impactos: la Health perdida debe recuperarse a ritmo de 2 HP/s mientras no haya counter activo, hasta el máximo 60. Con Sapping Bolt, no debe subir durante la contrarregeneración activa.

Para cerrar M7 deben pasar todos los criterios anteriores y la prueba manual debe confirmar que el HUD refleja los valores reales durante combate, que los atajos 1, 8 y 9 funcionan incluso tras usar controles de interfaz y que se pueden iniciar oleadas distintas repetidamente. También se debe revisar que el HUD compacto y el panel F3 caben en la ventana de 1440×900. Los perfiles y cifras no se convierten en balance confirmado.

## M8 Status Effects
- Cada `StatusEffectData` valida ID/nombre, duración, intervalo, regla, límite de stacks, velocidad y perfil DoT; los efectos sin efecto jugable o con tags inválidos se rechazan.
- `TowerData.status_effects` configura los payloads por torre y no admite IDs duplicados en el mismo perfil. El Resource no se modifica al aplicarlo.
- Un impacto válido aplica estados después del daño directo y solo si el objetivo sigue en `MOVING`; si el golpe lo derrota, no recibe estado.
- `REFRESH` conserva una acumulación y reinicia duración; `ADD_STACKS` incrementa hasta `max_stacks` y reinicia duración. Reaplicar conserva la fase del siguiente tick; las diferentes instancias de enemigo mantienen estado independiente.
- Slow cambia realmente la velocidad de `PathFollowerComponent`; los multiplicadores activos se combinan por mínimo y, al expirar/limpiar, la velocidad vuelve a normal.
- Burn/Bleed aplican ticks de daño configurado por `DamageService`, con los tags y mitigación del objetivo. Los ticks no vuelven a aplicar sus propios payloads.
- Al agotarse el tiempo se elimina el estado; muerte o llegada a base limpia todos los estados. El HUD debug enseña el nombre, acumulaciones y tiempo del objetivo de la torre seleccionada; aros del enemigo distinguen Slow, Burn y Bleed.
- La fixture M8 usa un objetivo de 180 HP sin Armor/regen, Status Probe a 0.5 ataques/s, Slow refrescable, Burn hasta 3 stacks y Bleed con 0.5 s de ventana observable entre impactos. Es contenido provisional.
- No hay resistencia de estado en M8: no está definida por el diseño fuente.

### Prueba manual de M8 en el juego
1. Ejecutar `game/main/main.tscn`, abrir el panel F3 y en el selector de oleada elegir **DEBUG · Status Training Target**. Pulsar `0` y colocar **Status Probe (DEBUG)** en Grass `(1,-1)`, que tiene alcance a lo largo de la ruta inicial.
2. Iniciar la oleada seleccionada. La línea de diagnóstico debe identificar **Objetivo de estados (M8 prueba)** y mostrar sus HP, impacto estimado y estados activos. El enemigo debe llevar aros celeste (Lento), naranja (Quemadura) y rojo/rosa (Sangrado).
3. Observar al menos tres impactos: Lento debe mantenerse en una sola acumulación y su duración debe refrescarse; Quemadura debe mostrar `×2` y luego `×3`, sin superar el máximo configurado aunque haya impactos posteriores. El objetivo debe avanzar más despacio mientras Lento esté activo.
4. Sangrado debe hacer bajar HP mediante ticks. Como dura 1.5 s y la torre ataca cada 2 s, su nombre/aro debe desaparecer durante el intervalo entre impactos y volver con el siguiente. Quemadura también debe reducir HP por ticks. Esta comparación comprueba expiración y aplicación del daño por el pipeline común.
5. El objetivo de entrenamiento debe sobrevivir el tiempo suficiente para observar los efectos y finalmente llegar al final de su ruta; al terminar, sus efectos y aros desaparecen. El HUD deja de mostrar un objetivo cuando ya no hay uno vivo en alcance. La prueba termina con cero pendientes/vivos y vuelve a la fase previa sin afectar Health de base, Gold ni ronda.
6. Repetir la prueba M8: stacks, timers y ticks comienzan limpios. Elegir después el diagnóstico M7 para confirmar que los atajos `1`, `8` y `9` y sus perfiles conservan el comportamiento anterior.

Para dar M8 por aceptado deben pasar todos los criterios de la sección y la prueba manual debe verificar velocidad real, refresh, límite de stacks, daño periódico, expiración antes de la llegada, limpieza al finalizar la ruta, HUD y aros. Registrar cualquier ajuste de valores de fixture como provisional; la prueba no convierte Bleed ni estos números en diseño final.

## M9 Economy + Mana
- `Main` configura `RunEconomyService` desde `RunEconomyData`; el perfil de prueba inicia con 150 Gold, 100/100 Mana y regen interna de 1.5/s. El tooltip del Mana y las descripciones de mejoras expresan tasas y modificadores como equivalencias con cantidades e intervalos enteros, sin decimales ni redondear el valor runtime.
- El Gold de construcción es runtime de esta run y no altera `MetaProgression.meta_currency` ni se persiste como moneda meta.
- Los siete perfiles principales y sus costes aparecen en la barra según sus Resources: Ballista 10, Mortar 200, Tesla Coil 200, Frost Keep 250, Flame Thrower 300, Poison Sprayer 300 y Shredder 500 Gold, antes de incrementos por cantidad y mejoras de run. Los atajos `8`, `9` y `0` mantienen Armor Piercing Bolt/Sapping Bolt/Status Probe a 40 Gold; Sapping Bolt indica 4 Mana por ataque.
- Una construcción legal cobra una sola vez antes de ocupar la celda. Terreno inválido, casilla ocupada o saldo insuficiente no cobran ni crean torre/ocupación.
- Una mejora cobra `TowerData.get_upgrade_cost(nivel_actual)`: en los fixtures M9, nivel 1→2 cuesta 20 Gold y nivel 2→3 cuesta 35. El nivel/stats aumentan una sola vez; tope o fondos insuficientes dejan nivel y saldo intactos.
- Cada enemigo derrotado paga una sola vez el `EnemyData.kill_reward`, también si la muerte procede de DoT. Un enemigo que llega a base no paga recompensa de baja. Repetir callbacks no duplica el pago.
- La recompensa de `WaveData.round_reward` solo se paga una vez cuando acabaron los spawns y no queda enemigo activo. Si una baja ya pagó y luego la oleada falla, esa recompensa por baja se conserva, pero no se concede el bonus de limpieza.
- Una torre con `mana_cost_per_attack` descuenta Mana antes de cada impacto; con saldo insuficiente no ejecuta daño/status, no genera saldo negativo y muestra estado sin Mana en el debug de la torre seleccionada. Una torre sin coste de Mana no consulta ni consume el saldo.
- El Mana regenera en preparación, combate, recompensa y expansión; no supera `maximum_mana` y se detiene en setup/derrota/victoria. No existe una fuente de Mana de Support Building.
- Al terminar una ronda de campaña, `RunManager` entra a `ROUND_REWARD` durante 0.8 s: no se puede iniciar otra oleada, comprar ni colocar terreno. Después pasa a `TERRAIN_EXPANSION` y ofrece tres piezas; construcción se habilita al elegir una, y la siguiente ronda solo se desbloquea al confirmar una pieza válida.
- Los costes, recompensas y tasas actuales son fixtures configurables y provisionales, no balance confirmado.

### Prueba manual de M9 en el juego
1. Ejecutar `game/main/main.tscn`. El HUD debe mostrar **Gold 150 · Mana 100 / 100**. Al pasar el cursor por el Mana, el tooltip debe indicar **3 Mana cada 2 s**. La barra inferior debe indicar los costes de los siete atajos `1–7`.
2. Pulsar `1` y colocar Ballista en una casilla Grass libre. El Gold pasa a 140, la celda queda ocupada y aparece una sola torre. Seleccionarla y mejorarla: el saldo pasa a 120 al llegar a nivel 2 y a 85 al llegar a nivel 3; los stats cambian según el nivel y el botón deja de ofrecer otra mejora. Repetir clic sobre la torre o un terreno no construible no debe cobrar.
3. Iniciar **Ronda 01/45 · Standard · 1 enemigo**. El Goblin paga +4 Gold por su baja, una sola vez, y al terminar el spawn con cero enemigos activos se suman +20 de limpieza. Si muere, desde los 85 restantes debe terminar en 109. El aviso de recompensa y el saldo tienen que coincidir.
4. Reiniciar la escena para disponer otra vez del perfil inicial. Construir tres Sapping Bolts M7 en celdas construibles próximas al camino (por ejemplo `(1,-1)`, `(1,0)` y `(0,1)`); deben costar 40 cada una usando la tecla `9`. Con los 30 Gold restantes, intentar construir la Status Probe (DEBUG) de 40 (tecla `0`): el preview/HUD explica que faltan fondos, el atajo se deshabilita y el Gold se conserva en 30. Pulsar `Esc` para salir del preview rechazado antes de cambiar la oleada.
5. Abrir F3, elegir **DEBUG · Status Training Target** e iniciar la prueba. Con tres Sapping Bolts, el saldo de Mana debe bajar en pasos de 4 por disparo mientras hay objetivo. Al llegar a cero, la torre seleccionada muestra **sin Mana** y deja de disparar; su ataque no reduce HP ni aplica nuevos estados y el Mana no queda negativo. Este diagnóstico no puede dañar la base ni pagar recompensas.
6. Completar la ronda real actual para observar el Mana en `TERRAIN_EXPANSION`: debe regenerarse a la tasa base (equivalente a 3 Mana cada 2 s) hasta 100 y nunca superar ese máximo. Los diagnósticos M7/M8 no pagan bonus; una ronda de campaña limpia paga su `round_reward` una vez.
7. Durante el instante posterior a una victoria, comprobar que aparece `ROUND_REWARD`; el botón de oleada/selector y la colocación permanecen bloqueados esos 0.8 s, y luego se habilitan al entrar en expansión.
8. (Opcional, comprueba fallo de campaña) No construir torres durante las rondas reales y dejar que la base llegue a cero. Debe entrar `RUN_DEFEAT`; la ronda fallida no paga bonus de limpieza, aunque se conservan bajas ya recompensadas. Las pruebas DEBUG no dañan la base ni pueden forzar esta derrota.

Para dar M9 por aceptado deben pasar todos los criterios de la sección y la prueba manual debe confirmar saldos y mensajes en pantalla, cobros atómicos, pago único por evento, rechazo sin fondos, bloqueo de disparos sin Mana y regeneración acotada. La prueba debe incluir una llegada a base para verificar que no se confunde con una baja; el bonus de ronda se comprueba aparte. El smoke/validación automática de gameplay queda pendiente; la prueba descrita es interactiva.

## Roster jugable M9.5
- La barra principal muestra los siete perfiles en orden. Los valores iniciales de coste/ataque/H/A/S se validan ahora en M12A; M9.5 conserva el requisito de acceso por botón/tecla y terreno legal, pero los precios históricos 30/80/70/50/65/65/100 ya no aplican.
- Los atajos `1–7` seleccionan el mismo perfil que el botón y permiten construir solo en Grass/Mountain libre. PATH, terreno ocupado o saldo insuficiente no cobran ni crean torre. Cada una de las siete formas placeholder debe distinguirse en el mapa.
- Ballista solo daña el objetivo elegido. Mortar lanza un proyectil y afecta a enemigos agrupados dentro de su radio al aterrizar; Frost también afecta en área y refresca Slow.
- Tesla descarga sobre todos los enemigos válidos dentro del alcance circular, gasta 5 Mana por ataque y no daña/aplica estado si el saldo no alcanza.
- Flame daña a los enemigos del cono frontal y aplica Burn; Poison hace lo mismo con su tag Poison y aplica el estado Poison. El aro verde Poison aparece y los ticks pasan por `DamageService` y `EnemyData.poison_damage_multiplier`.
- Shredder lanza la hoja desde la torre hasta la posición actual del objetivo, luego avanza por sus waypoints restantes hacia la base. Cada enemigo en el recorrido recibe un impacto como máximo; cada impacto posterior pierde 1 de daño base. Cada contacto hace daño directo y añade Bleed por el 100% del daño base restante de la hoja; prueba la interacción con H/A/S en el fixture M12A.
- Las torres con Mana gastan el coste indicado por disparo; al quedar sin saldo esperan y vuelven a atacar al regenerar. Las torres sin coste no lo consumen.
- Los perfiles M7/M8 de diagnóstico siguen disponibles en `8` (Armor Piercing Bolt), `9` (Sapping Bolt) y `0` (Status Probe); no ocupan botones del roster principal.
- Daño, costes, RPM, radios, cono, multiplicadores y efectos restantes son configurables. Las cifras compartidas se validan en M12A; la capa Shield ya forma parte del modelo.

### Prueba manual M9.5 en el juego
1. Abrir `game/main/main.tscn`. Confirmar los siete botones y probar los atajos `1–7`; el perfil elegido y su nombre deben coincidir. En el tooltip revisar rol, coste, patrón y coste de Mana.
2. Reiniciar la escena entre perfiles para recuperar el Gold inicial. Construir cada torre cerca del camino y verificar el coste que muestre el botón, el color y la silueta. La tabla de costes ya no es la antigua configuración M9.
3. Ejecutar **Ronda 01/45 · Standard · 1 enemigo** para observar los ataques contra un objetivo. Ballista debe seguirlo; Mortar debe mostrar su impacto; Tesla debe alcanzarlo dentro de su alcance circular; Frost debe ralentizarlo con el valor actual. Para confirmar impactos de área y cadenas sobre varios objetivos, usar la Ronda 07 (22 enemigos directos) o una oleada DEBUG con varios objetivos.
4. Probar Flame y Poison sobre enemigos alineados delante de la torre. El cono solo aplica estado a enemigos dentro del ángulo y rango; verificar aros Burn naranja y Poison verde, y que el HP cae por ticks equivalentes al 100% del daño base por aplicación. En Poison, el diagnóstico debe identificar `veneno`, no `arcano`.
5. Reiniciar, abrir F3, seleccionar **DEBUG · Status Training Target** y construir Shredder (`7`) a rango del objetivo. Iniciar la oleada: la hoja debe llegar a la posición del objetivo y seguir sus waypoints restantes. Al contactar, debe aplicar daño directo y Bleed equivalente al 100% del daño base restante de la hoja. Para comprobar perforación, usar la ronda 07/45 (22 enemigos directos) con varios enemigos vivos en el mismo trazado; cada enemigo debe recibir un impacto y Bleed, el segundo con 1 menos de daño base. En M12A se desglosa cada componente usando HP por capas.
6. Dejar que las torres Tesla/Frost/Flame/Poison gasten su Mana. Cuando falte, confirmar que se bloquean sin infligir impacto ni aplicar nuevos estados; esperar regeneración y confirmar que reanudan fuego. Ballista, Mortar y Shredder no deben gastar Mana.
7. Usar `8`, `9` y `0` para comprobar que los fixtures M7/M8 siguen seleccionables sin aparecer como parte de las siete torres finales.

M9.5 queda aceptado cuando pasan todos los criterios y se observa cada perfil en la ventana del juego. La implementación está en código; la revisión visual/interactiva todavía está pendiente. Registrar cualquier ajuste de balance como provisional.

## M10 Campaña de 45 rondas

- Una run normal comienza en Ronda 01/45. El selector habilita solo la ronda actual, y limpiar la 45 produce RUN_VICTORY con 45/45.
- WaveCampaignData valida las 45 entradas consecutivas y exactamente 1.093 enemigos directos. Contrastar cada grupo y su orden con 14_CAMPANA_45_RONDAS.md; cada WaveData debe contener los mismos tipos y cantidades.
- WaveEnemyGroupData.count cuenta unidades directas. Con una y varias salidas alcanzables, los enemigos se asignan round-robin y el total por grupo no cambia. Los spawns pendientes y enemigos activos se muestran por separado.
- La oleada solo se limpia si acabaron todos los grupos y no quedan enemigos vivos. Las invocaciones cuentan como adicionales; no se incluyen en el total 1.093. Transformar un enemigo mantiene la instancia, no paga una baja intermedia y no reduce el contador; la recompensa final se paga una vez tras derrotar la forma final.
- La expansión de terreno aparece tras las rondas 1–44, nunca tras la ronda 45. Mantiene la oferta de tres piezas, preview del grafo, colocación conectada y cierre de huecos interiores. Si la ronda está configurada para una carta M11, el orden es expansión, carta y preparación de la siguiente ronda.
- Las rondas 17 y 19 muestran el encuentro `Boss` por la presencia de Ooogie. Cyclops y Werewolf no tienen designación especial de Miniboss y conservan sus perfiles normales cuando aparecen en la tabla.
- Ooogie von Ooogovich (Haunted) invoca dos Bats cada 2 s y, al agotarse Health, reaparece como Bat con 2.500 Health. Mantiene la recompensa asociada a la instancia hasta derrotar la fase final.
- Comprobar las habilidades de EnemyAbilityData activadas por aparición, cerca de base, agotamiento de Armor/Shield, muerte y temporizador. Las reglas de radio son 5 hexágonos desde la base y 2 hexágonos para auras. Haste aumenta velocidad según fuerza, Fortification reduce 5 del daño base recibido por golpe, ambas alcanzan 60 puntos y decaen 6 puntos/s. Revisar también teletransporte, invocaciones y transformaciones de los perfiles que los declaran en 13_CONTENT_ROSTER.md.
- Confirmar que todos los 26 perfiles de campaña tienen PNG transparente visible. Sus sprites miran a la derecha cuando el recorrido avanza hacia la derecha y quedan reflejados horizontalmente al navegar a la izquierda.
- Confirmar el balance propio solicitado: Frost Keep inicia con daño 2, 120 RPM y Slow ×0,85 durante 1 s; Tesla Coil inicia con daño 9. El escalado por cobertura PATH y las mejoras de carta pueden cambiar el resultado runtime; los Resources compartidos no deben mutarse.
- Los fixtures DEBUG pueden repetirse sin mover el contador de campaña, aplicar daño a base o conceder recompensas de campaña.
- Verificar victoria al limpiar ronda 45; después se deshabilitan inicio, selector, construcción/mejora y colocación. Las recompensas de limpieza de las rondas 21–45 son provisionales según ADR-0037.

### Prueba manual M10 en el juego

1. Iniciar una run nueva y confirmar Ronda 01/45, el tablero inicial de 19 celdas y ruta válida de cuatro celdas PATH desde spawn hasta base. Mantener la inspección previa de orientación, terreno y preview.
2. En cada oleada muestreada, comparar los grupos visibles/activos con la tabla de la ronda. Verificar que dos o más endpoints no multipliquen la cantidad anunciada y que la distribución alterne rutas.
3. En una oleada con grupos espaciados, comprobar que pendientes llega a cero antes de que la ronda termine si aún hay enemigos vivos. Probar también muerte/llegada a base mientras quedan grupos pendientes.
4. Completar varias rondas y expansiones, incluyendo una ronda con oferta M11. Verificar bloqueo de acciones entre fases y orden expansión→carta→siguiente ronda.
5. En la ronda 24, observar el jefe Ooogie von Ooogovich, las invocaciones, la transición a Bat y la espera del contador/recompensa hasta la derrota final.
6. Inspeccionar al menos un enemigo que mira a cada lado del eje horizontal. El sprite debe voltearse solo al moverse hacia la izquierda y volver a su orientación original hacia la derecha.
7. Abrir el inspector técnico y seleccionar Frost Keep y Tesla Coil. Comparar daño, RPM, Slow y duración con el perfil documentado; comprobar que sus modificadores runtime se reflejan sin cambiar los Resources.
8. Repetir una prueba de expansión y un fixture DEBUG desde preparación/expansión. El estado actual de oferta y campaña debe conservarse al volver.
9. Completar la ronda 45 y confirmar 45/45, RUN_VICTORY, una sola recompensa de limpieza, sin expansión posterior y sin acciones de combate/construcción disponibles.

La implementación de campaña, recursos, perfiles, habilidades y sprites está integrada. El arranque headless se comprobó en esta revisión; la aceptación completa de gameplay/arte requiere completar los pasos interactivos anteriores en la ventana del juego.


## M11 Cartas de mejora
- Después de colocar una expansión de las rondas 1 y 2, la fase pasa directamente a `ROUND_PREP`; no aparece una carta de mejora fuera del calendario.
- Después de colocar la expansión de las rondas 3, 6, 9, 12, 15 o 18, `RunManager` entra a `CARD_OFFER` antes de `ROUND_PREP`. La oferta muestra exactamente tres cartas distintas con título, rareza y efecto descrito. No duplica opciones dentro de una misma oferta.
- Hasta elegir una carta se mantienen bloqueados inicio de ronda, construcción, mejora y colocación. `Esc`/clic derecho no descartan ni saltan la elección. Tras seleccionar una, se aplican sus efectos y se habilita una sola vez la siguiente ronda.
- Las definiciones viven en Resources. Seleccionar una carta no cambia ningún `TowerData`, `StatusEffectData`, economía de arranque ni archivo `.tres` compartido. Las cartas específicas de torre requieren el ID desbloqueado correspondiente; las cartas globales no requieren unlock.
- Daño plano/multiplicador, alcance, radio de área, coste de Mana, duración de estado, capacidad/regeneración de Mana, crítico y multiplicadores H/A/S afectan el gameplay y la lectura de stats/preview que corresponda. Se aplican también a torres construidas antes de elegir la carta. Las cartas no alteran el RPM fijo; Frost Keep solo gana RPM por cobertura PATH.
- Las ofertas futuras excluyen cartas que llegaron a `max_per_run`; las no elegidas siguen disponibles. Una escena/run nueva reinicia las selecciones. Los efectos no persisten entre runs (la persistencia y unlocks guardados son M12).
- Los números y el calendario de oferta son provisionales y centralizados en `.tres`; no se derivan del balance comunitario de Rogue Tower.

### Prueba manual M11 en el juego
1. Ejecutar `game/main/main.tscn` y jugar la campaña normal. Limpiar y expandir las rondas 1 y 2: tras cada colocación debe comenzar la preparación siguiente sin aparecer panel de mejoras.
2. Antes de completar la ronda 3, construir Ballista en Grass y anotar el daño mostrado en su resumen. Completar la ronda y colocar una pieza de terreno válida. Ahora, antes de que se habilite ronda 4, debe aparecer la fase `CARD_OFFER` con tres cartas. Verificar títulos, descripciones/efectos, rarezas y que los tres botones sean clicables; comprobar que no se puede iniciar la oleada ni construir mientras está abierta. `Esc` no debe saltarse la elección.
3. Si aparece **Disparo calibrado**, seleccionarlo: la expansión ya está colocada, el panel desaparece y se habilita la ronda 4; al seleccionar la Ballista ya construida, su resumen debe mostrar 2 de daño adicional. Si no aparece esa carta, repetir la run; no hace falta editar recursos.
4. En runs sucesivas, elegir **Depósito de Mana** y comprobar que la capacidad HUD sube 20 sin llenar instantáneamente el saldo; **Flujo constante** aumenta la regeneración 0,5/s; **Circuitos eficientes** reduce el coste por ataque en un 15 %. Para una mejora de estado, seleccionar la carta del estado/torre correspondiente y usar el fixture M8 para comprobar su mayor duración. Alcance y área deben reflejar el stat correspondiente en preview/resumen y comportamiento de ataque. Comprobar en otras ofertas las tres cartas de multiplicador H/A/S descritas abajo.
5. Alcanzar la siguiente oferta (ronda 6). La carta elegida antes no puede aparecer de nuevo con el máximo actual de una copia; las opciones no elegidas sí pueden volver a aparecer. Cerrar y abrir una run nueva debe quitar los efectos y reiniciar el límite por run.

M11 queda aceptado cuando se verifican la frecuencia provisional y el orden expansión→carta→siguiente ronda, bloqueo hasta selección, tres opciones válidas, filtro de unlocks/límites por run y al menos un efecto verificable de cada familia afectada (incluido un multiplicador H/A/S), sin mutar recursos compartidos. El gameplay y la UI todavía requieren esta aceptación manual; no se ha ejecutado Godot en la revisión de implementación.

## M12 Meta-progresión
- Una nueva instalación crea `user://rogue_tower_meta.json` con versión 1, 0 de moneda y Ballista desbloqueada. La moneda meta nunca cambia al construir torres ni se confunde con el Gold de la run.
- Una derrota de campaña y la victoria al limpiar ronda 45 terminan la run, otorgan meta-moneda una sola vez y muestran el resumen con resultado, ronda, recompensa, saldo total y seed. Los fixtures DEBUG no finalizan ni recompensan una run.
- Con la configuración demo, la recompensa es `5 + 5 × rondas completas`, más 30 por victoria, con tope 1000: perder en la ronda 1 da 5; perder durante la ronda 2 tras completar la 1 da 10; completar las 45 rondas da 260. Progresar más da una recompensa superior que repetir únicamente una derrota en la primera ronda.
- La tienda deja comprar torres y niveles permanentes solo con saldo suficiente. El coste se resta una sola vez; un elemento ya desbloqueado/nivel máximo no se vuelve a cobrar. Si falla el guardado, la compra se revierte.
- Tras comprar una torre, «Empezar nueva run» inicia una run sin cartas/efectos temporales anteriores, mantiene el unlock, muestra la torre en la barra y habilita sus cartas específicas M11. Las torres bloqueadas no aparecen en la barra y `BuildController` rechaza su construcción aunque se invoque desde otro acceso.
- Comprueba al menos una mejora de cada familia persistente: «Fondo de campaña» da +20 Gold inicial por nivel; «Reserva de Mana» +15 de capacidad por nivel; «Manantial» +0,25 Mana/s por nivel; «Calibración de torres» multiplica daño ×1,05 por nivel. Deben aplicarse a una run nueva, sin mutar `.tres` ni sobrevivir los modificadores M11 de la run anterior.
- Comprar «Archivo de cartas» añade al pool dos cartas globales identificadas por `meta:card_archive`; sin la compra no aparecen, y la compra debe persistir tras cerrar y volver a abrir el juego.
- `SaveData` contiene solo primitivas, versión y progreso estable. Un archivo corrupto o con versión distinta no se sobrescribe automáticamente; se muestra el error y se deshabilitan compras, conservando el archivo para recuperación. Los guardados normales conservan una copia `.bak` antes de reemplazarse.

### Prueba manual M12 en el juego
1. Ejecuta `game/main/main.tscn` con un guardado nuevo. Comprueba que la barra ofrece Ballista como único perfil de demo y que el HUD muestra Gold/Mana de run, separados de cualquier meta-moneda.
2. Para comprobar el mínimo de 5 en derrota de ronda 1, reduce temporalmente `max_health` a 20 en `data/base/base_data.tres` en una copia de trabajo. La ronda inicial tiene tres enemigos de 10 de daño a base; déjalos pasar y confirma que el resumen indica derrota `1/20`, `+5 moneda meta`, saldo total 5 y seed. Restaura `max_health = 50` al terminar esta comprobación. Si no quieres tocar el fixture, la primera derrota natural será probablemente durante ronda 2 y deberá pagar 10.
3. Con el fixture restaurado, inicia una nueva run y deja pasar la ronda 1 completa; después deja caer la base durante la ronda 2. El resumen debe otorgar 10 (5 base + 5 por una ronda completa), dejando 15 en total. Esto confirma que progresar paga más que una derrota temprana.
4. Con esos 15, compra Mortar en la tienda y pulsa «Empezar nueva run». Mortar debe aparecer en la barra, permitir construcción y habilitar su carta específica; la moneda meta debe conservar el coste descontado aunque cierres y vuelvas a abrir el juego. Comprueba que las demás torres aún bloqueadas no aparecen.
5. Compra un nivel de «Fondo de campaña» y una mejora de cada una de las familias mana/daño cuando haya saldo. En la run siguiente compara el Gold inicial, capacidad, regeneración y daño esperado de Ballista con el valor base de `data/run/run_economy_m9.tres`/`data/towers/ballista.tres`: solo el runtime debe cambiar. Comprar «Archivo de cartas» habilita «Filos bruñidos» y «Canalización» en una futura oferta de ronda 3; sin comprarlo siguen filtradas.
6. Verifica saldo insuficiente y máximos: la tienda no cobra, no aumenta niveles ni desbloquea contenido. Abre F3 para iniciar una run de diagnóstico y confirma que completarla no aumenta el contador/recompensa meta ni altera el número de campaña.
7. Para probar migración, conserva una copia externa del JSON y, en una copia de trabajo, cambia solo `version` a `0` o elimínalo. El juego debe cargar los campos reconocidos, reescribir versión 1 y conservar el formato anterior en `.bak`; un valor JSON como `1.0` también debe cargar sin bloqueo. Como ruta de error, prueba JSON inválido o `version: 999`: el juego debe iniciar en fallback sin sobrescribir el archivo incompatible, mostrar la explicación y bloquear compras hasta recuperar un guardado válido.
8. Completa la ronda 45 en una run de aceptación: el resultado es victoria, el bonus se aplica una sola vez y la recompensa configurada es 135. Volver a pulsar o duplicar el evento de final no vuelve a sumarla.

M12 queda aceptado al comprobar las dos salidas de run, fórmula creciente, aislamiento DEBUG, compras transaccionales, unlocks consumidos por gameplay/cartas, upgrades efectivos en runs posteriores y persistencia/error seguro después de reiniciar. La jerarquía visual de interfaz se valida por separado en M13. Costes/valores siguen siendo provisionales.

## M12A Reglas de torres y capas de Health

- El modelo de cada enemigo contiene Health, Armor y Shield; el perfil configura los tres máximos y cero desactiva una capa para esa unidad. La oleada `DEBUG · capas Shield/Armor/Health` contiene un objetivo con 40 Shield, 60 Armor y 120 Health, regeneración 1/s por capa y las tres filas visibles. Los valores se consumen Shield→Armor→Health; la barra conserva los colores Shield azul, Armor beige, Health verde y actualiza sus segmentos al recibir daño/curación.
- El perfil Ballista inicial muestra 10 de daño, H/A/S 10/5/5, rango 5, 20 RPM, sin Mana y precio 10. Comparar los otros seis Resources contra la tabla de `11_INITIAL_CONTENT_PLACEHOLDERS.md`: Mortar 20/10-15-5/10/10/200(+75); Tesla 9/6-3-10/2/30/5/ataque/200(+75); Frost 2/10-5-5/2/120 iniciales/2/s/250(+100); Flame 6/6-9-3/4/60/1/ataque/300(+75); Poison 5/6-3-9/4/60/1/ataque/300(+75); Shredder 10/20-10-10/5/5/0/500(+100). Desbloquearlos en tienda meta antes de probarlos. Costes de upgrade provisionales por perfil: Ballista/Mortar 10(+10), Tesla/Frost 20(+20), Flame/Poison/Shredder 30(+30), en línea con las páginas comunitarias consultadas.
- Seleccionar una torre muestra daño, H/A/S, alcance, RPM, crítico, XP H/A/S y Mana. Una elevación de terreno suma +1 al daño base y +0.5 de alcance por nivel. El Frost suma 18 RPM por cada PATH cubierto por el rango cuadrado; los otros perfiles no cambian su RPM.
- El precio de la primera Ballista es 10, segunda 25, tercera 40; demoler una reduce el siguiente coste según el conteo actual. La demolición no devuelve Gold en este prototipo. Intentar comprar o mejorar sin fondos no cobra ni muta la torre.
- Las prioridades se aplican en orden y se revelan con `+`; cada opción secundaria solo desempata la anterior. Repetir una misma opción muestra rechazo/restaura el selector. Validar progreso, menor HP de capa activa, máximo/mínimo H/A/S y velocidad.
- Una mejora manual cobra el coste del siguiente nivel, añade +1 al daño base y +1 a la capa elegida (botones `+ Health`, `+ Armor`, `+ Shield`). El nivel máximo bloquea los tres botones. Para una comprobación rápida de XP, duplicar un `TowerData` local, poner `targeting_xp_required_per_level = 1`, sostener un enemigo en rango y comprobar que gana +1 daño base y +1 a la capa activa; no modificar los Resources versionados del perfil definitivo. Restaurar la copia después.
- Críticos empiezan en 0%. Al conseguir una oferta de carta, `Impulso crítico global` suma 15 puntos porcentuales globales y `Advanced Circuits` 15 a Tesla. `Foco de Health`, `Foco de Armor` y `Foco de Shield` suman +1 al multiplicador de esa capa para todas las torres. El resumen debe reflejar los críticos y los tres modificadores H/A/S. Las tiradas muestran de manera aleatoria ×2/×3/×4 según bandas de chance; si no sale la carta, repetir oferta/run.
- Ballista mueve un proyectil hasta su objetivo. Mortar lanza un shell y al aterrizar daña todo enemigo en el radio, sin depender de estar agrupados al disparar. Tesla descarga sobre todos los enemigos en su alcance circular; Frost cubre una zona cuadrada y ralentiza un 15% durante 1 s; Flame y Poison afectan solo al cono frontal, aplican 100% del daño base como Burn/Poison y sus ticks pasan por `DamageService`; Shredder pega directamente, aplica Bleed por el 100% del daño base restante y pierde 1 de daño base en cada enemigo atravesado.
- Para comprobar el cambio de capa sin interferencia de regeneración, en una copia local poner a 0 las tres regeneraciones del `tower_layer_training_dummy.tres`. Un impacto Ballista de 10×5 debe consumir como máximo los 40 Shield y dejar Armor/Health intactos; el siguiente golpe solo afecta Armor y Health no recibe daño hasta agotarse Armor. Restaurar las tres regen en 1/s. Con Bleed/Burn/Poison activos, confirmar que se detiene regen de Health/Armor/Shield, respectivamente. Después, un ataque directo recibe +1 una sola vez al multiplicador de la capa asociada al estado (sin multiplicación adicional por stacks); el tick periódico no recibe ese bonus y usa su daño por capa configurado (100% en la asociada, 50% en las otras).
- El test DEBUG no paga Gold, no daña la base ni avanza número de campaña. Al salir del diagnóstico, la campaña y sus Resources conservan su estado.

### Prueba manual M12A en el juego

1. Ejecutar `game/main/main.tscn`, desbloquear varios perfiles en la tienda al disponer de moneda meta y construir una Ballista. Seleccionarla y comparar su resumen con el perfil actual; debe indicar 20 RPM. Durante combate, medir el tiempo entre dos disparos consecutivos de la Ballista con el mismo objetivo continuamente en rango: debe ser 3 s (20 disparos/minuto); medir el flash o evento de lanzamiento, porque el proyectil viaja después del disparo. Usar `1–7` después de desbloquear las otras torres para confirmar las siete filas de stats.
   - En la ronda 1, sin mejoras, crítico ni elevación, confirma que un proyectil de Ballista elimina al Goblin: 10 de daño base × 10 al Health = 100 contra sus 100 Health. Si el objetivo tiene Armor o Shield, el impacto debe afectar primero esa capa y respetar el multiplicador de la Ballista para ella.
2. Construir tres Ballistas (precios 10/25/40), seleccionar una y pulsar `Demoler`. Comprueba que no devuelve Gold y que el precio visible de la próxima Ballista baja al nivel que corresponde al conteo restante.
3. Seleccionar la Ballista restante y comprar la mejora `Shield`. Debe cobrar el coste de Shield, subir solo Shield en 1 y añadir +1 al daño base y +1 al multiplicador Shield. Health y Armor conservan su nivel y XP. Comprar después Health y confirmar que Shield no cambia. Las barras muestran progreso/XP propios y los costes usan el nivel de su propia capa.
4. Abrir F3, elegir `DEBUG · capas Shield/Armor/Health`, iniciar y observar el enemigo. Sus segmentos deben empezar azul/beige/verde; pasar los valores actuales en el inspector técnico. Con la copia de regen=0, confirmar que solo cae Shield al principio; después Armor; Health al final. Restaurar regen=1/s y comprobar cada capa se regenera. No conservar modificaciones temporales.
5. Construir un Frost Keep y colocar/enlazar celdas PATH adicionales dentro del cuadrado de alcance; su RPM del resumen debe crecer en 18 por cada PATH adicional y su área debe alcanzar objetivos dentro de ese cuadrado. Las demás torres mantienen RPM base aunque se amplíe el mapa.
6. Probar las prioridades ordenadas con varios enemigos y empates: abrir Prioridad 2 y 3 con `+`; la segunda solo resuelve el empate de la primera y la tercera el empate restante. No se permiten criterios duplicados; elegir una prioridad ya usada debe intercambiar su posición con el criterio desplazado.
7. Comprobar los proyectiles Ballista/Mortar, la explosión AoE del Mortar, el impacto de Tesla sobre todos los enemigos en alcance, los efectos de cono y ticks al 100% de Flame/Poison, Slow cuadrado y Shredder directo+Bleed/perforación. Verificar que sin Mana Tesla/Frost/Flame/Poison esperan; Ballista/Mortar/Shredder no consumen.
8. Alcanzar ofertas M11 y seleccionar, en runs sucesivas, `Foco de Health`, `Foco de Armor` y `Foco de Shield`; comprobar que el multiplicador correspondiente aumenta en todas las torres existentes y construidas después. Obtener también `Impulso crítico global` o `Advanced Circuits`, confirmar el crítico en stats y observar impactos con multiplicador variable. Cada carta puede requerir otra run por su peso de oferta.

M12A queda aceptado cuando barra/daño por capas, stats de los siete perfiles, precio incremental/demolición, los dos caminos de upgrade, prioridades ordenadas, crítico, comportamiento diferencial y counters de regeneración pasan en ventana Godot. La progresión individual detallada en M20 tiene su propio criterio manual. La implementación de código está documentada; todavía no se ha ejecutado este procedimiento ni se ha hecho inspección visual.

## M13 UX/UI

- El HUD activo se actualizó en M22: salud/atajos arriba a la izquierda, Gold/Mana arriba a la derecha, ronda centrada y datos de torre a la derecha debajo de los recursos; sin paneles compartidos para salud, recursos ni ronda. El título «RogueTower» no aparece. La salud de Main Tower muestra su valor actual/máximo dentro de una barra segmentada cada 10 puntos, con un segmento final parcial si corresponde. El Gold usa un icono y tamaño visual mayores que el Mana; toda ganancia o gasto anima icono y cifra con escalado y rebote. El Mana se restablece a su máximo efectivo al comenzar cada ronda y se muestra como entero, sin decimales. El progreso presenta 45 puntos de tamaño variable, destaca encuentros especiales y muestra composición al hacer hover; el botón de inicio lleva sprite propio.
- El selector de perfiles de oleada y la lectura técnica continua del objetivo no ocupan la vista normal: aparecen dentro del panel F3. Abrir/cerrar F3 no altera la fase ni los saldos; `H` oculta y restaura paneles, barra de torres y panel técnico. La navegación con rueda y botón central continúa funcionando con el HUD visible/oculto.
- Seleccionar una torre muestra en el panel derecho nivel, daño, H/A/S, alcance, RPM, crítico, patrón, icono de energía si consume y XP por capa. El panel se ajusta al contenido y nunca usa scroll; reduce su escala vertical si el alto del viewport no permite mostrarlo a tamaño natural. Al entrar en build mode presenta el retrato grande de la torre y sus datos; omite la instrucción redundante de elegir Grass/Mountain y muestra el bonus cuantificado de Mountain frente a Grass. Health, Armor y Shield usan negrita y colores distintos. Los tres botones de mejora casi cuadrados enseñan icono, nivel de su capa, barra XP, `+1 Daño`, efecto y precio; Demoler queda debajo. Hover sobre torre no seleccionada muestra el radio y un contorno; al seleccionar, el sprite y card inferior pulsan con brillo alfa, sin círculo y sin pulso del panel. Prioridad 1 aparece sola; botones `+` revelan prioridades únicas 2 y 3. El panel desaparece al deseleccionar la torre o pulsar fuera del tablero.
- Cada objeto tiene su PNG RGBA transparente independiente en `game/ui/icons/` (256×256); no existe un atlas compartido. Los atajos inferiores son botones individuales con un asset de marco estilo carta, sprite grande, nombre y precio con icono de moneda; el contenedor que los alinea no muestra fondo ni marco común. El sprite de torre es idéntico al preview y a la torre colocada. La base usa un sprite PNG configurable desde `BaseData`. Los tamaños por perfil son: torres 84 px, enemigos estándar 72 px con jefes escalados por recurso y base 176×176; todos se dibujan 6 px más abajo. No cambian huellas lógicas ni movimiento. La UI sustituye por iconos las menciones a Gold/Mana en textos enriquecidos. Las cards específicas muestran la torre afectada; las cards de terreno conservan el contrato M10.
- Los enemigos muestran un marco de Health con carriles de Shield y Armor sobre una Health fragmentada; los iconos de capa identifican cada carril. Los estados activos aparecen encima y solo muestran cifra cuando hay varias acumulaciones. Cada impacto hace destellar y saltar al enemigo, y presenta daño flotante coloreado según Shield, Armor o Health. El efecto no cambia el cálculo de `DamageService`.
- Al derrotar la base, el overlay terminal identifica claramente derrota; al superar la ronda 45 identifica victoria. Ambos resumen ronda alcanzada, rondas completas, recompensa y saldo total de moneda meta; la seed queda en tooltip técnico.
- En la tienda, `TORRES` y `MEJORAS` son categorías independientes. Cada fila muestra nombre, descripción, coste/estado y acción; saldo insuficiente o guardado bloqueado impide comprar y no cambia el progreso. «Empezar nueva run» conserva las compras, recarga el tablero y aplica los niveles permanentes.
- A 1440×900, el HUD principal, el panel F3, la barra de siete torres y las ofertas no se recortan ni bloquean la lectura del mapa. La tienda terminal se adapta al área visible y, si una categoría excede su altura, se puede recorrer con scroll vertical.

### Prueba manual M13 en el juego

1. Abre `game/main/main.tscn` en la ventana de 1440×900. Comprueba que la base muestra el nuevo sprite sobre la huella hexagonal y que la barra de salud tiene un bloque por cada 10 puntos con el texto actual/máximo centrado. El HUD no presenta título «RogueTower»: salud y atajos quedan arriba a la izquierda; Gold/Mana, arriba a la derecha; el estado de ronda, sus 45 puntos y el botón responsive se centran. El panel derecho empieza oculto. El icono y la cifra del Gold deben destacar sobre los del Mana. El tooltip del Mana expresa su regeneración sin decimales; el saldo visible nunca muestra decimales.
2. Confirma que el HUD normal no presenta el selector de fixtures ni la línea técnica del enemigo. Abre `F3`: deben aparecer selector de rondas/pruebas, coordenada axial/terreno, preview y rotación, además del inspector de objetivo. Si la torre consume Mana, su coste en el inspector debe usar el icono PNG junto a la cantidad. Cierra F3 y confirma que desaparecen los datos técnicos. Pulsa `H`, mueve/zoomea el tablero, vuelve a pulsar `H` y comprueba que la interfaz vuelve sin haber cambiado la cámara ni la ronda.
3. Activa build mode para Ballista y para otra torre: el panel derecho debe mostrar un icono grande, coste, stats H/A/S con color y bonus de Mountain vs Grass, sin la frase «selecciona Grass o Mountain». Comprueba que su alto se ajusta a esta información. Construye Ballista en Grass/Mountain. El botón individual tiene fondo estilo carta y el conjunto no queda dentro de un panel compartido. El botón, el preview del cursor y la torre colocada deben mostrar la misma Ballista ampliada. Pasa el cursor sobre ella: aparece su radio y contorno; selecciónala y comprueba que mantiene su brillo y pulso de sprite/card sin mostrar círculos. Haz clic en una casilla vacía y confirma que el panel desaparece.
4. Selecciona cada torre disponible en la barra. Comprueba icono grande arriba, nombre debajo y cifra de precio junto al icono de moneda. Con Gold insuficiente, los atajos afectados deben estar deshabilitados y verse atenuados, incluidos sus iconos y textos; tras ganar Gold suficiente se activan. Gasta Gold construyendo o mejorando y gana Gold con recompensas: tanto el icono como la cifra deben escalar y rebotar juntos en cada cambio. Gasta parte del Mana antes de iniciar una ronda y confirma el saldo como entero; al iniciar la siguiente, debe volver al máximo efectivo. Pasa el cursor por una torre no seleccionada para ver su radio/contorno; selecciónala y comprueba que el panel no pulsa y el sprite no tiene círculo. Confirma que el click fuera limpia selección. En el resumen lateral comprueba las etiquetas y valores Health verdes, Armor ámbar y Shield azules, además de iconos y XP. En la torre seleccionada, abre prioridades adicionales con `+`; intenta repetir un criterio y confirma que se intercambian sin duplicarse y que la primera posición no se puede vaciar. Confirma que el panel se ajusta a sus datos, y que los tres upgrades son grandes y casi cuadrados, muestran icono/capa/`+1 Daño`/precio, y Demoler aparece debajo.
5. Para la comprobación rápida usa F3 y la oleada DEBUG Health/Armor/Shield; para comprobar la campaña normal, llega a la ronda 24 y observa Ooogie von Ooogovich con su kit propio. Sobre el enemigo con pools activos debe verse Shield arriba, Armor debajo y Health fragmentada; las barras e iconos deben leerse a simple vista. Observa impactos en cada fase: el enemigo parpadea/salta y los números son cian para Shield, ámbar para Armor y rojo para Health. El valor debe corresponder al daño que realmente aplicó el juego.
6. Repite con la oleada de estados M8 y Frost Keep, Flame Thrower, Poison Sprayer o Shredder. El símbolo PNG de Bleed, Burn, Poison o Slow aparece encima de la barra sin una placa o fondo opaco, ampliado y con transparencia; no debe verse un rectángulo detrás. Para un estado acumulable, aplica al menos dos acumulaciones y comprueba que aparece su cifra; al expirar, icono y cifra desaparecen. Verifica que estado y barra acompañan al enemigo durante su movimiento.
7. Obtén una card específica de una torre durante la run: la card incluye el sprite de esa torre. Elige cartas con descripciones que aumenten o consuman Gold/Mana y confirma que aparecen los iconos en línea; no debe quedar el nombre textual de esas monedas en los elementos enriquecidos.
8. Repite una run hasta derrota dejando llegar enemigos a la base. La tienda debe presentar derrota, ronda, rondas completas, recompensa y saldo meta. Cambia entre TORRES y MEJORAS: solo se ve la lista activa con descripción/coste/estado. Compra una opción asequible y confirma el saldo nuevo; con saldo insuficiente no debe cobrarse. «Empezar nueva run» debe conservar las compras. Completa la campaña hasta 45/45 para revisar la variante de victoria.
9. A 1280×720 y 1440×900, repite HUD, F3, panel lateral, barra inferior y cards. Los controles deben permanecer legibles; el panel lateral muestra todos sus datos, nunca presenta scroll y se reduce verticalmente si el alto del viewport es insuficiente. La tienda sí debe desplazarse sin bloquear el mapa ni recortar nombres, precios o cifras. Confirma que las ilustraciones de Path/Grass/Mountain coinciden con las caras hexagonales sin corrimiento visible y que torres, enemigos y base conservan sus puntos de anclaje al aumentar de tamaño y desplazarse 6 px hacia abajo.

M13 queda aceptado cuando los nueve puntos anteriores pasan en una ventana Godot y se comprueba que la interfaz guía acciones normales sin requerir DEBUG, mantiene sprites consistentes, segmenta la base cada 10 Health, repone Mana al inicio de cada ronda, anima las variaciones de Gold, comunica estado/capas/daño con iconos y animación, conserva F3 y permite operar prioridades, upgrades y tienda sin ambigüedad. En esta revisión se implementó el código y se actualizaron los documentos; la inspección visual y esta prueba manual siguen pendientes.

## M14 Terreno, cofres y feedback

### Prueba manual en el juego

1. Inicia una run con un seed conocido. Confirma que las celdas Path no contienen props; Grass genera obstáculos con una frecuencia aproximada del 25 % y Mountain del 15 %. Repite una run con el mismo seed y verifica que las asignaciones coinciden. Explora suficientes celdas para distinguir roca, esquirla, hierba alta, tótem y piedras; comprueba también las tres variantes visuales de Path, Grass y Mountain. Las caras deben cubrir el mismo footprint hexagonal y las cinco decoraciones deben ocupar exactamente 86×86 px, estiradas si su arte fuente tiene otra proporción, centradas y con el pie seis píxeles debajo del centro lógico. Confirma la misma caja en las cards de terreno.
2. Activa build mode y apunta a obstáculos de varios tipos: el preview debe marcarlos inválidos y no se debe colocar torre. Repite en una celda Grass/Mountain con cofre; la torre tampoco se debe construir hasta abrirlo. Haz clic en el cofre y confirma que desaparece y añade 25 Gold una sola vez, sin alterar la ruta ni la celda axial. Vuelve a hacer clic y confirma que no duplica la recompensa.
3. En la tienda permanente compra «Suerte del explorador» nivel por nivel y comienza otra run para que cambie el porcentaje de cofres. Comprueba que parte del 1 %, sube en pasos de 5 puntos porcentuales y se limita al 20 % tras cuatro niveles; la configuración persiste al reiniciar el juego.
4. Comprueba el VFX al impactar cada torre: Ballista Dust_01, Mortar Explosion_01, Tesla Coil TeslaCoil, Frost Keep Ice_01, Flame Thrower Fire_03, Poison Sprayer Poison y Shredder Blood. Los efectos deben aparecer en la posición de impacto y concluir su animación sin quedarse congelados.
5. Comprueba los cuatro estados del cursor: Cursor_01 normal, Cursor_02 al pasar sobre controles u objetos interactivos, Cursor_03 al apuntar a terreno inválido o una acción deshabilitada, y Cursor_04 mientras se coloca una torre.
6. Verifica que el panel lateral de torre no tiene barras de desplazamiento a 1280×720 y 1440×900; debe mostrar todo su contenido y adaptarse a la altura disponible. Revisa que la tienda conserve su scroll cuando una categoría exceda el espacio.

El código y los assets están integrados. M14 requiere ejecutar este procedimiento en ventana y corregir cualquier problema visual/interactivo antes de marcarlo aceptado.

## M17 Oclusión, escala de arte y flujo de rutas

### Prueba manual en el juego

1. Coloca una torre y un obstáculo en hexes con distintas posiciones Y y mueve enemigos por PATH delante y detrás de ellos. Confirma que el elemento más cercano a la parte frontal del tablero aparece delante, que los props pueden quedar detrás de torres/enemigos y que la base también participa en el orden por profundidad. El orden debe seguir el pie visual de cada elemento, no su centro gráfico.
2. Inspecciona cada tipo y variante de terreno. El borde pintado del PNG debe coincidir con el contorno de la cara hexagonal, sin desplazamiento lateral o vertical visible y sin tapar de más las celdas vecinas.
3. Con `Ctrl+D` desactivado, confirma que cada rama y convergencia de PATH muestra flechas con movimiento continuo hacia la base. Cambia una colocación válida para revisar el grafo candidato; cancélala y comprueba que vuelve a fluir el grafo activo. Los portales pulsantes siguen visibles y no muestran carteles.
4. Comprueba las dimensiones por recurso (torres 84 px, enemigos estándar 72 px y base 176×176) a zoom 1× y 0,75×. Deben conservar proporción y su arte debe quedar unos 6 px por debajo del centro lógico. La ampliación no debe alterar selección, ocupación, alcance, hitboxes de combate ni navegación.

ADR-0041 y ADR-0042 implementan en código la ordenación de props, la alineación del arte, el flujo animado por aristas, la profundidad por elevación, el hover selectivo del grid y el portal de spawn. Esta revisión no marca M17/M18 aceptados hasta completar las comprobaciones visuales en una ventana Godot.

## M18 Orden visual, feedback y piezas de terreno

### Prueba manual en el juego

1. Haz pasar enemigos por PATH junto a una montaña elevada y coloca la base detrás de una celda elevada. Comprueba que las fachadas del cliff no se dibujan encima de unidades: solo la superficie superior texturada debe ocultar objetos cuyo anclaje quede detrás por Y-sort. Los objetos delante deben mostrarse por encima; torres y props sobre la misma celda elevada deben seguir legibles.
2. Aleja el cursor de las celdas: no deben verse los bordes blancos del grid ni las conexiones/sockets de PATH. Haz hover sobre una celda y confirma que aparece su borde y ruta; las celdas a una y dos posiciones axiales se muestran con opacidad decreciente y el resto sigue oculto. Las flechas de flujo permanecen visibles.
3. Sigue un portal de spawn alcanzable: debe pulsar suavemente, no debe tener etiqueta/cartel `SPAWN` y debe desaparecer si deja de ser endpoint alcanzable. Selecciona una card, mueve el preview a una posición válida y confirma que los portales siguen los endpoints del grafo candidato con un tono verde; rota, cancela y comprueba que se recalculan o restauran según el estado activo. Verifica que el flujo de flechas apunta a la base en ramas y convergencias.
4. Entra en modo de construcción y confirma que el cursor de torre mide aproximadamente 32 px y pulsa mientras sigue el puntero. Al pasar por un botón debe volver el cursor de interfaz; sobre terreno inválido debe usar el cursor de error. Coloca una torre y confirma que vibra su icono correspondiente en la barra.
5. Comprueba que las siete cartas de torre son más grandes y tienen menor separación entre sí, sin recorte a 1280×720. Gana y gasta Gold y confirma que el icono y el saldo animan en ambas direcciones.
6. Revisa las diez nuevas piezas (Pradera de colinas, Macizo montañoso, Llanura abierta, Cresta escalonada, Loma aislada, Picos gemelos, Pradera con ramal sin salida, Curva junto al acantilado, Camino serpenteante y Bifurcación del barranco). Cada oferta debe tener siete hexes y mostrar los obstáculos representativos sobre Grass/Mountain; PATH no lleva props. Confirma que la ilustración no se trata como resultado garantizado: la asignación real se genera al colocar la pieza. Gira cada pieza y comprueba terreno, reciprocidad PATH y colocación/validación global. En la pieza del ramal, confirma que la rama norte termina dentro de la pieza y la salida este continúa conectándose con el grafo existente.

El código, las piezas y el sprite del portal están integrados. La aceptación M18 queda pendiente hasta recorrer estos puntos en ventana Godot. La corrección de superficies y la vista de obstáculos en cards está registrada en ADR-0043.

## M19 Auditoría de torres, selección y texturas

### Prueba manual en el juego

1. Selecciona una torre sobre Grass y otra sobre Mountain elevadas. El panel lateral debe permanecer quieto; la card inferior activa y el sprite de la torre pulsan, y el brillo azul sigue el alfa del PNG. No debe aparecer un círculo alrededor mientras está seleccionada. Revisa desde varios lados que la torre seleccionada aparezca por delante de tapas altas, Path, obstáculos y otras torres; al deseleccionar debe recuperar el Y-sort.
2. Haz hover en una celda Path y en Grass/Mountain de elevación 1 y 2, incluidos hexes delanteros a otras superficies. El borde de la tapa seleccionada debe coincidir con su superficie elevada y quedar legible sobre el arte; sockets PATH deben compartir los anillos con opacidad decreciente.
3. Observa una rama larga y una convergencia. Las flechas deben avanzar en loop hacia la base, a menor velocidad, con menos repeticiones y menor opacidad que el build anterior; verifica que las ramas del candidato válido cambian durante el preview y se restauran al cancelar.
4. Gana Gold por kill, cofre y limpieza, y gasta Gold en construcción/mejora. En una recompensa, icono y cifra deben pegar un rebote amplio juntos y regresar a escala normal; el gasto conserva un efecto perceptible más corto. Cofre nuevo: aparece con una pulsación única y termina en escala normal. Portal: cada spawn pulsa lentamente con fase distinta; no deben volver a oscilar todos al mismo tiempo.
5. Compara las texturas con el tablero a zoom 1× y 2,5×: base, portal, cofre y carta de torre deben conservar la escala visual anterior, con detalles limpios y sin memoria/resolución exageradas. Confirma que existen nueve PNG de tiles de 180×208 y cinco PNG de obstáculos de 208×208; todos conservan alpha y cada una de las catorce rutas está usada en mapa o card. Los dos atlas originales quedan guardados como fuentes, pero no los carga `TerrainVisualCatalog`.
6. Construye cada tipo de torre y coteja el panel con [Auditoría del sistema de torres](15_AUDITORIA_SISTEMA_DE_TORRES.md). Comprueba RPM, rango circular/cuadrado, coste de Mana, daño por capa, mejora manual y mejora XP en objetivo de cada capa. Configura dos y tres prioridades para confirmar los desempates lexicográficos del proyecto y su diferencia frente a los pesos oficiales RT. Como observación de balance y sin modificar datos, contrasta las bandas críticas y el Mana de Frost Keep con las preguntas pendientes del informe.

El código y las texturas de M19 están integrados. No se ejecutó Godot para esta revisión; M19 queda pendiente de aceptación visual/interactiva en ventana. El informe distingue hechos runtime de propuestas no aprobadas.

## M20 Progresión individual, targeting y feedback de colocación

### Prueba manual en el juego

1. En una run, selecciona una torre y compra una mejora Health. Confirma que solo Health aumenta `0 → 1`, que sube +1 el daño base y +1 el multiplicador Health, y que Armor/Shield conservan niveles y XP. Mejora luego Armor y Shield: cada botón debe afectar únicamente a su propia capa. El total del resumen debe aumentar una unidad por compra y mostrar `n/45`.
2. Examina los tres botones: cada uno debe mostrar icono/nombre de la capa, nivel `n/15`, barra XP con color Health verde, Armor ámbar o Shield azul, XP actual/umbral, efecto y coste Gold. Comprueba que la barra solo avanza en la capa activa del enemigo que la torre mantiene como objetivo; cambiar a un enemigo con otra capa activa debe enviar la XP posterior a esa otra capa. XP acumulada previamente en la primera capa no debe desaparecer.
3. Comprueba que las compras de cada capa parten de su coste base independiente (10/20/30 Gold según la torre) y que el siguiente coste de esa misma capa crece con el nivel propio. Para verificar el límite sin farmear toda una run, utiliza un fixture o una copia local de Resource con umbral/costes bajos: una capa debe llegar a `15/15`, bloquear XP y compra solo para sí; las otras dos deben poder seguir subiendo. La suma máxima debe ser 45, con daño base total incrementado en 45 y +15 a cada multiplicador si se maximizan las tres.
4. Al seleccionar una torre, aparece solo Prioridad 1 junto al botón `+`. Cada clic revela una fila debajo, primero Prioridad 2 y después Prioridad 3. Cambia de torre y confirma que las filas no configuradas quedan ocultas. Elige criterios distintos y verifica que sus tooltips explican la métrica; en «Menos HP total», compara objetivos con sumas Health+Armor+Shield distintas. Repite un criterio ocupado y comprueba el intercambio; intenta duplicar en una fila vacía y confirma que se revierte. No quedan duplicados y Prioridad 1 no se puede vaciar. En empate deliberado, la segunda resuelve el empate de la primera y la tercera el empate que quede.
5. Entra en build mode y mueve la torre seleccionada encima de superficies elevadas, obstáculos, Path y huecos. El sprite y el contorno del ghost deben verse siempre delante de terreno, obstáculos, base, torres y enemigos, también si la ubicación es inválida. Las posiciones legales se contornean en verde y las no disponibles en rojo; comprobar por separado Path, obstáculo, celda ocupada y falta de Gold. No se debe colocar torre si el contorno está rojo.
6. La card de torre activa de la fila inferior debe pulsar al entrar en build mode y al seleccionar una torre colocada; las otras cards mantienen su escala normal. Al cambiar selección, el pulso debe trasladarse a la nueva card y resetear la anterior.
7. Mide las cinco decoraciones sobre mapa y cards: todas ocupan 86×86 px, se ven centradas en su celda con el desplazamiento artístico compartido de 6 px hacia abajo, y conservan bloqueo de construcción. La nueva caja no debe cubrir excesivamente el hex vecino.
8. Revisa la celda de base y sus seis vecinas axiales: todas las vecinas deben tener elevación 0 y la base no debe quedar tapada por una tapa elevada inmediata. Ejecuta la validación de tablero inicial y confirma que rechazar una vecina con elevación positiva produce error.

M20 queda aceptado cuando los contadores, XP, costes y límites son independientes por capa; las prioridades mantienen orden y unicidad; el preview da feedback visible sin permitir colocaciones inválidas; el pulso se mueve con la selección; las cajas de obstáculos coinciden y el anillo de la base es plano. Esta revisión integró código y documentación, pero no ejecutó Godot ni la prueba manual.

## M21 Herramientas de depuración, prioridades y hover de obstáculos

### Prueba manual en el juego

1. Pulsa `Ctrl+K` y confirma que el menú abre/cierra y no mueve el mapa. Activa cada acción: Gold aumenta 1.000; Mana aumenta 100 hasta su máximo; la acción de restaurar lo repone al máximo; Curar la base recupera Health; iniciar ronda invoca la ronda seleccionada cuando la fase permite empezar; reiniciar crea una run con tablero/economía/cartas nuevos y conserva las compras permanentes.
2. Activa «Desbloquear todo»: deben aparecer las siete torres y poder ofrecerse cartas con requisito de unlock. Repite después de desactivar el override y comprueba el roster persistente original. Reinicia la run con el override activo y confirma que el nuevo run vuelve a los desbloqueos guardados. Inspecciona el archivo de meta-progresión: el botón de depuración no añadió IDs.
3. Gana Gold por bajas, cofre y ronda, y gástalo en construir o mejorar. Tanto el icono como el número de Gold del HUD superior derecho deben aumentar de tamaño y rebotar juntos. El importe permanece legible y vuelve a escala normal.
4. Selecciona torre: el panel derecho no debe vibrar. Solo pulsa la card inferior elegida y el sprite seleccionado; el sprite conserva brillo recortado pero no muestra círculo. Haz hover sobre otra torre y confirma que se ven su rango y contorno de hover.
5. Prueba targeting en ventana 1280×720 y 1440×900. Por defecto hay una fila; `+` revela la segunda y luego la tercera. Al cambiar a torre con una sola prioridad, las filas extra se ocultan. El panel entero queda dentro de la ventana con sus datos, sin scroll.
6. Haz hover sobre cada obstáculo en diferentes elevaciones. El resplandor debe seguir solo la forma opaca del PNG, incluido el recorte transparente, y desaparecer al abandonar la celda; cofres y terreno no deben adquirir el contorno de obstáculo.
7. Comprueba el invariante del spawn: al arrancar hay al menos una salida PATH exterior con ruta hasta Main Tower. Durante expansión mueve y rota cada pieza candidata. Una que no tenga spawn alcanzable o rompa cualquier ruta existente debe verse inválida y no permitir confirmación; el grafo activo y sus portales no cambian hasta confirmar una pieza válida.

M21 queda aceptado cuando los cheats sirven para preparar una sesión, no alteran datos persistentes salvo el contador normal de run reiniciada, Gold rebota de manera visible, las prioridades se despliegan gradualmente, panel y selección respetan la jerarquía visual y ninguna expansión confirmada elimina todos los spawns alcanzables. La aceptación requiere inspección manual en Godot.

## M22 HUD, oleadas, cards de terreno y fachadas

### Prueba manual en el juego

1. Inicia `game/main/main.tscn`. Comprueba que no aparecen errores al resolver `%GoldGroup` y que tanto ganar como gastar Gold animan icono y cifra. La vida de Main Tower queda arriba a la izquierda con los atajos debajo; Gold y Mana quedan arriba a la derecha, con valores enteros y sin fondos compartidos.
2. Selecciona una torre. El panel lateral debe comenzar debajo de Gold/Mana y no cubrir los recursos. Cambia la resolución entre 1280×720 y 1440×900; el panel de ronda y el botón no deben quedar cortados.
3. Comprueba que el bloque de ronda no tiene panel de fondo y que el botón usa su sprite completo sin deformación, mantiene el texto legible y adapta su anchura con «Iniciar ronda», «Iniciar ronda NN/45» y los estados deshabilitados.
4. Revisa los 45 puntos: debe haber uno por ronda, los de mayor cantidad deben verse mayores y las rondas con jefe/enemigo de boss tier deben tener énfasis. Pasa el cursor por rondas simples, mixtas y especiales; el tooltip indica el total, usa el retrato del `EnemyData` y lista solo tipos cuya suma es mayor que uno. Los singleton solo forman parte del total.
5. Tras completar una ronda y abrir las tres cards de terreno, confirma que no existe panel de fondo compartido. Cada card conserva su marco y preview; la preview se ve completa dentro del marco y no sobresale. En oferta las cards miden al menos 320×420 px; durante colocación se reducen a 184×126 px y mantienen la preview contenida. Debajo indica cantidades como `4 Path 2 Grass 1 Mountain`; comprueba que las categorías con cero unidades no aparecen.
6. Coloca o consulta celdas elevadas Grass y Mountain de nivel 1 y 2. Las fachadas deben usar su material de césped/tierra o roca, conservar el mismo tamaño de detalle entre ambas alturas, quedar cerradas sin grietas ni ángulos abiertos y permanecer debajo de las entidades. Confirma que la cara superior mantiene el Y-sort y que los PNG pueden reemplazarse sin cambiar la altura lógica.

M22 queda aceptado tras pasar esta revisión manual en ventana Godot. La integración de código y arte está registrada en [ADR-0048](../decisions/ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md).

## M23 Navegación, preview de portales, ghost y Tower Info

### Revisión manual en ventana

1. Ejecuta `game/main/main.tscn`. Mantén `W`, `A`, `S`, `D` y prueba diagonales; la cámara debe moverse continuo sin aceleración diagonal extra y mantener velocidad visual al acercar/alejar. Comprueba que `D` panea a la derecha y que `Ctrl+D` alterna el overlay diagnóstico. Suelta las teclas y cambia el foco de ventana mientras una está pulsada: la cámara no debe quedarse moviéndose. Los controles con foco de interfaz deben conservar su entrada.
2. Inspecciona las salidas PATH de una ronda mixta con varios endpoints. Encima de cada portal deben aparecer los tipos de enemigo asignados a ese endpoint y una cifra en los grupos repetidos. Al hacer hover aparece el contorno que sigue el alfa del portal y un tooltip con ronda, total y cantidades por tipo. Suma todos los portales y compara con la composición directa de esa `WaveData`.
3. Repite para una ronda siguiente, un fixture DEBUG con `ROUND_ROBIN` y otro con `FIRST`; confirma que los iconos y conteos cambian con la ronda/política. Selecciona una expansión válida y mueve/rota su preview: la vista por portal debe usar los endpoints del grafo candidato. Al cancelar o invalidar, debe volver al grafo activo. El tooltip no debe quedarse visible cuando se oculta el HUD ni capturar clics.
4. Entra en colocación de torre y mueve el cursor por celdas legales e ilegales, elevadas y con obstáculos. El sprite fantasma debe quedar encima de terreno y props y recibir tinte verde translúcido si es válido o rojo si no. Al cancelar no debe permanecer el sprite fantasma.
5. Revisa torres, enemigos, base, cofres y obstáculos en profundidad: no deben aparecer elipses ni trazos de sombra proyectada generados por el juego debajo de ellos. El arte que venga dibujado dentro de sus PNG no se elimina.
6. Selecciona una torre y revisa Tower Info a 1280×720 y 1440×900. El marco PNG debe conservar las esquinas; el retrato aparece grande debajo del encabezado, el título queda junto a `NIVEL X DE 45` y el panel ajusta su altura sin scroll ni recorte. Las mejoras H/A/S muestran iconos mayores, nivel en negrita y XP como barra con progreso/restante; el tooltip de cada botón incluye las cifras de XP. Demoler es cuadrado de 64×64, su icono queda limitado a 36×36 y no estira el panel; conserva su comportamiento. Comprueba que el nivel acumulado avanza tras comprar capas y llega como máximo a 45.

M23 queda aceptado tras completar esta revisión manual en ventana. El cambio está registrado en [ADR-0051](../decisions/ADR-0051-navegacion-prevision-portales-y-panel-torre.md).

## M24 Feedback legible de daño

### Revisión manual en ventana

1. En una oleada de combate, observa impactos repetidos en enemigos con Health, Armor y Shield. Cada número debe entrar con un golpe breve de escala, desplazarse hacia arriba por un arco alternando los lados, variar su tamaño de forma moderada y desaparecer con un contorno oscuro que mantenga legibilidad sobre el mapa.
2. Confirma que el texto y el flash del enemigo identifican Health en rojo, Armor en ámbar y Shield en cian. Compara golpes pequeños y grandes al mismo enemigo: el tamaño relativo debe notarse sin producir números desproporcionados.
3. Genera un crítico y confirma que su etiqueta `CRIT`, tamaño/contorno y punch destacan sin ocultar el color de la capa afectada. Comprueba grupos de muchos enemigos y torres rápidas: los números deben separarse lo suficiente para leerse y no afectar HP ni el resultado de combate.

M24 queda aceptado tras completar esta revisión manual en ventana. La decisión está registrada en [ADR-0052](../decisions/ADR-0052-numeros-de-dano-animados-y-legibles.md).

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

## UI — migración híbrida (2026-10-10)

### Smoke de escenas y contratos

Ejecutar `tests/ui_migration_smoke.tscn` en Godot 4.7. Debe completar e imprimir `UI migration smoke: PASS` sin errores de script/escena. El smoke verifica carga/instanciación de `main.tscn`, emisión única del ID `start_wave` por el menú debug, configuración de tarjetas de torre, controles de capa, oferta de tres y cinco cartas, filas de tienda de torre/mejora, `new_run_requested`, y filas de tooltip desde `WaveData`. No sustituye la navegación por la partida ni la revisión visual.

### Revisión visual e interactiva en ventana

1. Abre `game/main/main.tscn` a 1440×900 y después a 1280×720. Compara posiciones, dimensiones, tipografía, iconos, colores, fondos y escalado con la implementación anterior; ningún panel debe quedar cortado ni cubrir Gold/Mana.
2. Usa `Ctrl+K` y cada acción debug disponible. Comprueba que el panel aparece en la misma capa, no bloquea controles fuera de su superficie, emite una sola acción y se cierra/togglea igual. Comprueba que `H` oculta/restaura el HUD como antes.
3. Construye/selecciona una torre, cambia la selección, mejora por Health/Armor/Shield y demuele. Revisa hover, foco, disabled/pressed, el pulso del icono, cantidades/XP/costes y propagación de clics al tablero.
4. Completa una ronda que ofrezca mejoras: abre/cierra la oferta, inspecciona tres cartas y elige una. Confirma orden, contenido, animación y estado de la run; comprueba también que el número sigue el `offer_size` configurado.
5. Abre la tienda terminal y cambia entre pestañas. Desplaza listas largas, compra contenido disponible/no disponible, verifica monedas/mensajes, resultado y «Nueva run». Confirma que el guardado y los unlocks conservan el comportamiento anterior.
6. Pasa el cursor por varios puntos de `RoundProgressStrip`. El tooltip debe conservar anclaje/ocultación y total; una sola fila por tipo repetido, mismo retrato y conteo. Comprueba cursor y hover al salir del strip.
7. Selecciona `Main` y expande `ui_icon_catalog`: deben verse las 20 texturas del catálogo, agrupadas por recursos, capas, torres, estados y cursor. Cambia un icono de torre y confirma que se refleja en el retrato/cards que consultan el catálogo. Selecciona `TowerShortcut1…7` y `UpgradeHealth/Armor/Shield`; cada instancia debe exponer su `tower_icon_texture` o `layer_icon_texture` y previsualizarla en el `TextureRect` hijo. Comprueba también en esta propiedad los cuatro cursores usados por `BuildCursorOverlay`.
8. Selecciona `StartWave` y las tres `TerrainCard` en `main.tscn`; expande `Theme Overrides > Styles` y comprueba que sus StyleBoxTexture exponen el PNG, nueve cortes, márgenes y tintes de normal/hover/pressed/disabled. Cambia la textura para comprobar la vista previa. Abre `tower_shortcut_card.tscn` y revisa el marco 9-slice del botón.
9. Abre `game/ui/themes/rogue_hud_theme.tres` y edita `Panel`/`PanelContainer`. Las superficies generales son StyleBoxFlat y no usan sprite; los cambios se deben ver en HUD, tienda, oferta y debug sin cambiar su jerarquía.
10. Abre por separado las escenas de componentes en `game/ui/components/` y `game/progression/`. Ajusta tamaños en `custom_minimum_size`, márgenes y separación en sus `Container`, sustituye una textura en el `TextureRect` y confirma que los cambios se reflejan al instanciarlas desde `Main`.

M13 requiere además revisar los estados de selección/build mode del HUD y legibilidad a ambas resoluciones. El smoke headless y el escaneo del editor pasaron en Godot 4.7 el 2026-10-10; la inspección visual, el recorrido funcional completo y la comparación frente al baseline quedan pendientes. Ver [ADR-0049](../decisions/ADR-0049-arquitectura-hibrida-ui-editable.md) y [ADR-0050](../decisions/ADR-0050-recursos-visuales-ui-en-inspector.md).

## Scope
- No existe support building.
- Mana no depende de support building.
