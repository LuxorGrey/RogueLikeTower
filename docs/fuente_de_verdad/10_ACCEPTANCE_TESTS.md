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
- Mejorar aumenta los stats configurados hasta `max_level`; una mejora posterior se bloquea. En M6 los upgrades son gratuitos como placeholder; costes quedan pendientes de M9.
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
- Los tags Físico/Fuego/Arcano se validan como bitmask; cada enemigo declara sus multiplicadores recibidos y los tags combinados multiplican sus resultados.
- La regeneración por segundo acumula fracciones, no supera la vida máxima y solo corre mientras el enemigo sigue vivo. El counter reduce la regen según su fuerza durante la duración configurada; varios impactos usan la mayor fuerza y el máximo tiempo restante.
- `DamageService.preview_damage()` y `apply_damage()` usan el mismo cálculo; el servicio emite un resultado con armadura absorbida, multiplicador de tipo, HP aplicado y objetivo derrotado.
- El HUD muestra HP, armadura, regen base/efectiva y daño estimado del objetivo de la torre seleccionada; la descripción de torre presenta su perfil configurado.
- Se pueden seleccionar los perfiles de prueba Basic Bolt (6 HP al fixture), Perforadora (9 HP) y Drenadora Arcana (7 HP y 100% de contrarregeneración durante 1.25 s) contra el blindado de armadura 4, regen 2 HP/s y multiplicador arcano 1.25. Estos valores son placeholders.
- Status y sus payloads no se aplican en M7; recompensas por muerte permanecen pendientes de M9.

### Prueba manual de M7 en el juego
1. Ejecutar `game/main/main.tscn`. La interfaz principal debe limitarse a base, estado de oleada, selección de oleada, resumen de torre y diagnóstico del objetivo. La cabecera muestra permanentemente **F3 - Terreno   H - Interfaz**; `F3` abre/cierra el panel técnico del terreno y `H` oculta/muestra todo el HUD.
2. Elegir **Diagnóstico · blindado regenerador**. Construir una torre de prueba próxima al camino usando `1` (Basic Bolt), `2` (Perforadora) o `3` (Drenadora); las tres opciones deben estar visibles en la barra inferior. Hacer clic en una casilla libre de Grass/Montaña.
3. Iniciar la oleada seleccionada. Seleccionar la torre si hace falta. Cuando el enemigo entre en alcance, el debug compacto debe mostrar vida actual/máxima, armadura, regeneración y daño estimado; si el counter está activo también debe mostrar la regen efectiva reducida.
4. Repetir con cada perfil: Basic Bolt estima 6 HP; Perforadora estima 9 HP porque solo aplica 1 punto de armadura; Drenadora estima 7 HP por vulnerabilidad arcana y, tras impactar, reduce la regen a 0 HP/s durante hasta 1.25 s.
5. Al completar una oleada debe habilitarse la expansión y la selección de oleada. Cambiar a **Oleada básica · 3 enemigos**, iniciar y completarla; después volver a elegir el diagnóstico e iniciarlo de nuevo. Coloca suficientes torres para derrotar enemigos y conservar vida de base durante la prueba: el HP perdido persiste entre fixtures. Repetir oleadas no debe dejar enemigos de la anterior ni bloquear el botón de inicio. Esta repetición sirve para depurar y no sustituye el loop de 20 rondas M10.
6. Con Basic Bolt, observar el HP del blindado entre impactos: la vida perdida debe recuperarse a ritmo de 2 HP/s mientras no haya counter activo, hasta el máximo 60. Con Drenadora, no debe subir durante la contrarregeneración activa.

Para cerrar M7 deben pasar todos los criterios anteriores y la prueba manual debe confirmar que el HUD refleja los valores reales durante combate, que los atajos 1–3 funcionan incluso tras usar controles de interfaz y que se pueden iniciar oleadas distintas repetidamente. También se debe revisar que el HUD compacto y el panel F3 caben en la ventana de 1440×900. Los perfiles y cifras no se convierten en balance confirmado.

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
