# Hex Grid, Terrain Pieces & Visual Elevation

## 1. Coordenadas
Usar coordenadas axiales `(q,r)` con 6 vecinos. La orientación provisional del prototipo es pointy-top, registrada en [ADR-0001](../decisiones/ADR-0001-cuadricula-axial-pointy-top.md); mantenerla en todo el grid y reabrirla solo al revisar el arte propio.

Toda lógica usa coordenadas hex. Nunca inferir conectividad mirando píxeles.

## 2. Pieza de 7 hexágonos
La pieza es una agrupación lógica. No debe ser un único sprite gigante como fuente de gameplay.

Requisito:
- 7 `TerrainPieceCellData`.
- una celda origen/pivote.
- seis rotaciones posibles.
- preview de toda la pieza.
- cada celda conserva terreno, altura y conexiones tras rotar.

La plantilla inicial confirmada por el usuario usa el centro `(0,0)` y sus seis vecinos inmediatos: `(0,-1)`, `(1,-1)`, `(1,0)`, `(0,1)`, `(-1,1)` y `(-1,0)`. Sus seis orientaciones válidas se obtienen rotando en pasos de 60° alrededor de `(0,0)`. Esta huella es la plantilla inicial; el modelo sigue admitiendo cualquier grupo conectado de siete hexágonos para piezas futuras.

Las celdas de la plantilla pueden ser PATH, GRASS o MOUNTAIN. La vista debug diferencia esos tipos por color y etiqueta: PATH `#59666E`, GRASS `#479157` y MOUNTAIN `#A1947A`. Los colores y la composición de la plantilla de muestra son provisionales, no arte ni balance final.

La silueta NO tiene por qué ser siempre el hexágono central + seis vecinos si en el futuro se diseñan otras formas de 7 celdas. El sistema debe soportar cualquier conjunto conectado de 7 hexes.

## 3. Validación de colocación
Una colocación es legal si:
1. Ninguna de sus 7 celdas solapa una celda existente.
2. La pieza toca el mapa existente por al menos un borde.
3. Si el diseño requiere conexión de camino, al menos una entrada de Path de la pieza conecta con un Path existente.
4. Ninguna salida PATH explícita apunta a terreno que no sea PATH; las ofertas flexibles solo conectan con otra celda PATH.
5. Tras colocarla, el/los spawns que deban conservar ruta hacia la base siguen teniendo una ruta válida.
6. No se crea una celda construible inaccesible visualmente por error de renderer (solo validación de desarrollo).

Regla de diseño: las conexiones de camino se definen explícitamente por borde; no asumir que dos celdas PATH adyacentes conectan si la plantilla visual dice lo contrario.

Contrato ejecutado por M3, registrado en [ADR-0004](../decisiones/ADR-0004-contrato-colocacion-terreno.md):
- `path_edges` es una máscara de seis bits. Dirección 0 = este `(1,0)`, 1 = sureste `(0,1)`, 2 = suroeste `(-1,1)`, 3 = oeste `(-1,0)`, 4 = noroeste `(0,-1)`, 5 = noreste `(1,-1)`; el borde opuesto es `(dirección + 3) mod 6`.
- Las conexiones internas de una pieza requieren `path_edges` recíprocos entre dos PATH. Si una conexión interna apunta a otra clase de terreno o no es recíproca, el Resource es inválido.
- Cuando un `path_edges` externo sale de la huella, se derivan dos sockets laterales flexibles en las caras contiguas que también queden fuera de la huella. Se rotan con la pieza y se ven como brazos laterales más tenues. Permiten conectar una pieza por el borde central o por cualquiera de esos laterales, siempre que los hexágonos vecinos sean PATH y la otra cara ofrezca el borde exacto o flexible complementario.
- Las salidas explícitas sin pareja siguen siendo errores si enfrentan una celda existente; una salida flexible es opcional y puede quedar abierta o mirar a terreno que no sea PATH. `requires_path_connection` exige al menos una salida externa explícita y que durante la colocación una conexión compatible llegue a un PATH existente.
- El `HexGrid` confirma las siete celdas de forma atómica después de validar. El Resource original no se modifica; las celdas rotadas son copias y reciben un `piece_instance_id`.
- M3 muestra un fantasma verde cuando la colocación es legal y rojo cuando no lo es. El cursor se ajusta a coordenadas axiales; clic izquierdo o el botón del HUD confirma, `Esc`, clic derecho o Cancelar abandona el preview. Q/E y los botones giran 60°.
- M4 implementa la verificación global mediante `PathGraph`: antes de confirmar una pieza se deriva el snapshot PATH candidato y se rechaza si falta la base, no queda ningún endpoint spawn, una salida exacta no encuentra socket complementario o una celda PATH/spawn no tiene ruta a la base. El hover del ghost no reconstruye el grafo; se evalúa al confirmar. El control visual de celdas construibles inaccesibles sigue siendo revisión de desarrollo.

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

En M4, cada salida exacta `path_edges` que queda abierta hacia una coordenada fuera del tablero se presenta como candidato spawn. Las aperturas exclusivamente flexibles no son endpoints; solo forman conexión cuando una celda PATH vecina ofrece la cara recíproca. El endpoint guarda la celda PATH, la dirección axial y la coordenada exterior para que M5 pueda colocar el enemigo antes de recorrer la ruta. La muestra M5 instancia `GameBase` en `(0,0)`, sobre el PATH central de la pieza inicial; la ubicación sigue siendo provisional, no un compromiso de diseño final. Véase [ADR-0007](../decisiones/ADR-0007-grafo-logico-de-caminos.md).

`PathGraph` mantiene una arista cuando ambas caras PATH ofrecen socket exacto o flexible complementario. Resuelve una ruta mínima por número de enlaces con BFS y desempate por orden de direcciones de `HexCoord`. La adyacencia conserva caminos alternativos en bifurcaciones y convergencias aunque cada spawn tenga una ruta cacheada escogida para el prototipo. Recalcula en inicio/confirmación de pieza; el modo debug `D` muestra candidatos, base y rutas cacheadas.

## 6. Elevación
Altura lógica:
- 0: Path.
- 1: terreno construible normal.
- 2: terreno elevado/montaña.

Representación visual:
```text
logical_position = hex_to_world(coord)
draw_position.y = logical_position.y - elevation * ELEVATION_PIXEL_OFFSET
```

Los cliffs rellenan visualmente la diferencia con vecinos más bajos.

La selección/click debe mapear correctamente al HexCoord aunque el sprite esté desplazado.

En el preview M2, cada nivel desplaza temporalmente la cara superior 18 px hacia arriba. Los desniveles se dibujan como caras laterales sombreadas mediante dos triángulos construidos desde la arista superior y el desplazamiento vertical exacto. Cuando ambos vectores se proyectan en la misma dirección, se añade un grosor lateral visual mínimo para que el polígono no colapse; en la pieza aislada, una celda vecina ausente se trata como altura 0. Las caras superiores se ordenan por profundidad lógica (Y de base, con X como desempate), y muestran `h0/h1/h2` para depuración. Este offset y estos polígonos son placeholders visuales, no especificación de arte final. La escena principal incluye un contenedor `Entities` con Y-sort habilitado para los actores.

El hover solo detecta las caras superiores: PATH resalta en `#82BFE6`, GRASS en `#80E085` y MOUNTAIN en `#F5C25C`. En el preview aislado, el HUD muestra coordenadas locales; sobre el tablero M3 muestra las coordenadas axiales globales `(q,r)`, el terreno y la altura. Los cliffs no son superficies seleccionables. La interacción de M3 está pendiente de inspección manual en Godot.

Estado del preview M3: el tablero inicial y las piezas confirmadas se dibujan desde `HexGrid`; el ghost se compone sobre esas celdas. Se distinguen visualmente los sockets PATH exactos y sus brazos laterales flexibles; el HUD informa coordenada axial global, terreno, altura, legalidad y cantidad de conexiones. El renderer permanece en polígonos placeholder.

## 7. Filosofía visual Urtuk-like
- Grid estricta por debajo.
- Arte orgánico por encima.
- Top de terreno, cliffs y props son capas separables.
- Árboles/rocas pueden sobresalir del footprint visual.
- El footprint lógico nunca cambia por decoración.
- La elevación se ve mediante paredes/fachadas dibujadas, no geometría 3D.
- Variantes visuales rompen repetición.

## 8. Orden de dibujo
Prioridad aproximada:
1. fondos;
2. cliffs traseros;
3. tops de terreno;
4. cliffs/front faces;
5. props;
6. entidades con Y-sort;
7. proyectiles/VFX;
8. overlays de selección.

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

En el prototipo M4, `D` alterna el overlay de rutas cacheadas, candidatos spawn y marcador de base. Las coordenadas, terreno, altura y sockets permanecen en la vista de pieza; un panel HUD resume el número de nodos, endpoints y bifurcaciones. La visualización es provisional y no activa spawns.

## 11. Navegación del mapa
- `Camera2D` controla el tablero; `CanvasLayer` mantiene la interfaz fija.
- Botón central del ratón + arrastre desplaza el mapa. La velocidad compensa el zoom actual.
- Rueda del ratón acerca o aleja alrededor del cursor, dentro del rango provisional `0.45×`–`2.5×`.
- `H` muestra u oculta el HUD. `R` devuelve el zoom a `1×` y centra la cámara sobre el tablero colocado.
- Estos controles y límites son decisiones provisionales de interfaz, registradas en [ADR-0005](../decisiones/ADR-0005-navegacion-de-mapa.md).

## Integración M5

La escena de muestra instancia `GameBase` en la celda PATH provisional `(0,0)`. El enemigo aparece en la coordenada exterior del endpoint seleccionado, avanza por los centros de `PathRoute.cells` y alcanza el objetivo; la llegada aplica `EnemyData.base_damage`. La base puede agotarse y emitir derrota. La ubicación de la base y sus valores son provisionales; no cambian la autoridad axial del tablero.
