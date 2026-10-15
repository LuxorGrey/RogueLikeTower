# Rogue Tower — historial de decisiones

Este archivo contiene el registro histórico completo. La regla aprobada vigente está en PROJECT_SPEC.md; el código y Resources muestran el estado ejecutable. Consulta los ADR para el motivo y la fecha, no para inferir una regla más reciente que el propietario de diseño.

<a id='decision-index'></a>
## Índice de decisiones
- [ADR-0001 — cuadrícula axial con orientación pointy-top](#adr-0001)
- [ADR-0002 — plantilla inicial de terreno de siete hexágonos](#adr-0002)
- [ADR-0003 — renderizado provisional de elevación](#adr-0003)
- [ADR-0004 — contrato de colocación de piezas de terreno](#adr-0004)
- [ADR-0005 — navegación del mapa y visibilidad del HUD](#adr-0005)
- [ADR-0006 — sockets laterales flexibles de camino](#adr-0006)
- [ADR-0007 — grafo lógico de caminos y rutas M4](#adr-0007)
- [ADR-0008 — primera oleada y movimiento de enemigos M5](#adr-0008)
- [ADR-0009 — construcción y primera torre M6](#adr-0009)
- [ADR-0010 — pipeline central de daño y counters M7](#adr-0010)
- [ADR-0011 — HUD compacto y oleadas repetibles para depuración M7](#adr-0011)
- [ADR-0012 — Framework de efectos de estado M8](#adr-0012)
- [ADR-0013 — Economía de run y maná M9](#adr-0013)
- [ADR-0014 — Roster jugable de siete torres antes de las cartas](#adr-0014)
- [ADR-0015 — Bleed y recorrido de Shredder](#adr-0015)
- [ADR-0016 — Campaña de veinte rondas](#adr-0016)
- [ADR-0017 — Oferta de terreno y cierre de huecos](#adr-0017)
- [ADR-0018 — Spawn simultáneo en todos los endpoints abiertos](#adr-0018)
- [ADR-0019 — Lectura visual de hexes, combos y base](#adr-0019)
- [ADR-0020 — Cards visuales e inventario de terreno](#adr-0020)
- [ADR-0021 — Cartas de mejora dentro de la run](#adr-0021)
- [ADR-0022 — Meta-progresión persistente entre runs](#adr-0022)
- [ADR-0023 — Reglas de torres, mejoras y capas de vida](#adr-0023)
- [ADR-0024 — Ballista elimina al enemigo básico](#adr-0024)
- [ADR-0025 — Tablero inicial amplio y ruta mínima](#adr-0025)
- [ADR-0026 — Jerarquía de la interfaz de run y tienda terminal](#adr-0026)
- [ADR-0027 — HUD en tres paneles e iconos vectoriales reutilizables](#adr-0027)
- [ADR-0028 — Atlas PNG y feedback visual de torres y enemigos](#adr-0028)
- [ADR-0029 — Previsualización de spawns durante la expansión](#adr-0029)
- [ADR-0030 — Maná inicial y presentación de la regeneración](#adr-0030)
- [ADR-0031 — PNG independientes para cada icono](#adr-0031)
- [ADR-0032 — Ooogie von Ooogovich — identidad y fase adaptada](#adr-0032)
- [ADR-0033 — Nomenclatura canónica alineada con Rogue Tower](#adr-0033)
- [ADR-0034 — Reembolso de cooldown de Ballista al perder el objetivo](#adr-0034)
- [ADR-0035 — Parámetros del roster de Rogue Tower](#adr-0035)
- [ADR-0036 — Parámetros de torres según changelog oficial](#adr-0036)
- [ADR-0037 — Campaña de 45 rondas, roster y habilidades enemigas](#adr-0037)
- [ADR-0038 — Sprite de base y feedback del HUD](#adr-0038)
- [ADR-0039 — Panel lateral de torre y escala visual por objeto](#adr-0039)
- [ADR-0040 — terreno, obstáculos, cofres y feedback visual](#adr-0040)
- [ADR-0041 — Oclusión, arte de terreno y flujo de rutas](#adr-0041)
- [ADR-0042 — Orden por elevación y feedback del tablero](#adr-0042)
- [ADR-0043 — Superficies de elevación, preview de spawns y obstáculos en cards](#adr-0043)
- [ADR-0044 — Caja estándar para los sprites de obstáculos](#adr-0044)
- [ADR-0045 — auditoría de torres, feedback de selección y texturas runtime](#adr-0045)
- [ADR-0046 — Progresión independiente de mejoras y feedback de selección](#adr-0046)
- [ADR-0047 — Herramientas de depuración y claridad de selección](#adr-0047)
- [ADR-0048 — HUD, progreso de oleadas, cards de terreno y paredes texturizadas](#adr-0048)
- [ADR-0049 — Arquitectura híbrida y editable para la UI](#adr-0049)
- [ADR-0050 — Recursos visuales de UI editables en el Inspector](#adr-0050)
- [ADR-0051 — Navegación, previsión por portal y panel de torre](#adr-0051)
- [ADR-0052 — Números de daño animados y legibles](#adr-0052)
- [ADR-0053 — Paneles y sprites sencillos](#adr-0053)
- [ADR-0054 — Tipografía global y ausencia de sombras generadas por código](#adr-0054)
- [ADR-0055 — Feedback de base, selección y recompensas](#adr-0055)
- [ADR-0056 — Tablero inicial sencillo con camino recto](#adr-0056)
- [ADR-0057 — Oferta de expansión con prolongación garantizada](#adr-0057)
- [ADR-0058 — Arte Dirt en las texturas PATH](#adr-0058)
- [ADR-0059 — Frost Keep usa copos de impacto individual](#adr-0059)
- [ADR-0060 — Ofertas de terreno variables y contenido visual determinista](#adr-0060)
- [ADR-0061 — Pausa y exclusividad de las fases de expansión](#adr-0061)
- [ADR-0062 — Catálogo de Upgrade Cards y Permanent Upgrades](#adr-0062)
- [ADR-0063 — Selección y retirada de objetos del terreno](#adr-0063)
- [ADR-0064 — Reembolso al demoler torres](#adr-0064)
- [ADR-0065 — Panel común e iconos para Upgrade Cards](#adr-0065)
- [ADR-0066 — Cofres al confirmar terreno y sombras por elevación](#adr-0066)
- [ADR-0067 — Hacks de progreso, tienda general y run limpia](#adr-0067)
- [ADR-0068 — Sombras de losetas recortadas por altura receptora](#adr-0068)
- [ADR-0069 — Arsenal inicial, XP de perfil y lectura de altura](#adr-0069)
- [ADR-0070 — Sin sombras generadas y rutas limpias durante expansión](#adr-0070)
- [ADR-0071 — Marco perimetral de cards y colocación automática de terreno](#adr-0071)
- [ADR-0072 — Controles y tooltip compacto de celdas](#adr-0072)
- [ADR-0073 — Elevaciones 0–3 y bonus de torre](#adr-0073)
- [ADR-0074 — Vida inicial de base y derrota por llegada de boss](#adr-0074)
- [ADR-0075 — Panel único y aura de rareza para upgrade cards](#adr-0075)
- [ADR-0076 — Oro inicial, reclutamiento de torres y flujo de run](#adr-0076)
- [ADR-0077 — Mapa conectado de mejoras permanentes](#adr-0077)
- [ADR-0078 — Ventana ampliada del timeline de rondas](#adr-0078)
- [ADR-0079 — Límites de obstáculos y cierre visual del terreno elevado](#adr-0079)
- [ADR-0080 — Sprite vertical y tier visible en upgrade cards](#adr-0080)
- [ADR-0081 — Mejoras permanentes H/A/S en ramas paralelas](#adr-0081)
- [ADR-0082 — Tinte multiplicativo tenue por elevación](#adr-0082)
- [ADR-0083 — Timeline fijo de quince rondas y preview fiel de terreno](#adr-0083)
- [ADR-0084 — Retícula axial compartida y profundidad de fachadas por celda](#adr-0084)
- [ADR-0085 — Solo fachadas delanteras y degradado de cliffs](#adr-0085)
- [ADR-0086 — Oferta de cards y cierre de derrota](#adr-0086)
- [ADR-0087 — Props, obstáculos y altura junto a base](#adr-0087)
- [ADR-0088 — Presentación compacta de upgrade cards](#adr-0088)
- [ADR-0089 — Ajustes de escala, oclusión, portales y props](#adr-0089)
- [ADR-0090 — Fachadas limitadas a la diferencia de elevación](#adr-0090)
- [ADR-0091 — Contornos compartidos por región de terreno y elevación](#adr-0091)
- [ADR-0092 — Pulido visual y raíz común de sprites](#adr-0092)
- [ADR-0093 — Preview exacto, oferta fija y torres articuladas](#adr-0093)
- [ADR-0094 — Mapa de mejoras y legibilidad del terreno](#adr-0094)
- [ADR-0095 — Contorno regional de terreno de un solo tono](#adr-0095)
- [ADR-0096 — Sprite de base más alto y visible](#adr-0096)
- [ADR-0097 — Outline de base y enemigos](#adr-0097)
- [ADR-0098 — Ajuste de grosor del outline y contorno permanente de portales](#adr-0098)
- [ADR-0099 — Tinte de altura y sombra animada de nubes](#adr-0099)
- [ADR-0100 — Sprite único de torre y tinte de altura](#adr-0100)
- [ADR-0101 — VFX animados de Cozy Chunky por evento](#adr-0101)
- [ADR-0102 — Sprites completos de torre, escala y feedback](#adr-0102)
- [ADR-0103 — Escala de torre sin recorte](#adr-0103)
- [ADR-0104 — Reducción del 20 % de escala de torre](#adr-0104)
- [ADR-0105 — Tooltip de spawn, atajos de torre, panel de Gold, zoom y escala](#adr-0105)
- [ADR-0106 — VFX de evento anclados al mundo durante el paneo](#adr-0106)
- [ADR-0107 — Feedback de progresión y presentación de cards](#adr-0107)
- [ADR-0108 — Agua Wind Waker y explosión pixel de enemigo](#adr-0108)
- [ADR-0109 — Sombra de nubes reforzada y agua anclada a cámara](#adr-0109)
- [ADR-0110 — Mejoras de capa en fila y shake de ronda](#adr-0110)
- [ADR-0111 — Barra de XP y precios de demolición](#adr-0111)
- [ADR-0112 — Legibilidad de mejoras, pausa y colocación de terreno](#adr-0112)
- [ADR-0113 — Ajustes de paneles y pausa de agua](#adr-0113)
- [ADR-0114 — Preview de torre, resumen de run y mapa permanente](#adr-0114)
- [ADR-0115 — UI editable desde Inspector y limpieza de recursos](#adr-0115)
- [ADR-0116 — Spritesheets de correr de enemigos](#adr-0116)
- [ADR-0117 — Recorte del spritesheet de portal y outline de torres](#adr-0117)
- [ADR-0118 — Reclutamiento garantizado y aleatorio en las ofertas](#adr-0118)
- [ADR-0119 — Feedback de vida de la base](#adr-0119)
- [ADR-0120 — Control de velocidad de la partida](#adr-0120)
- [ADR-0121 — Color y gradiente de fachadas de elevación](#adr-0121)
- [ADR-0122 — Exploración del mapa, mar e islas decorativas](#adr-0122)
- [ADR-0123 — Islas explorables, tesoros de cartas y borde costero](#adr-0123)

## Cómo mantener el historial

Añade cada decisión como una sección con ancla ADR estable. Actualiza también la sección propietaria de PROJECT_SPEC.md y el estado/criterios en IMPLEMENTATION_AND_QA.md cuando cambien. No dupliques aquí la especificación activa.

<a id='adr-0001'></a>
## ADR-0001 — cuadrícula axial con orientación pointy-top

- Estado: Aceptada para el prototipo M1; provisional hasta revisar el arte del tablero.
- Fecha: 2026-10-07.

### Contexto

El paquete de diseño confirma coordenadas axiales `(q,r)`, seis vecinos, rotación, conversión mundo/pantalla y una cuadrícula lógica independiente del renderer. Deja la orientación pointy-top o flat-top para elegirla durante M1 según la referencia visual. En esta fase todavía no hay arte propio ni licencia verificada para arte externo.

### Decisión

M1 usa hexágonos pointy-top. La conversión axial–pantalla usa un radio lógico configurable y un origen centrado en la vista. Las reglas y búsquedas usan coordenadas axiales; la clave del diccionario es `Vector2i(q,r)`. El renderizador puede reemplazarse sin cambiar el modelo lógico.

La elección es provisional: queda fijada de forma coherente para el prototipo y solo debe cambiar mediante una decisión documentada cuando se revise el arte propio de M2.

### Consecuencias

- Las seis direcciones, vecinos y rotación se centralizan en `HexCoord`; la conversión axial–pantalla queda en `HexMath`, sin dependencias circulares entre ambos tipos.
- La cuadrícula lógica no depende de `TileMapLayer`, píxeles ni elevación visual.
- Las pruebas de referencia de rotación y conversión quedan descritas en `IMPLEMENTATION_AND_QA.md#acceptance`; no se añadieron ni ejecutaron pruebas en esta tarea.
- La igualdad de coordenadas se compara por `(q,r)` y la clave canónica del diccionario es `Vector2i(q,r)`, que aporta hash por valor sin usar instancias `RefCounted` como claves.

### Reglas sustituidas

Esta decisión inaugura el registro del proyecto reiniciado. El paquete nuevo sustituye las reglas de terreno y cámara anteriores que definían chunks 3×3/3×3×3, proyección isométrica 2:1 o `TileMapLayer` como autoridad lógica. El inventario de documentos retirados consta en [`ORIGEN.md`](CONTENT_AND_ASSETS.md#origin-and-sources).

### Fuentes

- Paquete del usuario: `PROJECT_SPEC.md#terrain`, consultado el 2026-10-07.
- *Urtuk: The Desolation*, Steam y Press Kit, consultados el 2026-10-07; referencia visual, no regla de orientación: [Steam](https://store.steampowered.com/app/1181830/Urtuk_The_Desolation/), [Press Kit](https://www.urtuk.com/page/presskit).

<a id='adr-0002'></a>
## ADR-0002 — plantilla inicial de terreno de siete hexágonos

- Estado: Aceptada para la forma de las losetas de siete celdas; su uso como tablero de campaña queda sustituido por ADR-0025.
- Fecha: 2026-10-07.

### Contexto

El diseño base establece que cada expansión usa una pieza compuesta por siete celdas hexagonales. El usuario precisó la huella inicial como `(0,0)`, `(0,-1)`, `(1,-1)`, `(1,0)`, `(0,1)`, `(-1,1)` y `(-1,0)`: el centro axial más sus seis vecinos.

### Decisión

- La plantilla de loseta de siete celdas tiene exactamente esas coordenadas locales, con `(0,0)` como pivote.
- Cada celda guarda su propio terreno: PATH, GRASS o MOUNTAIN. La primera muestra usa 2 PATH, 3 GRASS y 2 MOUNTAIN para que los tres colores aparezcan; esa distribución es provisional y editable en el Resource.
- La vista debug usa PATH `#59666E`, GRASS `#479157` y MOUNTAIN `#A1947A`, además de etiquetas P/G/M para que el tipo no dependa solo del color. Las etiquetas de montaña usan tinta oscura para conservar contraste. No se importa ni distribuye arte de terceros.
- El giro ocurre en seis pasos de 60° alrededor del origen. Las coordenadas y los bits de conexiones de camino giran juntos; el Resource original no se modifica.
- Esta huella define la primera plantilla, no todas las piezas futuras: el modelo conserva la regla de admitir cualquier conjunto conectado de siete hexágonos.

### Alcance y estado de implementación

M3 usó esta plantilla como tablero semilla; ADR-0025 sustituye ese uso por `StartingBoardData` de 19 celdas y mantiene las siete coordenadas como forma estándar de losetas. M3 también añadió cinco Resources expansivos con sockets de camino, validador, preview y confirmación/cancelación. M4 implementa `PathGraph` y ancla provisionalmente la base en PATH `(0,0)`. La interacción M3 y el overlay M4 siguen pendientes de inspección en Godot.

### Referencias

- Requerimiento del usuario en esta conversación, 2026-10-07.
- Paquete de diseño del usuario: `PROJECT_SPEC.md#terrain` y `PROJECT_SPEC.md`, consultados el 2026-10-07.

<a id='adr-0003'></a>
## ADR-0003 — renderizado provisional de elevación

- Estado: Aceptada como implementación placeholder de M2.
- Fecha: 2026-10-07.

### Contexto

El diseño requiere terreno 2D con alturas lógicas 0/1/2, desplazamiento visual, caras laterales para desniveles y una cuadrícula que siga siendo la autoridad lógica. La implementación actual necesita mostrar esas diferencias antes de disponer del arte final.

### Decisión

- El preview dibuja la cara superior de cada hexágono en `posición_lógica - altura × 18 px`.
- En cada borde que enfrenta una celda más baja se genera una cara lateral sombreada mediante dos triángulos construidos desde la arista superior y el desplazamiento vertical del desnivel. Si ambos vectores se proyectan en la misma dirección y la cara colapsaría, se añade un grosor visual lateral mínimo. En el preview aislado, una celda ausente equivale a altura 0.
- Las caras laterales se dibujan antes de las caras superiores; estas últimas se ordenan por Y de base y X como desempate.
- El hover solo selecciona polígonos de caras superiores. PATH se ilumina `#82BFE6`, GRASS `#80E085` y MOUNTAIN `#F5C25C`; el HUD superior muestra la coordenada axial local `(q,r)`, terreno y altura.
- Se usan polígonos y colores de depuración, no sprites temporales importados. El offset de 18 px y el sombreado pueden cambiar al integrar renderer, cámara y arte final.
- La escena principal mantiene un contenedor `Entities` con `y_sort_enabled` para actores que se añadan al tablero.

### Consecuencias

- La elevación visual no modifica `HexCoord`, conectividad, selección lógica ni `TerrainPieceCellData.elevation`.
- El preview puede representar PATH/GRASS/MOUNTAIN y sus niveles antes de producir assets.
- Al colocar el cursor sobre acantilados o fuera de las caras superiores no se selecciona ninguna celda.
- El contenedor de entidades está preparado, aunque la escena actual todavía no contiene torres, enemigos ni decoración.

### Fuentes

- Paquete de diseño del usuario: `PROJECT_SPEC.md#terrain`, consultado el 2026-10-07.
- Requerimiento del usuario de usar placeholders sustituibles por arte final, conversación actual, 2026-10-07.

<a id='adr-0004'></a>
## ADR-0004 — contrato de colocación de piezas de terreno

- Estado: Aceptada para M3; la reciprocidad exacta entre piezas quedó ampliada por ADR-0006. La semilla especial de siete celdas se conserva como antecedente M3; ADR-0025 define el tablero de campaña actual. La reciprocidad exacta dentro de una pieza sigue vigente.
- Fecha: 2026-10-07.

### Contexto

M3 necesita ampliar el tablero con piezas de siete celdas, conservar los datos del terreno al girar y prevenir empalmes ambiguos de PATH. M4 añade una validación del snapshot global PATH antes de confirmar una expansión; su algoritmo y la coordenada provisional de base están en ADR-0007.

### Decisión

- `TerrainPieceData` es una plantilla inmutable de contenido; el pivote local es `(0,0)`. La huella puede ser cualquier grupo conectado de siete celdas.
- `path_edges` es una máscara de seis bits, alineada con `HexCoord.DIRECTION_OFFSETS`. Las conexiones internas de una pieza requieren que dos celdas PATH vecinas marquen sus bordes recíprocos.
- Una pieza expansiva debe tener al menos un socket explícito hacia fuera y al colocarla debe unirlo con PATH del tablero mediante una cara explícita o flexible complementaria. Las aperturas laterales flexibles se describen en ADR-0006; las que queden abiertas pueden servir para expansión posterior.
- `TerrainPlacementValidator` calcula la legalidad sin modificar el tablero ni el Resource. Se rechazan solapamientos, falta de contacto, bordes PATH explícitos incompatibles, salidas explícitas hacia terreno que no sea PATH y piezas que no enlacen con PATH existente cuando lo requieren. Una oferta flexible no usada no invalida la colocación.
- Tras confirmar una evaluación legal, `HexGrid.add_cells` inserta todas las celdas de la pieza en una única operación, asignándoles un `piece_instance_id`.
- La semilla M3 de siete celdas no requería conexión entrante y exponía una salida hacia `(0,-2)`. Ese tablero queda sustituido para la campaña por el tablero de 19 celdas y la ruta de cuatro PATH de ADR-0025.
- La conectividad global spawn-base corresponde a `PathGraph` de M4 y se valida sobre las celdas existentes más la pieza candidata antes de insertarla en `HexGrid`.
- El preview combina tablero confirmado y fantasma; verde indica colocación legal y rojo indica que la evaluación actual tiene errores. La UI solo confirma una evaluación legal.

### Consecuencias

- Pueden coexistir adyacencias visuales entre dos celdas PATH sin conexión lógica cuando ninguno ofrezca un borde exacto ni flexible. Esto mantiene explícita la topología.
- La legalidad local de `TerrainPlacementValidator` no basta para confirmar una pieza: `Main` exige que el snapshot `PathGraph` resultante conserve rutas válidas hacia la base provisional.
- Las cinco piezas iniciales (`straight`, `gentle_turn`, `hard_turn`, `fork`, `convergence`) son composiciones y contenido provisionales, no decisiones de balance ni arte final.

### Fuentes

- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md`, consultado el 2026-10-07.
- `docs/rogue_tower/PROJECT_SPEC.md`, consultado el 2026-10-07.
- `docs/rogue_tower/PROJECT_SPEC.md#terrain`, consultado el 2026-10-07.
- Requerimiento explícito del usuario en esta conversación, 2026-10-07.

<a id='adr-0005'></a>
## ADR-0005 — navegación del mapa y visibilidad del HUD

- Estado: Aceptada para el prototipo M3.
- Fecha: 2026-10-08.

### Contexto

El mapa puede crecer más allá de la ventana y la interfaz de colocación tapa una parte de la vista. Se necesita mover y escalar el mundo sin alterar las coordenadas axiales ni el tamaño del HUD.

### Decisión

- Un `Camera2D` dentro de la escena principal desplaza y escala el tablero. El `CanvasLayer` conserva el HUD en coordenadas de pantalla.
- El botón central del ratón, mantenido y arrastrado, pannea la cámara; el movimiento se divide por el zoom para mantener una velocidad visual constante.
- La rueda hace zoom uniforme centrado en el cursor. El rango inicial configurable es `0.45×`–`2.5×`, con pasos multiplicativos de `1.12`.
- `H` alterna la visibilidad del HUD sin desactivar la navegación del mapa.
- `R` restablece zoom `1×` y centra la cámara sobre los límites actuales de las celdas confirmadas.
- Mientras se pannea no se mueve el ancla del ghost. Al soltar el botón central, la posición del cursor vuelve a actualizarla.

### Consecuencias

- La navegación queda desacoplada del `HexGrid`; pan y zoom no cambian coordenadas, ocupación ni validación.
- El zoom centrado en cursor facilita inspeccionar/posicionar piezas lejos del centro de la pantalla.
- No hay límites de cámara específicos por tamaño del mapa; `R` permite recuperar la vista del tablero.
- La sensibilidad, rango de zoom y teclas son controles provisionales que pueden ajustarse al probar la interfaz.

### Fuentes

- Requerimiento explícito del usuario en esta conversación, 2026-10-08.
- Godot Engine 4.7, clase `Camera2D`, https://docs.godotengine.org/en/4.7/classes/class_camera2d.html, consultada el 2026-10-08. Se usa `Camera2D` para el scroll del viewport y su propiedad `zoom` uniforme.

<a id='adr-0006'></a>
## ADR-0006 — sockets laterales flexibles de camino

- Estado: Aceptada para M3.
- Fecha: 2026-10-08.

### Contexto

La rotación de piezas de seis lados estaba limitada por exigir coincidencia exacta de las caras de salida marcadas en los hexágonos PATH. El usuario pidió que los caminos de borde se abran hacia los lados contiguos, como en la referencia visual adjunta, para dar más opciones al encajar piezas. También reportó avisos repetidos de triangulación al dibujar los cliffs.

### Decisión

- Los `.tres` mantienen `path_edges` como topología explícita. Las conexiones internas de una pieza siguen requiriendo dos bordes exactos recíprocos entre celdas PATH.
- Cuando un borde `path_edges` apunta fuera de la huella de la pieza, `TerrainPieceData` deriva en runtime hasta dos `flexible_path_edges`: las direcciones contiguas `d-1` y `d+1` que también quedan fuera de la huella. Las direcciones se limitan a las caras exteriores del hexágono y rotan con la pieza.
- En el límite entre piezas, la validación y `PathGraph` unen caras complementarias cuando cada lado ofrece el borde exacto o flexible recíproco. Una conexión explícita sin pareja frente a una celda existente sigue siendo inválida; las ofertas flexibles que no se usan pueden quedar abiertas y no fuerzan camino sobre terreno GRASS o MOUNTAIN.
- La vista muestra los bordes explícitos con trazo principal y los laterales flexibles con trazo más tenue. La geometría real del camino y sus bifurcaciones proviene de las conexiones que se confirmen.
- Los cliffs se dibujan como dos triángulos a partir de los extremos de la arista superior y el desplazamiento vertical del desnivel. Si la proyección los deja colineales, se añade un grosor lateral mínimo. No se triangula un cuadrilátero reconstruido desde el hexágono vecino.
- La cuadrícula mantiene seis orientaciones a 60°; la flexibilidad de los sockets amplía los encajes sin cambiar coordenadas axiales.

### Consecuencias

- Piezas que solo difieren en el lado por el que alcanzan el borde pueden conectarse sin cambiar el contenido exacto de su ruta interna.
- `HexCell` conserva tanto `path_edges` como `flexible_path_edges`; `PathGraph` comprueba la unión de ambas máscaras en sentidos opuestos.
- Las aperturas laterales no son conexiones confirmadas por sí solas. La conexión aparece cuando se coloca una pieza PATH adyacente y ofrece una cara compatible.
- La geometría de cliffs no depende de la triangulación de un polígono de cuatro puntos; la inspección visual en Godot sigue pendiente.

### Fuentes

- Requerimiento del usuario y captura adjunta en esta conversación, 2026-10-08.
- `docs/rogue_tower/PROJECT_SPEC.md#terrain`, consultado el 2026-10-08.
- `docs/rogue_tower/DECISION_HISTORY.md`, consultado el 2026-10-08.

<a id='adr-0007'></a>
## ADR-0007 — grafo lógico de caminos y rutas M4

- Estado: contrato técnico M4 vigente; la coordenada M4 `(0,0)` quedó sustituida primero por ADR-0025 y su geometría actual por ADR-0056.
- Fecha: 2026-10-08.

### Contexto

M4 debe derivar conectividad desde las celdas PATH, distinguir la base de los posibles spawns, encontrar rutas reproducibles, conservar bifurcaciones/convergencias y recalcular al confirmar una expansión. El mapa es axial y discreto. ADR-0006 ya establece que una conexión entre piezas puede usar sockets PATH exactos y laterales flexibles complementarios, y que una oferta flexible sin pareja no confirma por sí sola un camino. El diseño deja la selección de spawns activos para el `WaveDirector`.

La documentación aún no sitúa la base en una coordenada. Para completar el grafo inicial sin convertir esa suposición en una regla de diseño, se necesita un anclaje temporal sobre el PATH de la loseta inicial.

### Decisión

- `PathGraph` mantiene un nodo por celda PATH y une dos nodos adyacentes solo cuando ambas caras ofrecen una conexión recíproca en la unión de `path_edges` y `flexible_path_edges`. Una salida exacta enfrentada a una celda existente sin oferta complementaria es un error; una flexible no emparejada permanece opcional.
- Una salida exacta que apunta fuera de todas las celdas del tablero crea un `PathEndpoint` candidato a spawn. Un socket exclusivamente flexible no crea un endpoint. Los candidatos se exponen; M4 no activa oleadas ni selecciona cuáles usa el `WaveDirector`.
- La coordenada de base provisional es el PATH axial `(0,0)`. M5 la situaba en el centro de la pieza inicial de siete celdas; el tablero de campaña actual la carga desde `StartingBoardData` y aumenta la huella inicial. ADR-0025 fija el tablero de radio 2 y cuatro celdas PATH mínimas por ruta, manteniendo `(0,0)` editable y provisional.
- Cada spawn candidato obtiene una ruta mínima en número de enlaces mediante búsqueda en anchura (BFS). Los vecinos se recorren según el orden estable de las seis direcciones de `HexCoord`, por lo que los empates devuelven la misma ruta para el mismo grafo. No hay costes de terreno ni pesos de balance en M4.
- El grafo se reconstruye al iniciar la escena y al confirmar una pieza, nunca por frame ni al mover el ghost. La nueva pieza solo se confirma si el snapshot resultante tiene base PATH, al menos un candidato spawn y conectividad entre la base y todos los PATH/endpoints.
- El preview marca siempre sobre el mapa cada endpoint alcanzable que usa el `WaveDirector`: puerta circular roja/ámbar fuera del borde PATH, flecha hacia dentro y etiqueta `SPAWN`. El overlay de `D` conserva las rutas elegidas por BFS y el marcador de base; oculta o mostrar esa depuración no cambia el grafo ni los spawns.

### Consecuencias

- Las bifurcaciones y convergencias permanecen en la adyacencia del grafo. El BFS elige una ruta determinista por endpoint para depuración y el movimiento M5; no elimina otras ramas. M5 configura `FIRST_SORTED` o `ROUND_ROBIN` para sus muestras. En campaña M10, ADR-0018 sustituye la incertidumbre: todos los endpoints PATH abiertos alcanzables generan enemigos simultáneamente por pulso.
- `PathRoute` almacena la secuencia ordenada de coordenadas PATH de spawn a base. M5 consume esa secuencia en el enemigo para mantener sus waypoints, índice y progreso durante la oleada.
- Se rechazan snapshots con subredes PATH aisladas o extremos sin retorno a base; activar un subconjunto de candidatos sigue siendo responsabilidad del sistema de oleadas.
- La base `(0,0)`, el algoritmo sin pesos y la tecla `D` son decisiones técnicas/provisionales. El sistema de datos y APIs permiten cambiar la base y el control visual sin alterar las coordenadas del tablero.
- La señal `SPAWN` es una ayuda visual provisional: se deriva de rutas alcanzables del `PathGraph` tras cada reconstrucción y por eso coincide con los puntos exteriores por los que puede aparecer la oleada.

### Referencias

- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md`, alcance M4, consultado el 2026-10-08.
- `docs/rogue_tower/PROJECT_SPEC.md`, arquitectura de navegación lógica, consultado el 2026-10-08.
- `docs/rogue_tower/PROJECT_SPEC.md`, modelos de mapa/oleadas, consultado el 2026-10-08.
- `docs/rogue_tower/PROJECT_SPEC.md#terrain`, sockets, endpoints y rutas, consultado el 2026-10-08.
- `docs/rogue_tower/PROJECT_SPEC.md#combat`, movimiento de enemigos por una ruta, consultado el 2026-10-08.
- `docs/rogue_tower/DECISION_HISTORY.md`, consultado el 2026-10-08.
- `.agents/skills/godot-master/references/navigation-pathfinding.md` y `resource-data-patterns.md`, consultados el 2026-10-08; la autoridad lógica hexagonal del proyecto prevalece sobre las APIs de navegación genérica.

<a id='adr-0008'></a>
## ADR-0008 — primera oleada y movimiento de enemigos M5

> Nota posterior: M9 implementa los campos de recompensa que quedaban pendientes en este prototipo. Sus valores de prueba y la propiedad del pago están en [ADR-0013](#adr-0013).

- Estado: aceptada para el prototipo M5; contenido y parámetros provisionales.
- Fecha: 2026-10-08.

### Contexto

M5 debe cerrar el recorrido desde el grafo M4 hasta un objetivo con vida: generar enemigos, recorrer una ruta válida, dañar la base al llegar y terminar la primera oleada. El proyecto aún no tiene torres (M6), pipeline de daño (M7) ni ciclo completo de rondas (M10); esta etapa necesita datos mínimos para probar el flujo sin anticipar esos sistemas.

### Decisión

- `GameBase` es una escena con `BaseData` y `HealthComponent`. Para la muestra se dibuja sobre PATH axial `(0,0)`, que sigue siendo una coordenada de objetivo provisional y reemplazable.
- `Enemy` es una escena con `EnemyData`, `HealthComponent` y `PathFollowerComponent`. El director inyecta una `PathRoute` válida; el actor aparece en la coordenada exterior del endpoint y recorre los centros de los hexes en orden, usando movimiento determinista por distancia en `_physics_process`.
- `WaveDirector` recibe explícitamente la oleada, el snapshot `PathGraph`, la base, el contenedor de entidades, el origen del mapa y el radio hexagonal. El código de gameplay no hace una búsqueda espacial genérica ni reconstruye ruta por frame.
- `WaveData` y `WaveEnemyGroupData` declaran enemigos, cantidad, intervalo, demora y política de endpoint. `FIRST_SORTED` usa el primer candidato válido en orden estable para la oleada de prueba; `ROUND_ROBIN` queda disponible como opción configurable. El comportamiento de ronda final sigue abierto.
- La muestra usa base 50 HP, enemigo 20 HP, velocidad 90 px/s, daño de llegada 10 y tres enemigos espaciados 1 s. Son placeholders técnicos configurables, no valores de balance confirmados.
- `Main` bloquea la colocación mientras `RunManager` está en `COMBAT`; terminar la muestra entra en `TERRAIN_EXPANSION`, agotar la base entra en `RUN_DEFEAT`. No se inicia automáticamente otra ronda.

### Consecuencias

- El smoke de M5 puede demostrar ruta, daño, muerte, derrota y terminación sin implementar torres ni alterar el alcance de M6–M10.
- Al no haber defensa en esta fase, los tres enemigos llegan a la base y dejan la muestra con 20 de 50 HP. Esto es una comprobación del flujo, no una experiencia de juego balanceada.
- El `PathFollowerComponent` almacena waypoints, índice y progreso normalizado de tramo; mantiene la regla de que el mapa no se expande con enemigos vivos.
- Los stats completos (armor, regeneración, recompensas, tags/resistencias) y el pipeline central de daño siguen pendientes de M7/M9.

### Referencias

- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md`, M5/M6/M7/M10, consultado el 2026-10-08.
- `docs/rogue_tower/PROJECT_SPEC.md`, escena principal y navegación lógica, consultado el 2026-10-08.
- `docs/rogue_tower/PROJECT_SPEC.md`, modelos Enemy/Wave, consultado el 2026-10-08.
- `docs/rogue_tower/PROJECT_SPEC.md#terrain` y `PROJECT_SPEC.md#combat`, objetivo y movimiento por `PathRoute`, consultados el 2026-10-08.
- `docs/rogue_tower/DECISION_HISTORY.md`, consultado el 2026-10-08.
- `.agents/skills/godot-master/references/characterbody-2d-movement-recipes.md`, `composition.md`, `state-machine-advanced.md`, `signal-architecture.md` y `combat-system.md`, consultados el 2026-10-08. Para este movimiento sobre waypoints no se necesita cuerpo físico ni NavigationAgent; los hexes y `PathRoute` son la autoridad lógica.

<a id='adr-0009'></a>
## ADR-0009 — construcción y primera torre M6

- Estado: aceptada para el prototipo histórico; la construcción durante `TERRAIN_EXPANSION` fue sustituida por ADR-0061, el camino temporal de daño directo por ADR-0010, el coste gratuito de M6 por ADR-0013 y el bonus de altura por ADR-0073. Los demás números de Basic Bolt siguen siendo placeholders.
- Fecha: 2026-10-08.

### Contexto

M6 debe convertir la ruta y la oleada de M4/M5 en un prototipo de Tower Defense comprobable. La economía está planificada en M9 y el cálculo central de daño en M7. El tablero aún es una autoridad axial 2D con altura lógica y las celdas PATH deben seguir formando una ruta válida hasta la base.

### Decisión

- `BuildController` es dueño del build mode, la selección y la lista de torres por coordenada. Consulta `HexGrid` y exige una celda existente, `buildable`, sin ocupación, y terreno permitido por `TowerData`.
- M6 solo habilita construcción sobre GRASS o MOUNTAIN. Las torres no pueden ocupar PATH; por eso su colocación no muta `PathGraph` ni puede sellar una ruta.
- Regla histórica M6: se permitía construir/mejorar durante `ROUND_PREP`, `COMBAT` y `TERRAIN_EXPANSION`; no durante `RUN_SETUP` ni `RUN_DEFEAT`. ADR-0061 elimina el permiso de expansión: el runtime actual permite construcción en `ROUND_PREP` y `COMBAT` únicamente, y mantiene bloqueadas las acciones de torre durante `TERRAIN_EXPANSION` y `CARD_OFFER`.
- `Basic Bolt` es la única torre inicial. `TowerData` almacena daño, ataques por segundo, alcance en hexes, máscara de terrenos, prioridad, bonus de altura, límite e incrementos de mejora y escena.
- La torre busca enemigos vivos en alcance cada 0.1 segundos, una frecuencia suficiente para la muestra pequeña. First/last usan el progreso normalizado de ruta; highest health compara vida actual y highest armor consulta el campo configurado en `EnemyData`. Los empates se resuelven por ID de instancia estable durante la vida del nodo.
- El ataque M6 es hitscan directo y llama `Enemy.apply_damage`. No se añade un `Area2D`, búsqueda física ni escena de proyectil, porque el prototipo no requiere colisiones y el daño central pertenece a M7. El director sigue administrando las señales de muerte y llegada existentes.
- El placeholder vectorial dibuja base, orientación, alcance al seleccionar y flash de disparo. El preview del tablero muestra marcador y radio de colocación legal/ilegal.
- Valores provisionales del prototipo Basic Bolt: daño 10, 1 ataque/s, rango base 3 hexes, máximo nivel 3, +5 daño y +0.25 hex de rango por mejora. La regla histórica de +0.25 hex de alcance por nivel de elevación fue sustituida por el escalado lógico vigente de ADR-0073 (+1 daño y +0.5 hex de alcance por nivel).
- Las mejoras no cuestan nada en M6 para probar progresión local; M9 agregará coste, moneda y recompensas. No se implementa venta en este milestone. El armor se usa para ordenar objetivos, no para mitigar daño; M7 añadirá el pipeline y la mitigación.

### Consecuencias

- Se puede defender la primera oleada y comprobar colocación, targeting, rango, cadencia y mejoras sin anticipar economía o arquitectura final de daño.
- Los números, el bonus de altura, los colores del preview y el arte de torre permanecen configurables y no son reglas de balance confirmadas.
- Si más adelante se permiten torres sobre PATH o terreno que altere topología, habrá que revalidar rutas antes de confirmar la construcción.
- M6 smoke prueba el contrato de datos/lógica. El render del HUD, la lectura del alcance y el input de ratón requieren además la prueba manual documentada en `IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md`, secciones M5–M9, consultado el 2026-10-08.
- `docs/rogue_tower/PROJECT_SPEC.md`, `PROJECT_SPEC.md#combat` y `IMPLEMENTATION_AND_QA.md#acceptance`, consultados el 2026-10-08.
- `.agents/skills/godot-master/references/combat-system.md`, `resource-data-patterns.md`, `signal-architecture.md` y `2d-physics-area2d-and-queries.md`, consultados el 2026-10-08.

### Cambio posterior en M9

La decisión histórica de que las mejoras fueran gratuitas solo aplicaba al prototipo M6 y queda reemplazada por los costes configurables `TowerData.upgrade_costs`, el coste de construcción y la integración de oro/maná descritos en [ADR-0013](#adr-0013). El resto de este ADR conserva los contratos de construcción y targeting de M6.

<a id='adr-0010'></a>
## ADR-0010 — pipeline central de daño y counters M7

- Estado: contrato histórico de M7; fórmula de mitigación plana sustituida por M12A/ADR-0023. Servicio, tags y fixtures de prueba siguen como referencia de la arquitectura original; sus cifras son provisionales. La expectativa de recompensas pendientes de M9 quedó resuelta por ADR-0013.
- Fecha: 2026-10-08.

### Contexto

M7 requiere que salud, armadura, regeneración, tipos/counters configurables y estadísticas de combate usen una sola ruta de resolución. M6 aplicaba el daño directamente desde `Tower`; esa decisión temporal ya no sirve porque repartiría fórmulas al añadir torres especializadas. El juego actual es 2D local, usa Resources para contenido y todavía no tiene modificadores de run, status ni recompensa por kill.

### Decisión

- `DamageService` vive como hijo de `Main` y se inyecta por `BuildController.configure()` a cada torre. No se crea un Autoload global para resolver combate de una run.
- `Tower` construye un `DamagePacket` por impacto con daño, instance ID de origen, bitmask de tags, multiplicadores de armadura/vida y counter anti-regen configurados por `TowerData`.
- El paquete es `RefCounted` transitorio. `DamageResult` registra armor absorbida, multiplicador de tipo, daño calculado/aplicado, fuerza y duración anti-regen y si el objetivo murió. El servicio expone `preview_damage()` para debug sin mutación y `apply_damage()` para resolver y emitir `damage_resolved`.
- Tags iniciales de prototipo: Físico (`1`), Fuego (`2`) y Arcano (`4`). Son categorías técnicas configurables, no catálogo o balance confirmados. Los multiplicadores de daño recibido están en `EnemyData`; los tags múltiples combinan sus multiplicadores por producto.
- Fórmula provisional: `armor_absorbed = min(raw_damage, armor * armor_multiplier)`. Después, `health_damage = floor(max(raw_damage - armor_absorbed, 0) * damage_tag_multiplier * health_multiplier)`. `HealthComponent` limita la aplicación a la vida actual. Un counter del paquete no transforma ni consume armor: modifica la regeneración aparte.
- `Enemy` aplica la regeneración por segundo usando un acumulador fraccional, solo en estado vivo/móvil, y la limita al HP máximo. El counter reduce la tasa por `regen_counter_strength` durante `regen_counter_duration`. Si se vuelve a aplicar antes de expirar, rige la fuerza más alta y el mayor tiempo restante; no hay stacks aditivos.
- El pipeline deja el campo `status_payloads` preparado, pero no lo procesa hasta M8. No hay proveedor de modificadores de run antes de M11; el servicio no inventa una lista de modificadores vacía. La muerte conserva el flujo de señales M5 y las recompensas esperan M9.
- La demo permite seleccionar Basic Bolt, Perforadora y Drenadora y una oleada M7 con un enemigo de prueba para exponer los counters desde HUD. Son fixtures temporales con un único placeholder visual.

### Consecuencias

- Las torres usan el mismo cálculo y pueden diferenciarse con datos sin duplicar código de mitigación.
- Se pueden configurar vulnerabilidades por tipo, resistencia de armor, daño a vida y supresión de regeneración por separado.
- En el contrato histórico M7, Armor era un stat defensivo plano y no una barra consumible. Esa regla quedó sustituida por M12A; la reducción a HP entero truncaba hacia abajo y `DamageResult` hacía observable un impacto de cero daño.
- Los números de la oleada diagnóstica permiten comparar perfiles, pero no fijan la curva de balance. La prueba manual y criterios de cierre están en `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md`, milestones M6–M9, consultado el 2026-10-08.
- `docs/rogue_tower/PROJECT_SPEC.md`, `PROJECT_SPEC.md#combat`, `IMPLEMENTATION_AND_QA.md#progress` y `IMPLEMENTATION_AND_QA.md#acceptance`, consultados el 2026-10-08.
- `.agents/skills/godot-master/references/combat-system.md`, `resource-data-patterns.md` y `signal-architecture.md`, consultados el 2026-10-08.

### Cambio posterior en M9

Este ADR describe el pipeline de daño de M7, cuando todavía no había recompensa económica. M9 conecta las muertes de `Enemy` a los pagos de `WaveDirector`; el cálculo de daño sigue sin ser dueño del oro. Ver [ADR-0013](#adr-0013).

<a id='adr-0011'></a>
## ADR-0011 — HUD compacto y oleadas repetibles para depuración M7

- Estado: aceptada para el harness de depuración; no define el HUD final de M13.
- Fecha: 2026-10-08.

### Contexto

El HUD M7 acumulaba selector de perfiles, controles de terreno, estadísticas completas, estado del pipeline de daño y controles de torre en una única columna alta. Ocultaba el tablero y no dejaba repetir el fixture después de la primera oleada, lo que dificultaba comparar los perfiles de daño. Además, el editor del usuario informó que `DamageService`, `DamagePacket` y `DamageResult` no estaban disponibles como tipos globales al analizar scripts nuevos.

### Decisión

- La interfaz principal muestra únicamente estado de base/oleada, selector e inicio de oleada, resumen de torre y un renglón del objetivo actual (HP, armadura, regeneración y daño estimado).
- Una barra inferior ofrece botones persistentes con los atajos `1` Basic Bolt, `2` Perforadora y `3` Drenadora. El atajo/botón inicia el modo de construcción; repetir el mismo atajo lo cancela. Las torres se colocan con clic sobre Grass o Mountain libres.
- `F3` alterna el panel de diagnóstico de terreno (pieza, hover axial, validez, conexiones y herramientas). `D` conserva el overlay visual de rutas y `H` oculta o muestra toda la interfaz.
- Al terminar una muestra, el juego vuelve a `TERRAIN_EXPANSION`, habilita el selector y permite iniciar cualquiera de los fixtures disponibles más de una vez. Esta capacidad solo sirve para validación local de M7; M10 sigue definiendo rondas, incremento de número y victoria de run.
- Los nuevos scripts M7 se cargan por `preload` explícito y los límites entre `Tower`, `BuildController` y el pipeline usan `Node`/`RefCounted`, sin requerir que los tipos globales M7 estén previamente en la caché del editor. Los bits Físico/Fuego/Arcano mantienen sus valores 1/2/4 en los Resources para que sus datos no dependan de cargar una clase de combate.

### Consecuencias

- Se reduce el espacio ocupado por el HUD y los datos de diagnóstico siguen accesibles durante el combate.
- El jugador puede comparar perfiles y oleadas distintas en la misma ejecución, aunque la vida perdida de la base se conserva entre pruebas. Reiniciar la escena devuelve la base a su estado inicial.
- Los atajos son parte del harness M7, no un compromiso con controles finales. La revisión visual de layout, navegación de foco y repetición de fixtures es criterio manual en `IMPLEMENTATION_AND_QA.md#acceptance`.
- La interfaz `RefCounted` evita fallos por orden de indexado de `class_name`, a costa de usar `get`/`set`/`call` en el pipeline M7. La validación manual debe confirmar que no haya errores de método/propiedad en tiempo de ejecución.

### Referencias

- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md`, sección M7, consultado el 2026-10-08.
- `docs/rogue_tower/PROJECT_SPEC.md`, `IMPLEMENTATION_AND_QA.md#progress` y `IMPLEMENTATION_AND_QA.md#acceptance`, consultados el 2026-10-08.
- `.agents/skills/godot-master/references/ui-containers.md`, `resource-data-patterns.md` y `combat-system.md`, consultados el 2026-10-08.

<a id='adr-0012'></a>
## ADR-0012 — Framework de efectos de estado M8

- Estado: contrato histórico de M8; las reglas actuales de regeneración y bonus de daño por capa se ampliaron en M12A/ADR-0023.
- Fecha: 2026-10-08.
- Contexto: el roadmap M8 exige Slow, Burn y un tercer ejemplo provisional, además de duración, ticks, origen y reglas configurables de acumulación. El diseño no confirma catálogo ni resistencias.

### Decisiones

1. `StatusEffectData` es un Resource de contenido. `TowerData.status_effects` lista los efectos que entrega cada impacto; no se mutan los Resources compartidos durante el combate.
2. Cada `Enemy` tiene un `StatusEffectController` que conserva duración restante, acumulaciones, reloj del próximo tick y `source_id` por estado. Los efectos con el mismo ID se combinan dentro del mismo objetivo.
3. `REFRESH` deja una acumulación y reinicia la duración. `ADD_STACKS` añade una acumulación hasta `max_stacks` y reinicia la duración. Ambas reglas conservan la fase del próximo tick. La última aplicación del mismo ID define los datos y el origen activos.
4. Slow modifica el movimiento con `speed_multiplier`. Varios estados de movimiento se combinan usando el mínimo multiplicador activo y la velocidad vuelve a `1.0` al expirar o limpiar esos estados.
5. Burn y Bleed causan daño por tick. Cada tick crea un `DamagePacket` sin payloads de estado y usa el `DamageService` local a `Main`; sus tags pasan por la misma mitigación de armadura y multiplicadores de `EnemyData` que el daño directo.
6. Un efecto se elimina al agotarse su duración. Muerte y llegada a base limpian todos los estados. No se añade resistencia de estado hasta que exista una regla de diseño y datos que lo justifiquen.
7. Bleed se elige como tercer ejemplo para esta etapa, sin cerrar el catálogo. Los valores de Slow/Burn/Bleed, la Sonda de estados, el objetivo y la oleada de diagnóstico son fixtures provisionales.

### Consecuencias

- Los perfiles de torre pueden aplicar varios estados a la vez; el resultado de daño registra los IDs aceptados.
- El HUD de depuración muestra los estados y tiempos del objetivo de la torre seleccionada; el enemigo muestra un aro de color por los IDs temporales de esta demo.
- `Sonda de estados M8` y su oleada permiten comprobar refresco, acumulación limitada, daño periódico, expiración observable de Bleed y limpieza del ciclo de vida desde la escena principal.
- Estado histórico al cierre de M8: los efectos de estado aún no modificaban la regeneración; anti-regen era una capacidad separada de M7. M12A/ADR-0023 sustituyen esta regla: Bleed/Burn/Poison bloquean la regeneración de Salud/Armadura/Escudo y aumentan en +1 el multiplicador de ataque de su capa asociada.
- Si una futura regla requiere acumulaciones con relojes u orígenes independientes por stack, se debe revisar el modelo antes de implementarla.

### Artefactos afectados

- `game/combat/status_effect_data.gd`
- `game/combat/status_effect_controller.gd`
- `game/combat/damage_packet.gd`, `game/combat/damage_result.gd`, `game/combat/damage_service.gd`
- `data/towers/tower_data.gd`, `game/towers/tower.gd`, `game/enemies/enemy.gd`, `game/enemies/path_follower_component.gd`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md`, `PROJECT_SPEC.md`, `PROJECT_SPEC.md`, `PROJECT_SPEC.md#combat`, `IMPLEMENTATION_AND_QA.md#progress`, `IMPLEMENTATION_AND_QA.md#acceptance`, `CONTENT_AND_ASSETS.md#initial-content`, `project_spec.json`

<a id='adr-0013'></a>
## ADR-0013 — Economía de run y maná M9

- Estado: aceptado para implementación; balance provisional. El valor inicial y la presentación de regeneración se actualizan parcialmente en ADR-0030.
- Fecha: 2026-10-08.
- Milestone: M9.

### Contexto

M9 necesita financiar construcción/mejoras, pagar bajas y oleadas, y habilitar ataques que consumen maná. La moneda meta y el guardado permanente pertenecen a M12. No hay edificios de soporte en el alcance. M6 dejó construcción/mejoras sin coste y M7/M8 usan perfiles de diagnóstico.

### Decisiones

1. `RunEconomyService` es hijo de `Main`, no Autoload. Su saldo runtime vive durante la escena/run actual; `RunEconomyData` configura el estado inicial y la regen.
2. Oro de construcción y maná son recursos runtime independientes de `MetaProgression.meta_currency`. M9 no los persiste ni los convierte.
3. `TowerData` posee `build_cost`, `upgrade_costs` por siguiente nivel y `mana_cost_per_attack`. La compra valida y cobra antes de ocupar el hex; la mejora cobra antes de cambiar nivel y devuelve el gasto si la mutación no pudiera completarse.
4. `EnemyData.kill_reward` se paga una vez al recibir muerte, incluida muerte por DoT. Llegar a base no paga recompensa. El pago de una baja resuelta se conserva si después se pierde la misma oleada.
5. `WaveData.round_reward` se paga una sola vez cuando acabaron los spawns y no queda enemigo activo. Una oleada fallida no paga el bonus de limpieza.
6. La torre consume maná antes de crear/aplicar el daño del ataque. Si el saldo no alcanza, el ataque y sus payloads de estado no se ejecutan; la torre vuelve a intentarlo tras una espera breve. El saldo no puede ser negativo.
7. La regen ocurre durante preparación, combate, recompensa y expansión; se limita a `maximum_mana` y no progresa en setup, derrota ni victoria.
8. Las pruebas de oleada M7/M8 pueden repetirse tras un intermedio `ROUND_REWARD` de 0.8 segundos. Este selector temporal no sustituye el loop secuencial de M10.

### Valores provisionales de los fixtures M9

| Dato | Valor de prueba |
|---|---:|
| Oro inicial | 150 |
| Maná inicial / máximo (valor original, sustituido por ADR-0030) | 30 / 100 |
| Regeneración | 1.5 maná/s |
| Basic Bolt / perfiles de diagnóstico | 30 / 40 oro |
| Mejoras (nivel 1→2 / 2→3) | 20 / 35 oro |
| Drenadora M7 | 4 maná por ataque |
| Kill básico / blindado / dummy M8 | 5 / 10 / 5 oro |
| Limpieza oleada básica / M7 / M8 | 20 / 10 / 10 oro |

Son números para verificar operaciones y no balance de la demo.

### Consecuencias

- La UI presenta saldos, regen, costes en atajos y coste de la siguiente mejora; el botón de compra/mejora refleja fondos insuficientes.
- `BuildController` y `Tower` aceptan un servicio opcional para mantener compatibilidad con callers/smokes de hitos anteriores; `Main` siempre inyecta el servicio configurado.
- La prueba manual de `IMPLEMENTATION_AND_QA.md#acceptance` es el criterio de aceptación interactiva. Esta revisión deja dicha aceptación pendiente, no certifica arranque ni gameplay en Godot.
- M9 no añade Support Buildings ni desarrolla el roster de torres M14.

### Roster de demo — paralelo de roles, no de balance

Propuesta de seis perfiles para M14: Ballesta (Ballista), Mortero (Mortar), Bobina Tesla (Tesla Coil), Guardafría (Frost Keep), Lanzallamas (Flame Thrower) y Pulverizador venenoso (Poison Sprayer). Los nombres/roles son provisionales; ver [CONTENT_AND_ASSETS.md#initial-content](CONTENT_AND_ASSETS.md#initial-content). Poison requerirá contenido/status posterior, porque el proyecto solo tiene Slow/Burn/Bleed en M8.

### Referencias externas consultadas el 2026-10-08

Wiki comunitaria; se usaron solamente para mapear arquetipos. No se importaron sus stats ni costes.

- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers)
- [Ballista — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Ballista)
- [Mortar — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Mortar)
- [Tesla Coil — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Tesla_Coil)
- [Frost Keep — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Frost_Keep)
- [Flame Thrower — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Flame_Thrower)
- [Poison Sprayer — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Poison_Sprayer)

La edición de la wiki no está indicada en las páginas. Se consultaron resúmenes indexados porque el acceso directo respondió con bloqueo de robots.

<a id='adr-0014'></a>
## ADR-0014 — Roster jugable de siete torres antes de las cartas

- Estado: aceptada; el alcance de stats/HP fue ampliado y sustituye esta ADR en esas partes mediante ADR-0023, 2026-10-08.
- Contexto: el usuario aceptó los seis arquetipos propuestos para la demo y añadió Shredder. Pidió tener todas estas torres disponibles en el gameplay antes de empezar las cartas de mejora.
- Decisión: introducir una prioridad de implementación M9.5 entre economía y rondas completas. La demo tendrá siete perfiles jugables: Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder. Los atajos `1–7` construyen el roster; `8`, `9` y `0` conservan los perfiles de diagnóstico M7/M8.
- Comportamiento histórico actualizado por ADR-0023: Ballista ataca un objetivo; Mortar resuelve daño de área; Tesla descarga sobre todos los enemigos dentro del alcance; Frost aplica Slow en área y consume maná; Flame y Poison afectan conos con Burn/Poison; Shredder lanza una hoja que sigue la ruta restante de su objetivo, perfora cada enemigo una vez y reduce el daño base en uno por impacto, además de aplicar Bleed.
- Arquitectura: `TowerData` declara patrón de ataque, parámetros geométricos y arquetipo visual. `Tower` selecciona objetivos y envía impactos al `DamageService` existente. Shredder usa un `Node2D` efímero sobre la ruta; no crea un segundo pipeline de daño. Poison se añade como tag configurable con multiplicador de recepción en `EnemyData`.
- Datos y límites históricos: los costes y parámetros jugables viven en Resources. ADR-0023 añade ahora Shield/Armor/Health, adopta como valores iniciales de demo la tabla numérica que el usuario compartió y mantiene el balance configurable/provisional. La decisión original de omitir escudo queda sustituida.
- Consecuencias: `M10` se implementará después de cerrar la aceptación manual M9.5; las cartas M11 siguen posteriores a M10. Los siete perfiles tienen placeholder vectorial y no requieren assets de terceros.
- Verificación: [IMPLEMENTATION_AND_QA.md#acceptance](IMPLEMENTATION_AND_QA.md#roster-jugable-m95) describe cómo probar cada patrón y su coste/maná/estado.
- Referencia comunitaria consultada el 2026-10-08: [Shredder — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Shredder), edición/versionado no visible. Describe hoja que recorre PATH, perfora, pierde daño por enemigo y aplica Bleed. Se usa como referencia de rol; la implementación conserva el patrón general con cifras configurables del proyecto.
- La descripción inicial de Shredder que lo hacía dirigirse al punto de ruta más cercano quedó sustituida por [ADR-0015](#adr-0015): la hoja primero alcanza al objetivo actual y entonces sigue el resto de su ruta.

<a id='adr-0015'></a>
## ADR-0015 — Bleed y recorrido de Shredder

- Estado: recorrido y presupuesto Bleed aceptados; la ausencia de daño directo queda sustituida por ADR-0023, 2026-10-08.
- Contexto: Shredder estaba usando el multiplicador de vida del golpe directo y el daño fijo del Bleed M8. Además, proyectar la hoja al punto geométrico más cercano de toda la ruta podía saltarse la posición actual del objetivo.
- Decisión histórica de M9.5: el contacto de la hoja no aplicaba daño directo. ADR-0023 sustituye esa parte: cada contacto ahora aplica daño directo según H/A/S y añade Bleed con un presupuesto bruto igual al daño base restante de la hoja (10, 9, 8…). El estado reparte el presupuesto entero entre sus ticks restantes.
- Defensa y tipos: cada tick sigue pasando por `DamageService`; armadura y multiplicadores por tag pueden reducir el daño efectivo en HP. El override es runtime por instancia de estado y no muta el `StatusEffectData` compartido.
- Recorrido: la hoja vuela desde la torre hasta la posición actual del objetivo seleccionado y luego avanza por los waypoints restantes de esa ruta. Comprueba cada segmento, registra un impacto por enemigo y desaparece al terminar la ruta o alcanzar daño base cero. Si hay bifurcaciones, sigue la ruta del objetivo inicial.
- Consecuencias históricas reemplazadas: ahora se verifica tanto el impacto directo como el presupuesto de Bleed; la prueba nueva está en la sección M12A de `IMPLEMENTATION_AND_QA.md#acceptance`.
- Verificación pendiente: seguir la prueba manual M9.5 de [IMPLEMENTATION_AND_QA.md#acceptance](IMPLEMENTATION_AND_QA.md#roster-jugable-m95); esta revisión no ejecutó Godot ni pruebas automatizadas.

<a id='adr-0016'></a>
## ADR-0016 — Campaña de veinte rondas

- Estado: **sustituido para calendario, roster y cantidades** por ADR-0037. Conservado como historia del ciclo de expansión M10.
- Contexto: M5 ya podía crear una oleada desde `WaveData`, pero la escena principal permitía repetir cualquier fixture, no contaba spawns pendientes y no obligaba a expandir una sola vez antes de continuar. El roadmap define 20 rondas y el jugador indicó que `docs/rogue_tower/CONTENT_AND_ASSETS.md#reference-enemies` recoge reglas propias confirmadas además de datos comunitarios.

### Decisiones

1. `WaveCampaignData` mantiene exactamente veinte `WaveData` consecutivos, valida que la ronda 17 y 19 sean encuentros de minijefe y la 20 un jefe Tier 2. Las reglas de calendario se promueven a la fuente de verdad; la identidad aprobada posteriormente se registra en ADR-0032; el balance propio del jefe permanece abierto.
2. La campaña usa datos propios placeholder: Asaltante básico, Asaltante acorazado, Regenerador, Minijefe genérico y Jefe Tier 2 genérico. La cifra de vida del Asaltante básico de esta decisión queda sustituida por ADR-0024 para que la Ballista inicial lo elimine de un impacto. Los demás perfiles no importan estadísticas o habilidades de la wiki comunitaria. La identidad inicialmente genérica se actualizó a Ooogie von Ooogovich (Haunted) en ADR-0032; el Resource ejecutable sigue genérico hasta implementar ese diseño. Color y radio son representación vectorial temporal.
3. `WaveCampaignData` configura crecimiento por ronda para vida máxima (+5% por ronda posterior a la primera), daño a base (+2.5%) y recompensa por baja (+2%). Son valores experimentales, editables y no balance aprobado.
4. Antes de configurar cada enemigo de campaña, el director duplica su `EnemyData` y escala la copia runtime. No modifica Resources compartidos. La composición, intervalos y bonus de limpieza viven en `round_01.tres`–`round_20.tres`.
5. El director cuenta `pending_spawn_count` y enemigos vivos por separado. Solo termina cuando no quedan grupos/spawns pendientes, el generador se detuvo y no hay enemigos vivos. El bonus de ronda se emite una vez tras ese punto.
6. Después de limpiar las rondas 1–19, la run entra en `TERRAIN_EXPANSION`; combate real queda bloqueado hasta confirmar una pieza válida de siete hexágonos y actualizar la ruta. Esa confirmación incrementa una sola vez el número de ronda y devuelve a `ROUND_PREP`. No hay expansión tras la 20: limpiar su jefe entra a `RUN_VICTORY`.
7. Los fixtures M7/M8 siguen accesibles como `DEBUG` durante preparación/expansión. El modo diagnóstico vuelve a la fase de origen sin progresar el contador, gastar/recompensar oro o dañar la base. Los diagnósticos no sustituyen ni permiten saltar una ronda real.
8. Alcance histórico de M10: este hito no incluyó las capas Shield→Armor→Health, cartas M11 ni meta-progresión M12; estas llegaron en hitos posteriores. La afirmación de que las capas y counters quedaban pendientes está sustituida por M12A y ADR-0023. La campaña conserva estadísticas propias configurables en vez de copiar cifras de la wiki.

### Configuración provisional de enemigos M10

| Perfil | HP base | Velocidad | Daño a base | Armadura | Regen HP/s | Oro por baja |
|---|---:|---:|---:|---:|---:|---:|
| Asaltante básico | 100 | 90 | 10 | 0 | 0 | 5 |
| Asaltante acorazado | 46 | 76 | 12 | 5 | 0 | 7 |
| Regenerador | 58 | 70 | 10 | 1 | 3 | 8 |
| Minijefe placeholder | 320 | 42 | 24 | 12 | 1 | 60 |
| Jefe Tier 2 placeholder | 1600 | 26 | 50 | 45 | 5 | 200 |

Todos los valores de la tabla se escalan por ronda donde aplique y pueden cambiarse en `.tres`. Las estadísticas salvo la salud del Asaltante básico no se obtuvieron de la tabla de Rogue Tower.

### Consecuencias y aceptación

- El selector HUD muestra el contenido 1–20, etiqueta encuentros especiales y solo permite jugar la ronda activa.
- La expansión de una pieza se vuelve una puerta de progresión; las acciones de build siguen permitidas en preparación/expansión según `BuildController`.
- La demo se completa técnicamente al limpiar la ronda 20. El estado de victoria bloquea nuevos combates, colocaciones y compras.
- Verificar contadores, recompensa, bloqueo, expansión única, encuentros 17/19/20, aislamiento de DEBUG y victoria con la prueba manual M10 en [IMPLEMENTATION_AND_QA.md#acceptance](IMPLEMENTATION_AND_QA.md#prueba-manual-m10-en-el-juego).
- Estado de esta revisión: implementación y documentación en código; aceptación visual/manual pendiente. No se ejecutó Godot ni pruebas en esta revisión.

<a id='adr-0017'></a>
## ADR-0017 — Oferta de terreno y cierre de huecos

- Estado: aceptado para M10, 2026-10-08.
- Contexto: la expansión existente habilitaba la selección directa de cualquier Resource de terreno. El mapa podía conservar vacíos interiores incómodos y el loop no ofrecía una elección acotada después de cada ronda.

### Decisiones

1. Tras las rondas 1–19, `TERRAIN_EXPANSION` ofrece tres `TerrainPieceData` diferentes elegidas sin reemplazo del pool configurado. Son ofertas de expansión, no `CardData` de mejoras M11.
2. Elegir una card fija esa pieza para el ghost de siete hexágonos. La colocación válida continúa exigiendo los contratos actuales de solapamiento, adyacencia y conectividad PATH. `Esc`, clic derecho o el botón de volver abandona el ghost y muestra las mismas tres opciones. Confirmar una pieza válida limpia la oferta y desbloquea una sola ronda. La presentación visual de cards y su inventario inferior se concreta en ADR-0020.
3. Tras construir el tablero candidato, se buscan vacíos dentro de la envolvente axial de sus límites q/r/s. Un vacío solo se rellena si no está conectado a la frontera de esa envolvente ni a una salida PATH explícita que deba seguir funcionando como spawn.
4. Cada vacío interior protegido se convierte al azar, 50/50, en Grass (altura 1) o Montaña (altura 2); la celda es construible y no pertenece a una pieza colocada por el jugador. El relleno se añade al mismo commit lógico que la pieza; se valida el `PathGraph` con el tablero completo antes de aceptarlo.
5. Las opciones de cards se conservan si se ejecuta un fixture DEBUG desde expansión. Un diagnóstico no consume una elección ni adelanta la campaña.

### Consecuencias

- La expansión de terreno requiere seleccionar una de tres opciones y colocarla antes de iniciar la siguiente ronda.
- Las áreas cerradas quedan cubiertas por terreno construible; las aberturas de spawn permanecen vacías para no bloquear rutas.
- Los posibles enemigos siguen viniendo de todos los endpoints PATH activos según ADR-0018.
- La cantidad de opciones (tres), el muestreo uniforme y la mezcla de terrenos de relleno son parámetros provisionales de presentación, no balance final.
- Ver criterios manuales en [M10 de aceptación](IMPLEMENTATION_AND_QA.md#prueba-manual-m10-en-el-juego).

<a id='adr-0018'></a>
## ADR-0018 — Spawn simultáneo en todos los endpoints abiertos

- Estado: **sustituido por ADR-0037**. Las cantidades ahora son fijas por oleada y se reparten round-robin; ya no se crea un enemigo por cada endpoint en cada pulso.
- Contexto: `WaveDirector` seleccionaba un único endpoint por enemigo, aunque `PathGraph` ya enumeraba todas las salidas PATH abiertas con ruta a la base. El comportamiento pedido para la demo es presión simultánea desde todos los lados abiertos.

### Decisiones

1. En oleadas de campaña, cada pulso genera en el mismo frame un enemigo por cada `PathRoute` alcanzable del grafo. Un endpoint PATH explícito abierto con retorno a la base equivale a una salida activa.
2. `WaveEnemyGroupData.count` representa pulsos por endpoint en campaña; `spawn_interval` separa pulsos. La población pendiente inicial y el total anunciado en HUD son `count × endpoints alcanzables` sumado para los grupos.
3. Las políticas `FIRST_SORTED` y `ROUND_ROBIN` continúan limitando los fixtures M5/M7/M8 de diagnóstico. Los diagnósticos no multiplican su grupo por todos los endpoints y siguen aislados de campaña/economía/base.
4. La selección por endpoints no cambia las rutas cacheadas, el BFS ni las bifurcaciones/convergencias; cada enemigo recibe el `PathRoute` concreto de su spawn.

### Consecuencias

- Abrir más finales PATH aumenta el tamaño de cada grupo y el HUD lo refleja. Los valores de campaña actuales son provisionales y el balance debe revisarse después de aceptar el comportamiento visual.
- En el primer spawn de cada pulso se ven enemigos en todos los finales abiertos a la vez; la finalización todavía exige generador detenido, pendientes cero y enemigos vivos cero.
- Ver criterios manuales en [M10 de aceptación](IMPLEMENTATION_AND_QA.md#prueba-manual-m10-en-el-juego).

<a id='adr-0019'></a>
## ADR-0019 — Lectura visual de hexes, combos y base

- Estado: aceptado para el renderer placeholder, 2026-10-08.
- Contexto: las iniciales de terreno y coordenadas dibujadas en cada cara saturaban el mapa. La base provisional era un círculo pequeño dentro de una cara PATH, y el usuario pidió una lectura de hover, señal discreta de combos y una huella completa para la base.

### Decisiones

1. Las caras de terreno no dibujan letras ni coordenadas. El mapa comunica PATH/Grass/Montaña mediante sus colores y el hover conserva el highlight por terreno más la ficha HUD con `(q,r)`, tipo y altura.
2. Clusters hex-conectados de Grass o Montaña se detectan por componente: de 3–4 celdas reciben resplandor tenue de combo 3; de 5 o más, un poco más visible de combo 5. PATH no participa. El feedback es visual y no aplica todavía oro, stats, daño ni otra recompensa.
3. `GameBase` ocupa la cara hexagonal completa en su coordenada axial (radio visual igual al radio de terreno). La decoración del placeholder queda dentro de esa huella y no amplía la ocupación lógica.

### Consecuencias

- El hover HUD se vuelve la única lectura textual de una celda del mapa; los paneles técnicos F3 y el toggle de rutas D siguen disponibles.
- Los clusters también se reconocen cuando incluyen celdas auto-rellenadas, y el ghost permite previsualizar un combo potencial.
- El aspecto/animación del brillo y el arte final de la base son provisionales; la huella axial completa es el contrato confirmado.

<a id='adr-0020'></a>
## ADR-0020 — Cards visuales e inventario de terreno

- Estado: aceptado, 2026-10-08.
- Contexto: la oferta de expansión mostraba una lista textual de composición y escondía las otras opciones tras elegir una. El usuario pidió cards legibles como terreno y posibilidad de cambiar la pieza seleccionada sin reabrir la oferta.

### Decisiones

1. Cada una de las tres opciones es una card clicable que muestra únicamente el nombre de la pieza y una previsualización dibujada de sus siete hexes, colores, alturas y conexiones PATH. No muestra conteos, coordenadas, estadísticas, descripciones ni tooltip.
2. La oferta inicial se centra y da espacio a las previsualizaciones. Tras elegir una pieza, las mismas tres cards se reducen y se mantienen juntas en el inventario inferior, encima de la barra de atajos de torres. La card activa queda resaltada.
3. Mientras no se confirme terreno, elegir otra card cambia la pieza del ghost y conserva la misma oferta. `Esc`, clic derecho o «Volver a cartas» cancelan la selección de colocación y regresan a la oferta centrada sin cambiar las opciones.
4. Confirmar una colocación válida elimina el inventario, limpia las opciones y habilita la ronda siguiente según ADR-0017. El inventario no es el sistema de cartas de mejora M11.

### Consecuencias

- La identidad de una pieza se reconoce por nombre y composición visual; el mapa y el HUD conservan su lectura/diagnóstico independiente.
- La selección/cambio de card es una acción visual durante la expansión; no modifica la oferta hasta la colocación válida.
- Ver criterios manuales en [M10 de aceptación](IMPLEMENTATION_AND_QA.md#prueba-manual-m10-en-el-juego).

<a id='adr-0021'></a>
## ADR-0021 — Cartas de mejora dentro de la run

- Estado: aceptado para el prototipo; lista de operaciones ampliada por ADR-0023; calendario y balance provisionales.
- Fecha: 2026-10-08.
- Contexto: M11 del roadmap requiere `CardData`, oferta/selección, modificadores de torre/globales/maná, filtro por unlocks y un pool inicial. M10 ya coloca una pieza de terreno tras cada ronda 1–19. El diseño deja abierta la cantidad/frecuencia final de cartas y define la fase de carta después de la expansión.

### Decisiones

1. Separar definición, pool y estado runtime: `CardModifierOperation` describe una operación; `CardData` contiene texto/rareza/unlock/operaciones/límite; `CardPoolData` define el pool y calendario; `RunCardService` mantiene ofertas y elecciones de la run.
2. Ejecutar el ciclo en el orden documentado: completar ronda → recompensa → expansión/colocación de terreno → si corresponde, `CARD_OFFER` → preparar la siguiente ronda. `CARD_OFFER` bloquea la siguiente ronda hasta elegir una carta. Las cards de M10 para terreno no son `CardData`.
3. Usar tres opciones, primera oferta después de ronda 3 y luego cada tres rondas hasta la 18. Los datos `offer_size`, `first_offer_round` y `offer_interval` son configurables en `data/cards/demo_card_pool.tres`; esta decisión habilita pruebas de la demo y no cierra el calendario final.
4. Elegir sin duplicados en una oferta, usando `offer_weight`; `unlock_requirement` filtra contenido específico, y `max_per_run` limita repeticiones elegidas. Las cartas ofrecidas pero no seleccionadas permanecen disponibles.
5. Usar modificadores aditivos que se suman y multiplicadores que se componen multiplicando. El set admite daño, alcance, radio de área, coste de maná, duración de estado, maná máximo/regeneración, crítico y suma al multiplicador Health/Armor/Shield. RPM es fijo salvo Frost Keep por cobertura PATH; la operación histórica de cadencia no se ofrece en cartas. Un servicio de run local a `Main` aplica los resultados a torres nuevas/existentes y a la economía.
6. No modificar Resources compartidos. Los status payloads se duplican antes de ajustar duración; `TowerData` y `RunEconomyData` conservan los valores base. La selección y los efectos no se guardan entre runs; M12 conserva los unlocks meta, no las cartas elegidas ni sus modificadores temporales.
7. Configurar 12 cartas originales placeholder para los siete perfiles actuales, estadísticas globales y maná. M12 añade dos cartas de Archivo y M12A añade una global de crítico y tres mejoras globales de multiplicador H/A/S: 18 cartas en el pool actual. Los nombres, pesos, rarezas y cifras son provisionales; las tres mejoras por capa reproducen la forma general de `Monster Studies` consultada como referencia, no una copia completa de sus árboles.

### Consecuencias

- La elección puede cambiar el comportamiento de una run sin añadir sistemas de inventario o edificios de soporte.
- La selección modifica también torres construidas antes de obtenerla, ya que estas consultan el proveedor común de modificadores.
- El HUD de torre/economía presenta los valores efectivos y el preview de construcción incorpora alcance global/específico.
- M12 conecta el filtro a `MetaProgression.get_unlocked_content_ids()` y añade dos cartas que requieren el upgrade permanente `card_archive`; las 12 opciones originales mantienen su configuración M11.
- Ver criterios y procedimiento de aceptación manual en [M11](IMPLEMENTATION_AND_QA.md#m11-cartas-de-mejora).

<a id='adr-0022'></a>
## ADR-0022 — Meta-progresión persistente entre runs

- Estado: Aceptada para implementación M12. M12A/ADR-0023 amplían después el pool de 14 cartas a 18.
- Fecha: 2026-10-08.
- Contexto: M9/M10/M11 ya implementan oro/maná temporales, una campaña de 20 rondas y cartas de mejora de run. El diseño confirma meta-moneda al perder o completar, tienda permanente, desbloqueos y el ciclo morir→mejorar→nueva run. Las cantidades y el catálogo siguen abiertos.

### Decisiones

1. `MetaProgression` conserva moneda, torres desbloqueadas, niveles permanentes, contadores y último resumen en un Autoload que sobrevive al reinicio de la escena. `RunEconomyService` sigue siendo el dueño de oro/maná temporales.
2. `finish_run()` solo puede cerrar/recompensar una run activa una vez. La fórmula de demo se configura en `MetaProgressionData`: `base + rondas completas × incremento`, más bonus de victoria y con tope. La primera pérdida entrega una cantidad mínima, pero avanzar rondas aumenta la recompensa. La fórmula demo actual es 5 + 5 por ronda completa + 30 por vencer, máximo 1000.
3. Ballista es el único unlock inicial provisional. Los otros seis perfiles tienen `unlock_id` estable y coste meta configurable en `TowerData`. El HUD oculta los perfiles bloqueados y `BuildController` también rechaza su construcción. Los mismos IDs alimentan `RunCardService`.
4. `PermanentUpgradeData` guarda costes por nivel, prerrequisitos y una operación por nivel. La demo ofrece bonos de oro inicial, capacidad/regeneración de maná, multiplicador global de daño y una mejora de pool de cartas. Sus efectos se calculan desde el estado meta al preparar la siguiente run; no editan Resources compartidos.
5. La tienda aparece sobre la escena terminal y permite comprar y luego recargar la escena para iniciar una nueva run. En M12 el pool M11 mantenía 12 opciones base y añadía dos cartas filtradas por `meta:card_archive` después de comprar el Archivo; el pool actual de 18 está descrito en ADR-0023.
6. `SaveData` usa JSON primitivo versionado bajo `user://rogue_tower_meta.json`; escribe temporal, rota el save anterior a `.bak` y reemplaza el principal. No guarda Nodes/Resources/runtime de la run. La versión 0 (incluido un `version` ausente) y la versión actual 1 se cargan/migran si el resto del esquema es válido; campos enteros del JSON (versión, moneda, contadores y niveles) aceptan valores numéricos finitos sin parte decimal aunque Godot los entregue como `float`. La migración escribe versión 1 y conserva el original como `.bak`. JSON corrupto o una versión futura desconocida cae a defaults de sesión, conserva el archivo y bloquea operaciones de compra/guardado.
7. La seed de run se registra en resumen y alimenta los RNG locales de oferta de cartas y selección/relleno del terreno para poder reproducir la secuencia al repetir las mismas acciones.

### Consecuencias

- El flujo técnico `RUN_VICTORY`/`RUN_DEFEAT` pasa a resumen/tienda y «Empezar nueva run» conserva el progreso comprado.
- La barra de construcción puede mostrar menos de siete torres hasta adquirir unlocks; las pruebas de diagnóstico con `unlock_id` vacío siguen disponibles en sus atajos.
- Los valores iniciales, recompensas, costes de desbloqueo y upgrades son placeholders editables y no balance final. El refinamiento visual de tienda queda para M13.
- La prueba manual de guardado, compras, filtros, bonus y recuperación está pendiente y se especifica en `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#acceptance`.
- Las seis rotaciones del tablero inicial siguen el contador persistente de runs; el contador ya guardado también evita que al reiniciar la aplicación se repita la orientación anterior.

<a id='adr-0023'></a>
## ADR-0023 — Reglas de torres, mejoras y capas de vida

- Estado: aplicado en código; aceptación visual y de gameplay pendiente. Las reglas Frost de las decisiones 4 y 9 están parcialmente sustituidas por ADR-0059; la regla provisional de no reembolsar al demoler de la decisión 7 fue sustituida por ADR-0064.
- Fecha: 2026-10-08; reglas de enemigos confirmadas y completadas el 2026-10-09.
- Contexto: el usuario pide alinear los siete perfiles de demo con las estadísticas y reglas que compartió, implementar el comportamiento de capas Salud/Armadura/Escudo de Rogue Tower, mostrar sus barras y añadir mejoras por tipo de HP, prioridades y críticos. Esto sustituye las limitaciones provisionales de M9.5 que omitían Shield y describían Mortar como hitscan.

### Decisiones

1. `EnemyData` y la instancia runtime de cada Enemy modelan Health, Armor y Shield con máximos y regeneración configurables (cero significa que ese perfil no usa esa capa). Cada enemigo mantiene valores y regeneración independientes. `TowerData` mantiene daño base y multiplicadores para las tres capas. Cada impacto consulta la capa no agotada más externa en el orden **Shield → Armor → Health**, aplica `base_damage × critical_multiplier × (layer_multiplier + status_bonus) × damage_tag_multiplier` y limita el resultado a los HP de esa capa. `status_bonus` se define en la regla 10. El exceso no pasa a la siguiente capa en ese mismo impacto; se descarta de forma provisional porque la fuente no especifica expresamente overkill.
2. Se incorporan los stats compartidos por el usuario para los siete perfiles: Ballista 10 daño, H/A/S 10/5/5, alcance 5, 20 RPM, 0 maná, 10 oro (+15); Mortar 20, 10/15/5, 10, 10 RPM, 0, 200 (+75); Tesla Coil 10, 6/3/10, 1.5, 30 RPM, 5/ataque, 200 (+75); Frost Keep 6, 10/5/5, 2, 180 RPM iniciales, 2 maná/s, 250 (+100); Flame Thrower 5, 6/9/3, 4, 60 RPM, 1/ataque, 300 (+75); Poison Sprayer 5, 6/3/9, 4, 60 RPM, 1/ataque, 300 (+75); Shredder 10, 20/10/10, 5, 5 RPM, 0, 500 (+100). Los valores se guardan en Resources y siguen siendo parámetros provisionales de la demo.
3. Cada nivel aumenta el daño base en 1 y un multiplicador H/A/S elegido en 1. Un upgrade manual cobra el coste configurado para ese nivel; el jugador puede elegir Vida, Armadura o Escudo. La torre también gana experiencia mientras mantiene un objetivo en alcance, aunque no le cause daño. El HP actual del objetivo asigna la experiencia a una sola capa; la fórmula temporal implementada es `(0.5 + 1 / (2 × alcance_hex)) XP/s`, y tanto el umbral de nivel como el máximo son configurables.
4. Elevación suma +1 de daño base y +0.5 hexes de alcance por nivel. RPM permanece fijo salvo Frost Keep: suma 18 RPM por cada celda PATH cubierta por su rango cuadrado. **Regla histórica de coste Frost sustituida por ADR-0059:** inicialmente el coste por segundo se convirtió a gasto por disparo; ahora se drena continuamente durante combate. Tesla, Flame y Poison pueden escalar su coste por ataque proporcionalmente al daño base. No hay edificios de soporte.
5. El crítico comienza en 0% y se acumula en bandas: hasta 50% para ×2; el siguiente 50% para ×3; el siguiente 50% para ×4. Los chequeos ocurren ×4, ×3 y ×2, cada banda con máximo 50%. Se agrega una carta global de +15% y Bobina sobrecargada pasa de aumentar RPM a añadir +15% crítico, porque el usuario compartió que las torres no cambian RPM salvo Frost Keep.
6. Se exponen hasta tres prioridades únicas en orden. Se admiten progreso, HP de la capa activa más bajo, valores de Health/Armor/Shield más altos o bajos y velocidad más alta o baja. Si empatan todos los criterios, el desempate es estable por ID de instancia.
7. Regla histórica, sustituida por ADR-0064: el precio de construcción es `precio_base + cantidad_en_tablero_del_mismo_tipo × incremento`; se había dejado la demolición sin reembolso por falta de fórmula explícita. El comportamiento vigente devuelve el precio marginal del slot que deja libre.
8. Enemy dibuja una fila por cada capa con máximo positivo, en orden Shield/Armor/Health y colores azul/beige/verde; Health aparece siempre y se fragmenta. Bleed bloquea regeneración de Health; Burn bloquea Armor; Poison bloquea Shield. El HUD de torre seleccionada presenta valores actuales/máximos y regeneración por capa.
9. Ballista lanza un proyectil a un objetivo; Mortar lanza un proyectil a una posición y hace daño de área al aterrizar; Tesla descarga sobre todos los enemigos dentro de su alcance circular; **la regla Frost original de Slow en área queda sustituida por ADR-0059:** cada copo individual daña y aplica Slow solo al impactar; Flame/Poison afectan sus conos y convierten el 100% de su daño base en Burn/Poison; Shredder recorre PATH, hace su impacto con multiplicadores de capa, añade Bleed por el 100% del daño base restante de la hoja y pierde 1 de daño base por enemigo que atraviesa. Todos los daños usan `DamageService`.
10. Los efectos Bleed/Burn/Poison suprimen la regeneración Health/Armor/Shield correspondiente. Un ataque directo contra una unidad con el estado activo suma +1 al multiplicador de su capa asociada, una sola vez mientras dure el estado y sin escalar por acumulaciones; este bonus no se aplica a los ticks periódicos. Los ticks aplican 100% de su daño configurado a la capa asociada y 50% a las otras capas mediante los multiplicadores del estado. El pool M11 incluye además tres cartas globales, una por capa, que suman +1 a su multiplicador para todas las torres.
11. La tabla comunitaria de mejoras de cada perfil sirve como guía de roles y clases de mejora. La demo mantiene un subconjunto configurable: una carta específica por perfil, mejoras H/A/S globales, crítico, rango, área, maná y estados. Los costes manuales de mejora usados como fixture son Ballista/Mortar 10 (+10), Tesla/Frost 20 (+20) y Flame/Poison/Shredder 30 (+30) oro.

### Fuente y provisionalidades

- Los nombres, roles, orden Shield/Armor/Health, prioridades, mejoras, críticos y estadísticas de la tabla provienen de la información pegada por el usuario. La referencia comunitaria aclara que Tesla descarga sobre todos los enemigos en alcance y detalla los árboles de mejoras por HP y estado; las cifras compartidas por el usuario prevalecen para la demo. Los costes de upgrade, umbral de XP, radios de área, velocidades y demás cifras no facilitadas explícitamente continúan siendo fixtures configurables.
- Las páginas comunitarias [Towers](https://rogue-tower.fandom.com/wiki/Towers), [Monsters](https://rogue-tower.fandom.com/wiki/Monsters), [Hit Points](https://rogue-tower.fandom.com/wiki/Hit_Points), [Status Effects](https://rogue-tower.fandom.com/wiki/Status_Effects), [Upgrade Cards](https://rogue-tower.fandom.com/wiki/Upgrade_Cards) y las fichas de torre se consultaron el 2026-10-08 y 2026-10-09. La edición/versión no está indicada. El acceso directo se bloqueó en la consulta del 2026-10-09; se revisaron resultados indexados. Son referencias comunitarias CC BY-SA salvo indicación distinta, no una fuente oficial de balance.
- El overflow de daño, el reembolso al demoler, las formas exactas de áreas/cono, el umbral de XP y todas las cifras de balance siguen abiertos salvo los valores explícitos del usuario.

### Consecuencias

- Quedan reemplazadas las afirmaciones de M9.5 que decían que Shield no existía y que Mortar era hitscan. La tabla no se considera balance final.
- El enemigo de entrenamiento Salud/Armadura/Escudo y la opción DEBUG de Main permiten probar las tres capas, barra, bonus de ataque y regeneraciones sin modificar la campaña. El jefe genérico provisional de ronda 20 tiene Escudo 100 y regeneración 1/s para exponer visualmente la capa en la campaña; no es una cifra de balance de Rogue Tower.
- Seguir [los criterios M12A de aceptación](IMPLEMENTATION_AND_QA.md#m12a-reglas-de-torres-y-capas-de-vida) antes de marcar el comportamiento como aceptado en gameplay.

<a id='adr-0024'></a>
## ADR-0024 — Ballista elimina al enemigo básico

- Estado: aplicado en datos; aceptación en gameplay pendiente.
- Fecha: 2026-10-08.
- Contexto: el usuario indica que la Ballista debe eliminar de un disparo al enemigo básico, como en Rogue Tower, sin reducir artificialmente el daño de las torres ni ignorar Health/Armor/Shield de los enemigos.

### Decisiones

1. El Asaltante básico de la primera ronda usa 100 Health, 0 Armor y 0 Shield. Estos son los valores del Goblin básico de la referencia que el usuario incluyó en `docs/rogue_tower/CONTENT_AND_ASSETS.md#reference-enemies`; se conservan el nombre y los demás parámetros propios del proyecto.
2. La Ballista conserva sus datos ya aprobados: daño base 10 y multiplicadores H/A/S 10/5/5. Por tanto, contra el enemigo básico sin capas defensivas, su daño es 10 × 10 = 100 y un impacto lo derrota.
3. La cadencia de Ballista queda en 20 RPM (un disparo cada 3 s); `rounds_per_minute` es el dato runtime canónico y `attack_rate` conserva el equivalente de 1/3 disparos por segundo como fallback de compatibilidad.
4. `DamageService` sigue resolviendo únicamente la capa activa en orden Shield → Armor → Health, usando el multiplicador correspondiente a torre y capa. No se reduce la salud de enemigos acorazados ni se modifica el daño base para simular el resultado.
5. Los otros perfiles de enemigos y su escalado por ronda quedan configurables. Este ajuste puntual no convierte todas las cifras comunitarias en balance confirmado.

### Referencias y verificación

- [Goblin — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Goblin), consultada el 2026-10-08. La entrada indica 100 Health y que una Ballista lo derrota de un impacto.
- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers), consultada el 2026-10-08. La tabla usada por el usuario fija Ballista en 10 de daño y multiplicador Health 10.
- [Hit Points — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Hit_Points), consultada el 2026-10-08. El daño a cada capa es daño base × multiplicador de esa capa; solo se puede dañar Health tras agotar Armor y Shield.
- [Ballista — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Ballista), consultada el 2026-10-08. La ficha indica 20 disparos por minuto y describe un disparo cada 3 segundos; el cooldown del proyecto se calcula como `60 / 20 = 3` segundos.
- Añadir/ejecutar la comprobación de la ronda 1 descrita en [IMPLEMENTATION_AND_QA.md#acceptance](IMPLEMENTATION_AND_QA.md#prueba-manual-m12a-en-el-juego): una Ballista sin mejoras elimina un enemigo de 100 Health de un impacto, y las capas defensivas siguen recibiendo su daño de capa.

<a id='adr-0025'></a>
## ADR-0025 — Tablero inicial amplio y ruta mínima

- Estado: parcialmente sustituido en la ubicación de base y geometría de ruta por [ADR-0056](#adr-0056); se mantienen el tablero de 19 celdas y la longitud mínima de cuatro PATH.
- Fecha: 2026-10-08.
- Contexto: el usuario pide más terreno disponible al comenzar y que el camino de los enemigos hasta la base tenga al menos cuatro celdas PATH; la muestra previa tenía una única celda de camino antes de la base.

### Decisiones

1. La loseta de expansión sigue teniendo exactamente siete hexágonos. El tablero de partida es un concepto distinto: `StartingBoardData` configura una huella axial de radio 2, con 19 celdas conectadas, 15 construibles y 4 PATH.
2. La base permanece en `(0,0)`. El camino inicial sigue `(0,0) → (1,0) → (2,-1) → (2,-2)`; la salida de spawn abierta queda en la coordenada exterior `(3,-2)`. La ruta contiene cuatro celdas PATH, contando spawn y base.
3. `PathGraph.rebuild` acepta `minimum_spawn_route_cells`. `Main` lo configura como 4 para el tablero inicial y para validar cada expansión de campaña. Un endpoint con una ruta más corta se rechaza. Las llamadas genéricas/diagnósticas pueden usar el valor por defecto de una celda.
4. El resto de las celdas iniciales alterna Grass y Mountain y sigue siendo terreno construible. Su distribución es visual provisional; no crea caminos, bonificaciones ni restricciones de construcción adicionales.
5. La huella inicial completa rota alrededor de la celda de base en seis orientaciones axiales. Cada nueva run avanza un paso de 60° respecto a la anterior (contador persistente de runs módulo 6); coordenadas, sockets PATH exactos y sockets flexibles rotan juntos. La base conserva su coordenada `(0,0)`.

### Consecuencias y aceptación

- La configuración del tablero inicial vive en `data/terrain/starting_board.tres`; cada celda se instancia en `HexGrid`. El tamaño de las piezas de expansión no cambia.
- `docs/rogue_tower/PROJECT_SPEC.md#terrain` y `project_spec.json` describen el tablero semilla y la ruta.
- Verificar la escena principal con la prueba manual M10: 19 celdas al iniciar, base completa en `(0,0)`, cuatro celdas PATH desde spawn hasta base, orientación inicial distinta por run y rechazo de cualquier expansión que genere un endpoint a menos de cuatro celdas PATH.
- Godot 4.7 headless verificó las seis rotaciones y que cada una conserva el grafo/ruta mínima; la inspección visual del tablero sigue pendiente.

<a id='adr-0026'></a>
## ADR-0026 — Jerarquía de la interfaz de run y tienda terminal

- Estado: Parcialmente sustituida por ADR-0027 para la distribución del HUD y ADR-0031 para el formato actual de iconos; los acuerdos funcionales restantes siguen vigentes. Aceptación visual manual pendiente.
- Fecha: 2026-10-08.
- Contexto: la escena ya tenía controles funcionales para campaña, terreno, combate, siete torres y meta-progresión, pero acumulaba el selector de diagnóstico y la lectura técnica del objetivo junto al HUD habitual. La tienda terminal mostraba muchos desbloqueos y mejoras en una sola lista, y el resultado de run compartía jerarquía con las compras. M13 requiere que los sistemas de la demo sean legibles sin depender del modo DEBUG.

### Decisiones

1. El HUD habitual prioriza la vida de la base, oro/maná de run, fase/ronda y las acciones de campaña. Una franja visual de veinte segmentos diferencia rondas completadas, actual y pendientes; los encuentros especiales 17/19/20 reciben un acento discreto.
2. La selección de fixtures de ronda y el inspector detallado de objetivo pasan al panel técnico que abre `F3`. No se eliminan los harnesses M7/M8 ni los atajos de diagnóstico `8–0`. El resumen compacto de la torre seleccionada mantiene sus stats relevantes visibles; al pasar el cursor sobre él se consulta el objetivo, capas, regeneración, daño estimado y estados.
3. Las estadísticas de torre se presentan en líneas agrupadas: nivel, daño, multiplicadores H/A/S, alcance, RPM, crítico, patrón, coste de maná y XP. Prioridad, mejora y demolición aparecen solo con una torre seleccionada; sus tooltips describen coste y efecto.
4. La tienda terminal muestra primero victoria/derrota, ronda alcanzada, rondas completadas, recompensa y saldo meta. Dos categorías separan desbloqueos de torres y mejoras permanentes; cada opción explica efecto/estado y coste, y una acción persistente inicia la siguiente run.
5. Un helper de estilo aplica placas azul pizarra, bordes acero, botones con hover ámbar y colores de estado verde/terracota. La jerarquía se construye con controles nativos de Godot; el uso posterior de iconos propios en SVG queda especificado en ADR-0027.
6. Los cambios M13 son de presentación y acceso a información. No cambian fórmulas, datos de balance, reglas de progresión, save, combate ni controles de cámara. `H` sigue ocultando todo el HUD y el panel F3.

### Consecuencias y aceptación

- Las funciones DEBUG continúan disponibles en una vista técnica plegable, mientras el estado de campaña no comparte espacio con datos continuos de diagnóstico.
- La tienda conserva compra persistente, validación de saldo/guardado y reload de nueva run de M12; solo cambia su organización visual.
- Implementar no equivale a aceptar: `IMPLEMENTATION_AND_QA.md#acceptance` define la comprobación manual de campaña, torre, terreno, tooltips y ambas salidas terminales en ventana Godot.
- Esta decisión no fija balance ni arte final; colores, espaciados y placeholders siguen ajustables después de la revisión visual.

### Referencias

- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md` (M13 UX/UI).
- `docs/rogue_tower/PROJECT_SPEC.md` (presentación de M13).
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#acceptance` (aceptación manual M13).

<a id='adr-0027'></a>
## ADR-0027 — HUD en tres paneles e iconos vectoriales reutilizables

- Estado: Parcialmente sustituida por ADR-0028 para feedback/controles de torre y ADR-0031 para el formato de iconos; distribución en tres paneles, jerarquía de recursos y comportamiento terminal siguen vigentes. Aceptación visual manual pendiente.
- Fecha: 2026-10-08.
- Contexto: la primera organización M13 reunía recursos, ronda y torre seleccionada en un panel superior grande. La lectura era densa y el jugador no distinguía de un vistazo la salud de la base, el inicio de la ronda y las acciones de torre.

### Decisiones

1. El HUD normal se distribuye en tres paneles: recursos compactos arriba a la izquierda, ronda/progreso/acción arriba al centro y detalles/acciones de la torre arriba a la derecha. La barra inferior de construcción conserva los atajos `1–7`.
2. Se elimina el título «RogueTower». La salud de la base se representa con una `ProgressBar` y el valor actual/máximo dentro de la barra. Oro y maná tienen iconos propios; el icono y valor del oro reciben mayor tamaño visual.
3. El panel de torre solo aparece durante la selección de una torre o mientras se está colocando una. Un clic en una casilla sin torre o fuera del tablero limpia la selección; abrir F3 oculta temporalmente el panel de torre y mantiene accesibles sus controles técnicos.
4. La primera versión guardó nueve iconos en un atlas SVG propio. ADR-0028 registró su sustitución por PNG RGBA; ADR-0031 reemplaza el atlas por un PNG independiente para cada objeto.
5. El panel de ronda mantiene los veinte segmentos de campaña y el botón de inicio. La nueva distribución solo cambia la presentación y la selección de torre; no modifica balance, combate, economía, progresión ni reglas de campaña.

### Consecuencias y aceptación

- El mapa conserva espacio libre en el centro y los tres paneles separan claramente los estados permanentes, el control de ronda y las estadísticas contextuales.
- La aceptación manual debe confirmar lectura a 1440×900, valor de vida dentro de la barra, jerarquía de oro/maná, los nueve iconos, visibilidad condicional de torre y convivencia con F3, `H` y la barra inferior.
- El atlas SVG y el atlas PNG fueron retirados; el formato actual de iconos PNG independientes está en ADR-0031.

### Referencias

- Sustituye la distribución descrita en los puntos 1–3 y actualiza el recurso visual descrito en el punto 5 de [ADR-0026](#adr-0026); su jerarquía de tienda y comportamiento terminal siguen vigentes.
- [M13 UX/UI](IMPLEMENTATION_AND_QA.md#roadmap).
- [Pruebas de aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

<a id='adr-0028'></a>
## ADR-0028 — Atlas PNG y feedback visual de torres y enemigos

- Estado: Parcialmente sustituida por ADR-0031 en el formato y almacenamiento de iconos; las decisiones de feedback visual, HUD y controles restantes siguen vigentes. Revisión manual en ventana pendiente.
- Fecha: 2026-10-08.
- Contexto: los controles de selección, el preview y las torres colocadas usaban representaciones distintas; el HUD mostraba demasiada información textual y los impactos/estados de enemigos no tenían feedback visual suficiente.

### Decisiones

1. La primera implementación M13 utilizó `game/ui/tower_defense_icons.png`, un atlas PNG RGBA 4×4 con 16 regiones: moneda, energía, vida, armadura, escudo, siete torres y cuatro estados (fuego, ralentización, veneno y sangrado). El arte era placeholder de proyecto, no importado de terceros; el atlas quedó retirado por ADR-0031.
2. En esa versión, `IconCatalog` proporcionaba regiones `AtlasTexture` a la barra de selección, preview de construcción, torres colocadas, barras/cap de estados, economía, resumen y mejoras de capas, tienda y cards. Cada atajo de torre era cuadrado, con icono grande, nombre y precio con el icono de moneda. ADR-0031 conserva los usos y sustituye la implementación por `Texture2D` independientes.
3. El hover y la selección de una torre muestran alcance y contorno; el panel lateral puede desplazarse para evitar recortes. La prioridad se configura desde un único menú checkable y admite hasta tres criterios distintos.
4. La vida del enemigo se dibuja en fragmentos y con barras/carriles mayores para que se lean en el tablero. Escudo y armadura ocupan carriles sobre la salud en un marco común; cada carril se identifica con su PNG ampliado. Los estados activos muestran el símbolo PNG sin una placa de fondo y un contador solo si hay más de una acumulación; los iconos también aumentan de tamaño.
5. `DamageService.damage_resolved` alimenta la presentación: el enemigo destella y salta; se genera un texto flotante coloreado según escudo, armadura o salud. El servicio continúa siendo dueño del cálculo de daño.
6. Los textos de cards, mensajes y lecturas técnicas que nombran oro/maná insertan el icono en línea. Las cards que modifican una torre muestran su sprite. La moneda meta conserva su identidad separada.
7. La UI y el feedback son de presentación; no alteran balance, costes, duración de estados, priorización efectiva, daños, progresión ni reglas de campaña. En su momento se sustituyó el atlas SVG de ADR-0027; la decisión de guardar iconos en un atlas PNG queda sustituida por ADR-0031.

### Consecuencias y aceptación

- La selección, el preview y la torre colocada muestran el mismo sprite reconocible.
- La prueba manual debe confirmar hover/selección, panel desplazable, selector de prioridades, iconos y fragmentación de barras, acumulaciones, textos de daño y animación. El procedimiento completo queda en `IMPLEMENTATION_AND_QA.md#acceptance`.
- Los iconos y las animaciones son placeholders editables. El formato vigente y el catálogo de IDs se definen en ADR-0031.

### Referencias

- [ADR-0027: HUD en tres paneles](#adr-0027).
- [Roadmap M13](IMPLEMENTATION_AND_QA.md#roadmap).
- [Arquitectura técnica](PROJECT_SPEC.md#architecture).
- [Pruebas de aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

<a id='adr-0029'></a>
## ADR-0029 — Previsualización de spawns durante la expansión

- Estado: Aceptada para implementación; revisión visual manual pendiente.
- Fecha: 2026-10-08.
- Contexto: los marcadores permanentes mostraban los endpoints activos, pero el jugador no podía anticipar qué salidas PATH permanecerían, se cerrarían o aparecerían al colocar una pieza de terreno.

### Decisiones

1. Mientras haya un ghost geométricamente válido, `Main` construye un `PathGraph` candidato a partir del tablero actual, la pieza transformada y los huecos encerrados que se rellenarían al confirmar. Este grafo es temporal: no muta `HexGrid` ni reemplaza el grafo activo.
2. El candidato debe pasar las mismas validaciones que se aplican al confirmar la pieza, incluidas continuidad a la base y longitud mínima de las rutas. Si el grafo candidato es inválido, la colocación no se muestra como válida y el botón de confirmar permanece deshabilitado.
3. `TerrainPiecePreview` compara endpoints identificados por hex PATH y dirección de borde. Los endpoints futuros se dibujan `NUEVO` (verde) o `SIGUE` (cian); los actuales que desaparecerían se marcan `CIERRA` con una X roja. La etiqueta de estado comunica cantidad actual/futura y altas/cierres.
4. El tipo de relleno de un hueco encerrado no afecta al grafo: preview y confirmación lo consideran no PATH; la elección Grass/Montaña aleatoria sucede al confirmar y conserva exactamente los endpoints candidatos.
5. El snapshot activo y los spawns reales solo cambian después de confirmar la pieza. Las oleadas continúan usando el `PathGraph` confirmado.

### Consecuencias y aceptación

- El jugador ve el resultado de la expansión antes de colocar la pieza y puede cambiar su posición o rotación sin alterar el tablero.
- La aceptación manual debe verificar marcadores nuevos, conservados y cerrados, recuento actualizado, rechazo de grafos inválidos y coincidencia con los spawns tras confirmar. El procedimiento está en `IMPLEMENTATION_AND_QA.md#acceptance`, apartado M10.
- Los colores y etiquetas son feedback visual; no modifican selección de rutas ni balance.

### Referencias

- [ADR-0007: grafo lógico de caminos](#adr-0007).
- [ADR-0017: oferta de terreno y cierre de huecos](#adr-0017).
- [Roadmap M10](IMPLEMENTATION_AND_QA.md#roadmap).
- [Pruebas de aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

<a id='adr-0030'></a>
## ADR-0030 — Maná inicial y presentación de la regeneración

- Estado: aceptada para implementación; balance provisional.
- Fecha: 2026-10-08.
- Alcance: perfil de economía M9 y presentación de accesibilidad de los atajos de torre.

### Contexto

El perfil M9 comenzaba con 30 de 100 maná y algunas mejoras mostraban tasas fraccionarias como `0,5` y `0,25` por segundo. Además, el contenido personalizado de los botones de torre mantenía sus colores aunque el botón estuviera deshabilitado por falta de oro.

### Decisiones

1. El perfil predeterminado inicia la run con su capacidad completa: 100/100 maná. `RunEconomyData.starting_mana` sigue siendo configurable y las bonificaciones de inicio se conservan; el cambio afecta al valor por defecto.
2. Las tasas runtime siguen siendo precisas y configurables. Las descripciones visibles expresan las fracciones como equivalencias enteras: 1,5 maná/s se presenta como 3 maná cada 2 s; 0,5 como 1 cada 2 s; 0,25 como 1 cada 4 s. No se redondea ni altera el cálculo de regeneración.
3. Los atajos de torre siguen deshabilitándose ante saldo insuficiente y ahora atenúan también el contenido personalizado (icono, nombre y precio). El tooltip explica que falta oro.

### Consecuencias

- El jugador empieza con recursos para desplegar torres consumidoras de maná sin esperar a regeneración.
- La representación de tasas evita decimales sin ocultar su equivalencia ni cambiar el balance efectivo.
- La falta de oro se comunica tanto por interacción como visualmente. La compra sigue validándose en `BuildController` antes de ocupar terreno.
- Los valores y costes de M9 continúan siendo provisionales. Ver la prueba manual M9/M13 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- [ADR-0013: Economía de run y maná M9](#adr-0013).
- [Modelos de datos](PROJECT_SPEC.md#data-models).

<a id='adr-0031'></a>
## ADR-0031 — PNG independientes para cada icono

- Estado: Aceptada e implementada.
- Fecha: 2026-10-08.
- Contexto: el HUD, las torres, las mejoras y las barras de enemigos consumían regiones de un único atlas PNG. El usuario pidió explícitamente que cada objeto tuviese su propio archivo PNG y que no se use un atlas compartido.

### Decisiones

1. Se conserva el arte placeholder existente y se exporta cada una de sus 16 celdas como un PNG RGBA transparente de 256×256 en `game/ui/icons/`.
2. Los IDs de archivo son `gold`, `mana`, `health`, `armor`, `shield`, `ballista`, `mortar`, `tesla_coil`, `frost_keep`, `flame_thrower`, `poison_sprayer`, `shredder`, `burn`, `slow`, `poison` y `bleed`.
3. `IconCatalog` resuelve cada ID a un `Texture2D` PNG independiente. Los botones, previews, torres colocadas, HUD, cards, barras y estados continúan usando estos IDs y sprites.
4. Se elimina `game/ui/tower_defense_icons.png` y su archivo `.import`. No se generan atlas ni se agrupan los sprites en una textura común.

### Consecuencias y aceptación

- Un objeto puede reemplazarse o editarse sin recortar ni volver a exportar los demás.
- La forma cuadrada 256×256 y el canal alfa mantienen una escala de origen uniforme y los fondos transparentes que espera la UI.
- La inspección de los PNG debe confirmar que cada archivo contiene solo su objeto, conserva transparencia y no pierde detalles en los límites de la celda original. La aceptación visual dentro de Godot se mantiene pendiente junto con M13.

### Referencias

- Sustituye la decisión de atlas PNG del [ADR-0028](#adr-0028).
- [Arquitectura técnica](PROJECT_SPEC.md#architecture).
- [Especificación del proyecto](archive/initial_import/project_spec.json).
- [Pruebas de aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

### Extensión del roster de enemigos (2026-10-09)

Los sprites de enemigos siguen el mismo contrato de PNG independiente: `EnemyData.sprite_texture` referencia un archivo RGBA individual en `assets/enemies/`. El juego no carga un atlas de enemigos; el arte fuente se separa antes de incorporarse al roster.

<a id='adr-0032'></a>
## ADR-0032 — Ooogie von Ooogovich — identidad y fase adaptada

- Fecha: 2026-10-09.
- Estado: identidad, habilidades adaptadas y ciclo de transformación aceptados; colocación fija en ronda 20 sustituida por ADR-0037; balance propio provisional implementado.
- Sustituye parcialmente: la identidad antes abierta en ADR-0016.
- Autoridad activa: la tabla de [campaña de 45 rondas](CONTENT_AND_ASSETS.md#campaign) decide en qué oleadas aparece.

### Contexto

El diseño anterior reservaba un Tier 2 Boss para la ronda 20. El usuario eligió Ooogie von Ooogovich (Haunted) y aprobó adaptar sus mecánicas de invocación y transformación con balance propio. Después, la tabla exacta del prompt extendió la demo a 45 rondas y ubicó el jefe en las rondas que esa tabla indica.

### Decisiones

1. El nombre canónico del perfil es **Ooogie von Ooogovich**; pertenece al roster Haunted.
2. Mientras su forma inicial está viva, invoca dos Bats cada 2 segundos.
3. Al morir la forma inicial, la misma instancia se transforma en Bat con 2.500 Health.
4. La transformación no termina la ronda ni concede la recompensa de baja. La ronda espera a que muera la forma Bat; entonces la instancia paga una vez con la recompensa del jefe original.
5. Health 8.000, Armor 1.500, Shield 2.000, regeneración de Health 25/s y Shield 10/s, velocidad 26 px/s, daño a base 50 y 200 Gold son parámetros propios provisionales. No se copian los valores de la wiki.
6. La campaña incluye el perfil donde aparezca en la tabla; ya no tiene una asignación obligatoria a ronda 20.

### Consecuencias

- El Resource activo es data/enemies/campaign_tier2_boss.tres y la tabla exacta vive únicamente en CONTENT_AND_ASSETS.md#campaign.
- WaveDirector conserva el mismo enemigo activo durante la segunda fase; las invocaciones sí son enemigos adicionales.
- Los valores de balance pueden ajustarse sin cambiar el patrón aprobado.
- ADR-0037 registra la prioridad de la tabla y la implementación de habilidades.

### Referencia

[Ooogie von Ooogovich — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Ooogie_von_Oogovich), Fandom comunitario, consultada el 2026-10-09; edición/changelog no indicado. Se usan ideas de comportamiento, no su balance publicado.

<a id='adr-0033'></a>
## ADR-0033 — Nomenclatura canónica alineada con Rogue Tower

- Fecha: 2026-10-09.
- Estado: nombres canónicos aceptados; las designaciones Miniboss de 17/19 quedaron retiradas por ADR-0037.
- Autoridad activa: [Nomenclatura](CONTENT_AND_ASSETS.md#canonical-names).

### Contexto

El usuario pidió unificar los nombres de enemigos, torres, estados, mejoras y términos con Rogue Tower. Las cards cuyo efecto difiere mantienen nombre propio. La selección previa asignaba Cyclops y Werewolf como Minibosses propios en las rondas 17 y 19; posteriormente el usuario dio prioridad a la tabla exacta de 45 rondas y retiró esas designaciones.

### Decisiones

1. Las siete torres jugables usan los nombres **Ballista**, **Mortar**, **Tesla Coil**, **Frost Keep**, **Flame Thrower**, **Poison Sprayer** y **Shredder**.
2. Los 26 enemigos usan los nombres visibles del roster seleccionado que aparecen en CONTENT_AND_ASSETS.md#canonical-names y CONTENT_AND_ASSETS.md#content-roster. La lista exacta de oleadas está solo en CONTENT_AND_ASSETS.md#campaign.
3. Cyclops y Werewolf son unidades normales cuando la tabla las enumera; no son Minibosses especiales en 17/19. Los tipos de encuentro activos son Standard, Boss y Tier 2 Boss.
4. Los estados se llaman **Bleed**, **Burn**, **Poison**, **Slow**, **Haste** y **Fortification**. Las capas son **Health**, **Armor** y **Shield**; recursos **Gold**, **Mana** y **XP**.
5. Se adoptan títulos de Rogue Tower solo cuando hay correspondencia de función: **Blizzard**, **Advanced Circuits**, **Treasury**, **Sourcery** y **Mana Capacity**. Si la operación de una card propia difiere, conserva su título propio.
6. Los fixtures de diagnóstico se marcan DEBUG y quedan fuera del roster de campaña. Los IDs y rutas permanecen estables salvo que dividir un perfil requiera Resources distintos.

### Consecuencias

- Los nombres visibles en Resources, selectores, cards y UI siguen CONTENT_AND_ASSETS.md#canonical-names.
- Compartir un nombre no importa automáticamente su balance o comportamiento.
- ADR-0037 sustituye las designaciones antiguas de rondas 17/19 y amplía el roster a 45 rondas.

### Fuentes

Nombres contrastados el 2026-10-09 en la wiki comunitaria: [Towers](https://rogue-tower.fandom.com/wiki/Towers), [Monsters](https://rogue-tower.fandom.com/wiki/Monsters), [Status Effects](https://rogue-tower.fandom.com/wiki/Status_Effects), [Upgrade Cards](https://rogue-tower.fandom.com/wiki/Upgrade_Cards) y [Permanent Upgrades](https://rogue-tower.fandom.com/wiki/Permanent_Upgrades). Edición de Fandom no indicada; ver atribución en [ORIGEN.md](CONTENT_AND_ASSETS.md#origin-and-sources).

<a id='adr-0034'></a>
## ADR-0034 — Reembolso de cooldown de Ballista al perder el objetivo

- **Fecha:** 2026-10-09
- **Estado:** Aceptado; Godot 4.7 analizó los scripts sin errores de parseo. La aceptación funcional dentro de una run sigue pendiente.
- **Ámbito:** proyectiles de Ballista durante la campaña.
- **Fuente de la decisión:** instrucción del usuario del 2026-10-09.

### Contexto

Al principio de la campaña, varias Ballistas pueden disparar al mismo enemigo y quedar esperando todo su tiempo de recarga aunque otras torres ya hayan eliminado el objetivo. Se necesita conservar la cadencia independiente de cada Ballista y recuperar parte de la recarga solo cuando su proyectil pierde un objetivo vivo por una causa ajena a ese impacto.

### Decisión

1. Cada proyectil de Ballista identifica el ciclo de recarga que inició su propio disparo.
2. Si su objetivo pasa a `DEAD` antes del impacto de ese proyectil, la Ballista dueña del disparo descuenta del tiempo restante el **33 % de la duración completa de ese cooldown**.
3. El reembolso no puede reducir el cooldown por debajo de cero y se puede aplicar una sola vez al ciclo activo de esa Ballista.
4. El impacto que mata al objetivo no da reembolso. Tampoco lo da un objetivo que llega a la base ni un objetivo que muere después de que el proyectil ya impactó.
5. Mortar y las demás torres no usan esta regla. Cada Ballista conserva su propio cooldown y los proyectiles de ciclos antiguos no pueden alterar la recarga de un disparo posterior.

### Consecuencias

- Varios proyectiles pueden perseguir al mismo objetivo sin bloquear la cadencia de las Ballistas cuyo proyectil perdió el objetivo.
- El ajuste no cambia el cooldown normal cuando el objetivo sobrevive hasta el impacto.
- El 33 % se calcula sobre la recarga completa del disparo, no sobre una cifra global compartida.
- Los casos de disparo, muerte por otra torre y muerte por el propio impacto deben verificarse en Godot antes de dar por validada la implementación.

### Referencias

- [Diseño de combate](PROJECT_SPEC.md#combat)
- [Catálogo de contenido](CONTENT_AND_ASSETS.md#content-roster)
- [Ballista — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Ballista) (referencia de cadencia base; esta regla es propia del proyecto).

<a id='adr-0035'></a>
## ADR-0035 — Parámetros del roster de Rogue Tower

- Fecha: 2026-10-09.
- Estado: ampliado y parcialmente sustituido por ADR-0037, que fija la campaña de 45 rondas, las habilidades y la selección de fichas individuales.
- Alcance histórico: primera promoción de perfiles normales hasta ronda 20.
- Fuentes base: [Monsters — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Monsters), tabla general e individual; Fandom comunitario consultado el 2026-10-09, edición/changelog no indicado.

### Contexto

El usuario pidió adoptar parámetros de referencia para los enemigos y la velocidad requería conversión al movimiento propio. La decisión inicial se limitó a los perfiles que aparecían antes de ronda 20; después, el prompt de 45 rondas seleccionó 26 perfiles y algunas páginas individuales.

### Decisiones vigentes que conserva esta ADR

1. La velocidad RT se convierte con velocidad RT × 45 = px/s, factor que conserva Goblin en 90 px/s.
2. Las tasas globales health_growth_per_round, base_damage_growth_per_round y reward_growth_per_round son cero. No se añade escalado por ronda a los perfiles adoptados.
3. Ooogie clásico usa 100.000 de daño a base como representación técnica de “mata la base de un golpe”; ese valor no es una cifra publicada.
4. Vampire adopta la ficha individual seleccionada en el prompt: 5.000 Health, sin Armor/Shield, +100 Health/s, velocidad 1,75 RT y 23 Gold. La tabla general Monsters difiere.
5. Los perfiles y habilidades actualmente promovidos se leen en CONTENT_AND_ASSETS.md#content-roster. La tabla de composición/orden/cantidad es CONTENT_AND_ASSETS.md#campaign, no la wiki ni este ADR.

### Decisiones sustituidas

- El roster de enemigos se amplía a 26 tipos y 45 rondas según ADR-0037.
- Cyclops y Werewolf no tienen asignaciones especiales de Miniboss en 17/19.
- Ooogie von Ooogovich conserva la identidad y el kit propio aprobados en ADR-0032; la tabla decide sus rondas.
- Las cantidades/grupos que antes estaban pendientes se copian de la tabla seleccionada por el usuario. No se atribuyen como conteos de la página general Monsters.
- La wiki aporta parámetros individuales seleccionados; cuando las fichas difieren, prevalece la elección registrada en el catálogo/ADR-0037.

### Consecuencias

Los perfiles ejecutables están en data/enemies/. Los cambios de velocidad, estadísticas elegidas, habilidades, overrides, sprites y discrepancias entre fichas quedan descritos por perfil en [13 — Catálogo y escalado](CONTENT_AND_ASSETS.md#content-roster). La nomenclatura canónica está en [CONTENT_AND_ASSETS.md#canonical-names](CONTENT_AND_ASSETS.md#canonical-names).

### Fuentes

- [Monsters — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Monsters), Fandom comunitario, consultada el 2026-10-09; edición/changelog no indicado.
- Solicitud y prompt de 45 rondas proporcionados por el usuario, consultados el 2026-10-09.
- [Parámetros activos del roster](CONTENT_AND_ASSETS.md#content-roster) y [composición exacta](CONTENT_AND_ASSETS.md#campaign).

<a id='adr-0036'></a>
## ADR-0036 — Parámetros de torres según changelog oficial

- **Fecha:** 2026-10-09
- **Estado:** Implementado históricamente; Frost Keep fue ajustado por ADR-0037 y recupera daño 6/cadencia 180 RPM por ADR-0059. Tesla Coil conserva el override provisional de ADR-0037.
- **Alcance:** stats base de las torres de la demo donde la wiki comunitaria contradice las notas oficiales.
- **Fuentes:** [anuncios y changelogs oficiales de Rogue Tower en Steam](https://steamcommunity.com/app/1843760/announcements/) y fichas de [Tesla Coil](https://rogue-tower.fandom.com/wiki/Tesla_Coil), [Flame Thrower](https://rogue-tower.fandom.com/wiki/Flame_Thrower) y [Frost Keep](https://rogue-tower.fandom.com/wiki/Frost_Keep), consultados el 2026-10-09.

### Contexto

El usuario pidió respetar los parámetros de Rogue Tower. La ficha comunitaria actual de Flame Thrower conserva daño base 5, pero el parche oficial 1.1.2.0 aumentó ese daño a 6. Las notas oficiales también subieron el alcance de Tesla Coil de 1,5 a 2 y su multiplicador Shield de 9 a 10. La ficha comunitaria de Tesla ya refleja los últimos valores; la tabla general de Towers puede conservar datos antiguos.

### Decisiones

1. Ante una cifra contradictoria, la nota oficial de balance prevalece sobre la wiki comunitaria.
2. `Tesla Coil` usa `range_hexes = 2.0`. Su daño base 10, multiplicadores 6/3/10 y 30 RPM ya estaban correctos.
3. `Flame Thrower` usa daño base 6. Sus multiplicadores 6/9/3, alcance 4 y 60 RPM ya estaban correctos.
4. `Frost Keep` conserva daño base 6: el mismo parche oficial lo había subido de 5 a 6 y el perfil ya estaba actualizado.
5. Las demás cifras de torre no cambian por esta decisión.

### Consecuencias

- `data/towers/tesla_coil.tres` y `data/towers/flame_thrower.tres` reflejan las notas oficiales.
- El roster legible y los placeholders de contenido muestran los mismos valores que los Resources.
- El resto de la información comunitaria sigue identificada como referencia; las cifras sin changelog encontrado no se califican como verificadas oficialmente.

### Fuentes

- Steam, [Rogue Tower — announcements](https://steamcommunity.com/app/1843760/announcements/), parche 1.1.2.0 (2022-09-08): Tesla Coil alcance 1,5→2 y Shield 9→10; Flame Thrower daño 5→6; Frost Tower daño 5→6.
- Rogue Tower Wiki, fichas individuales enlazadas arriba; edición comunitaria consultada el 2026-10-09.
- [Catálogo activo](CONTENT_AND_ASSETS.md#content-roster) y [resources de torres](../../data/towers/).

<a id='adr-0037'></a>
## ADR-0037 — Campaña de 45 rondas, roster y habilidades enemigas

- Fecha: 2026-10-09
- Estado: Aceptado por elección explícita del usuario; implementación integrada, aceptación de gameplay pendiente. El balance y comportamiento de Frost Keep de la decisión 10 fueron sustituidos por ADR-0059.
- Sustituye parcialmente: ADR-0016, ADR-0018, ADR-0032, ADR-0033, ADR-0035 y ADR-0036. ADR-0059 sustituye únicamente la decisión de Frost Keep.
- Fuente de autoridad: el prompt adjunto del hito, las aclaraciones directas del usuario y los Resources activos. La wiki es referencia de parámetros individuales, no reemplaza las decisiones propias.

### Contexto

La especificación vigente tenía 20 rondas y designaba Cyclops y Werewolf como Minibosses en las rondas 17 y 19. El nuevo prompt entregó una tabla de 45 rondas, 26 tipos y 1.093 enemigos directos. La tabla no contiene Cyclops en la 17 ni Werewolf en la 19, y el usuario indicó que prevaleciera la tabla exacta. El calendario anterior no puede convivir como segunda autoridad.

El proyecto ya separaba los recursos de oleada, pero contaba pulsos replicados por endpoint. Con varias rutas, el total real cambiaba según el mapa; eso contradice la cantidad fija de la tabla.

La implementación previa tampoco modelaba muchas habilidades ligadas por el usuario a páginas individuales de Monsters. El Frost Keep era dominante y Tesla Coil debía recibir un recorte menor.

### Decisiones

1. La campaña contiene exactamente 45 recursos de oleada. La tabla de [14 — Campaña de 45 rondas](CONTENT_AND_ASSETS.md#campaign) es la autoridad de orden y composición. Hay exactamente 1.093 enemigos directos; invocaciones de habilidades y fases transformadas son adicionales y no se incluyen en esa cifra.
2. WaveEnemyGroupData.count significa cantidad directa de ese tipo. WaveDirector genera uno por vez y rota entre rutas alcanzables. Cambiar cuántos endpoints están abiertos no cambia la cantidad total.
3. Las rondas 17 y 19 son encuentros `Boss` porque la tabla incluye Ooogie, cuyo perfil tiene `boss_tier = 1`. Cyclops y Werewolf siguen como unidades RT normales en las rondas donde aparecen; se retiran sus antiguas designaciones propias de Miniboss en 17/19.
4. Los 26 perfiles adoptan el nombre, las estadísticas individuales y las habilidades del roster indicado en el prompt cuando esas páginas dan el dato. La velocidad RT se convierte con el factor ya usado de 45 px/s. No se añade crecimiento por ronda. Datos de la wiki comunitaria quedan configurables y su versión/changelog oficial no se conoce; no se presentan como balance oficial actualizado.
5. Vampire adopta la ficha individual (5.000 Health, sin Armor/Shield, +100 Health/s, 1,75 velocidad, 23 Gold) aunque la tabla general Monsters consultada muestra otro bloque de HP. La ficha individual es la fuente elegida por el usuario para esa discrepancia.
6. Haste acumula hasta 60 y se degrada a 6 por segundo; mientras está activo aumenta la velocidad de movimiento en tantos puntos porcentuales como su fuerza. Fortification acumula hasta 60 y decae a 6 por segundo; mientras está activo resta 5 al daño base de cada ataque. Se usan 5 hex desde la base para triggers de cercanía y radio 2 alrededor del emisor para auras, según decisiones explícitas del usuario.
7. El jefe de balance propio es Ooogie von Ooogovich (Haunted). Invoca dos Bats cada 2 s y al morir se transforma en Bat con 2.500 Health. La transformación conserva una sola instancia activa y el pago por baja original; la oleada y su recompensa esperan la derrota de Bat. Health 8.000, Armor 1.500, Shield 2.000, regen 25 Health/s y 10 Shield/s, velocidad 26 px/s, daño a base 50 y 200 Gold son valores propios **provisionales**.
8. Se implementan las habilidades de invocación, transformación, teletransporte, Haste y Fortification declaradas por el roster. El árbol de Ooogiehedron crea Dodecahedron con 30.000 Shield, Octahedron con 20.000 Armor, Hexahedron con 10.000 Health y Tetrahedron con 10.000 Health; las variantes usan velocidad 1,3 RT. Las apariciones adicionales cuentan para la vida de la oleada.
9. Se conservan las recompensas de limpieza de rondas 1–20 de sus Resources antiguos. De la 21 a la 45 se asigna provisionalmente 100 + 5 × (ronda − 20), es decir, 105–225 Gold. Los intervalos 1–20 reutilizan el intervalo del primer grupo antiguo de cada ronda; las antiguas pausas de Miniboss en 17/19 se quitan. Las rondas 21–45 usan 0,5 s provisional. Grupos y tipos aparecen secuencialmente en el orden de la tabla.
10. **Decisión histórica, sustituida en Frost Keep por ADR-0059:** Frost Keep quedó inicialmente en daño base 2, 120 RPM y Slow ×0,85 durante 1 s. Tesla Coil baja de daño base 10 a 9; ese ajuste continúa vigente y provisional.
11. Todo enemigo con sprite mira inicialmente hacia la derecha; el renderizado refleja el sprite horizontalmente al navegar hacia la izquierda y restaura su orientación al dirigirse hacia la derecha. Los 12 PNG nuevos se generan como arte original transparente de 256×256; no se importan assets de terceros.
12. Todo contenido que no se promovió queda en [Backlog de candidatos](BACKLOG.md#candidates). La tabla de composición no se duplica en otros documentos: deben enlazar a la campaña para conservar una autoridad.

### Consecuencias

- La dificultad total incluye enemigos directos y adicionales generados por habilidades. No debe confundirse el 1.093 de la tabla con el total final de apariciones.
- Las recompensas de baja son por instancia derrotada; un enemigo que transforma paga al final, mientras que sus invocaciones pueden pagar sus propias bajas.
- El escalado de Health, daño a base y Gold por baja permanece a 0. Las recompensas por limpiar 21–45 son provisionales y pueden cambiar.
- Frost Keep conserva su carta Blizzard y sinergia de Path. La integración inicial de este ADR redujo su daño; ADR-0059 restablece el perfil de referencia y sustituye el antiguo impacto de área garantizado por copos individuales que pueden fallar. Tesla Coil conserva el recorte de 10% de daño.
- Cada WaveData se valida en orden; WaveCampaignData comprueba 45 entradas, coincidencia entre tipo de encuentro y boss_tier y exactamente 1.093 enemigos directos.
- La progresión del terreno sigue entre las rondas 1–44; después de limpiar la 45, la run termina en victoria.
- Las decisiones históricas que mencionaban el calendario previo se conservan como antecedente y no describen ya el diseño activo.

### Fuentes

- Prompt de hito proporcionado por el usuario: prompt_codex_roguetower_45_oleadas.md, sección tabla de oleadas y páginas individuales, consultado el 2026-10-09.
- [Monsters — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Monsters), comunidad Fandom, consultada el 2026-10-09; sin edición oficial indicada.
- [Status Effects — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Status_Effects), comunidad Fandom, consultada el 2026-10-09.
- Aclaraciones explícitas del usuario: prioridad de la tabla exacta, nombre del jefe, invocación y transformación adaptadas, radios de 5/2 hex, y cierre de ronda tras la forma final.

<a id='adr-0038'></a>
## ADR-0038 — Sprite de base y feedback del HUD

- Fecha: 2026-10-09
- Estado: Aceptado por petición explícita del usuario; implementación integrada. El tamaño inicial de 112×112 fue ampliado por ADR-0039; la aceptación visual sigue pendiente.
- Ámbito: arte intercambiable de la base, lectura de recursos y botones de torre.
- Decisiones relacionadas: ADR-0026, ADR-0027, ADR-0031.

### Contexto

La base se dibujaba con polígonos dentro de `GameBase`, así que cambiar su aspecto exigía editar lógica. La vida de la base no indicaba bloques de 10, el HUD mostraba Mana fraccionario, y la barra de torres tenía un panel compartido detrás de todos los botones. Los cambios solicitados mantienen las reglas de combate y afectan la presentación, salvo el refill explícito de Mana al inicio de cada ronda.

### Decisiones

1. El aspecto de la base se carga desde `BaseData.sprite_texture` con un tamaño visual configurable. El PNG `assets/base/main_tower.png` es arte original generado para este proyecto; la huella lógica hexagonal permanece independiente y el recurso permite intercambiar la imagen sin modificar `GameBase`. El sprite se renovó el 2026-10-10 con una fortaleza de cómic 2D, contorno oscuro sencillo, colores planos y entrada visible en el frente orientado a la derecha. La propuesta alternativa está en `assets/base/proposals/adventure_comic/main_tower_alt.png`.
2. La barra de Health de base dibuja un segmento por cada 10 puntos, con el último segmento parcial cuando el máximo no es múltiplo de diez. El valor actual/máximo permanece centrado sobre la barra.
3. Al comenzar cada ronda de campaña, `RunEconomyService.refill_mana_to_max()` restaura Mana hasta su capacidad efectiva. La vista lo redondea a enteros, sin alterar precisión del saldo runtime.
4. Cada cambio no nulo de Gold anima el icono y la cifra mediante escalado y rebote vertical, tanto al ganar como al gastar.
5. Cada botón del roster tiene un marco PNG de estilo carta (`assets/ui/tower_card_button.png`). El control que alinea los botones es transparente y no dibuja un panel común.

### Consecuencias

- El sprite de la base se cambia en `data/base/base_data.tres` o en un `BaseData` alternativo; tamaño y huella no se infieren de la imagen.
- La presentación entera del Mana puede diferir del saldo fraccionario interno por redondeo; costes y regeneración continúan usando el valor preciso.
- La barra inferior ocupa el mismo espacio de HUD, pero ahora cada botón tiene contraste y estados propios a través de su textura de nueve cortes.
- La aceptación de legibilidad, rebote, segmentación y encaje en 1280×720/1440×900 sigue pendiente de revisión manual en Godot; ver M13 en `IMPLEMENTATION_AND_QA.md#acceptance`. ADR-0039 amplía el sprite configurable de la base y añade la presentación detallada de torres.

### Fuentes

- Petición directa del usuario en la sesión del 2026-10-09.
- `assets/base/main_tower.png` y `assets/ui/tower_card_button.png`, arte original generado para el proyecto el 2026-10-09; sprite de base actualizado el 2026-10-10 por petición directa del usuario.

<a id='adr-0039'></a>
## ADR-0039 — Panel lateral de torre y escala visual por objeto

- Fecha: 2026-10-09
- Estado: Aceptado; la regla de scroll se sustituyó por ADR-0040 y las escalas visuales por ADR-0041. La aceptación visual sigue pendiente.
- Ámbito: panel informativo/build de torres y tamaño mostrado de torres, enemigos y base.
- Decisiones relacionadas: ADR-0026, ADR-0031, ADR-0038.
- Sustituye parcialmente: ADR-0038 en el tamaño visual de la base.

### Contexto

El panel de torre mantenía una altura fija excesiva, no identificaba visualmente la torre al construir y repetía instrucciones que el preview ya comunica con color. Las capas de daño y los botones de mejora no eran suficientemente legibles. El usuario también pidió sprites mayores cerca del 15% por objeto, evitando una escala global.

### Decisiones

1. Decisión histórica, sustituida por ADR-0040: el panel lateral se coloca arriba a la derecha y ajusta su altura al contenido; no presenta scroll y reduce la escala vertical si falta espacio.
2. Al construir, el panel presenta un icono de torre grande, nombre, resumen de rol, precio, daño, alcance, cadencia, multiplicadores Health/Armor/Shield y consumo de Mana si existe. Muestra la diferencia real de elevación `Mountain vs Grass` tomada del `TowerData`; no muestra el texto genérico de elegir terreno. El preview conserva el feedback verde/rojo y los errores de colocación siguen informándose.
3. En el resumen seleccionado, Health se muestra en verde, Armor en ámbar y Shield en azul, con etiquetas en negrita. Los tres botones de mejora son cuadrados y muestran icono, coste y la ganancia de +1 daño base junto con +1 al multiplicador de la capa elegida. Demoler aparece en la fila inferior.
4. Decisión histórica, sustituida por ADR-0041: el tamaño visual se configura por Resource y objeto. Los perfiles originales subieron las torres a 62 px, los enemigos alrededor de 15 % y la base a 129×129; ADR-0041 fija los tamaños mayores vigentes.
5. El escalado solo afecta la presentación, las sombras y el espacio de sus barras/estados. Mantiene el tamaño lógico de la huella axial, la ocupación del tablero, los rangos, las colisiones lógicas y el movimiento.
6. Por petición directa del usuario, el 2026-10-10 se actualizaron los iconos activos de Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder en `game/ui/icons/`. Son sprites originales de fantasía cómica 2D, con siluetas legibles, trazos simples y colores planos. Las alternativas quedan en `game/ui/icons/proposals/adventure_comic/`; el sprite activo y el alternativo conservan el tamaño fuente de 256×256. No cambia ningún `TowerData`, estadística ni comportamiento.

### Consecuencias

- El panel puede ser más bajo cuando la torre está seleccionada y más alto en build mode por el retrato; a ventanas bajas recurre al scroll.
- Alturas, tamaños de sprite y perfiles siguen editables desde Resources individuales; no hay multiplicador global de escena.
- El preview y la torre construida comparten el sprite y tamaño configurado. Cambiar el PNG conserva el tamaño guardado en su Resource.
- La revisión de los nuevos iconos a su escala de juego sigue pendiente junto con la revisión visual indicada abajo.
- La revisión visual en Godot queda pendiente a 1280×720 y 1440×900, incluidos texto, foco/hover de botones, recorte de sprites y panel durante build mode.

### Fuentes

- Petición directa del usuario en la sesión del 2026-10-09.
- Petición directa del usuario en la sesión del 2026-10-10 para renovar los sprites de las siete torres con estilo de cómic sencillo.
- `TowerData`, `EnemyData`, `BaseData` y los PNG existentes del proyecto.

<a id='adr-0040'></a>
## ADR-0040 — terreno, obstáculos, cofres y feedback visual

- Fecha: 2026-10-09.
- Estado: aceptado e integrado. La tasa inicial de cofres y el número de niveles de mejora quedaron parcialmente sustituidos por ADR-0041; la aceptación visual en ventana sigue pendiente.
- Contexto: el tablero necesitaba más variación por celda, un punto de economía explorable y feedback visual inmediato para ataques e interacción. El usuario pidió que el panel de torre muestre toda su información sin scroll, ajustándose al alto de los datos.

### Decisiones

1. Path, Grass y Mountain tienen tres variantes visuales PNG coherentes. La ilustración se genera para el proyecto y se mantiene independiente de la lógica de celdas.
2. Una celda Grass genera un obstáculo con probabilidad 25 %; Mountain, 15 %. El tipo se selecciona uniformemente entre roca, esquirla, hierba alta, tótem y piedras. No aparecen props de obstáculo o cofre sobre Path.
3. Obstáculos bloquean construcción del mismo modo que una celda no construible; no son nodos del PathGraph y no alteran terreno, elevación o conectividad.
4. Una celda construible que no tenga obstáculo genera un cofre con probabilidad base 5 %. La permanente «Suerte del explorador» suma cinco puntos porcentuales por nivel, hasta 20 % con tres niveles. Esta tasa se conservó como regla inicial y quedó sustituida parcialmente por ADR-0041, que reduce el inicio a 1 % y amplía la mejora a cuatro niveles. El premio al abrirlo es Gold de la run. Se implementa inicialmente como 25 Gold por cofre; la cantidad es configurable y provisional porque el usuario no especificó un monto.
5. Cofre cerrado bloquea la construcción en su celda. Un clic lo abre, retira el cofre y paga una vez sin alterar ruta ni celda axial.
6. La asignación de variante/obstáculo/cofre se deriva de seed de run, coordenada axial y salts separados. Repetir la misma run con idénticas acciones reproduce las mismas asignaciones. La selección de variantes no debe cambiar el camino ni los stats.
7. Cada torre emite un VFX al impacto que le corresponde: Ballista `Dust_01`, Mortar `Explosion_01`, Tesla Coil `TeslaCoil`, Frost Keep `Ice_01`, Flame Thrower `Fire_03`, Poison Sprayer `Poison` y Shredder `Blood`.
8. El cursor usa `Cursor_01` en estado normal, `Cursor_02` al pasar por controles/objetos interactivos, `Cursor_03` en una acción deshabilitada o posición inválida y `Cursor_04` al colocar una torre.
9. El panel de información de torre nunca tiene scroll. Se ajusta al contenido visible y reduce su escala vertical para conservar todos los datos si no caben al alto natural del viewport. El scroll de otras interfaces, como la tienda, se mantiene independiente.
10. Los siete spritesheets VFX y cuatro cursores se cargan desde una dependencia local de Tiny Swords entregada por el usuario. El source PNG no se incorpora a Git: el creador permite uso personal/comercial pero no la redistribución o reempaquetado de los archivos fuente. `assets/third_party/tiny_swords/README.md` conserva las rutas de instalación y mapeo.

### Consecuencias

- `HexCell` almacena el tipo de obstáculo y la presencia de cofre; `TerrainVisualCatalog` asigna contenido determinista a tablero inicial, expansiones confirmadas y huecos rellenados.
- `BuildController` rechaza celdas con obstáculo/cofre cerrado; `Main` abre cofres con clic y actualiza el saldo de Gold.
- `MetaProgression` aplica la mejora permanente de cofres a las runs siguientes. La probabilidad se limita a 20 %.
- El terreno usa atlas PNG con tres filas de terreno y tres columnas de variantes; props y cofres se dibujan separados sobre la celda.
- La ejecución y registro de integración no sustituyen la aceptación visual/interactiva; el procedimiento queda en `IMPLEMENTATION_AND_QA.md#acceptance` y el estado en `IMPLEMENTATION_AND_QA.md#progress`.

### Referencias

- Petición del usuario en la tarea del 2026-10-09: probabilidades de obstáculos/cofres, mejora permanente hasta 20 %, contenido PNG, efectos Particle FX, cursores y panel de torre sin scroll.
- Pixel Frog, *Tiny Swords (Free Pack)*, <https://pixelfrog-assets.itch.io/tiny-swords>, consultado el 2026-10-09. Ver [Origen](CONTENT_AND_ASSETS.md#origin-and-sources) para atribución/licencia y límites de distribución.
- [ADR-0039: panel lateral de torre y escala visual por objeto](#adr-0039).

<a id='adr-0041'></a>
## ADR-0041 — Oclusión, arte de terreno y flujo de rutas

- Fecha: 2026-10-09.
- Estado: aceptado por petición explícita del usuario; código integrado, aceptación visual pendiente.
- Ámbito: orden de dibujo de props y unidades, alineación de atlas, presentación mundial y ruta visible.
- Sustituye parcialmente: ADR-0039 (tamaños de sprites) y ADR-0040 (probabilidad inicial y niveles de cofres).
- La decisión de conservar proporciones para los obstáculos en el punto 3 quedó sustituida por [ADR-0044](#adr-0044); el resto de tamaños de entidades y del cofre sigue vigente.

### Contexto

El usuario detectó que las caras de terreno aparecían desplazadas dentro de sus hexágonos y que las torres, los obstáculos, los enemigos y la base se ocultaban entre sí en un orden que no correspondía con su profundidad. También pidió props más legibles, sprites mayores y un indicador animado que recorra las ramas PATH hacia la base. El cofre inicial debe ser raro.

### Decisiones

1. `TerrainVisualCatalog` conserva el atlas, pero cada variante usa su rectángulo de arte visible medido dentro de la celda fuente. El renderer ajusta ese recorte al ancho y alto del hex pointy-top. Esto centra las variantes que tenían padding asimétrico y hace coincidir el borde dibujado con la cara lógica; el borde interactivo y el hover siguen usando los mismos vértices hexagonales.
2. Cada obstáculo/cofre se dibuja como nodo independiente bajo `Entities`, donde ya conviven la base, torres y enemigos con `y_sort_enabled`. Todos mantienen el mismo Z para que el Y-sort pueda compararlos. El renderer del tablero conserva suelo, cliffs y sockets; no dibuja props encima de toda la escena en un único CanvasItem. Los nodos ordenables conservan como posición la coordenada/elevación axial lógica; todo el arte de mundo comparte un desplazamiento visual constante de seis píxeles hacia abajo. Así el punto de ordenación permanece coherente sin cambiar posiciones de gameplay.
3. Las texturas de terreno, torres, enemigos, props, cofres y base usan `TEXTURE_FILTER_LINEAR`. El tamaño se configura por tipo/Resource, no por una escala global: torres 84 px, enemigos estándar 72 px (jefes escalados individualmente en `EnemyData`), base 176×176 px, obstáculos de hasta 92 px de alto con proporción original y cofre 84×84 px. La parte de obstáculos fue sustituida por ADR-0044. Los dibujos de torre/enemigo/base y props bajan 6 px. No se alteran huella lógica, colisiones, selección, movimiento, alcance ni rutas.
4. Las rutas alcanzables muestran una línea tenue con flechas/cheurones animados que avanzan desde cada spawn hacia la base. Se generan desde los segmentos ordenados de `PathGraph.routes`; los segmentos repetidos se dibujan una sola vez y las ramas/convergencias quedan visibles. Con colocación válida se dibuja el grafo candidato; al cancelar se restaura el grafo activo. La tecla `D` conserva el overlay estático de diagnóstico.
5. Se eligió dibujo de flechas por segmento desde `_draw` con actualización de 30 Hz frente a un shader continuo en `Line2D`. Godot ofrece shaders `CanvasItem` y `TIME` para animación, pero las rutas del juego tienen bifurcaciones, aristas compartidas y dirección desde spawn hacia base: dibujarlas desde la ruta real permite deduplicar cada arista y mantener la orientación correcta sin generar texturas/UVs de flujo por rama ni usar un shader de pantalla completa. El coste se limita a los segmentos del tablero y sus cheurones.
6. La generación de cofres baja a 1 % en celdas Grass/Mountain sin obstáculo. «Suerte del explorador» tiene cuatro niveles de +5 puntos porcentuales, con costes 10/20/35/55 y tope absoluto de 20 %. Las probabilidades efectivas son 1 %, 6 %, 11 %, 16 % y 20 %; el cuarto incremento queda limitado por el tope. El premio provisional de 25 Gold no cambia.

### Consecuencias y estado

- Props, actores y base se ordenan desde el anclaje lógico de su celda/movimiento dentro de la capa compartida. Como el offset de arte es uniforme, no cambia el orden relativo; las caras de terreno y las flechas permanecen debajo de ese grupo.
- El recorte fuente se conserva por variante para no deformar el arte ni desplazar una variante respecto a otra. Obstáculos y cofres preservan proporción y usan un anclaje inferior compartido.
- La escala es una propiedad por tipo/perfil. El cuerpo lógico y los rangos siguen usando los valores de gameplay; el aumento visual puede causar solapes estéticos que deben revisarse en juego a zoom normal y reducido.
- El cálculo reproducible por `(seed, coordenada, salt)` sigue igual; solo cambia la tasa de cofre, por lo que las casillas nuevas se determinan según el 1 % y la mejora meta activa.
- Falta revisar manualmente oclusión, bordes del atlas, legibilidad de flechas, solapes y escalas en la ventana del juego. `IMPLEMENTATION_AND_QA.md#acceptance` registra ese recorrido.

### Referencias

- Petición directa del usuario en la sesión del 2026-10-09 y la imagen adjunta de alineación de Mountain.
- Godot Engine, *CanvasItem*, documentación oficial estable, consultada el 2026-10-09: <https://docs.godotengine.org/en/stable/classes/class_canvasitem.html>. El Y-sort dibuja los CanvasItem con mayor Y delante y solo compara nodos con igual Z.
- Godot Engine, *Using TileMaps*, documentación oficial estable, consultada el 2026-10-09: <https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html>. Referencia de `Y Sort Origin` y organización por capas de terreno.
- Godot Engine, *CanvasItem shaders*, documentación oficial estable, consultada el 2026-10-09: <https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html>. Referencia de CanvasItem 2D y el builtin `TIME`, considerada al evaluar el flujo animado.
- [ADR-0039: escala visual por Resource](#adr-0039); [ADR-0040: contenido visual y cofres](#adr-0040).

<a id='adr-0042'></a>
## ADR-0042 — Orden por elevación y feedback del tablero

- Fecha: 2026-10-09.
- Estado: aceptado por petición explícita del usuario; código y contenido integrados, aceptación visual pendiente.
- Ámbito: profundidad de terreno elevado, grid/hover, spawns, flujo PATH, cursor, barra de torres y catálogo de piezas.
- Sustituye parcialmente: ADR-0041, en cuanto el Y-sort solo seguía la coordenada terrestre y a la representación estática de endpoints spawn. El punto 1 sobre ordenar fachadas/cliffs fue reemplazado por [ADR-0043](#adr-0043) tras la revisión visual del usuario.

### Contexto

La base y los enemigos parecían dibujarse por encima de hexágonos elevados. El jugador también pidió ocultar la grid hasta hacer hover, cambiar los carteles `SPAWN` por un portal animado, reducir y pulsar el cursor de construcción, mejorar la lectura de la barra de torres y añadir más diversidad a las piezas de siete hexes. La imagen adjunta mostraba el estilo de flechas móviles deseado.

### Decisiones

1. **Decisión sustituida parcialmente por ADR-0043:** esta revisión ordenaba el centro de cada tapa de terreno según su altura proyectada y añadía cada fachada como nodo individual dentro de `Entities.y_sort_enabled`, anclada al borde inferior. La observación visual mostró que esa pared aparecía encima de enemigos/base; el contrato actual para superficies y fachadas está en ADR-0043. Ninguna regla axial, de navegación o de gameplay cambia.
2. Los bordes de los hexes y las líneas/sockets PATH permanecen ocultos cuando no hay hover. Al seleccionar una celda se dibujan su borde y conexiones; los anillos vecinos axialmente a distancia 1 y 2 se atenúan progresivamente. El overlay de flechas de navegación sigue visible aun sin hover.
3. Los endpoints spawn usan la escena `SpawnPortal` y el asset intercambiable `assets/terrain/spawn_portal.png`. El sprite tiene alfa y anima escala/brillo con Tween; no se imprime texto ni cartel `SPAWN`. Los endpoints se crean/retiran desde el `PathGraph` alcanzable activo o candidato.
4. Las flechas mantienen dibujo 2D por arista a partir de `PathGraph`, con silueta llena y movimiento hacia la base. ADR-0054 sustituye la sombra de línea ancha; las flechas conservan relleno y contorno de contraste. La referencia *Moving Arrow on Tiles/Cells for Voxel Engines/Games* describe un shader espacial y UV para celdas de voxel; no se copia ese shader porque el juego no usa voxel/mesh y necesita deduplicar las ramas de su grafo axial. El dibujo por segmento preserva orientación, bifurcaciones y tramos compartidos, y permite actualizar el candidato mientras se coloca terreno.
5. Durante el modo de construcción el puntero nativo se oculta y una `TextureRect` de 32×32 sigue el ratón con una pulsación de escala pequeña. El mismo overlay presenta el cursor válido o el de error; al pasar a controles interactuables se restaura el cursor normal de la interfaz.
6. Los siete botones de torre aumentan a 144×148 px y reducen su separación a 2 px para conservar una fila compacta. Al construir una torre, su icono correspondiente vibra con una secuencia de rotación y escala. El feedback de Gold ya anima icono y cifra tanto al cobrar como al gastar y se conserva.
7. El catálogo asciende a quince piezas totales. Las cinco existentes siguen disponibles y se añaden `meadow_hills`, `mountain_massif`, `open_grassland`, `staggered_ridge`, `mountain_islet`, `twin_peaks`, `dead_end_spur`, `cliff_turn`, `meadow_switchback` y `three_way_ravine`. Cada pieza nueva contiene el centro y sus seis vecinos axiales. Seis amplían paisajes construibles; las otras cuatro introducen una rama sin salida más una continuación, una curva, un serpenteo y una bifurcación. Las conexiones internas se declaran recíprocamente. No se ajustan el balance ni las reglas de colocación.

### Consecuencias y estado

- Históricamente, este ADR permitió que las fachadas taparan entidades. Esa oclusión quedó sustituida por la tapa texturada descrita en ADR-0043; las fachadas siguen siendo representación y no crean celdas ni colisiones.
- Ocultar el contorno reduce ruido en el mapa. El hover revela localmente la geometría y el sentido de conexión sin quitar el flujo global de ruta.
- El portal queda en un PNG separado fácil de intercambiar. La animación se configura en su escena.
- Se prefiere el flujo basado en `PathGraph` sobre UV/shader espacial para que una ruta 2D con ramificaciones mantenga dirección y continuidad. Se mantiene el shader simple como posible opción futura si la representación cambia a una textura/mesh continua.
- Los diez `.tres` nuevos pasan por los mismos validadores que las piezas originales. La aceptación de rotación, conexión y legibilidad en ventana Godot queda pendiente.
- No se ejecutaron pruebas automatizadas en este hito. La revisión manual está definida en M18 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- Petición directa del usuario y la imagen adjunta de referencia en la sesión del 2026-10-09.
- Sentry456123, *Moving Arrow on Tiles/Cells for Voxel Engines/Games*, Godot Shaders, publicación del 2026-09-18; consultado el 2026-10-09: <https://godotshaders.com/shader/moving-arrow-on-tiles-cells-for-voxel-engines-games/>. Referencia visual para flechas animadas; su implementación usa UV/shader espacial para voxel cells.
- Godot Engine, *CanvasItem*, documentación oficial estable, consultada el 2026-10-09: <https://docs.godotengine.org/en/stable/classes/class_canvasitem.html>. Y-sort 2D y comparación de CanvasItem con mismo Z.
- [ADR-0041](#adr-0041) para el sistema de assets, escalado individual, filtros, cofres y líneas de ruta.

<a id='adr-0043'></a>
## ADR-0043 — Superficies de elevación, preview de spawns y obstáculos en cards

- Fecha: 2026-10-09.
- Estado: parte del render de elevación y preview sigue vigente; la política de obstáculos ilustrativos de las cards fue sustituida por ADR-0060. Aceptación visual pendiente.
- Ámbito: oclusión de terreno elevado y presentación de previews de expansión.
- Sustituye parcialmente: ADR-0042, punto 1 sobre fachadas/cliffs ordenados como oclusores.

### Contexto

La corrección de profundidad de M18 hacía que las fachadas posteriores del terreno elevado aparecieran delante de enemigos y base. Además, al elegir una pieza el jugador necesita ver los spawns previstos en su ubicación candidata, y las cards de terreno deben mostrar cómo se integran los obstáculos con sus losetas. La generación real de props sigue dependiendo del seed y de la coordenada final, que todavía no se conocen al mostrar la oferta.

### Decisiones

1. Las fachadas traseras (bordes axiales 4 y 5) no se dibujan. Las fachadas laterales y frontales visibles siguen formando parte del render de terreno situado bajo las entidades.
2. Cada celda elevada coloca una sola copia texturada de su superficie superior en `Entities.y_sort_enabled`, ordenada por el centro elevado. Esa tapa es la única geometría de terreno que puede cubrir una entidad situada detrás por profundidad; una entidad situada delante se dibuja encima. Las paredes no se añaden a Y-sort. El recurso de terreno original y la cara copiada comparten región de atlas y footprint para que no haya un parche de color plano.
3. Durante una colocación activa y válida, `TerrainPiecePreview` sustituye los portales por los endpoints alcanzables del `PathGraph` candidato y los mueve a su coordenada exterior prevista. El tinte verde identifica este preview válido. Si la colocación deja de ser válida, se cancela o termina, se muestran los portales del grafo activo tras el siguiente refresco.
4. **Decisión histórica sustituida por ADR-0060:** las cards dibujaban obstáculos representativos deterministas separados de la tirada real. La regla vigente fija obstáculos/cofres en una copia de la pieza para cada oferta; la miniatura, el ghost y el tablero confirmado usan el mismo contenido.

### Consecuencias y estado

- La tapa elevada puede ocultar entidades lejanas situadas detrás y deja visible el frente de unidades cercanas. El dibujo de fachadas ya no participa en Y-sort, por lo que no puede aparecer como un muro sobre la silueta de un enemigo.
- El jugador ve a qué posiciones exteriores se moverán los spawns antes de confirmar la ampliación y distingue ese estado con el tinte verde.
- La política histórica de props representativos ya no aplica. Consultar ADR-0060 para la correspondencia vigente de miniatura, ghost y tablero.
- No se ejecutó Godot ni se hizo inspección visual en esta revisión. Los casos de altura, preview/cancelación, solape de props sobre cards y reversión de portales quedan en la aceptación M18 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- Petición directa del usuario en la sesión del 2026-10-09.
- [ADR-0042: orden por elevación y feedback del tablero](#adr-0042).
- [Terreno hexagonal y elevación visual](PROJECT_SPEC.md#terrain).

<a id='adr-0044'></a>
## ADR-0044 — Caja estándar para los sprites de obstáculos

- Fecha: 2026-10-09.
- Estado: sustituido parcialmente por ADR-0046; la caja común sigue vigente, el tamaño 104×104 px ya no.
- Ámbito: tamaño de dibujo para roca, esquirla, hierba alta, tótem y piedras.
- Sustituye parcialmente: ADR-0041, punto 3, sobre conservar la proporción original de los obstáculos.

### Contexto

Los cinco obstáculos tenían formas fuente muy distintas y cada uno se ajustaba dentro de un máximo conservando su proporción. Eso producía tamaños aparentes diferentes y requería cálculos por asset. El usuario quiere que todos tengan una huella visual uniforme y acepta que el arte temporal se estire, ya que será reemplazado más adelante.

### Decisiones

1. Todos los obstáculos se dibujan en un rectángulo fijo de **104×104 px**. La textura fuente se estira para llenar la caja, aunque cambie su proporción.
2. `TerrainVisualCatalog.OBSTACLE_DISPLAY_SIZE` es la única constante para este tamaño. La usa tanto el tablero como `TerrainPieceCardPreview`, y así los nuevos tipos del pool quedan estandarizados al añadirse.
3. La caja coincide con la altura de un hexágono pointy-top de radio 52 px. El punto inferior de la imagen conserva el offset artístico de seis píxeles hacia abajo. Esto solo modifica dibujo; no cambia footprint, ocupación, validación, selección ni colisiones.
4. Los cofres conservan su tamaño separado de 84×84 px y no forman parte del pool de obstáculos.

### Consecuencias y estado

- Los cinco obstáculos comparten exactamente el mismo rectángulo de destino y el mismo tamaño en cards y mapa.
- Las siluetas temporales pueden verse comprimidas o ensanchadas. Esa distorsión es aceptada para simplificar extensión y será reemplazada con el arte final.
- La aceptación visual pendiente debe confirmar que el rectángulo común se lee bien sobre Grass/Mountain y no oculta elementos importantes del hex vecino.

### Referencias

- Petición directa del usuario en la sesión del 2026-10-09.
- [Modelo de datos de terreno](PROJECT_SPEC.md#data-models).
- [Terreno hexagonal y elevación visual](PROJECT_SPEC.md#terrain).

<a id='adr-0045'></a>
## ADR-0045 — auditoría de torres, feedback de selección y texturas runtime

- **Fecha:** 2026-10-09
- **Estado:** cambios implementados; aceptación visual/manual pendiente. La decisión 2 de patrón Frost fue sustituida parcialmente por ADR-0059.
- **Decide:** solicita el usuario; se mantienen los valores de combate existentes salvo alinear metadata y UI con el runtime

### Contexto

El usuario pidió una revisión profunda de torres basada en la página Towers de Rogue Tower y mejoras visuales de selección, hover, flujo de Path, Gold, cofres y portales. También pidió ajustar cuatro PNG grandes y separar los atlas de terreno y obstáculos en objetos individuales.

La inspección confirmó que las mejoras de torre efectivas están codificadas como +1 de daño base y +1 al multiplicador H/A/S seleccionado; la elevación suma daño y rango; el XP usa tiempo con un objetivo en rango; el coste de Mana se cobra al intentar cada disparo; y los críticos ejecutan tiradas condicionales por banda. También encontró que Frost Keep usa una caja alineada a pantalla pero el Resource declaraba un radio de área de 1,2 hex, y la UI mostraba ese radio que no se ejecutaba.

### Decisiones

1. Registrar fórmulas, configuración cargada, diferencias con la wiki y preguntas de balance en [15 — Auditoría del sistema de torres](CONTENT_AND_ASSETS.md#tower-audit). La página describe el runtime y no aprueba por sí sola mecánicas externas.
2. **Decisión histórica, sustituida parcialmente por ADR-0059:** Frost Keep se configuró como `ALL_IN_RANGE` dentro de un cuadrado. Se conserva el alcance cuadrado; el patrón garantizado sobre todos los enemigos se reemplaza por caída de copos e impactos individuales.
3. Dejar `max_targets = 1` en Tesla Coil porque `ALL_IN_RANGE` alcanza a todos y ese campo no limita su ataque. `max_targets` sigue activo para `CHAIN`.
4. Al seleccionar una torre, hacer que su panel pulse, que su icono y radio tengan pulso y que el PNG reciba resplandor siguiendo su alfa. Elevar el `z_index` de la torre seleccionada para que su sprite no quede tapado por tapas elevadas.
5. Dibujar el contorno y los sockets de hover en un overlay independiente situado en la elevación lógica de cada celda, sobre las superficies Y-sorted. Las vecinas se desvanecen hasta dos anillos.
6. Hacer las flechas PATH más lentas, menos densas y tenues; ejecutar el pulso de portales con fase propia por instancia; pulsar el cofre al aparecer; exagerar el rebote de icono y cifra de Gold ganado y mantener una respuesta más discreta al gasto.
7. Mantener las texturas de los atlas originales como fuentes, pero separar el runtime en nueve PNG de tiles (180×208) y cinco PNG de obstáculos (208×208). Los cuatro PNG listados se reducen a dos píxeles de fuente por píxel de dibujo lógico: `main_tower` 352×352, `spawn_portal` 224×336, `treasure_chest` 168×168 y `tower_card_button` 288×296. Los destinos en pantalla no cambian.
8. Conectar el modificador de cadencia soportado por `RunCardService` a `Tower`; el pool actual no contiene una operación de ese tipo, así que no cambia el balance vigente.

### Consecuencias

- La cuadrícula y los sockets de hover no dependen del orden de las tapas por Y y se calculan con la elevación de la celda.
- Las texturas de terreno/props se pueden cambiar una por una sin editar un atlas runtime. Las cinco props mantienen una caja estirada idéntica.
- Los cuatro PNG revisados pasan de 6.805.626 a 433.294 bytes (−93,6 % combinado), conservando el destino lógico y dos píxeles fuente por píxel dibujado; sus dimensiones y pesos están en `assets/CONTENT_AND_ASSETS.md#sprite-catalog`.
- Varias propiedades antiguas de `TowerData` son declarativas o históricas y no alteran los upgrades efectivos; el modelo de datos lo documenta.
- No se rebalancean daño, niveles, XP, coste ni XP de cartas. Las diferencias propias y decisiones pendientes se listan en la auditoría.
- No se ejecutó Godot ni se confirmó la percepción visual en una ventana; los criterios manuales de M19 deben pasar antes de marcar aceptación.

### Fuentes

- [Rogue Tower Wiki — Towers](https://rogue-tower.fandom.com/wiki/Towers), consultada 2026-10-09; referencia comunitaria indexada, revisión exacta no identificada.
- [Anuncios oficiales de Rogue Tower en Steam](https://steamcommunity.com/app/1843760/announcements/), incluidos Patch Notes 1.1.2.0 (2022-09-08).
- Código y Resources del proyecto inspeccionados 2026-10-09.

### Sustituye

Completa ADR-0041–0044 en feedback, assets compactos, división de atlas y render de selección/hover; no cambia el alcance de elevación de ADR-0043 ni la caja de props de ADR-0044.

<a id='adr-0046'></a>
## ADR-0046 — Progresión independiente de mejoras y feedback de selección

- **Fecha:** 2026-10-09
- **Estado:** código y documentación integrados; aceptación visual/manual pendiente
- **Decide:** petición explícita del usuario
- **Sustituye parcialmente:** el máximo de mejoras compartido y la presentación anterior de ADR-0023/0039/0045; la caja de obstáculos de ADR-0044 pasa de 104×104 a 86×86 px

### Contexto

La torre mantenía un único nivel compartido para Health, Armor y Shield y la interfaz daba a entender que subir una estadística elevaba las otras. Además, la colocación podía quedar detrás del terreno, el feedback de ubicación inválida usaba verde y las prioridades estaban agrupadas en un único control. La base también tenía elevaciones junto a su huella, lo que podía tapar su sprite.

El usuario pidió que cada capa de mejora progrese de manera independiente hasta 15 niveles (45 subidas posibles), que cada capa enseñe su XP y que el jugador pueda elegir tres prioridades en orden. También solicitó feedback visual inequívoco para torre seleccionada/preview inválido y una corona de seis celdas planas alrededor de la base.

### Decisiones

1. Health, Armor y Shield mantienen contadores de mejora independientes, cada uno de 0 a 15. El máximo total por torre es 45. Una mejora manual o automática incrementa únicamente la capa elegida/activa; las otras dos conservan nivel y XP.
2. Cada mejora válida añade **+1 daño base** y **+1 al multiplicador** de la capa que sube. Las mejoras no aumentan rango ni RPM. El total de daño base conserva un contador agregado separado de los niveles H/A/S.
3. El coste Gold de la capa `L` es `round(base_cost[L] × cost_factor^level[L])`. Los valores iniciales son Ballista/Mortar 10 Gold, Tesla Coil/Frost Keep 20 y Flame Thrower/Poison Sprayer/Shredder 30; los factores parten de 1,15 y son configurables por `TowerData`.
4. La XP por segundo mientras la torre mantiene un objetivo válido en alcance es `0,5 + 1 / (2 × alcance_en_hexes)`. Se asigna a la capa activa del enemigo. El requisito de la capa `L` es `base_xp × xp_factor^level[L]`; el valor base es 100 XP y el factor inicial 1,15. XP base, factores y costes son parámetros provisionales configurables, no una afirmación de paridad de balance con Rogue Tower. Cada botón H/A/S muestra nivel, barra de progreso teñida por capa, XP y coste.
5. La UI conserva tres opciones de prioridad numeradas. No repite criterios. Si el criterio repetido desplaza una opción ya elegida, intercambia las dos; si intenta duplicar un criterio en una opción vacía, revierte la selección para no dejar vacía la prioridad existente. La primera prioridad no se puede vaciar. La regla de desempate propia continúa siendo lexicográfica.
6. Durante build mode, un nodo de preview con `z_index` superior a los elementos del tablero dibuja torre, rango y contorno sobre terreno, props y entidades incluso cuando la ubicación no es legal. La colocación legal es verde y la no disponible es roja. El botón inferior del tipo seleccionado pulsa tanto durante la construcción como al seleccionar una torre colocada de ese tipo.
7. Los cinco obstáculos usan una caja de dibujo común de 86×86 px en el tablero y las cards; se centran con el offset artístico compartido de 6 px hacia abajo. La textura se estira. Esto reemplaza la caja de 104×104 px de ADR-0044 sin cambiar ocupación ni colisiones.
8. Las seis celdas axiales inmediatamente adyacentes a Main Tower quedan en elevación 0. PATH y Grass respetan esa altura; las dos antiguas celdas Mountain del anillo pasan a Grass para conservar la regla del proyecto de que Mountain tiene elevación 2. `StartingBoardData` valida la corona plana.

### Consecuencias

- La UI y `TowerData` comunican la progresión que realmente ejecuta `Tower`; se retiraron los campos de Resource de upgrades antiguos que ya no tenían efecto.
- 15 subidas por capa permiten 45 mejoras por torre. La subida por XP y la compra Gold tienen techos independientes por capa, pero ambas afectan el mismo contador de mejora de esa capa.
- Costes y XP crecen de forma exponencial para que el nivel 15 requiera progresión creciente. El factor 1,15 es una elección de balance provisional y debe ajustarse mediante pruebas de campaña.
- La caja visual uniforme nueva ocupa menos área; la aceptación visual debe comprobar que los obstáculos siguen destacando y se ven centrados.
- No se ejecutó Godot ni la comprobación en ventana durante esta revisión. El procedimiento está en M20 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Fuentes

- Petición directa del usuario en la sesión del 2026-10-09.
- [Rogue Tower Wiki — Towers](https://rogue-tower.fandom.com/wiki/Towers), consultada el 2026-10-09; referencia comunitaria para comportamiento general y tasa de XP, no para los factores de balance propios.
- Código y Resources inspeccionados el 2026-10-09.

### Decisiones sustituidas

- ADR-0044 conserva el motivo de estandarizar sprites, pero su tamaño de 104×104 px queda sustituido por 86×86 px.
- ADR-0028/0039/0045 mantienen su alcance histórico de UX. Para progresión individual, selectores de prioridad, preview superior y estado actual del anillo base, manda este ADR y el diseño vigente.

<a id='adr-0047'></a>
## ADR-0047 — Herramientas de depuración y claridad de selección

- **Fecha:** 2026-10-10
- **Estado:** código y documentación integrados; aceptación visual/manual pendiente
- **Decide:** petición explícita del usuario
- **Actualiza:** presentación de targeting y selección documentada en ADR-0045/0046

### Contexto

Las pruebas repetidas requerían alterar Gold, Mana, Health y desbloqueos sin depender de progresar manualmente. La experiencia visual también conservaba pulso en el panel lateral, tres prioridades visibles todo el tiempo y círculos alrededor de una torre seleccionada. El feedback de Gold existente cambiaba la posición de controles que viven dentro de un contenedor, lo que hacía que el rebote de la cifra no se percibiera con fiabilidad. Los obstáculos usan PNG con transparencia y necesitan un hover que siga el contorno del arte.

### Decisiones

1. `Ctrl+K` abre un menú de depuración temporal con `+1000 Gold`, `+100 Mana`, restaurar Mana, curar la base, activar/desactivar todos los desbloqueos, iniciar la ronda seleccionada y reiniciar la run.
2. El override de desbloqueos se mantiene en memoria. Hace visibles todas las torres configuradas y permite cartas cuyo requisito sea un unlock; no escribe `SaveData`. Se reinicia al crear otra run. Los límites por run y las cartas con peso cero continúan vigentes.
3. «Empezar una run desde cero» recarga `Main`: restablece tablero, ronda, economía y cartas de la run y genera una nueva seed; conserva la meta-progresión permanente.
4. El panel de información de torre no pulsa. Mantiene alto natural y escala verticalmente desde su borde superior si el viewport no tiene espacio para mostrarlo entero. El pulso de la card inferior seleccionada continúa.
5. La prioridad 1 aparece sola. Un botón `+` revela prioridad 2 y luego prioridad 3, sin alterar la regla de desempate o unicidad. Al cambiar de torre, la UI muestra solo hasta la prioridad más alta configurada en esa torre.
6. La selección de una torre conserva el brillo recortado y el pulso de escala del sprite, pero no dibuja anillos circulares de alcance o contorno. El radio y contorno de hover siguen disponibles sobre una torre no seleccionada.
7. El hover de obstacle dibuja una copia del PNG mediante shader CanvasItem que expande su alfa. La aureola sigue la silueta transparente, no una forma geométrica.
8. Un cambio de Gold escala y hace rebotar el grupo de UI que contiene icono e importe. No se anima la posición de controles administrados por `HBoxContainer`.
9. La condición de spawn de terreno se mantiene como invariante: el grafo debe contener al menos una salida PATH externa, todas las salidas deben llegar a Main Tower y cumplir la longitud mínima. El tablero inicial se valida al arrancar; cada propuesta de terreno crea un grafo candidato, y el botón de confirmar exige que sea válido. No se aceptan piezas que dejen el tablero sin spawn alcanzable.

### Consecuencias

- Los hacks reducen el tiempo de preparación de pruebas sin contaminar moneda meta, desbloqueos o niveles permanentes.
- Reiniciar una run incrementa el contador persistente de runs iniciadas por el flujo normal de `MetaProgression.begin_run`; el resto del estado de run se inicializa nuevamente.
- Añadir prioridades ocupa altura solo cuando el jugador las solicita; el panel limita su extensión al viewport y no incorpora scroll.
- El shader requiere el mismo PNG usado por la decoración y añade un overlay solo al obstáculo bajo el cursor.
- La validación de rutas ya se aplicaba en `PathGraph` y `Main`; este ADR la hace explícita como garantía para la selección/confirmación de expansiones.

### Fuentes

- Petición directa del usuario en la sesión del 2026-10-10.
- `game/board/path_graph.gd`, `game/main/main.gd` y validación del tablero inspeccionados el 2026-10-10.

### Decisiones sustituidas

- ADR-0045 describía pulso del panel lateral y círculo de alcance al seleccionar; ambas presentaciones quedan reemplazadas por este ADR.
- ADR-0046 describía las tres prioridades como controles siempre visibles; ahora se despliegan bajo demanda. La lógica lexicográfica y las reglas de unicidad continúan vigentes.

<a id='adr-0048'></a>
## ADR-0048 — HUD, progreso de oleadas, cards de terreno y paredes texturizadas

- Fecha: 2026-10-10
- Estado: Aceptado; código y arte integrados, aceptación visual pendiente.
- Decisión relacionada: [ADR-0047](#adr-0047).

### Contexto

El HUD mantenía un fondo conjunto para la salud, Gold y Mana; `%GoldGroup` se intentaba resolver aunque el nodo no estaba marcado como nombre único en `main.tscn`, lo que dejaba nulo el grupo de animación. La línea de progreso anterior representaba las rondas con segmentos uniformes y no informaba la composición. Las ofertas de expansión tenían un contenedor con panel detrás y no resumían cuántos hexes había de cada terreno. Las fachadas elevadas se componían con dos triángulos vectoriales; algunas juntas podían quedar visibles y el material no diferenciaba Grass de Mountain. La primera versión texturizada cerró cada quad, pero estiraba el PNG entero sobre cada cara y dejaba pequeñas aperturas donde las extrusiones se encontraban en ángulo.

### Decisiones

1. Marcar `GoldGroup` como nombre único de escena, para que `%GoldGroup` y el rebote de Gold apunten al grupo que contiene icono y saldo.
2. Quitar el fondo compartido del HUD principal y del bloque de ronda. La salud queda arriba a la izquierda y los atajos debajo; Gold/Mana conservan su disposición y pasan arriba a la derecha. El panel de información de torre empieza debajo de los recursos para no cubrirlos.
3. El botón «Iniciar ronda» dibuja el PNG completo conservando su proporción 3:1. Su ancho sigue el texto visible con un mínimo cómodo; no corta el arte con márgenes 9-slice.
4. La tira de 45 rondas dibuja una línea con un punto por cada `WaveData`. El radio depende de la cantidad directa y añade énfasis si la ronda declara jefe o contiene `EnemyData.boss_tier`. Al hacer hover, el tooltip informa el total y agrega retratos/conteos por tipo de enemigo solo si su suma en esa ronda es mayor que uno.
5. Las tres cards de terreno conservan su preview como contenido, pero el panel compartido queda transparente; cada botón muestra su propio marco PNG. La oferta usa cards de al menos 320×420 px y previews de 264×340 px recortadas dentro de su área, para mantener el terreno dentro del marco. El estado reducido de colocación usa cards de 184×126 px y previews de 132×54 px. Su etiqueta inferior cuenta Path, Grass y Mountain en ese orden y omite los tipos con cero celdas.
6. Las fachadas de elevación se dibujan como un quad texturizado por cada borde visible y usan `mountain_cliff_face.png` o `grass_cliff_face.png`. Los UV muestrean regiones del PNG proporcionales al ancho y la altura del desnivel con una densidad estable; los vértices compartidos reciben cuñas de unión para cerrar las esquinas. La fachada continúa debajo de unidades/props y no cambia el hex lógico, su elevación, el Y-sort ni la oclusión de la cara superior. Los triángulos vectoriales ya no definen el material visible.
7. Los cuatro PNG nuevos se generaron para este proyecto el 2026-10-10 con el generador de imágenes integrado: marco de card, marco horizontal de botón, roca facetada y suelo con césped. No proceden de un pack externo.

### Consecuencias

- Las oleadas se leen de forma comparativa; su tooltip usa datos runtime cargados y suma grupos repetidos por ID de enemigo.
- Un tipo que aparece una sola vez queda fuera de la lista de retratos, aunque sí cuenta en el total de la ronda.
- La imagen del botón de ronda conserva su proporción al adaptarse a la longitud de su texto, y la preview de cada pieza queda contenida dentro de su card tanto en la oferta como durante la colocación.
- El marco de expansión puede cambiarse en `assets/ui/terrain_expansion_card_frame.png`; el botón, en `assets/ui/start_round_button.png`.
- Los materiales de fachada pueden sustituirse en `assets/terrain/tiles/` sin alterar la geometría lógica ni el cálculo de altura.
- El mapeo de UV y las uniones de vértice mantienen las fachadas de elevación 1 y 2 sin estirar el sprite ni dejar huecos angulares.
- El cambio de layout y la legibilidad de los recursos junto al panel lateral requieren revisión manual a 1280×720 y 1440×900.

### Verificación pendiente

- Ejecutar la escena y confirmar que GoldGroup se enlaza, anima al ganar/gastar y no emite el error de nodo nulo.
- Inspeccionar el HUD sin paneles de fondo, y verificar el espacio superior derecho con el panel de torre seleccionado.
- Pasar el cursor por rondas estándar, con varios tipos, y con encuentros especiales; confirmar tamaño relativo de puntos, total, retratos y omisión de tipos con conteo 1.
- Comprobar las tres cuentas de terreno, la ausencia del panel compartido y que las previews ocupen el marco sin salirse, tanto en oferta como en el estado reducido de colocación. Verificar además que el botón de ronda conserva su arte y muestra completo cada texto dinámico.
- Inspeccionar fachadas Grass/Mountain en elevaciones 1 y 2, comparar la escala de textura entre alturas, revisar los encuentros angulares y confirmar cierres y oclusión de entidades.

<a id='adr-0049'></a>
## ADR-0049 — Arquitectura híbrida y editable para la UI

- Fecha: 2026-10-10
- Estado: implementación integrada; aceptación visual e interactiva pendiente.
- Ámbito: presentación UI existente de `Main`, ofertas de mejora, tienda terminal y menú de hacks.
- Sustituye: la construcción programática de jerarquías visuales de estos componentes. No sustituye ADR-0026 ni decisiones de layout/arte posteriores.

### Contexto y auditoría

El proyecto ya tenía la mayor parte del HUD y del panel de selección colocados en `game/main/main.tscn`, con `main.gd` como coordinador de partida y presentación. Sin embargo, algunas interfaces carecían de escena propia: `MetaShopPanel` y `DebugHacksPanel` construían sus árboles completos desde GDScript; las tarjetas de oferta y las filas/controles repetidos dependían del árbol de `Main`; y el tooltip de ronda creaba filas visuales al vuelo. Un helper aplicaba estilos parecidos, pero no había un recurso `Theme` compartido.

El inventario de pantallas y responsabilidades encontrado fue:

| Interfaz | Escena y controlador | Datos, contratos e interacción | Riesgo y tratamiento |
|---|---|---|---|
| HUD de partida y paneles de construcción/selección | `game/main/main.tscn`, coordinado por `game/main/main.gd` | Servicios de run, selección, terreno, recursos, torre y estado de campaña; los atajos existentes y las señales de sistemas se mantienen en `Main`. | Alto por su acoplamiento con partida. Se conserva la escena raíz y el coordinador; solo se convierten controles repetidos y el panel de cartas en escenas. |
| Progreso de ronda y tooltip | `game/ui/round_progress_strip.gd` y sus nuevas escenas de tooltip/fila | Recibe `WaveData`; presenta el dibujo procedural de los 45 puntos y agrupaciones derivadas de `EnemyData`. | Medio. El dibujo y sus datos no cambian; la estructura del tooltip ahora es una escena y las filas se instancian desde una escena reutilizable. |
| Oferta de mejoras de run | `UpgradeOfferPanel` y `UpgradeOfferCard`; `main.gd` sigue atendiendo la selección | `RunCardService` determina los datos/ofertas; se conservan cantidad configurable, orden y manejadores existentes. | Medio. Vista y cartas son `.tscn`; el controlador de partida sigue aplicando las reglas y la oferta dimensiona las instancias según `offer_size`. |
| Tienda terminal de meta-progresión | `game/progression/meta_shop_panel.tscn/.gd` y `meta_shop_row.tscn` | `MetaProgression`, perfiles de torre y upgrades; conserva pestañas, compras, moneda, `configure`, `present`, `is_open` y `new_run_requested`. | Alto por el guardado y flujo de nueva run. El script de presentación mantiene esos contratos y las filas visuales pasan a `PackedScene`. |
| Menú de hacks de depuración | `game/ui/debug_hacks_panel.tscn/.gd` | Conserva acciones `StringName` hacia `Main`, el atajo `Ctrl+K`, la capa y el cierre tras acciones no toggle. | Bajo/medio. Se añade escena editable; la ejecución de los hacks queda en `Main` como antes. |
| Controles repetidos del HUD | `TowerShortcutCard`, `TowerLayerUpgradeButton` | Los siete perfiles de `TowerData`, iconos existentes, economía y progresión de capas alimentan sus vistas; las señales y handlers de botones siguen conectados por `Main`. | Medio. La jerarquía es editable por escena, y el comportamiento/datos continúan en el coordinador existente. |

No se encontraron pantallas de título, ajustes o navegación independientes en el estado actual. El `Label.new()` en `game/enemies/enemy.gd` representa daño flotante ligado al mundo y la entidad; se conserva fuera de la migración de UI de presentación. `RoundProgressStrip` mantiene su dibujo procedural porque representa una secuencia de datos y no una jerarquía de controles. El HUD F3 y las cards de terreno ya existentes también permanecen en sus escenas actuales.

### Decisión

1. Las jerarquías visuales persistentes y repetibles se definen en escenas `.tscn` bajo las carpetas actuales `game/ui/components`, `game/ui/themes` y `game/progression`; no se mueven escenas de gameplay sin necesidad.
2. Los scripts de componentes muestran datos, actualizan controles e informan interacciones. `Main`, `RunCardService`, `MetaProgression` y los servicios existentes conservan selección, reglas, compras, guardado y efectos de gameplay.
3. Los elementos cuyo número depende de recursos/datos se instancian desde escenas reutilizables. La cantidad de cartas continúa derivando de `DEMO_CARD_POOL.offer_size`; filas de tienda y enemigos del tooltip continúan naciendo de sus listas/datos existentes.
4. `game/ui/themes/rogue_hud_theme.tres` centraliza estilos base compartidos y se asigna localmente a las raíces relevantes. No se asigna como Theme global del proyecto, por lo que no altera controles ajenos a estos paneles.
5. Los recursos y valores de muestra de las escenas hacen que sus árboles puedan previsualizarse en el editor. El código sustituye esos valores con los datos runtime; no son contenido de gameplay.
6. No se cambia el layout global, resolución, atajos, fases, persistencia, contenido, balance, contratos de señales ni lógica de combate. No se extrae `Main` como parte de esta migración para evitar mezclar el cambio visual con una refactorización de gameplay.

### Escenas añadidas o adaptadas

- `game/ui/themes/rogue_hud_theme.tres`
- `game/ui/components/tower_shortcut_card.tscn` y `.gd`
- `game/ui/components/tower_layer_upgrade_button.tscn` y `.gd`
- `game/ui/components/upgrade_offer_panel.tscn` y `.gd`
- `game/ui/components/upgrade_offer_card.tscn` y `.gd`
- `game/ui/components/wave_hover_tooltip.tscn` y `.gd`
- `game/ui/components/wave_enemy_row.tscn`
- `game/progression/meta_shop_panel.tscn`, `meta_shop_panel.gd` y `meta_shop_row.tscn`
- `game/ui/debug_hacks_panel.tscn` y `debug_hacks_panel.gd`

### Validación y consecuencias

`tests/ui_migration_smoke.tscn` corre en Godot 4.7 headless. Comprueba carga de `Main`, el contrato de acción del panel debug, configuración de tarjetas, variación del número de ofertas, filas de tienda, señal de nueva run y creación del tooltip de ronda. La ejecución del 2026-10-10 pasó. Godot mostró el aviso del almacén de certificados raíz del host, sin errores de scripts/escenas en el resultado del smoke.

La validación automatizada no compara píxeles ni recorre la partida con ratón/teclado. Por ello no demuestra equivalencia visual a 1280×720 y 1440×900 ni reemplaza la inspección manual de hover, foco, propagación, scroll, compras y transiciones. Esos criterios quedan pendientes en `IMPLEMENTATION_AND_QA.md#acceptance`.

Beneficio: distribución, tamaños, márgenes, estilos base, contenidos de muestra y jerarquía de componentes pueden modificarse en el editor visual. Consecuencia: la previsualización aislada de una escena no refleja sus texturas y datos reales hasta configurarla desde el juego.

### Referencias

- [ADR-0026: jerarquía UX/UI](#adr-0026)
- [ADR-0048: HUD, oleadas, cards y fachadas](#adr-0048)
- [Arquitectura técnica](PROJECT_SPEC.md#architecture)
- [Pruebas de aceptación](IMPLEMENTATION_AND_QA.md#acceptance)

<a id='adr-0050'></a>
## ADR-0050 — Recursos visuales de UI editables en el Inspector

- Fecha: 2026-10-10
- Estado: implementación integrada; smoke y escaneo del editor pasados; aceptación visual pendiente.
- Ámbito: texturas existentes de HUD, cartas, iconos de torre/capa y recursos de estilo de botones.
- Relación: amplía ADR-0049; mantiene su límite de no cambiar lógica ni datos de gameplay.

### Contexto

La primera etapa migró jerarquías a escenas, pero algunas texturas aún se asignaban a los controles desde `Main` y `IconCatalog.gd` solo contenía rutas en código. Al cambiar un icono no resultaba evidente qué nodo o recurso debía abrirse, y el inspector de la escena no mostraba esas asignaciones.

La petición es poder inspeccionar y sustituir cómodamente los sprites existentes, incluidos iniciar ronda, marcos de panel/card, iconos de recursos y torre. No se deben cambiar diseños, controles o contenido de gameplay.

### Decisión

1. No se añaden campos visuales a `TowerData`, `WaveData` ni otros Resources de gameplay. Los iconos de interfaz se configuran en recursos y escenas de `game/ui/`.
2. `game/ui/resources/icon_catalog.tres` es el catálogo editable: al abrirlo en Godot muestra texturas agrupadas para recursos, capas, torres, estados y los cuatro cursores. `Main` expone la referencia `ui_icon_catalog` en el Inspector y los consumidores existentes consultan el mismo recurso, conservando sus IDs y la asociación actual.
3. Cada instancia de `TowerShortcutCard` y `TowerLayerUpgradeButton` en `main.tscn` expone `tower_icon_texture` o `layer_icon_texture`. Sus scripts `@tool` reflejan esa propiedad en el `TextureRect` hijo para que la asignación también se vea al editar la escena. Solo sincronizan un recurso visual; no ejecutan gameplay.
4. Las texturas de Gold/Mana están asignadas en sus `TextureRect` de escena. Los StyleBoxTexture de iniciar ronda y las cards de expansión están serializados en `main.tscn` con referencia visible a sus PNG y márgenes 9-slice. El marco de las cards de torre permanece asignado en su escena de componente. El usuario puede seleccionar el botón, abrir `Theme Overrides > Styles` y editar el StyleBox/Texture.
5. Los paneles generales no tenían sprite: usan `StyleBoxFlat` del Theme local [Rogue HUD](../../game/ui/themes/rogue_hud_theme.tres). Se mantienen como superficies planas existentes; color, borde, radio y margen se editan desde el recurso Theme o sus overrides.
6. Se retiran de `Main` las asignaciones de sprites y creación de StyleBoxTexture para iniciar ronda, cards de expansión, tarjetas de torre, iconos de recursos y capas. Se conserva el cálculo dinámico de anchura del botón de ronda y la selección runtime de iconos para tarjetas que representan datos variables.

### Ubicaciones de edición

| Qué se quiere cambiar | Selección en Godot |
|---|---|
| Icono usado por retratos, ofertas, tienda, estados y cursores | `game/ui/resources/icon_catalog.tres`, expandir la propiedad del icono |
| Icono de una tarjeta de torre | Instancia `TowerShortcut1…7` en `game/main/main.tscn`, propiedad `tower_icon_texture` |
| Icono de Health/Armor/Shield | Instancia `UpgradeHealth`, `UpgradeArmor` o `UpgradeShield`, propiedad `layer_icon_texture` |
| Sprite Gold/Mana del HUD | `HUD/ResourcesRow/GoldPanel/GoldGroup/GoldIcon` o `HUD/ResourcesRow/ManaGroup/ManaIcon` en `main.tscn`; M55 reubica Gold dentro de su panel horizontal |
| Fondo y estados del botón de ronda | `HUD/RoundPanel/Margin/Content/StartWave`, `Theme Overrides > Styles` |
| Marco/estados de una card de expansión | `HUD/TerrainCardPanel/.../TerrainCard1…3`, `Theme Overrides > Styles` |
| Marco de tarjeta de torre | Raíz `TowerShortcutCard` en `game/ui/components/tower_shortcut_card.tscn` |
| Apariencia base de paneles | `game/ui/themes/rogue_hud_theme.tres`, estilos `Panel` y `PanelContainer` |

### Validación

El smoke headless de Godot 4.7 pasó tras verificar las 20 texturas del catálogo, el StyleBox con sprite del botón de ronda y la presencia/propagación al `TextureRect` de los iconos exportados de torre y Health. Un escaneo headless del editor completó la inicialización y el registro de clases. Ambos mostraron únicamente el aviso del host por el almacén de certificados raíz. La vista manual de los nodos en el Inspector y la comparación visual en ventana siguen pendientes.

### Referencias

- [ADR-0049: arquitectura híbrida y editable para la UI](#adr-0049)
- [Arquitectura técnica](PROJECT_SPEC.md#architecture)
- [Aceptación de UI](IMPLEMENTATION_AND_QA.md#acceptance)

<a id='adr-0051'></a>
## ADR-0051 — Navegación, previsión por portal y panel de torre

- Fecha: 2026-10-10.
- Estado: aceptado; cambios de código y recursos integrados, aceptación visual/interactiva pendiente. M55/ADR-0105 sustituye los retratos flotantes sobre portales por una lista en tooltip.
- Complementa: ADR-0042, ADR-0043, ADR-0046, ADR-0047, ADR-0048 y ADR-0050.
- Sustituye: la tecla `D` deja de alternar el overlay diagnóstico para permitir mover la cámara a la derecha; el overlay pasa a `Ctrl+D`.

### Contexto

El mapa ya permitía panear con el botón central y arrastre. Los portales mostraban de dónde podían venir enemigos, pero no anunciaban la composición por entrada. El ghost de torre no diferenciaba suficientemente el modo de colocación. Tower Info tenía un panel plano, información de mejora principalmente textual y un botón Demoler ancho. Las sombras proyectadas que se dibujaban bajo entidades y decoración añadían manchas que no forman parte del arte.

La composición activa de la campaña se reparte en `WaveDirector._select_campaign_route`: cada enemigo de la ronda usa el siguiente endpoint alcanzable en un round-robin global que se reinicia al empezar la oleada. Los fixtures de diagnóstico, en cambio, siguen la política declarada en cada `WaveEnemyGroupData`. Una previsión visual debe respetar esta diferencia para mostrar datos correctos.

### Decisiones

1. `W`, `A`, `S`, `D` panean la cámara continuamente. Las diagonales se normalizan y la velocidad del mundo compensa el zoom. Las teclas mantenidas se limpian cuando la ventana pierde el foco. El pan con botón central, zoom, `H` y `R` conservan su función. El overlay de diagnóstico de rutas se asigna a `Ctrl+D`.
2. Cada portal alcanzable recibe la lista agregada de tipos de enemigo y el conteo que le corresponde en la ronda seleccionada. El tooltip al hover indica ronda, total y grupos por tipo; los retratos flotantes descritos en esta decisión son históricos y M55/ADR-0105 los elimina. La previsión se recalcula al elegir otra ronda, confirmar o mover una expansión válida y sigue el mismo reparto de `WaveDirector`.
3. El sprite alfa del portal recibe contorno cuando el puntero está sobre su área interactiva. El tooltip vive en la escena de HUD y se mantiene por encima del mundo sin capturar el puntero.
4. El sprite de la torre en construcción usa un `ShaderMaterial` fantasma verde translúcido si la casilla es legal y rojo si no lo es. Mantiene prioridad Z por encima de terrenos, elevaciones y decoración.
5. Se eliminan las sombras proyectadas dibujadas por código bajo enemigos, props y trazos de flujo. No se sustituyen por otro tipo de sombra procedural.
6. HISTÓRICO, sustituido en presentación por ADR-0053: la primera versión de Tower Info usaba un marco PNG, retrato grande e iconos ampliados. El marco `assets/ui/tower_info_panel_frame.png` y esa composición ya no forman parte del juego; la presentación actual del panel es plana.
7. HISTÓRICO, sustituido en presentación por ADR-0053: Demoler se probó con un botón cuadrado y un icono PNG. La interfaz actual usa el botón textual compacto descrito por la actualización M23 en [Progreso](IMPLEMENTATION_AND_QA.md#progress); la regla de tamaño PNG de esta decisión ya no aplica.

### Consecuencias

- La vista previa por entrada describe la asignación de enemigos de la ronda que el jugador tiene seleccionada, incluyendo una expansión candidata válida. El tooltip no promete habilidades o variantes de invocación; enumera los `EnemyData` de la composición directa.
- El nivel principal empieza en `0 DE 45` porque representa mejoras compradas de las 45 posibles. Los niveles 0–15 de Health, Armor y Shield siguen siendo independientes.
- La barra de experiencia comunica proporción y progreso restante sin repetir las cifras en el panel; el tooltip del botón de mejora conserva acceso a los números exactos.
- Se conserva el arte de las sombras ya pintado dentro de PNGs; solo desaparecen las elipses y trazos de sombra generados en runtime.
- Falta revisar la legibilidad, el orden de dibujo y la interacción en ventana a 1280×720 y 1440×900.

### Validación pendiente

Seguir la revisión manual M23 en [Aceptación](IMPLEMENTATION_AND_QA.md#acceptance). No se han ejecutado pruebas ni inspección en ventana para este cambio.

### Referencias

- [ADR-0046: progresión de mejoras y feedback de selección](#adr-0046).
- [ADR-0047: herramientas de depuración y claridad de selección](#adr-0047).
- [ADR-0048: HUD, oleadas, cards y paredes texturizadas](#adr-0048).

<a id='adr-0052'></a>
## ADR-0052 — Números de daño animados y legibles

- Fecha: 2026-10-10
- Estado: Aceptado; código integrado, revisión visual pendiente
- Decisores: usuario y equipo del proyecto
- Sustituye: ninguna

### Contexto

El daño ya se mostraba con un `Label` flotante, pero todos los impactos aparecían centrados y con tamaño/recorrido casi idénticos. Los ataques simultáneos se amontonaban. El usuario pidió adaptar la presentación del reel de CapyEmber, que combina entrada con golpe, trayectorias alternas, color semántico y énfasis de críticos.

### Decisiones

1. El feedback se dispara después de `DamageService.damage_resolved` cuando el resultado aplica daño positivo. Es presentación; no modifica `DamagePacket`, `DamageResult`, HP, estados ni cadencia.
2. Cada número entra con una escala breve tipo punch, asciende por dos tramos que forman un arco y alterna izquierda/derecha. Rota entre tres alturas iniciales para reducir solapamientos. Se desvanece y se libera al terminar su tween.
3. Health usa rojo, Armor ámbar y Shield cian, tanto en el texto como en el flash breve del sprite. El tamaño usa la proporción entre el daño y una media móvil por enemigo, limitada para conservar la legibilidad.
4. El crítico añade `CRIT`, mayor tamaño y contorno más fuerte sin sustituir el color de la capa afectada.
5. Los indicadores siguen siendo `Label` dinámicos dentro del mundo (`Entities`), como en la arquitectura M22; el tween está enlazado a la vida del propio indicador para que sobreviva si su enemigo muere durante la animación.

### Consecuencias

- Una sucesión de impactos en el mismo objetivo distribuye los valores por ambos lados y conserva la relación visual entre magnitud, capa y crítico.
- El daño se comprime visualmente con límites; no se promete equivalencia numérica con el tamaño del texto del reel.
- Sigue pendiente comprobar legibilidad y rendimiento con la oleada más densa y torres de cadencia alta. Si la revisión muestra presión de nodos, el siguiente ajuste será agrupar o reutilizar indicadores sin alterar el cálculo del combate.

### Referencias

- CapyEmber, «How I make damage numbers that feel good, with hundreds of enemies on screen», Instagram Reels, https://www.instagram.com/reels/DeSHBhkoEYE/, consultado el 2026-10-10.
- [Sistema de combate](PROJECT_SPEC.md#combat), sección «Feedback visual de impacto».
- [Aceptación manual M24](IMPLEMENTATION_AND_QA.md#acceptance).

<a id='adr-0053'></a>
## ADR-0053 — Paneles y sprites sencillos

- Fecha: 2026-10-13.
- Estado: aceptado; implementación y arte integrados, aceptación visual pendiente.
- Complementa: ADR-0040, ADR-0048 y ADR-0051.
- Sustituye: los acabados visuales ornamentales de las cards de expansión descritos en ADR-0048 y los puntos visuales 6–7 de Tower Info en ADR-0051. No cambia la previsión de oleadas, la navegación ni las reglas de selección/mejora.

### Contexto

Los paneles de selección de terreno y Tower Info usaban marcos ilustrados, y Tower Info reservaba mucho espacio para un retrato grande y controles de mejora altos. El cofre y el portal también tenían sprites muy detallados. Se pidió reducir al mínimo la decoración y trabajar sobre `main`, manteniendo el alcance de cualquier cambio de pixel art de otra rama independiente.

### Decisiones

1. Los `PanelContainer` del HUD usan superficies oscuras planas, borde fino de bajo contraste y esquinas casi rectas. La selección de terreno tiene tres cards separadas, sin marco PNG; hover y selección se señalan con un cambio sobrio de borde y relleno. Los previews y conteos se conservan.
2. Tower Info retira el marco ornamental. Un icono de 36×36 comparte cabecera con el nombre y `NIVEL X DE 45`. El contenido se ajusta a su ancho: estado compacto, tres botones de mejora de 96×98 con iconos de 32 px, nivel, barra de XP y coste, y un botón horizontal de texto `Demoler`. Prioridades, XP independiente, tooltips y acciones conservan su comportamiento.
3. El cofre y el portal se reemplazan por sprites originales de pixel art de paleta limitada y silueta simple. Se dibujan con filtro nearest. El import limita el cofre a 168 px y el portal a 336 px en su dimensión mayor; SpawnPortal calcula la escala a partir del tamaño real de la textura importada.
4. El cambio solo afecta presentación y recursos visuales. No cambia terrenos, cofres, oleadas, rutas, economía, mejoras ni selección lógica.

### Consecuencias

- La selección de expansión da prioridad visual al terreno y al preview; el estado de selección sigue visible con una línea de borde.
- Tower Info ocupa menos alto y ancho sin quitar acceso a cifras detalladas, gracias a los tooltips existentes.
- Los PNG fuente mantienen transparencia. El sprite del cofre se ajusta a su caja conservando proporción; el del portal conserva su proporción y tamaño lógico de 112×168 px.
- Queda pendiente revisar legibilidad, alineación y escala de ambos sprites y los dos paneles a 1280×720 y 1440×900 en una ventana Godot.

### Referencias

- [Diseño activo](PROJECT_SPEC.md#game-design).
- [Aceptación M23](IMPLEMENTATION_AND_QA.md#acceptance).
- [ADR-0048: HUD, oleadas, cards y paredes texturizadas](#adr-0048).
- [ADR-0051: navegación, previsión por portal y panel de torre](#adr-0051).

<a id='adr-0054'></a>
## ADR-0054 — Tipografía global y ausencia de sombras generadas por código

- Fecha: 2026-10-13.
- Estado: sustituido parcialmente por [ADR-0099](#adr-0099): sigue vigente la ausencia de sombras proyectadas individualmente por sprite; el velo global de nubes es la excepción visual aprobada.
- Complementa: ADR-0051 y ADR-0053.
- Alcance: presentación tipográfica global y sombras procedurales de la escena 2D. No cambia gameplay, estado, profundidad ni feedback de hover/selección.

### Contexto

El usuario pidió que ningún elemento del juego genere sombras por código, en especial las torres, y que Patrick Hand sea la fuente principal de todo el proyecto tal como está actualmente. El tema del HUD se aplicaba desde las escenas, pero no estaba configurado como tema predeterminado del proyecto. También había cifras pintadas manualmente que elegían `ThemeDB.fallback_font` en vez del tema activo.

### Decisiones

1. Se configura `rogue_hud_theme.tres` como tema predeterminado en `project.godot` y Patrick Hand como su `default_font`. Se conserva el tamaño tipográfico de cada control y no se añade ningún override local de fuente.
2. Los contadores que se dibujan manualmente en retratos de enemigos y previews de portal cargan directamente la misma FontFile para mantener consistencia con los controles.
3. Se elimina el polígono oscuro que `Tower._draw()` dibujaba bajo cada torre, el trazo ancho bajo las flechas de `PathFlowOverlay` y la copia de texto desplazada que simulaba sombra en los contadores de estados. La revisión no encontró una rutina equivalente de sombra para obstáculos, enemigos o base. No se consideran sombras el contorno de hover ni el feedback de selección; permanecen disponibles.
4. El archivo `PatrickHand-Regular.ttf` se copia desde la carpeta proporcionada por el usuario a `assets/fonts/`; se conserva junto a él `OFL.txt`. La fuente se distribuye bajo SIL Open Font License 1.1.

### Consecuencias

- La fuente predeterminada cubre los controles del proyecto y los dos usos de texto dibujado manualmente.
- Las torres ya no muestran la base/polígono oscuro generado por código, las flechas PATH no tienen trazo ancho debajo y los contadores no dibujan una copia de texto desplazada. Obstáculos, enemigos, base y props no reciben sombras individuales runtime; el velo global animado está documentado en ADR-0099.
- La legibilidad, el ajuste de texto y la apariencia final deben confirmarse en ventana Godot a 1280×720 y 1440×900.

### Referencias

- Fuente proporcionada por el usuario: `F:\Desktop\TowerDefense\Patrick_Hand\PatrickHand-Regular.ttf`.
- Licencia incluida con la fuente: SIL Open Font License 1.1, `OFL.txt`.
- [Revisión visual global](IMPLEMENTATION_AND_QA.md#acceptance).
- [ADR-0051: navegación, preview de portales y Tower Info](#adr-0051).

<a id='adr-0055'></a>
## ADR-0055 — Feedback de base, selección y recompensas

- Fecha: 2026-10-13.
- Estado: aceptado; código integrado, aceptación visual pendiente.
- Complementa: ADR-0038, ADR-0045, ADR-0051 y ADR-0052.
- Alcance: respuesta visual al daño de la base, recompensas Gold, selección de cartas y escala del sprite del portal. No cambia cálculos de combate, economía, oleadas ni rutas.

### Contexto

El usuario pidió feedback de combate y selección más evidente, pero breve y claro: la base debe avisar al recibir daño; Gold debe reaccionar al ganarse y al abrir cofres; las ofertas de terreno/mejoras deben destacar sobre el tablero; y el portal de aparición debe ocupar menos espacio.

### Decisiones

1. Cuando `WaveDirector` comunica daño positivo a la base, `Main` activa un tinte rojo temporal del sprite de base y una sacudida breve de `Camera2D.offset`. La cámara conserva su posición y zoom.
2. El grupo de icono y cifra de Gold recibe un golpe inmediato de escala, color e inclinación y vuelve con una secuencia breve de rebote. Así el efecto no depende de alcanzar un pico gradual ni pierde su énfasis cuando entran varias recompensas seguidas. Las ganancias y cofres con recompensa positiva usan la señal `gold_changed`; abrir un cofre sin Gold aceptado también anima el grupo una vez.
3. `SelectionBackdrop`, un `ColorRect` negro translúcido que ignora el ratón, queda bajo los controles del HUD. Se muestra para ofertas de terreno sin pieza elegida y para ofertas de mejora. Se oculta al elegir la pieza de terreno para colocar, y reaparece si se cancela la colocación y retorna la oferta.
4. El sprite de `SpawnPortal` reduce su caja visual de 112×168 a 64×96 px; se ajusta el desplazamiento vertical para conservar su alineación con el terreno. No se altera el área de interacción ni la previsualización de enemigos.

### Consecuencias

- El jugador recibe señales visuales acotadas en los eventos solicitados sin cambiar resultados de partida.
- El oscurecimiento queda detrás de las cards y no intercepta entradas.
- La intensidad/legibilidad y el anclaje del portal requieren revisión en ventana Godot.

### Referencias

- [Arquitectura técnica](PROJECT_SPEC.md#architecture).
- [Pruebas de aceptación visual](IMPLEMENTATION_AND_QA.md#acceptance).
- [ADR-0038: sprite de base y feedback de HUD](#adr-0038).
- [ADR-0051: navegación y portales](#adr-0051).

<a id='adr-0056'></a>
## ADR-0056 — Tablero inicial sencillo con camino recto

> La elevación plana de las seis celdas vecinas que se decidió originalmente quedó sustituida por ADR-0073. El trazado lineal, la ubicación de base y el mínimo de ruta de este ADR siguen vigentes.

- Estado: datos y código integrados; aceptación visual pendiente.
- Fecha: 2026-10-13.
- Contexto: el usuario pide simplificar el terreno inicial de la base y que las celdas PATH formen una línea recta. El tablero ya exige cuatro celdas PATH por ruta y tiene exactamente 19 hexágonos.

### Decisiones

1. Se conserva la huella axial de radio 2 (19 celdas) y el mínimo de cuatro celdas PATH por ruta.
2. La base pasa a `(-1,0)`. El camino queda en línea recta por `(-1,0) → (0,0) → (1,0) → (2,0)` y la salida de spawn se abre en `(3,0)`.
3. Las seis celdas vecinas de la base permanecen a elevación 0. El anillo se simplifica usando solo PATH y GRASS bajo; las elevaciones de montaña quedan fuera de la vecindad inmediata.
4. La rotación persistente de seis orientaciones se mantiene alrededor de la base; la recta y sus sockets PATH rotan juntos. Las piezas expansivas no cambian.

### Consecuencias y aceptación

- `data/terrain/starting_board.tres` define el cambio y `Main` sigue obteniendo la posición lógica de base desde `StartingBoardData`.
- La ubicación `(-1,0)` permite mantener 19 celdas y cuatro PATH en recta; con la base en el centro, el radio 2 solo permite tres celdas alineadas dentro del tablero.
- ADR-0025 queda parcialmente sustituido solo en la coordenada de base y la geometría inicial de la ruta. El tamaño del tablero y la longitud mínima siguen vigentes.
- La aceptación manual inicial M10 debía comprobar 19 celdas, anillo plano, ruta recta, endpoint y seis rotaciones. La regla del anillo plano fue retirada por ADR-0073; el criterio vigente acepta elevaciones Grass/Mountain aleatorias alrededor de la base.
- En el mismo cambio, el preview omite polígonos triangulares degenerados en las uniones de fachadas, y `Main` vuelve a asignar los cuatro cursores catalogados al puntero del sistema cuando no se usa el overlay de construcción. Los criterios manuales están en `IMPLEMENTATION_AND_QA.md#acceptance`.

<a id='adr-0057'></a>
## ADR-0057 — Oferta de expansión con prolongación garantizada

- Estado: parte del código integrada; la política de la card recta fue sustituida por ADR-0060; aceptación interactiva pendiente.
- Fecha: 2026-10-13.
- Contexto: una expansión podía cerrar spawns y dejar solo una salida abierta, mientras la siguiente oferta aleatoria contenía tres piezas sin una colocación legal para continuar PATH. El cambio responde a la petición de que siempre exista una opción de alargar el camino y que el cierre de un spawn se entienda antes de confirmar.

### Decisiones

1. La oferta de expansión incluye una pieza `ALARGA CAMINO` elegida mediante una búsqueda de las salidas alcanzables, las rotaciones de las piezas y las ubicaciones válidas. La posición preseleccionada conecta con una ruta existente y produce una ruta de spawn más larga.
2. La oferta comprueba que la colocación recomendada deja una nueva opción de prolongación. Al previsualizar una colocación de campaña, se bloquea la confirmación si el grafo resultante no tiene ninguna pieza y posición legal para extender una ruta; se repite la validación antes de mutar el tablero.
3. Durante la previsualización se conservan los portales activos que desaparecerían. Se muestran en rojo con una X, el hover advierte que se cerrarán al confirmar y el texto de colocación cuenta los cierres. Al salir de la previsualización, vuelven al estado del grafo activo.
4. El generador sigue ofreciendo tres piezas distintas. Las otras dos se eligen aleatoriamente entre las restantes del pool; la card de prolongación no reemplaza reglas de terreno, de sockets o del mínimo de ruta.

### Consecuencias y aceptación

- `Main` busca una colocación real que conecte una pieza a la coordenada exterior de un spawn y genera el grafo candidato incluyendo los huecos que se rellenarían.
- Tanto la previsualización como la confirmación deben conservar una siguiente prolongación legal. El bloqueo evita repetir el estado de bloqueo ilustrado por el usuario.
- `TerrainPiecePreview` mantiene los portales del grafo activo mientras evalúa el candidato y distingue cierres de endpoints nuevos/activos.
- La aceptación manual se añade a M10 en `IMPLEMENTATION_AND_QA.md#acceptance`: card marcada y preseleccionada, crecimiento de ruta, cierre visible, cancelación y bloqueo de posiciones sin continuación legal.
- Esta regla de gameplay está confirmada por la petición explícita; queda pendiente comprobar la legibilidad y usabilidad en ventana Godot. No se ejecutaron pruebas en este cambio.

### Fuentes

- Solicitud del usuario y captura del estado bloqueado, recibidas el 2026-10-13.
- Reglas de grafo y expansión vigentes en [diseño de terreno](PROJECT_SPEC.md#terrain) y [diseño principal](PROJECT_SPEC.md#game-design).

### ADR relacionados y sustituciones

- ADR-0060 sustituye la regla de reservar siempre una card `ALARGA CAMINO`; conserva el requisito de al menos una opción legal de continuidad y el aviso de spawns que se cierran. Complementa [ADR-0007](#adr-0007), [ADR-0025](#adr-0025) y [ADR-0056](#adr-0056).

<a id='adr-0058'></a>
## ADR-0058 — Arte Dirt en las texturas PATH

- **Fecha:** 2026-10-13
- **Estado:** aceptado e integrado
- **Contexto:** El lote artístico incluye Dirt_01/02/03, pero el proyecto no contiene una categoría Dirt ni destinos runtime Dirt. Las texturas Path existentes son los tres destinos de suelo equivalentes disponibles. El usuario indicó sustituir Path con Dirt y conservar el grafo y las flechas de ruta.

### Decisiones

1. Asignar Dirt_01/02/03, respectivamente, a `assets/terrain/tiles/path_01.png`, `path_02.png` y `path_03.png`.
2. Adaptar la máscara alfa de cada ilustración a la silueta hexagonal del PNG Path original y conservar las variantes bajo los nombres que ya carga `TerrainVisualCatalog`.
3. Mantener PATH como tipo lógico. No modificar sus sockets, topología, construcción, `PathGraph`, overlay ni flechas animadas.
4. Sustituir los otros veinte PNG del lote por sus equivalentes directos en las rutas runtime existentes y respaldar los 23 PNG originales bajo `art_generation/originals_replaced/2026-10-13/`.

### Consecuencias

- Las celdas PATH se ven como suelo Dirt genérico sin camino pintado. El recorrido se identifica con el overlay animado de flechas y los sockets interactivos existentes.
- No se crea una categoría Dirt ni se alteran reglas de terreno. La sustitución de los otros sprites conserva sus rutas, dimensiones y uso actuales.
- El arte instalado coincide píxel por píxel con las salidas documentadas; su canal alfa coincide con cada original respaldado. La inspección visual de la partida queda pendiente.
- El manifiesto y el [mapa completo de sustitución](CONTENT_AND_ASSETS.md#art-replacements) registran las equivalencias y las copias de respaldo.

### Relación con decisiones anteriores

Esta decisión cambia únicamente la presentación de Path/Grass/Mountain descrita en [ADR-0040](#adr-0040) y [ADR-0041](#adr-0041). No sustituye sus reglas de terreno, generación, oclusión ni flujo de rutas.

<a id='adr-0059'></a>
## ADR-0059 — Frost Keep usa copos de impacto individual

- **Fecha:** 2026-10-13
- **Estado:** implementación integrada; aceptación manual pendiente
- **Sustituye parcialmente:** decisión 10 de ADR-0037 (Frost Keep) y decisión 2 de ADR-0045 (patrón de ataque Frost). El alcance cuadrado de ADR-0045 se conserva.
- **Autoridad:** petición explícita del usuario; Rogue Tower se usa como referencia de comportamiento y cifras.

### Contexto

Frost Keep estaba configurado como `ALL_IN_RANGE`: cada disparo aplicaba un paquete de daño directo a todos los enemigos del cuadrado, aunque no hubiera un impacto visual. La aplicación repetida de un golpe garantizado convertía a Frost en daño de área constante y podía hacer que eliminase una oleada por sí sola. Además, Slow tenía un multiplicador fijo de 0,85 durante 1 segundo, distinto del efecto proporcional al daño de la referencia.

La página individual de Frost Keep describe copos que caen sobre PATH, alcance cuadrado, impacto a un enemigo por copo, Slow equivalente al 50% del daño y coste de 2 Mana/s. Su ficha indexada aún muestra daño 5; el anuncio oficial 1.1.2.0 posterior subió el daño de Frost de 5 a 6. La configuración usa 6.

### Decisiones

1. Frost Keep usa daño base 6, multiplicadores Health/Armor/Shield 10/5/5, alcance 2 en cuadrado, 180 RPM base y +18 RPM por celda PATH cubierta.
2. Durante combate, cada ataque crea un copo sobre una celda PATH aleatoria dentro de la cobertura cuadrada. El copo cae visualmente; al tocar un enemigo en movimiento dentro del alcance aplica un único `DamagePacket` por `DamageService` y desaparece. Puede fallar; un copo sin contacto no hace daño ni aplica estados. Un copo nunca golpea más de un enemigo.
3. Slow recibe fuerza igual al 50% del daño realmente aplicado por el impacto. La fuerza se suma hasta 60 y decae a 6 puntos por segundo; cada punto es un punto porcentual de reducción de velocidad. Si el daño aplicado es cero, no se aplica Slow. La fuerza por enemigo queda en la instancia de `StatusEffectController` y no muta el Resource compartido.
4. El coste de 2 Mana/s se drena continuamente mientras la run está en `COMBAT`, aunque Frost no tenga objetivo. Las cards que modifican el coste multiplican esa tasa. Sin Mana suficiente, la torre se bloquea y no lanza copos hasta reunir el coste del siguiente paso.
5. Altura de caída, velocidad y radio de contacto son parámetros de `TowerData` para ajustar el dibujo y la tolerancia de colisión. Son aproximaciones configurables del efecto visual; la distribución interna exacta de partículas del juego original no es pública.
6. Se conserva la carta Blizzard y el sistema de mejoras por capas del proyecto. No se importa el árbol específico de cartas de Rogue Tower.

### Consecuencias

- El daño vuelve a coincidir con la ficha oficial más reciente, pero cada impacto exige contacto y solo puede afectar a un enemigo. Los copos pueden fallar, por lo que Frost deja de repartir un golpe garantizado a todos los objetivos del cuadrado.
- Con 100% de impactos sobre un solo objetivo, el techo matemático inicial es 180 Health/s, 90 Armor/s o 90 Shield/s antes de overkill. El daño real depende de cuántos copos contacten con enemigos. Las mejoras y cartas del proyecto pueden elevar las cifras runtime.
- La cadencia conserva su sinergia PATH: cada celda cubierta añade 18 ataques por minuto. Más cobertura también aumenta los copos creados, conforme a la regla publicada.
- El coste nominal refleja 2 Mana/s durante combate y no queda sujeto a la presencia de objetivos.
- Queda pendiente observar en Godot la frecuencia visual de contactos, el Slow acumulado y la lectura del HUD. La altura/velocidad/radio configurables pueden necesitar ajuste tras esa aceptación.

### Fuentes

- [Frost Keep — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Frost_Keep), consultada 2026-10-13. Referencia comunitaria para lluvia de copos, contacto individual, Slow, coste, rango y cadencia por PATH; la ficha indexada muestra daño 5.
- [Anuncios oficiales de Rogue Tower en Steam](https://steamcommunity.com/app/1843760/announcements/), Patch Notes 1.1.2.0, 2022-09-08; consultados 2026-10-13. El changelog sube el daño base de Frost de 5 a 6.
- [Status Effects — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Status_Effects), consultada 2026-10-13. Referencia para el cap de Slow 60 y decaimiento 6/s.
- [Discusión de Steam sobre Slow](https://steamcommunity.com/app/1843760/discussions/0/3182358518959301391/), respuesta del desarrollador consultada 2026-10-13. Explica que los copos aplican Slow al contacto y que Frost acelera con más cobertura.

<a id='adr-0060'></a>
## ADR-0060 — Ofertas de terreno variables y contenido visual determinista

- Estado: decisión aprobada por petición del usuario; código integrado; aceptación interactiva pendiente.
- Fecha: 2026-10-13.
- Contexto: una oferta siempre mostraba una pieza recta `ALARGA CAMINO`, incluso cuando el jugador podía tomar una ruta distinta. Además, las cards generaban props ilustrativos por separado del roll aplicado al colocar, por lo que la miniatura y el tablero podían discrepar.

### Decisiones

1. La oferta conserva al menos una colocación real que puede prolongar una ruta alcanzable y deja otra continuación legal. La búsqueda prueba geometrías, anclas y rotaciones del catálogo con orden aleatorio de run, por lo que la pieza marcada `EXTIENDE RUTA` puede ser recta, curva o bifurcada.
2. Si la pieza sugerida de continuidad no es recta, las otras dos opciones excluyen la recta. Así hay ofertas donde el jugador no puede elegir un camino recto. La ubicación y orientación válidas se preseleccionan como sugerencia; otras cards siguen disponibles si su colocación respeta las reglas y conserva una expansión legal posterior.
3. Las piezas de una oferta son copias runtime de los Resources de catálogo. `TerrainVisualCatalog` asigna obstáculos/cofres a las celdas locales de cada copia usando seed, ronda/índice de oferta, ID de pieza y coordenada local. La copia original compartida nunca se modifica.
4. La card dibuja esos datos fijados. El ghost de colocación y la pieza confirmada trasladan las mismas celdas al tablero, rotando junto con el terreno. Al cancelar o volver a la oferta no se vuelven a tirar obstáculos/cofres. Al confirmar, solo se calcula la variante del suelo según la coordenada axial final; no se sobrescribe el contenido de la oferta.
5. Se mantienen las tasas configurables vigentes: Grass 25 % para obstáculos, Mountain 15 %, cinco tipos de obstáculo y cofres en celdas sin obstáculo con la probabilidad de run/meta-progresión.

### Consecuencias y aceptación

- La regla de continuidad de ADR-0057 sigue vigente, pero ya no reserva siempre la pieza recta ni etiqueta la card como `ALARGA CAMINO`.
- Una expansión que no deje una opción posterior para extender una ruta sigue siendo inválida; los spawns que se cierran siguen visibles y contados antes de confirmar.
- La prueba manual M10/M14 debe comparar miniatura, ghost rotado y tablero confirmado, además de completar ofertas sin recta y verificar que el ghost mantiene las tiradas tras cancelar.
- El cambio se integra en los docs activos de [diseño](PROJECT_SPEC.md#game-design), [terreno](PROJECT_SPEC.md#terrain), [arquitectura](PROJECT_SPEC.md#architecture), [progreso](IMPLEMENTATION_AND_QA.md#progress) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

### Fuentes y ADR relacionados

- Solicitud del usuario de 2026-10-13: la oferta no debe asegurar siempre un camino recto y el contenido de la card debe coincidir con lo que se coloca.
- Actualiza parcialmente [ADR-0057](#adr-0057); mantiene la validación de continuidad y el aviso previo de cierre de spawns.

<a id='adr-0061'></a>
## ADR-0061 — Pausa y exclusividad de las fases de expansión

- Estado: decisión aprobada por petición del usuario; código integrado; aceptación interactiva pendiente.
- Fecha: 2026-10-13.
- Contexto: el jugador necesita poder pausar durante la partida, y las fases que esperan una card/pieza de terreno no deben admitir acciones de torres, cofres o inicio de ronda.

### Decisiones

1. `P` y el botón `PauseButton` bajo la barra de vida alternan `SceneTree.paused`. El control de pausa procesa siempre y refleja «Pausar»/«Reanudar» según el estado real.
2. `StartWave` puede recibir clic durante la pausa. Si la fase es `ROUND_PREP` y la ronda es válida, el controlador despeja la pausa antes de iniciar. En `TERRAIN_EXPANSION` y `CARD_OFFER`, el inicio de ronda no está disponible y no elimina la pausa.
3. Durante una oferta o colocación de terreno se bloquean selección/construcción/mejora/demolición de torres, apertura de cofres, controles de depuración y cambio de HUD. Se mantienen selección de card, rotación, colocación, cancelación y pausa.
4. `BuildController` no permite construir ni seleccionar torres durante expansión. `Main` bloquea también los atajos y clics de mundo para que no haya una ruta alternativa de entrada a acciones de torre.
5. El hover de un cofre cerrado activa bote cíclico y contorno/resplandor dorado; el efecto termina al salir del hex o abrir el cofre.

### Consecuencias y aceptación

- Los controles de pausa permanecen visibles bajo la vida y el botón de inicio se vuelve a sincronizar al despausar desde código.
- La oferta de terreno es la única interacción de tablero durante la fase de expansión; pausar sigue permitido en cualquier fase.
- La aceptación manual M25 verifica teclado, botón, inicio de ronda pausada, exclusividad de fases y ciclo de hover del cofre.

### Fuentes y ADR relacionados

- Solicitud del usuario de 2026-10-13 sobre pausa, inicio de ronda y restricción de acciones durante selección de terreno.
- El efecto de cofre complementa [ADR-0040](#adr-0040); se documenta en [GDD](PROJECT_SPEC.md#game-design), [arquitectura](PROJECT_SPEC.md#architecture), [progreso](IMPLEMENTATION_AND_QA.md#progress) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

<a id='adr-0062'></a>
## ADR-0062 — Catálogo de Upgrade Cards y Permanent Upgrades

- Estado: decisión aprobada por petición del usuario; datos y efectos integrados; aceptación manual pendiente.
- Fecha: 2026-10-13.
- Contexto: el pool M11 tenía 18 cards propias y una frecuencia de oferta provisional hasta la ronda 18. La tienda M12 permitía comprar mejoras permanentes propias, pero no contenía la mayoría de las ramas de Upgrade Cards y Permanent Upgrades de Rogue Tower.

### Decisiones

1. Se representan las 173 Upgrade Cards compatibles con el roster actual de siete torres: Ballista (24), Mortar (25), Tesla Coil (16), Frost Keep (19), Flame Thrower (14), Poison Sprayer (14), Shredder (15) y efectos generales/de estado (46). Se añaden 172 Resources; Advanced Circuits ya existe con la misma operación en `tesla_overcharge.tres`, así que se conserva esa card y se le aplica la rama de prerequisitos de referencia en vez de ofrecer un duplicado. Esa equivalencia ya forma parte de las 18 cards propias previas: 18 + 172 = 190 IDs únicos, que representan las 173 entradas compatibles de referencia más 17 cards propias sin equivalente. Las cartas específicas requieren que la torre esté desbloqueada; las cadenas y alternativas se filtran por las cards seleccionadas. Cada carta tiene máximo una copia por run.
2. Las mejoras temporales aparecen después de colocar la expansión al cerrar las rondas 3, 6, 9, …, 42, antes de la ronda siguiente. La cadencia cada tres rondas queda confirmada. La oferta base tiene tres opciones y Card Draw I–III, comprable en la tienda meta, la amplía a cuatro, cinco y seis. La victoria en 45/45 finaliza la run y abre la tienda sin una oferta temporal adicional.
3. La tienda que aparece tras victoria o derrota incluye 25 mejoras permanentes adicionales; junto con las seis propias, el catálogo contiene 31. Se incorporan Card Draw, Gold Drop, Repair, Fortification de base y las ramas Better para Health/Armor/Shield de cada una de las siete torres. Cada rama de torre requiere el unlock persistente de esa torre. Las compras se persisten y se aplican desde la siguiente run.
4. No se copian las condiciones de XP ni el árbol de desbloqueo de cartas del juego de referencia: el proyecto usa Meta Currency, unlocks persistentes y prerequisitos por carta durante la run. Nombres y efectos de referencia se conservan donde encajan, pero las cantidades, rarezas y costes del proyecto quedan configurables/provisionales.
5. Se excluyen mejoras que requieren torres o sistemas ausentes (Cannon, Encampment, Lookout, Radar, Obelisk, Particle Cannon, Monument, University, Mine, Mana Siphon/Bank y otros edificios), Freeze, Gold Rush que exige Mine, Treasure! que concede draws desde cofres de cartas y Draw Frequency I–II, que alteraría la cadencia confirmada. Las cartas de cofres de jefe tampoco se incorporan: los cofres actuales son de terreno y solo conceden Gold. No se añaden assets de terceros.
6. Se mantienen sin cambios las decisiones propias de tablero, combate, torres y campaña que no forman parte de estas mejoras. Los efectos sin equivalencia directa se resuelven mediante operaciones de datos runtime y no mutan Resources compartidos.

### Consecuencias y aceptación

- `CardPoolData` combina el pool propio y `CardCatalogData`; `RunCardService` valida IDs/prerrequisitos, filtra por unlock, copia y requisitos seleccionados, y aplica efectos temporales.
- `MetaProgressionData` combina catálogos `PermanentUpgradeCatalogData`; la tienda presenta y persiste los 31 upgrades. Las mejoras de torre permanecen bloqueadas hasta desbloquear su torre.
- Aceptación manual pendiente en M11/M12 de `IMPLEMENTATION_AND_QA.md#acceptance`: revisar oferta en rondas 3, 6, 9 y 42; estados/caps/daño condicionado y efectos generales; Card Draw; compra y persistencia post-run; ramas por torre; exclusión de una oferta al concluir la 45.
- Los valores comunitarios se tratan como punto de partida, no como balance final aprobado.

### Fuentes y ADR relacionados

- Petición del usuario de 2026-10-13: usar las Upgrade Cards compatibles y las mejoras permanentes, con oferta temporal cada tres waves y compras generales al acabar la run.
- [Upgrade Cards — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Upgrade_Cards), consulta 2026-10-13.
- [Permanent Upgrades — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Permanent_Upgrades), consulta 2026-10-13.
- Fandom bloqueó la consulta web directa durante esta revisión; se cotejaron los extractos indexados. Las fuentes y limitaciones están anotadas en [Origen y referencias](CONTENT_AND_ASSETS.md#origin-and-sources).
- Continúa [ADR-0021](#adr-0021) y [ADR-0022](#adr-0022) en el nuevo alcance de contenido; no altera sus reglas de aislamiento temporal ni guardado.

<a id='adr-0063'></a>
## ADR-0063 — Selección y retirada de objetos del terreno

- Estado: decisión aprobada por petición del usuario; código integrado; aceptación visual/interactiva pendiente. El rango lógico 0–2 de la decisión 6 fue ampliado a 0–3 por ADR-0073.
- Fecha: 2026-10-13.
- Contexto: los obstáculos no se podían inspeccionar ni retirar y los portales eran solo indicadores de rutas. Las capturas del usuario mostraron vértices de fachadas que parecen abiertos; además, el offset de elevación de 18 px por nivel ofrecía poca separación visual.

### Decisiones

1. En `ROUND_PREP`, seleccionar un obstáculo muestra su nombre en el panel de información: Roca, Cristal, Hierba alta, Tótem o Montón de piedra, con su retrato, terreno y elevación. Los nombres se fijan en `CONTENT_AND_ASSETS.md#canonical-names` y corresponden al orden de `HexCell.ObstacleType`.
2. Se puede pagar para quitar obstáculos. La retirada número `n` cuesta `25 × n²` Gold: 25, 100, 225, 400… `n` es el ordinal de la retirada actual, equivalente a uno más la cantidad de obstáculos que ya retiró el jugador; no es el número de obstáculo generado ni incluye portales.
3. Al hacer clic en un portal, el panel muestra la composición que tiene asignada en la ronda seleccionada como lista con sprite, nombre y cantidad de cada tipo. Se conserva el tooltip de hover existente.
4. Se puede retirar un portal solo cuando quedan más de tres spawns activos. Su coste es dos veces el siguiente coste de retirada de obstáculo. Retirar portales no incrementa el contador de obstáculos retirados.
5. `PathGraph` conserva los endpoints retirados durante la run y expone únicamente rutas activas al `WaveDirector`, el overlay de flujo y la previsión. Las cantidades de `WaveData` permanecen iguales; el round-robin redistribuye los enemigos entre los endpoints activos.
6. El desplazamiento visual de cada nivel pasa de 18 a 28 px en terrenos, hover, fantasmas y torres. En esta decisión se conservaba el rango lógico 0–2, ampliado a 0–3 por ADR-0073. Las uniones de fachadas se rellenan con una cuña única sin descartar wedges por un umbral de área.
7. Las compras ocurren solo en preparación de ronda. No alteran el grafo PATH, las coordenadas, el terreno, los sockets ni el contenido guardado entre runs.

### Consecuencias y aceptación

- La interfaz reutiliza `TowerInfoPanel` y el coste se paga con `RunEconomyService`.
- `WaveDirector` no genera menos enemigos cuando desaparece un portal; selecciona desde `PathGraph.get_active_routes()`.
- La verificación manual pendiente está en M26 de `IMPLEMENTATION_AND_QA.md#acceptance`: selección de los cinco obstáculos, secuencia de precios, restricción de tres portales, consistencia entre preview y wave real, juntas de fachadas y lectura de alturas a varios zooms.
- La altura extra es un parámetro visual confirmado por el usuario; no constituye una redefinición de gameplay ni cambia bonus de alcance/daño.

### Fuentes y ADR relacionados

- Petición del usuario del 2026-10-13: selección/retirada de obstáculos y portales, coste de Gold, revisión de vértices y mayor separación visual de alturas.
- Capturas adjuntas del usuario del 2026-10-13: juntas de fachadas Grass y Mountain.
- Continúa [ADR-0043](#adr-0043) para la oclusión 2D y el orden visual; precisa la selección de spawns de [ADR-0051](#adr-0051).
- Sustituye únicamente el offset visual de altura documentado en ADR-0048; conserva el rango lógico de elevación y las demás decisiones de esos ADR.

<a id='adr-0064'></a>
## ADR-0064 — Reembolso al demoler torres

- Fecha: 2026-10-13
- Estado: Aceptado por petición explícita del usuario; código integrado, aceptación manual pendiente.
- Sustituye: la regla provisional sin reembolso de [ADR-0023](#adr-0023), solo en demolición.

### Contexto

El usuario pidió que demoler torres devuelva Gold siguiendo el comportamiento de Rogue Tower. El coste de compra de este proyecto escala por perfil: `precio_base + cantidad_del_tipo × incremento`. Los niveles y mejoras se acumulan sobre la torre y no deben cambiar el coste de comprar/demoler.

### Decisiones

1. Al demoler una torre de tipo `T`, se devuelve el precio marginal del último slot ocupado: `precio_base(T) + (cantidad_antes_de_demoler(T) - 1) × incremento(T)`.
2. El cálculo usa únicamente el perfil de torre y el conteo previo de torres del mismo tipo. No lee nivel, XP ni upgrades comprados.
3. La devolución se acredita al Gold de la run; el siguiente coste de compra usa el conteo reducido.
4. La cifra devuelta aparece en Tower Info/mensaje y en el tooltip de demolición.

La fórmula marginal exacta es una elección propia para este proyecto, inferida de la curva por cantidad y del precio vigente tras retirar una torre. No se presenta como una transcripción literal de la wiki.

### Fuentes consultadas

- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers), wiki comunitaria de Fandom; consulta 2026-10-13. Referencia contextual para precio base, incremento, cantidad del mismo tipo y que el nivel es irrelevante.
- [Rogue Tower for Newbs (OUTDATED) — Steam Community](https://steamcommunity.com/sharedfiles/filedetails/?id=2742933260), guía comunitaria marcada como desactualizada; consulta 2026-10-13. Contexto sobre la venta de torres mejoradas; no fija el balance de esta demo.

### Consecuencias

- `BuildController` calcula y acredita el reembolso antes de emitir `tower_demolished`.
- Las compras de niveles/XP quedan fuera del reembolso.
- La UI comunica el importe y que los niveles no se reembolsan.
- Hay que revisar en ventana que 1.º, 2.º y 3.º ejemplar devuelven respectivamente su precio marginal configurado y que demoler una torre mejorada no cambia la cifra.

<a id='adr-0065'></a>
## ADR-0065 — Panel común e iconos para Upgrade Cards

- Fecha: 2026-10-13
- Estado: Parcialmente sustituido por ADR-0075: ya no se usan fondos PNG ni marco 9-slice; se conservan el panel reutilizable y los iconos de efecto.

### Contexto

Las ofertas temporales reutilizan una plantilla para cartas de muchas torres, rarezas y efectos generales. Hasta ahora, la plantilla ocultaba el icono en efectos globales y todas las rarezas compartían la misma superficie.

### Decisiones

1. Todas las cartas de run usan la misma escena `UpgradeOfferCard`; el recurso de carta solo aporta texto, rareza y operaciones.
2. El catálogo visual proporciona un marco común perimetral y fondos PNG separados para Común, Poco común y Rara. La rareza elige el fondo, sin duplicar la escena; el marco usa cortes 9-slice con el centro transparente y no debe cruzar ni tapar el contenido.
3. El icono de efecto/torre se presenta siempre y aumenta de 50×50 a 78×78 px. Las cartas que afectan a una sola torre conservan su sprite de torre.
4. El catálogo asigna icono a cada tipo de operación actual: daño, crítico, alcance, elevación, cadencia, área, Mana, Health/Armor/Shield, Gold, enemigo o estado. Una operación futura sin regla explícita usa el icono de daño como fallback visible.
5. Los siete PNG de efecto general son assets base editables, separados por concepto, bajo `game/ui/icons/`.

### Consecuencias

- `IconCatalogData` mantiene los PNG y resuelve el icono de cada carta sin cambiar los Resources del pool.
- La frecuencia de oferta cada tres rondas sigue siendo la de ADR-0062; esta decisión cambia la presentación.
- Se debe revisar a 1280×720 y 1440×900 la legibilidad de los fondos, el marco perimetral 9-slice y el nuevo tamaño del icono, también con ofertas de hasta seis cartas. El encuadre se corrigió en [ADR-0071](#adr-0071).

<a id='adr-0066'></a>
## ADR-0066 — Cofres al confirmar terreno y sombras por elevación

- Fecha: 2026-10-13
- Estado: Aceptado para tirada de cofres; la parte de sombras fue sustituida por ADR-0070 y su código se eliminó.
- Actualiza: [ADR-0060](#adr-0060) para el momento de la tirada de cofre y [ADR-0054](#adr-0054) para sombras de terreno.

### Contexto

El usuario pidió que las cards/selección de losas no anticipen cofres y que, si una casilla obtiene uno al colocarla, aparezca con animación de salto. También pidió sombras para las losas y los obstáculos que ayuden a leer altura, con dirección rotatoria lenta.

### Decisiones

1. Los obstáculos siguen fijados en la oferta y se conservan en su ghost. La casilla no contiene una tirada de cofre mientras aparece en la miniatura o se mueve como ghost.
2. Al confirmar la expansión, cada casilla Grass/Mountain sin obstáculo obtiene una tirada de cofre reproducible por seed y coordenada axial. PATH y las casillas con obstáculo no pueden contenerlo.
3. El cofre generado se muestra en el tablero con un salto único; el hover mantiene su animación y resplandor existentes.
4. El overlay generó sombras de terreno y obstáculos en la primera implementación; su geometría se refinó temporalmente mediante [ADR-0068](#adr-0068), y ambos sistemas fueron eliminados por [ADR-0070](#adr-0070).
5. La regla vigente desactiva todas las sombras generadas por código. ADR-0054 vuelve a ser la referencia para esta decisión visual.

### Consecuencias

- La política anterior de mostrar una asignación fija de cofre en card/ghost queda sustituida; ADR-0060 sigue vigente para los obstáculos y la reproducibilidad.
- La regla de no usar sombra procedural queda restaurada para todo el tablero; no quedan scripts ni shaders del overlay.
- Falta inspeccionar visualmente el salto del cofre, la ausencia de sombras y la colocación PATH en ventana.

<a id='adr-0067'></a>
## ADR-0067 — Hacks de progreso, tienda general y run limpia

- Fecha: 2026-10-13
- Estado: Aceptado por petición explícita del usuario; código integrado, aceptación manual pendiente.

### Contexto

Las cards de run solo se ofrecen al terminar las rondas definidas por `CardPoolData` (cada tres rondas en la demo). Probarlas requiere jugar combate y colocar expansiones. También se necesita revisar la tienda de mejoras permanentes desde cualquier fase y repetir una run sin efectos comprados.

### Decisiones

1. El panel de hacks `Ctrl+K` permite saltar desde preparación o expansión hasta la siguiente ronda que tenga oferta según `RunCardService.should_offer_after()`. El hack actualiza la ronda de campaña y abre el pool real de cards; las rondas y colocaciones omitidas no otorgan recompensas.
2. El panel puede abrir la pestaña de mejoras generales de la tienda permanente. El acceso de debug muestra un botón para volver al tablero. Las compras se guardan y se aplican al comenzar una run posterior, igual que en el acceso normal de post-run.
3. La primera versión de `Empezar run limpia` conservaba los desbloqueos; [ADR-0069](#adr-0069) sustituye esa regla: el hack vuelve al arsenal inicial, reinicia mejoras permanentes y devuelve el XP gastado en ellas. El saldo XP no gastado y los contadores históricos se conservan. Las cards temporales se reinician al configurar el nuevo `RunCardService`.
4. La acción normal de nueva run mantiene la progresión permanente; el reinicio limpio se activa únicamente desde el panel de hacks para facilitar pruebas sin cambiar el loop de progresión aprobado.

### Consecuencias

- Se pueden inspeccionar cards sin esperar el combate ni colocar dos piezas entre ofertas.
- El test de run limpia permite volver a comprar las mejoras con el XP devuelto, mientras mantiene el guardado reversible desde la interfaz de la tienda.
- La secuencia de salto es solo una herramienta de depuración: no simula recompensas ni el crecimiento del terreno de las rondas omitidas.
- Falta probar en ventana la cadencia 3/6/9, el acceso a la tienda y el reinicio/rehacer compras.

<a id='adr-0068'></a>
## ADR-0068 — Sombras de losetas recortadas por altura receptora

- Fecha: 2026-10-13
- Estado: Sustituido; el overlay y el shader fueron eliminados por ADR-0070.
- Reemplazó temporalmente: la técnica de sombra de losetas de [ADR-0066](#adr-0066). Su alcance fue cancelado por la petición posterior de no mostrar sombras generadas.

### Contexto

La primera sombra de M27 estampaba la silueta de cada loseta encima de la propia casilla. Eso oscurecía terreno de la misma altura y creaba marcas sin relación con los desniveles. En este momento histórico el rango lógico era 0–2; ADR-0073 lo amplió a 0–3. La cámara sigue siendo 2D top-down con elevación isométrica simulada.

### Decisiones

1. En la implementación temporal, solo las celdas con elevación mayor que 0 proyectaban sombra de loseta. Un receptor solo recibía la sombra de un caster si su elevación era menor.
2. La silueta hexagonal del caster se desplaza según la diferencia de altura y la dirección lenta de luz. El resultado se recorta contra el hexágono de cada receptor inferior cercano, de modo que la marca permanece dentro de la cara superior que la recibe.
3. Las sombras de terreno se dibujan encima de las caras del suelo y debajo del flujo de flechas y las entidades. Las sombras de obstáculos conservan su silueta alfa actual.
4. La sombra visual no altera elevación lógica, oclusión Y-sort, PathGraph ni fachadas.

### Consecuencias

- Esta implementación quedó retirada; el estado vigente elimina las sombras de todas las celdas y obstáculos.
- ADR-0070 registra la retirada y el trabajo visual de PATH asociado.

<a id='adr-0069'></a>
## ADR-0069 — Arsenal inicial, XP de perfil y lectura de altura

- Fecha: 2026-10-13
- Estado: Aceptado por petición explícita del usuario; código integrado, aceptación manual pendiente.
- Actualiza: el roster inicial de [ADR-0022](#adr-0022) y el reinicio limpio de [ADR-0067](#adr-0067).
- ADR-0076 aclara que las tres torres iniciales son unlocks permanentes: solo Ballista está reclutada al comenzar una run.

### Contexto

Una instalación nueva estaba dejando disponibles solo Ballista y cobrando costes bajos en moneda meta por las demás torres. El usuario pidió seguir el principio de XP de Rogue Tower, empezar con Ballista/Mortar/Tesla Coil, usar los costes de su tabla y explicar visualmente el bonus de construir en altura.

### Decisiones

1. El saldo persistente que el código guarda como `meta_currency` se presenta al jugador como XP de perfil. Se conserva la clave JSON existente para mantener compatibilidad con los guardados versión 1. Este saldo financia desbloqueos de torres y mejoras permanentes; la recompensa por run sigue siendo configurable por el diseño propio.
2. Ballista, Mortar y Tesla Coil forman el conjunto de unlocks permanentes gratuitos iniciales. ADR-0076 sustituye la lectura de que las tres se puedan construir desde el comienzo de cada run: solo Ballista empieza reclutada y las demás requieren elegir su card de reclutamiento. Frost Keep, Flame Thrower y Poison Sprayer cuestan 50 XP de perfil cada una; Shredder cuesta 100 XP. Un desbloqueo comprado persiste en las runs normales y habilita reclutamientos/cartas específicos de esa torre.
3. El hack `Empezar desde cero` deja solo el arsenal inicial, restablece mejoras permanentes y devuelve el XP que se gastó en esas mejoras. Conserva XP no gastado, desbloqueos de contenido que no sean torres y contadores históricos. Una run normal conserva los unlocks.
4. Al seleccionar una torre colocada en una celda elevada, Tower Info muestra `ALTURA hN`, el aumento de daño base y el aumento de alcance derivados de `TowerData`. La cifra usa `tower.elevation × bonus_per_level`, igual que el cálculo runtime.
5. Los costes y roster provistos por el usuario se usan directamente. El resto del árbol, la fórmula de XP por run y cualquier balance que no haya pedido siguen siendo propios y configurables.

### Consecuencias

- Una instalación nueva tiene tres torres con unlock permanente. El roster construible y los botones de una run se limitan a las torres reclutadas, según ADR-0076.
- Los perfiles ya guardados conservan sus torres compradas y reciben las tres torres iniciales gratuitas si les faltaban; el reset de prueba las vuelve a bloquear si son extras.
- No se cambia el formato de guardado. La tienda muestra XP de perfil para compras de torres y mejoras.
- Falta comprobar la barra inicial, compra/persistencia, reinicio de prueba y cifras de altura en ventana.

### Referencias

- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers), wiki comunitaria consultada el 2026-10-13. La página directa respondió HTTP 402; la búsqueda indexada devolvió la tabla de torres y el usuario aportó la tabla de XP/costes que se aplica aquí.
- [Upgrades — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Upgrades), wiki comunitaria consultada el 2026-10-13; referencia del XP persistente y su uso para unlocks y mejoras. No se importa su fórmula de recompensas.

<a id='adr-0070'></a>
## ADR-0070 — Sin sombras generadas y rutas limpias durante expansión

- Fecha: 2026-10-13
- Estado: Sustituido parcialmente por [ADR-0099](#adr-0099): sigue vigente la retirada de sombras proyectadas por sprite y la limpieza de rutas durante preview; el nuevo velo de nubes procedural es una capa global distinta.
- Sustituyó la parte de sombras de [ADR-0066](#adr-0066) y la implementación de [ADR-0068](#adr-0068). En su periodo vigente mantuvo la regla de sombras por sprite de [ADR-0054](#adr-0054); el alcance actual queda precisado por ADR-0099.

### Contexto

El usuario pidió borrar el script usado para generar sombras y dejar el videojuego sin sombras por ahora. También indicó que, al elegir una loseta de expansión, el camino y sus trazos se ven confusos.

### Decisiones

1. Eliminar `TerrainShadowOverlay`, su shader y archivos UID, sus referencias en `TerrainPiecePreview` y toda proyección de sombras individuales para terreno u obstáculos. No reintroducir sombras geométricas por sprite; el velo procedural global posterior está definido en ADR-0099.
2. El hover de terreno conserva el contorno de selección, pero no dibuja sockets PATH sobre las caras.
3. Mientras hay una pieza de expansión seleccionada para previsualizar/colocar, se ocultan las flechas de flujo PATH y las polilíneas de diagnóstico. Al cancelar/confirmar se restaura el flujo normal del tablero.
4. La altura continúa leyéndose con el desplazamiento visual, fachadas y oclusión Y-sort. El bonus de combate se expone en Tower Info según ADR-0069.

### Consecuencias

- No quedan scripts ni referencias runtime para sombras proyectadas individualmente; CloudShadowOverlay es una pasada global distinta, añadida después por ADR-0099.
- Se conservan las texturas originales y no se añaden sombras por sprite; el único shader de sombra actual es el overlay global de nubes descrito en ADR-0099.
- El grafo y la simulación PATH no cambian; solo se oculta su feedback visual durante el preview de expansión.
- Falta inspeccionar que el velo global de nubes no tape la UI y que las flechas PATH vuelvan tras confirmar/cancelar en ventana.

<a id='adr-0071'></a>
## ADR-0071 — Marco perimetral de cards y colocación automática de terreno

- Fecha: 2026-10-13
- Estado: Parcialmente sustituido por ADR-0075 en la presentación de cards; miniaturas y auto-colocación vigentes, aceptación visual/interactiva pendiente.
- Actualiza la presentación de Upgrade Cards de [ADR-0065](#adr-0065) y detalla la interacción de terreno de [ADR-0060](#adr-0060).

### Contexto

La textura de marco 9-slice de Upgrade Cards estaba usando un parche central y márgenes insuficientes; parte de su decoración aparecía estirada detrás del icono y los textos. Las miniaturas de expansión también dibujaban líneas de sockets que hacían que bifurcaciones y convergencias parecieran una maraña. El usuario pidió un atajo para colocar terreno automáticamente cuando exista un sitio legal.

### Decisiones

1. La textura de tier se mantiene como fondo de la card. El marco común utiliza cortes 9-slice ajustados a sus adornos perimetrales y no dibuja el centro; iconos y textos quedan dentro del borde.
2. Las miniaturas de cards muestran terreno y obstáculos, sin brazos, ramificaciones o flechas de conexión PATH. Esto solo cambia su representación: el grafo, las conexiones de la pieza y las validaciones siguen intactas.
3. Mientras hay una pieza seleccionada para colocar, la UI indica `Q · Colocar automáticamente (no recomendado)`. Pulsar Q busca una ubicación y orientación entre las adyacentes al tablero, en orden aleatorio del RNG de terreno de la run.
4. Cada candidata debe pasar `TerrainPlacementValidator`, producir un `PathGraph` válido y, durante una expansión de campaña, dejar una opción de continuación PATH futura. Si encuentra una, Q la confirma de inmediato. Si no encuentra ninguna, informa del resultado y deja el tablero y la pieza sin cambios.
5. E y los botones siguen rotando manualmente. Q conserva el giro antihorario fuera de una colocación activa.

### Consecuencias

- Las tres rarezas comparten un marco perimetral y ya no muestran una banda escalada por el centro.
- Las formas PATH se leen sin líneas superpuestas en las cards; la navegación real continúa dependiendo del grafo.
- La colocación automática puede elegir cualquier ubicación legal del contorno actual del tablero. Nunca omite las restricciones de conectividad ni de continuidad.
- La asignación de Q para auto-colocación descrita aquí es histórica y queda sustituida por ADR-0072: Q/E y la rueda giran; T auto-coloca.
- Falta inspeccionar el marco en ofertas de distintos tamaños y probar T con ubicación válida y sin ubicación válida, además de rotación Q/E y con rueda, en Godot.

### Verificación

Godot 4.7 abrió `game/main/main.tscn` sin errores tras el cambio de M32. La inspección visual e interactiva de marco, miniaturas y auto-colocación queda pendiente según M32–M33 de `IMPLEMENTATION_AND_QA.md#acceptance`; los controles vigentes constan en ADR-0072.

<a id='adr-0072'></a>
## ADR-0072 — Controles y tooltip compacto de celdas

- Fecha: 2026-10-14
- Estado: Aceptado e implementado; M55 sustituye parcialmente la decisión de rueda. Aceptación visual/interactiva pendiente.
- Actualiza los controles de colocación de [ADR-0071](#adr-0071).

### Contexto

La asignación de auto-colocación a Q desplazó la rotación manual que ya usaba ese atajo. El jugador también necesita entender el tipo de superficie, su ocupación y el beneficio de construir en altura sin abrir el panel técnico.

### Decisiones

1. `Q` gira 60° en sentido antihorario y `E` 60° en sentido horario durante una colocación.
2. Regla histórica de M33: la rueda giraba la pieza durante colocación. M55 la sustituye: la rueda sin modificador siempre controla el zoom, también durante colocación; `Ctrl+rueda` gira la pieza. `Q`/`E` siguen girando en ambas direcciones.
3. `T` ejecuta la auto-colocación validada y mantiene el aviso visible en la fase de expansión. Las validaciones de geometría, grafo y continuación PATH no cambian.
4. Si no hay torre seleccionada ni pieza en colocación, el hover muestra un tooltip pequeño, junto al puntero, con terreno, estado de construcción y altura. Para Grass/Mountain calcula el bonus de daño y alcance desde los perfiles compatibles de `TowerData`; en PATH indica que es ruta y no admite torres.
5. El tooltip no aparece sobre la interfaz, una selección activa de torre/objeto/pieza ni cuando otro panel contextual está activo. Es visual únicamente y no modifica reglas de terreno ni construcción.

### Consecuencias

- La rotación manual vuelve a ser inmediata y la opción automática queda en un atajo separado.
- El comportamiento de la rueda descrito originalmente aquí quedó reemplazado por M55/ADR-0105.
- Altura y bonus se muestran con los valores efectivos de las torres compatibles; el tooltip evita tapar el tablero y no compite con paneles de selección.
- La aceptación visual/interactiva queda pendiente en M33 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Verificación

No se ejecutaron pruebas ni se hizo inspección visual durante esta actualización.

<a id='adr-0073'></a>
## ADR-0073 — Elevaciones 0–3 y bonus de torre

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código integrado, aceptación visual pendiente.
- Amplía y sustituye el rango lógico de elevación de [ADR-0063](#adr-0063) y el feedback de altura de [ADR-0069](#adr-0069).

### Contexto

El juego solo admitía PATH 0, Grass 1 y Mountain 2, aunque el terreno debe variar sus desniveles por mapa y el jugador pidió que la altura sea legible tanto en terreno como en las torres.

### Decisiones

1. El rango lógico es 0–3: PATH solo usa 0; Grass usa 1 o 2; Mountain usa 2 o 3. Cada celda construible recibe una elevación reproducible por seed de run, coordenada/identidad de oferta. La card, el ghost y el tablero confirmado conservan el mismo valor.
2. Una torre en altura h gana `+h` de daño base y `+0.5 × h` hexágonos de alcance. Las reglas configurables de coste de Mana siguen perteneciendo a cada `TowerData`.
3. La torre construida muestra sobre su sprite una insignia con su bonus de daño efectivo (`+1`, `+2` o `+3`). El tooltip y Tower Info continúan mostrando daño y alcance.
4. PATH no recibe desnivel. El anillo de la base no tiene una regla especial de terreno bajo; el mapa sortea Grass/Mountain con sus rangos habituales.
5. Si en el futuro se incorpora un edificio cuya colocación dependa de una feature adyacente, su regla deberá evaluar la elevación de la feature vecina además de su relación axial. No se añade ahora ningún edificio de soporte ni lógica nueva de adyacencia.
6. No se incorporan elevaciones avanzadas 4–6: el diseño de este proyecto termina en 3.

### Consecuencias

- `HexCell`, `TerrainPieceCellData` y sus validadores aceptan el rango y combinaciones de terreno indicados.
- El offset visual continúa siendo 28 px por nivel; fachadas, hover, ghost y selección cubren desniveles de hasta tres niveles.
- Los perfiles/configuraciones de Mana mantienen su comportamiento actual: los que escalan por daño pueden elevar su coste efectivo con el bonus de altura.
- La revisión visual de generación, insignias, oclusión y colocación queda pendiente en M34 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- Petición explícita del usuario, 2026-10-14; fija los rangos PATH/Grass/Mountain y el tope 3.
- [Map features — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Map_features) y [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers), wiki comunitaria consultada el 2026-10-14. Los extractos indexados describen el bonus de altura (+1 daño y +0.5 rango por nivel) y alturas avanzadas; prevalece el límite explícito 0–3 del proyecto.
- [05 — Hex Grid & Terrain](PROJECT_SPEC.md#terrain), consultado el 2026-10-14.

<a id='adr-0074'></a>
## ADR-0074 — Vida inicial de base y derrota por llegada de boss

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; datos y código integrados, aceptación manual pendiente.
- Actualiza la vida de `Main Tower` y la condición de derrota descritas en [ADR-0008](#adr-0008) y [ADR-0022](#adr-0022).

### Contexto

La base configurada tenía 50 HP. El usuario fijó 10 HP base, diez niveles permanentes de Fortification y tres cards de Fortification por run; también pidió que tocar la base con un boss acabe la partida inmediatamente.

### Decisiones

1. `BaseData` inicia con 10/10 HP. Fortification permanente añade +1 al máximo por nivel, hasta +10 HP y 20/20 al nivel X. Los costes secuenciales I–X son 20, 40, 60, 80, 100, 120, 140, 160, 180 y 200 XP; el total es 1.100 XP.
2. Cada nivel superior de Fortification exige haber comprado el nivel anterior, como permite el catálogo por niveles. No se añaden gates de cantidad de cartas desbloqueadas.
3. Fortification I, II y III de run son independientes de la mejora permanente; cada una añade +3 HP máximos y se acumulan hasta +9 HP en esa run.
4. Si un enemigo con `boss_tier > 0` alcanza la base, `WaveDirector` termina la run en ese contacto incluso si queda Health. La llegada sigue aplicando el daño normal configurado antes de emitir la derrota. La regla solo se suprime para fixtures de diagnóstico.

### Consecuencias

- El máximo de base de una run normal es 10–20 HP según el nivel permanente. Las cards pueden aumentarlo en otros 3, 6 o 9 HP durante esa run.
- La derrota por llegada de boss se distingue de la destrucción por daño de enemigos normales.
- La inspección de los costes, HP, independencia de cards y llegada de jefe queda pendiente en M34 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- Petición explícita del usuario, 2026-10-14; valores de HP, beneficios y costes prevalecen sobre la wiki.
- [Fortification I–X — Permanent Upgrades, Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Permanent_Upgrades), wiki comunitaria consultada el 2026-10-14. Se registra solo como contexto de requisitos de niveles; el usuario indicó que en este proyecto basta exigir el nivel anterior.
- [Upgrade Cards — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Upgrade_Cards), wiki comunitaria consultada el 2026-10-14; referencia contextual para las cards separadas de la progresión permanente.

<a id='adr-0075'></a>
## ADR-0075 — Panel único y aura de rareza para upgrade cards

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; ampliado por [ADR-0080](#adr-0080), aceptación visual pendiente.
- Sustituye la distinción de fondos y marcos de Upgrade Cards de [ADR-0065](#adr-0065) y [ADR-0071](#adr-0071). Mantiene sus iconos y el resto de decisiones de esos ADR.

### Contexto

Las texturas de borde y los fondos por rareza se veían recargados y poco legibles en las ofertas de mejoras cada tres rondas.

### Decisiones

1. Todas las rarezas usan una sola escena y la misma superficie de tarjeta. El requerimiento posterior de un sprite vertical común, etiqueta de tier y separación se registra en ADR-0080.
2. La rareza se comunica mediante el color del aura alrededor del panel; el hover aumenta su intensidad sin crear una variante de superficie.
3. Icono, título y descripción mantienen sus posiciones y usan el espacio interior del panel. Los iconos de efecto no cambian.
4. Las imágenes PNG anteriores de marco y fondos de rareza dejan de formar parte del catálogo/runtime; el único sprite compartido posterior está definido en ADR-0080.

### Consecuencias

- `UpgradeOfferCard` ya no depende de la rareza para elegir textura ni necesita los sprites de `CardFrame`/`TierBackground`.
- Los colores de aura son configuración visual interna del componente; rarezas y pesos del catálogo de cartas no cambian.
- La aceptación visual en ofertas de tres a seis opciones y textos largos queda pendiente en M34 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- Petición explícita del usuario, 2026-10-14.
- [ADR-0065](#adr-0065) y [ADR-0071](#adr-0071), decisiones anteriores de presentación, consultadas el 2026-10-14.

<a id='adr-0076'></a>
## ADR-0076 — Oro inicial, reclutamiento de torres y flujo de run

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código integrado, aceptación interactiva pendiente.
- Actualiza la implementación de economía y tienda de [ADR-0022](#adr-0022) y el roster inicial de [ADR-0069](#adr-0069).

### Contexto

El roster persistente y el roster disponible para construir durante una run son conceptos distintos. La campaña también necesita una entrada de menú, pausa y retorno consistentes, junto a un resumen breve al terminar.

### Decisiones

1. Una run nueva inicia con 1.000 Gold. Starting Coffers añade 100 Gold por nivel, hasta diez niveles y un máximo de 2.000 Gold. El Gold sigue siendo temporal de run.
2. El roster construible al comenzar una run contiene únicamente Ballista. Mortar y Tesla Coil están desbloqueadas inicialmente y aparecen como cartas de reclutamiento en la primera oferta programada; torres que se desbloqueen de forma permanente podrán aparecer como reclutamientos en runs posteriores. Reclutar añade esa torre al roster de la run; no reclutarla impide construirla aunque tenga atajo.
3. La oferta de reclutamiento sigue el calendario general de cards, tras las expansiones de terreno de las rondas 3, 6, …, 42. Los filtros de cartas específicas respetan las torres ya reclutadas.
4. El menú principal, la partida y la pausa usan escenas distintas. El menú ofrece iniciar run y abrir la tienda. Tras victoria o derrota, el resultado vuelve al menú con la tienda abierta. Escape abre la pausa; desde allí se reanuda o se vuelve al menú. Volver al menú desde pausa abandona la run sin recompensa de derrota.
5. Game Over muestra un resumen compacto por tipo de torre con cantidad construida y daño acumulado. Solo se muestran tipos desbloqueados de forma permanente.

### Consecuencias

- `RunManager` conserva roster, construcciones y daño atribuido por tipo durante la run; `RunEconomyData` define el saldo inicial y Starting Coffers aporta el bonus persistente.
- El estado de victoria/derrota se conserva al cambiar a la escena de menú para presentar el resumen y abrir la tienda. Abandonar desde pausa limpia el estado temporal sin sumar recompensa ni contar la run como completada.
- La aceptación de saldo, reclutamiento, pausa, derrota y resumen está pendiente en M35 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño activo](PROJECT_SPEC.md#game-design), [progresión](PROJECT_SPEC.md#progression) y [progreso](IMPLEMENTATION_AND_QA.md#progress), consultados el 2026-10-14.

<a id='adr-0077'></a>
## ADR-0077 — Mapa conectado de mejoras permanentes

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; el caso de mejoras H/A/S en paralelo se amplía en [ADR-0081](#adr-0081); aceptación visual pendiente.
- Actualiza la presentación de tienda definida en [ADR-0022](#adr-0022); no cambia los efectos ni los costes configurados de las mejoras.

### Contexto

La tienda anterior agrupaba las mejoras como una lista terminal. El usuario quiere una progresión explorable con dependencias visibles, tarjetas consistentes e iconografía que identifique de inmediato qué entidad modifica cada mejora.

### Decisiones

1. Las mejoras permanentes se presentan en un mapa desplazable de nodos conectados. Comprar un nodo habilita los nodos que dependan de él según sus `prerequisites`; no se permite saltar los requisitos. Las tres mejoras H/A/S de torre son ramas hermanas reveladas por el unlock de su torre, conforme a ADR-0081.
2. Todas las mejoras usan una única escena reutilizable de tarjeta/nodo, independientemente de su categoría. Cada nodo muestra icono grande, título, descripción/efecto, coste y estado. Se reutiliza la iconografía existente; cualquier icono faltante se crea como PNG sencillo.
3. Los iconos representan el objeto o sistema afectado: retrato de torre, moneda/economía, carta/archivo, base u otro icono de sistema pertinente. Los títulos de mejoras de torre identifican explícitamente la torre afectada.
4. El tooltip de un nodo bloqueado explica los prerequisitos y cómo desbloquearlo. Comprar un nodo reproduce una ráfaga de partículas y actualiza en el momento sus conexiones/estados.
5. Este ADR solo decide la presentación y navegación del mapa; el catálogo, los identificadores, los efectos y el balance siguen siendo los Resources de datos y las reglas de diseño activo. Las conexiones usan exactamente `PermanentUpgradeData.id`; no se quitan prefijos ni se normalizan IDs al enlazar prerequisitos o dibujar ramas.

### Consecuencias

- `MetaProgressionMap` dibuja conexiones y partículas; `MetaUpgradeNode` es el componente compartido. El menú reutiliza la misma tienda.
- El código y contenido de la tienda están integrados. La legibilidad de iconos, bloqueos, conexiones, costes, escalado y feedback queda pendiente de aceptación visual en M35.

### Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño activo](PROJECT_SPEC.md#game-design), [progresión](PROJECT_SPEC.md#progression) y [nomenclatura](CONTENT_AND_ASSETS.md#canonical-names), consultados el 2026-10-14.

<a id='adr-0078'></a>
## ADR-0078 — Ventana ampliada del timeline de rondas

- Fecha: 2026-10-14
- Estado: Sustituido por [ADR-0083](#adr-0083) en el tamaño de ventana y el selector; se conserva como historial el uso de una ventana móvil con círculos, hover y datos de campaña.
- Sustituía la vista fija completa de 45 rondas descrita por [ADR-0048](#adr-0048).

### Contexto

El timeline de 45 puntos y su tooltip resultan útiles, pero la vista completa deja cada ronda demasiado pequeña para leerla durante la partida.

### Decisiones

1. El HUD muestra una ventana móvil de 10 o 15 rondas, elegible desde la propia interfaz. La ronda actual queda en el borde inicial; al avanzar una ronda, la ventana se desplaza manteniendo el mismo tamaño.
2. Los círculos y el área interactiva se amplían. Se conserva el tooltip con iconos y cantidades de enemigos al pasar el cursor.
3. El extremo futuro de la ventana se desvanece progresivamente para indicar que hay más rondas fuera de vista. El total de campaña continúa siendo 45.

### Consecuencias

- Historial: `RoundProgressStrip` conservó la fuente de datos y el hover, pero calculó las posiciones respecto a una ventana.
- Los dos modos de zoom se retiraron por petición explícita; la decisión vigente está en ADR-0083.

### Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño activo](PROJECT_SPEC.md#game-design), [campaña](CONTENT_AND_ASSETS.md#campaign) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance), consultados el 2026-10-14.

<a id='adr-0079'></a>
## ADR-0079 — Límites de obstáculos y cierre visual del terreno elevado

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código integrado, aceptación visual pendiente.
- Amplía las reglas de terreno de [ADR-0043](#adr-0043) y la distribución de props de [ADR-0060](#adr-0060), sin alterar el modelo lógico de elevación de [ADR-0073](#adr-0073).

### Contexto

La variación de altura reveló texturas de cliff estiradas, un borde abierto con cara violeta, puntas sin cerrar cuando una fachada terminaba sola en un vértice y un orden visual que mezclaba la profundidad axial con el desplazamiento de altura. La distribución aleatoria también necesita límites alrededor de la base.

### Decisiones

1. Una pieza de expansión de siete hexes puede contener como máximo dos obstáculos por celda. En el tablero inicial hay como máximo un obstáculo en total; la celda de base y sus seis vecinas axiales no admiten obstáculos.
2. La tapa de cada hex debe ser un polígono cerrado de seis vértices. La textura se recorta a ese polígono mediante UV por vértice; no se dibuja como rectángulo que sobresalga o se deforme.
3. Las fachadas de desnivel usan repetición/recorte de UV para preservar la escala de la textura al variar la altura. No se permite que el UV fuera del rango pinte una franja ajena (por ejemplo, el tramo violeta de una textura).
4. La lectura de profundidad conserva la cámara top-down isométrica fija. Las tapas del tablero se dibujan back-to-front por la Y proyectada del anclaje axial de suelo; la altura desplaza su imagen, pero no cambia la prioridad frontal de la celda. Las copias elevadas participan en el Y-sort de `Entities` en la posición proyectada de su superficie y se colocan antes de actores/props en empates.
5. Durante el modo de colocación de Ballista, el ghost de hover muestra el mismo bonus de daño de elevación que recibe una torre construida.
6. Cada fachada conserva el descenso vertical real hasta el vecino y solo añade espesor lateral donde la proyección colapsaría la cara. En cada vértice, una envolvente convexa entre los puntos de apoyo y los extremos extruidos cierra las uniones, incluidos los extremos aislados de una sola fachada.
7. La miniatura de cada oferta usa las mismas caras hexagonales texturadas, fachadas de Grass/Mountain y tapas de vértice que el tablero. Su Y-sort se calcula con el anclaje axial de suelo, y la altura solo desplaza las superficies; se muestran las elevaciones de la oferta que se va a colocar. El detalle de geometría, clave de vértice y orden de pintura de las fachadas quedó reemplazado por [ADR-0084](#adr-0084), después de que la primera versión todavía permitiera paredes recortadas y juntas abiertas.

### Consecuencias

- La corrección de superficie y fachadas queda en los componentes 2D del terreno; no se añaden mallas 3D ni se cambia la cámara. Las cards dejan de usar caras laterales lisas y no calculan su propio orden de profundidad basado en altura. El cierre por envolvente de puntos de pantalla descrito en el punto 6 y el dibujo global de fachadas/tapas son antecedentes: ADR-0084 fija la clave axial entera y el pase de dibujo local por celda.
- Los límites se aplican a los rolls iniciales y a cada pieza de expansión. La unión de extremos ahora incluye tanto el apoyo vertical como el espesor de pantalla y las tapas base usan profundidad axial; la aceptación visual de geometría, escala de textura y oclusión sigue pendiente en M35.

### Referencias

- Petición explícita del usuario y capturas de defectos de terreno, 2026-10-14.
- [Hex Grid & Terrain](PROJECT_SPEC.md#terrain), [arquitectura](PROJECT_SPEC.md#architecture) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance), consultados el 2026-10-14.

<a id='adr-0080'></a>
## ADR-0080 — Sprite vertical y tier visible en upgrade cards

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código integrado, aceptación visual pendiente.
- Amplía la presentación unificada de [ADR-0075](#adr-0075); mantiene una única superficie común y los iconos de efecto.

### Contexto

El usuario quiere cards de mejora verticales con el tier escrito, espacio perceptible entre opciones y un aura de rareza. Debe seguir existiendo un diseño compartido por todas las rarezas.

### Decisiones

1. Todas las ofertas usan la misma textura PNG vertical `game/ui/cards/upgrade_card_universal.png`, escalada con nueve cortes para conservar el contorno al variar el tamaño.
2. La card muestra su tier/rareza en texto dentro de la cabecera. El aura exterior comunica la rareza mediante color e intensidad; icono, título y descripción conservan el tratamiento común.
3. Las cards se separan con un pequeño espacio y se agrupan centradas en la oferta. No se seleccionan paneles, bordes ni fondos distintos por rareza.
4. El aura cambia solo la presentación; no altera la rareza, el contenido, el peso ni el efecto de la carta.

### Consecuencias

- `UpgradeOfferCard` combina un sprite común NinePatch, etiqueta de tier e icono de catálogo; el panel transparente dibuja el aura y su realce al hacer hover.
- La aceptación visual en ofertas de tres y seis opciones, con textos cortos y largos, sigue pendiente en M36 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- Petición explícita del usuario, 2026-10-14.
- [ADR-0075](#adr-0075), consultado el 2026-10-14.

<a id='adr-0081'></a>
## ADR-0081 — Mejoras permanentes H/A/S en ramas paralelas

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código y catálogo integrados, aceptación interactiva pendiente.
- Amplía el mapa de nodos de [ADR-0077](#adr-0077).

### Contexto

Al desbloquear una torre, el jugador debe poder escoger en qué orden mejora sus bonos de daño contra Health, Armor y Shield. Comprar una capa no debe bloquear las otras.

### Decisiones

1. Para cada torre, sus mejoras permanentes Health, Armor y Shield requieren únicamente el unlock permanente de esa torre.
2. Las tres mejoras son hermanas: no tienen requisitos mutuos ni orden obligatorio y pueden comprarse en cualquier orden. Comprar una no cambia el estado de disponibilidad de las otras.
3. El mapa dibuja las tres conexiones directamente desde el nodo de unlock de la torre. Se aplica a Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder.
4. Los requisitos secuenciales de otras ramas, como Main Tower Fortification I–X, no cambian.

### Consecuencias

- `PermanentUpgradeData.prerequisite_unlock_ids` mantiene el control del unlock de torre; las dependencias de compra entre cada trío H/A/S se eliminan del catálogo.
- El orden vertical de las tarjetas solo organiza el mapa, no expresa prerrequisitos.
- La comprobación de que los tres nodos se habiliten juntos y permanezcan disponibles tras una compra queda en M36 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- Petición explícita del usuario, 2026-10-14.
- [ADR-0077](#adr-0077), consultado el 2026-10-14.

<a id='adr-0082'></a>
## ADR-0082 — Tinte multiplicativo tenue por elevación

- Fecha: 2026-10-14
- Estado: Sustituido en intensidad y fórmula por [ADR-0099](#adr-0099); queda como historial de la primera implementación.
- Añade una señal de profundidad a las tapas del terreno sin cambiar el modelo 2D ni el orden de dibujo definido en [ADR-0073](#adr-0073) y [ADR-0079](#adr-0079).

### Contexto

La altura lógica ya desplaza las caras y dibuja fachadas, pero algunos niveles contiguos son difíciles de distinguir. Se pide un filtro multiplicativo muy tenue que preserve la textura y la vista isométrica.

### Decisiones

1. La modulación de las tapas escala el rojo por `1 − 0,01 × h` y el verde por `1 − 0,005 × h`; el azul permanece en 1. La altura usada se limita a 0–3.
2. Altura 0 conserva blanco. La misma función de `TerrainVisualCatalog` se usa para las tapas del preview y sus copias elevadas Y-sorted.
3. El tinte no cambia textura, UV, geometría, cámara, profundidad, navegación, alcance ni posición lógica. No se vuelve a introducir un overlay/shader de sombras.

### Consecuencias

- En altura 3 el multiplicador es `(0,97, 0,985, 1)`; el contraste es intencionalmente leve y la textura original debe seguir leyéndose.
- La aceptación visual debe comparar alturas 0–3 y verificar que no se deforman las texturas ni se altera la oclusión en M36 de `IMPLEMENTATION_AND_QA.md#acceptance`.

### Referencias

- Petición explícita del usuario, 2026-10-14.
- [ADR-0073](#adr-0073) y [ADR-0079](#adr-0079), consultados el 2026-10-14.

<a id='adr-0083'></a>
## ADR-0083 — Timeline fijo de quince rondas y preview fiel de terreno

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código integrado, aceptación visual pendiente.
- Sustituye la elección del tamaño de ventana de [ADR-0078](#adr-0078). Amplía la presentación de terreno de [ADR-0079](#adr-0079).

### Contexto

El selector 10/15 ocupa espacio y la vista de ofertas de terreno no comunica con fidelidad la forma, altura ni orden frontal de las piezas que se colocarán. El efecto es especialmente visible en la pieza `Camino serpenteante`, donde la variación de elevación puede cambiar incorrectamente qué hexágono tapa a otro.

### Decisiones

1. El timeline muestra siempre 15 de las 45 rondas y elimina el selector 10/15. La ronda actual queda al inicio de la ventana mientras haya espacio; al final de la campaña, el tramo visible se fija en 31–45 para conservar los 15 marcadores.
2. El timeline conserva sus tooltips, tamaños, colores, fade y datos de campaña. La cámara y el orden de las rondas no cambian.
3. Las cards de terreno representan la pieza de siete hexes con las mismas texturas superiores, UV hexagonales y fachadas texturadas cerradas que el tablero. Se conservan los obstáculos que ya pertenecen a la oferta.
4. El orden de las celdas del preview sigue la profundidad Y de su anclaje axial en el suelo. La elevación únicamente desplaza la superficie y determina el desnivel de la fachada; no altera la prioridad frontal.
5. Las alturas que se ven en la card son las de la copia de oferta que se coloca en el tablero. PATH permanece en altura 0; Grass y Mountain conservan los rangos vigentes de ADR-0073.

### Consecuencias

- `RoundProgressStrip` representa una ventana invariable de 15 puntos; entre las rondas 31 y 45 mantiene visible el tramo final completo.
- `TerrainPieceCardPreview` usa tapas hexagonales texturadas y fachadas con UV de escala estable y cierre de vértices, alineadas con el orden del renderer del tablero.
- La aceptación visual manual de timeline, alturas, solapamiento y continuidad de fachadas queda pendiente en M35.

### Referencias

- Petición explícita del usuario y captura de ofertas de terreno, 2026-10-14.
- [Diseño activo](PROJECT_SPEC.md#game-design), [terreno](PROJECT_SPEC.md#terrain), [arquitectura](PROJECT_SPEC.md#architecture) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance), consultados el 2026-10-14.

<a id='adr-0084'></a>
## ADR-0084 — Retícula axial compartida y profundidad de fachadas por celda

- Fecha: 2026-10-14
- Estado: Aceptado parcialmente; la retícula axial y las claves de vértice siguen vigentes. La selección de fachadas se concreta en [ADR-0085](#adr-0085) y la altura expuesta/visibilidad de tapas en [ADR-0090](#adr-0090).
- Amplía el renderer 2D de [ADR-0043](#adr-0043) y [ADR-0079](#adr-0079). Conserva la elevación lógica, el movimiento axial, los UV y la cámara fija definidos por [ADR-0073](#adr-0073).

### Contexto

La revisión de una captura real mostró dos fallos que sobrevivieron al primer arreglo: fachadas elevadas podían quedar tapadas demasiado pronto por tapas dibujadas en una pasada global posterior, y algunas uniones seguían mostrando huecos. La causa era una combinación de fases de dibujo separadas y vértices calculados individualmente con seno/coseno, mientras las tapas, miniaturas, copias Y-sorted y cierres de esquina no compartían una única clave geométrica.

### Decisiones

1. `HexMath` es la autoridad de los vértices pointy-top y del desplazamiento vertical visual de 28 px por nivel. Calcula cada esquina desde una clave entera de la retícula axial; dos celdas que comparten vértice obtienen el mismo punto de pantalla sin redondeos ni trigonometría independiente.
2. Tablero, ghost, miniaturas, hover y copias elevadas usan esta función geométrica común. La elevación solo desplaza la superficie en pantalla; no cambia coordenada axial, ocupación ni orden del grid.
3. La regla histórica de fachadas expuestas y cierres locales quedó ajustada por ADR-0085 y ADR-0090: cada fachada delantera termina a la altura de la tapa vecina, y la tapa hexagonal no puede quedar cubierta por esa pared.
4. La profundidad de una fachada es `max(altura_celda − altura_vecina, 0) × 28 px`. En miniaturas o bordes de pieza sin vecina se usa altura 0. Se conservan los PNG intercambiables y el mapeo UV que repite el patrón con densidad estable.
5. Una tapa sigue siendo un polígono de seis vértices con UV propios. No se deforma la textura en un rectángulo para compensar la elevación. La cámara top-down isométrica permanece fija y las fachadas continúan debajo de actores/props.

### Consecuencias

- La geometría base del tablero ya no depende de aproximaciones trigonométricas separadas entre celdas; los vértices compartidos se identifican en el espacio axial entero.
- Se unifica el orden de terreno del tablero y de las cards, con el painter pass intercalando pared y tapa por celda según la profundidad del grid.
- La regla de elevación y el bonus de torre no cambian. La aceptación visual sigue pendiente hasta recorrer alturas 0–3, desniveles mixtos y vértices aislados en la escena.
- El punto 6 de [ADR-0079](#adr-0079), que agrupaba puntos redondeados en pantalla, queda sustituido para el renderer de fachadas. Sus límites de obstáculos y demás decisiones siguen vigentes.

### Referencias

- Petición explícita y captura adjunta del terreno con fachadas truncadas y vértices abiertos, 2026-10-14.
- [Hex Grid & Terrain](PROJECT_SPEC.md#terrain), [arquitectura](PROJECT_SPEC.md#architecture) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance), consultados el 2026-10-14.

<a id='adr-0085'></a>
## ADR-0085 — Solo fachadas delanteras y degradado de cliffs

- Fecha: 2026-10-14
- Estado: Aceptado parcialmente. La selección de fachadas delanteras y el degradado siguen vigentes; el tramo de pared hasta el suelo y la regla de oclusión por tapas quedan sustituidos por [ADR-0090](#adr-0090). Los tintes inferiores aquí descritos quedaron sustituidos por [ADR-0121](#adr-0121). La inspección visual completa sigue pendiente.
- Ajusta la presentación 2D de elevación de [ADR-0084](#adr-0084). Conserva la retícula axial, el orden por celda y la cámara fija.

### Contexto

Las capturas mostraron tiras de color y vértices laterales que aparecían al cerrar esquinas con polígonos añadidos y al dar profundidad radial a paredes casi paralelas a la extrusión vertical. El usuario pidió que no se dibuje profundidad en los laterales del hex, que se conserve la silueta axial y que Grass/Mountain tengan un degradado oscuro hacia abajo solo en sus fachadas.

### Decisiones

1. En el hex pointy-top actual, solo las aristas axiales 1 y 2 son fachadas delanteras. Únicamente esas dos aristas generan paredes; las dos laterales y las dos traseras no producen geometría de altura.
2. Cada fachada es un quad cuyos dos vértices inferiores son la copia vertical de la arista superior. Su extensión vertical se limita a la diferencia de altura con la celda vecina; si no hay celda, llega hasta el suelo. El detalle vigente está en ADR-0090. No se añade espesor lateral, desplazamiento radial, triángulo de cierre ni ningún vértice de unión.
3. La tapa superior conserva sus seis vértices axiales completos y ninguna pared se prolonga por encima de ella. El anclaje Y-sorted de cada fachada coincide con su borde inferior; la profundidad resultante se describe en ADR-0090.
4. `TerrainVisualCatalog` mantiene las texturas PNG actuales de Grass/Mountain y define un tinte inferior multiplicativo para cada material. Los valores `#263b2b` para Grass y `#24242a` para Mountain describen una paleta histórica, sustituida por los tonos y gradiente de ADR-0121. La tapa superior, sus UV y sus tintes por elevación no cambian en este ADR.
5. El mismo trazado de dos fachadas y el mismo degradado se usan en el tablero, ghost y miniaturas. La escala UV se deriva del largo de la arista y de la elevación renderizada para que la textura no se estire.

### Consecuencias

- Se elimina del renderer toda fuente de paredes laterales, tapas de esquina y parches sólidos marrones; las esquinas visibles resultan únicamente de las dos fachadas que comparten los vértices axiales de la tapa.
- La elevación se representa como terreno 2D con falsa profundidad, no como un prisma cerrado. Las cuatro caras que el usuario no quiere ver quedan fuera del render. El cálculo de la parte visible de las paredes se sustituye por ADR-0090.
- La inspección visual inicial en Godot 4.7 no encontró errores GDScript/runtime. La aprobación visual inicial quedó limitada por la petición posterior de conservar siempre completas las tapas hexagonales; esa corrección se registra en ADR-0090. Falta revisar manualmente alturas 1–3, vecinos con elevaciones distintas y zoom alto.
- Para el contrato completo de alturas y bonos de torre sigue vigente [ADR-0073](#adr-0073); este ADR solo cambia la representación de las paredes.

### Referencias

- Petición explícita y capturas del terreno con defectos en las esquinas laterales, 2026-10-14.
- [Hex Grid & Terrain](PROJECT_SPEC.md#terrain), [arquitectura](PROJECT_SPEC.md#architecture), [progreso](IMPLEMENTATION_AND_QA.md#progress) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance), consultados el 2026-10-14.

<a id='adr-0086'></a>
## ADR-0086 — Oferta de cards y cierre de derrota

- Fecha: 2026-10-14
- Estado: Correcciones integradas; smokes de UI, M4, M5 y M6 pasan en Godot 4.7. La aceptación interactiva de campaña completa sigue pendiente.
- Relacionado: [M11 Cards](IMPLEMENTATION_AND_QA.md#roadmap), [M38 fachadas delanteras](#adr-0085).

### Contexto

Al completar nueve rondas no aparecía la selección de mejoras. El log mostraba `No se pudo crear oferta M11:` sin detalle. `RunCardService` devolvía las tres opciones configuradas correctamente, pero `Main` solo las aceptaba si la lista llenaba las seis ranuras máximas del panel. La comparación confundía el tamaño de la oferta con la capacidad de la interfaz y hacía avanzar la campaña sin elección.

Al perder, `_show_run_end` cambiaba de escena y `_on_wave_failed` continuaba actualizando la colocación en la escena que se desmontaba. El preview consultaba la posición del ratón con su `Viewport` ya desconectado.

### Decisiones

1. La cantidad de cartas se valida contra la capacidad máxima del panel: una oferta válida no vacía de hasta seis opciones se presenta, aunque use menos ranuras. El tamaño por defecto sigue siendo tres y Card Draw puede ampliarlo.
2. La ruta de oferta programada se resuelve antes de preparar la siguiente ronda. Si no se puede crear una oferta válida, se conserva el bloqueo de la ronda y se muestra el motivo; nunca se omite silenciosamente la selección obligatoria.
3. La derrota es terminal para `Main`: después de solicitar el cambio al menú, no se ejecutan actualizaciones de HUD/preview. El preview comprueba que sigue dentro del árbol y tiene un `Viewport` antes de consultar el ratón.
4. El aspecto del terreno de M38 aprobado por el usuario se conserva como referencia visual en ADR-0085; esta corrección no cambia el renderer.

### Consecuencias

- `ui_migration_smoke` comprueba que las ofertas configuradas de tres cartas en las rondas 3, 6 y 9 entran en `CARD_OFFER` y muestran tres cards pese a las seis ranuras disponibles; también llama al preview separado del árbol para cubrir la guarda de `Viewport` nulo.
- Los smokes M4, M5 y M6 se ejecutaron correctamente tras alinear sus expectativas de fase y el límite de mejora de su fixture con el comportamiento vigente.
- La aceptación completa de M11 sigue requiriendo jugar la campaña y comprobar rondas 3, 6, 9 y 42, filtros de cartas y efectos.
- El flujo de derrota deja de llamar al preview tras iniciar el cambio de escena; la guarda del preview también cubre llamadas tardías.

### Referencias

- Reporte de juego del usuario: oferta ausente tras nueve rondas y error de `get_viewport()` al perder, 2026-10-14.
- [Diseño de cartas](PROJECT_SPEC.md#game-design), [aceptación M11/M38](IMPLEMENTATION_AND_QA.md#acceptance), [progreso](IMPLEMENTATION_AND_QA.md#progress).

<a id='adr-0087'></a>
## ADR-0087 — Props, obstáculos y altura junto a base

- Fecha: 2026-10-14
- Estado: Aceptado; código y assets integrados, aceptación visual pendiente.
- Ámbito: renderer de terreno, generación de contenido visual por celda, recursos de base y documentación activa.

### Contexto

La base usa un sprite de resolución original, y su anillo de seis hexes debe conservar un perfil bajo para mantener legible el acceso. Los props disponibles llegaron agrupados por terreno, mientras los obstáculos nuevos vivían en una carpeta separada y tenían tamaños/rutas distintas al pool runtime anterior. La presentación previa también desplazaba obstáculos hacia abajo. Se requiere una nomenclatura uniforme, contenido decorativo reproducible y un único comportamiento visual coherente en miniatura, ghost y tablero.

### Decisión

1. Las seis celdas axialmente adyacentes a Main Tower tienen elevación máxima 1. PATH conserva elevación 0; Grass queda en elevación 1; una Mountain generada para una celda vecina se normaliza a Grass. La validación inicial también rechaza una celda de base vecina por encima de 1. El ghost aplica la misma conversión y enseña esa altura antes de confirmar.
2. El sprite de la base se dibuja a escala 1:1. Se elimina el tamaño configurable que permitía deformarlo; el asset actual mide 352×352 px.
3. Cada PNG de props se nombra `prop_<terreno>_<elemento>.png` y se prepara a 96×96 px con transparencia. Cada asset compatible con el terreno realiza un roll independiente de 5 % en cada celda; se permiten hasta dos IDs distintos por celda. La selección se hace determinísticamente por la seed y la identidad de celda/oferta; el límite se aplica después de los rolls. Si el terreno se normaliza junto a la base, se regeneran los props desde el catálogo del tipo resultante y se comparte la misma tirada entre ghost y tablero confirmado. Los props solo son decoración, no tienen input/hitbox ni efectos, y no se colocan superpuestos entre sí.
4. Los props aparecen en Path, Grass o Mountain de su carpeta y se muestran a 30×30 px. La oferta se conserva entre miniatura, ghost y tablero; si la colocación cae en el anillo de base y Mountain se normaliza a Grass, el ghost y el tablero regeneran juntos los props compatibles con Grass a partir de la coordenada global. La miniatura, al no tener ancla, conserva el terreno/props ofertados. Se dibujan debajo del obstáculo.
5. Los cinco obstáculos anteriores se sustituyen por ocho assets, renombrados `obstacle_<nombre>.png`, ubicados directamente en `assets/terrain/obstacles/` y preparados a 208×208 px, igual que la resolución fuente anterior. En tablero/miniatura se muestran en caja de 86×86 px, centrados en la celda y por delante de props. La probabilidad y la lógica de bloqueo/retirada no cambian.
6. Se eliminan las imágenes antiguas, sidecars y referencias runtime; la herramienta de preparación de arte ya no regenera la lista anterior.

### Consecuencias

- La elevación junto a base queda acotada sin cambiar las reglas aleatorias de las demás celdas.
- Los props siguen siendo decorativos y no alteran ocupación, construcción, navegación, obstáculos ni cofres.
- El resultado de prop y obstáculo se transfiere sin nueva aleatoriedad entre preview y tablero confirmado.
- Los nombres visibles de obstáculos y las rutas se enumeran en [Nomenclatura](CONTENT_AND_ASSETS.md#canonical-names) y [README de assets](CONTENT_AND_ASSETS.md#sprite-catalog); esta ADR y esas páginas enlazan el criterio activo.
- La inspección visual en ventana de posiciones, escalas y capas continúa pendiente; no se declara aceptación de arte.

### Decisiones relacionadas

- [ADR-0079](#adr-0079): límites de cantidad de obstáculos.
- [ADR-0084](#adr-0084) y [ADR-0085](#adr-0085): renderer axial, fachadas y profundidad.
- Sustituye el catálogo de assets/props de las versiones anteriores de ADR-0040, ADR-0044, ADR-0058 y ADR-0060; mantiene sus reglas de obstáculos, cofres y ofertas que no se contradicen aquí.

<a id='adr-0088'></a>
## ADR-0088 — Presentación compacta de upgrade cards

- Fecha: 2026-10-14
- Estado: Aceptado; escena y shader integrados, aceptación visual pendiente.
- Ámbito: presentación de ofertas de mejora temporales durante una run.

### Contexto

La presentación anterior seguía usando un panel vertical NinePatch que ocupaba demasiado espacio y restaba legibilidad a las opciones. La referencia aportada muestra tres opciones claramente separadas, iconos grandes y una iluminación suave asociada a la rareza. El diseño debe mantener el contenido funcional de cada card y no requerir assets de borde distintos.

### Decisión

1. Todas las `UpgradeOfferCard` comparten una superficie plana y una única estructura; no se usan sprites de marco/fondo ni variantes visuales por rareza. Se retira `upgrade_card_universal.png`.
2. La oferta base muestra tres cards en una fila centrada, con una separación visible. Cuando Card Draw amplía la oferta hasta seis, se conservan tres columnas y se distribuye el resto en una segunda fila.
3. Cada card muestra tier/rareza como texto, icono grande, título y descripción. El panel debe dejar legibles estos elementos y permitir que el botón completo reciba la interacción.
4. Un shader procedural dibuja un aura radial detrás de la superficie común, con destellos/partículas animadas. El color expresa rarity (Common gris, Uncommon verde y Rare azul); el hover solo refuerza el aura y la superficie no cambia por rareza.
5. La oferta conserva los efectos, orden, rareza y reglas de selección definidos por el catálogo y `RunCardService`; esta decisión afecta solo la presentación.

### Consecuencias

- La forma del panel no compite con el contenido ni con el tablero, y los efectos de rareza quedan limitados a una capa de aura.
- No se necesitan texturas PNG de card. El shader y la escena son la fuente visual común.
- La presentación de M36 con sprite vertical se sustituye; siguen vigentes la etiqueta de tier, las ramas paralelas H/A/S de ADR-0081 y el tinte de altura de ADR-0082.
- Tamaño final, legibilidad, intensidad del aura, animación y clicabilidad requieren aceptación manual en ventana; no se declara aceptación visual todavía.

### Decisiones relacionadas

- [ADR-0075](#adr-0075): panel único y aura por rareza.
- [ADR-0080](#adr-0080): sprite/tier previo, sustituido solo en su presentación de marco.
- [ADR-0081](#adr-0081): ramas de mejoras permanentes, no afectadas por esta ADR.

<a id='adr-0089'></a>
## ADR-0089 — Ajustes de escala, oclusión, portales y props

- Fecha: 2026-10-14
- Estado: Aceptado parcialmente; portales y props siguen vigentes. La regla de escala visual de la base fue sustituida por [ADR-0096](#adr-0096); el alcance geométrico de fachadas y tapas se ajusta por [ADR-0090](#adr-0090). Aceptación visual pendiente.
- Decisión de usuario: mensaje del 2026-10-14 en esta conversación
- Sustituye parcialmente: [ADR-0055](#adr-0055) (tamaño de portal) y [ADR-0087](#adr-0087) (tamaño de base y parámetros de props)

### Contexto

La resolución fuente de la base se había confundido con su tamaño dibujado. La oclusión actual dejaba las fachadas elevadas en una capa fija detrás de los enemigos. El usuario también indicó que los portales debían animarse con el spritesheet ya presente en el proyecto y que los props eran demasiado pequeños y poco frecuentes. `TerrainPiecePreview` tenía además una llamada multilínea en el anillo de base que impedía cargar la clase en el editor informado por el usuario.

### Decisiones

1. `assets/base/main_tower.png` conserva su PNG original de 270×352 px. La escala uniforme de hasta 86×86 px fue la regla anterior; ADR-0096 la sustituye por una presentación estirada más alta sin cambiar la celda lógica.
2. Cada fachada expuesta obtiene un nodo propio bajo `Entities.y_sort_enabled`, anclado en su borde inferior para ocluir actores detrás y quedar detrás de actores delante. La altura de la pared y la prioridad completa de las tapas se definen en ADR-0090.
3. `spawn_portal_SpriteSheet.png` se interpreta como ocho frames de 443×443 px en una cuadrícula 4×2. Los portales animan los ocho frames en bucle continuo a 10 FPS. Cada endpoint recibe y conserva una fase determinista única durante la run; añadir o retirar otros endpoints no reinicia la animación ya visible. `spawn_portal.png` permanece como icono estático del panel de selección.
4. Los props compatibles con cada terreno tienen un 10 % de probabilidad independiente por asset y celda, mantienen un máximo de dos elementos únicos y pasan de 30×30 a 36×36 px. Sus offsets se separan para que dos props no se solapen; un obstáculo sigue dibujándose delante.
5. La asignación de variante visual y props al anillo de base se expresa con llamadas simples en `_apply_base_ring_elevation`, eliminando la indentación que impedía analizar el script.

### Consecuencias

- La resolución de imagen y el tamaño visual de la base quedan documentados como valores distintos.
- Los actores y las fachadas comparten el orden Y de `Entities`; las miniaturas y ghosts conservan el render de preview.
- Los valores de props y la animación de portales quedan centralizados en el código de terreno/portal y descritos en la página activa [Hex grid y terreno](PROJECT_SPEC.md#terrain).
- La implementación está integrada, pero necesita aceptación visual en ventana, especialmente para la oclusión de enemigos detrás/delante y la continuidad del atlas animado.

### Fuentes

- Solicitud directa del usuario, 2026-10-14.
- PNGs del proyecto: `assets/base/main_tower.png`, `assets/terrain/spawn_portal_SpriteSheet.png` y `assets/terrain/spawn_portal.png`.

<a id='adr-0090'></a>
## ADR-0090 — Fachadas limitadas a la diferencia de elevación

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; implementación integrada, aceptación visual en Godot pendiente.
- Ajusta la geometría de fachadas de [ADR-0085](#adr-0085). Mantiene la retícula, el material y las dos direcciones delanteras.

### Contexto

La captura más reciente muestra fachadas opacas y continuas, pero algunas se dibujan por encima de las tapas hexagonales vecinas. Las tapas deben conservar siempre su polígono axial completo. El terreno sigue siendo 2D con elevación visual; no se introducen sólidos 3D.

### Decisiones

1. Una fachada delantera solo dibuja la parte expuesta entre la elevación de su hexágono y la elevación del hexágono que comparte ese borde. La altura visible es `max(elevación_actual − elevación_vecina, 0) × 28 px`.
2. Si no hay celda vecina, se considera elevación 0 y la fachada llega al suelo. A igual altura no se dibuja pared entre las tapas; si la celda vecina está más alta, no se dibuja pared desde la celda baja.
3. El borde inferior de cada quad coincide con la arista superior de la celda vecina (o con el suelo). La pared conserva textura opaca y degradado, pero nunca ocupa el interior de una tapa hexagonal. Cada arista delantera tiene su ancla Y-sort en ese borde inferior.
4. La misma regla geométrica se aplica al tablero confirmado, el ghost y las miniaturas. Las tapas siguen siendo polígonos cerrados de seis vértices calculados desde la retícula axial común.
5. Se mantienen las aristas delanteras 1 y 2, sin caras laterales/traseras, espesor radial ni cierres de esquina.

### Consecuencias

- Las caras superiores vuelven a mostrar la silueta hexagonal completa aunque una pared vecina atraviese su zona proyectada.
- Las paredes siguen siendo sólidas en la altura realmente expuesta; las fachadas entre hexágonos contiguos a igual altura desaparecen como corresponde a una superficie continua.
- La textura de pared se escala según la altura visible y el Y-sort puede resolver cada borde por separado.
- Falta inspeccionar en Godot 4.7 alturas 1–3, vecinos a la misma altura, desniveles mixtos, borde vacío, ghost y miniaturas. Esta decisión no se considera aceptación visual.

### Referencias

- Petición explícita y captura adjunta sobre tapas hexagonales cubiertas por paredes, 2026-10-14.
- [Hex Grid & Terrain](PROJECT_SPEC.md#terrain), [aceptación](IMPLEMENTATION_AND_QA.md#acceptance) y ADR-0085, consultados el 2026-10-14.

<a id='adr-0091'></a>
## ADR-0091 — Contornos compartidos por región de terreno y elevación

- Fecha: 2026-10-14
- Estado: Geometría/agrupación aceptadas y vigentes; la paleta y el estilo del trazo fueron sustituidos parcialmente por ADR-0095. Aceptación visual pendiente.
- Alcance: presentación 2D de celdas del tablero y miniaturas de piezas.
- Sustituye: no sustituye decisiones anteriores; añade una regla visual al renderer de terreno.

### Contexto

El usuario pide que las celdas del mismo nivel no muestren un borde individual por hexágono. Cada región debe leerse como una forma continua, con su color asociado al tipo de terreno. La elevación y la lectura de qué región queda delante o detrás deben seguir la geometría axial y el orden visual existentes.

### Decisiones

1. Una región está formada por celdas conectadas con el mismo tipo de terreno y la misma elevación lógica.
2. No se dibujan aristas internas entre vecinos de la misma región. Se dibuja cada arista que limita con otra región o con una coordenada vacía; el vacío cuenta como elevación 0 para esta silueta visual.
3. En una frontera entre regiones, ambos lados conservan su propio trazo, desplazado ligeramente hacia dentro de su tapa: verde para Grass, gris para Mountain y amarillo para Path.
4. Las tapas superiores permanecen hexagonales y completas. El contorno se coloca sobre las superficies, respeta las elevaciones y copias superiores Y-sorted, y no altera fachadas, selección, conectividad, ocupación ni navegación.
5. Tablero, superficies elevadas, preview y miniaturas usan la misma regla. El hover puede seguir resaltando temporalmente su celda y sus anillos, y el ghost conserva los colores de validez de colocación.

### Consecuencias

- Las superficies amplias de un mismo terreno/altura se leen como una sola región y pierden la retícula interna persistente.
- Cambios de tipo o elevación quedan visibles incluso cuando las celdas comparten la misma altura.
- Los bordes contra vacío cierran la silueta exterior de cada región.
- Se requiere una revisión visual de juntas, grosor de trazo, miniaturas y oclusión con alturas 1–3.

### Referencias

- [Diseño de terreno hexagonal](PROJECT_SPEC.md#terrain)
- [Aceptación visual M42](IMPLEMENTATION_AND_QA.md#acceptance)

<a id='adr-0092'></a>
## ADR-0092 — Pulido visual y raíz común de sprites

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita del usuario; código y recursos integrados, aceptación visual pendiente.
- Alcance: dibujo de torres, contorno de terreno, fachadas Grass/Mountain, escala de props/obstáculos, animación/interacción de portales y organización de assets.
- Sustituye: parámetros de presentación de sprites descritos en ADR-0087 y ADR-0089; mantiene las reglas de elevación, Y-sort y fachadas de ADR-0084/0085/0090 y la silueta regional de ADR-0091.

### Contexto

El usuario pidió centrar las torres en su hexágono y ampliar su presentación un 20 %, suavizar las uniones del perímetro, hacer coincidir el tono superior de las fachadas con Grass/Mountain, ampliar props y obstáculos un 10 %, eliminar el cuadro duplicado del loop del portal, limpiar tooltips cuando desaparece un portal y reunir los sprites dispersos en una única raíz.

### Decisiones

1. Las torres y su ghost usan la misma coordenada axial central. El arte conserva su ancla inferior centrada en la tapa; el tamaño visible se multiplica por 1,2 y el pequeño ajuste de arte pasa de 6 a 8 px para mantener el apoyo centrado después de escalar. No cambia ocupación, alcance, daño, hitbox ni selección.
2. Los segmentos de contorno del tablero, las superficies elevadas, el hover y las miniaturas terminan con uniones redondeadas que rellenan los huecos en los vértices. Las fronteras de región y sus colores siguen ADR-0091.
3. `grass_cliff_face.png` usa el tono base dominante de Grass (`#53B56F`) y `mountain_cliff_face.png` el de Mountain (`#8A8B91`). El degradado oscuro de vértice continúa solo hacia la parte baja de las fachadas; las tapas no se modifican.
4. Props pasan de 36 a 39,6 px y obstáculos de 86 a 94,6 px de caja visual. Sus PNG fuente, probabilidades, distribución determinista, límite de dos props y orden (props detrás de obstáculos) permanecen iguales.
5. El portal conserva su atlas 4×2 y recorre solo los frames 0–6. El frame 7, idéntico al frame 0, no participa en el loop. El desfasado por endpoint permanece igual.
6. Un portal limpia su estado de hover y notifica su salida antes de `queue_free`; el cierre de una salida oculta su tooltip inmediatamente, antes de que aparezcan cards.
7. Todos los sprites del proyecto, incluidos iconos de interfaz, enemigos, terreno, obstáculos, props, portales y sprites de Tiny Swords, viven bajo `assets/sprites/` con subcarpetas por categoría. Se trasladan sus sidecars `.import` y se actualizan las rutas de código, Resources, escenas y herramientas. El contenido Tiny Swords sigue ignorado por Git por su restricción de redistribución. Tipografías y fuentes/previas de `art_generation/` no son sprites runtime y conservan su ubicación.

### Consecuencias

- Los iconos colocados y el ghost usan una escala compartida de torre, evitando discrepancias al construir.
- Los trazos de terreno se conectan en los vértices sin cortar el perímetro de regiones.
- Las fachadas mantienen el degradado inferior y su extremo superior adopta el color del terreno correspondiente.
- Las cajas de decoración ocupan más superficie, pero no cambian la lógica hexagonal ni las probabilidades.
- Se rompe la ruta antigua de los sprites; el proyecto y las herramientas apuntan a `assets/sprites/` y deben seguir usando esa raíz.
- La revisión visual en Godot queda pendiente; no se ejecutó una sesión de juego en esta actualización.

### Referencias

- [Fuente de verdad de diseño](PROJECT_SPEC.md#game-design)
- [Grid hexagonal y terreno](PROJECT_SPEC.md#terrain)
- [Aceptación M43](IMPLEMENTATION_AND_QA.md#acceptance)
- [Catálogo central de sprites](CONTENT_AND_ASSETS.md#sprite-folders)
- [Catálogo de sprites de terreno](CONTENT_AND_ASSETS.md#sprite-catalog)

<a id='adr-0093'></a>
## ADR-0093 — Preview exacto, oferta fija y torres articuladas

- **Estado:** preview/oferta/contornos siguen vigentes; la decisión de torre articulada quedó sustituida por ADR-0100.
- **Fecha:** 2026-10-14.
- **Contexto:** las celdas del ghost podían tener alturas y contenido distintos a los de la colocación confirmada. Los contornos de regiones conservaban colores neón y pequeños insets que separaban juntas. El servicio de cartas podía ampliar la oferta por encima de tres. El arte nuevo de torres incluye una base y una cabeza separadas que deben poder girar por separado.
- **Decisiones:**
  1. `Main` crea un snapshot determinista del tablero candidato para la selección actual y entrega el mismo snapshot al preview y a la confirmación. Los auto-rellenos también se generan con semilla/coordenada deterministas.
  2. Los límites de regiones usan los vértices axiales exactos, sin inset; las uniones se redondean con extremos circulares compartidos. Grass toma `#53B56F`, Mountain `#8A8B91` y Path conserva el amarillo configurado.
  3. `CardPoolData`, `RunCardService`, `UpgradeOfferPanel` y `Main` fijan exactamente tres opciones y tres botones seleccionables. Los reclutamientos elegibles se mezclan con las mejoras; las cartas no elegidas permanecen elegibles para rondas siguientes. El nodo permanente `card_draw` se retira de la tienda y su ID permanece en el catálogo solo para compatibilidad con perfiles guardados.
  4. Las siete imágenes nuevas sustituyen sus iconos canónicos. `TowerArtCatalog` crea regiones `AtlasTexture` para una base fija y una cabeza rotatoria cuyo pivote se alinea con la unión de la base. El ghost reutiliza las mismas partes.
  5. Un shader alfa de `CanvasItem` dibuja un contorno blanco por Sprite2D en las bases/cabezas de torre y obstáculos. Esto conserva su orden de profundidad individual y evita agruparlos en `CanvasGroup`.
  6. El asset proporcionado como séptima torreta se asigna a Shredder, porque ese es el séptimo tipo del roster canónico y no existe una torre Raider en el proyecto.
- **Consecuencias:** preview y estado confirmado comparten elevación, variantes, obstáculos, props, cofres y auto-rellenos; todas las ofertas mantienen un panel de tres opciones y no dejan botones extra seleccionables; las torres pueden seguir visualmente la dirección de sus objetivos; los objetos interactuables tienen un borde legible. El panel no cambia de rareza ni de tamaño.
- **Nota de vigencia:** las decisiones originales 4–5 describen el montaje anterior de partes articuladas. ADR-0100 lo reemplaza por una única textura y un único Sprite2D con espejo horizontal.
- **Validación:** no se ejecutó Godot ni la inspección visual/manual en esta actualización. Ver criterios M44 en [`IMPLEMENTATION_AND_QA.md#acceptance`](IMPLEMENTATION_AND_QA.md#acceptance).
- **Referencias:** imágenes de torre aportadas por el usuario y actualmente localizadas bajo `assets/sprites/ui/icons/`; [Canvas Group Outline — Godot Shaders](https://godotshaders.com/shader/canvas-group-outline/), consultado 2026-10-14. El shader del proyecto implementa la dilatación alfa para sprites individuales; no copia el código publicado.
- **Sustituye:** cualquier comportamiento de Card Draw que aumentase las ofertas por encima de tres y las reglas visuales anteriores de color/inset del contorno. La paleta/estilo de trazo vigentes quedan sustituidos parcialmente por ADR-0095. Complementa ADR-0084, ADR-0091 y ADR-0092.

<a id='adr-0094'></a>
## ADR-0094 — Mapa de mejoras y legibilidad del terreno

- **Estado:** aceptado e implementado en código; la paleta y el estilo de trazo del contorno fueron sustituidos parcialmente por ADR-0095. Aceptación visual/interactiva pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** la tienda de permanentes todavía mostraba instrucciones y un botón de nueva run en el pie. El árbol era demasiado compacto, las mejoras de torre se apilaban en vertical y no había navegación por arrastre. También se pidió recuperar fachadas oscuras y el contorno cromático regional sin el hover de alta intensidad.
- **Decisiones:**
  1. La tienda no contiene controles para iniciar una run ni instrucciones en el pie. El menú conserva “Empezar run”; el mapa tiene un cierre × fijo arriba a la derecha. Desde el menú o al revisar una run terminada, cerrar el panel vuelve a dejar visible el menú principal; desde acceso DEBUG, lo cierra y revela el tablero.
  2. El mapa crece a 3560×2020 unidades lógicas con clusters separados y nodos de 236×254. La rueda conserva scroll; mantener y arrastrar con botón izquierdo (umbral 8 px) o central desplaza el área. Cada nodo usa su icono canónico del `IconCatalog`, con un icono de daño como fallback.
  3. El unlock de cada torre conecta a tres mejoras hermanas H/A/S, dispuestas en una misma fila horizontal. El catálogo, las dependencias y los costes no cambian. Los tooltips conservan el detalle completo y los requisitos.
  4. El sprite de cada torre crece linealmente por nivel: nivel 1 usa la escala base y las 45 mejoras posibles alcanzan como máximo +12 %. Se aplica a sprites únicos y a los componentes divididos; no altera stats, alcance ni celda ocupada. El máximo es un parámetro visual provisional.
  5. Las fachadas siguen siendo únicamente las dos caras delanteras y mantienen sus quads axiales. Se les aplica un tinte multiplicativo oscuro por dirección (`#666A70` y `#7A7E84`) y se conserva un gradiente inferior más oscuro. No se añaden caras laterales, cierres ni vértices.
  6. El perímetro exterior sigue agrupando por `(terrain_type, elevation)`, omite aristas internas y comparte vértices redondeados. Grass usa stroke `#53B56F`, Mountain `#8A8B91` y Path mantiene amarillo. ADR-0095 sustituye estos tonos y elimina el keyline oscuro; la regla geométrica permanece vigente.
- **Consecuencias:** el mapa se navega como un árbol amplio, se identifican visualmente las mejoras H/A/S y cada torre muestra crecimiento acumulativo discreto. La silueta hexagonal y la regla de dos caras delanteras no cambian; las imágenes de pared conservan su textura con más contraste.
- **Validación:** no se ejecutó Godot ni se hizo inspección visual/interactiva. Ver criterios de M45 en [`IMPLEMENTATION_AND_QA.md#acceptance`](IMPLEMENTATION_AND_QA.md#acceptance).
- **Sustituye:** los textos de tienda y criterios visuales anteriores incompatibles con el mapa limpio, el arrastre, la fila H/A/S, el sombreado direccional oscuro y el hover atenuado; actualiza parcialmente el tono de fachadas de ADR-0092 y, hasta que ADR-0095 lo sustituye, los colores de contorno de ADR-0093. Complementa ADR-0077, ADR-0081 y ADR-0091.

<a id='adr-0095'></a>
## ADR-0095 — Contorno regional de terreno de un solo tono

- **Estado:** aceptado por petición explícita del usuario; código/documentación integrados, aceptación visual pendiente.
- **Fecha:** 2026-10-14.
- **Alcance:** stroke regional de las tapas de terreno en tablero, copias elevadas, previews y miniaturas.
- **Nombre canónico:** **contorno de región de terreno** (clase runtime `TerrainRegionOutline`).

### Contexto

El contorno anterior dibujaba una línea oscura más ancha debajo del stroke de terreno. El resultado parecía tener un reborde exterior y una franja interior más clara. El usuario pidió un aspecto más oscuro y uniforme e indicó tonos exactos para Grass y Mountain.

### Decisiones

1. Se conserva la agrupación por `(terrain_type, elevation)`, la malla axial compartida, la omisión de aristas internas y los extremos/uniones redondeados. Estas reglas geométricas de ADR-0091 siguen vigentes.
2. El **contorno de región de terreno** se dibuja con un solo stroke opaco por arista, sin keyline exterior ni segunda línea o relleno de otro color. Grass usa `#406e4d`; Mountain usa `#646567`.
3. Path conserva el amarillo configurado. El hover puede variar la opacidad, pero mantiene el mismo RGB de cada terreno.
4. No se modifican las texturas de las tapas, el sombreado de fachadas, la cámara ni la geometría hexagonal.

### Consecuencias

- Las regiones siguen conectándose visualmente sin retícula interior, pero sus bordes son más oscuros y uniformes.
- Tablero, superficie elevada, hover y miniaturas continúan usando el mismo helper para evitar diferencias entre vistas.
- La apariencia debe aceptarse visualmente en Godot; el cambio no se considera validado solo por integrar el código.

### Sustituye

El color/keyline de ADR-0091, ADR-0093 y ADR-0094 queda sustituido parcialmente. Se conservan su agrupación, límites, geometría y uniones redondeadas.

<a id='adr-0096'></a>
## ADR-0096 — Sprite de base más alto y visible

- **Estado:** aceptado por petición explícita del usuario; código/documentación integrados, aceptación visual pendiente.
- **Fecha:** 2026-10-14.
- **Alcance:** representación visual del sprite de `GameBase`.
- **Parámetros:** provisionales hasta la revisión visual.

### Contexto

El usuario quiere localizar la base con más facilidad y pidió hacer el sprite más grande y alto. Autorizó estirarlo aunque pierda su proporción mientras se calibra el tamaño definitivo.

### Decisiones

1. El PNG fuente de 270×352 px no se remuestrea ni reemplaza.
2. Para `footprint_radius = r`, el sprite se dibuja en una caja de `1.8r` de ancho por `2.8r` de alto mediante escalas X/Y independientes. Con el radio actual de 52 px equivale aproximadamente a 94×146 px.
3. El centro visual sube la mitad del incremento de altura para conservar fijo el borde inferior del sprite. La base queda más alta hacia arriba y no cambia la celda que ocupa.
4. La huella lógica, las reglas, las colisiones, la vida y el Y-sort del nodo de base no cambian. La deformación visual es temporal y queda sujeta a aceptación.

### Consecuencias

- La base sobresale más de su hexágono y resulta más fácil de identificar en el tablero.
- La proporción del PNG se distorsiona intencionadamente. El tamaño y el ajuste final pueden revisarse tras observarlo en ventana.

### Sustituye

La escala uniforme y caja máxima de 86×86 px definidas para la presentación en ADR-0089 quedan sustituidas. Se conserva su resolución fuente y la separación entre el sprite visual y la huella lógica.

<a id='adr-0097'></a>
## ADR-0097 — Outline de base y enemigos

- Fecha: 2026-10-14.
- Estado: integrado en código; grosores refinados por [ADR-0098](#adr-0098); aceptación visual pendiente.
- Contexto: torres y obstáculos ya usan `interactable_outline.gdshader`, mientras que la base no tenía contorno y los enemigos pintaban sus sprites manualmente. Hace falta conservar el mismo trazo alfa sin interferir con animación, barras ni orden de profundidad.

### Decisión

1. Reutilizar `interactable_outline.gdshader` para el sprite de `GameBase`, con contorno blanco como el de las torres y obstáculos.
2. Añadir al mismo shader el modo `outline_only`, que dibuja solo la dilatación del alfa y deja el relleno al sprite del enemigo.
3. Cada `Enemy` añade una capa `Sprite2D` detrás de su dibujo, a partir de la misma textura, tamaño, orientación y desplazamiento vertical. El outline sigue el salto de impacto, el giro horizontal y las transformaciones de perfil.
4. Los perfiles de campaña y de diagnóstico reciben un color claro por `EnemyData.id`, con tonos variados entre perfiles; los que no tengan color explícito usan un azul pálido. Los placeholders vectoriales usan la misma asignación de color.
5. La capa de outline no cambia el Y-sort del actor. Las barras de Health/Armor/Shield, los iconos de estado y el sprite original permanecen dibujados por encima.

### Consecuencias

- Base, torres y obstáculos comparten el trazo alfa blanco. Los enemigos conservan el mismo algoritmo de contorno con una paleta pastel diferenciada por tipo.
- Las texturas, el movimiento, la colisión, la selección y el combate no cambian.
- Falta aceptar en ventana el grosor, contraste por perfil y oclusión visual de enemigos delante y detrás de fachadas.

### Fuentes y alcance

- Implementación: `game/board/interactable_outline.gdshader`, `game/main/game_base.gd` y `game/enemies/enemy.gd`.
- Extiende parcialmente [ADR-0093](#adr-0093), que introdujo el outline para torres y obstáculos. No sustituye otras decisiones.

<a id='adr-0098'></a>
## ADR-0098 — Ajuste de grosor del outline y contorno permanente de portales

- Fecha: 2026-10-14.
- Estado: integrado en código; aceptación visual pendiente.
- Contexto: el outline blanco de la base necesitaba reducirse y el de los enemigos ganar un poco de presencia. Los portales debían conservar su acento de hover y, además, mostrar el contorno blanco interactivo de forma permanente, igual que los obstáculos.

### Decisión

1. Reducir `outline_size_px` de `GameBase` de 12 a 6, manteniendo el shader compartido y el color blanco.
2. Aumentar `outline_size_px` de los enemigos de 1.5 a 2.0, conservando la paleta clara por `EnemyData.id` y la sincronización de su capa con el sprite.
3. Añadir a cada portal una capa outline-only permanente con `interactable_outline.gdshader`, color blanco y `outline_size_px = 3.0`, el mismo valor usado por obstáculos. La capa acompaña el frame y la escala de pulsación del portal.
4. Mantener encima el resplandor temporal que marca hover, candidato y cierre previsto; el nuevo borde blanco no sustituye esas señales.

### Consecuencias

- Base, torres, obstáculos y portales usan el mismo estilo de dilatación alfa blanca; los enemigos comparten el shader con su color por tipo.
- El contorno del portal se ve durante toda la partida y no cambia la interacción, el tamaño del hitbox ni la animación desfasada.
- Queda pendiente validar en ventana el grosor, el recorte de alfa durante el loop y la convivencia entre el borde blanco y el resplandor de hover.

### Fuentes y alcance

- Implementación: `game/main/game_base.gd`, `game/enemies/enemy.gd`, `game/board/spawn_portal.gd` y `game/board/interactable_outline.gdshader`.
- Refina los grosores definidos en [ADR-0097](#adr-0097) y extiende su contorno a los portales. No sustituye otras decisiones.

<a id='adr-0099'></a>
## ADR-0099 — Tinte de altura y sombra animada de nubes

- Fecha: 2026-10-14
- Estado: Implementado en código; ADR-0100 actualiza parcialmente la intensidad del tinte y ADR-0109 refina la opacidad de nubes. Aceptación visual pendiente.
- Sustituye: la intensidad/fórmula del tinte de [ADR-0082](#adr-0082), actualizada después por ADR-0100, y la prohibición general de cualquier sombra generada de [ADR-0070](#adr-0070) y [ADR-0054](#adr-0054). Se mantiene la prohibición de sombras proyectadas por sprite.

### Contexto

La diferencia visual entre niveles altos todavía cuesta leerse. También se pide una sombra móvil de nubes que cubra el mundo y todos sus sprites, con formas irregulares de aspecto dibujado, sin tapar los controles de interfaz. La insignia de bonus de elevación de una torre debe quedar disponible solo al pasar el cursor; el ghost de colocación mantiene la información contextual que ya mostraba.

### Decisiones

1. `TerrainVisualCatalog.get_elevation_tint()` usa un multiplicador neutro igual en RGB: altura 0 = `1,00`, altura 1 = `0,96`, altura 2 = `0,92` y altura 3 = `0,88`. Aplica el mismo valor a la tapa del tablero, previews y copias elevadas Y-sorted.
2. La insignia numérica de bonus en una torre construida se dibuja solo cuando `Tower._is_hovered` es verdadero. El indicador del ghost sigue visible durante la previsualización de colocación bajo el cursor.
3. `CloudShadowOverlay` usa un ColorRect de pantalla completa con un shader CanvasItem procedural, ruido deformado de varios tamaños y deriva lenta. El patrón toma la posición/zoom de `Camera2D` para permanecer anclado al terreno al mover la cámara. La sombra se implementó inicialmente con una opacidad de `0,16`; ADR-0109 la actualiza a `0,20`, manteniendo el tono azul-negro y los bordes irregulares suaves.
4. El ColorRect vive en `CloudShadowLayer`, un CanvasLayer justo antes del HUD en el árbol de la escena. Cubre el mundo dibujado detrás y queda debajo de los controles del HUD; sigue activo aunque se oculte el HUD. Afecta de manera uniforme a terreno, fachadas, base, torres, enemigos, obstáculos, props y portales, sin cambiar la iluminación individual, las texturas, el orden Y-sort, la geometría ni el gameplay.
5. El tooltip de celda se coloca a 24 px del cursor en horizontal y conserva 14 px en vertical; si no hay espacio a la derecha, se ubica al lado opuesto con el mismo margen.

### Consecuencias

- En la versión M49, la tapa llegaba a 12 % de oscurecimiento en altura 3. M50/ADR-0100 actualiza el máximo vigente a 15 %. Las fachadas conservan su propio sombreado direccional y el degradado inferior.
- No se añaden imágenes de nubes ni assets externos; el shader crea las masas animadas durante la partida.
- La uniformidad del velo evita diferencias entre sprites animados, torres y terreno. Los elementos de interfaz conservan sus colores.
- La forma, contraste, velocidad y visibilidad del efecto deben revisarse en ventana Godot; no se verificaron visualmente en esta implementación.

### Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño del terreno](PROJECT_SPEC.md#terrain) y [criterios de aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

<a id='adr-0100'></a>
## ADR-0100 — Sprite único de torre y tinte de altura

- **Estado:** aceptado; el montaje por regiones quedó sustituido por ADR-0102. Sprite único, espejo horizontal y tinte siguen vigentes.
- **Fecha:** 2026-10-14.
- **Contexto:** la presentación anterior montaba base y cabeza como Sprite2D distintos y rotaba la cabeza. La composición y el apuntado se sentían articulados, mientras las mismas ilustraciones se veían diferentes en el mundo, la barra de construcción y el panel de información. También se solicita reforzar ligeramente la lectura de las elevaciones.

### Decisiones

1. En M50, `TowerArtCatalog` combinaba las regiones de base y parte superior de cada lámina en una textura cacheada. M52 sustituyó ese montaje por los siete PNG completos entregados en `assets/sprites/ui/icons/`; ya no se recortan rectángulos ni se calculan pivotes.
2. `Tower` y `TowerBuildGhost` dibujan esa textura con un solo `Sprite2D`. Se elimina el pivote de rotación y la torre no inclina el sprite: mira a la derecha por defecto y usa `flip_h` cuando el objetivo está a su izquierda. Los proyectiles mantienen su lógica de combate actual.
3. La misma textura compuesta se usa en la colocación, la card de construcción y el retrato del panel de información. La card mide `148×178 px`, el retrato `104×104 px`, el nombre usa 16 px y el precio en Gold 22 px. Tower Info amplía el retrato a `128×156 px`, el nombre a 28 px y permite hasta 460 px de ancho; el coste visible en la barra de construcción recibe más jerarquía tipográfica.
4. El multiplicador neutro de las tapas del terreno pasa de 4 % a 5 % por nivel: h0 `1,00`, h1 `0,95`, h2 `0,90`, h3 `0,85`. Tablero, previews y copias Y-sorted comparten `TerrainVisualCatalog.get_elevation_tint()`; no cambia la geometría ni el sombreado propio de las fachadas.

### Consecuencias

- Cada torre mantiene un único sprite visible, un outline y el crecimiento de tamaño por nivel ya aprobado. El montaje por regiones descrito aquí es histórico; véase ADR-0102.
- El retrato del mundo y el de UI usan la misma composición, aunque su tamaño de presentación y material de outline/ghost sean distintos.
- La tapa de elevación 3 queda con un 15 % de oscurecimiento acumulado, manteniendo la progresión por altura simple y uniforme.
- La aceptación visual de orientación, escala de cards/panel e intensidad de tinte queda pendiente de revisión en Godot.

### Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño del juego](PROJECT_SPEC.md#game-design), [arquitectura](PROJECT_SPEC.md#architecture), [terreno](PROJECT_SPEC.md#terrain) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

### Sustituye

- Sustituye únicamente el montaje visual articulado de base/cabeza decidido en [ADR-0093](#adr-0093); preview determinista, oferta fija, contornos y outline siguen vigentes.
- La mecánica de composición por regiones de este ADR queda sustituida por [ADR-0102](#adr-0102).
- Actualiza la intensidad del tinte introducida en [ADR-0099](#adr-0099). El badge de hover, el tooltip y el velo de nubes de ADR-0099 siguen vigentes.

<a id='adr-0101'></a>
## ADR-0101 — VFX animados de Cozy Chunky por evento

- **Estado:** aceptado e implementado en código; aceptación visual/interactiva pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** los eventos de combate, progresión y terreno necesitan feedback legible y consistente. El usuario aportó los spritesheets locales de Cozy Chunky y pidió asociarlos a eventos concretos. Las torres ya usan una sola textura compuesta y deben conservar su anclaje sobre la celda.

### Decisiones

1. `AnimatedImpact` acepta hojas en una fila y cuadrículas con tamaño de frame explícito. Los efectos de evento se dibujan en `FeedbackVfxLayer` (CanvasLayer 130), se convierten de posición del mundo a coordenadas de viewport y usan `PROCESS_MODE_ALWAYS`; por eso no se congelan durante ofertas de cards, expansión de terreno ni pausa.
2. Toda torre usa sus hojas `shoot` e `impact` del catálogo `assets/sprites/ui/Cozy_Chunky/PNG_1x/combat/`: Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder. Mortar dispara `tap_ripple` en la posición objetivo prevista. El daño a la base reproduce `base_hit` por encima de su sprite.
3. Cada subida manual o automática de nivel emite un único evento de nivel: muestra `Rewards/star_burst_gold` y `PNG_1x/pickup_ui/level_up` sobre la torre. Las hojas se reproducen una vez por nivel incluso durante las elecciones de cards o terreno.
4. La derrota de un enemigo final (no una transformación por muerte) muestra `PNG_1x/pickup_ui/coins_top`, el recurso disponible que corresponde al “Coin stomp” descrito en la petición. Abrir un cofre muestra `Rewards/coin_burst_gold` y `PNG_1x/pickup_ui/pickup`; mientras siga disponible, `item_glow` anima en loop detrás del cofre.
5. La colocación confirmada de una pieza reproduce `sparkle_twinkle_white_loop` durante dos ciclos. Un clic en obstacle, portal, torre, base o cofre muestra `ui_click` en la posición del cursor. Una run finalizada muestra `confetti_burst_01` en la escena del menú.
6. Los iconos de estados sobre enemigos usan hojas animadas, con este mapeo: Bleed→`bleed`, Burn→`burn`, Poison→`poison`, Slow→`frost`, Haste/Fortification→`buff` y Stun→`stun`. Los iconos solo existen mientras el estado está activo; el contador de acumulaciones se conserva.
7. En M51 la torre ya se mostraba como un único sprite en mundo, ghost, card y retrato, centrado en el hexágono y desplazado 8 px hacia abajo. M52 sustituye la composición por regiones por el PNG completo de cada torre; conserva el mismo centro, offset y espejo horizontal sin rotación.

### Consecuencias

- Las animaciones son overlays de pantalla y su punto de aparición sigue la cámara en el frame de emisión; los elementos persistentes del cofre y los estados continúan anclados a sus entidades del mundo.
- `coins_top` es el nombre de archivo proporcionado para el feedback de muerte; no se renombra el asset fuente.
- FPS y tamaños de presentación quedan configurables en `Main` y `AnimatedImpact`. El ajuste fino y el recorrido visual quedan pendientes de aceptación manual en Godot.

### Referencias

- Petición explícita del usuario y spritesheets locales de `assets/sprites/ui/Cozy_Chunky/`, 2026-10-14.
- [Diseño del juego](PROJECT_SPEC.md#game-design), [arquitectura](PROJECT_SPEC.md#architecture), [combate](PROJECT_SPEC.md#combat), [terreno](PROJECT_SPEC.md#terrain), [progreso](IMPLEMENTATION_AND_QA.md#progress) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

### Sustituye

- Sustituye el uso activo de VFX Tiny Swords descrito históricamente en M16; no cambia sus reglas de combate ni elimina los archivos históricos del proyecto.
- Amplía el anclaje visual de sprite único fijado en [ADR-0100](#adr-0100) con un desplazamiento compartido de 8 px hacia abajo.

<a id='adr-0102'></a>
## ADR-0102 — Sprites completos de torre, escala y feedback

- **Estado:** aceptado e implementado en código; aceptación visual pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** los siete PNG de torre se sustituyeron por ilustraciones completas, pero `TowerArtCatalog` seguía recortando las coordenadas de las antiguas láminas de base/cañón. Esto encogía o cortaba el arte. Además, las torres de ataque rápido repetían demasiado el efecto `shoot`.

### Decisiones

1. Cada perfil canónico carga directamente su PNG completo desde `assets/sprites/ui/icons/`. `TowerArtCatalog` conserva una textura compartida cacheada por perfil, pero no recorta ni recompone regiones. El mismo recurso se utiliza en torre colocada, ghost, card de selección y Tower Info.
2. El centro del sprite coincide con el centro lógico de la celda y conserva un offset visual fijo de +8 px en Y. No se rota: el sprite completo solo usa espejo horizontal para apuntar al lado contrario. `TOWER_VISUAL_SCALE` sube a 1,44 y `TowerArtCatalog.DISPLAY_HEIGHT_MULTIPLIER` mantiene 1,12; mundo y ghost comparten el mismo cálculo. El icono de la card mide 126×126 px, la card 162×198 px y el retrato de Tower Info 152×176 px.
3. Las torres de fuego continuo (Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder) emiten el primer efecto `shoot` inmediatamente y luego limitan ese VFX con un intervalo aleatorio propio de 2,0–2,5 s. Ballista y Mortar conservan el efecto de cada disparo discreto. El límite no afecta a las hojas `impact`, los proyectiles ni el daño.
4. La hoja `pickup.png` también se reproduce al construir una torre y al retirar correctamente un obstáculo, en el centro visual del objeto. La apertura de cofres conserva `coin_burst_gold` y `pickup`.

### Consecuencias

- Los sprites completos ya no dependen de rectángulos/pivotes definidos a mano; cambios de resolución o de encuadre de esas imágenes no requieren rehacer el montaje.
- `TOWER_VISUAL_SCALE` y el tamaño de las imágenes de UI son valores de presentación. No cambian la celda ocupada, el rango ni la colisión.
- El cooldown solo dosifica el efecto visual de disparo. No modifica frecuencia de ataque, proyectiles, daño ni efectos de impacto.
- El ajuste fino del tamaño y la legibilidad queda pendiente de aceptación manual en Godot.

### Referencias

- Petición explícita del usuario y sprites PNG completos de `assets/sprites/ui/icons/`, 2026-10-14.
- [Diseño del juego](PROJECT_SPEC.md#game-design), [arquitectura](PROJECT_SPEC.md#architecture), [combate](PROJECT_SPEC.md#combat), [progresión](CONTENT_AND_ASSETS.md#progression-audit), [progreso](IMPLEMENTATION_AND_QA.md#progress) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

### Sustituye

- Sustituye el montaje por regiones de la lámina descrito en [ADR-0100](#adr-0100). Su sprite único, espejo, crecimiento por nivel y tinte de elevación siguen vigentes.
- Amplía [ADR-0101](#adr-0101) con la limitación temporal de `shoot` y la reutilización de `pickup.png` en construcción y retirada de obstáculos.
- La escala de tablero/ghost de la decisión 2 fue refinada por [ADR-0103](#adr-0103); los tamaños de interfaz de esta decisión permanecen vigentes.

<a id='adr-0103'></a>
## ADR-0103 — Escala de torre sin recorte

- **Estado:** aceptado e implementado en código; aceptación visual pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** después de cargar los sprites completos de torre con la escala ampliada de M52, algunas torres se veían cortadas al colocarse. La reducción debe preservar la coincidencia entre preview y torre final, y dejar intactos los retratos de interfaz.

### Decisiones

1. Reducir `Tower.TOWER_VISUAL_SCALE` de 1,44 a 1,32. Este valor alimenta el sprite colocado y el tamaño del ghost, por lo que ambos conservan la misma escala y anclaje.
2. Mantener `TowerArtCatalog.DISPLAY_HEIGHT_MULTIPLIER = 1,12`, el offset visual de +8 px y el sprite PNG completo sin recortes ni composición por regiones.
3. No cambiar los tamaños de las cards ni de Tower Info: este ajuste afecta al arte de mundo/preview, no a los iconos UI.

### Consecuencias

- La escala mundial conserva una ampliación visible, pero deja más margen alrededor del sprite para reducir cortes al colocarlo.
- No cambia el hex ocupado, las colisiones, el alcance, el daño ni las reglas de selección.
- La reducción debe aceptarse visualmente en Godot con las siete torres, terreno plano y elevado; no se realizó esa revisión en esta actualización.

### Referencias

- Petición explícita del usuario y sprites completos en `assets/sprites/ui/icons/`, 2026-10-14.
- [Diseño del juego](PROJECT_SPEC.md#game-design), [arquitectura](PROJECT_SPEC.md#architecture), [progreso](IMPLEMENTATION_AND_QA.md#progress) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

### Sustituye

- Sustituye únicamente la escala de tablero/ghost 1,44 de [ADR-0102](#adr-0102). Los PNG completos, offset, tamaño UI, mirror, contorno y cadencia de VFX siguen vigentes.
- La escala 1,32 quedó posteriormente reducida por [ADR-0104](#adr-0104).

<a id='adr-0104'></a>
## ADR-0104 — Reducción del 20 % de escala de torre

- **Estado:** implementado; escala de mundo/ghost supersedida por ADR-0105. La aceptación visual de M54 sigue pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** incluso con el ajuste de margen M53, las torres colocadas seguían ocupando demasiado espacio visual. El usuario pide reducirlas otro 20 % en el tablero.

### Decisiones

1. Reducir `Tower.TOWER_VISUAL_SCALE` exactamente un 20 % respecto a 1,32: el valor nuevo es 1,056.
2. Mantener sincronizada la escala del ghost con la torre colocada; conservar `DISPLAY_HEIGHT_MULTIPLIER = 1,12`, el offset visual de +8 px y la textura PNG completa.
3. Limitar este ajuste al mundo y su preview. Los iconos de la barra de selección y Tower Info mantienen sus tamaños actuales.

### Consecuencias

- Las torres colocadas son un 20 % menores que con la escala anterior; preview y resultado siguen coincidiendo.
- No cambia la huella hexagonal, colisiones, alcance, daño ni selección lógica.
- La comprobación visual en Godot queda pendiente.

### Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño del juego](PROJECT_SPEC.md#game-design), [arquitectura](PROJECT_SPEC.md#architecture), [progreso](IMPLEMENTATION_AND_QA.md#progress) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

### Sustituye

- Sustituye el valor 1,32 de tablero/ghost de [ADR-0103](#adr-0103). Los tamaños UI y demás reglas de sprites completos de ADR-0102/0103 siguen vigentes.
- M55/ADR-0105 reduce posteriormente esta escala de 1,056 a 0,9504; esta página conserva el valor de M54 como historial.

<a id='adr-0105'></a>
## ADR-0105 — Tooltip de spawn, atajos de torre, panel de Gold, zoom y escala

- **Estado:** aceptado e implementado en código; aceptación visual/interactiva pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** la composición de enemigos sobre los portales cubría el tablero, los atajos de la barra no se compactaban al reclutar torres, la rueda quedaba reservada a rotación durante colocación y Gold/precios no compartían el panel horizontal del botón de ronda. También se solicita reducir otro 10 % el tamaño de las torres colocadas.

### Decisiones

1. Los portales dejan de dibujar retratos flotantes. Mantienen la distribución real de `WaveDirector`; el tooltip de hover muestra retrato, nombre y cantidad de cada tipo de enemigo, además del resumen de ronda.
2. Las torres disponibles en la run se enumeran en el orden del roster visible y reciben atajos consecutivos desde `1`. La tecla aparece como una insignia en cada card; al reclutar otra torre, el nuevo orden se recalcula.
3. La rueda sin modificadores siempre controla el zoom de cámara, también durante la colocación de terreno. `Ctrl+rueda` rota la pieza; Q/E siguen rotando sin usar el ratón.
4. Gold del HUD y el precio de las cards de torre usan un mismo StyleBoxTexture 9-slice, derivado de `start_round_button.png`, que también comparte el estado normal de Iniciar ronda. Mana conserva su presentación sin panel.
5. La escala de `Tower` y `TowerBuildGhost` pasa de 1,056 a 0,9504 (10 % menos), manteniendo escala vertical 1,12, el offset de +8 px, el PNG completo y los tamaños de los iconos UI.

### Consecuencias

- El hover del portal es la única presentación de los tipos y cantidades asignados a ese spawn; la lógica de distribución no cambia.
- La card visible y el número del teclado describen el mismo índice de torre reclutada.
- El usuario puede hacer zoom con la rueda durante la colocación sin girar por accidente la pieza; para girarla con la rueda debe mantener Ctrl.
- La lectura de Gold y del precio de construcción comparte el panel dorado horizontal, mientras Mana no ocupa ese tratamiento visual.
- La reducción afecta al sprite de mundo y al preview, no a retratos, alcance, daño, colisión ni celda ocupada. Los valores anteriores de M54 quedan como historial en [ADR-0104](#adr-0104).

### Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño del juego](PROJECT_SPEC.md#game-design), [arquitectura](PROJECT_SPEC.md#architecture), [progreso](IMPLEMENTATION_AND_QA.md#progress) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

### Sustituye

- Sustituye la escala 1,056 × 1,12 de mundo/ghost establecida en [ADR-0104](#adr-0104), los badges flotantes de portal descritos en [ADR-0051](#adr-0051) y el uso de la rueda de [ADR-0072](#adr-0072). Conserva los demás contratos de sprites y escala de M52–M54.

<a id='adr-0106'></a>
## ADR-0106 — VFX de evento anclados al mundo durante el paneo

- **Estado:** aceptado e implementado en código; aceptación visual pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** al emitir VFX de baja, disparo, impacto y otros eventos del juego, `Main` convertía una vez la posición del mundo a coordenadas de viewport. `FeedbackVfxLayer` no seguía la transformación de `Camera2D`, por lo que el efecto quedaba en pantalla mientras el terreno y los actores se desplazaban al paneo.

### Decisiones

1. `FeedbackVfxLayer` conserva su CanvasLayer superior y `PROCESS_MODE_ALWAYS`, pero activa `follow_viewport_enabled` para seguir la transformación de cámara sin perder el orden visual sobre HUD, cards y preview.
2. `Main._spawn_impact_vfx` pasa la posición del mundo directamente a `AnimatedImpact` para los eventos del juego; ya no la convierte a viewport ni compensa manualmente el tamaño por el zoom.
3. Los VFX de juego se dibujan y escalan mediante la transformación de la cámara durante toda su animación. Paneo y zoom los mueven junto con la celda o actor que originó el evento.
4. `ui_click` conserva su semántica de cursor en un CanvasLayer separado sin seguimiento de viewport; por eso permanece sobre el cursor aunque el usuario panee.
5. El glow del cofre y los iconos de estado mantienen su lógica persistente en las entidades del mundo; no se trasladan al overlay de eventos.

### Consecuencias

- Disparos, impactos, bajas, daño a base, cofres, subida de nivel y colocación de terreno permanecen en sus coordenadas de mundo mientras se panea; el marcador `ui_click` sigue al cursor.
- Los efectos siguen mostrándose por encima de la interfaz y siguen animándose durante pausa y selección.
- El tamaño aparente de los efectos responde al zoom como el de cualquier otro objeto del mundo.
- La compilación de escena y la revisión visual/interactiva quedan pendientes; el criterio incluye paneo y zoom mientras cada animación está activa.

### Referencias

- Petición del usuario sobre el anclaje de partículas al mover la cámara, 2026-10-14.
- [Arquitectura técnica](PROJECT_SPEC.md#architecture), [progreso](IMPLEMENTATION_AND_QA.md#progress) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

### Corrige

- Corrige el posicionamiento de coordenadas de viewport descrito en [ADR-0101](#adr-0101). Conserva el catálogo de efectos, eventos, capa superior y proceso ALWAYS establecidos por ese ADR.

<a id='adr-0107'></a>
## ADR-0107 — Feedback de progresión y presentación de cards

- **Estado:** aceptado e implementado en código; aceptación visual pendiente. La presentación del agua del punto 8 fue sustituida parcialmente por ADR-0108.
- **Fecha:** 2026-10-15.
- **Contexto:** el seguimiento de objetivos hacía que las torres subieran demasiado despacio; los iconos de estado, los controles H/A/S y la tienda necesitaban más legibilidad. Las fachadas elevadas podían ganar empates de profundidad frente a enemigos. El usuario pidió además un feedback común para cards, una acción de demolición compacta y un fondo animado oscuro.

### Decisiones

1. La XP automática por seguimiento de objetivo de todas las torres multiplica por cinco la tasa anterior. Al subir automáticamente, `Tower` emite `level_up_effect_requested`, igual que en una mejora manual, para reutilizar el feedback de nivel existente.
2. Los iconos de estados animados sobre enemigos pasan de 22×22 a 44×44 px. El contador de acumulaciones se mantiene junto al sprite.
3. Las fachadas de terreno conservan su origen de profundidad en la junta inferior. `TerrainCliffOccluder` añade un sesgo local de 1 px solo al Y-sort para resolver coincidencias exactas; no desplaza el polígono, la textura ni los anclajes axiales.
4. Los botones Health/Armor/Shield forman una columna y expanden su ancho al máximo del panel padre. Los iconos de capa aumentan a 52×52 px.
5. Las acciones de demoler torre y retirar obstáculo usan el mismo icono `assets/sprites/ui/demolish_tower_icon.png` en botones cuadrados de 58×58 px. El coste de retirada ocupa un badge pequeño con el icono Gold y su importe; el sprite de demolición conserva el protagonismo.
6. Cada mejora permanente selecciona un icono desde su operación o torre afectada. La moneda persistente se presenta con `assets/sprites/ui/icons/exp.png` junto a los importes; la interfaz de la tienda no muestra los textos «XP», «EXP» ni «experiencia».
7. `BalatroCardHover` aporta inclinación, escala moderada y brillo radial ligado al cursor a cards de mejora de run, terreno y torre. El efecto es visual y no intercepta entrada ni reemplaza la selección existente.
8. **Histórico; presentación sustituida por ADR-0108.** M56 incorporó el agua procedural oscura en `CanvasLayer` -10. La capa inferior y su función de fondo siguen vigentes; paleta, tamaño de las formas y velocidad actuales se rigen por ADR-0108.

### Consecuencias

- La experiencia automática por objetivo es cinco veces más rápida, pero los costes/curvas de nivel no cambian.
- Las mejoras manuales y automáticas presentan el mismo efecto visual.
- La profundidad mantiene el criterio visual por posición; solo se rompe de forma estable un empate de un píxel a favor de la fachada.
- La tienda usa iconografía coherente para cada nodo y para todos los importes de la moneda persistente.
- Los tres tipos de cards responden al hover con el mismo componente y mantienen sus propias acciones.
- El agua permanece limitada al fondo visible detrás del juego. Su presentación vigente y aceptación visual quedan en ADR-0108.

### Referencias

- Petición del usuario sobre XP, iconos, demolición, cards, enemigos y shader de fondo, 2026-10-15.
- [Fuente de verdad de diseño](PROJECT_SPEC.md#game-design), [progresión](CONTENT_AND_ASSETS.md#progression-audit), [combate](PROJECT_SPEC.md#combat), [terreno](PROJECT_SPEC.md#terrain), [progreso](IMPLEMENTATION_AND_QA.md#progress) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance).
- [Wind Waker 2D Water Shader (Godot 4)](https://godotshaders.com/shader/wind-waker-2d-water-shader-godot-4/), Godot Shaders; snippet identificado como CC0, consultado el 2026-10-15.

### Extiende

- ADR-0069/0077: moneda persistente, iconografía y tienda permanente.
- ADR-0090/0099: orden/lectura visual de fachadas y capas del tablero.
- ADR-0101/0102/0106: feedback visual, subida de torre y efectos de run.

<a id='adr-0108'></a>
## ADR-0108 — Agua Wind Waker y explosión pixel de enemigo

- **Estado:** aceptado e implementado en código; aceptación visual y revisión de rendimiento pendientes.
- **Fecha:** 2026-10-15.
- **Contexto:** el fondo oscuro de M56 no se parecía a la imagen de agua suministrada. La muerte de enemigos solo mostraba `coins_top`; el usuario pidió que el sprite se descompusiera en píxeles con el shader enlazado.

### Decisiones

1. `WaterBackgroundLayer` conserva `CanvasLayer -10`, bajo mundo, efectos y HUD. Su shader usa la composición de agua animada de Wind Waker con espuma casi blanca, masas azules redondeadas, patrón de escala grande y desplazamiento lento. Es un fondo visual de pantalla y no afecta a terreno, selección ni reglas de juego.
2. Al producirse una baja final, `WaveDirector` emite la instancia de `Enemy` a su listener local en `Main`. Antes de liberar al enemigo, `Main` obtiene una instantánea de su sprite dibujado: textura, frame, orientación horizontal, modulación y escala efectiva, además de la posición visual que incluye salto y offset artístico.
3. `EnemyDeathParticlePool.emit_death_particles_at(coords, sprite)` configura una `GPUParticles2D` one-shot con `amount = texture.width × texture.height`, muestreo nearest del frame indicado, escala del sprite y orientación espejada. Los emisores se reutilizan después de terminar; cada instancia duplica su material para que bajas simultáneas no compartan parámetros de textura.
4. El estallido se crea en `FeedbackVfxLayer` 130, con coordenadas locales del emisor, para que siga anclado a la posición del mundo durante paneo/zoom. Procesa `ALWAYS` y queda visible al abrir cards o terreno. La explosión de píxeles complementa `coins_top`; no lo reemplaza.
5. Las duraciones, velocidades y escala aleatoria del shader de partículas son parámetros visuales configurables. El número de partículas sigue la resolución de la textura de origen, tal como pidió el usuario; el pool evita recrear emisores en cada baja.

### Consecuencias

- El fondo actual es brillante y de alto contraste con grandes manchas animadas; sustituye la paleta oscura provisional de M56.
- La muerte reproduce la apariencia y el tamaño del sprite visible, incluso cuando el enemigo va espejado o está en el punto alto de un salto.
- El `coins_top` anterior y las recompensas de baja continúan ejecutándose una sola vez por muerte final.
- Falta comprobar visualmente la escala de las gotas/píxeles, el aspecto del fondo a distintas resoluciones y la carga de GPU en oleadas con bajas simultáneas.

### Referencias

- Petición e imagen de referencia del usuario, shader pegado y configuración solicitada para `emit_death_particles_at`, 2026-10-15.
- [Wind Waker 2D Water Shader (Godot 4)](https://godotshaders.com/shader/wind-waker-2d-water-shader-godot-4/), Godot Shaders; snippet CC0, consultado el 2026-10-15.
- [Improved Sprite Pixel Explosion Shader](https://godotshaders.com/shader/improved-sprite-pixel-explosion-shader/), Mopifish / m o r b o; shader Godot 4.7.1 y código CC0, consultado el 2026-10-15.
- [VFX anclados al mundo](#adr-0106), [combate](PROJECT_SPEC.md#combat), [arquitectura](PROJECT_SPEC.md#architecture), [progreso](IMPLEMENTATION_AND_QA.md#progress) y [aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

### Extiende y sustituye

- Extiende ADR-0101 y ADR-0106 para añadir el burst de píxeles al evento de baja, conservando las capas y el anclaje de los VFX de juego.
- Sustituye únicamente la paleta y presentación del agua del punto 8 de ADR-0107; conserva su posición en `CanvasLayer -10`.

<a id='adr-0109'></a>
## ADR-0109 — Sombra de nubes reforzada y agua anclada a cámara

- Fecha: 2026-10-15
- Estado: Implementado en código; aceptación visual pendiente.
- Refina: [ADR-0099](#adr-0099) para la opacidad de nubes y [ADR-0108](#adr-0108) para el movimiento del patrón de agua.

### Contexto

El sombreado móvil de nubes apenas se percibía y el agua del fondo se quedaba fija respecto a la pantalla mientras el tablero se desplazaba al panear la cámara. El usuario pidió reforzar ligeramente la sombra y que el agua acompañe el movimiento del mundo.

### Decisiones

1. `CloudShadowOverlay.shadow_opacity` pasa de `0,16` a `0,20`. Se conservan el color, la forma procedural, la velocidad, el área afectada y su posición bajo el HUD.
2. `WaterBackgroundLayer` conserva el `CanvasLayer -10` y el `ColorRect` a pantalla completa. El shader recibe posición mundial de cámara, tamaño del viewport y zoom; deriva desde ellos la coordenada del mundo visible para generar el patrón. Así el agua acompaña paneo y zoom sin mover ni escalar el panel que cubre la pantalla.
3. Los parámetros de cámara se actualizan en el mismo ciclo que los del sombreado de nubes. El patrón continúa animándose en coordenadas del mundo; no cambia la simulación, el terreno ni la entrada.

### Consecuencias

- La sombra debe resultar algo más visible sin ocultar la lectura de los sprites.
- El agua conserva su escala de pantalla y su cobertura completa, y deja de parecer una capa flotante al desplazar el tablero.
- La aceptación visual tras paneo y zoom queda pendiente.

### Fuentes

- Solicitud del usuario en Codex, 2026-10-15.
- Implementación del shader de agua y la sombra en el proyecto, 2026-10-15.

<a id='adr-0110'></a>
## ADR-0110 — Mejoras de capa en fila y shake de ronda

- Fecha: 2026-10-15
- Estado: Implementado en código; aceptación visual pendiente.
- Refina: la disposición de los botones H/A/S descrita en [ADR-0107](#adr-0107).

### Contexto

Los botones de mejora de Health, Armor y Shield ocupaban una columna en el panel de acciones de torre. El precio de cada botón no compartía el panel visual de `TowerShortcutCard`. Además, faltaba una señal visual ligera para indicar que una ronda estaba activa.

### Decisiones

1. `UpgradeRow` pasa a ser una fila horizontal centrada con tres botones H/A/S de `128 × 128` unidades, de modo que cada botón es cuadrado y conserva su tamaño al repartirse el ancho.
2. `TowerLayerUpgradeButton` presenta icono de coste y cantidad dentro de un `PanelContainer` que reutiliza `gold_panel_style.tres`, las dimensiones y la composición de `TowerShortcutCard`.
3. Al recibir `wave_started`, `Main` inicia una sacudida ambiental de cámara de baja amplitud. Se detiene inmediatamente en `wave_completed` o `wave_failed`.
4. La sacudida ambiental y el impulso de daño a base se componen como offsets separados; el shake continuo no reemplaza ni cancela el feedback de daño ya existente.

### Consecuencias

- Las tres mejoras se ven juntas y el panel usa menos altura que la disposición vertical.
- Los precios de torre y los costes H/A/S comparten el mismo lenguaje visual.
- La cámara transmite actividad mientras hay combate y recupera el offset base al acabar la ronda.
- La aceptación visual/interactiva queda pendiente.

### Fuentes

- Solicitud del usuario en Codex, 2026-10-15.
- Implementación de `main.tscn`, `tower_layer_upgrade_button.tscn` y `main.gd`, 2026-10-15.

<a id='adr-0111'></a>
## ADR-0111 — Barra de XP y precios de demolición

- Fecha: 2026-10-15
- Estado: Implementado en código; aceptación visual pendiente.
- Refina: la presentación de mejoras y demolición descrita en [ADR-0107](#adr-0107) y [ADR-0110](#adr-0110). Mantiene el cálculo económico de reembolso aprobado por [ADR-0064](#adr-0064).

### Contexto

La barra de XP de `TowerLayerUpgradeButton` era demasiado fina y se extendía por todo el ancho de la card. Los botones de demolición usaban principalmente el icono, por lo que no dejaban claro el nombre de la acción ni el importe que se cobraría o devolvería.

### Decisiones

1. `XPBar` mide `88 × 8` unidades y usa alineación de encogimiento centrada. Es más gruesa y ocupa menos ancho que la barra anterior.
2. La acción sobre torres muestra el icono de demolición, el texto `DEMOLER` y un panel de Gold con `+<importe>` cuando hay una torre seleccionada. El valor se obtiene de `BuildController.get_demolition_refund()`; no se recalcula ni se altera la regla de reembolso.
3. La acción sobre obstáculos muestra el icono, el texto `DEMOLER` y el coste actual de retirada como `−<importe>` con el icono de Gold.
4. La acción sobre portales conserva el verbo `RETIRAR` y muestra su coste como `−<importe>` con icono de Gold, que sigue siendo el doble del coste actual de retirar un obstáculo.

### Consecuencias

- El jugador puede leer de un vistazo la progresión de XP de capa y la longitud de la barra no domina la card.
- Antes de confirmar una retirada, el jugador ve si pagará Gold o recibirá Gold.
- La economía, las curvas progresivas, las restricciones de fase y el mínimo de portales activos permanecen sin cambios.
- La aceptación visual/interactiva queda pendiente.

### Fuentes

- Solicitud del usuario en Codex, 2026-10-15.
- Implementación en `game/ui/components/tower_layer_upgrade_button.tscn`, `game/main/main.tscn` y `game/main/main.gd`, 2026-10-15.

### ADR sustituidos

- Ninguno. Este ADR refina la presentación sin sustituir la regla de reembolso de ADR-0064.

<a id='adr-0112'></a>
## ADR-0112 — Legibilidad de mejoras, pausa y colocación de terreno

- Fecha: 2026-10-15
- Estado: Aceptado; implementación integrada; aceptación visual e interactiva pendiente.
- Decisiones relacionadas: refina ADR-0061 (pausa y fases de expansión), ADR-0072 (controles de terreno), ADR-0093 (selección de portales) y ADR-0105 (presentación de spawns y panel de Gold).

### Contexto

Los textos de mejoras no diferenciaban visualmente las cifras positivas y negativas. El HUD mantenía un panel técnico de terreno/debug accesible con F3 que ya no forma parte del flujo esperado. El botón de pausa ocupaba una fila separada bajo la vida, Mana no compartía el panel de Gold y la colocación de terreno no mostraba sus atajos de forma suficientemente visible. La composición de enemigos de un portal estaba disponible en hover, aunque el usuario también necesita consultarla desde el panel lateral.

### Decisiones

1. Las cifras de efectos beneficiosos se muestran en verde y las de efectos perjudiciales en rojo, tanto en cards de run como en nodos de mejoras permanentes. En Tower Info, cada estadística efectiva se compara con el valor base: una subida aparece verde, una reducción roja y un valor sin cambio conserva el color normal. Los bonuses por elevación y los efectos positivos H/A/S usan verde. El coste de Mana se interpreta al revés: consumir menos es verde y consumir más, rojo.
2. El botón de pausa comparte la fila de la barra de vida. Su único carácter visible es `P`, junto a un glyph de pausa mientras la partida corre y de play mientras está pausada. `P` conserva su atajo de teclado.
3. Se retira de la escena y del código runtime el panel F3, su selector de oleadas de diagnóstico y su inspector técnico. La campaña normal mantiene sus 45 rondas en orden; los controles de terreno siguen funcionando con teclado, ratón y cards.
4. Al seleccionar una pieza para colocar aparece un panel grande, encima de las cards de torre, con `Q / E` para rotar y `T` para colocación automática. El texto de validación de la posición permanece debajo.
5. Clicar un portal produce el mismo feedback `ui_click` que los demás objetos interactuables, cierra su tooltip y deja en Tower Info la composición de enemigos asignada a esa salida para la ronda actual.
6. Gold y Mana usan paneles 9-slice iguales, con dimensiones, altura, icono y composición coincidentes.

### Consecuencias

- Se elimina la superficie de diagnóstico F3 del flujo de juego. Los criterios históricos de esa herramienta se consideran sustituidos por M61.
- Los colores describen el efecto relativo en combate, no rareza ni tipo de recurso.
- No se ejecutaron pruebas de escena; las comprobaciones visuales e interactivas quedan en [Aceptación](IMPLEMENTATION_AND_QA.md#m61--legibilidad-de-mejoras-hud-y-colocacion-de-terreno).

<a id='adr-0113'></a>
## ADR-0113 — Ajustes de paneles y pausa de agua

- Fecha: 2026-10-15
- Estado: Aceptado; implementación integrada; aceptación visual e interactiva pendiente.
- Decisiones relacionadas: refina ADR-0110 (fila H/A/S), ADR-0111 (precios de demolición), ADR-0112 (Tower Info, pausa y selección de portal) y ADR-0108/0109 (fondo de agua).

### Contexto

La escena `main.tscn` conservaba restos serializados de la ruta anterior de `RemovalCostLabel`, que provocaban un error al iniciar. La fila de mejoras H/A/S alineaba mal los iconos y algunos valores de layout se imponían desde código, dificultando ajustarlos en el Inspector. Los precios de demolición compartían el interior del botón. La selección de portal no siempre mantenía una referencia válida para abrir su información lateral. El shader de agua seguía avanzando mientras el árbol de juego estaba pausado.

### Decisiones

1. `RemovalCostBadge` y `TowerDemolitionRefundPanel` son hermanos de sus botones, colocados a su derecha. La escena contiene los nodos de fila, icono y cifra bajo su ruta vigente; no conserva nodos huérfanos en la raíz.
2. El icono H/A/S se centra mediante un `CenterContainer` y usa 64 × 64 px. El tamaño de los botones vuelve a depender de la escena reutilizable, sin asignaciones de tamaño desde `_configure_tower_upgrade_visuals()`.
3. Los parámetros responsivos de Tower Info (anchos, márgenes de posición, altura mínima y espacio inferior) se exponen en el Inspector del nodo `Main`. El código no resetea la escala ni el pivote de `TowerInfoContent`; los márgenes del `MarginContainer` se conservan como propiedades de escena.
4. `SpawnPortal` seleccionado se conserva como referencia explícita. La visibilidad de Tower Info no depende de una consulta global de cantidad de spawns; el panel muestra el detalle y reparto de esa salida.
5. El shader usa el uniforme `water_time`, actualizado con el delta de `Main`. Como `Main` no procesa durante pausa, el agua se congela y continúa al reanudar.

### Consecuencias

- Los cambios de layout de Tower Info se pueden ajustar desde el Inspector sin editar constantes de código.
- La escena vuelve a resolver `%RemovalCostLabel`; el precio y el reembolso quedan fuera del botón.
- No se ejecutó Godot; la carga de escena y la aceptación visual/interactiva quedan pendientes en [M62](IMPLEMENTATION_AND_QA.md#m62--correcciones-de-paneles-y-pausa-del-agua).

<a id='adr-0114'></a>
## ADR-0114 — Preview de torre, resumen de run y mapa permanente

- Fecha: 2026-10-15
- Estado: Aceptado; código/documentación integrados; aceptación visual e interactiva pendiente.
- Decisiones relacionadas: refina ADR-0093/0094 para el preview de torre y ADR-0076 para el resumen de fin de run; desarrolla el mapa de ADR-0077.

### Contexto

El radio de ataque solo se intuía al pasar el cursor y no permanecía visible al seleccionar una torre. El ghost y la ficha de selección podían calcular daño/alcance por caminos distintos, mostrando una elevación diferente a la que recibía la torre al construirse. La colocación de terreno necesitaba una señal más evidente de validez. El resumen final filtraba los tipos por unlock permanente, y el mapa de mejoras no alineaba todos los unlocks de torre en una fila común. Algunos nodos de mejora podían quedar sin icono y su precio no compartía una jerarquía visual uniforme.

### Decisiones

1. `Tower.get_damage_for`, `Tower.get_range_hexes_for` y `Tower.get_cell_world_position` son los cálculos compartidos por torre construida, ficha y ghost. El preview incorpora elevación, cartas activas y multiplicador permanente, por lo que se puede comprobar el resultado antes de confirmar la colocación.
2. Una torre dibuja un anillo de alcance de alto contraste mientras está bajo el cursor o seleccionada. El radio usa el alcance efectivo actual, incluidos modificadores de run.
3. Las celdas de una pieza en colocación usan un tinte y un contorno lima intenso cuando la pieza es válida y rojo intenso cuando no lo es.
4. `RunManager` presenta en el Game Over solo los IDs que registraron al menos una torre construida durante la run, agrupando por tipo el número construido y el daño total. El resumen no depende de los unlocks permanentes.
5. Los siete nodos de unlock de torre se disponen en la misma fila del mapa. Cada torre habilita tres opciones H/A/S alineadas horizontalmente; ninguna requiere comprar antes una de las otras dos, aparte de desbloquear la torre.
6. Cada nodo permanente tiene un icono del `IconCatalog`, usando primero el icono de perfil y, en última instancia, el icono común de daño como fallback. En nodos con coste, la cifra se centra en grande y el icono de perfil (`exp.png`) se muestra a su derecha en la misma fila.

### Consecuencias

- El jugador puede comparar el alcance de torres con rapidez y evaluar la elevación antes de gastar Gold.
- Un tipo desbloqueado pero nunca construido no añade ruido al resumen de la run.
- El árbol presenta las opciones H/A/S en paralelo, con lectura común de icono y coste.
- No se ejecutó Godot ni una revisión en ventana; la aceptación visual/interactiva está descrita en [M63](IMPLEMENTATION_AND_QA.md#m63--alcance-ghost-exacto-y-mapa-de-mejoras).

<a id='adr-0115'></a>
## ADR-0115 — UI editable desde Inspector y limpieza de recursos

- Fecha: 2026-10-15
- Estado: escaneo headless y smoke de escena principal pasados; aceptación de Inspector y revisión visual pendiente. El sandbox impidió guardar el inicio de run de prueba y las preferencias del editor.
- Decisiones relacionadas: desarrolla ADR-0049/0050 para configuración de UI; el ajuste de iconos de estado sustituye el tamaño 44×44 px de ADR-0107. No cambia las reglas de M63.

### Contexto

La UI ya se construye principalmente con escenas `.tscn`, pero varios scripts reasignaban fuentes, márgenes, estilos, tamaños y posiciones al iniciar. Esto hacía que cambios del Inspector se perdieran o que los controles creados durante la partida carecieran de una configuración visible. También quedaban hojas PNG y Resources de oleadas DEBUG sin consumidores después de retirar el selector F3.

### Decisiones

1. Los valores estáticos de tipografía, espaciado y estilo viven en escenas, Themes o StyleBoxes asignados desde Inspector. Para contenido generado durante la partida, la escena/script propietario expone los tamaños, fuentes, separaciones y colores que usa; el código no sustituye esos valores por constantes ocultas.
2. Las ofertas de mejora conservan su jerarquía `.tscn`; los StyleBoxes y el material de aura se asignan en la escena. Se exponen en Inspector las dimensiones del panel y las cartas, la distribución del mapa permanente, los enlaces, el timeline, el feedback de enemigo, las dos composiciones de cards de terreno, los colores de estado HUD, el tamaño adaptable del botón de ronda, las dimensiones/pulso del cursor y los tamaños de VFX.
3. El marcador de portal se convierte en un `Label` estático de `spawn_portal.tscn`. El mapa permanente contiene su título central en `meta_progression_map.tscn`. Los estilos de XP H/A/S se configuran en la escena reutilizable `TowerLayerUpgradeButton`.
4. Los iconos de estado del enemigo pasan de 44×44 a 28×28 px, con 5 px de separación. La colocación, el contador de stacks, las barras H/A/S y el texto flotante de daño quedan configurables desde el Inspector del nodo Enemy. El contador de vida segmentada expone fondo/borde/grosor; el burst del mapa permanente expone colores, cantidad, tamaño, distancia y duración; el confeti de resumen expone su tamaño.
5. Los 25 iconos de `assets/sprites/ui/icons/` limitan la textura importada a 256 px; la hoja del portal a 768 px y el cofre conserva el límite existente de 168 px. Se mantienen intactos los PNG fuente. La hoja del portal conserva dos píxeles importados por píxel de frame a su tamaño de dibujo de 96 px.
6. Se retiran los 26 PNG alternativos sin consumidor autorizados por el usuario, el marco antiguo de Tower Info, el script `SpawnPortalPreviewLayer` sin instancias y los Resources de enemigo/oleada M7/M8 sin selector ni prueba activa. Se conservan Armor Piercing Bolt, Sapping Bolt y Status Probe porque siguen disponibles en runtime con los atajos `8`, `9` y `0`.
7. No se modifica el combate, la economía, la campaña ni los Resources que alimentan el juego normal. Los procedimientos que dependían de F3 o de las oleadas retiradas quedan marcados como históricos; la aceptación vigente usa la campaña y los criterios M12A/M13/M63.

### Consecuencias

- El Inspector de las escenas relevantes expone las medidas de UI y los recursos de estilo que determinan la presentación en runtime.
- Se reduce memoria de texturas importadas para iconos y hojas grandes sin perder los originales de arte.
- El estado de implementación es M64; la aceptación visual en ventana sigue pendiente.
- El escaneo headless del editor y el smoke de tres frames de `game/main/main.tscn` terminaron con código 0, sin errores GDScript ni recursos faltantes. La aceptación en ventana se mantiene pendiente en [Progreso](IMPLEMENTATION_AND_QA.md#progress) y [Aceptación](IMPLEMENTATION_AND_QA.md#acceptance).

<a id='adr-0116'></a>
## ADR-0116 — Spritesheets de correr de enemigos

- Estado: aceptado por petición explícita del usuario; integración de arte completada, aceptación visual pendiente.
- Fecha: 2026-10-15.
- Sustituye: el arte estático anterior de los 26 enemigos canónicos.
- Fuentes: petición y orden de la lámina de contacto del usuario, 2026-10-15. La ruta `assets/sprites/enemies/new/` citada en la solicitud no existe en el checkout actual; los archivos fuente no están disponibles localmente, según la auditoría de sprites.

### Contexto

El juego necesita mostrar a todos los enemigos con su ciclo de correr desde que aparecen en el camino. Los nuevos archivos contienen cuatro poses por personaje en una cuadrícula 2×2. `EnemyData` ya reconoce una hoja horizontal de cuatro cuadros y `Enemy` ya los recorre a 8 FPS durante el estado `MOVING`.

### Decisiones

1. Sustituir el contenido de los 26 PNG de `assets/sprites/enemies/` por hojas de 512×128 px con cuatro cuadros de 128×128 px, transparencia, base común y escala uniforme por personaje.
2. Mantener los nombres y rutas canónicos que ya leen los `EnemyData`; así las 26 hojas quedan conectadas directamente a campaña, retratos y visuales de enemigos.
3. Los PNG fuente no se cargan desde runtime. Su conservación se solicitó al integrar los spritesheets, pero no se puede afirmar que estén conservados en este checkout: la carpeta no existe y el inventario solo encuentra los 26 archivos canónicos.
4. Mantener el arte orientado a la derecha y usar el espejo horizontal que ya aplica `Enemy` cuando la ruta avanza hacia la izquierda.
5. Mantener los valores existentes de `sprite_extent` por enemigo y la cadencia de animación de 8 FPS. Son decisiones de presentación configurables, no cambios de balance.
6. Mantener la animación activa mientras el enemigo está en `MOVING`, incluido desde el primer momento tras `configure()`; las fases de derrota o llegada al portal no reproducen la carrera.

### Consecuencias

- Los 26 recursos canónicos muestran animación de cuatro cuadros sin cambios en los datos de combate, velocidad o composición de oleadas.
- Cada frame tiene lienzo idéntico y el personaje se centra y alinea con una base común para evitar saltos de tamaño y posición entre poses.
- La reimportación de texturas y la aceptación visual/interactiva en ventana Godot siguen pendientes; no se ejecutaron pruebas en esta actualización.

### Mapeo de entrada

Según el orden de la lámina de contacto indicado por el usuario, de izquierda a derecha y de arriba abajo:

| Índice fuente | EnemyData / archivo de salida |
|---:|---|
| 1 | `tetrahedron` |
| 2 | `hexahedron` |
| 3 | `octahedron` |
| 4 | `dodecahedron` |
| 5 | `icosahedron` |
| 6 | `oogiehedron` |
| 7 | `vampire` |
| 8 | `jack_o_lantern` |
| 9 | `werewolf` |
| 10 | `oogie_von_oogovich_haunted` |
| 11 | `imp` |
| 12 | `blink_dog` |
| 13 | `demon` |
| 14 | `manticore` |
| 15 | `succubus` |
| 16 | `fallen_oogie` |
| 17 | `goblin` |
| 18 | `orc` |
| 19 | `armored_goblin` |
| 20 | `troll` |
| 21 | `armored_orc` |
| 22 | `battering_ram` |
| 23 | `cyclops` |
| 24 | `oogie` |
| 25 | `witch` |
| 26 | `bat` |

<a id='adr-0117'></a>
## ADR-0117 — Recorte del spritesheet de portal y outline de torres

- Fecha: 2026-10-15.
- Estado: código y documentación integrados; aceptación visual pendiente.
- Decisiones relacionadas: conserva la optimización de importación de ADR-0115 y refina el contorno compartido de ADR-0098.

### Contexto

ADR-0115 redujo la textura importada del portal a 768×384 px para conservar dos píxeles de textura por cada píxel de dibujo. `SpawnPortal` todavía usaba regiones fijas de 443×443 px, medidas de la imagen fuente de 1774×887. Esas regiones no coinciden con la textura ya reducida y recortan frames incorrectos. Además, las torres fijaban su outline blanco en 12 px, un grosor visual excesivo.

### Decisiones

1. Mantener intacto el PNG fuente y el límite de importación de 768 px.
2. Dividir la cuadrícula 4×2 calculando el tamaño de cada región a partir de `PORTAL_SPRITE_SHEET.get_size()`. El loop conserva los siete frames únicos a 10 FPS y omite el octavo, que repite el primero.
3. Reducir `outline_size_px` de los sprites de torre de 12 a 6, la mitad del grosor anterior. El shader, color, orientación, escala y orden del sprite permanecen iguales.
4. Añadir la comprobación visual de torres y frames del portal a M48.

### Consecuencias

- Cambiar el límite de importación no deja coordenadas de atlas desfasadas, siempre que se conserve la cuadrícula 4×2.
- La hoja de portal conserva su resolución importada optimizada y la animación usa regiones de 192×192 px.
- El contorno de torre conserva el estilo blanco existente con la mitad de grosor.
- Falta la revisión visual en una ventana Godot; no se ejecutaron pruebas automatizadas.

### Implementación

- `game/board/spawn_portal.gd`
- `game/towers/tower.gd`
- `assets/sprites/CONTENT_AND_ASSETS.md#sprite-catalog`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#acceptance`

<a id='adr-0118'></a>
## ADR-0118 — Reclutamiento garantizado y aleatorio en las ofertas

- Fecha: 2026-10-15.
- Estado: integrado en código y documentación; aceptación interactiva pendiente.
- Decisiones relacionadas: ADR-0062 define el catálogo y filtros de cards; ADR-0076 fija el roster de run; ADR-0093 conserva exactamente tres opciones.

### Contexto

`RunCardService` insertaba primero todos los reclutamientos elegibles y podía llenar con ellos los tres espacios. El jugador necesita poder reclutar una torre cuando tenga una disponible, pero las otras opciones deben seguir permitiendo mejoras globales y pasivas de torres que ya forman parte de la run.

### Decisiones

1. Mantener las ofertas programadas en exactamente tres cartas distintas.
2. Cuando haya al menos una torre desbloqueada que aún no se haya reclutado, seleccionar por peso y garantizar un reclutamiento en la oferta.
3. Sortear por peso y sin reemplazo los espacios restantes entre todas las cartas elegibles, incluidos otros reclutamientos. Limitar a dos el número total de reclutamientos de una oferta.
4. Mantener los filtros actuales de unlock permanente, roster de run para pasivas específicas, prerequisitos, peso y máximo por run. Las cartas de reclutamiento no elegidas continúan disponibles en futuras ofertas.
5. Si no hay reclutamientos elegibles, sortear los tres espacios normalmente entre las cartas elegibles.

### Consecuencias

- Una oferta con torres pendientes siempre permite incorporar una; nunca queda ocupada por tres reclutamientos.
- Las pasivas globales y las de torres ya reclutadas compiten aleatoriamente por los demás espacios con el resto del pool elegible.
- Los pesos y la semilla de la run siguen controlando el sorteo; no se mutan Resources compartidos.
- La aceptación de la distribución en una partida queda pendiente; no se ejecutó Godot ni se añadió una prueba automatizada en este cambio.

### Implementación

- `game/cards/run_card_service.gd`
- `docs/rogue_tower/PROJECT_SPEC.md`
- `docs/rogue_tower/PROJECT_SPEC.md#progression`
- `docs/rogue_tower/CONTENT_AND_ASSETS.md#content-roster`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#acceptance`

<a id='adr-0119'></a>
## ADR-0119 — Feedback de vida de la base

- Fecha: 2026-10-15.
- Estado: código y documentación integrados; aceptación visual pendiente.
- Decisiones relacionadas: ADR-0074 define la vida y derrota de Main Tower; ADR-0115 mantiene el HUD editable desde Inspector.

### Contexto

El HUD mostraba la vida de Main Tower como bloques de 10 HP y con una barra baja. La pérdida de un punto no era fácil de leer, y el estado crítico de la base no tenía una señal ambiental persistente.

### Decisiones

1. Aumentar aproximadamente un 50 % el tamaño del indicador de vida: alto de barra de 28 a 42 px y más ancho disponible en la fila superior izquierda. Mantener el estado `actual / máximo` y la pausa junto a la barra.
2. Dibujar un segmento independiente por cada HP, también cuando una mejora amplíe la vida máxima. Al perder uno o más segmentos, cada cuadro perdido hace un flash ámbar, se encoge y se desvanece durante 0,28 s.
3. Cambiar el color del relleno de forma continua según la proporción restante: verde a vida completa, ámbar a la mitad y rojo cerca de cero, usando los colores editables de Main.
4. Añadir una viñeta rojo oscuro a pantalla completa por detrás del HUD. Se activa con 3 HP, gana intensidad con 2 HP y con 1 HP mantiene una respiración lenta de amplitud baja (periodo de 2,8 s) para sostener tensión sin parpadear ni cubrir el centro de la pantalla.
5. Basar la viñeta en HP actuales absolutos y retirarla al superar 3 HP; las intensidades y parámetros visuales quedan editables desde Inspector.

### Consecuencias

- Cada golpe a la base tiene una representación discreta en la barra, mientras el degradado refuerza la tendencia de vida restante.
- Los umbrales de 3/2/1 HP mantienen una lectura estable aunque el máximo de vida aumente por Fortification.
- La viñeta queda debajo de HUD y no bloquea entradas. Al permanecer a 1 HP, su pulso lento y limitado evita el flash rápido o la vibración continua.
- Falta la revisión visual en ventana Godot; no se ejecutó Godot ni se añadieron pruebas en este cambio.

### Implementación

- `game/ui/segmented_health_bar.gd`
- `game/ui/base_health_vignette.gdshader`
- `game/main/main.tscn`
- `game/main/main.gd`
- `docs/rogue_tower/PROJECT_SPEC.md`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#acceptance`

<a id='adr-0120'></a>
## ADR-0120 — Control de velocidad de la partida

- Fecha: 2026-10-15.
- Estado: código y documentación integrados; aceptación visual e interactiva pendiente.
- Decisiones relacionadas: ADR-0061 define pausa; ADR-0112 fija el botón de pausa junto a la vida.

### Contexto

El jugador necesita acelerar oleadas y tiempos de espera de una run de tower defense sin alterar las reglas de combate ni cambiar de escena.

### Decisiones

1. Añadir un botón junto a Pausa en la fila de vida del HUD. Su texto muestra el multiplicador activo y alterna en este orden: ×1 → ×2 → ×3 → ×1.
2. Aplicar el multiplicador global con `Engine.time_scale`, para que procesos, física y temporizadores de gameplay avancen según la velocidad elegida.
3. La pausa modal detiene el gameplay y cubre los controles del HUD; conserva el multiplicador seleccionado para cuando la partida se reanude.
4. Empezar cada run en ×1 y restaurar ×1 cuando la escena de run sale del árbol, evitando filtrar la velocidad al menú o a otra escena.

### Consecuencias

- El jugador puede acelerar el ritmo de la partida desde el HUD y ver el valor activo en todo momento.
- Las animaciones y temporizadores que usan el reloj de juego también avanzan más rápido; la pausa conserva el valor elegido sin permitir interacción con los controles cubiertos del HUD.
- Falta inspección visual e interactiva en Godot; no se ejecutó el motor ni se añadieron pruebas.

### Implementación

- `game/ui/game_speed_button.gd`
- `game/main/main.tscn`
- `game/main/main.gd`
- `docs/rogue_tower/PROJECT_SPEC.md`
- `docs/rogue_tower/PROJECT_SPEC.md`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#progress`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#acceptance`

<a id='adr-0121'></a>
## ADR-0121 — Color y gradiente de fachadas de elevación

- Fecha: 2026-10-15.
- Estado: código y documentación integrados; aceptación visual pendiente.
- Decisiones relacionadas: ADR-0085 limita el dibujo a las dos fachadas delanteras; ADR-0092/0094 definen el estilo previo de sombreado.
- Sustituye parcialmente: los tintes multiplicativos oscuros y la diferencia de brillo por dirección de ADR-0094.

### Contexto

Las fachadas verticales de los hexágonos se veían casi negras en gran parte de su superficie. El usuario pidió aclararlas con colores concretos y conservar un gradiente negro que desaparezca desde la base hacia la parte superior.

### Decisiones

1. Mostrar en la parte superior de las fachadas Grass el color `#407850` y en las de Mountain `#3b3c41`. Los PNG de fachada actuales son rellenos planos `#406e4d` y `#646567`; el renderer los modula para alcanzar los nuevos tonos sin cambiar las texturas fuente.
2. Dibujar sobre cada quad de fachada un gradiente negro alfa: opaco en los vértices inferiores y completamente transparente en los superiores. El gradiente no se aplica a las tapas hexagonales.
3. Compartir los colores y el gradiente entre el tablero, `TerrainPiecePreview` y `TerrainPieceCardPreview`. Conservar geometría axial, dos caras delanteras, recorte de desnivel y orden Y-sort.

### Consecuencias

- La parte superior de cada cara elevada tiene el color especificado; el sombreado oscuro queda concentrado abajo y se desvanece suavemente hacia arriba.
- La diferencia de tinte superior entre las dos direcciones se retira; ambas caras usan el mismo color de terreno y gradiente vertical.
- Falta inspección visual de tablero, previews y miniaturas en Godot; no se ejecutó el motor.

### Implementación

- `game/board/terrain_visual_catalog.gd`
- `game/board/terrain_cliff_occluder.gd`
- `game/board/terrain_piece_preview.gd`
- `game/board/terrain_piece_card_preview.gd`
- `docs/rogue_tower/PROJECT_SPEC.md`
- `docs/rogue_tower/PROJECT_SPEC.md`
- `docs/rogue_tower/PROJECT_SPEC.md#terrain`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#progress`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#acceptance`

<a id='adr-0122'></a>
## ADR-0122 — Exploración del mapa, mar e islas decorativas

- Fecha: 2026-10-15.
- Estado: código/documentación integrados; la espuma animada y las islas decorativas no interactivas fueron sustituidas parcialmente por ADR-0123. Cámara, parallax y niebla siguen vigentes; aceptación visual e interactiva pendiente.
- Decisiones relacionadas: ADR-0005 define los controles iniciales de cámara; ADR-0109 mantiene el mar a pantalla completa y sincroniza sus coordenadas con la cámara; ADR-0084 conserva la retícula axial y el renderer 2D.

### Contexto

El mapa de la campaña puede crecer de forma indefinida en pantalla y el jugador puede alejarse del loop de expansión. El usuario pidió limitar gradualmente cámara y exploración, reforzar la lectura de mar/isla y añadir decoración insular sin afectar rutas ni expansión. Antes de implementar se confirmaron el rango de zoom completo en R45, el margen de paneo, las islas solo visuales, la densidad máxima y la niebla radial desde Main Tower.

### Decisiones

1. Conservar el `Camera2D`, zoom alrededor del cursor y `R` para volver a 1× y centrar el tablero. En R1, limitar el zoom a 0,82×–1,35× y el margen de paneo a 1,5 hexes. Ambos límites progresan por ronda hasta llegar en R45 al rango completo actual de 0,45×–2,5× y a 2,5 hexes de margen. Al confirmar terreno, los límites de paneo y los cálculos de exploración incluyen el tablero nuevo.
2. Mantener el agua en su `CanvasLayer -10`; desplazar sus coordenadas de cámara con un factor de parallax 0,62 para que el patrón avance más despacio que el mundo. Añadir variación lenta de onda. Dibujar espuma procedural rota solo en aristas exteriores sin celda vecina del tablero/islas visibles y anclarla a sus superficies; no se perfilan uniones internas.
3. Crear como máximo seis islas visuales por run, reproducibles por seed, en grupos conectados de 3–7 celdas. Se revelan de forma gradual en las rondas 8, 15, 23, 30, 38 y 45. Sus alturas visuales van de 0 a 2, usan la paleta/recursos de terreno ya existentes y viven fuera de `HexGrid`. No generan PATH, obstáculos, ocupación, construcción ni restricciones de expansión; se ocultan si el tablero confirmado se aproxima.
4. Añadir `MapFog` como overlay CanvasItem procedural, calculado en coordenadas de mundo desde `Main Tower`. Su radio cubre el punto más distante del tablero confirmado o de las islas decorativas visibles y un margen que progresa de 1,5 a 3 hexes entre R1 y R45; el borde es irregular y lleva trazos estilizados. La niebla aumenta la opacidad con la distancia, admite oscuridad casi total fuera de su radio y deja HUD/entrada/reglas intactos.
5. Mantener configurables en `Main` los límites iniciales de zoom, los márgenes de paneo/niebla, la distancia de transición y la rugosidad del borde. La elevación decorativa no modifica el contrato lógico: PATH 0, Grass 1–2, Mountain 2–3.

### Consecuencias

- El campo de cámara y de visión avanza con la campaña y se adapta a cada expansión, mientras el mar da una sensación de deriva y las costas quedan reconocibles.
- Las islas aportan silueta de archipiélago sin convertirse en terreno jugable ni cambiar la validación, el camino o la economía.
- La niebla limita visualmente la exploración lejana sin impedir paneo permitido, entradas o lectura del HUD.
- La revisión en Godot debe confirmar costuras/espuma, escala del parallax, límites del mouse/WASD, persistencia/reproducibilidad de islas, transición de niebla y legibilidad extrema. No se ejecutó el motor ni pruebas automatizadas en este cambio.

### Implementación

- `game/main/main.gd`
- `game/main/main.tscn`
- `game/main/wind_waker_water_background.gdshader`
- `game/main/map_fog.gdshader`
- `game/board/decorative_island_field.gd`
- `game/board/shoreline_foam_overlay.gd`
- `game/board/shoreline_foam.gdshader`
- `docs/rogue_tower/PROJECT_SPEC.md`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#progress`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#acceptance`

<a id='adr-0123'></a>
## ADR-0123 — Islas explorables, tesoros de cartas y borde costero

- Fecha: 2026-10-16.
- Estado: código y documentación integrados; aceptación visual e interactiva pendiente.
- Decisiones relacionadas: ADR-0122 conserva progresión de cámara, parallax y niebla; ADR-0084 define el renderer 2D sobre retícula axial; ADR-0118 fija la política de ofertas de run.

### Contexto

El usuario pidió que las islas incentivaran la exploración y pudieran localizarse antes de verlas, con un tesoro de cartas al descubrirlas. Aprobó usar el paneo como exploración, revelar la isla completa al ver una arista, mostrar una isla cercana desde el inicio y las otras cinco progresivamente, trasladar islas alcanzadas por expansiones, y pausar hasta elegir una oferta de tres cartas. También pidió retirar la espuma animada y anclar las torres por su base inferior.

### Decisiones

1. Mantener el agua con parallax lento de 0,62× de ADR-0122 y reemplazar la espuma animada por un borde blanco estático con distorsión Voronoi. Se dibuja solo en aristas sin celda vecina del tablero o de islas descubiertas; no se marcan costuras internas.
2. Crear seis islas conectadas por run, reproducibles por seed, fuera de `HexGrid`, con 3–7 hexes decorativos y alturas visuales 0–2. La primera se genera en R1 y al menos una de sus celdas queda a 8 hexes o menos de Main Tower. Las cinco restantes aparecen en R10, R19, R28, R37 y R45, en anillos axiales progresivos alrededor de la base.
3. Usar el centro de cámara como posición explorada. Cuando el punto medio de cualquier arista exterior de una isla entra en el rectángulo visible, marcar toda la isla como descubierta y crear su cofre. La brújula muestra dirección, distancia e identidad de cada isla/cofre pendiente cuando queda a 12 hexes o menos de la cámara.
4. Cada isla contiene un cofre reclamable con tres cartas del mismo pool, filtros, sorteo y panel de selección que las ofertas habituales. Abrirlo pausa el `SceneTree`; al escoger, entrega el efecto de la carta, marca el tesoro cobrado y reanuda la fase previa (`ROUND_PREP` o `COMBAT`). No consume, reemplaza ni cambia la programación de las ofertas de campaña cada tres rondas.
5. Si una expansión deja alguna celda insular a distancia axial 1 o menor del tablero, mover el grupo y su cofre a una posición segura en agua. La isla sigue descubierta y el tesoro no se pierde. Las celdas continúan fuera del grid lógico y no crean caminos, ocupación ni bloqueos.
6. Añadir `island_card_chest.png`, nuevo sprite generado para el proyecto con `treasure_chest.png` como referencia de estilo, madera y herrajes dorados más una gema turquesa. Anclar la base de ese sprite al centro del hex insular.
7. Anclar los sprites completos de torre y los ghosts por el punto medio de su borde inferior al centro del hex; todo el cuerpo crece hacia arriba y queda fuera de cualquier recorte de celda.

### Consecuencias

- El paneo comunica exploración: la brújula orienta al jugador, ver el litoral revela el grupo y cada tesoro da una elección bonus sin interferir con la progresión regular.
- El archipiélago sigue siendo presentación fuera de las reglas lógicas del terreno; las expansiones no pueden tragarse un tesoro pendiente.
- La espuma deja una silueta blanca texturada en costa sin animación y sin costuras entre hexes.
- El arranque de `main.tscn` en Godot 4.7 no presentó errores de análisis ni ejecución; queda un aviso de división entera en `data/enemies/enemy_data.gd:47`, fuera de este cambio. La inspección manual debe revisar generación por seed, brújula, revelado, recogida en preparación/combate, reanudación de fase, reubicación, oferta programada, contorno Voronoi y el anclaje de torres; no se ejecutaron pruebas automatizadas.

### Implementación

- `game/board/decorative_island_field.gd`
- `game/board/exploration_island_data.gd`
- `game/board/island_card_chest.gd`
- `game/ui/island_compass_indicator.gd`
- `game/cards/run_card_service.gd`
- `game/board/shoreline_foam_overlay.gd`
- `game/board/shoreline_foam.gdshader`
- `game/towers/tower.gd`
- `game/board/tower_build_ghost.gd`
- `assets/sprites/terrain/island_card_chest.png`
- `game/main/main.gd`
- `game/main/main.tscn`
- `docs/rogue_tower/PROJECT_SPEC.md`
- `docs/rogue_tower/CONTENT_AND_ASSETS.md`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#progress`
- `docs/rogue_tower/IMPLEMENTATION_AND_QA.md#acceptance`
