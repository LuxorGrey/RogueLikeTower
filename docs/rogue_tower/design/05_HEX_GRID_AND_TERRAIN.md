# Hex Grid, Terrain Pieces & Visual Elevation

## 1. Coordenadas
Usar coordenadas axiales `(q,r)` con 6 vecinos. La orientación provisional del prototipo es pointy-top, registrada en [ADR-0001](../decisions/ADR-0001-cuadricula-axial-pointy-top.md); mantenerla en todo el grid y reabrirla solo al revisar el arte propio.

Toda lógica usa coordenadas hex. Nunca inferir conectividad mirando píxeles.

## 2. Pieza de 7 hexágonos
La pieza es una agrupación lógica. No debe ser un único sprite gigante como fuente de gameplay.

Requisito:
- 7 `TerrainPieceCellData`.
- una celda origen/pivote.
- seis rotaciones posibles.
- preview de toda la pieza.
- cada celda conserva terreno, altura y conexiones tras rotar.

La plantilla de loseta de 7 hexágonos confirmada por el usuario usa el centro `(0,0)` y sus seis vecinos inmediatos: `(0,-1)`, `(1,-1)`, `(1,0)`, `(0,1)`, `(-1,1)` y `(-1,0)`. Sus seis orientaciones válidas se obtienen rotando en pasos de 60° alrededor de `(0,0)`. Esa huella define el tamaño de cada pieza de terreno, no el tamaño del tablero de inicio.

Las celdas de la plantilla pueden ser PATH, GRASS o MOUNTAIN. La vista diferencia esos tipos mediante arte PNG en tres variantes por terreno; no dibuja iniciales ni coordenadas encima de las caras. El panel de terreno muestra axial `(q,r)`, tipo y altura al pasar el cursor por una cara superior. El conjunto tiene tres variantes por tipo. Desde la sustitución artística del 2026-10-13, las caras PATH usan el arte genérico Dirt_01/02/03, sin camino pintado; PATH conserva su identidad lógica y las flechas animadas siguen indicando el recorrido. Ver [ADR-0058](../decisions/ADR-0058-arte-dirt-en-texturas-path.md).

El tablero inicial está separado de las piezas de expansión y se configura en `data/terrain/starting_board.tres`: ocupa un hexágono axial de radio 2 (19 celdas) y coloca la base en `(-1,0)` para permitir un camino recto sin ampliar el tablero. `StartingBoardData` valida 19 coordenadas únicas, terreno/elevaciones permitidos, una huella conectada y que las seis celdas vecinas a la base no superen elevación 1. PATH permanece a 0 y Grass junto a la base a 1; Mountain no puede formar parte de ese anillo. La generación vuelve a aplicar el límite, y normaliza a Grass cualquier Mountain que llegase a una posición vecina de la base. La ruta inicial va en línea recta por `(-1,0) → (0,0) → (1,0) → (2,0)` y la salida exterior queda en `(3,0)`: cuatro celdas PATH contando base y spawn. En campaña, `PathGraph` además rechaza cualquier endpoint cuya ruta mínima a la base tenga menos de cuatro celdas PATH; se conserva esa distancia también al colocar expansiones. El tablero lineal se registra en [ADR-0056](../decisions/ADR-0056-tablero-inicial-lineal.md); las elevaciones se mantienen dentro de [ADR-0073](../decisions/ADR-0073-elevaciones-y-bonus-de-torre.md) con el límite adicional de [ADR-0087](../decisions/ADR-0087-props-obstaculos-y-altura-junto-a-base.md).

Desde M10, las expansiones rellenan al azar con Grass o Mountain los espacios vacíos completamente encerrados dentro de la envolvente axial del tablero. Un espacio conectado a un borde exterior o a una salida PATH abierta queda vacío. Los rellenos son celdas construibles y no forman parte de una pieza del jugador. Grupos conectados de 3–4 Grass/Mountain reciben un brillo tenue de combo 3; grupos de 5 o más reciben un brillo algo más intenso de combo 5. Es señal visual sin bonus numérico confirmado. El catálogo contiene las cinco plantillas originales y diez Resources adicionales: Pradera de colinas, Macizo montañoso, Llanura abierta, Cresta escalonada, Loma aislada, Picos gemelos, Pradera con ramal sin salida, Curva junto al acantilado, Camino serpenteante y Bifurcación del barranco. Todas conservan la huella central de siete celdas y las conexiones PATH internas son recíprocas; cuatro piezas nuevas amplían rutas y giros.

## Obstáculos, cofres y variantes visuales

Actualización artística (ADR-0058): Path_01/02/03 usa las ilustraciones Dirt_01/02/03 sin camino pintado. Es un cambio de textura únicamente; `PATH`, sus sockets, el `PathGraph` y las flechas animadas mantienen su comportamiento.

Cada celda de Path, Grass o Mountain recibe props decorativos deterministas a partir del seed y de su coordenada axial; en una oferta se usa su seed estable de oferta y coordenada local. Cada asset compatible con el terreno tiene una tirada independiente del 10 % por celda. La selección evita repetir el mismo asset dentro de la celda y conserva como máximo dos; no ocupa ni bloquea la celda y no crea una superficie interactiva. Los PNG se recortan al alfa y normalizan a 96×96 px, se dibujan a 36×36 px en posiciones separadas y nunca se seleccionan. Si comparten celda con obstáculo, este se dibuja delante. La miniatura sin ancla enseña el contenido de oferta; al colocar junto a la base, el ghost y el tablero confirmado convierten Mountain a Grass y regeneran juntos los props compatibles con el terreno resultante a partir de la coordenada global.

Los portales usan `assets/terrain/spawn_portal_SpriteSheet.png`, un atlas de 4×2 con ocho frames cuadrados de 443×443 px. La animación recorre los ocho frames en bucle continuo a 10 FPS. Cada endpoint recibe una fase inicial determinista y única, guardada durante la run; al actualizar una colocación, los portales existentes no se reinician ni se sincronizan.

Grass tiene 25 % de probabilidad de obstáculo, Mountain 15 %; PATH no genera obstáculos. El pool runtime reemplaza los antiguos cinco sprites con ocho assets: matorral, tronco caído, montón de ramas, tocón, rocas y madera, caja de suministros, raíces expuestas y roca musgosa. El panel de selección muestra el nombre que corresponde al sprite. El obstáculo es contenido del hex, no un tipo de terreno, elevación, nodo ni borde de `PathGraph`; bloquea construir en esa celda igual que una celda PATH. Una pieza de expansión admite como máximo dos obstáculos entre sus siete hexes. El tablero inicial admite uno como máximo en total y excluye la celda de base y sus seis vecinas inmediatas. En `ROUND_PREP`, el jugador puede seleccionar y pagar para quitar un obstáculo. La retirada n cuesta `25 × n²` Gold, donde n es el ordinal de retirada: 25, 100, 225, 400… Las retiradas de portales no incrementan ese contador. Ver [ADR-0079](../decisions/ADR-0079-limites-de-obstaculos-y-cierre-visual-del-terreno.md) y [ADR-0087](../decisions/ADR-0087-props-obstaculos-y-altura-junto-a-base.md).

Una celda Grass/Mountain sin obstáculo tiene un 1 % de probabilidad base de cofre. «Suerte del explorador» suma cinco puntos porcentuales por nivel en cuatro niveles; el último incremento queda limitado por el tope y la posibilidad máxima es 20 %. En expansiones, la probabilidad se calcula al confirmar la colocación: ni la miniatura de la pieza ni el ghost muestran cofres. Si la tirada tiene éxito, el cofre aparece en el tablero con un salto único. PATH, obstáculos y cofres son excluyentes. Hacer clic en un cofre cerrado lo abre y entrega Gold; la recompensa inicial del juego es 25 Gold por cofre y se considera balance provisional configurable. Una celda con cofre cerrado no admite construcción. Al pasar el cursor por un cofre, este bota y recibe un resplandor dorado.

El PNG de terreno contiene nueve imágenes: tres variantes por cada tipo Path/Grass/Mountain. `TerrainVisualCatalog` recorta por variante el área visible y la coloca en el rectángulo exacto de la cara hexagonal; así elimina el desfase que producía el padding distinto entre casillas del atlas. Los ocho obstáculos actuales son PNG separados con nomenclatura `obstacle_<nombre>.png`, normalizados a 208×208 px; la caja común de dibujo sigue en 86×86 px (`OBSTACLE_DISPLAY_SIZE`), sin desplazamiento del centro de celda. La textura se estira para ocupar la caja completa tanto en el tablero como en las cards. Los props viven en `random_props/{grass,mountain,path}/`, usan nombres `prop_<terreno>_<nombre>.png`, mantienen alfa y miden 96×96 px. Se dibujan a 36×36 px con una tirada del 10 % por asset y celda, hasta dos props sin solaparse. El contenido visual no cambia huellas, sockets, elevación ni selección axial.

Cada oferta crea copias de sus piezas y fija el roll de obstáculo y props por seed, ronda, índice de oferta, ID de pieza y coordenada local. Ghost y tablero confirmado conservan la oferta; en el anillo de base, la normalización de terreno y props se refleja de forma idéntica en ambos. La miniatura no tiene ancla global y conserva los tipos/props sin colocar. Las miniaturas usan las tapas hexagonales texturadas, las fachadas y el orden axial del tablero, además de las alturas de esa copia de oferta. Los cofres se sortean únicamente al confirmar la colocación y se muestran después en el tablero. El tablero inicial y los rellenos interiores usan los rolls reproducibles por seed y coordenada axial. El tamaño de obstáculo continúa el objetivo de caja de [ADR-0046](../decisions/ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md); arte, centro y props se actualizan en [ADR-0087](../decisions/ADR-0087-props-obstaculos-y-altura-junto-a-base.md). La consistencia de preview sigue [ADR-0060](../decisions/ADR-0060-ofertas-de-terreno-y-contenido-determinista.md) y [ADR-0083](../decisions/ADR-0083-timeline-fijo-de-quince-rondas-y-preview-fiel.md).

Las aristas del hex y los sockets PATH permanecen ocultos mientras no haya hover. Al pasar el cursor por una celda se dibujan su borde y conexiones de ruta; los bordes de los anillos vecinos se atenúan por distancia axial. Las flechas de flujo siguen visibles en la ruta para enseñar el sentido hacia la base. Cada spawn alcanzable muestra un portal PNG pulsante en su celda exterior, sin texto ni cartel. Al pasar el cursor sobre el portal, su silueta recibe un contorno y un tooltip enumera los enemigos y la cantidad que se asignará a esa salida en la siguiente ronda. Al hacer clic, el panel de información presenta la misma asignación como lista con el sprite de cada enemigo. Encima de cada portal se ven iconos de esos tipos, con una cifra para cantidades repetidas. El reparto se calcula con la misma política de `WaveDirector`: en campaña, round-robin global entre endpoints alcanzables, reiniciado al iniciar cada ronda; en fixtures DEBUG se respeta la política configurada por grupo. La previsión se actualiza al cambiar la ronda y al mover el grafo candidato. Al seleccionar una pieza y mover el preview a una colocación válida, los portales pasan al `PathGraph` candidato y se sitúan en sus endpoints previstos; el tono verde indica ese estado. Una colocación inválida o cancelada restaura los portales del grafo activo. En `ROUND_PREP`, también se puede quitar un portal pagando el doble del precio actual de obstáculo (50 Gold inicialmente). Deben permanecer al menos tres spawns; al retirarlo, el total de enemigos de la oleada se conserva y el `WaveDirector` los reparte de nuevo entre las salidas activas.

La silueta NO tiene por qué ser siempre el hexágono central + seis vecinos si en el futuro se diseñan otras formas de 7 celdas. El sistema debe soportar cualquier conjunto conectado de 7 hexes.

Sin una torre seleccionada ni una pieza en colocación, el hover muestra un tooltip pequeño junto al cursor: tipo de terreno, disponibilidad/ocupación y altura. En Grass/Mountain añade el bonus calculado para las torres compatibles desde sus `TowerData`; en el roster vigente cada nivel aporta +1 daño y +0,5 hex de alcance. PATH se identifica como ruta no construible. El tooltip se oculta durante una selección, sobre la interfaz o mientras otro panel contextual está activo. Ver [ADR-0072](../decisions/ADR-0072-controles-y-tooltip-de-celdas.md).

## 3. Validación de colocación
Una colocación es legal si:
1. Ninguna de sus 7 celdas solapa una celda existente.
2. La pieza toca el mapa existente por al menos un borde.
3. Si el diseño requiere conexión de camino, al menos una entrada de Path de la pieza conecta con un Path existente.
4. Ninguna salida PATH explícita apunta a terreno que no sea PATH; las ofertas flexibles solo conectan con otra celda PATH.
5. Tras colocarla, el/los spawns que deban conservar ruta hacia la base siguen teniendo una ruta válida de al menos cuatro celdas PATH.
6. No se crea una celda construible inaccesible visualmente por error de renderer (solo validación de desarrollo).

Regla de diseño: las conexiones de camino se definen explícitamente por borde; no asumir que dos celdas PATH adyacentes conectan si la plantilla visual dice lo contrario.

Contrato ejecutado por M3, registrado en [ADR-0004](../decisions/ADR-0004-contrato-colocacion-terreno.md):
- `path_edges` es una máscara de seis bits. Dirección 0 = este `(1,0)`, 1 = sureste `(0,1)`, 2 = suroeste `(-1,1)`, 3 = oeste `(-1,0)`, 4 = noroeste `(0,-1)`, 5 = noreste `(1,-1)`; el borde opuesto es `(dirección + 3) mod 6`.
- Las conexiones internas de una pieza requieren `path_edges` recíprocos entre dos PATH. Si una conexión interna apunta a otra clase de terreno o no es recíproca, el Resource es inválido.
- Cuando un `path_edges` externo sale de la huella, se derivan dos sockets laterales flexibles en las caras contiguas que también queden fuera de la huella. Se rotan con la pieza y se ven como brazos laterales más tenues. Permiten conectar una pieza por el borde central o por cualquiera de esos laterales, siempre que los hexágonos vecinos sean PATH y la otra cara ofrezca el borde exacto o flexible complementario.
- Las salidas explícitas sin pareja siguen siendo errores si enfrentan una celda existente; una salida flexible es opcional y puede quedar abierta o mirar a terreno que no sea PATH. `requires_path_connection` exige al menos una salida externa explícita y que durante la colocación una conexión compatible llegue a un PATH existente.
- El `HexGrid` confirma las siete celdas de forma atómica después de validar. El Resource original no se modifica; las celdas rotadas son copias y reciben un `piece_instance_id`.
- M3 muestra una torre fantasma con shader verde translúcido cuando la colocación es legal y rojo cuando no lo es, por encima de terreno y props. El cursor se ajusta a coordenadas axiales; clic izquierdo o el botón del HUD confirma, `Esc`, clic derecho o Cancelar abandona el preview. Durante una colocación de terreno, `Q`/`E` y la rueda del ratón giran 60°; `T` confirma una ubicación automática válida conservando las reglas de ruta. Fuera de la colocación, la rueda sigue controlando el zoom.
- Las miniaturas de cards de expansión no dibujan los brazos/ramificaciones de conexión PATH: muestran las superficies del terreno y los props para comunicar la forma y el contenido sin superponer el grafo de navegación.
- M4 implementa la verificación global mediante `PathGraph`: el snapshot activo solo cambia al iniciar o confirmar terreno. Mientras se mueve un ghost geométricamente válido, `Main` deriva un snapshot candidato independiente y `TerrainPiecePreview` actualiza la comparación de spawns sin mutar el tablero ni sustituir el grafo activo. La confirmación usa esa misma validación y se rechaza si falta la base, no queda ningún endpoint spawn, una salida exacta no encuentra socket complementario o una celda PATH/spawn no tiene ruta a la base. El control visual de celdas construibles inaccesibles sigue siendo revisión de desarrollo.

## 4. Bifurcaciones y convergencias
El grafo permite grado > 2.
- Bifurcación: un nodo/ruta puede tener varias salidas.
- Convergencia: varias ramas pueden llegar a una misma sección.
- El comportamiento exacto de selección de rama del enemigo debe ser configurable/determinista.

Prototipo recomendado:
- cada spawn calcula la ruta de menor coste hasta la base;
- si hay empate, usar tie-break determinista basado en coordenadas/run seed.

## 5. Spawn endpoints
No asumir que cada endpoint es siempre un spawn.
`PathGraph` expone endpoints; `WaveDirector` decide cuáles están activos según ronda/reglas.

Esto permite que ampliar terreno "haga que puedan venir desde más sitios" sin obligar a activar todos inmediatamente.

En M4, cada salida exacta `path_edges` que queda abierta hacia una coordenada fuera del tablero se presenta como candidato spawn. Las aperturas exclusivamente flexibles no son endpoints; solo forman conexión cuando una celda PATH vecina ofrece la cara recíproca. El endpoint guarda la celda PATH, la dirección axial y la coordenada exterior para que M5 pueda colocar el enemigo antes de recorrer la ruta. Durante la previsualización, los endpoints que cerrarían permanecen en su sitio con una X roja y el estado indica el número de cierres. En campaña, cada oferta incluye una card `EXTIENDE RUTA` con una colocación validada para prolongar una ruta alcanzable; la forma sugerida varía entre recta, curva y bifurcación, y algunas ofertas no contienen ninguna recta. Una colocación de campaña se rechaza si su tablero resultante no conserva al menos una siguiente colocación legal que extienda una ruta. Durante toda la selección de terreno se deshabilitan las acciones de torres, construcción y cofres; el jugador elige, rota, coloca o cancela la pieza y puede pausar con `P` o el botón bajo la vida. En `ROUND_PREP`, iniciar ronda quita la pausa; durante la selección de terreno no se puede iniciar. En campaña M10 se activan todos los endpoints PATH abiertos con ruta a la base y cada enemigo se asigna en round-robin global a uno de ellos; los fixtures DEBUG siguen la política de spawn de cada grupo. Cada portal alcanzable muestra el icono y conteo de tipos asignados a esa salida en la siguiente ronda, y al hover presenta el detalle y un contorno de su silueta alfa. Flechas luminosas en movimiento siguen cada arista de ruta hacia la base; se conservan las ramificaciones y los enlaces compartidos se dibujan una sola vez. `Ctrl+D` alterna el overlay de diagnóstico de rutas BFS y base; `WASD` desplaza la cámara. El mapa recalcula estos indicadores junto con el `PathGraph` al confirmar terreno. La partida usa ahora un tablero semilla de 19 celdas, `GameBase` en `(-1,0)` y la ruta recta descrita arriba; cada ruta de spawn a base debe contener cuatro o más celdas PATH. Véase [ADR-0007](../decisions/ADR-0007-grafo-logico-de-caminos.md), [ADR-0025](../decisions/ADR-0025-tablero-inicial-y-ruta-minima.md), [ADR-0051](../decisions/ADR-0051-navegacion-prevision-portales-y-panel-torre.md), [ADR-0056](../decisions/ADR-0056-tablero-inicial-lineal.md), [ADR-0057](../decisions/ADR-0057-expansion-con-prolongacion-garantizada.md), [ADR-0060](../decisions/ADR-0060-ofertas-de-terreno-y-contenido-determinista.md) y [ADR-0061](../decisions/ADR-0061-pausa-y-fases-de-expansion.md).

`PathGraph` mantiene una arista cuando ambas caras PATH ofrecen socket exacto o flexible complementario. Resuelve una ruta mínima por número de enlaces con BFS y desempate por orden de direcciones de `HexCoord`. La adyacencia conserva caminos alternativos en bifurcaciones y convergencias aunque cada spawn tenga una ruta cacheada escogida para el prototipo. El grafo activo se recalcula al iniciar/confirmar; durante el movimiento de un ghost legal se crea el grafo candidato separado para actualizar la vista previa. El flujo animado usa la ruta candidata si la colocación es válida; `Ctrl+D` muestra la información estática de diagnóstico.

## 6. Elevación
Altura lógica:
- 0: PATH.
- 1: Grass.
- 2: Grass o Mountain.
- 3: Mountain.

Representación visual:
```text
logical_position = hex_to_world(coord)
draw_position.y = logical_position.y - elevation * ELEVATION_PIXEL_OFFSET
```

Los cliffs rellenan visualmente la diferencia con vecinos más bajos.

La selección/click debe mapear correctamente al HexCoord aunque el sprite esté desplazado.

Cada nivel eleva visualmente la cara superior 28 px (antes 18 px), valor único definido en `HexMath`; la elevación lógica va de 0 a 3 y no cambia reglas de movimiento. PATH usa 0, Grass 1–2 y Mountain 2–3. Una torre en altura h gana +h de daño base y +0.5 × h de alcance; la lógica de alcance aplica este bonus. En torres cuyo `TowerData.mana_cost_scales_with_damage` esté activo, el aumento de daño también escala el coste efectivo de Mana por ataque. Las elevaciones se sortean de forma reproducible a partir del seed, coordenada e identidad de oferta. La geometría usa una única retícula entera axial de vértices pointy-top: una clave entera `(u,v)` identifica cada vértice común a las celdas vecinas y se transforma a pantalla una sola vez. Tapa, fachada, selección y copia Y-sorted usan esa misma geometría; ya no se recalculan las esquinas con seno/coseno por celda. Las tapas son polígonos cerrados de seis vértices y la textura se recorta con UV normalizados, no como rectángulo deformable. Las cards usan las mismas tapas y muestran la elevación de la oferta. Las dos fachadas delanteras usan la textura PNG del tipo de terreno (`Grass` o `Mountain`) y un degradado multiplicativo desde el color actual en la parte superior hasta un tono muy oscuro abajo; el degradado solo afecta paredes y no modifica las tapas. Los UV mantienen densidad estable y repiten el PNG sin estirar la textura. Cada pared cubre solo la diferencia entre la elevación de su celda y la de la celda vecina que comparte ese borde, a razón de 28 px por nivel; si el borde da al vacío, llega al suelo. Las paredes no invaden la tapa vecina y una arista entre tapas a igual altura no genera pared. En pointy-top solo se dibujan las aristas delanteras de las direcciones axiales 1 y 2; las dos aristas laterales y las dos traseras no generan geometría de pared. Cada pared es un quad derivado de la arista original y su copia desplazada verticalmente: no se añaden tapas, cierres, profundidad radial ni vértices extra de esquina. Las dos fachadas delanteras conservan así el contorno del hex y se encuentran sin rellenos de otro color. La tapa superior permanece como polígono axial cerrado de seis vértices y ninguna pared se dibuja por encima; tablero, ghost y miniaturas comparten esta regla. Las copias de tapas elevadas participan en `Entities.y_sort_enabled` en el centro proyectado de su superficie y permiten que la tapa oculte objetos situados detrás; cada fachada se ordena por su borde inferior, a la altura de la tapa vecina o del suelo. Base, torres, enemigos, portales y props comparten la capa Z para la profundidad. El offset artístico de 6 px hacia abajo no altera las posiciones lógicas. El preview de colocación de Ballista muestra el bonus de daño de la celda bajo el cursor. El renderer modula la textura superior con un tinte multiplicativo muy tenue, compartido con la tapa Y-sorted, en pasos de `R −0,01` y `G −0,005` por nivel (máximo 3; B no cambia), sin sustituir las texturas ni alterar polígonos, UV o cámara. Ver [ADR-0082](../decisions/ADR-0082-tinte-multiplicativo-por-elevacion.md), [ADR-0084](../decisions/ADR-0084-render-axial-de-terreno-y-profundidad-por-celda.md), [ADR-0085](../decisions/ADR-0085-solo-fachadas-delanteras-y-degradado-de-cliffs.md) y [ADR-0090](../decisions/ADR-0090-fachadas-limitadas-a-la-diferencia-de-elevacion.md). Véase [ADR-0043](../decisions/ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md), [ADR-0048](../decisions/ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md), [ADR-0073](../decisions/ADR-0073-elevaciones-y-bonus-de-torre.md), [ADR-0079](../decisions/ADR-0079-limites-de-obstaculos-y-cierre-visual-del-terreno.md) y [ADR-0083](../decisions/ADR-0083-timeline-fijo-de-quince-rondas-y-preview-fiel.md).
No se generan sombras en el tablero: se eliminaron el overlay, el shader y las llamadas de dibujo para terreno y obstáculos. La elevación se comunica con las dos fachadas delanteras texturadas, offset visual y oclusión Y-sort; las caras laterales/traseras y los cierres de vértice no se dibujan. Esta retirada sustituye la técnica temporal de [ADR-0068](../decisions/ADR-0068-sombras-recortadas-por-elevacion.md) mediante [ADR-0070](../decisions/ADR-0070-sin-sombras-y-rutas-limpias-en-expansion.md) y el modelo de cierres de [ADR-0084](../decisions/ADR-0084-render-axial-de-terreno-y-profundidad-por-celda.md) queda limitado por [ADR-0085](../decisions/ADR-0085-solo-fachadas-delanteras-y-degradado-de-cliffs.md).

El hover solo detecta las caras superiores: PATH resalta en `#82BFE6`, GRASS en `#80E085` y MOUNTAIN en `#F5C25C`. Sin hover no se muestran bordes blancos del grid ni sockets PATH. El hover dibuja el contorno de la celda y atenúa sus dos anillos axiales; no dibuja líneas de sockets encima del camino. Al seleccionar una pieza de expansión, las flechas de flujo se ocultan hasta cancelar o confirmar. En el preview aislado, el HUD muestra coordenadas locales; sobre el tablero M3 muestra las coordenadas axiales globales `(q,r)`, el terreno y la altura. Los cliffs no son superficies seleccionables. Desde M10 los clusters de terreno muestran un leve brillo animado para combos visuales de 3/5, sin cambiar sus stats.

Estado del preview M3: las 19 celdas del tablero inicial y las piezas confirmadas se dibujan desde `HexGrid`; el ghost se compone sobre esas celdas. El tablero y el preview técnico permiten distinguir sockets PATH exactos y sus brazos laterales flexibles; las miniaturas de las cards de expansión los omiten según [ADR-0071](../decisions/ADR-0071-marco-de-cards-y-colocacion-automatica.md), pero comparten el material y el Y-sort axial del terreno normal. El HUD informa coordenada axial global, terreno, altura, legalidad y cantidad de conexiones. Las caras superiores usan PNG recortados por variante y las fachadas elevadas usan sprites de Grass/Mountain. La base reserva la celda lógica PATH `(-1,0)`; conserva su PNG fuente de 270×352 px y se dibuja uniformemente dentro de un footprint de 86×86 px, menor que un hexágono sin remuestrear el asset. Ver M41/ADR-0089.

## 7. Filosofía visual Urtuk-like
- Grid estricta por debajo.
- Arte orgánico por encima.
- Top de terreno, cliffs y props son capas separables.
- Árboles/rocas pueden sobresalir del footprint visual.
- El footprint lógico nunca cambia por decoración.
- La elevación se ve con una cara superior y sprites de pared/fachada cerrados, no geometría 3D.
- Variantes visuales rompen repetición.

## 8. Orden de dibujo
Prioridad aproximada:
1. fachadas delanteras, limitadas al desnivel expuesto respecto a la celda vecina;
2. tapas hexagonales completas; ninguna pared puede cubrirlas;
3. ruta y flujo de flechas sobre las caras PATH;
4. superficies elevadas texturadas junto con props y entidades bajo `Entities.y_sort_enabled`;
5. proyectiles/VFX;
6. overlays de selección.

El filtro lineal se aplica a la ilustración de suelo, torres, enemigos, base, props y cofres. Unidades, decoraciones de mundo, tapas elevadas y fachadas usan `Entities.y_sort_enabled`, con la posición Y proyectada del anclaje como autoridad; la posición Z permanece igual para que Godot pueda compararlas. Las tapas se ordenan por la superficie elevada; cada fachada tiene un nodo propio anclado a su borde inferior, que coincide con la tapa vecina o el suelo. Así una fachada cubre actores que pasan detrás y queda detrás de los que pasan por delante, pero no se prolonga sobre las tapas. La malla lógica axial entera es la única autoridad de los seis vértices de cada tapa; cada celda dibuja solo sus dos fachadas delanteras como quads verticales, sin geometría de pared en laterales/trasera ni cierres de esquina. Las fachadas usan la textura del terreno y un degradado inferior oscuro exclusivo de las paredes. En el preview y las miniaturas se conserva el dibujo por celda back-to-front y la misma regla de desnivel. Los VFX y la interfaz conservan sus capas propias. Ver [ADR-0084](../decisions/ADR-0084-render-axial-de-terreno-y-profundidad-por-celda.md), [ADR-0085](../decisions/ADR-0085-solo-fachadas-delanteras-y-degradado-de-cliffs.md), [ADR-0090](../decisions/ADR-0090-fachadas-limitadas-a-la-diferencia-de-elevacion.md) y M41/ADR-0089.

Probar oclusión con torre en altura 2 y enemigo en camino 0.

## 9. Preview
Durante expansión:
- pieza fantasma;
- verde = legal;
- rojo = ilegal;
- destacar bordes de camino que conectan/no conectan;
- tecla/botón para rotar izquierda/derecha en pasos de 60° (seis orientaciones sobre el grid);
- confirmar colocación solo si legal.

## 10. Debug obligatorio
Toggle para mostrar:
- coordenadas q,r;
- elevation;
- terrain type;
- path edges;
- endpoints;
- ruta de cada spawn;
- footprint de pieza.

En el prototipo M4, `Ctrl+D` alterna el overlay de rutas cacheadas y el marcador de base. Los puntos de spawn alcanzables se muestran siempre mediante el portal pulsante en la celda exterior. Desde ADR-0041, las rutas alcanzables también muestran cheurones animados que recorren las conexiones hacia la base; las ramas y convergencias permanecen visibles. El overlay no rotula hexes: coordenadas, terreno y altura se consultan al hacer hover y el panel HUD resume nodos, endpoints y bifurcaciones. La animación es solo informativa; no modifica la ruta ni la selección de camino del enemigo.

## 11. Navegación del mapa
- `Camera2D` controla el tablero; `CanvasLayer` mantiene la interfaz fija.
- Botón central del ratón + arrastre desplaza el mapa. La velocidad compensa el zoom actual.
- `W`, `A`, `S`, `D` desplazan la cámara de forma continua; las diagonales se normalizan y el zoom mantiene una velocidad aparente estable. Al perder el foco se limpian las teclas mantenidas.
- Rueda del ratón acerca o aleja alrededor del cursor, dentro del rango provisional `0.45×`–`2.5×`.
- `H` muestra u oculta el HUD. `R` devuelve el zoom a `1×` y centra la cámara sobre el tablero colocado. `Ctrl+D` muestra u oculta el overlay diagnóstico de rutas.
- Estos controles y límites son decisiones provisionales de interfaz, registradas en [ADR-0005](../decisions/ADR-0005-navegacion-de-mapa.md).

## Integración M5

La muestra histórica M5 instanciaba `GameBase` en PATH `(0,0)`; la campaña actual usa `(-1,0)` según [ADR-0056](../decisions/ADR-0056-tablero-inicial-lineal.md). El enemigo aparece en la coordenada exterior del endpoint seleccionado, avanza por los centros de `PathRoute.cells` y alcanza el objetivo; la llegada aplica `EnemyData.base_damage`. La base puede agotarse y emitir derrota. Su ubicación y valores no cambian la autoridad axial del tablero.
