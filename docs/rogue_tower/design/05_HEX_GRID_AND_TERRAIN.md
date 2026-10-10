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

Las celdas de la plantilla pueden ser PATH, GRASS o MOUNTAIN. La vista diferencia esos tipos mediante arte PNG en tres variantes por terreno; no dibuja iniciales ni coordenadas encima de las caras. El panel de terreno muestra axial `(q,r)`, tipo y altura al pasar el cursor por una cara superior. El atlas de terreno se generó para el proyecto y cada tipo ocupa una fila con tres variantes.

El tablero inicial está separado de las piezas de expansión y se configura en `data/terrain/starting_board.tres`: ocupa un hexágono axial de radio 2 (19 celdas), con la base en `(0,0)`. Las seis celdas vecinas inmediatas de la base tienen elevación 0; se usa Path o Grass bajo y no se colocan elevaciones junto al edificio. `StartingBoardData` valida ese anillo plano, 19 coordenadas únicas y una huella conectada. Su ruta de entrada tiene cuatro celdas PATH contando la celda de spawn y la de base; la salida inicial queda en `(3,-2)`. En campaña, `PathGraph` además rechaza cualquier endpoint cuya ruta mínima a la base tenga menos de cuatro celdas PATH; se conserva esa distancia también al colocar expansiones.

Desde M10, las expansiones rellenan al azar con Grass o Mountain los espacios vacíos completamente encerrados dentro de la envolvente axial del tablero. Un espacio conectado a un borde exterior o a una salida PATH abierta queda vacío. Los rellenos son celdas construibles y no forman parte de una pieza del jugador. Grupos conectados de 3–4 Grass/Mountain reciben un brillo tenue de combo 3; grupos de 5 o más reciben un brillo algo más intenso de combo 5. Es señal visual sin bonus numérico confirmado. El catálogo contiene las cinco plantillas originales y diez Resources adicionales: Pradera de colinas, Macizo montañoso, Llanura abierta, Cresta escalonada, Loma aislada, Picos gemelos, Pradera con ramal sin salida, Curva junto al acantilado, Camino serpenteante y Bifurcación del barranco. Todas conservan la huella central de siete celdas y las conexiones PATH internas son recíprocas; cuatro piezas nuevas amplían rutas y giros.

## Obstáculos, cofres y variantes visuales

Cada celda real de Grass/Mountain recibe contenido determinista a partir del seed de run y su coordenada axial; repetir el mismo seed y las mismas expansiones reproduce la misma asignación. Grass tiene 25 % de probabilidad de obstáculo, Mountain 15 %. El tipo se elige del pool visual provisional: roca, esquirla, hierba alta, tótem y piedras. PATH nunca genera obstáculos. El obstáculo es contenido del hex, no un tipo de terreno, elevación, nodo ni borde de `PathGraph`; bloquea construir en esa celda igual que una celda PATH.

Una celda Grass/Mountain sin obstáculo tiene un 1 % de probabilidad base de cofre. «Suerte del explorador» suma cinco puntos porcentuales por nivel en cuatro niveles; el último incremento queda limitado por el tope y la posibilidad máxima es 20 %. PATH, obstáculos y cofres son excluyentes. Hacer clic en un cofre cerrado lo abre y entrega Gold; la recompensa inicial del juego es 25 Gold por cofre y se considera balance provisional configurable. Una celda con cofre cerrado no admite construcción.

El PNG de terreno contiene nueve imágenes: tres variantes por cada tipo Path/Grass/Mountain. `TerrainVisualCatalog` recorta por variante el área visible y la coloca en el rectángulo exacto de la cara hexagonal; así elimina el desfase que producía el padding distinto entre casillas del atlas. El atlas de obstáculos contiene roca, esquirla, hierba alta, tótem y piedras; el cofre usa un PNG separado. Los obstáculos se dibujan en una caja común de 86×86 px (`OBSTACLE_DISPLAY_SIZE`), centrados respecto al hexágono con el desplazamiento artístico compartido de 6 px hacia abajo. La textura se estira para ocupar la caja completa; el mismo tamaño lógico se usa en el tablero y en las cards. El contenido visual no cambia huellas, sockets, elevación ni selección axial. La asignación real por `TerrainVisualCatalog` se aplica al tablero inicial, celdas de piezas confirmadas y rellenos interiores; las cards muestran obstáculos representativos de forma determinista y con las mismas tasas Grass 25 %/Mountain 15 %, forzando uno si no hubo ninguna tirada para que se vea el estilo del contenido. Es una ilustración, no predice qué hex recibirá obstáculo al colocar: la tirada real depende del seed y de la coordenada axial finales. El tamaño actual sustituye el de 104×104 fijado antes en [ADR-0044](../decisions/ADR-0044-caja-estandar-de-obstaculos.md); el cambio está en [ADR-0046](../decisions/ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md).

Las aristas del hex y los sockets PATH permanecen ocultos mientras no haya hover. Al pasar el cursor por una celda se dibujan su borde y conexiones de ruta; los bordes de los anillos vecinos se atenúan por distancia axial. Las flechas de flujo siguen visibles en la ruta para enseñar el sentido hacia la base. Cada spawn alcanzable muestra un portal PNG pulsante en su celda exterior, sin texto ni cartel. Al seleccionar una pieza y mover el preview a una colocación válida, los portales pasan al `PathGraph` candidato y se sitúan en sus endpoints previstos; el tono verde indica ese estado. Una colocación inválida o cancelada restaura los portales del grafo activo.

La silueta NO tiene por qué ser siempre el hexágono central + seis vecinos si en el futuro se diseñan otras formas de 7 celdas. El sistema debe soportar cualquier conjunto conectado de 7 hexes.

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
- M3 muestra un fantasma verde cuando la colocación es legal y rojo cuando no lo es. El cursor se ajusta a coordenadas axiales; clic izquierdo o el botón del HUD confirma, `Esc`, clic derecho o Cancelar abandona el preview. Q/E y los botones giran 60°.
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

En M4, cada salida exacta `path_edges` que queda abierta hacia una coordenada fuera del tablero se presenta como candidato spawn. Las aperturas exclusivamente flexibles no son endpoints; solo forman conexión cuando una celda PATH vecina ofrece la cara recíproca. El endpoint guarda la celda PATH, la dirección axial y la coordenada exterior para que M5 pueda colocar el enemigo antes de recorrer la ruta. Durante una colocación de terreno válida, los mismos endpoints se derivan del grafo candidato y sus portales se trasladan para enseñar la previsión antes de confirmar. En campaña M10 se activan todos los endpoints PATH abiertos con ruta a la base: cada pulso definido por el grupo genera un enemigo en todos ellos simultáneamente. Cada endpoint alcanzable muestra un portal PNG pulsante en la coordenada exterior, sin etiqueta `SPAWN`. Flechas luminosas en movimiento siguen cada arista de ruta hacia la base; se conservan las ramificaciones y los enlaces compartidos se dibujan una sola vez. `D` queda como overlay de diagnóstico de rutas BFS y base. El mapa recalcula estos indicadores junto con el `PathGraph` al confirmar terreno. La partida usa ahora un tablero semilla de 19 celdas y `GameBase` en `(0,0)`; cada ruta de spawn a base debe contener cuatro o más celdas PATH. Véase [ADR-0007](../decisions/ADR-0007-grafo-logico-de-caminos.md), [ADR-0025](../decisions/ADR-0025-tablero-inicial-y-ruta-minima.md) y [ADR-0043](../decisions/ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md).

`PathGraph` mantiene una arista cuando ambas caras PATH ofrecen socket exacto o flexible complementario. Resuelve una ruta mínima por número de enlaces con BFS y desempate por orden de direcciones de `HexCoord`. La adyacencia conserva caminos alternativos en bifurcaciones y convergencias aunque cada spawn tenga una ruta cacheada escogida para el prototipo. El grafo activo se recalcula al iniciar/confirmar; durante el movimiento de un ghost legal se crea el grafo candidato separado para actualizar la vista previa. El flujo animado usa la ruta candidata si la colocación es válida; `D` muestra la información estática de diagnóstico.

## 6. Elevación
Altura lógica:
- 0: Path.
- 1: terreno construible normal.
- 2: terreno elevado/Mountain.

Representación visual:
```text
logical_position = hex_to_world(coord)
draw_position.y = logical_position.y - elevation * ELEVATION_PIXEL_OFFSET
```

Los cliffs rellenan visualmente la diferencia con vecinos más bajos.

La selección/click debe mapear correctamente al HexCoord aunque el sprite esté desplazado.

Cada nivel eleva temporalmente la cara superior 18 px. Los desniveles se rellenan con una textura PNG de fachada, distinta para roca `Mountain` y suelo con hierba `Grass`, mapeada a un quad por arista visible. Los UV muestrean un recorte de la textura según las dimensiones reales de cada cara, con una densidad de 20 píxeles de origen por píxel de juego; así el arte conserva su escala entre desniveles de 1 y 2 niveles y no se estira para ocupar cada quad. La selección del recorte es determinista por posición y dirección y permanece dentro de los límites del PNG. Cuando las extrusiones de dos caras no coinciden en un vértice, una cuña de unión del color de la fachada cierra el encuentro para que no queden ángulos abiertos. No se dibujan las fachadas de los bordes traseros; en la pieza aislada, una celda vecina ausente se trata como altura 0. Las texturas pueden cambiarse en `assets/terrain/tiles/{mountain,grass}_cliff_face.png` sin modificar elevación ni topología. Cada celda elevada añade una copia texturada de su cara superior como nodo de `Entities.y_sort_enabled`, ordenada por el centro elevado. Esta cara superior es la única parte del terreno que se interpone en el Y-sort: cubre unidades/props detrás y queda debajo de los que pasan por delante. No se ordenan las paredes/cliffs por encima de unidades. Base, torres, enemigos, portales y props comparten la misma capa Z para decidir el orden por profundidad. Obstáculos y cofres son nodos independientes, no se pintan desde la capa completa del suelo. El offset artístico de 6 px hacia abajo no altera las posiciones lógicas. La conversión vectorial solo resuelve la forma de los quads y las uniones; el material visible procede de los sprites. Véase [ADR-0043](../decisions/ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md) y [ADR-0048](../decisions/ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md).

El hover solo detecta las caras superiores: PATH resalta en `#82BFE6`, GRASS en `#80E085` y MOUNTAIN en `#F5C25C`. Sin hover no se muestran bordes blancos del grid ni sockets PATH. La celda seleccionada muestra su arista y camino, y los anillos a una y dos celdas axiales reducen progresivamente su opacidad. En el preview aislado, el HUD muestra coordenadas locales; sobre el tablero M3 muestra las coordenadas axiales globales `(q,r)`, el terreno y la altura. Los cliffs no son superficies seleccionables. Desde M10 los clusters de terreno muestran un leve brillo animado para combos visuales de 3/5, sin cambiar sus stats.

Estado del preview M3: las 19 celdas del tablero inicial y las piezas confirmadas se dibujan desde `HexGrid`; el ghost se compone sobre esas celdas. Se distinguen visualmente los sockets PATH exactos y sus brazos laterales flexibles; el HUD informa coordenada axial global, terreno, altura, legalidad y cantidad de conexiones. Las caras superiores usan PNG recortados por variante y las fachadas elevadas usan sprites de Grass/Mountain. La base provisional en `(0,0)` cubre visualmente una cara hexagonal completa y reserva esa celda PATH.

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
1. fondos y fachadas laterales visibles del terreno;
2. caras superiores de terreno alineadas al footprint de cada hex;
3. ruta y flujo de flechas sobre las caras PATH;
4. superficies elevadas texturadas junto con props y entidades bajo `Entities.y_sort_enabled`;
5. proyectiles/VFX;
6. overlays de selección.

El filtro lineal se aplica a la ilustración de suelo, torres, enemigos, base, props y cofres. Las unidades, decoraciones de mundo y tapas elevadas usan `Entities.y_sort_enabled`, ordenadas por la posición Y proyectada de su anclaje; la posición Z permanece igual para que Godot pueda compararlas. Las fachadas se quedan bajo las entidades y nunca las tapan. Los VFX y la interfaz conservan sus capas propias.

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

En el prototipo M4, `D` alterna el overlay de rutas cacheadas y el marcador de base. Los puntos de spawn alcanzables se muestran siempre, incluso con `D` apagado, mediante el portal pulsante en la celda exterior. Desde ADR-0041, las rutas alcanzables también muestran cheurones animados que recorren las conexiones hacia la base; las ramas y convergencias permanecen visibles. El overlay no rotula hexes: coordenadas, terreno y altura se consultan al hacer hover y el panel HUD resume nodos, endpoints y bifurcaciones. La animación es solo informativa; no modifica la ruta ni la selección de camino del enemigo.

## 11. Navegación del mapa
- `Camera2D` controla el tablero; `CanvasLayer` mantiene la interfaz fija.
- Botón central del ratón + arrastre desplaza el mapa. La velocidad compensa el zoom actual.
- Rueda del ratón acerca o aleja alrededor del cursor, dentro del rango provisional `0.45×`–`2.5×`.
- `H` muestra u oculta el HUD. `R` devuelve el zoom a `1×` y centra la cámara sobre el tablero colocado.
- Estos controles y límites son decisiones provisionales de interfaz, registradas en [ADR-0005](../decisions/ADR-0005-navegacion-de-mapa.md).

## Integración M5

La escena de muestra instancia `GameBase` en la celda PATH provisional `(0,0)`. El enemigo aparece en la coordenada exterior del endpoint seleccionado, avanza por los centros de `PathRoute.cells` y alcanza el objetivo; la llegada aplica `EnemyData.base_damage`. La base puede agotarse y emitir derrota. La ubicación de la base y sus valores son provisionales; no cambian la autoridad axial del tablero.
