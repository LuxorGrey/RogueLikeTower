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
- Cada endpoint spawn alcanzable muestra siempre en el mapa un portal rojo/ámbar en su coordenada exterior, flecha hacia el camino y etiqueta `SPAWN`; debe coincidir con los lugares de aparición de enemigos.
- `D` alterna el overlay con rutas por spawn y marcador de base; los indicadores de spawn permanecen visibles con el overlay apagado.
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
- El inspector técnico disponible con `F3` muestra HP, armadura, regen base/efectiva y daño estimado del objetivo de la torre seleccionada; el resumen de torre conserva sus stats de perfil en el HUD habitual.
- Se pueden seleccionar Ballista (6 HP al fixture), Perforadora (9 HP) y Drenadora Arcana (7 HP y 100% de contrarregeneración durante 1.25 s) contra el blindado de armadura 4, regen 2 HP/s y multiplicador arcano 1.25. Estos valores son placeholders.
- Status y sus payloads no se aplicaban en M7; M8/M9 añadieron estados y recompensas en hitos posteriores.

### Prueba manual de M7 en el juego
1. Ejecutar `game/main/main.tscn`. La interfaz habitual debe mostrar base, economía de run, estado de oleada, resumen de torre y acciones disponibles. La cabecera mantiene **F3 - Terreno   H - Interfaz**; el selector de perfiles y la inspección técnica de objetivo se ven al abrir F3, y `H` oculta/muestra el HUD completo.
2. Abrir F3 y elegir **DEBUG · blindado regenerador**. Construir una torre próxima al camino usando `1` (Ballista), `8` (Perforadora) o `9` (Drenadora); las tres opciones deben estar disponibles. Hacer clic en una casilla libre de Grass/Montaña.
3. Iniciar la oleada seleccionada. Seleccionar la torre si hace falta. Cuando el enemigo entre en alcance, el panel técnico F3 debe mostrar vida actual/máxima, armadura, regeneración y daño estimado; el tooltip del resumen de torre debe informar ese objetivo. Si el counter está activo también debe mostrar la regen efectiva reducida.
4. Repetir con cada perfil: Ballista estima 6 HP; Perforadora estima 9 HP porque solo aplica 1 punto de armadura; Drenadora estima 7 HP por vulnerabilidad arcana y, tras impactar, reduce la regen a 0 HP/s durante hasta 1.25 s.
5. Una prueba `DEBUG` debe volver a la misma fase de campaña sin cambiar ronda, oro ni vida de base. Cambiar a **Ronda 01/20 · normal · 3 enemigos**, completarla y comprobar que abre expansión; desde expansión se puede volver a seleccionar un diagnóstico y, al terminar, continuar la colocación pendiente. No deben quedar enemigos de la prueba anterior. La ronda real no se puede repetir ni saltar.
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
1. Ejecutar `game/main/main.tscn`, abrir el panel F3 y en el selector de oleada elegir **DEBUG · objetivo de estados M8**. Pulsar `0` y colocar **Sonda de estados (M8 prueba)** en Grass `(1,-1)`, que tiene alcance a lo largo de la ruta inicial.
2. Iniciar la oleada seleccionada. La línea de diagnóstico debe identificar **Objetivo de estados (M8 prueba)** y mostrar sus HP, impacto estimado y estados activos. El enemigo debe llevar aros celeste (Lento), naranja (Quemadura) y rojo/rosa (Sangrado).
3. Observar al menos tres impactos: Lento debe mantenerse en una sola acumulación y su duración debe refrescarse; Quemadura debe mostrar `×2` y luego `×3`, sin superar el máximo configurado aunque haya impactos posteriores. El objetivo debe avanzar más despacio mientras Lento esté activo.
4. Sangrado debe hacer bajar HP mediante ticks. Como dura 1.5 s y la torre ataca cada 2 s, su nombre/aro debe desaparecer durante el intervalo entre impactos y volver con el siguiente. Quemadura también debe reducir HP por ticks. Esta comparación comprueba expiración y aplicación del daño por el pipeline común.
5. El objetivo de entrenamiento debe sobrevivir el tiempo suficiente para observar los efectos y finalmente llegar al final de su ruta; al terminar, sus efectos y aros desaparecen. El HUD deja de mostrar un objetivo cuando ya no hay uno vivo en alcance. La prueba termina con cero pendientes/vivos y vuelve a la fase previa sin afectar vida de base, oro ni ronda.
6. Repetir la prueba M8: stacks, timers y ticks comienzan limpios. Elegir después el diagnóstico M7 para confirmar que los atajos `1`, `8` y `9` y sus perfiles conservan el comportamiento anterior.

Para dar M8 por aceptado deben pasar todos los criterios de la sección y la prueba manual debe verificar velocidad real, refresh, límite de stacks, daño periódico, expiración antes de la llegada, limpieza al finalizar la ruta, HUD y aros. Registrar cualquier ajuste de valores de fixture como provisional; la prueba no convierte Bleed ni estos números en diseño final.

## M9 Economy + Mana
- `Main` configura `RunEconomyService` desde `RunEconomyData`; el perfil de prueba inicia con 150 oro, 100/100 maná y regen interna de 1.5/s. El tooltip del maná y las descripciones de mejoras expresan tasas y modificadores como equivalencias con cantidades e intervalos enteros, sin decimales ni redondear el valor runtime.
- El oro de construcción es runtime de esta run y no altera `MetaProgression.meta_currency` ni se persiste como moneda meta.
- Los siete perfiles principales y sus costes aparecen en la barra: Ballista 30, Mortar 80, Tesla 70, Frost 50, Flame 65, Poison 65 y Shredder 100 oro. Los atajos `8`, `9` y `0` mantienen Perforadora/Drenadora/Sonda a 40 oro; Drenadora indica 4 maná por ataque.
- Una construcción legal cobra una sola vez antes de ocupar la celda. Terreno inválido, casilla ocupada o saldo insuficiente no cobran ni crean torre/ocupación.
- Una mejora cobra `TowerData.get_upgrade_cost(nivel_actual)`: en los fixtures M9, nivel 1→2 cuesta 20 oro y nivel 2→3 cuesta 35. El nivel/stats aumentan una sola vez; tope o fondos insuficientes dejan nivel y saldo intactos.
- Cada enemigo derrotado paga una sola vez el `EnemyData.kill_reward`, también si la muerte procede de DoT. Un enemigo que llega a base no paga recompensa de baja. Repetir callbacks no duplica el pago.
- La recompensa de `WaveData.round_reward` solo se paga una vez cuando acabaron los spawns y no queda enemigo activo. Si una baja ya pagó y luego la oleada falla, esa recompensa por baja se conserva, pero no se concede el bonus de limpieza.
- Una torre con `mana_cost_per_attack` descuenta maná antes de cada impacto; con saldo insuficiente no ejecuta daño/status, no genera saldo negativo y muestra estado sin maná en el debug de la torre seleccionada. Una torre sin coste de maná no consulta ni consume el saldo.
- El maná regenera en preparación, combate, recompensa y expansión; no supera `maximum_mana` y se detiene en setup/derrota/victoria. No existe una fuente de maná de Support Building.
- Al terminar una ronda de campaña, `RunManager` entra a `ROUND_REWARD` durante 0.8 s: no se puede iniciar otra oleada, comprar ni colocar terreno. Después pasa a `TERRAIN_EXPANSION` y ofrece tres piezas; construcción se habilita al elegir una, y la siguiente ronda solo se desbloquea al confirmar una pieza válida.
- Los costes, recompensas y tasas actuales son fixtures configurables y provisionales, no balance confirmado.

### Prueba manual de M9 en el juego
1. Ejecutar `game/main/main.tscn`. El HUD debe mostrar **Oro 150 · Maná 100 / 100**. Al pasar el cursor por el maná, el tooltip debe indicar **3 maná cada 2 s**. La barra inferior debe indicar los costes de los siete atajos `1–7`.
2. Pulsar `1` y colocar Ballista en una casilla Grass libre. El oro pasa a 120, la celda queda ocupada y aparece una sola torre. Seleccionarla y mejorarla: el saldo pasa a 100 al llegar a nivel 2 y a 65 al llegar a nivel 3; los stats cambian según el nivel y el botón deja de ofrecer otra mejora. Repetir clic sobre la torre o un terreno no construible no debe cobrar.
3. Iniciar **Ronda 01/20 · normal · 3 enemigos**. El oro sube +5 por cada enemigo derrotado, una vez por baja, y al terminar todos los spawns con cero enemigos activos sube +20 una sola vez. Si todos mueren, desde los 65 restantes debe terminar en 100. El aviso de recompensa y el saldo tienen que coincidir.
4. Reiniciar la escena para disponer otra vez del perfil inicial. Construir tres Drenadoras M7 en celdas construibles próximas al camino (por ejemplo `(1,-1)`, `(1,0)` y `(0,1)`); deben costar 40 cada una usando la tecla `9`. Con los 30 oro restantes, intentar construir la Sonda M8 de 40 (tecla `0`): el preview/HUD explica que faltan fondos, el atajo se deshabilita y el oro se conserva en 30. Pulsar `Esc` para salir del preview rechazado antes de cambiar la oleada.
5. Abrir F3, elegir **DEBUG · objetivo de estados M8** e iniciar la prueba. Con tres Drenadoras, el saldo de maná debe bajar en pasos de 4 por disparo mientras hay objetivo. Al llegar a cero, la torre seleccionada muestra **sin maná** y deja de disparar; su ataque no reduce HP ni aplica nuevos estados y el maná no queda negativo. Este diagnóstico no puede dañar la base ni pagar recompensas.
6. Completar la ronda real actual para observar el maná en `TERRAIN_EXPANSION`: debe regenerarse a la tasa base (equivalente a 3 maná cada 2 s) hasta 100 y nunca superar ese máximo. Los diagnósticos M7/M8 no pagan bonus; una ronda de campaña limpia paga su `round_reward` una vez.
7. Durante el instante posterior a una victoria, comprobar que aparece `ROUND_REWARD`; el botón de oleada/selector y la colocación permanecen bloqueados esos 0.8 s, y luego se habilitan al entrar en expansión.
8. (Opcional, comprueba fallo de campaña) No construir torres durante las rondas reales y dejar que la base llegue a cero. Debe entrar `RUN_DEFEAT`; la ronda fallida no paga bonus de limpieza, aunque se conservan bajas ya recompensadas. Las pruebas DEBUG no dañan la base ni pueden forzar esta derrota.

Para dar M9 por aceptado deben pasar todos los criterios de la sección y la prueba manual debe confirmar saldos y mensajes en pantalla, cobros atómicos, pago único por evento, rechazo sin fondos, bloqueo de disparos sin maná y regeneración acotada. La prueba debe incluir una llegada a base para verificar que no se confunde con una baja; el bonus de ronda se comprueba aparte. El smoke/validación automática de gameplay queda pendiente; la prueba descrita es interactiva.

## Roster jugable M9.5
- La barra principal muestra los siete perfiles en orden. Los valores iniciales de coste/ataque/H/A/S se validan ahora en M12A; M9.5 conserva el requisito de acceso por botón/tecla y terreno legal, pero los precios históricos 30/80/70/50/65/65/100 ya no aplican.
- Los atajos `1–7` seleccionan el mismo perfil que el botón y permiten construir solo en Grass/Montaña libre. PATH, terreno ocupado o saldo insuficiente no cobran ni crean torre. Cada una de las siete formas placeholder debe distinguirse en el mapa.
- Ballista solo daña el objetivo elegido. Mortar lanza un proyectil y afecta a enemigos agrupados dentro de su radio al aterrizar; Frost también afecta en área y refresca Slow.
- Tesla descarga sobre todos los enemigos válidos dentro del alcance circular, gasta 5 maná por ataque y no daña/aplica estado si el saldo no alcanza.
- Flame daña a los enemigos del cono frontal y aplica Burn; Poison hace lo mismo con su tag Poison y aplica el estado Poison. El aro verde Poison aparece y los ticks pasan por `DamageService` y `EnemyData.poison_damage_multiplier`.
- Shredder lanza la hoja desde la torre hasta la posición actual del objetivo, luego avanza por sus waypoints restantes hacia la base. Cada enemigo en el recorrido recibe un impacto como máximo; cada impacto posterior pierde 1 de daño base. Cada contacto hace daño directo y añade Bleed por el 100% del daño base restante de la hoja; prueba la interacción con H/A/S en el fixture M12A.
- Las torres con maná gastan el coste indicado por disparo; al quedar sin saldo esperan y vuelven a atacar al regenerar. Las torres sin coste no lo consumen.
- Los perfiles M7/M8 de diagnóstico siguen disponibles en `8` (Perforadora), `9` (Drenadora) y `0` (Sonda); no ocupan botones del roster principal.
- Daño, costes, RPM, radios, cono, multiplicadores y efectos restantes son configurables. Las cifras compartidas se validan en M12A; la capa Shield ya forma parte del modelo.

### Prueba manual M9.5 en el juego
1. Abrir `game/main/main.tscn`. Confirmar los siete botones y probar los atajos `1–7`; el perfil elegido y su nombre deben coincidir. En el tooltip revisar rol, coste, patrón y coste de maná.
2. Reiniciar la escena entre perfiles para recuperar el oro inicial. Construir cada torre cerca del camino y verificar el coste que muestre el botón, el color y la silueta. La tabla de costes ya no es la antigua configuración M9.
3. Ejecutar **Ronda 01/20 · normal · 3 enemigos**. Ballista debe seguir un único objetivo; Mortar debe mostrar impacto en el objetivo y afectar al menos otro enemigo si están dentro del radio; Tesla debe alcanzar a todos los enemigos dentro de su alcance circular; Frost debe ralentizar y afectar a enemigos dentro de su área.
4. Probar Flame y Poison sobre enemigos alineados delante de la torre. El cono solo aplica estado a enemigos dentro del ángulo y rango; verificar aros Burn naranja y Poison verde, y que el HP cae por ticks equivalentes al 100% del daño base por aplicación. En Poison, el diagnóstico debe identificar `veneno`, no `arcano`.
5. Reiniciar, abrir F3, seleccionar **DEBUG · objetivo de estados M8** y construir Shredder (`7`) a rango del objetivo. Iniciar la oleada: la hoja debe llegar a la posición del objetivo y seguir sus waypoints restantes. Al contactar, debe aplicar daño directo y Bleed equivalente al 100% del daño base restante de la hoja. Para comprobar perforación, usar la ronda 01/20 con varios enemigos vivos en el mismo trazado; cada enemigo debe recibir un impacto y Bleed, el segundo con 1 menos de daño base. En M12A se desglosa cada componente usando HP por capas.
6. Dejar que las torres Tesla/Frost/Flame/Poison gasten su maná. Cuando falte, confirmar que se bloquean sin infligir impacto ni aplicar nuevos estados; esperar regeneración y confirmar que reanudan fuego. Ballista, Mortar y Shredder no deben gastar maná.
7. Usar `8`, `9` y `0` para comprobar que los fixtures M7/M8 siguen seleccionables sin aparecer como parte de las siete torres finales.

M9.5 queda aceptado cuando pasan todos los criterios y se observa cada perfil en la ventana del juego. La implementación está en código; la revisión visual/interactiva todavía está pendiente. Registrar cualquier ajuste de balance como provisional.

## M10 Rondas 1–20

- La opción inicial es **Ronda 01/20**; el selector muestra 20 recursos consecutivos e identifica normal/minijefe/jefe Tier 2. No se puede iniciar una ronda posterior ni saltarse el número actual.
- `WaveDirector` muestra `pendientes` y `en ruta` por separado. Si termina el último spawn pero quedan enemigos, la ronda sigue en `COMBAT`; si muere o llega a base el último enemigo pero quedan spawns pendientes, también continúa. La limpieza y recompensa solo suceden cuando el generador terminó y ambos recuentos llegan a cero.
- Las recompensas por baja se otorgan una vez por muerte; la recompensa de ronda se concede una vez por limpieza. Una llegada a base no da oro y un fallo no cobra la recompensa de ronda.
- Durante `ROUND_REWARD` no se inicia combate, no se compra y no se coloca terreno. Al pasar 0.8 s se abre `TERRAIN_EXPANSION`; en rondas M11 programadas, `CARD_OFFER` aparece después de la colocación y antes de la siguiente preparación.
- En expansión se muestran exactamente tres piezas distintas como cards visuales: cada una contiene solo el título y una vista dibujada de sus hexes, sin conteos, estadísticas ni texto auxiliar. Al elegir una, las tres cards pasan al inventario inferior, la seleccionada queda resaltada y aparece el ghost; se puede pulsar otra card para cambiar la pieza sin perder la oferta. `Esc` o «Volver a cartas» muestra la misma oferta centrada. Una posición ilegal o cancelación no avanza la ronda ni modifica el tablero. Tras confirmar una pieza legal se añaden sus siete hexes, desaparece el inventario, el grafo se actualiza y después la siguiente ronda vuelve a `ROUND_PREP`.
- En campaña, cada pulso genera un enemigo simultáneo en cada endpoint PATH abierto con ruta alcanzable. `count` representa pulsos por salida; el total inicial pendiente/HUD es la suma de `count × endpoints alcanzables`. El intervalo separa pulsos completos, no enemigos de rutas distintas.
- Tras colocar una pieza, las celdas interiores totalmente encerradas se rellenan al azar como Grass o Montaña construible. No se rellenan celdas exteriores ni huecos conectados a una salida PATH abierta; el grafo sigue siendo válido.
- Al mover una pieza por una posición válida, el ghost muestra el futuro del spawn antes de confirmar: los endpoints que siguen se marcan `SIGUE`, los nuevos `NUEVO` y los que desaparecerían `CIERRA`, con flecha hacia el camino. El resumen indica el número actual→futuro y altas/cierres. Una posición cuyo grafo candidato es inválido no habilita confirmar ni muestra endpoints como futuros; el grafo/tablero actuales siguen intactos.
- Las caras de hex no muestran `G`, `M`, `P` ni coordenadas. Hover ilumina según PATH/Grass/Montaña y el panel F3 muestra `(q,r)`, tipo y altura. Un cluster conectado de 3–4 Grass/Montaña brilla suavemente; uno de 5+ brilla un poco más. No concede bonus de stats/economía.
- La base cubre exactamente la cara superior de un hexágono completo en `(0,0)` y no sobresale hacia casillas vecinas.
- Las rondas 17 y 19 identifican un minijefe placeholder más grande; la 20 identifica un jefe Tier 2 provisional. Al limpiar la ronda 20, entra a `RUN_VICTORY`, muestra demo completada y bloquea combate, construcción y terreno. Variante, poderes y cifras finales siguen pendientes.
- Al comparar objetivos de ronda inicial y avanzada, `EnemyData` de campaña muestra HP máximo/daño escalados. Los archivos base `.tres` no cambian al instanciar enemigos.
- `DEBUG · blindado regenerador` y `DEBUG · objetivo de estados M8` pueden repetirse en preparación/expansión; dejan igual fase y número de campaña y no cambian oro ni vida de base. Estos nombres y reglas sustituyen las instrucciones anteriores de repetición de fixtures.
- El balance, colores y radios de los enemigos de campaña son placeholders. No se usan números ni habilidades de las tablas comunitarias de `docs/borradores_personales/02_monstruos.md`.

### Prueba manual M10 en el juego
1. Iniciar una run nueva. Confirmar **Ronda 01/20**, inicio habilitado y sin ghost de terreno. El tablero inicial debe contener 19 celdas (radio axial 2); la base ocupa una cara hexagonal completa en `(0,0)`. Verificar que la ruta desde el único spawn hasta la base tenga cuatro celdas PATH y que cualquier expansión que proponga un spawn con ruta menor a cuatro se rechace. Ninguna cara muestra letras/coordenadas; el hover ilumina PATH/Grass/Montaña y F3 informa coordenadas, tipo y altura. Anotar la orientación del camino de entrada, iniciar otra run nueva y confirmar que gira exactamente 60°; repetir hasta observar las seis orientaciones y comprobar que las conexiones PATH se mantienen válidas.
2. Iniciar la ronda 1. Observar `pendientes` y `en ruta`; el fin/recompensa no aparecen al llegar a cero los pendientes si aún queda un enemigo. Completar la ronda y verificar que solo entonces se paga y empieza la transición.
3. Antes de iniciar y después de cada expansión, comprobar que cada salida abierta alcanzable tiene el portal `SPAWN` con flecha hacia el PATH aunque `D` esté apagado. Activar `D` para ver las rutas correspondientes y confirmar que cada marcador coincide con un endpoint. Iniciar una ronda con más de una salida abierta: en cada pulso deben aparecer enemigos en todos esos puntos a la vez. El total anunciado y el contador pendiente deben coincidir con la suma de pulsos por salida; el intervalo se mide entre esos grupos simultáneos.
4. Durante `ROUND_REWARD`, intentar iniciar ronda, construir/mejorar torre y colocar terreno; la campaña y el terreno siguen bloqueados. Al pasar 0.8 s debe abrirse una oferta centrada de exactamente tres cards de terreno, sin duplicados. Cada card muestra solo nombre y vista visual de la pieza. Elegir una: las tres cards deben pasar al inventario inferior, con la pieza seleccionada resaltada; pulsar otra debe cambiar el ghost. Mover el ghost por una posición válida: antes de confirmar, el mapa marca en verde `NUEVO` los spawns que abrirá, en cian `SIGUE` los que mantiene y con una X roja `CIERRA` los que elimina; el texto muestra el cambio de cantidad. Rotar o mover el ghost actualiza la comparación; una posición inválida conserva los marcadores actuales y deshabilita confirmar. Pulsar `Esc`: vuelve la misma oferta centrada y no se pierde la ronda. Elegir de nuevo y colocar en una posición inválida; el tablero y el contador no cambian. Colocar después una posición legal conectada: desaparecen las cards y los spawns visibles deben coincidir con los marcadores `NUEVO`/`SIGUE` previsualizados; la siguiente fase es la oferta M11 cuando corresponda, o `ROUND_PREP` en las demás rondas.
5. Repetir el loop y buscar una colocación que cierre un hueco interior. El área queda cubierta con Grass o Montaña; al pasar el cursor F3 confirma tipo/altura y se permite construir allí. Los huecos conectados al exterior y las salidas PATH abiertas siguen vacíos; no aparece error del `PathGraph` ni desaparece un spawn.
6. Observar un grupo conectado de 3–4 Grass/Montaña y uno de 5 o más. Deben brillar de forma leve, con el cluster mayor algo más visible; PATH no debe brillar y no se concede ningún bonus numérico.
7. Al llegar a 17 y 19, el selector/HUD debe marcarlas como minijefe y el placeholder destacar por tamaño/color. En ronda 20 aparece el jefe Tier 2 provisional, después del grupo normal. No inferir balance final por sus estadísticas actuales.
8. Limpiar ronda 20: debe mostrarse **¡DEMO COMPLETADA! · 20/20**, cambiar a `RUN_VICTORY` y deshabilitar selector, botón de combate, compra/mejora y colocación de terreno.
9. Antes de avanzar desde la primera ronda, abrir F3 y usar ambos perfiles `DEBUG`. Deben completar y devolver a la fase previa, sin cambiar contador de campaña, oro o vida de base ni dejar enemigos vivos. Si se ejecutan desde expansión, la oferta de terreno se conserva. Verificar que después se puede continuar la campaña normal.
10. Comparar HP máximo de un enemigo normal de ronda 1 con uno de ronda avanzada que siga vivo en su primera barra de salud; se observa el crecimiento gradual. El perfil base de `EnemyData` debe conservar los valores de su Resource.

M10 queda aceptado cuando se verifican todos los criterios y el flujo completo hasta `RUN_VICTORY` en ventana de juego. La implementación de código está documentada; la revisión interactiva está pendiente. Ninguna cifra provisional confirma balance.

## M11 Cartas de mejora
- Después de colocar una expansión de las rondas 1 y 2, la fase pasa directamente a `ROUND_PREP`; no aparece una carta de mejora fuera del calendario.
- Después de colocar la expansión de las rondas 3, 6, 9, 12, 15 o 18, `RunManager` entra a `CARD_OFFER` antes de `ROUND_PREP`. La oferta muestra exactamente tres cartas distintas con título, rareza y efecto descrito. No duplica opciones dentro de una misma oferta.
- Hasta elegir una carta se mantienen bloqueados inicio de ronda, construcción, mejora y colocación. `Esc`/clic derecho no descartan ni saltan la elección. Tras seleccionar una, se aplican sus efectos y se habilita una sola vez la siguiente ronda.
- Las definiciones viven en Resources. Seleccionar una carta no cambia ningún `TowerData`, `StatusEffectData`, economía de arranque ni archivo `.tres` compartido. Las cartas específicas de torre requieren el ID desbloqueado correspondiente; las cartas globales no requieren unlock.
- Daño plano/multiplicador, alcance, radio de área, coste de maná, duración de estado, capacidad/regeneración de maná, crítico y multiplicadores H/A/E afectan el gameplay y la lectura de stats/preview que corresponda. Se aplican también a torres construidas antes de elegir la carta. Las cartas no alteran el RPM fijo; Frost Keep solo gana RPM por cobertura PATH.
- Las ofertas futuras excluyen cartas que llegaron a `max_per_run`; las no elegidas siguen disponibles. Una escena/run nueva reinicia las selecciones. Los efectos no persisten entre runs (la persistencia y unlocks guardados son M12).
- Los números y el calendario de oferta son provisionales y centralizados en `.tres`; no se derivan del balance comunitario de Rogue Tower.

### Prueba manual M11 en el juego
1. Ejecutar `game/main/main.tscn` y jugar la campaña normal. Limpiar y expandir las rondas 1 y 2: tras cada colocación debe comenzar la preparación siguiente sin aparecer panel de mejoras.
2. Antes de completar la ronda 3, construir Ballista en Grass y anotar el daño mostrado en su resumen. Completar la ronda y colocar una pieza de terreno válida. Ahora, antes de que se habilite ronda 4, debe aparecer la fase `CARD_OFFER` con tres cartas. Verificar títulos, descripciones/efectos, rarezas y que los tres botones sean clicables; comprobar que no se puede iniciar la oleada ni construir mientras está abierta. `Esc` no debe saltarse la elección.
3. Si aparece **Disparo calibrado**, seleccionarlo: la expansión ya está colocada, el panel desaparece y se habilita la ronda 4; al seleccionar la Ballista ya construida, su resumen debe mostrar 2 de daño adicional. Si no aparece esa carta, repetir la run; no hace falta editar recursos.
4. En runs sucesivas, elegir **Depósito de maná** y comprobar que la capacidad HUD sube 20 sin llenar instantáneamente el saldo; **Flujo constante** aumenta la regeneración 0,5/s; **Circuitos eficientes** reduce el coste por ataque en un 15 %. Para una mejora de estado, seleccionar la carta del estado/torre correspondiente y usar el fixture M8 para comprobar su mayor duración. Alcance y área deben reflejar el stat correspondiente en preview/resumen y comportamiento de ataque. Comprobar en otras ofertas las tres cartas de multiplicador H/A/E descritas abajo.
5. Alcanzar la siguiente oferta (ronda 6). La carta elegida antes no puede aparecer de nuevo con el máximo actual de una copia; las opciones no elegidas sí pueden volver a aparecer. Cerrar y abrir una run nueva debe quitar los efectos y reiniciar el límite por run.

M11 queda aceptado cuando se verifican la frecuencia provisional y el orden expansión→carta→siguiente ronda, bloqueo hasta selección, tres opciones válidas, filtro de unlocks/límites por run y al menos un efecto verificable de cada familia afectada (incluido un multiplicador H/A/E), sin mutar recursos compartidos. El gameplay y la UI todavía requieren esta aceptación manual; no se ha ejecutado Godot en la revisión de implementación.

## M12 Meta-progresión
- Una nueva instalación crea `user://rogue_tower_meta.json` con versión 1, 0 de moneda y Ballista desbloqueada. La moneda meta nunca cambia al construir torres ni se confunde con el oro de la run.
- Una derrota de campaña y la victoria de ronda 20 terminan la run, otorgan meta-moneda una sola vez y muestran el resumen con resultado, ronda, recompensa, saldo total y seed. Los fixtures DEBUG no finalizan ni recompensan una run.
- Con la configuración demo, la recompensa es `5 + 5 × rondas completas`, más 30 por victoria, con tope 1000: perder en la ronda 1 da 5; perder durante la ronda 2 tras completar la 1 da 10; completar la demo da 135. Progresar más da una recompensa superior que repetir únicamente una derrota en la primera ronda.
- La tienda deja comprar torres y niveles permanentes solo con saldo suficiente. El coste se resta una sola vez; un elemento ya desbloqueado/nivel máximo no se vuelve a cobrar. Si falla el guardado, la compra se revierte.
- Tras comprar una torre, «Empezar nueva run» inicia una run sin cartas/efectos temporales anteriores, mantiene el unlock, muestra la torre en la barra y habilita sus cartas específicas M11. Las torres bloqueadas no aparecen en la barra y `BuildController` rechaza su construcción aunque se invoque desde otro acceso.
- Comprueba al menos una mejora de cada familia persistente: «Fondo de campaña» da +20 oro inicial por nivel; «Reserva de maná» +15 de capacidad por nivel; «Manantial» +0,25 maná/s por nivel; «Calibración de torres» multiplica daño ×1,05 por nivel. Deben aplicarse a una run nueva, sin mutar `.tres` ni sobrevivir los modificadores M11 de la run anterior.
- Comprar «Archivo de cartas» añade al pool dos cartas globales identificadas por `meta:card_archive`; sin la compra no aparecen, y la compra debe persistir tras cerrar y volver a abrir el juego.
- `SaveData` contiene solo primitivas, versión y progreso estable. Un archivo corrupto o con versión distinta no se sobrescribe automáticamente; se muestra el error y se deshabilitan compras, conservando el archivo para recuperación. Los guardados normales conservan una copia `.bak` antes de reemplazarse.

### Prueba manual M12 en el juego
1. Ejecuta `game/main/main.tscn` con un guardado nuevo. Comprueba que la barra ofrece Ballista como único perfil de demo y que el HUD muestra oro/maná de run, separados de cualquier meta-moneda.
2. Para comprobar el mínimo de 5 en derrota de ronda 1, reduce temporalmente `max_health` a 20 en `data/base/base_data.tres` en una copia de trabajo. La ronda inicial tiene tres enemigos de 10 de daño a base; déjalos pasar y confirma que el resumen indica derrota `1/20`, `+5 moneda meta`, saldo total 5 y seed. Restaura `max_health = 50` al terminar esta comprobación. Si no quieres tocar el fixture, la primera derrota natural será probablemente durante ronda 2 y deberá pagar 10.
3. Con el fixture restaurado, inicia una nueva run y deja pasar la ronda 1 completa; después deja caer la base durante la ronda 2. El resumen debe otorgar 10 (5 base + 5 por una ronda completa), dejando 15 en total. Esto confirma que progresar paga más que una derrota temprana.
4. Con esos 15, compra Mortero en la tienda y pulsa «Empezar nueva run». Mortero debe aparecer en la barra, permitir construcción y habilitar su carta específica; la moneda meta debe conservar el coste descontado aunque cierres y vuelvas a abrir el juego. Comprueba que las demás torres aún bloqueadas no aparecen.
5. Compra un nivel de «Fondo de campaña» y una mejora de cada una de las familias mana/daño cuando haya saldo. En la run siguiente compara el oro inicial, capacidad, regeneración y daño esperado de Ballista con el valor base de `data/run/run_economy_m9.tres`/`data/towers/ballista.tres`: solo el runtime debe cambiar. Comprar «Archivo de cartas» habilita «Filos bruñidos» y «Canalización» en una futura oferta de ronda 3; sin comprarlo siguen filtradas.
6. Verifica saldo insuficiente y máximos: la tienda no cobra, no aumenta niveles ni desbloquea contenido. Abre F3 para iniciar una run de diagnóstico y confirma que completarla no aumenta el contador/recompensa meta ni altera el número de campaña.
7. Para probar migración, conserva una copia externa del JSON y, en una copia de trabajo, cambia solo `version` a `0` o elimínalo. El juego debe cargar los campos reconocidos, reescribir versión 1 y conservar el formato anterior en `.bak`; un valor JSON como `1.0` también debe cargar sin bloqueo. Como ruta de error, prueba JSON inválido o `version: 999`: el juego debe iniciar en fallback sin sobrescribir el archivo incompatible, mostrar la explicación y bloquear compras hasta recuperar un guardado válido.
8. Completa la ronda 20 en una run de aceptación: el resultado es victoria, el bonus se aplica una sola vez y la recompensa configurada es 135. Volver a pulsar o duplicar el evento de final no vuelve a sumarla.

M12 queda aceptado al comprobar las dos salidas de run, fórmula creciente, aislamiento DEBUG, compras transaccionales, unlocks consumidos por gameplay/cartas, upgrades efectivos en runs posteriores y persistencia/error seguro después de reiniciar. La jerarquía visual de interfaz se valida por separado en M13. Costes/valores siguen siendo provisionales.

## M12A Reglas de torres y capas de vida

- La oleada `DEBUG · capas escudo/armadura/vida` contiene un objetivo con 40 Shield, 60 Armor y 120 Health, regeneración 1/s por capa y barra segmentada visible. Los valores se consumen Shield→Armor→Health; la barra conserva los colores Shield azul, Armor beige, Health verde y actualiza sus segmentos al recibir daño/curación.
- El perfil Ballista inicial muestra 10 de daño, H/A/E 10/5/5, rango 5, 20 RPM, sin maná y precio 10. Comparar los otros seis Resources contra la tabla de `11_INITIAL_CONTENT_PLACEHOLDERS.md`: Mortar 20/10-15-5/10/10/200(+75); Tesla 10/6-3-10/1.5/30/5/ataque/200(+75); Frost 6/10-5-5/2/180 iniciales/2/s/250(+100); Flame 5/6-9-3/4/60/1/ataque/300(+75); Poison 5/6-3-9/4/60/1/ataque/300(+75); Shredder 10/20-10-10/5/5/0/500(+100). Desbloquearlos en tienda meta antes de probarlos. Costes de upgrade provisionales por perfil: Ballista/Mortar 10(+10), Tesla/Frost 20(+20), Flame/Poison/Shredder 30(+30), en línea con las páginas comunitarias consultadas.
- Seleccionar una torre muestra daño, H/A/E, alcance, RPM, crítico, XP H/A/E y maná. Una elevación de terreno suma +1 al daño base y +0.5 de alcance por nivel. El Frost suma 18 RPM por cada PATH cubierto por el rango cuadrado; los otros perfiles no cambian su RPM.
- El precio de la primera Ballista es 10, segunda 25, tercera 40; demoler una reduce el siguiente coste según el conteo actual. La demolición no devuelve oro en este prototipo. Intentar comprar o mejorar sin fondos no cobra ni muta la torre.
- Las tres prioridades se aplican en orden; cada opción secundaria solo desempata la anterior. Repetir una misma opción muestra rechazo/restaura el selector. Validar progreso, menor HP de capa activa, máximo/mínimo H/A/E y velocidad.
- Una mejora manual cobra el coste del siguiente nivel, añade +1 al daño base y +1 a la capa elegida (botones `+ Vida`, `+ Armadura`, `+ Escudo`). El nivel máximo bloquea los tres botones. Para una comprobación rápida de XP, duplicar un `TowerData` local, poner `targeting_xp_required_per_level = 1`, sostener un enemigo en rango y comprobar que gana +1 daño base y +1 a la capa activa; no modificar los Resources versionados del perfil definitivo. Restaurar la copia después.
- Críticos empiezan en 0%. Al conseguir una oferta de carta, `Cantidad sobre calidad` suma 15 puntos porcentuales globales y `Bobina sobrecargada` 15 a Tesla. `Estudios de vida`, `Estudios de armadura` y `Estudios de escudo` suman +1 al multiplicador de esa capa para todas las torres. El resumen debe reflejar los críticos y los tres modificadores H/A/E. Las tiradas muestran de manera aleatoria ×2/×3/×4 según bandas de chance; si no sale la carta, repetir oferta/run.
- Ballista mueve un proyectil hasta su objetivo. Mortar lanza un shell y al aterrizar daña todo enemigo en el radio, sin depender de estar agrupados al disparar. Tesla descarga sobre todos los enemigos en su alcance circular; Frost cubre una zona cuadrada y ralentiza al 50%; Flame y Poison afectan solo al cono frontal, aplican 100% del daño base como Burn/Poison y sus ticks pasan por `DamageService`; Shredder pega directamente, aplica Bleed por el 100% del daño base restante y pierde 1 de daño base en cada enemigo atravesado.
- Para comprobar el cambio de capa sin interferencia de regeneración, en una copia local poner a 0 las tres regeneraciones del `tower_layer_training_dummy.tres`. Un impacto Ballista de 10×5 debe consumir como máximo los 40 Shield y dejar Armor/Health intactos; el siguiente golpe solo afecta Armor y Health no recibe daño hasta agotarse Armor. Restaurar las tres regen en 1/s. Con Bleed/Burn/Poison activos, confirmar que se detiene regen de Health/Armor/Shield, respectivamente.
- El test DEBUG no paga oro, no daña la base ni avanza número de campaña. Al salir del diagnóstico, la campaña y sus Resources conservan su estado.

### Prueba manual M12A en el juego

1. Ejecutar `game/main/main.tscn`, desbloquear varios perfiles en la tienda al disponer de moneda meta y construir una Ballista. Seleccionarla y comparar su resumen con el perfil anterior; debe indicar 20 RPM. Durante combate, medir el tiempo entre dos disparos consecutivos de la Ballista con el mismo objetivo continuamente en rango: debe ser 3 s (20 disparos/minuto); medir el flash o evento de lanzamiento, porque el proyectil viaja después del disparo. Usar `1–7` después de desbloquear las otras torres para confirmar las siete filas de stats.
   - En la ronda 1, sin mejoras, crítico ni elevación, confirma que un proyectil de Ballista elimina al Asaltante básico: 10 de daño base × 10 al Health = 100 contra sus 100 Health. Si el objetivo tiene Armor o Shield, el impacto debe afectar primero esa capa y respetar el multiplicador de la Ballista para ella.
2. Construir tres Ballistas (precios 10/25/40), seleccionar una y pulsar `Demoler`. Comprueba que no devuelve oro y que el precio visible de la próxima Ballista baja al nivel que corresponde al conteo restante.
3. Seleccionar la Ballista restante y comprar `+ Escudo`. Debe cobrar el precio indicado, subir un nivel, subir daño base en 1 y solo el multiplicador Shield en 1. Repetir con otro HP type en una torre/nivel posterior. Los botones se deshabilitan en el máximo o sin saldo.
4. Abrir F3, elegir `DEBUG · capas escudo/armadura/vida`, iniciar y observar el enemigo. Sus segmentos deben empezar azul/beige/verde; pasar los valores actuales en el inspector técnico. Con la copia de regen=0, confirmar que solo cae Shield al principio; después Armor; Health al final. Restaurar regen=1/s y comprobar cada capa se regenera. No conservar modificaciones temporales.
5. Construir un Frost Keep y colocar/enlazar celdas PATH adicionales dentro del cuadrado de alcance; su RPM del resumen debe crecer en 18 por cada PATH adicional y su área debe alcanzar objetivos dentro de ese cuadrado. Las demás torres mantienen RPM base aunque se amplíe el mapa.
6. Probar las prioridades 1–3 con varios enemigos y un empate deliberado en el primer criterio; el siguiente debe resolverlo. Dos criterios iguales no pueden quedar activos simultáneamente.
7. Comprobar los proyectiles Ballista/Mortar, la explosión AoE del Mortar, el impacto de Tesla sobre todos los enemigos en alcance, los efectos de cono y ticks al 100% de Flame/Poison, Slow cuadrado y Shredder directo+Bleed/perforación. Verificar que sin maná Tesla/Frost/Flame/Poison esperan; Ballista/Mortar/Shredder no consumen.
8. Alcanzar ofertas M11 y seleccionar, en runs sucesivas, `Estudios de vida`, `Estudios de armadura` y `Estudios de escudo`; comprobar que el multiplicador correspondiente aumenta en todas las torres existentes y construidas después. Obtener también `Cantidad sobre calidad` o `Bobina sobrecargada`, confirmar el crítico en stats y observar impactos con multiplicador variable. Cada carta puede requerir otra run por su peso de oferta.

M12A queda aceptado cuando barra/daño por capas, stats de los siete perfiles, precio incremental/demolición, los dos caminos de upgrade, tres prioridades, crítico, comportamiento diferencial y counters de regeneración pasan en ventana Godot. La implementación de código está documentada; todavía no se ha ejecutado este procedimiento ni se ha hecho inspección visual.

## M13 UX/UI

- La vista normal presenta tres paneles: recursos compactos arriba a la izquierda, ronda/progreso/inicio arriba al centro y torre seleccionada arriba a la derecha. El título «RogueTower» no aparece. La vida de base se muestra en una barra con el valor actual/máximo dentro; el oro usa un icono y tamaño visual mayores que el maná. El progreso distingue rondas completadas, actual y pendientes; al limpiar una ronda el segmento pasa al color de completada, y 17/19/20 se reconocen como encuentros especiales.
- El selector de perfiles de oleada y la lectura técnica continua del objetivo no ocupan la vista normal: aparecen dentro del panel F3. Abrir/cerrar F3 no altera la fase ni los saldos; `H` oculta y restaura paneles, barra de torres y panel técnico. La navegación con rueda y botón central continúa funcionando con el HUD visible/oculto.
- Seleccionar una torre muestra en el panel derecho nivel, daño, H/A/E, alcance, RPM, crítico, patrón, icono de energía si consume y XP por capa. El panel hace scroll si el contenido supera su altura. Hover y selección muestran el radio y un contorno distinto. Un solo menú checkable permite hasta tres prioridades distintas; al deseleccionar la torre o pulsar fuera del tablero, desaparece el panel.
- Cada objeto tiene su PNG RGBA transparente independiente en `game/ui/icons/` (256×256); no existe un atlas compartido. Los atajos inferiores son cuadrados con sprite grande, nombre y precio con icono de moneda; el sprite es idéntico al preview y a la torre colocada. La UI sustituye por iconos las menciones a oro/maná en textos enriquecidos. Las cards específicas muestran la torre afectada; las cards de terreno conservan el contrato M10.
- Los enemigos muestran un marco de vida con carriles de escudo y armadura sobre una vida fragmentada; los iconos de capa identifican cada carril. Los estados activos aparecen encima y solo muestran cifra cuando hay varias acumulaciones. Cada impacto hace destellar y saltar al enemigo, y presenta daño flotante coloreado según escudo, armadura o salud. El efecto no cambia el cálculo de `DamageService`.
- Al derrotar la base, el overlay terminal identifica claramente derrota; al superar la ronda 20 identifica victoria. Ambos resumen ronda alcanzada, rondas completas, recompensa y saldo total de moneda meta; la seed queda en tooltip técnico.
- En la tienda, `TORRES` y `MEJORAS` son categorías independientes. Cada fila muestra nombre, descripción, coste/estado y acción; saldo insuficiente o guardado bloqueado impide comprar y no cambia el progreso. «Empezar nueva run» conserva las compras, recarga el tablero y aplica los niveles permanentes.
- A 1440×900, el HUD principal, el panel F3, la barra de siete torres y las ofertas no se recortan ni bloquean la lectura del mapa. La tienda terminal se adapta al área visible y, si una categoría excede su altura, se puede recorrer con scroll vertical.

### Prueba manual M13 en el juego

1. Abre `game/main/main.tscn` en la ventana de 1440×900. Comprueba que no hay título «RogueTower» y que se ven los tres paneles: barra de vida con su valor dentro e iconos de recursos a la izquierda; número/estado de ronda, veinte segmentos y botón «Iniciar ronda» centrados; panel derecho inicialmente oculto. El icono y la cifra del oro deben destacar sobre los del maná. El tooltip del maná debe expresar su regeneración sin decimales. Inicia y limpia una ronda: el primer segmento queda completado y el siguiente pasa a activo.
2. Confirma que el HUD normal no presenta el selector de fixtures ni la línea técnica del enemigo. Abre `F3`: deben aparecer selector de rondas/pruebas, coordenada axial/terreno, preview y rotación, además del inspector de objetivo. Si la torre consume maná, su coste en el inspector debe usar el icono PNG junto a la cantidad. Cierra F3 y confirma que desaparecen los datos técnicos. Pulsa `H`, mueve/zoomea el tablero, vuelve a pulsar `H` y comprueba que la interfaz vuelve sin haber cambiado la cámara ni la ronda.
3. Construye Ballista en Grass/Montaña. El botón cuadrado, el preview del cursor y la torre colocada deben mostrar la misma Ballista. Pasa el cursor sobre ella: aparece su radio y contorno; selecciónala y comprueba un contorno de selección más marcado. Haz clic en una casilla vacía y confirma que el panel desaparece.
4. Selecciona cada torre disponible en la barra. Comprueba icono grande arriba, nombre debajo y cifra de precio junto al icono de moneda. Con oro insuficiente, los atajos afectados deben estar deshabilitados y verse atenuados, incluidos sus iconos y textos; tras ganar oro suficiente se activan. Pasa el cursor por una torre colocada y seleccionada para comparar radio/contorno; confirma que el click fuera limpia selección. En el resumen lateral deben aparecer iconos de vida, armadura y escudo junto a sus multiplicadores y XP. En una torre seleccionada, abre Criterios: selecciona uno, luego dos y tres criterios; intenta un cuarto y confirma que no se activa. Desmarca y reordena prioridades; los checks deben coincidir con los criterios usados. Revisa que el panel lateral pueda desplazarse sin cortar textos ni controles, y que los botones de mejora muestran iconos de vida/armadura/escudo y moneda.
5. Usa F3 para elegir la oleada de diagnóstico de capas H/A/E, coloca una torre que pueda impactar y empieza la prueba. Sobre el enemigo debe verse escudo arriba, armadura debajo y salud fragmentada; las barras y sus iconos deben leerse a simple vista y ser mayores que la versión anterior. Observa impactos en cada fase de la barra: el enemigo parpadea/salta y los números son cian para escudo, ámbar para armadura y rojo para salud. El valor debe corresponder al daño que realmente aplicó el juego.
6. Repite con la oleada de estados M8 y torres de frío, fuego, veneno o Shredder. El símbolo PNG del estado activo aparece encima de la barra sin una placa o fondo opaco, ampliado y con transparencia; no debe verse un rectángulo detrás. Para un estado acumulable, aplica al menos dos acumulaciones y comprueba que aparece su cifra; al expirar, icono y cifra desaparecen. Verifica que estado y barra acompañan al enemigo durante su movimiento.
7. Obtén una card específica de una torre durante la run: la card incluye el sprite de esa torre. Elige cartas con descripciones que aumenten o consuman oro/maná y confirma que aparecen los iconos en línea; no debe quedar el nombre textual de esas monedas en los elementos enriquecidos.
8. Repite una run hasta derrota dejando llegar enemigos a la base. La tienda debe presentar derrota, ronda, rondas completas, recompensa y saldo meta. Cambia entre TORRES y MEJORAS: solo se ve la lista activa con descripción/coste/estado. Compra una opción asequible y confirma el saldo nuevo; con saldo insuficiente no debe cobrarse. «Empezar nueva run» debe conservar las compras. Completa la campaña hasta 20/20 para revisar la variante de victoria.
9. A 1280×720 y 1440×900, repite HUD, F3, panel lateral, barra inferior y cards. Los controles deben permanecer legibles, panel lateral y tienda desplazables y sin bloquear el mapa ni recortar nombres, precios o cifras.

M13 queda aceptado cuando los nueve puntos anteriores pasan en una ventana Godot y se comprueba que la interfaz guía acciones normales sin requerir DEBUG, mantiene sprites consistentes, comunica estado/capas/daño con iconos y animación, conserva F3 y permite operar prioridades, upgrades y tienda sin ambigüedad. En esta revisión se implementó el código y se actualizaron los documentos; la inspección visual y esta prueba manual siguen pendientes.

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
