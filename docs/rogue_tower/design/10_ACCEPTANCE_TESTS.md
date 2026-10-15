# Acceptance Tests

> **Vigencia M61:** cualquier criterio histórico de M7–M13 que pida abrir o conservar el panel F3 quedó sustituido. El juego ya no contiene ese panel ni un selector runtime de oleadas DEBUG; usa el apartado M61 para la aceptación vigente de HUD y controles de terreno.

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
- El tablero de campaña coloca la base en PATH `(-1,0)` y usa el camino recto `(-1,0) → (0,0) → (1,0) → (2,0)`, con salida exterior `(3,0)`; una base ausente invalida el grafo.
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
- Grass = 1 o 2; Mountain = 2 o 3.
- Las alturas construibles se vuelven a sortear con el seed de cada run/oferta y no cambian entre card, ghost y tablero confirmado.
- Una torre de altura h recibe +h de daño base y +0.5 × h de alcance; su insignia numérica aparece únicamente al hacer hover y muestra el bonus de daño.
- La fachada, hover, preview y selección siguen funcionando en desniveles de hasta tres niveles.
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
- Cada llegada aplica `EnemyData.base_damage`; si llega un enemigo con `boss_tier > 0`, la run termina inmediatamente aunque reste Health.
- La base comienza con 10/10 HP; Fortification permanente añade hasta +10 HP y las cards Fortification I–III dan +3 HP cada una de forma independiente.
- Durante `COMBAT` no se puede colocar terreno; derrota bloquea la expansión y victoria de la muestra habilita `TERRAIN_EXPANSION`.
- Smoke M5 histórico: su fixture terminaba con 20/50 HP y cero enemigos activos. Esa cifra no describe la vida inicial actual, que es 10 HP.
- Enemy llega a base y causa daño.
- Tower adquiere target y lo daña.
- Armor/health/regen alteran el resultado.
- Status expira correctamente.
- Matar enemigo entrega recompensa una vez.

## M6 Towers

> Se conserva este procedimiento como registro del prototipo `Basic Bolt`. El perfil ahora se llama `Basic Bolt (DEBUG)` y el roster visible vigente está en M9.5; estos pasos ya no son la aceptación manual actual de la interfaz. Sigue las pruebas M9.5/M12A/M13 para comprobar las torres y el HUD activos.

- `Basic Bolt` carga desde `TowerData`; ID, daño, cadencia, alcance, terreno permitido, prioridades y mejoras están configurados en Resource.
- Regla histórica de M6: el prototipo permitía build mode en `TERRAIN_EXPANSION`. ADR-0061 sustituyó ese permiso: el runtime vigente solo permite construir en `ROUND_PREP` y `COMBAT`; también bloquea `RUN_SETUP`, `TERRAIN_EXPANSION`, `CARD_OFFER` y `RUN_DEFEAT`.
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

## M7 Damage model (histórico, fórmula sustituida por M12A)

M7 registró el primer `DamageService`, los `DamagePacket` y una fórmula plana de Armor/Health. Esa fórmula, las cifras contra `Armored Regenerator`, el inspector F3 y su procedimiento manual ya no describen el juego: M12A define el daño actual por capas, M61 retiró F3 y M64 eliminó la oleada/dummy M7. Se conserva este hito solo como historial; no ejecutar ni usar sus cifras como criterio vigente. Las estructuras compartidas de combate siguen en `DamageService` y se aceptan con los criterios M12A y las rondas activas.

## M8 Status Effects

Las reglas de estados implementadas siguen vigentes: `StatusEffectData` valida payloads; `TowerData.status_effects` configura efectos sin mutar Resources; REFRESH conserva una acumulación y reinicia duración; ADD_STACKS acumula hasta el límite; Slow cambia la velocidad real; Burn/Bleed pasan sus ticks por `DamageService`; muerte o llegada a base limpia efectos y señales. No hay resistencia de estado definida en el diseño. Los valores provisionales viven en los Resources y ADR-0012, no en una oleada de test.

La oleada `m8_status_test` y `status_training_dummy.tres` se retiraron en M64. Para una revisión visual actual, usar un enemigo de campaña y el perfil Status Probe accesible con `0`; comprobar iconos, acumulaciones, movimiento y ticks sin asumir la composición ni los valores del dummy retirado. La aceptación automatizada de reglas internas debe usar los smokes existentes o una futura prueba que instancie Resources activos, no recrear una opción de selector DEBUG.

## M9 Economy + Mana
- Fixture histórico de M9: su perfil de prueba inicia con 150 Gold, 100/100 Mana y regen interna de 1.5/s. La economía de campaña vigente empieza con 1.000 Gold y Starting Coffers puede elevarlo a 2.000; véase M35. El tooltip del Mana expresa tasas como equivalencias enteras sin alterar el valor runtime.
- El Gold de construcción es runtime de esta run y no altera `MetaProgression.meta_currency` (XP de perfil) ni se persiste.
- Los siete perfiles principales y sus costes aparecen en la barra según sus Resources: Ballista 10, Mortar 200, Tesla Coil 200, Frost Keep 250, Flame Thrower 300, Poison Sprayer 300 y Shredder 500 Gold, antes de incrementos por cantidad y mejoras de run. Los atajos `8`, `9` y `0` mantienen Armor Piercing Bolt/Sapping Bolt/Status Probe a 40 Gold; Sapping Bolt indica 4 Mana por ataque.
- Una construcción legal cobra una sola vez antes de ocupar la celda. Terreno inválido, casilla ocupada o saldo insuficiente no cobran ni crean torre/ocupación.
- Una mejora cobra `TowerData.get_upgrade_cost(nivel_actual)`: en los fixtures M9, nivel 1→2 cuesta 20 Gold y nivel 2→3 cuesta 35. El nivel/stats aumentan una sola vez; tope o fondos insuficientes dejan nivel y saldo intactos.
- Cada enemigo derrotado paga una sola vez el `EnemyData.kill_reward`, también si la muerte procede de DoT. Un enemigo que llega a base no paga recompensa de baja. Repetir callbacks no duplica el pago.
- La recompensa de `WaveData.round_reward` solo se paga una vez cuando acabaron los spawns y no queda enemigo activo. Si una baja ya pagó y luego la oleada falla, esa recompensa por baja se conserva, pero no se concede el bonus de limpieza.
- Una torre con `mana_cost_per_attack` descuenta Mana antes de cada impacto; con saldo insuficiente no ejecuta daño/status, no genera saldo negativo y muestra el estado sin Mana en Tower Info. Una torre sin coste de Mana no consulta ni consume el saldo.
- El Mana regenera en preparación, combate, recompensa y expansión; no supera `maximum_mana` y se detiene en setup/derrota/victoria. No existe una fuente de Mana de Support Building.
- Al terminar una ronda de campaña, `RunManager` entra a `ROUND_REWARD` durante 0.8 s: no se puede iniciar otra oleada, comprar ni colocar terreno. Después pasa a `TERRAIN_EXPANSION` y ofrece tres piezas; torre/construcción, cofres e inicio de ronda siguen bloqueados durante la oferta y colocación. Al confirmar una pieza válida, pasa a `ROUND_PREP` y se habilita la construcción para la siguiente ronda.
- Los costes, recompensas y tasas actuales son fixtures configurables y provisionales, no balance confirmado.

### Prueba manual de M9 en el juego
1. Iniciar una run desde el menú. Registrar Gold y Mana iniciales desde la configuración activa; no esperar el valor de fixture histórico M9 (150/100) ni una oleada de test. El tooltip de Mana debe reflejar la tasa configurada y la barra de torres debe mostrar solo el roster reclutado.
2. Construir Ballista en una casilla legal. El coste visible y el saldo deben diferir por el precio configurado del Resource; la celda se ocupa y aparece una única torre. Mejorarla: cada compra cobra una vez y actualiza nivel/stats según el Resource; tope o fondos insuficientes no cobran. Una casilla inválida tampoco cobra.
3. Completar una ronda activa. Cada baja paga su `kill_reward` como máximo una vez y la limpieza paga el `round_reward` solo cuando no quedan spawns/enemigos; comparar el saldo con el aviso y la composición real de `WaveData`, sin usar cantidades de un fixture antiguo.
4. Con una torre que tenga coste de Mana y esté disponible en la run, comprobar que cada ataque descuenta el coste del Resource y que, al no alcanzar el saldo, no ejecuta daño/estados ni permite saldo negativo. Tower Info debe mostrar «sin Mana»; una torre sin coste no consume Mana.
5. Observar la regeneración en las fases donde está permitida: no supera el máximo efectivo, se detiene en setup/derrota/victoria y reanuda según las reglas de la fase. La ronda entra en `ROUND_REWARD` durante 0,8 s, bloquea acciones y después ofrece expansión.
6. Repetir con rondas de campaña y comprobar que una llegada a base no paga recompensa de baja; una ronda fallida no concede bonus de limpieza, aunque conserva bajas ya recompensadas. La campaña no se reinicia ni avanza por usar los perfiles de torre de diagnóstico `8`, `9` y `0`.

Para dar M9 por aceptado deben pasar todos los criterios de la sección y la prueba manual debe confirmar saldos y mensajes en pantalla, cobros atómicos, pago único por evento, rechazo sin fondos, bloqueo de disparos sin Mana y regeneración acotada. La prueba debe incluir una llegada a base para verificar que no se confunde con una baja; el bonus de ronda se comprueba aparte. El smoke/validación automática de gameplay queda pendiente; la prueba descrita es interactiva.

## Roster jugable M9.5
> Estos criterios de acceso describen la etapa anterior al reclutamiento de M35. El combate de cada perfil sigue siendo comprobable al reclutarlo; en una run normal solo Ballista está disponible al comenzar. Ver M35.
- La barra principal muestra los siete perfiles en orden. Los valores iniciales de coste/ataque/H/A/S se validan ahora en M12A; M9.5 conserva el requisito de acceso por botón/tecla y terreno legal, pero los precios históricos 30/80/70/50/65/65/100 ya no aplican.
- Los atajos `1–7` seleccionan el mismo perfil que el botón y permiten construir solo en Grass/Mountain libre. PATH, terreno ocupado o saldo insuficiente no cobran ni crean torre. Cada una de las siete formas placeholder debe distinguirse en el mapa.
- Ballista solo daña el objetivo elegido. Mortar lanza un proyectil y afecta a enemigos agrupados dentro de su radio al aterrizar; los copos de Frost pueden fallar y cada contacto daña a un único enemigo y añade Slow proporcional al daño aplicado.
- Tesla descarga sobre todos los enemigos válidos dentro del alcance circular, gasta 5 Mana por ataque y no daña/aplica estado si el saldo no alcanza.
- Flame daña a los enemigos del cono frontal y aplica Burn; Poison hace lo mismo con su tag Poison y aplica el estado Poison. El aro verde Poison aparece y los ticks pasan por `DamageService` y `EnemyData.poison_damage_multiplier`.
- Shredder lanza la hoja desde la torre hasta la posición actual del objetivo, luego avanza por sus waypoints restantes hacia la base. Cada enemigo en el recorrido recibe un impacto como máximo; cada impacto posterior pierde 1 de daño base. Cada contacto hace daño directo y añade Bleed por el 100% del daño base restante de la hoja; prueba la interacción con H/A/S en el fixture M12A.
- Las torres con Mana gastan el coste indicado por disparo; al quedar sin saldo esperan y vuelven a atacar al regenerar. Las torres sin coste no lo consumen.
- Los perfiles de diagnóstico siguen disponibles en `8` (Armor Piercing Bolt), `9` (Sapping Bolt) y `0` (Status Probe); no ocupan botones del roster reclutable ni tienen oleadas DEBUG asociadas desde M64.
- Daño, costes, RPM, radios, cono, multiplicadores y efectos restantes son configurables. Las cifras compartidas se validan en M12A; la capa Shield ya forma parte del modelo.

### Prueba manual M9.5 en el juego
1. Iniciar una run desde el menú. La disponibilidad de los siete botones/atajos es histórica y está reemplazada por el roster de run descrito en M35; tras reclutar una torre, probar su botón/atajo y revisar rol, coste, patrón y coste de Mana.
2. Reiniciar la escena entre perfiles para recuperar el Gold inicial. Construir cada torre cerca del camino y verificar el coste que muestre el botón, el color y la silueta. La tabla de costes ya no es la antigua configuración M9.
3. Ejecutar una ronda de campaña adecuada para observar ataques contra uno o varios objetivos. Ballista debe seguirlo; Mortar debe mostrar su impacto; Tesla debe alcanzarlo dentro de su alcance circular; los copos Frost deben caer sobre PATH y ralentizar solo al enemigo que toquen. Para confirmar impactos de área y cadenas sobre varios objetivos, usar la Ronda 07 (22 enemigos directos) u otra composición activa equivalente.
4. Probar Flame y Poison sobre enemigos alineados delante de la torre. El cono solo aplica estado a enemigos dentro del ángulo y rango; verificar aros Burn naranja y Poison verde, y que el HP cae por ticks equivalentes al 100% del daño base por aplicación. En Poison, el diagnóstico debe identificar `veneno`, no `arcano`.
5. Construir Shredder (`7`) cerca de una ruta de campaña con varios objetivos. Iniciar la ronda: la hoja debe llegar a la posición actual del objetivo y seguir sus waypoints restantes. Cada contacto aplica daño directo y Bleed por el 100% del daño base restante; cada impacto posterior pierde 1 de daño base. En M12A se desglosan las capas de daño.
6. Dejar que las torres Tesla/Frost/Flame/Poison gasten su Mana. Cuando falte, confirmar que se bloquean sin infligir impacto ni aplicar nuevos estados; esperar regeneración y confirmar que reanudan fuego. Ballista, Mortar y Shredder no deben gastar Mana.
7. Si están disponibles, usar `8`, `9` y `0` para comprobar que los perfiles de diagnóstico siguen seleccionables y funcionales sin aparecer como parte del roster reclutable. No existe un selector de oleadas de diagnóstico.

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
- Confirmar el perfil Frost: daño base 6, 180 RPM más 18 por PATH cubierto, Slow de 50% del daño aplicado con cap 60 y decaimiento 6/s, y 2 Mana/s durante combate. Confirmar que los copos no causan daño ni Slow si no hay contacto. Tesla Coil inicia con daño 9; las mejoras de carta pueden cambiar el resultado runtime y los Resources compartidos no deben mutarse.
- Los perfiles de torre de diagnóstico `8`, `9` y `0` no permiten elegir/repetir oleadas ni alteran el orden secuencial de la campaña.
- Verificar victoria al limpiar ronda 45; después se deshabilitan inicio, selector, construcción/mejora y colocación. Las recompensas de limpieza de las rondas 21–45 son provisionales según ADR-0037.

### Prueba manual M10 en el juego

1. Iniciar una run nueva y confirmar Ronda 01/45, el tablero inicial de 19 celdas, base en `(-1,0)` y camino recto por `(-1,0) → (0,0) → (1,0) → (2,0)` hasta la salida `(3,0)`. Confirmar cuatro celdas PATH en cada ruta y mantener la inspección previa de orientación, terreno y preview.
2. En cada oleada muestreada, comparar los grupos visibles/activos con la tabla de la ronda. Verificar que dos o más endpoints no multipliquen la cantidad anunciada y que la distribución alterne rutas.
3. En una oleada con grupos espaciados, comprobar que pendientes llega a cero antes de que la ronda termine si aún hay enemigos vivos. Probar también muerte/llegada a base mientras quedan grupos pendientes.
4. Completar varias rondas y expansiones, incluyendo una ronda con oferta M11. Verificar bloqueo de acciones entre fases y orden expansión→carta→siguiente ronda.
5. En cada oferta, comprobar que una card está marcada `EXTIENDE RUTA` y que su ghost empieza en una posición/rotación legales guardadas. La pieza sugerida debe variar entre recta, curva y bifurcación; cuando la elegida no sea recta, las otras cards no deben introducir una recta. Confirma que conecta con una ruta existente, aumenta su longitud y deja otra opción legal para la expansión siguiente. Para las otras cards, mueve y gira el ghost hasta una posición que bloquearía toda futura prolongación: debe verse inválido, explicar el motivo y no permitir confirmar.
6. Elige una pieza con obstáculos visibles y compara la miniatura, el ghost durante el movimiento/rotación y el tablero tras confirmar: cada obstáculo debe quedar en el mismo hex. La miniatura y el ghost no muestran cofres; el contenido de obstáculos de la oferta se conserva al volver a ella.
7. Previsualiza una posición que cierre uno o más spawns. Los portales afectados deben quedarse visibles en su ubicación y mostrar una X roja; el texto debe indicar claramente cuántos se cerrarían. Al cancelar, los portales activos recuperan su estado normal. No debe ser posible confirmar una posición que deje cero opciones legales para alargar la ruta.
7. En la ronda 24, observar el jefe Ooogie von Ooogovich, las invocaciones, la transición a Bat y la espera del contador/recompensa hasta la derrota final.
8. Inspeccionar al menos un enemigo que mira a cada lado del eje horizontal. El sprite debe voltearse solo al moverse hacia la izquierda y volver a su orientación original hacia la derecha.
9. Abrir el inspector técnico y seleccionar Frost Keep y Tesla Coil. Comparar daño, RPM, Slow y duración con el perfil documentado; comprobar que sus modificadores runtime se reflejan sin cambiar los Resources.
10. Repetir una prueba de expansión desde preparación. La oferta/campaña conserva su estado al cancelar y reabrir la colocación según las reglas actuales.
11. Completar la ronda 45 y confirmar 45/45, RUN_VICTORY, una sola recompensa de limpieza, sin expansión posterior y sin acciones de combate/construcción disponibles.

La implementación de campaña, recursos, perfiles, habilidades y sprites está integrada. El arranque headless se comprobó en esta revisión; la aceptación completa de gameplay/arte requiere completar los pasos interactivos anteriores en la ventana del juego.


## M11 Cartas de mejora
- Después de colocar una expansión de las rondas 1 y 2, la fase pasa directamente a `ROUND_PREP`; no aparece una carta de mejora fuera del calendario.
- Después de colocar la expansión de cada ronda múltiplo de tres entre 3 y 42, `RunManager` entra a `CARD_OFFER` antes de `ROUND_PREP`. La oferta muestra exactamente tres cartas distintas, con título, rareza y efecto descrito; el panel solo deja seleccionar esos tres botones. Si hay torres elegibles sin reclutar, siempre hay al menos una carta de reclutamiento y nunca más de dos; los otros espacios se sortean por peso entre cartas elegibles. Las cartas no elegidas siguen disponibles en ofertas futuras. Tras la 45 no hay carta porque la run termina.
- Hasta elegir una carta se mantienen bloqueados inicio de ronda, construcción, mejora y colocación. `Esc`/clic derecho no descartan ni saltan la elección. Tras seleccionar una, se aplican sus efectos y se habilita una sola vez la siguiente ronda.
- Las definiciones viven en Resources. Seleccionar una carta no cambia ningún `TowerData`, `StatusEffectData`, economía de arranque ni archivo `.tres` compartido. Las cartas específicas de torre requieren unlock permanente y reclutamiento durante la run; las cartas de reclutamiento aparecen para torres desbloqueadas que aún no están en el roster. Las cartas globales no requieren unlock.
- Las 173 entradas compatibles de referencia y las 18 cartas propias se representan con 190 IDs únicos: 172 Resources nuevos y la Advanced Circuits propia, que ya ejecuta el mismo efecto. Sus familias incluyen daño plano/multiplicador, alcance por elevación, área, Mana, estados/caps/sinergias, críticos, H/A/S, economía y base. Las cartas de torre se filtran por unlock permanente, roster reclutado y prerequisitos; los efectos elegidos afectan también a torres construidas previamente, no mutan Resources compartidos y no alteran RPM fijo; Frost Keep solo gana RPM por cobertura PATH.
- Las ofertas futuras excluyen cartas que llegaron a `max_per_run`; las no elegidas siguen disponibles. Una escena/run nueva reinicia las selecciones. Los efectos no persisten entre runs (la persistencia y unlocks guardados son M12).
- La frecuencia cada tres rondas está confirmada por ADR-0062. Números, rarezas y tamaño base siguen configurables/provisionales y no se presentan como balance aprobado de Rogue Tower.

### Prueba manual M11 en el juego
1. Ejecutar `game/main/main.tscn` y jugar la campaña normal. Limpiar y expandir las rondas 1 y 2: tras cada colocación debe comenzar la preparación siguiente sin aparecer panel de mejoras.
2. Antes de completar la ronda 3, construir Ballista en Grass y anotar el daño mostrado en su resumen. Completar la ronda y colocar una pieza de terreno válida. Ahora, antes de que se habilite ronda 4, debe aparecer `CARD_OFFER` con tres cartas. Verificar títulos, descripciones/efectos, rarezas y botones; no se puede iniciar ni construir mientras está abierta. El panel dispone de seis ranuras, pero muestra tres por defecto: la oferta no debe descartarse por no llenar todas las ranuras. Si Mortar y Tesla Coil siguen desbloqueadas y sin reclutar, debe mostrarse al menos una de ellas, no ambas son obligatorias y no pueden ocupar las tres opciones. `Esc` no debe saltarse la elección.
3. Si aparece **Disparo calibrado**, seleccionarlo: la expansión ya está colocada, el panel desaparece y se habilita la ronda 4; al seleccionar la Ballista ya construida, su resumen debe mostrar 2 de daño adicional. Si no aparece esa carta, repetir la run; no hace falta editar recursos.
4. En runs sucesivas, elegir **Depósito de Mana** y comprobar que la capacidad HUD sube 20 sin llenar instantáneamente el saldo; **Flujo constante** aumenta la regeneración 0,5/s; **Circuitos eficientes** reduce el coste por ataque en un 15 %. Para una mejora de estado, seleccionar la carta del estado/torre correspondiente y usar el fixture M8 para comprobar su mayor duración. Alcance y área deben reflejar el stat correspondiente en preview/resumen y comportamiento de ataque. Comprobar en otras ofertas las tres cartas de multiplicador H/A/S descritas abajo.
5. Alcanzar la siguiente oferta (ronda 6). La carta elegida antes no puede aparecer de nuevo con el máximo actual de una copia; las opciones no elegidas sí pueden volver a aparecer. Comprobar el mismo flujo al menos en rondas 9 y 42, y confirmar que tras completar la 45 se abre la tienda sin una oferta temporal adicional. Una run nueva quita efectos y reinicia el límite por run.

M11 queda aceptado cuando se verifican la frecuencia confirmada y el orden expansión→carta→siguiente ronda, bloqueo hasta selección, exactamente tres botones visibles y seleccionables, filtro de unlocks/prerrequisitos/límites y al menos un efecto de cada familia afectada (incluidos estados, Gold, Mana, base y H/A/S), sin mutar recursos compartidos. El ID legado Card Draw no aparece en la tienda ni cambia la oferta. La distribución M66 tiene criterios propios al final de esta página.

## M12 Meta-progresión
> Los criterios de barra con las tres torres simultáneas y la tienda terminal por pestañas son históricos. M35 define el roster por run, el menú separado y el mapa permanente de nodos; conserva de esta sección la persistencia, XP y economía meta.
- Una nueva instalación crea `user://rogue_tower_meta.json` con versión 1, 0 XP de perfil y Ballista, Mortar y Tesla Coil desbloqueadas. El XP nunca cambia al construir torres ni se confunde con el Gold de la run.
- Una derrota de campaña y la victoria al limpiar ronda 45 terminan la run, otorgan XP de perfil una sola vez y muestran el resumen con resultado, ronda, recompensa, saldo total y seed. Los perfiles de torre de diagnóstico no añaden oleadas ni interrumpen la secuencia de campaña.
- Con la configuración demo, la recompensa es `5 + 5 × rondas completas`, más 30 por victoria, con tope 1000: perder en la ronda 1 da 5; perder durante la ronda 2 tras completar la 1 da 10; completar las 45 rondas da 260. Progresar más da una recompensa superior que repetir únicamente una derrota en la primera ronda.
- La tienda deja comprar torres y niveles permanentes solo con saldo suficiente. El coste se resta una sola vez; un elemento ya desbloqueado/nivel máximo no se vuelve a cobrar. Si falla el guardado, la compra se revierte.
- Tras comprar una torre, «Empezar nueva run» mantiene el unlock y permite que aparezca como card de reclutamiento; no la añade directamente a la barra. Solo Ballista está disponible al inicio; una torre sin reclutar no se puede construir. Ver M35.
- Comprueba al menos una mejora de cada familia persistente: «Fondo de campaña» da +20 Gold inicial por nivel; «Reserva de Mana» +15 de capacidad por nivel; «Manantial» +0,25 Mana/s por nivel; «Calibración de torres» multiplica daño ×1,05 por nivel. Deben aplicarse a una run nueva, sin mutar `.tres` ni sobrevivir los modificadores M11 de la run anterior.
- Comprar «Archivo de cartas» añade al pool dos cartas globales identificadas por `meta:card_archive`; sin la compra no aparecen, y la compra debe persistir tras cerrar y volver a abrir el juego.
- `SaveData` contiene solo primitivas, versión y progreso estable. Un archivo corrupto o con versión distinta no se sobrescribe automáticamente; se muestra el error y se deshabilitan compras, conservando el archivo para recuperación. Los guardados normales conservan una copia `.bak` antes de reemplazarse.

### Prueba manual M12 en el juego
1. En el menú, inicia run con un guardado nuevo. Comprueba que solo Ballista aparece construible; Mortar y Tesla Coil son desbloqueos permanentes iniciales, se reclutan con las cards de la primera oferta programada y pasan a la barra tras elegirlas. M35 reemplaza los demás criterios de UI de esta etapa.
2. Para comprobar el mínimo de 5 XP en derrota de ronda 1, cambia temporalmente `max_health` a 1 en `data/base/base_data.tres` dentro de una copia de trabajo. La ronda inicial contiene un enemigo con 1 de daño a base; déjalo pasar y confirma que el resumen indica derrota en ronda `1/45`, `+5 XP de perfil`, saldo total 5 y seed. Restaura `max_health = 10` al terminar esta comprobación.
3. Para comprobar la recompensa de derrota tras completar una ronda, cambia temporalmente `max_health` a 5 en la misma copia, inicia una nueva run y deja pasar los enemigos de las rondas 1 y 2: la ronda 1 tiene uno y la ronda 2 cuatro, cada uno con 1 de daño a base. La base debe caer durante la ronda 2 y el resumen otorgar 10 (5 base + 5 por una ronda completa), dejando 15 en total. Restaura `max_health = 10` al acabar.
4. Con al menos 50 XP, compra Frost Keep en la tienda y pulsa iniciar run. Frost Keep queda habilitada para aparecer como card de reclutamiento, pero solo entra en la barra tras elegir esa card; el XP conserva el coste descontado al reiniciar. Las torres bloqueadas permanentemente no se ofrecen.
5. Compra un nivel de Treasury y una mejora disponible de cada familia: Mana Capacity, Sourcery, daño, Gold por baja, salud/reparación de base y H/A/S de torre cuando estén desbloqueadas. Desde la nueva run compara Gold/Mana, daño y stats afectados; la oferta sigue mostrando tres opciones. `card_draw` no aparece en la tienda y se conserva únicamente como ID legado. El Archivo de cartas habilita «Filos bruñidos» y «Canalización» en una futura oferta; sin comprarlo siguen filtradas.
6. Verifica saldo insuficiente y máximos: la tienda no cobra, no aumenta niveles ni desbloquea contenido. Abre F3 para iniciar una run de diagnóstico y confirma que completarla no aumenta el contador/recompensa meta ni altera el número de campaña.
7. Para probar migración, conserva una copia externa del JSON y, en una copia de trabajo, cambia solo `version` a `0` o elimínalo. El juego debe cargar los campos reconocidos, reescribir versión 1 y conservar el formato anterior en `.bak`; un valor JSON como `1.0` también debe cargar sin bloqueo. Como ruta de error, prueba JSON inválido o `version: 999`: el juego debe iniciar en fallback sin sobrescribir el archivo incompatible, mostrar la explicación y bloquear compras hasta recuperar un guardado válido.
8. Completa la ronda 45 en una run de aceptación: el resultado es victoria, el bonus se aplica una sola vez y la recompensa configurada es 260. La tienda muestra las 30 mejoras comprables; el catálogo conserva el ID legado Card Draw, que no aparece como nodo. Las ramas de torres bloqueadas no se pueden comprar hasta desbloquear la torre. Volver a pulsar o duplicar el evento de final no vuelve a sumar recompensas.

M12 queda aceptado al comprobar las dos salidas de run, fórmula creciente, aislamiento DEBUG, compras transaccionales, unlocks consumidos por gameplay/cartas, upgrades efectivos en runs posteriores y persistencia/error seguro después de reiniciar. La jerarquía visual de interfaz se valida por separado en M13. Costes/valores siguen siendo provisionales.

## M12A Reglas de torres y capas de Health

- El modelo de cada enemigo contiene Health, Armor y Shield; el perfil configura los tres máximos y cero desactiva una capa para esa unidad. Los perfiles de campaña con varias capas muestran sus filas visibles. Los valores se consumen Shield→Armor→Health; la barra conserva los colores Shield azul, Armor beige, Health verde y actualiza sus segmentos al recibir daño/curación. La oleada/dummy de entrenamiento con valores fijos se retiró en M64.
- El perfil Ballista inicial muestra 10 de daño, H/A/S 10/5/5, rango 5, 20 RPM, sin Mana y precio 10. Comparar los otros seis Resources contra la tabla de `11_INITIAL_CONTENT_PLACEHOLDERS.md`: Mortar 20/10-15-5/10/10/200(+75); Tesla 9/6-3-10/2/30/5/ataque/200(+75); Frost 6/10-5-5/2/180 iniciales/2 Mana/s/250(+100); Flame 6/6-9-3/4/60/1/ataque/300(+75); Poison 5/6-3-9/4/60/1/ataque/300(+75); Shredder 10/20-10-10/5/5/0/500(+100). Desbloquearlos en tienda meta antes de probarlos. Costes de upgrade provisionales por perfil: Ballista/Mortar 10(+10), Tesla/Frost 20(+20), Flame/Poison/Shredder 30(+30), en línea con las páginas comunitarias consultadas.
- Seleccionar una torre muestra daño, H/A/S, alcance, RPM, crítico, XP H/A/S y Mana. Una elevación de terreno suma +1 al daño base y +0.5 de alcance por nivel. El Frost suma 18 RPM por cada PATH cubierto por el rango cuadrado; los otros perfiles no cambian su RPM.
- El precio de la primera Ballista es 10, segunda 25, tercera 40; demoler devuelve el precio marginal del slot ocupado según M27/ADR-0064 y reduce el siguiente coste; el nivel de la torre no altera la devolución. Intentar comprar o mejorar sin fondos no cobra ni muta la torre.
- Las prioridades se aplican en orden y se revelan con `+`; cada opción secundaria solo desempata la anterior. Repetir una misma opción muestra rechazo/restaura el selector. Validar progreso, menor HP de capa activa, máximo/mínimo H/A/S y velocidad.
- Una mejora manual cobra el coste del siguiente nivel, añade +1 al daño base y +1 a la capa elegida (botones `+ Health`, `+ Armor`, `+ Shield`). El nivel máximo bloquea los tres botones. Para una comprobación rápida de XP, duplicar un `TowerData` local, poner `targeting_xp_required_per_level = 1`, sostener un enemigo en rango y comprobar que gana +1 daño base y +1 a la capa activa; no modificar los Resources versionados del perfil definitivo. Restaurar la copia después.
- Críticos empiezan en 0%. Al conseguir una oferta de carta, `Impulso crítico global` suma 15 puntos porcentuales globales y `Advanced Circuits` 15 a Tesla. `Foco de Health`, `Foco de Armor` y `Foco de Shield` suman +1 al multiplicador de esa capa para todas las torres. El resumen debe reflejar los críticos y los tres modificadores H/A/S. Las tiradas muestran de manera aleatoria ×2/×3/×4 según bandas de chance; si no sale la carta, repetir oferta/run.
- Ballista mueve un proyectil hasta su objetivo. Mortar lanza un shell y al aterrizar daña todo enemigo en el radio, sin depender de estar agrupados al disparar. Tesla descarga sobre todos los enemigos en su alcance circular; Frost deja caer copos sobre PATH dentro de una zona cuadrada, cada copo daña a un único enemigo al contacto y aplica Slow igual al 50% del daño; Flame y Poison afectan solo al cono frontal, aplican 100% del daño base como Burn/Poison y sus ticks pasan por `DamageService`; Shredder pega directamente, aplica Bleed por el 100% del daño base restante y pierde 1 de daño base en cada enemigo atravesado.
- Comprobar la transición de capa con un perfil de campaña con Shield y Armor: Ballista debe consumir primero Shield, luego Armor y finalmente Health. Verificar en `EnemyData` los máximos/regeneraciones configurados y confirmar que el combate no muta el Resource compartido. Con Bleed/Burn/Poison activos, comprobar la supresión de regeneración de Health/Armor/Shield, respectivamente. Un ataque directo recibe +1 una sola vez al multiplicador de la capa asociada al estado; el tick no recibe ese bonus y usa su daño por capa configurado (100% en la asociada, 50% en las otras).
- Los antiguos test DEBUG no están disponibles desde M64; no hay que seleccionar ni preservar oleadas de entrenamiento. Los perfiles de torre `8`, `9` y `0` siguen siendo atajos de diagnóstico sin selector de oleada.

### Prueba manual M12A en el juego

1. Ejecutar `game/main/main.tscn`, desbloquear varios perfiles en la tienda al disponer de XP de perfil y construir una Ballista. Seleccionarla y comparar su resumen con el perfil actual; debe indicar 20 RPM. Durante combate, medir el tiempo entre dos disparos consecutivos de la Ballista con el mismo objetivo continuamente en rango: debe ser 3 s (20 disparos/minuto); medir el flash o evento de lanzamiento, porque el proyectil viaja después del disparo. Usar `1–7` después de desbloquear las otras torres para confirmar las siete filas de stats.
   - En la ronda 1, sin mejoras, crítico ni elevación, confirma que un proyectil de Ballista elimina al Goblin: 10 de daño base × 10 al Health = 100 contra sus 100 Health. Si el objetivo tiene Armor o Shield, el impacto debe afectar primero esa capa y respetar el multiplicador de la Ballista para ella.
2. Construir tres Ballistas (precios 10/25/40), seleccionar una y pulsar `Demoler`. Comprueba que devuelve el precio marginal del slot y que el precio visible de la próxima Ballista baja al conteo restante, según M27/ADR-0064.
3. Seleccionar la Ballista restante y comprar la mejora `Shield`. Debe cobrar el coste de Shield, subir solo Shield en 1 y añadir +1 al daño base y +1 al multiplicador Shield. Health y Armor conservan su nivel y XP. Comprar después Health y confirmar que Shield no cambia. Las barras muestran progreso/XP propios y los costes usan el nivel de su propia capa.
4. Iniciar una ronda activa que incluya un enemigo de campaña con varias capas. Comprobar que las filas azul/beige/verde aparecen solo para las capas existentes y caen en el orden Shield→Armor→Health; comparar máximos y regeneración con su `EnemyData`. No editar Resources compartidos para esta prueba.
5. Construir un Frost Keep y colocar/enlazar celdas PATH adicionales dentro del cuadrado de alcance; su RPM del resumen debe crecer en 18 por cada PATH adicional y los copos deben caer sobre celdas PATH de ese cuadrado. Las demás torres mantienen RPM base aunque se amplíe el mapa.
6. Probar las prioridades ordenadas con varios enemigos y empates: abrir Prioridad 2 y 3 con `+`; la segunda solo resuelve el empate de la primera y la tercera el empate restante. No se permiten criterios duplicados; elegir una prioridad ya usada debe intercambiar su posición con el criterio desplazado.
7. Comprobar los proyectiles Ballista/Mortar, la explosión AoE del Mortar, el impacto de Tesla sobre todos los enemigos en alcance, los efectos de cono y ticks al 100% de Flame/Poison, Slow Frost solo por contacto y Shredder directo+Bleed/perforación. Verificar que sin Mana Frost no lanza copos y que su drenaje sea 2/s durante combate; Tesla/Flame/Poison esperan su siguiente ataque; Ballista/Mortar/Shredder no consumen.
8. Alcanzar ofertas M11 y seleccionar, en runs sucesivas, `Foco de Health`, `Foco de Armor` y `Foco de Shield`; comprobar que el multiplicador correspondiente aumenta en todas las torres existentes y construidas después. Obtener también `Impulso crítico global` o `Advanced Circuits`, confirmar el crítico en stats y observar impactos con multiplicador variable. Cada carta puede requerir otra run por su peso de oferta.

M12A queda aceptado cuando barra/daño por capas, stats de los siete perfiles, precio incremental/demolición, los dos caminos de upgrade, prioridades ordenadas, crítico, comportamiento diferencial y counters de regeneración pasan en ventana Godot. La progresión individual detallada en M20 tiene su propio criterio manual. La implementación de código está documentada; todavía no se ha ejecutado este procedimiento ni se ha hecho inspección visual.

## M13 UX/UI
> La selección simultánea de siete torres, el timeline fijo de 45 puntos y las pestañas de la tienda terminal son descripciones históricas. La interfaz vigente de acceso, tienda, pausa, resumen y ventana móvil se acepta en M35.

- El HUD activo se actualizó en M22: salud/atajos arriba a la izquierda, Gold/Mana arriba a la derecha, ronda centrada y datos de torre a la derecha debajo de los recursos. Salud y ronda no tienen panel compartido; M55 añade un panel horizontal 9-slice solo a Gold y deja Mana sin panel. El título «RogueTower» no aparece. La salud de Main Tower muestra su valor actual/máximo dentro de una barra segmentada cada 10 puntos, con un segmento final parcial si corresponde. El Gold usa un icono y tamaño visual mayores que el Mana; toda ganancia o gasto anima icono y cifra con escalado y rebote. El Mana se restablece al máximo y se muestra como entero. El timeline de M35 muestra siempre 15 de las 45 rondas, sin selector; el hover de composición y el botón de inicio se conservan.
- No hay selector runtime de oleadas de diagnóstico ni panel técnico F3. `H` oculta y restaura el HUD; la navegación con rueda y botón central continúa funcionando con la interfaz visible/oculta.
- Seleccionar una torre muestra en el panel derecho nivel, daño, H/A/S, alcance, RPM, crítico, patrón, icono de energía si consume y XP por capa. El panel se ajusta al contenido y nunca usa scroll; reduce su escala vertical si el alto del viewport no permite mostrarlo a tamaño natural. Al entrar en build mode presenta el retrato grande de la torre y sus datos; omite la instrucción redundante de elegir Grass/Mountain y muestra el bonus cuantificado de Mountain frente a Grass. Health, Armor y Shield usan negrita y colores distintos. Los tres botones de mejora casi cuadrados enseñan icono, nivel de su capa, barra XP, `+1 Daño`, efecto y precio; Demoler queda debajo. Hover sobre torre no seleccionada muestra el radio y un contorno; al seleccionar, el sprite y card inferior pulsan con brillo alfa, sin círculo y sin pulso del panel. Prioridad 1 aparece sola; botones `+` revelan prioridades únicas 2 y 3. El panel desaparece al deseleccionar la torre o pulsar fuera del tablero.
- Cada objeto tiene su PNG RGBA transparente independiente en `assets/sprites/ui/icons/` (256×256); no existe un atlas compartido. Los atajos inferiores son botones individuales con un asset de marco estilo carta, sprite grande, nombre y precio con icono de moneda; el contenedor que los alinea no muestra fondo ni marco común. El sprite de torre es idéntico al preview y a la torre colocada. La base usa un sprite PNG configurable desde `BaseData`; su tamaño vigente conserva el archivo fuente 270×352 px y lo estira a 1,8 × el radio de huella de ancho por 2,8 × de alto, manteniendo fijo el borde inferior. La huella lógica y la posición Y-sort siguen separadas. No cambian huellas lógicas ni movimiento. La UI sustituye por iconos las menciones a Gold/Mana en textos enriquecidos. Las cards específicas muestran la torre afectada; las cards de terreno conservan el contrato M10.
- Los enemigos muestran un marco de Health con carriles de Shield y Armor sobre una Health fragmentada; los iconos de capa identifican cada carril. Los estados activos aparecen encima y solo muestran cifra cuando hay varias acumulaciones. Cada impacto hace destellar y saltar al enemigo, y presenta daño flotante coloreado según Shield, Armor o Health. El efecto no cambia el cálculo de `DamageService`.
- El resumen de victoria/derrota se presenta en el menú después de cambiar de escena; M35 añade el resumen compacto de cantidad y daño por torre desbloqueada. La seed se conserva como dato técnico.
- La tienda anterior por categorías/filas quedó reemplazada por el mapa de nodos compartido de M35. Sigue mostrando coste/estado y rechaza compras sin saldo o guardado válido.
- A 1440×900, el HUD principal, la barra de torres reclutadas y las ofertas no se recortan ni bloquean la lectura del mapa. El mapa de mejoras se puede recorrer mediante scroll; comprobar encuadre y tooltips en M35.

### Prueba manual M13 en el juego

1. Arranca en la escena de menú y pulsa iniciar. En una ventana de 1440×900, comprueba la base y la barra de salud segmentada; el HUD no presenta título «RogueTower». La disposición de salud/recursos sigue vigente; el timeline de 45 puntos fue reemplazado por una ventana fija de 15 rondas en M35. El panel derecho empieza oculto. El icono/cifra de Gold destacan sobre Mana y los saldos no muestran decimales.
2. Confirma que el HUD normal no presenta selector de fixtures ni la línea técnica del enemigo. El panel técnico F3 de esta etapa histórica fue retirado en M61. Pulsa `H`, mueve/zoomea el tablero, vuelve a pulsar `H` y comprueba que la interfaz vuelve sin haber cambiado la cámara ni la ronda.
3. Activa build mode para Ballista y para otra torre: el panel derecho debe mostrar un icono grande, coste, stats H/A/S con color y bonus por elevación, sin la frase «selecciona Grass o Mountain». Comprueba que su alto se ajusta a esta información. Construye Ballista en Grass/Mountain con elevaciones diferentes. El botón individual tiene fondo estilo carta y el conjunto no queda dentro de un panel compartido. El botón, el preview del cursor y la torre colocada deben mostrar la misma Ballista ampliada. Pasa el cursor sobre ella: aparece su radio y contorno; selecciónala y comprueba que mantiene su brillo y pulso de sprite/card sin mostrar círculos. Haz clic en una casilla vacía y confirma que el panel desaparece.
4. Selecciona Ballista y una torre reclutada en la barra. Comprueba icono, nombre, precio, disponibilidad por Gold y feedback de construcción. Gasta/recibe Gold y confirma que icono/cifra animan juntos. Gasta Mana antes de una ronda y comprueba que se repone al máximo efectivo al iniciar la siguiente. Verifica hover de rango, selección, prioridades e iconos/capas H/A/S como en la versión anterior de M13.
5. Durante la campaña normal, llega a la ronda 24 y observa Ooogie von Ooogovich con su kit propio. Sobre el enemigo con pools activos debe verse Shield arriba, Armor debajo y Health fragmentada; las barras e iconos deben leerse a simple vista. Observa impactos en cada fase: el enemigo parpadea/salta y los números son cian para Shield, ámbar para Armor y rojo para Health. El valor debe corresponder al daño que realmente aplicó el juego. Las fixtures de daño antiguas ya no se seleccionan en una partida normal.
6. Repite con Status Probe (`0`) o con Frost Keep, Flame Thrower, Poison Sprayer o Shredder sobre una ronda activa. El símbolo PNG de Bleed, Burn, Poison o Slow aparece encima de la barra sin una placa o fondo opaco, a 28×28 px y con transparencia; no debe verse un rectángulo detrás. Para un estado acumulable, aplica al menos dos acumulaciones y comprueba que aparece su cifra; al expirar, icono y cifra desaparecen. Verifica que estado y barra acompañan al enemigo durante su movimiento.
7. Obtén una card específica de una torre durante la run: la card incluye el sprite de esa torre. Elige cartas con descripciones que aumenten o consuman Gold/Mana y confirma que aparecen los iconos en línea; no debe quedar el nombre textual de esas monedas en los elementos enriquecidos.
8. Repite una run hasta derrota dejando llegar enemigos a la base. La tienda debe presentar derrota, ronda, rondas completas, recompensa y saldo meta. Cambia entre TORRES y MEJORAS: solo se ve la lista activa con descripción/coste/estado. Compra una opción asequible y confirma el saldo nuevo; con saldo insuficiente no debe cobrarse. «Empezar nueva run» debe conservar las compras. Completa la campaña hasta 45/45 para revisar la variante de victoria.
9. A 1280×720 y 1440×900, revisa HUD, panel lateral, barra inferior y cards. Los controles deben permanecer legibles; el panel lateral muestra todos sus datos, nunca presenta scroll y se reduce verticalmente si el alto del viewport es insuficiente. La tienda sí debe desplazarse sin bloquear el mapa ni recortar nombres, precios o cifras. Confirma que las ilustraciones de Path/Grass/Mountain coinciden con las caras hexagonales sin corrimiento visible y que torres, enemigos y base conservan sus puntos de anclaje al aumentar de tamaño y desplazarse 6 px hacia abajo.

M13 queda aceptado cuando los nueve puntos anteriores pasan en una ventana Godot y se comprueba que la interfaz guía acciones normales sin requerir DEBUG, mantiene sprites consistentes, segmenta la base cada 10 Health, repone Mana al inicio de cada ronda, anima las variaciones de Gold, comunica estado/capas/daño con iconos y animación, y permite operar prioridades, upgrades y tienda sin ambigüedad. La presentación vigente del HUD y la ausencia del panel F3 se comprueban en M61.

## M14 Terreno, cofres y feedback

### Prueba manual en el juego

1. Criterio histórico de M14 sustituido por M39. Usa la sección M39 para revisar el pool actual de ocho obstáculos, los 18 props de Path/Grass/Mountain, la escala, la frecuencia y las capas de dibujo.
2. Activa build mode y apunta a obstáculos de varios tipos: el preview debe marcarlos inválidos y no se debe colocar torre. Repite en una celda Grass/Mountain con cofre; la torre tampoco se debe construir hasta abrirlo. Haz clic en el cofre y confirma que desaparece y añade 25 Gold una sola vez, sin alterar la ruta ni la celda axial. Vuelve a hacer clic y confirma que no duplica la recompensa.
3. En la tienda permanente compra «Suerte del explorador» nivel por nivel y comienza otra run para que cambie el porcentaje de cofres. Comprueba que parte del 1 %, sube en pasos de 5 puntos porcentuales y se limita al 20 % tras cuatro niveles; la configuración persiste al reiniciar el juego.
4. Pasa el cursor sobre un cofre sin abrirlo. Debe botar suavemente y mostrar un resplandor dorado mientras siga el hover; al salir, animación y brillo deben detenerse. Al abrirlo, la animación debe terminar sin bloquear la retirada del cofre.
5. Comprueba el VFX al impactar cada torre: Ballista Dust_01, Mortar Explosion_01, Tesla Coil TeslaCoil, Frost Keep Ice_01, Flame Thrower Fire_03, Poison Sprayer Poison y Shredder Blood. Los efectos deben aparecer en la posición de impacto y concluir su animación sin quedarse congelados.
6. Comprueba los cuatro estados del cursor: Cursor_01 normal, Cursor_02 al pasar sobre controles u objetos interactivos, Cursor_03 al apuntar a terreno inválido o una acción deshabilitada, y Cursor_04 mientras se coloca una torre. Confirma que los tres primeros se asignan al puntero del sistema y que al salir del overlay de construcción se restaura el cursor del estado actual.
7. Verifica que el panel lateral de torre no tiene barras de desplazamiento a 1280×720 y 1440×900; debe mostrar todo su contenido y adaptarse a la altura disponible. Revisa que la tienda conserve su scroll cuando una categoría exceda el espacio.

El código y los assets están integrados. M14 requiere ejecutar este procedimiento en ventana y corregir cualquier problema visual/interactivo antes de marcarlo aceptado.

## M17 Oclusión, escala de arte y flujo de rutas

### Prueba manual en el juego

1. Coloca una torre y un obstáculo en hexes con distintas posiciones Y y mueve enemigos por PATH delante y detrás de ellos. Confirma que el elemento más cercano a la parte frontal del tablero aparece delante, que los props pueden quedar detrás de torres/enemigos y que la base también participa en el orden por profundidad. El orden debe seguir el pie visual de cada elemento, no su centro gráfico.
2. Inspecciona cada tipo y variante de terreno. El borde pintado del PNG debe coincidir con el contorno de la cara hexagonal, sin desplazamiento lateral o vertical visible y sin tapar de más las celdas vecinas.
3. Con `Ctrl+D` desactivado, confirma que cada rama y convergencia de PATH muestra flechas con movimiento continuo hacia la base. Cambia una colocación válida para revisar el grafo candidato; cancélala y comprueba que vuelve a fluir el grafo activo. Los portales pulsantes siguen visibles y no muestran carteles.
4. Comprueba las dimensiones por recurso (torres 84 px y enemigos estándar 72 px) a zoom 1× y 0,75×. Deben conservar proporción y su arte debe quedar unos 6 px por debajo del centro lógico. El tamaño visual vigente de la base está especificado en M46: el PNG fuente permanece 270×352 y su caja renderizada es 1,8 × el radio de huella de ancho por 2,8 × de alto. La ampliación no debe alterar selección, ocupación, alcance, hitboxes de combate ni navegación.

ADR-0041 y ADR-0042 implementan en código la ordenación de props, la alineación del arte, el flujo animado por aristas, la profundidad por elevación, el hover selectivo del grid y el portal de spawn. Esta revisión no marca M17/M18 aceptados hasta completar las comprobaciones visuales en una ventana Godot.

## M18 Orden visual, feedback y piezas de terreno

### Prueba manual en el juego

1. Haz pasar enemigos por PATH detrás y delante de una montaña elevada. La fachada del cliff debe cubrir a los actores detrás de su borde delantero Y-sorted y quedar bajo los actores delante; las torres y props que se apoyan en la superficie elevada deben seguir legibles.
2. Aleja el cursor de las celdas: no deben verse los bordes blancos del grid ni las conexiones/sockets de PATH. Haz hover sobre una celda y confirma que aparece su borde y ruta; las celdas a una y dos posiciones axiales se muestran con opacidad decreciente y el resto sigue oculto. Las flechas de flujo permanecen visibles.
3. Sigue un portal de spawn alcanzable: debe pulsar suavemente, no debe tener etiqueta/cartel `SPAWN` y debe desaparecer si deja de ser endpoint alcanzable. Selecciona una card, mueve el preview a una posición válida y confirma que los portales siguen los endpoints del grafo candidato con un tono verde; rota, cancela y comprueba que se recalculan o restauran según el estado activo. Verifica que el flujo de flechas apunta a la base en ramas y convergencias.
4. Entra en modo de construcción y confirma que el cursor de torre mide aproximadamente 32 px y pulsa mientras sigue el puntero. Al pasar por un botón debe volver el cursor de interfaz; sobre terreno inválido debe usar el cursor de error. Coloca una torre y confirma que vibra su icono correspondiente en la barra.
5. Comprueba que las siete cartas de torre son más grandes y tienen menor separación entre sí, sin recorte a 1280×720. Gana y gasta Gold y confirma que el icono y el saldo animan en ambas direcciones.
6. Revisa las diez nuevas piezas (Pradera de colinas, Macizo montañoso, Llanura abierta, Cresta escalonada, Loma aislada, Picos gemelos, Pradera con ramal sin salida, Curva junto al acantilado, Camino serpenteante y Bifurcación del barranco). Cada oferta debe tener siete hexes y mostrar el contenido de su plan sobre Grass/Mountain; PATH no lleva props. Los mismos obstáculos/cofres deben permanecer en el ghost y tras confirmar. Cancela y vuelve a elegir para verificar que no se vuelven a tirar. Gira cada pieza y comprueba terreno, reciprocidad PATH y colocación/validación global. En la pieza del ramal, confirma que la rama norte termina dentro de la pieza y la salida este continúa conectándose con el grafo existente.

El código, las piezas y el sprite del portal están integrados. La aceptación M18 queda pendiente hasta recorrer estos puntos en ventana Godot. La corrección de superficies y el preview inicial se registró en ADR-0043; ADR-0060 documenta la consistencia de oferta y M39/ADR-0087 define su excepción al normalizar el anillo de base.

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
8. Revisa la celda de base y sus seis vecinas axiales: PATH se mantiene en 0 y Grass/Mountain pueden tener sus alturas válidas. La validación inicial no debe exigir un anillo plano; prueba una elevación positiva junto a la base.

M20 queda aceptado cuando los contadores, XP, costes y límites son independientes por capa; las prioridades mantienen orden y unicidad; el preview da feedback visible sin permitir colocaciones inválidas; el pulso se mueve con la selección y las cajas de obstáculos coinciden. El criterio histórico del anillo plano queda sustituido por las elevaciones M34/ADR-0073. Esta revisión integró código y documentación, pero no ejecutó Godot ni la prueba manual.

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

1. Inicia `game/main/main.tscn`. Comprueba que no aparecen errores al resolver `%GoldGroup` y que tanto ganar como gastar Gold animan icono y cifra. La vida de Main Tower queda arriba a la izquierda con los atajos debajo; Gold y Mana quedan arriba a la derecha, con valores enteros. Gold usa el panel 9-slice de Iniciar ronda; el criterio histórico de Mana sin panel queda sustituido por M61, que usa el mismo panel 9-slice.
2. Selecciona una torre. El panel lateral debe comenzar debajo de Gold/Mana y no cubrir los recursos. Cambia la resolución entre 1280×720 y 1440×900; el panel de ronda y el botón no deben quedar cortados.
3. Comprueba que el bloque de ronda no tiene panel de fondo y que el botón usa su sprite completo sin deformación, mantiene el texto legible y adapta su anchura con «Iniciar ronda», «Iniciar ronda NN/45» y los estados deshabilitados.
4. Criterio histórico reemplazado por M35: el timeline muestra 15 rondas, sin selector, conserva los círculos/tooltip y desvanece el extremo futuro.
5. Tras completar una ronda y abrir las tres cards de terreno, confirma que no existe panel de fondo compartido. Cada card conserva su marco y preview; la preview se ve completa dentro del marco y no sobresale. En oferta las cards miden al menos 320×420 px; durante colocación se reducen a 184×126 px y mantienen la preview contenida. Debajo indica cantidades como `4 Path 2 Grass 1 Mountain`; comprueba que las categorías con cero unidades no aparecen.
6. Coloca o consulta celdas elevadas Grass y Mountain de nivel 1 y 2. Las fachadas deben usar su material de césped/tierra o roca, conservar el mismo tamaño de detalle entre ambas alturas y quedar cerradas sin grietas ni ángulos abiertos. Confirma la oclusión de actores por Y-sort: enemigo detrás cubierto por la fachada, enemigo delante dibujado por encima. Los PNG pueden reemplazarse sin cambiar la altura lógica.

M22 queda aceptado tras pasar esta revisión manual en ventana Godot. La integración de código y arte está registrada en [ADR-0048](../decisions/ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md).

## M23 Navegación, preview de portales, ghost y Tower Info

### Revisión manual en ventana

1. Ejecuta `game/main/main.tscn`. Mantén `W`, `A`, `S`, `D` y prueba diagonales; la cámara debe moverse continuo sin aceleración diagonal extra y mantener velocidad visual al acercar/alejar. Comprueba que `D` panea a la derecha y que `Ctrl+D` alterna el overlay diagnóstico. Suelta las teclas y cambia el foco de ventana mientras una está pulsada: la cámara no debe quedarse moviéndose. Los controles con foco de interfaz deben conservar su entrada.
2. Inspecciona las salidas PATH de una ronda mixta con varios endpoints. Sobre el portal no deben aparecer badges de enemigos. Al hacer hover aparece el contorno que sigue el alfa del frame actual y un tooltip con ronda, total, retratos, nombres y cantidades por tipo; al hacer clic, el panel de información presenta la misma lista. El atlas 4×2 se reproduce en bucle continuo a 96×96 px y cada endpoint tiene una fase distinta. Suma todos los portales y compara con la composición directa de esa `WaveData`.
3. Repite para la ronda siguiente y compara distribución round-robin entre endpoints con la ronda/política activa; no hay fixtures de oleada DEBUG desde M64. Selecciona una expansión válida y mueve/rota su preview: la vista por portal debe usar los endpoints del grafo candidato. Al cancelar o invalidar, debe volver al grafo activo. El tooltip no debe quedarse visible cuando se oculta el HUD ni capturar clics.
4. Entra en colocación de torre y mueve el cursor por celdas legales e ilegales, elevadas y con obstáculos. El sprite fantasma debe quedar encima de terreno y props y recibir tinte verde translúcido si es válido o rojo si no. Al cancelar no debe permanecer el sprite fantasma.
5. Revisa torres, enemigos, base, cofres y obstáculos en profundidad: no deben aparecer sombras generadas por código ni sprites auxiliares de sombra. El cofre conserva su silueta cerrada y simple al tamaño real; los PNG de cofre y portal mantienen alpha y se dibujan con filtro nearest.
6. Selecciona una torre y revisa Tower Info a 1280×720 y 1440×900. La superficie plana no lleva marco ornamental; el icono pequeño comparte cabecera con el nombre y `NIVEL X DE 45`. El panel se ajusta sin scroll ni recorte. Health/Armor/Shield muestran icono, nivel, barra de XP y coste en tres controles compactos; el tooltip conserva las cifras exactas de XP y el efecto completo. Demoler usa un botón de texto horizontal y conserva su comportamiento. Comprueba que el nivel acumulado avanza tras comprar capas y llega como máximo a 45.
7. Abre la selección de expansión de terreno. Las tres cards usan superficies planas con un borde fino para hover/selección, sin marco ornamental; preview, nombre y conteos siguen legibles y seleccionar una pieza conserva el comportamiento.

M23 queda aceptado tras completar esta revisión manual en ventana. El cambio está registrado en [ADR-0051](../decisions/ADR-0051-navegacion-prevision-portales-y-panel-torre.md), [ADR-0053](../decisions/ADR-0053-paneles-y-sprites-sencillos.md), [ADR-0055](../decisions/ADR-0055-feedback-base-seleccion-y-recompensas.md) y [ADR-0105](../decisions/ADR-0105-tooltip-de-spawn-atajos-oro-zoom-y-escala-de-torre.md).

## M24 Feedback legible de daño

### Revisión manual en ventana

1. En una oleada de combate, observa impactos repetidos en enemigos con Health, Armor y Shield. Cada número debe entrar con un golpe breve de escala, desplazarse hacia arriba por un arco alternando los lados, variar su tamaño de forma moderada y desaparecer con un contorno oscuro que mantenga legibilidad sobre el mapa.
2. Confirma que el texto y el flash del enemigo identifican Health en rojo, Armor en ámbar y Shield en cian. Compara golpes pequeños y grandes al mismo enemigo: el tamaño relativo debe notarse sin producir números desproporcionados.
3. Genera un crítico y confirma que su etiqueta `CRIT`, tamaño/contorno y punch destacan sin ocultar el color de la capa afectada. Comprueba grupos de muchos enemigos y torres rápidas: los números deben separarse lo suficiente para leerse y no afectar HP ni el resultado de combate.

M24 queda aceptado tras completar esta revisión manual en ventana. La decisión está registrada en [ADR-0052](../decisions/ADR-0052-numeros-de-dano-animados-y-legibles.md).

## Feedback de daño a base, recompensas y selección

### Revisión manual en ventana

1. Inicia una oleada con enemigos que alcanzan la base: el sprite se tiñe de rojo durante un instante y la cámara tiembla brevemente. La cámara debe terminar exactamente en su posición y zoom previos, también al recibir impactos seguidos.
2. Gana Gold por una baja/recompensa y abre un cofre con recompensa: el icono y la cifra de la esquina superior derecha deben rebotar y vibrar juntos. Abre un cofre teniendo Gold al límite y confirma que el cofre también produce el feedback sin cambiar el saldo.
3. Abre una oferta de mejoras y una oferta de expansión de terreno: el tablero queda oscurecido bajo las cards, las cards siguen destacadas y el fondo no bloquea clics. Al elegir una pieza el velo desaparece; cancela su colocación y confirma que vuelve con las tres opciones.

El feedback queda aceptado tras completar esta revisión visual/interactiva. La decisión está registrada en [ADR-0055](../decisions/ADR-0055-feedback-base-seleccion-y-recompensas.md).

## Revisión visual global: tipografía y estado sin sombras

### Revisión manual en ventana

1. Revisa el HUD, selección de terreno, Tower Info, cards de mejora, tienda permanente, tooltips, panel de debug, números de daño y cifras dibujadas junto a iconos. Todos deben usar Patrick Hand; los números de contadores dibujados manualmente también deben coincidir con la tipografía de controles.
2. Comprueba tamaños legibles y ausencia de recortes en 1280×720 y 1440×900. La sustitución de fuente conserva los tamaños tipográficos y la estructura actuales.
3. Coloca una torre, un obstáculo, una celda elevada y una celda plana; mueve enemigos y abre cofres. No deben aparecer sombras proyectadas, pedestales oscuros ni formas que simulen sombra generadas por el juego. Las flechas PATH no deben tener un trazo ancho debajo y los contadores no deben dibujar texto desplazado como sombra. El feedback de hover y selección se mantiene.

La revisión queda aceptada tras completar estos puntos en ventana. La tipografía está registrada en [ADR-0054](../decisions/ADR-0054-tipografia-global-y-sin-sombras-de-codigo.md); la retirada actual de sombras generadas, en [ADR-0070](../decisions/ADR-0070-sin-sombras-y-rutas-limpias-en-expansion.md).

## M25 Oferta de terreno, pausa y control de fases

### Revisión manual en ventana

1. Pulsa `P` y el botón junto a la vida durante `ROUND_PREP` y `COMBAT`. Confirma que pausa/reanuda el árbol y que el botón alterna entre el glyph de pausa y el de play, conservando solo la letra `P` visible.
2. Pausa durante `ROUND_PREP` y pulsa «Iniciar ronda». La partida debe despausarse e iniciar la oleada. Durante una selección de terreno o `CARD_OFFER`, iniciar ronda debe permanecer bloqueado y no debe quitar una pausa activa.
3. Durante la oferta y la colocación de terreno, comprueba que la barra de torres/panel de torre se oculta, `1–7` no seleccionan torres, `F3`/`Ctrl+D`/`Ctrl+K` no abren herramientas de diagnóstico, y hacer clic en una torre o cofre del tablero no selecciona/abre nada. Elegir, rotar, cancelar y confirmar la pieza siguen funcionando; al volver a `ROUND_PREP` regresan los controles normales.
4. Elige una card con un obstáculo visible. Verifica que miniatura, ghost al rotar/mover y tablero confirmado enseñan el mismo obstáculo en el mismo hex; miniaturas y ghost no muestran cofres. Cancela y vuelve a la misma oferta: los rolls se conservan.
5. Completa varias ofertas y revisa la pieza marcada `EXTIENDE RUTA`. La posición sugerida debe prolongar una ruta y la geometría debe variar entre recta, curva y bifurcación; cuando la sugerencia sea curva/bifurcación, ninguna card debe ofrecer la pieza recta. Las colocaciones que eliminen toda continuación legal deben seguir bloqueadas.
6. Haz hover sobre un cofre: debe botar y resplandecer en dorado mientras el cursor permanezca sobre el hex; al salir o abrirlo, el movimiento y el brillo deben detenerse.

La implementación M25 está integrada en código. La aceptación de pausa, control de fases, fidelidad de props y variedad de rutas queda pendiente de esta revisión interactiva. Decisiones: [ADR-0060](../decisions/ADR-0060-ofertas-de-terreno-y-contenido-determinista.md) y [ADR-0061](../decisions/ADR-0061-pausa-y-fases-de-expansion.md).

## M26 Selección/retirada de obstáculos y portales, fachadas y altura

### Revisión manual en ventana

1. En `ROUND_PREP`, haz clic en obstáculos de cada tipo. El panel debe mostrar Roca, Cristal, Hierba alta, Tótem o Montón de piedra junto a su retrato y altura/terreno.
2. Comprueba que retirar obstáculos cuesta 25, 100 y 225 Gold sucesivamente; la celda queda libre para construir y el siguiente precio cambia solo tras retirar otro obstáculo.
3. Haz clic en cada portal y comprueba que el panel muestra la ronda y una lista desplazable con sprite, nombre y cantidad de cada enemigo asignado.
4. Con cuatro spawns activos, quita uno: cuesta 50 Gold si no se retiró ningún obstáculo, desaparece ese portal y el total directo de enemigos no cambia; la distribución round-robin debe aparecer actualizada en los tres restantes. Con tres activos, la opción de quitar queda deshabilitada. Si ya se retiró un obstáculo, el coste del portal debe ser el doble del siguiente coste de obstáculo.
5. Inicia una oleada después de cerrar portales y confirma que se generan todos los enemigos y salen solo de los portales activos; compara la vista previa con la asignación real.
6. Inspecciona varias uniones de fachadas Grass/Mountain a elevaciones 1 y 2, incluyendo las esquinas de las capturas adjuntas, a zoom 0.45×, 1× y 2×. No debe quedar fondo abierto en vértices coincidentes; la elevación de cada nivel debe distinguirse más sin desalinear hover, tapas, torres ni props.

M26 está implementado en código. La escena se inició con Godot 4.7 sin errores de parseo/runtime; se mantienen avisos de GDScript. La verificación de interacción y la revisión de seams/elevación en ventana quedan pendientes. Ver [ADR-0063](../decisions/ADR-0063-seleccion-y-retirada-de-objetos-del-terreno.md).

## M27 Upgrade Cards, reembolso y cofres

### Revisión manual en ventana

1. Criterio visual original de M27, sustituido por M34/M36 y luego por M40/ADR-0088: consulta el layout plano, tier y aura en M40.
2. Inspecciona cartas de cada operación general vigente: daño, crítico, alcance, elevación, cadencia, área, Mana, capas Health/Armor/Shield, Gold, enemigo y estados. Ninguna card debe quedar sin imagen. Las cartas de torre específica deben conservar el retrato de la torre.
3. Coloca dos o más torres del mismo tipo. Comprueba que el reembolso de demoler la última torre seleccionada coincide con `precio_base + (cantidad_antes - 1) × incremento`, el conteo baja y el siguiente precio de compra disminuye. Sube una torre de nivel antes de demolerla y confirma que su reembolso no cambia.
4. En una oferta de terreno y al mover/rotar su ghost, verifica que no aparecen cofres en miniaturas ni losas seleccionadas. Confirma terreno Grass/Mountain sin obstáculo: si la tirada genera cofre, aparece en la celda ya colocada con un salto visible; PATH y celdas con obstáculo nunca reciben cofre. Abre uno y confirma que conserva hover, pago y retirada.
5. Abre el proyecto y observa la salida de GDScript: no deben reaparecer los avisos de parámetro/variable sin uso, variable `rotation` en conflicto, `_mana_icon` ni `is_pressed` reportados antes.

La regla M27 de cofres sustituye la visualización de cofres en oferta descrita en M25/ADR-0060. La implementación de sombras descrita en ADR-0066/0068 se retiró posteriormente mediante ADR-0070. Código/PNG integrados; Godot 4.7 inició la escena principal el 2026-10-13 con `errors: []`, incluidos los avisos GDScript listados. La aceptación visual e interactiva sigue pendiente. Ver [ADR-0064](../decisions/ADR-0064-reembolso-al-demoler-torres.md), [ADR-0065](../decisions/ADR-0065-panel-y-iconos-de-upgrade-cards.md), [ADR-0066](../decisions/ADR-0066-cofres-al-colocar-y-sombras-de-elevacion.md) y [ADR-0070](../decisions/ADR-0070-sin-sombras-y-rutas-limpias-en-expansion.md).

## M28 Hacks de progresión para testeo rápido

### Revisión manual en ventana

1. Abre `Ctrl+K` desde preparación y selecciona `Saltar a la siguiente card`. Debe buscar la siguiente ronda elegible del pool (3, 6, 9…) y abrir una oferta real de tres cards sin crear ronda dentro de combate.
2. Abre la tienda desde hacks. Debe abrir el mapa de nodos vigente de M35, indicar que es acceso de depuración y permitir comprar; la mejora se aplica a la próxima run. Cerrar el panel vuelve al tablero sin reiniciar la run.
3. Usa `Empezar desde cero`. Los niveles permanentes vuelven a cero, se devuelve el XP gastado en mejoras y el arsenal vuelve a Ballista, Mortar y Tesla Coil; el saldo XP no gastado y los contadores históricos permanecen. `Reiniciar run con mejoras actuales` y la nueva run normal conservan desbloqueos y niveles meta.

M28 está integrado en código. El salto omite combate, recompensa y colocación de terreno, por lo que sirve para revisar cards y no para medir la progresión de campaña. La revisión interactiva está pendiente. Ver [ADR-0067](../decisions/ADR-0067-hacks-de-progresion-y-run-limpia.md).

## M29 Sombras receptoras por elevación — sustituido

### Revisión manual en ventana

Este criterio quedó sustituido por ADR-0070. Ya no debe comprobarse ninguna sombra de terreno u obstáculo.

## M30 Sin sombras y preview PATH despejado

### Revisión manual en ventana

1. Inicia el tablero y coloca el cursor sobre terreno, obstáculos y torres. No deben aparecer sombras de losetas, obstáculos, edificios, unidades o base. El hover puede resaltar bordes sin dibujar rayos/socket PATH sobre las celdas.
2. Selecciona una pieza de expansión. Las flechas de flujo PATH y las líneas de diagnóstico deben ocultarse mientras la pieza está elegida; al cancelar o confirmar vuelven las flechas del tablero normal. La selección de terreno no debe crear otra visualización del camino.

El overlay de sombras, shader y enlaces a runtime se eliminaron; queda pendiente la inspección en ventana. ADR-0070 sustituye las decisiones de sombra de ADR-0066/0068.

## M31 XP de desbloqueo y feedback de altura
> M35 separa el unlock permanente del reclutamiento temporal; una torre comprada no aparece inmediatamente en la barra de la run siguiente y debe reclutarse con una card.

### Revisión manual en ventana

1. En un guardado nuevo, comprueba que Ballista, Mortar y Tesla Coil están desbloqueadas; solo Ballista aparece en la barra inicial. Mortar/Tesla se reclutan con cartas; las otras compras permanentes habilitan la opción de reclutamiento futura. La tienda cobra 50 XP por Frost Keep, Flame Thrower y Poison Sprayer, y 100 por Shredder.
2. Desde `Ctrl+K`, usa `Empezar desde cero`. En la run siguiente están desbloqueadas las tres torres iniciales, pero solo aparece Ballista en la barra hasta reclutar Mortar/Tesla con una card. Los niveles permanentes son cero y el XP devuelto permite recomprar mejoras.
3. Selecciona torres sobre Grass 1/2 y Mountain 2/3. El panel muestra su altura y los extras: +1 daño base y +0.5 hex de alcance por nivel según `TowerData`. Comprueba que el badge sobre la torre muestra +1, +2 o +3 según su bonus y que el daño/alcance coinciden.

Los perfiles actuales cargan y el feedback está integrado; la aceptación manual sigue pendiente. Ver [ADR-0069](../decisions/ADR-0069-desbloqueos-xp-y-feedback-de-altura.md).

## M32 Marco de cards y colocación automática

### Revisión manual en ventana

1. Criterio visual de card sustituido por M34; el panel unificado y las auras por rareza se revisan en esa sección.
2. Abre una oferta de terreno. Las miniaturas de bifurcación y convergencia muestran los hexágonos y obstáculos, sin brazos, ramas ni flechas PATH superpuestos.
3. Elige una pieza y comprueba que aparece `T · Auto-colocar (no recomendado)`. Pulsa T: la pieza debe colocarse en una posición libre que pase las validaciones geométricas y de PATH, incluida la continuación futura de campaña. Repite en un estado donde no exista una posición válida: debe mostrarse un aviso y el tablero no debe cambiar. Comprueba que la rotación manual y la confirmación usual siguen disponibles.

La inspección visual/interactiva de este milestone sigue pendiente. Ver [ADR-0071](../decisions/ADR-0071-marco-de-cards-y-colocacion-automatica.md) y [ADR-0072](../decisions/ADR-0072-controles-y-tooltip-de-celdas.md).

## M33 Rotación y tooltip compacto de terreno

### Revisión manual en ventana

1. Criterio histórico de M33: Q/E giraban y la rueda rotaba durante colocación. M55 sustituyó el uso de la rueda; la regla vigente se verifica en M55.
2. Sin pieza, torre ni objeto seleccionados, mueve el cursor por PATH 0, Grass 1/2 y Mountain 2/3. Debe aparecer junto al puntero un tooltip pequeño con el tipo/estado de la celda, la altura y el bonus de daño/alcance compatible. PATH debe indicar ruta no construible.
3. Comprueba Grass/Mountain con obstáculo, cofre y torre colocada: el estado refleja el bloqueo. El bonus usa los `TowerData` aplicables y aumenta con la elevación. La caja debe permanecer dentro de la ventana incluso junto a sus bordes.
4. Selecciona/coloca una torre, selecciona una pieza, pasa por un portal y abre oferta/tienda/hacks: el tooltip de celda debe ocultarse y los paneles/acciones existentes deben seguir respondiendo.
5. Criterio histórico de M33: sin pieza, la rueda acercaba/alejaba desde el cursor; al seleccionar terreno, no hacía zoom. M55 sustituyó este comportamiento; la regla vigente se verifica en M55.

La implementación está integrada; no se ejecutaron pruebas ni revisión visual/interactiva en esta actualización. Ver [ADR-0072](../decisions/ADR-0072-controles-y-tooltip-de-celdas.md).

## M34 Elevaciones, vida de base, jefes y upgrade cards

### Revisión manual en ventana

1. En una run nueva, confirma base en 10/10 HP. En la tienda, cada nivel permanente de Fortification añade +1 HP y cobra 20, 40, 60, 80, 100, 120, 140, 160, 180 y 200 XP; nivel X deja la base en 20/20 HP. No se puede omitir un nivel anterior. Las cards Fortification I, II y III suman +3 HP cada una durante esa run, sin alterar el nivel permanente.
2. En una copia/fixture de campaña con HP sobrante, deja que un enemigo `boss_tier > 0` toque la base y comprueba que la run termina al instante aun si conserva HP. Un enemigo normal debe finalizarla solo al agotar la vida de la base.
3. Genera varios mapas/ofertas. PATH siempre usa altura 0, Grass solo 1 o 2, Mountain solo 2 o 3; los valores permanecen iguales desde la miniatura y el ghost hasta confirmar la expansión. Verifica que los resultados varían al cambiar seed.
4. Construye torres en alturas 1, 2 y 3. El badge superior muestra el bonus de daño (+1/+2/+3), el alcance aumenta 0,5 hex por altura y la torre conserva su selección/click con el sprite elevado. En torres con coste de Mana escalado por daño, comprueba que el coste por ataque también aumenta con la altura.
5. Selecciona Ballista para construir y mueve el cursor por Grass/Mountain de alturas diferentes. El ghost debe mostrar en todo momento el bonus de daño de la celda; PATH, huecos, obstáculos y casillas inválidas no deben tapar el indicador ni permitir construcción.
6. La presentación vigente de upgrade cards está definida por M40/ADR-0088; comprueba esa sección. El criterio temporal del sprite vertical de M36 queda sustituido.

La aceptación visual/interactiva de M34 está pendiente; no se ejecutaron pruebas en esta actualización. Ver [ADR-0073](../decisions/ADR-0073-elevaciones-y-bonus-de-torre.md), [ADR-0074](../decisions/ADR-0074-vida-de-base-y-derrota-por-jefe.md) y [ADR-0075](../decisions/ADR-0075-panel-unico-y-aura-de-rareza.md).

## M35 Menú, reclutamiento, tienda de nodos y lectura del tablero

### Revisión manual en ventana

1. En una partida nueva, confirma 1.000 Gold al entrar. Starting Coffers debe sumar 100 Gold por nivel comprado; al nivel X el saldo inicial debe ser 2.000. Verifica que se trata de Gold de run y no de XP persistente.
2. En el menú principal, inicia una partida y comprueba que aparece solo la Ballista en la barra de construcción. Tras completar la ronda 3 y colocar terreno, la primera oferta programada debe incluir Mortar y Tesla Coil como opciones de reclutamiento. Elige una: aparece su botón y se puede construir; la otra torre no se puede construir antes de reclutarla. Las cartas de mejora específicas de una torre no aparecen hasta reclutarla. Compra el unlock permanente de otra torre y confirma que puede entrar en ofertas de runs posteriores, pero no se construye antes de elegir su carta.
3. Desde el menú, abre la tienda y recorre el mapa de mejoras. Todas las categorías usan la misma tarjeta/nodo y un icono grande del objeto afectado; las ramas tienen conectores. Un nodo bloqueado informa en tooltip del unlock o nivel anterior requerido. Compra uno y confirma que se actualizan sus dependencias y aparece una ráfaga de partículas. Los nombres Better de torre identifican claramente la torre afectada. Para cada torre, Health/Armor/Shield comparten el requisito del unlock de torre y son hermanas; las mejoras de Main Tower conservan su secuencia de niveles.
4. Mientras corre una partida, pulsa Escape: el juego se pausa y muestra opciones para reanudar o volver al menú. Reanuda y comprueba que el juego sigue; vuelve al menú y confirma que se limpia la pausa sin entregar recompensa de derrota. Al perder por daño a la base o contacto de boss, el resultado lleva al menú con la tienda abierta. El cambio de escena no debe disparar consultas del puntero desde el preview desmontado ni errores de `get_viewport()`. Game Over resume por torre la cantidad construida y el daño acumulado; no muestra categorías sin unlock permanente. Ver [ADR-0086](../decisions/ADR-0086-oferta-de-cards-y-cierre-de-derrota.md).
5. Comprueba que el timeline no tiene selector y muestra siempre 15 rondas. Verifica círculos, tooltip con retratos/conteos y el total de 45 rondas. La ventana empieza en la ronda actual; al llegar al tramo final, muestra 31–45 para mantener los 15 puntos. El extremo futuro se desvanece. La cámara de juego no rota ni cambia de proyección.
6. Repite la generación del tablero inicial y varias ofertas. En el tablero inicial hay como máximo un obstáculo total y no se coloca en la base ni sus seis vecinas. Cada pieza de siete hexes tiene como máximo dos obstáculos. Confirma los mismos límites al pasar de miniatura a ghost y tablero. Compara las tres vistas de cada oferta: tapa texturada, fachada, altura, props y orden delante/detrás deben coincidir; presta atención a Camino serpenteante. La lista activa de obstáculos y las condiciones de los props se verifican en M39.
7. Recorre celdas delante y detrás entre alturas 0–3 con los dos tipos de fachada. Cada tapa debe verse como polígono cerrado de seis lados; no aparecen vértices abiertos ni caras rectangulares sueltas, y la textura no se estira al subir altura. En uniones de vértice no quedan huecos, incluidos los extremos aislados de una sola fachada; los UV nunca muestran una franja ajena de textura. Comprueba primero el orden back-to-front por posición axial proyectada de suelo entre tapas y después las copias elevadas junto a actores detrás, delante y sobre la misma superficie; las superficies deben ocluir solo lo que queda detrás y dejar visibles los actores del mismo nivel. La cámara permanece fija.
8. Selecciona Ballista y haz hover por celdas elevadas de altura 1, 2 y 3. El ghost muestra +1/+2/+3 de daño antes de confirmar la construcción; después, la insignia de la torre colocada queda oculta hasta pasar el cursor por encima.
9. Carga la tienda y confirma que la validación del catálogo no informa de prerequisitos ausentes. Archivo de cartas aparece conectado tras Suerte del explorador (ID persistente `meta:chest_finder`); el mapa no emite avisos de división entera al distribuir nodos sueltos. La partida compila con Ballista como torre seleccionada por defecto.

La integración de M35 está en código y documentos. Tras los arreglos de ID, división entera y perfil Ballista, Godot 4.7 arrancó la escena de menú sin errores en la salida de depuración y el escaneo headless no reportó diagnósticos GDScript. No se ejecutaron tests ni se inspeccionó visualmente la interfaz o el tablero. La aceptación de flujo, legibilidad, partículas, ventana y geometría requiere esta revisión visual/interactiva. Ver ADR-0076, ADR-0077, ADR-0079 y ADR-0083.

## M36 Cards de tier, ramas paralelas y tinte de altura

### Revisión manual en ventana

1. El criterio de sprite vertical de esta sección quedó sustituido por M40/ADR-0088. Conserva aquí la comprobación de ramas H/A/S paralelas; la intensidad del tinte se actualizó en M49.
2. En el mapa permanente, desbloquea una torre y confirma que sus mejoras Health, Armor y Shield pasan juntas a disponibles y que las tres conexiones salen del nodo de torre. Compra una de ellas y verifica que las otras dos siguen comprables; comprueba que puedes elegir las tres en cualquier orden para Ballista y otra torre.
3. Compara tapas Grass/Mountain a elevaciones 0, 1, 2 y 3 junto a sus copias elevadas Y-sorted. El nivel 0 conserva el color original y cada nivel oscurece el RGB con multiplicadores 1,00/0,95/0,90/0,85. Deben seguir visibles los detalles de textura y el patrón no debe estirarse. Verifica que la cámara top-down isométrica, UV, geometría cerrada y oclusión delante/detrás no cambian.

Las ramas H/A/S y el tinte de M36 permanecen vigentes; su presentación de card se reemplazó en M40. No se ejecutaron pruebas automatizadas ni se hizo revisión visual/interactiva; la aceptación queda pendiente. Ver [ADR-0080](../decisions/ADR-0080-sprite-vertical-y-tier-de-upgrade-cards.md), [ADR-0081](../decisions/ADR-0081-mejoras-de-torre-en-ramas-paralelas.md), [ADR-0082](../decisions/ADR-0082-tinte-multiplicativo-por-elevacion.md) y ADR-0088.

## M37/M38 Geometría axial y fachadas delanteras

### Revisión manual en ventana

1. Genera tableros con Grass y Mountain en alturas 1, 2 y 3. En un borde con vecino, la pared solo cubre el desnivel expuesto entre ambas tapas; en un borde vacío llega al suelo. La tapa de cada hexágono permanece completa y nunca queda cubierta por una pared.
2. Revisa celdas contiguas y piezas de siete hexes. Solo se dibujan las dos fachadas delanteras del hex pointy-top; ninguna cara lateral/trasera, extrusión radial, cierre de esquina añadido o polígono marrón debe aparecer.
3. Comprueba que cada fachada mantiene el ancho de la arista axial original, termina exactamente en la tapa vecina y no crea vértices de esquina. Conserva la textura Grass/Mountain y el degradado; las tapas y sus texturas permanecen intactas y los UV de muro no se estiran.
4. Recorre las mismas coordenadas con hover, selección y copias elevadas de `Entities`. La cámara se mantiene fija; las celdas de delante cubren terreno de detrás y los actores conservan el Y-sort acordado.

M37 estableció la retícula axial compartida. M38 simplifica el renderer para responder a la revisión visual: solo dos fachadas delanteras por hex, sin cierres de vértice ni profundidad lateral, con degradado multiplicativo por vértice en las paredes. ADR-0090 limita cada pared al desnivel expuesto para mantener visibles las tapas hexagonales. La matriz completa de alturas, vecinos y oclusión sigue pendiente de revisión en ventana. Ver [ADR-0084](../decisions/ADR-0084-render-axial-de-terreno-y-profundidad-por-celda.md), [ADR-0085](../decisions/ADR-0085-solo-fachadas-delanteras-y-degradado-de-cliffs.md) y [ADR-0090](../decisions/ADR-0090-fachadas-limitadas-a-la-diferencia-de-elevacion.md).

## M39 Props decorativos, obstáculos y base

### Revisión manual en ventana

1. Genera varios mapas y ofertas. La base conserva intacto su PNG fuente de 270×352 px y se estira a 1,8 × el radio de huella de ancho por 2,8 × de alto. La silueta crece hacia arriba, mantiene anclado su borde inferior y sigue ocupando una sola celda lógica; la cámara sigue aplicando su zoom uniforme al mundo.
2. Inspecciona las seis celdas adyacentes a base en varias semillas: Path es elevación 0, Grass elevación 1 y nunca hay Mountain ni altura mayor que 1.
3. Verifica que cada uno de los 18 props del catálogo solo aparece en su tipo de terreno, con roll independiente del 10 % por asset/celda, tamaño 36×36 px y máximo dos props únicos en una celda. Los props no reaccionan al hover/clic, no seleccionan nada ni bloquean construcción.
4. En celdas con dos props, confirma que no se solapan. Cuando una celda tiene obstáculo, este aparece delante de los props; el obstáculo queda centrado en el hex.
5. Comprueba que los ocho obstáculos del catálogo reemplazan al pool antiguo, que sus imágenes conservan el tamaño fuente 208×208 y que su tamaño en tablero/miniatura es 86×86. El anillo de base queda excluido según reglas existentes, con máximo de un obstáculo en tablero inicial y dos por pieza.
6. Para cada pieza, compara el set de props y obstáculos entre miniatura, ghost y terreno confirmado. Sin normalización del anillo de base, debe ser idéntico. Si una celda Mountain se convierte en Grass junto a base, la miniatura conserva el contenido sin ancla y el ghost debe coincidir exactamente con el tablero confirmado. Rota las piezas y verifica que las decoraciones siguen asociadas a su celda local.

El código, los assets y la documentación de M39 están integrados; sus valores visuales vigentes se actualizan en M41/ADR-0089. No se ejecutaron pruebas ni revisión visual/interactiva en esta actualización; aceptación pendiente. Ver [ADR-0087](../decisions/ADR-0087-props-obstaculos-y-altura-junto-a-base.md) y [ADR-0089](../decisions/ADR-0089-ajustes-escala-occlusion-portales-props.md).

## M40 Presentación compacta de upgrade cards

### Revisión manual en ventana

1. Abre varias ofertas de mejora y confirma que cada una muestra exactamente tres cards en una fila, con separación legible y sin ocupar indebidamente el centro del mapa.
2. Todas las rarezas comparten exactamente la misma superficie plana y estructura. No hay sprites de borde/fondo ni variantes por rareza. El tier aparece escrito y el icono, título y descripción tienen tamaño/contraste legible sin recortes.
3. El aura radial animada queda detrás de la superficie y usa color distinto por rareza; se perciben destellos/partículas suaves sin tapar el texto ni el icono. El hover refuerza el aura sin cambiar el panel.
4. Selecciona cartas y confirma que el botón entero recibe la interacción y que el fondo visual no bloquea la lectura o el clic. Reabre y verifica que la oferta conserva sus datos y rarezas.

El código y la documentación de M40 están integrados. No se ejecutaron pruebas ni revisión visual/interactiva en esta actualización; aceptación pendiente. Ver [ADR-0088](../decisions/ADR-0088-presentacion-compacta-de-upgrade-cards.md).

## M41 Ajustes de base, oclusión, portales y props

### Revisión manual en ventana

1. Abre un tablero con elevaciones y enemigos en rutas por delante y detrás. La fachada del hex elevado debe ocultar al enemigo tras ella y quedar oculta por el enemigo que pasa delante. Ninguna pared puede tapar una tapa hexagonal; las paredes entre vecinos terminan en la elevación de la tapa vecina.
2. Confirma que la base conserva el PNG fuente 270×352 sin remuestreo y que se dibuja a 1,8 × el radio de huella de ancho por 2,8 × de alto, con el borde inferior visual anclado.
3. Inspecciona todos los portales: el atlas 4×2 recorre los primeros siete frames continuamente y omite el último, duplicado del primero; fases iniciales distintas impiden que dos portales avancen sincronizados. El hover sigue el alfa del frame actual.
4. Revisa varios seeds y celdas con cero, uno y dos props. Cada asset compatible tiene 10 % de probabilidad independiente, el tamaño es 39,6×39,6 px y dos props no se solapan; obstáculos se dibujan a 94,6×94,6 px y por delante.
5. Abre el proyecto con Godot 4.7 y confirma que `TerrainPiecePreview` carga sin errores de parseo en `_apply_base_ring_elevation`.

La implementación M41 está integrada en código y documentación. No se ha ejecutado Godot ni se ha realizado revisión visual/interactiva; aceptación pendiente. Ver [ADR-0089](../decisions/ADR-0089-ajustes-escala-occlusion-portales-props.md).

## M42 Contornos compartidos por región de terreno

### Revisión manual en ventana

1. En un tablero con grupos contiguos de Grass, Mountain y Path, confirma que las aristas internas entre celdas del mismo terreno y altura no se dibujan. El perímetro de cada grupo queda continuo y usa verde para Grass, gris para Mountain y amarillo para Path.
2. Comprueba que los bordes contra celdas de otro terreno, otra altura y vacío se trazan; cuando dos regiones se tocan se ven ambos colores, cada uno dentro de su tapa. El trazo sigue el hex exacto y no tapa props ni caras superiores.
3. Compara el tablero, las copias elevadas Y-sorted y las miniaturas de expansión. Las alturas y los límites deben coincidir; el hover conserva su contorno temporal y las piezas fantasma mantienen el color de colocación legal/ilegal. Revisa las seis esquinas de cada perímetro: las uniones no presentan cortes ni picos separados.

La integración M42 está en código y documentación. La inspección visual/interactiva en Godot queda pendiente. Ver [ADR-0091](../decisions/ADR-0091-contornos-compartidos-por-region-de-terreno.md).

## M43 Centrado, pulido visual y raíz común de sprites

### Revisión manual en ventana

1. Criterio histórico de M43: construye cada una de las siete torres en varias celdas y confirma el ancla centrada y el tamaño original +20 %. Esa escala fue sustituida por M53/M54/M55; para la build vigente usa la verificación de M55. Rango, daño, ocupación y selección no cambian.
2. Examina perímetros de varias regiones Grass/Mountain/Path, bordes contra vacío, cambios de altura, superficies Y-sorted y miniaturas. Las líneas deben unirse sin huecos y sus vértices deben verse suaves sin cambiar la forma hexagonal.
3. La lectura vigente de las fachadas se prueba en M45/ADR-0094: las dos caras delanteras deben verse oscuras con sombreado direccional distinto. Los tonos de `#406e4d` Grass y `#646567` Mountain corresponden al contorno de región de terreno, no sustituyen la textura superior.
4. Confirma props de 39,6×39,6 px y obstáculos de 94,6×94,6 px. La probabilidad, distribución por celda y orden de dibujo permanecen iguales.
5. Deja el cursor sobre un portal que vaya a cerrarse, confirma una pieza y comprueba que el tooltip desaparece antes de la siguiente oferta. Observa el loop: usa frames 0–6 y omite el último frame duplicado.
6. Inspecciona `assets/sprites/`: todos los PNG runtime, iconos, enemigos, terreno, interfaz y sidecars `.import` quedan agrupados en subcarpetas por categoría. Confirma que las hojas Tiny Swords locales siguen ignoradas por Git y que `assets/fonts/` y `art_generation/` siguen siendo fuentes aparte.

La implementación M43 y la documentación están integradas. No se ejecutó Godot ni una inspección visual/interactiva; aceptación pendiente. Ver [ADR-0092](../decisions/ADR-0092-pulido-visual-y-raiz-comun-de-sprites.md).

## M44 Preview exacto, tres cartas y arte de torre (actualizado por M50)

### Revisión manual en ventana

1. Mueve y rota varias piezas con celdas Grass/Mountain en desniveles, con una o más celdas que auto-rellenen huecos. Compara cada tapa y fachada del ghost con el tablero después de confirmar: altura, textura, obstáculos, props y cofres deben permanecer idénticos.
2. Revisa el contorno de región de terreno Grass/Mountain/Path en tablero, superficies elevadas, hover y miniaturas. Las aristas internas desaparecen; las juntas no tienen huecos ni picos, los extremos son redondeados y el trazo usa un único color plano por terreno: `#406e4d`, `#646567` y amarillo Path.
3. Desbloquea varias torres, inicia run y abre ofertas de ronda 3/6/9. Cada panel debe contener exactamente tres cartas; si hay reclutamientos disponibles muestra al menos uno y nunca más de dos, con los otros espacios elegidos aleatoriamente. Las torres no elegidas permanecen disponibles en ofertas futuras; no aparece una cuarta opción aunque haya más torres pendientes.
4. Construye Ballista, Mortar, Tesla Coil, Poison Sprayer, Flame Thrower, Frost Keep y Shredder. Cada torre debe usar un único sprite completo sin montaje de partes ni rotación visual, mantener el outline blanco y reflejarse horizontalmente al apuntar a enemigos del lado opuesto. El ghost, la card de construcción y Tower Info deben reutilizar la misma imagen; la fachada conserva Y-sort y alfa completos.
5. Verifica los iconos de los siete tipos en barra, cards y tienda; todos corresponden al sprite nuevo. El séptimo asset se asocia a Shredder, el nombre canónico actual.

La implementación M44 queda integrada en código/documentación. No se ejecutó Godot ni se hizo inspección visual/interactiva; aceptación pendiente. Ver [ADR-0093](../decisions/ADR-0093-preview-de-terreno-oferta-fija-y-torres-articuladas.md).

## M45 Mapa navegable y lectura de altura

### Revisión manual en ventana

1. Desde el menú abre Mejoras permanentes. Confirma que no existe el pie con instrucciones ni un botón “Empezar nueva run”; el botón × de la esquina superior derecha cierra la tienda y deja visible el menú. Después de perder una run, confirma que la tienda aparece abierta y que el mismo cierre vuelve al menú.
2. Desplaza con rueda en ambos ejes, arrastra con el botón izquierdo una distancia mayor a 8 px y vuelve a probar con el botón central. Verifica que un clic corto todavía selecciona nodos y que el arrastre no compra una mejora al soltar.
3. Recorre todos los nodos generales y de las siete torres: cada uno debe mostrar un icono relacionado, título legible y descripción breve; los tooltips deben conservar descripción completa, coste y requisitos. En cada torre, Health, Armor y Shield se ven en una sola fila debajo del unlock, conectados como alternativas hermanas, sin superponerse con los clusters vecinos.
4. Compara una torre de nivel 1, nivel intermedio y nivel 46. El arte aumenta de forma gradual hasta un máximo discreto de 12 %; la base y cabeza mantienen alineación/pivote. El aumento no cambia daño, alcance, colisión ni celda ocupada.
5. Comprueba una región Grass y una Mountain en elevaciones distintas: las aristas internas de la misma región no se dibujan, los bordes regionales son redondeados y sin huecos, Grass usa únicamente `#406e4d` y Mountain únicamente `#646567`; no debe aparecer keyline ni interior más claro. Hover conserva el mismo color RGB y solo cambia su opacidad. Las fachadas son las dos caras delanteras y respetan la geometría de la tapa; no aparecen costados, cierres de esquina ni cambios de cámara. El color y el gradiente vigentes se comprueban en M69.

M45 está implementado en código y documentado. No se ejecutó Godot ni revisión visual/interactiva; los cinco criterios anteriores siguen pendientes de aceptación manual. Ver [ADR-0094](../decisions/ADR-0094-mapa-de-mejoras-y-legibilidad-del-terreno.md).

## M46 Contorno de región de terreno y escala de la base

### Revisión manual en ventana

1. Revisa un borde Grass y uno Mountain con y sin hover, en tablero, copias elevadas y miniaturas. Grass debe usar `#406e4d` y Mountain `#646567` en un único trazo redondeado; no debe aparecer línea de keyline, borde doble ni interior más claro. Path conserva su tono amarillo.
2. Comprueba que el sprite de base mantiene el archivo 270×352 px, se estira a 1,8 × radio de ancho y 2,8 × radio de alto, y crece hacia arriba con su borde inferior anclado. Su huella de reglas y colisiones sigue siendo un hexágono.

M46 está implementado en código/documentación; no se ejecutó Godot ni revisión visual. La aceptación de ambos criterios queda pendiente. Ver [ADR-0095](../decisions/ADR-0095-contorno-regional-de-terreno-monotono.md) y [ADR-0096](../decisions/ADR-0096-base-mas-alta-y-visible.md).

## M47 Outline de base y enemigos

### Revisión manual en ventana

1. Comprueba que la silueta visible de la base tenga un outline blanco limpio que siga el alfa de su sprite, comparable al de torres y obstáculos.
2. Recorre varios tipos de enemigo: cada perfil debe tener un contorno pastel claro y distinguible. El contorno debe coincidir con la ilustración durante el movimiento, el cambio de dirección, el salto al recibir daño y una transformación de perfil.
3. Confirma que el outline queda detrás del sprite y que las barras Health/Armor/Shield e iconos de estado se leen encima; al cruzar una fachada, enemigo y contorno deben quedar ocluidos juntos según el orden Y.
4. Usa un perfil DEBUG sin textura para confirmar que el placeholder vectorial conserva un borde claro del tipo asignado o, si no tiene color configurado, el tono de reserva.

M47 está implementado en código/documentación; no se ejecutó Godot ni revisión visual. La aceptación de los cuatro criterios queda pendiente. Ver [ADR-0097](../decisions/ADR-0097-outline-de-base-y-enemigos.md).

## M48 Ajuste de grosor y contorno de portales

### Revisión manual en ventana

1. Comprueba que el contorno de la base sea visiblemente más fino que el anterior y mantenga un blanco uniforme alrededor de su alfa.
2. Compara varios enemigos con la versión anterior: el borde debe ser solo un poco más ancho, seguir siendo claro y conservar el color asignado por perfil.
3. Coloca varias torres: el borde blanco debe ser fino y uniforme, con `outline_size_px = 6`, sin tapar una parte apreciable del sprite.
4. Observa los portales sin hover: debe verse de forma permanente el mismo borde blanco fino que en los obstáculos. Al hacer hover, marcar una salida candidata o indicar un cierre, conserva su resplandor contextual por encima del borde blanco.
5. Recorre los siete frames del loop y el pulso de los portales; no debe haber saltos del contorno, arte de otra celda ni cambio de tamaño del hitbox.

M48 está implementado en código/documentación; no se ejecutó Godot ni revisión visual. La aceptación de estos criterios queda pendiente. Ver [ADR-0098](../decisions/ADR-0098-ajuste-de-outline-y-contorno-de-portales.md).

## M49 Lectura de altura y sombra animada de nubes

### Revisión manual en ventana

1. Coloca torres en alturas 0–3: la insignia numérica debe estar oculta en reposo y aparecer al pasar el cursor por encima; el indicador del ghost de Ballista sigue visible durante la colocación.
2. Pasa el cursor por celdas en varios bordes de la pantalla. El tooltip debe quedar a 24 px a la derecha y, cuando no quepa, a 24 px al lado contrario; el contenido no debe quedar bajo el cursor ni fuera del viewport.
3. Compara tapas y previews h0–h3: las superficies deben mantener sus texturas y oscurecerse uniformemente por multiplicadores 1,00/0,95/0,90/0,85; el contorno de región y las fachadas no deben cambiar de color ni geometría.
4. Observa al menos una partida durante varios segundos y mueve/zoomea la cámara: el patrón debe seguir anclado al terreno mientras deriva lentamente, con masas irregulares sobre terreno, fachadas, base, torres, enemigos, obstáculos, props y portales. No debe alterar selección, animación, Y-sort ni interacción.
5. Confirma que el velo queda bajo todo el HUD y sigue visible al ocultar el HUD. La UI debe conservar su color y contraste normales.

M49 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0099](../decisions/ADR-0099-tinte-de-altura-y-sombra-animada-de-nubes.md).

## M50 Sprite único de torre y tinte de altura

### Revisión manual en ventana

1. Construye cada torre canónica. Cada una debe aparecer como una sola ilustración con outline blanco; su anclaje queda en el centro del hexágono y el arte se ve ligeramente más abajo (8 px), sin partes que roten de forma independiente.
2. Deja que los enemigos pasen primero por la derecha y luego por la izquierda. La torre mira a la derecha por defecto y usa espejo horizontal para seguir un objetivo a su izquierda; no gira ni se inclina. Comprueba que el disparo sigue llegando al objetivo.
3. Compara la torre colocada, su ghost de construcción, la card de la barra y el retrato de Tower Info: todos deben cargar el mismo PNG completo, sin recortes, y conservar su proporción. El retrato, el nombre y el coste en Gold deben leerse con claridad y aprovechar el panel.
4. Compara tapas y previews de elevación 0–3. El multiplicador RGB debe ser 1,00/0,95/0,90/0,85; el contorno de región y las fachadas conservan color y geometría.

M50 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0100](../decisions/ADR-0100-sprite-unico-de-torre-y-tinte-de-altura.md).

## M51 VFX de combate, estados y feedback de juego

### Revisión manual en ventana

1. Deja disparar a cada una de las siete torres: debe reproducirse su hoja `shoot` sobre la torre y su hoja `impact` donde ocurre el impacto. Dispara con Mortar y confirma que `tap_ripple` marca la posición objetivo al lanzar el proyectil.
2. Aplica Bleed, Burn, Poison y Slow; también Haste/Fortification en un perfil compatible. Cada uno debe mostrar su spritesheet animado correcto encima del personaje, mantener su contador actual y desaparecer al terminar el estado. El mapeo vigente está en ADR-0101.
3. Sube una torre mediante cada ruta de mejora: `star_burst_gold` y `level_up` deben aparecer sobre ella para la subida manual y la automática por XP. Abre una oferta de cards o una expansión de terreno durante el efecto; la animación debe seguir encima de la interfaz y terminar por sí misma.
4. Deja aparecer un cofre: `item_glow` debe animar detrás del sprite durante toda su disponibilidad. Al abrirlo deben aparecer `coin_burst_gold`, `pickup` y `ui_click`; confirma `coins_top` en cada muerte final de enemigo y `base_hit` sobre la base al recibir daño.
5. Confirma una pieza válida de terreno: `sparkle_twinkle_white_loop` debe aparecer centrado sobre las celdas nuevas y completar dos ciclos. Haz clic en obstacle, portal, torre y base; `ui_click` debe aparecer en el cursor. Termina una run y comprueba `confetti_burst_01` en el menú con la tienda de resultado abierta.
6. Mientras se reproduce cada VFX de mundo (baja, disparo, impacto, daño de base, subida de nivel y colocación), panea con el botón central y cambia el zoom. El efecto debe seguir el mismo punto del mundo que su evento, paneando/zoomeando junto con la celda o actor; no debe quedarse pegado a la pantalla. Comprueba que `ui_click` siga sobre el cursor, que la animación no se congele durante ofertas, terreno o pausa, y que el glow del cofre siga ligado a su celda.

M51 está implementado en código/assets/documentación; la corrección de anclaje a mundo está en código, pero no se ejecutó Godot ni inspección visual/interactiva. Los criterios anteriores, incluido el paneo/zoom durante la animación, quedan pendientes de aceptación manual. Ver [ADR-0101](../decisions/ADR-0101-vfx-animados-de-cozy-chunky-por-evento.md) y [ADR-0106](../decisions/ADR-0106-vfx-de-evento-anclados-al-mundo-durante-el-paneo.md).

## M52 Sprites completos de torre, escala y cadencia de feedback

### Revisión manual en ventana

1. Revisa las siete torres en el tablero, el ghost, las cards de selección y Tower Info. Cada una debe usar su PNG completo, sin cortes ni partes compuestas; debe verse más grande, centrada en la celda y desplazada 8 px hacia abajo. El ghost y la torre construida deben coincidir.
2. Mantén ataques rápidos durante varios segundos. En Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder, el primer `shoot` aparece inmediatamente y los siguientes quedan separados por intervalos aleatorios de 2,0–2,5 s. Ballista y Mortar conservan un efecto por disparo discreto. Comprueba que todos los `impact`, proyectiles, ataques y daños siguen ocurriendo con su cadencia normal.
3. Construye varias torres y retira obstáculos. `pickup.png` debe aparecer una vez en el centro visual de cada acción exitosa; un intento fallido o cancelado no debe mostrar el efecto ni cobrar Gold.
4. Compara las cards (sprite 126×126 px) y Tower Info (152×176 px); los siete PNG deben mantener proporción, transparencia, outline y encuadre completo.

M52 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0102](../decisions/ADR-0102-sprites-completos-de-torre-escala-y-feedback.md).

## M53 Escala de torre sin recorte

1. Coloca cada una de las siete torres en terreno plano y elevado. El PNG completo debe quedar visible sin cortes en el tablero; el ghost debe coincidir en tamaño y posición con la torre construida.
2. Confirma que tablero y ghost usan escala 1,32 × 1,12 y offset visual de +8 px, mientras los iconos de la barra de construcción y Tower Info mantienen sus tamaños de UI.

M53 está implementado; su escala 1,32 fue sustituida por M54 y luego refinada por M55. La revisión visual de tamaño vigente se rige por los criterios de M55. No se ejecutó Godot ni revisión visual/interactiva. Ver [ADR-0103](../decisions/ADR-0103-escala-de-torre-sin-recorte.md), [ADR-0104](../decisions/ADR-0104-reduccion-del-20-por-ciento-de-escala-de-torre.md) y [ADR-0105](../decisions/ADR-0105-tooltip-de-spawn-atajos-oro-zoom-y-escala-de-torre.md).

## M54 Reducción adicional de escala de torre

1. Compara torre colocada y ghost en terreno plano/elevado; ambos deben usar escala 1,056 × 1,12, mantener el offset de +8 px y mostrar el PNG completo.
2. Confirma que la reducción de escala es del 20 % respecto a M53 y que cards/Tower Info no cambian de tamaño.

M54 está implementado en código/documentación; su escala 1,056 fue refinada por M55. No se ejecutó Godot ni revisión visual/interactiva. Ver [ADR-0104](../decisions/ADR-0104-reduccion-del-20-por-ciento-de-escala-de-torre.md).

## M55 Tooltip de spawn, atajos, zoom y panel de Gold

1. Pasa el cursor por cada spawn: no debe aparecer ningún retrato flotante encima del portal. El tooltip debe listar los tipos enemigos asignados, su retrato y el conteo exacto; al quitar el hover debe desaparecer.
2. Inicia una run con Ballista y verifica la tecla `1` tanto en la card como al pulsarla. Recluta otra torre y comprueba que aparece como `2`; recluta más y verifica el orden `1–N` sin huecos. El atajo selecciona la misma torre que su card.
3. Durante colocación de terreno, rueda arriba/abajo debe acercar/alejar la cámara sin cambiar orientación. `Ctrl+rueda` y Q/E deben rotar la pieza. Fuera de colocación, la rueda mantiene el zoom.
4. Compara visualmente el precio de Gold dentro de cada card y el saldo Gold del HUD: ambos usan el mismo panel horizontal 9-slice que Iniciar ronda; el panel cabe en 1440×900 y 1280×720, y Mana permanece legible.
5. En terreno plano y elevado compara torre colocada con ghost. Ambos deben usar escala `0,9504 × 1,12`, mantener el offset visual de +8 px y mostrar el PNG entero. Cards y Tower Info conservan su escala de UI.

M55 está integrado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0105](../decisions/ADR-0105-tooltip-de-spawn-atajos-oro-zoom-y-escala-de-torre.md).

## Loop
- Al completar una oleada de campaña entre las rondas 1–44, se entra en la oferta de expansión y no comienza la siguiente ronda hasta colocar una pieza válida.
- La colocación actualiza el tablero y la ruta una sola vez; la fase de mejora aparece después cuando el calendario de cards la requiere.
- La ronda 45 cierra la campaña al completarse; la victoria/derrota abre el flujo de recompensa y meta-progresión.

## Meta
- Derrota -> XP de perfil.
- Compra persiste tras reiniciar.
- Torre desbloqueada aparece en siguiente run.
- Save corrupto/versión desconocida falla de forma segura.

## UI — migración híbrida (2026-10-10)

### Smoke de escenas y contratos

Ejecutar `tests/ui_migration_smoke.tscn` en Godot 4.7. Debe completar e imprimir `UI migration smoke: PASS` sin errores de script/escena. El smoke verifica carga/instanciación de `main.tscn`, emisión única del ID `start_wave` por el menú debug, configuración de tarjetas de torre, controles de capa, oferta de tres y cinco cartas, filas de tienda de torre/mejora, cierre de tienda por `close_requested` y filas de tooltip desde `WaveData`. No sustituye la navegación por la partida ni la revisión visual.

### Revisión visual e interactiva en ventana

1. Abre `game/main/main.tscn` a 1440×900 y después a 1280×720. Compara posiciones, dimensiones, tipografía, iconos, colores, fondos y escalado con la implementación anterior; ningún panel debe quedar cortado ni cubrir Gold/Mana.
2. Usa `Ctrl+K` y cada acción debug disponible. Comprueba que el panel aparece en la misma capa, no bloquea controles fuera de su superficie, emite una sola acción y se cierra/togglea igual. Comprueba que `H` oculta/restaura el HUD como antes.
3. Construye/selecciona una torre, cambia la selección, mejora por Health/Armor/Shield y demuele. Revisa hover, foco, disabled/pressed, el pulso del icono, cantidades/XP/costes y propagación de clics al tablero.
4. Completa una ronda que ofrezca mejoras: abre/cierra la oferta, inspecciona exactamente tres cartas y elige una. Confirma orden, contenido, animación y estado de la run; verifica que el `offer_size` de `CardPoolData` está fijado en 3 y el panel no deja seleccionar botones adicionales.
5. Abre la tienda terminal y cambia entre pestañas. Desplaza listas largas, compra contenido disponible/no disponible, verifica monedas/mensajes, resultado y «Nueva run». Confirma que el guardado y los unlocks conservan el comportamiento anterior.
6. Pasa el cursor por varios puntos de `RoundProgressStrip`. El tooltip debe conservar anclaje/ocultación y total; una sola fila por tipo repetido, mismo retrato y conteo. Comprueba cursor y hover al salir del strip.
7. Selecciona `Main` y expande `ui_icon_catalog`: deben verse las 32 texturas del catálogo, agrupadas por recursos, capas, torres, estados, moneda de perfil y cursor. Cambia un icono de torre y confirma que se refleja en el retrato/cards que consultan el catálogo. Selecciona `TowerShortcut1…7` y `UpgradeHealth/Armor/Shield`; cada instancia debe exponer su `tower_icon_texture` o `layer_icon_texture` y previsualizarla en el `TextureRect` hijo. Comprueba también en esta propiedad los cuatro cursores usados por `BuildCursorOverlay`.
8. Selecciona `StartWave` y las tres `TerrainCard` en `main.tscn`; expande `Theme Overrides > Styles` y comprueba que sus StyleBoxTexture exponen el PNG, nueve cortes, márgenes y tintes de normal/hover/pressed/disabled. Cambia la textura para comprobar la vista previa. Abre `tower_shortcut_card.tscn` y revisa el marco 9-slice del botón.
9. Abre `game/ui/themes/rogue_hud_theme.tres` y edita `Panel`/`PanelContainer`. Las superficies generales son StyleBoxFlat y no usan sprite; los cambios se deben ver en HUD, tienda, oferta y debug sin cambiar su jerarquía.
10. Abre por separado las escenas de componentes en `game/ui/components/` y `game/progression/`. Ajusta tamaños en `custom_minimum_size`, márgenes y separación en sus `Container`, sustituye una textura en el `TextureRect` y confirma que los cambios se reflejan al instanciarlas desde `Main`.

M13 requiere además revisar los estados de selección/build mode del HUD y legibilidad a ambas resoluciones. El smoke headless y el escaneo del editor pasaron en Godot 4.7 el 2026-10-10; la inspección visual, el recorrido funcional completo y la comparación frente al baseline quedan pendientes. Ver [ADR-0049](../decisions/ADR-0049-arquitectura-hibrida-ui-editable.md) y [ADR-0050](../decisions/ADR-0050-recursos-visuales-ui-en-inspector.md).

## Scope
- No existe support building.
- Mana no depende de support building.

## M56 — feedback de progresión, cards y oclusión

1. Aplica estados con acumulaciones a enemigos de campaña: cada sprite de estado debe verse al menos al doble del tamaño anterior (44×44 px), mantener su animación, acumular iconos en una fila legible y conservar el contador de stacks.
2. Revisa enemigos que cruzan junto a fachadas en elevaciones 1–3 y desde ambos lados visibles. La fachada debe cubrirlos cuando están detrás y quedar cubierta cuando pasan delante; el sesgo de empate no debe mover la textura ni abrir juntas.
3. **Criterio histórico, sustituido por M59:** H/A/S se mostraban en una columna; la disposición vigente en una fila se comprueba en M59.
4. **Criterio histórico, sustituido por M60:** las acciones de demolición eran botones cuadrados solo con icono; el texto y los importes actuales se comprueban en M60.
5. Abre cada rama del mapa permanente: todos los nodos tienen un icono que coincide con la torre/efecto; el saldo, coste y recompensa se acompañan de `exp.png` y no aparece texto «XP», «EXP» ni «experiencia» en esa interfaz.
6. Durante varios ataques, compara tiempo hasta subida de nivel automática con la fórmula documentada ×5. Confirma que una subida automática reproduce el mismo `star_burst_gold` y `tower_level_up` que una mejora manual.
7. Pasa el cursor por una mejora de run, una card de terreno y una card de torre. Las tres deben inclinarse y escalar ligeramente, con un brillo radial que sigue el cursor; los clics y la selección deben seguir funcionando.
8. **Criterio histórico, sustituido por M57:** el fondo de agua de M56 era oscuro y de bajo contraste. La apariencia vigente se verifica en la sección M57.

M56 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0107](../decisions/ADR-0107-feedback-de-progresion-y-presentacion-de-cards.md).

## M57 — agua luminosa y explosión pixel de enemigos

1. Observa el fondo visible alrededor y entre las celdas: debe mostrar grandes manchas orgánicas azul medio/azul claro sobre espuma casi blanca, con movimiento lento y continuo, parecido a la referencia del usuario. Comprueba 1440×900 y 1280×720; el patrón debe conservar escala razonable y cubrir toda la pantalla.
2. Confirma que `WaterBackgroundLayer` permanece por debajo del tablero, las unidades, los VFX y el HUD; el agua no intercepta clics ni altera terreno, hover, selección o zoom de cámara.
3. Mata enemigos con sprites de proporciones y tamaños distintos, incluyendo uno que se mueve hacia la izquierda y uno durante el salto: el burst debe partir del centro visual, mostrar píxeles con los colores del sprite, respetar espejo y escala, y no usar coordenadas desfasadas.
4. Panea y haz zoom mientras el burst está activo: las partículas deben permanecer junto al lugar del mundo donde murió el enemigo. Abre cards/terreno durante la animación: debe terminar por encima de la UI, sin detenerse.
5. Verifica que cada muerte final reproduce tanto `coins_top` como el burst una sola vez y entrega su recompensa solo una vez; una transformación activada al morir no debe generar ninguna baja falsa.
6. Durante bajas simultáneas confirma que cada efecto conserva su propia textura y orientación, el pool reutiliza emisores al terminar y no quedan partículas visibles en la siguiente baja por datos anteriores. Observa el tiempo de GPU con una oleada densa y sprites grandes.

M57 está implementado en código/documentación; no se ejecutó Godot ni revisión visual o de rendimiento. La aceptación queda pendiente. Ver [ADR-0108](../decisions/ADR-0108-agua-wind-waker-y-explosion-pixel-de-enemigo.md).

## M58 — sombra de nubes y agua anclada a cámara

1. En un mapa con terreno visible, compara el sombreado con la versión anterior: las nubes deben notarse un poco más, sin tapar la textura ni cambiar el brillo del HUD.
2. Panea en ambas direcciones: el patrón del agua debe desplazarse junto al mundo y conservar continuidad respecto a las celdas, sin quedarse fijo en pantalla ni flotar sobre el tablero.
3. Cambia el zoom: el agua debe mantener cobertura completa del viewport, acompañar la escala del mundo y no modificar la posición de los controles, el tablero o la simulación.
4. Confirma que agua y sombra siguen debajo del HUD, y que la animación procedural continúa en el tiempo.

M58 está implementado en código/documentación; no se ejecutó Godot ni revisión visual. La aceptación queda pendiente. Ver [ADR-0109](../decisions/ADR-0109-sombra-de-nubes-reforzada-y-agua-anclada-a-camara.md).

## M59 — mejoras de torre en fila y shake de ronda

1. Selecciona una torre: Health, Armor y Shield deben aparecer en una sola fila, centrados y en botones cuadrados de 128 × 128; ninguno debe caer a una segunda fila en el panel de 500 px.
2. Compara los importes H/A/S con los de `TowerShortcutCard`: deben compartir el panel de fondo, el icono de 24 px, el estilo tipográfico y la alineación.
3. Inicia una ronda: la cámara debe mostrar una sacudida muy ligera y continua; al completarla o fallarla, vuelve al offset base. El shake por daño a la base debe seguir viéndose encima de la oscilación y no cancelarla.
4. Durante una pausa, comprueba que no se acumula movimiento ni se reanuda el shake si la ronda ya terminó.

M59 está implementado en código/documentación; no se ejecutó Godot ni revisión visual. La aceptación queda pendiente. Ver [ADR-0110](../decisions/ADR-0110-mejoras-de-capa-en-fila-y-shake-de-ronda.md).

## M60 — barra de XP y precios de demolición

1. Selecciona una torre con XP parcial en Health, Armor y Shield: las tres barras deben medir 88 × 8 px, verse más gruesas y ser más cortas que el ancho anterior; cada una queda centrada bajo el nivel.
2. Selecciona una torre y comprueba que su botón muestra el icono, `DEMOLER` y el importe `+N` con el icono de Gold. Demuele una torre: debe acreditarse el mismo importe que se mostró y el texto no debe incluir niveles ni upgrades.
3. Selecciona un obstáculo: la acción muestra `DEMOLER` y el coste actual como `−N` con el icono de Gold. Tras demolerlo, el siguiente coste debe aumentar según la curva existente.
4. Selecciona un portal: la acción muestra `RETIRAR` y el coste como `−N`, el doble del obstáculo; el botón sigue respetando el mínimo de tres portales y la fase de preparación.

M60 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0111](../decisions/ADR-0111-barra-de-xp-y-precios-de-demolicion.md).

## M61 — legibilidad de mejoras, HUD y colocación de terreno

1. Abre una oferta de mejoras de run y revisa descripciones con efectos positivos y negativos. Cada cifra positiva debe verse verde y cada perjuicio explícito, como una reducción de daño, rojo. Revisa también mejoras permanentes en el mapa: las cifras de efecto deben conservar esos colores.
2. Selecciona una torre sin mejoras y una torre elevada o mejorada. En Tower Info, Daño, Rango, RPM y Crítico deben compararse con el perfil base: mejoras verdes, reducciones rojas y valores sin cambio con el color normal. Los bonuses de altura y el efecto positivo H/A/S deben verse verdes. Si una mejora reduce el coste de Mana, el coste aparece verde; si lo aumenta, rojo.
3. En `ROUND_PREP` y durante una ronda, pulsa `P` y el botón junto a la vida. El botón debe mostrar solo `P` más el glyph de pausa al jugar y el de play al pausar; ambas acciones deben alternar el estado de pausa.
4. Elige una card de terreno. Debe aparecer sobre las cards de torre el panel prominente `PULSA Q / E PARA ROTAR · T: COLOCACIÓN AUTOMÁTICA`. Comprueba que Q/E rotan, T busca/confirma una posición legal, y el panel desaparece al confirmar o salir de la colocación.
5. Clica un portal: debe aparecer el mismo `ui_click` que al clicar otros interactuables, cerrarse el tooltip y mostrarse en Tower Info la ronda y la lista con retrato, nombre y cantidad asignada a ese portal. Cambia de selección y verifica que la lista anterior no persiste.
6. Compara Gold y Mana en la esquina superior derecha: ambos paneles deben medir 176 × 52 px y usar el mismo fondo 9-slice, separación, iconos de 32 px y cifras de 23 px.
7. Busca `F3` en los controles visibles y pulsa F3 durante la partida: no debe existir ni abrirse ningún panel de terreno/debug. Confirma que la ronda normal sigue el orden secuencial de la campaña de 45 rondas y que la ayuda de colocación de terreno sigue disponible.

M61 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0112](../decisions/ADR-0112-legibilidad-de-mejoras-hud-y-colocacion.md).

## M62 — correcciones de paneles y pausa del agua

1. Inicia una run desde el menú. La escena debe resolver `%RemovalCostLabel` sin `Node not found` ni advertencias de ruta de padre desaparecida. Inspecciona `main.tscn`: la fila de coste, icono y label debe estar bajo `RemovalCostBadge/RemovalCostRow`, sin nodos huérfanos en la raíz.
2. Selecciona una torre con reembolso y un obstáculo/portal con coste. En cada caso, el botón conserva su icono y texto; el panel Gold aparece como hermano a su derecha, fuera de su superficie.
3. Selecciona una torre. Los iconos Health, Armor y Shield deben quedar centrados en sus botones y medir 64 × 64 px. Cambia el tamaño desde `tower_layer_upgrade_button.tscn` y comprueba que el script no lo sobrescribe.
4. En el Inspector de `Main`, ajusta los parámetros `Tower Info layout`. Comprueba que cambian el ancho y la posición responsivos del panel. Cambia los márgenes del `MarginContainer` y verifica que no se reinician al iniciar ni al cambiar la selección.
5. Durante `ROUND_PREP`, clica cada portal. Tower Info debe mostrar el título, ronda, cantidad de enemigos y lista de retratos/nombres/conteos de esa salida; no depende de mantener el cursor encima.
6. Inicia la ronda, pausa con `P` y confirma que el patrón del agua deja de animarse; al reanudar, continúa sin salto de fase.

M62 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación de escena queda pendiente. Ver [ADR-0113](../decisions/ADR-0113-ajustes-de-paneles-y-pausa-de-agua.md).

## M63 — alcance, ghost exacto y mapa de mejoras

1. Coloca una torre en una casilla elevada y otra a nivel de suelo. Al pasar el cursor sobre cada torre y al seleccionarla, el anillo visible debe coincidir con el alcance efectivo del panel.
2. Selecciona una torre para construir y pasa por casillas de elevación distinta. El daño, el alcance del panel, el badge del ghost y su círculo deben coincidir con los valores efectivos tras colocarla, incluyendo cartas activas.
3. Compara una oferta de terreno legal con una ilegal. El ghost debe leerse inmediatamente en lima para válida y rojo para inválida, incluso encima de la textura del terreno.
4. Termina una run usando al menos dos tipos de torre y deja otro tipo desbloqueado sin construir. El resumen debe agrupar cantidad y daño de los tipos construidos, y omitir el tipo sin desplegar.
5. Abre el mapa permanente. Los siete unlocks de torre deben compartir una fila horizontal. Al abrir un unlock, Health, Armor y Shield deben aparecer en una línea horizontal, conectados por separado y poder comprarse en cualquier orden.
6. Revisa nodos generales, torres y capas de mejora: todos deben tener un icono temático. En los nodos con coste, el importe grande queda centrado y el icono `exp.png` a su derecha, alineado en la misma fila.

M63 queda implementado en código/documentación. El smoke de carga headless realizado para M64 no valida el alcance, el ghost ni el mapa durante gameplay; la aceptación visual/interactiva sigue pendiente. Ver [ADR-0114](../decisions/ADR-0114-preview-de-torre-resumen-y-mapa-permanente.md).

## M64 — interfaz editable desde Inspector y limpieza

1. Ejecuta la escena principal y cambia en el Inspector los grupos exportados de Main para Tower Info, lista/tooltip de portales, inventario/ofertas de terreno, colores semánticos, botón de ronda y tamaños tipográficos. Repite inicio, selección de torre/portal, cambio de fase y actualización de filas: los valores deben persistir y no volver a una constante del script.
2. Abre `upgrade_offer_panel.tscn`, `upgrade_offer_card.tscn`, `tower_layer_upgrade_button.tscn`, `meta_progression_map.tscn`, `meta_upgrade_node.tscn`, `round_progress_strip.tscn`, `spawn_portal.tscn` y `main_menu.tscn`; en `main.tscn`, selecciona además `BaseHealthBar` y `BuildCursor`. Modifica un margen, tamaño, fuente, color o StyleBox desde Inspector y ejecuta la escena; la presentación debe reflejar la propiedad guardada. Revisa que el estilo no se reconstruya en `_ready()`.
3. Cambia dimensiones y tipografías de la oferta de mejora y el mapa permanente. Ajusta en `Main` los tamaños de VFX; cambia en `BuildCursor` su tamaño/pulso y en el mapa colores/tamaño/vida de partículas. Verifica anclajes, centrado, enlaces, tooltips y selección a 1280×720 y 1440×900. Los layout de progreso, portal, cards de terreno y feedback H/A/S deben seguir las propiedades expuestas en sus escenas/scripts.
4. En combate, confirma que los iconos de estado se dibujan a 28×28 px, separados 5 px, con stack count y barras alineadas. Revisa que la fuente y el contorno de los números flotantes de daño se controlan desde el nodo Enemy.
5. Ejecuta el escaneo de escenas/código de Godot y la entrada normal a `game/main/main.tscn`; no deben aparecer recursos faltantes, errores de parseo ni nodos no encontrados tras retirar fixtures y script de preview.
6. Comprueba los importes en los `.import`: iconos UI a 256 px, spritesheet de portal a 768 px y cofre a 168 px. Confirma que los PNG fuente no cambiaron, los 26 PNG alternativos y los recursos retirados ya no están en disco, y los perfiles `8`, `9` y `0` siguen cargando.

El escaneo headless del editor y el smoke de tres frames de `game/main/main.tscn` pasan con código 0, sin errores GDScript ni recursos faltantes. El entorno aislado impidió guardar el inicio de run de prueba. M64 queda aceptado tras completar la revisión en ventana y confirmar que los cambios del Inspector sobreviven al ciclo de vida de los controles. Ver [ADR-0115](../decisions/ADR-0115-ui-inspector-y-limpieza-de-recursos.md).

## M65 — spritesheets de correr de enemigos

1. Inicia una ronda y comprueba los 26 tipos de enemigo al aparecer: todos muestran su ciclo de correr desde el primer instante en que entran al camino, sin quedar en una pose estática mientras se mueven.
2. Revisa que cada hoja canónica mide 512×128 px, contiene cuatro cuadros horizontales de 128×128 px y conserva transparencia alrededor del personaje.
3. Recorre tramos de camino que cambien la dirección horizontal: las imágenes originales miran a la derecha y se espejan al avanzar hacia la izquierda, sin invertir el ciclo ni afectar la ruta.
4. Compara enemigos pequeños, medianos y jefes: el personaje debe quedar centrado, alineado a su base y conservar el tamaño visual configurado en su `EnemyData`.

Las hojas están en sus rutas canónicas y el runtime existente selecciona cuatro cuadros a 8 FPS durante `MOVING`. La revisión en ventana Godot queda pendiente. Ver [ADR-0116](../decisions/ADR-0116-spritesheets-de-correr-de-enemigos.md).

## M66 — Oferta aleatoria de reclutamientos y mejoras

1. En la primera oferta de una run con Mortar/Tesla Coil desbloqueadas, comprueba que aparece al menos uno de sus reclutamientos y que los otros dos espacios pueden ser cartas globales o pasivas de Ballista. Debe haber exactamente tres cartas distintas y nunca más de dos reclutamientos.
2. Con varias torres pendientes, repite ofertas/runs: el reclutamiento obligatorio debe poder variar según los pesos/seed; reclutamientos adicionales pueden aparecer en cualquiera de los otros espacios, pero nunca llenan la oferta.
3. Antes de reclutar una torre, sus pasivas específicas siguen ausentes. Tras reclutarla, comprueba que pasan a ser elegibles en ofertas futuras. Las pasivas de torres no reclutadas siguen ausentes; las globales y las pasivas de torres ya reclutadas pueden ocupar los espacios aleatorios.
4. No elijas uno de los reclutamientos disponibles y abre otra oferta en una ronda posterior: debe seguir elegible. Comprueba también una oferta sin torres pendientes, que debe sortear tres cartas normales.

M66 queda aceptado cuando se verifican garantía condicional, límite de dos reclutamientos, mezcla ponderada sin reemplazo, filtros de run y persistencia de no elegidas. Código/documentación integrados; aceptación interactiva pendiente. Ver [ADR-0118](../decisions/ADR-0118-ofertas-de-reclutamiento-aleatorio.md).

## M67 — Feedback de vida de Main Tower

1. En la escena principal, compara la barra de base con la versión previa: pasa de 28 a 42 px de alto y dispone de una fila superior más ancha. La pausa sigue legible junto a ella.
2. Con una base de 10 HP y también con un máximo ampliado por Fortification/cards, confirma que cada HP ocupa un cuadro propio. Al perder un punto, el cuadro perdido hace flash y se encoge/desvanece; al recibir varios puntos de daño, cada cuadro perdido se anima. Curar o reparar repone los segmentos.
3. Observa el relleno con la base completa, a media vida y casi vacía: el color debe cambiar gradualmente de verde a ámbar y rojo, sin saltos entre solo tres colores planos.
4. Al llegar a 3 HP, aparece una viñeta roja tenue en los bordes; a 2 HP se intensifica y a 1 HP se vuelve más clara, con respiración lenta y sutil (aprox. 2,8 s). El centro de juego, los textos y los controles siguen legibles. Comprueba que desaparece al sanar por encima de 3 HP y que la run sigue cómoda durante varios minutos a 1 HP.

M67 queda integrado en código/documentación. La inspección visual e interactiva en Godot sigue pendiente; no se ejecutó Godot en este cambio. Ver [ADR-0119](../decisions/ADR-0119-feedback-de-vida-de-base.md).

## M68 — Velocidad de simulación de la partida

1. En la escena de juego, confirma que el nuevo botón queda junto al de pausa y muestra ×1 al iniciar.
2. Pulsa sucesivamente el botón: debe pasar a ×2, luego ×3 y volver a ×1. El mundo, enemigos, torretas y temporizadores de ronda deben avanzar con el multiplicador visible.
3. Pausa en ×2 y ×3. El juego debe detenerse y, al reanudar, continuar con el multiplicador elegido antes de pausar.
4. Vuelve al menú e inicia otra run. Debe comenzar en ×1 sin heredar el multiplicador de la run anterior.

M68 queda integrado en código/documentación; la inspección visual e interactiva queda pendiente. No se ejecutó Godot. Ver [ADR-0120](../decisions/ADR-0120-control-de-velocidad-de-partida.md).

## M69 — Color y gradiente de las fachadas elevadas

1. En la partida, revisa las fachadas Grass y Mountain: su borde superior debe mostrar los colores `#407850` y `#3b3c41`, respectivamente; no deben verse casi negras en toda su altura.
2. Revisa la transición vertical de cada pared: el negro se ve en la base y su alfa desaparece progresivamente hasta transparente en la parte superior. La tapa no recibe este sombreado.
3. Compara tablero, ghost/preview de expansión y miniaturas de cartas. Los colores y el gradiente deben coincidir en las tres presentaciones, sin cambiar el contorno, altura ni oclusión Y-sort de las paredes.

M69 queda integrado en código/documentación; la revisión visual en Godot queda pendiente. No se ejecutó el motor. Ver [ADR-0121](../decisions/ADR-0121-color-y-gradiente-de-fachadas.md).
