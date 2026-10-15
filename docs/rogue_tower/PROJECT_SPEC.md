# Rogue Tower — especificación del proyecto

Documento normativo de diseño y técnica. La sección de cada sistema es propietaria de sus reglas; los valores realmente ejecutados se consultan en código y Resources. El estado de integración y las comprobaciones viven en IMPLEMENTATION_AND_QA.md; las elecciones históricas se consultan en DECISION_HISTORY.md.

## Índice

- [Diseño global](#game-design)
- [Arquitectura](#architecture)
- [Modelos de datos](#data-models)
- [Terreno hexagonal](#terrain)
- [Combate](#combat)
- [Progresión](#progression)

<a id='game-design'></a>
## Diseño del juego y reglas globales

Esta página define la fantasía, el alcance y las reglas globales aprobadas. El [índice maestro](README.md#index) asigna un propietario único a cada regla de sistema; las páginas temáticas detallan su dominio sin crear versiones competidoras. Los ADR registran el motivo y el historial del cambio; [Progreso](IMPLEMENTATION_AND_QA.md#progress) describe implementación y [Aceptación](IMPLEMENTATION_AND_QA.md#acceptance) describe comprobaciones.

**Estado de implementación (2026-10-16, último hito M72):** M65 integra ciclos de correr para los 26 enemigos; M66 garantiza un reclutamiento elegible por oferta y sortea los espacios restantes con un máximo de dos reclutamientos; M67 amplía y segmenta la vida de la base, añade color progresivo y viñeta de baja vida; M68 permite velocidad ×1/×2/×3; M69 ajusta las fachadas Grass a #407850 y Mountain a #3b3c41 con gradiente; M70 añade progresión de cámara, parallax y niebla; M71 convierte seis islas en objetivos explorables con tesoro y brújula; M72 hace clicables y animados sus cofres, y dibuja espuma de costa blanca, más ancha, animada y alineada con la parte baja de las caras delanteras elevadas. M71 también introdujo el borde Voronoi y el anclaje de la base de los sprites completos de torre al centro del hexágono. La aceptación visual o interactiva de M65–M72 sigue pendiente. El estado completo y la prioridad de revisión viven en [Progreso](IMPLEMENTATION_AND_QA.md#progress); los criterios están en [Aceptación](IMPLEMENTATION_AND_QA.md#acceptance). ADR: [0116](DECISION_HISTORY.md#adr-0116), [0118](DECISION_HISTORY.md#adr-0118), [0119](DECISION_HISTORY.md#adr-0119), [0120](DECISION_HISTORY.md#adr-0120), [0121](DECISION_HISTORY.md#adr-0121), [0122](DECISION_HISTORY.md#adr-0122), [0123](DECISION_HISTORY.md#adr-0123) y [0124](DECISION_HISTORY.md#adr-0124).
### 1. Pitch
Tower Defense Roguelike de runs cortas/medias donde el jugador no solo construye torres: **construye el propio tablero que tendrá que defender**.

La referencia sistémica principal es Rogue Tower, reducida a un scope de demo pequeño. Los nombres canónicos y las equivalencias aprobadas están en [Nomenclatura](CONTENT_AND_ASSETS.md#canonical-names); compartir un nombre no importa las cifras ni la mecánica. La referencia visual/técnica del tablero es Urtuk: The Desolation: grid hexagonal lógica, arte 2D que simula volumen y elevaciones discretas.

### 2. Scope confirmado
- Motor: **Godot 4.7**.
- Género: Tower Defense + Roguelike.
- Demo: **45 rondas**, con la composición directa exacta de [la campaña](CONTENT_AND_ASSETS.md#campaign).
- Grid: hexagonal.
- Expansión del mapa: tras limpiar las rondas 1–44 se ofrecen tres piezas distintas de siete hexágonos como cards visuales. La ronda 45 completa la demo.
- El jugador coloca una pieza predefinida compuesta por **7 hexágonos**.
- La pieza puede rotarse en las 6 orientaciones hexagonales.
- Si contiene camino, sus conexiones deben ser válidas con el mapa existente.
- El mapa puede generar prolongaciones, bifurcaciones y convergencias.
- Cuatro niveles lógicos de altura: 0, 1, 2 y 3. Cada mapa/run fija la elevación de forma reproducible según seed, celda e identidad de oferta.
- Terrenos principales:
  - Path: altura 0, transitable por enemigos, no construible.
  - Grass: construible; altura 1 o 2.
  - Mountain: construible; altura 2 o 3.
- El rango y la distribución vigentes están en [terreno hexagonal](#terrain) y [ADR-0073](DECISION_HISTORY.md#adr-0073).
- Una torre en elevación h gana `+h` de daño base y `+0.5 × h` hexágonos de alcance. La elevación 0 no concede bonus. Sobre cada torre elevada aparece un indicador con su bonus de daño. Los costes de Mana siguen las reglas configuradas por cada torre y pueden aumentar con el daño.
- La base reserva una única celda axial para reglas y colisiones; conserva su PNG RGBA de 270×352 px y se estira solo en la presentación a 1,8 × el radio de huella de ancho por 2,8 × el radio de alto, manteniendo fijo el borde inferior del sprite. Es un parámetro visual provisional y no cambia la huella lógica de un hexágono. PATH siempre es altura 0; las seis celdas adyacentes a la base nunca superan elevación 1. Mountain no aparece junto a la base; una celda Grass adyacente queda en elevación 1.
- Tras una expansión, los huecos completamente encerrados dentro de la envolvente axial del mapa se rellenan al azar con Grass o Mountain. Una abertura PATH que funcione como salida/spawn nunca se rellena. El tablero inicial y cada expansión confirmada deben conservar al menos un spawn PATH exterior con ruta válida hasta Main Tower; la opción de colocar terreno se rechaza si el grafo candidato no cumple esa condición.
- Cada oferta de terreno incluye una pieza con una colocación comprobada que prolonga una ruta PATH existente. Se identifica como `EXTIENDE RUTA` y muestra una posición sugerida; la forma varía entre recta, curva y bifurcación. Si la pieza sugerida no es recta, la oferta no añade una recta como alternativa. Las miniaturas muestran terreno y obstáculos, sin ramificaciones ni flechas de conexión PATH. Durante la colocación, `Q`/`E` o Ctrl+rueda giran la pieza; la rueda sin Ctrl conserva el zoom incluso mientras se coloca terreno. Un panel grande muestra `Q / E` para rotar y `T` para buscar y confirmar automáticamente una posición legal, manteniendo las validaciones de grafo y continuidad. Antes de confirmar, los spawns que cerrarían permanecen visibles con una marca roja y el texto cuenta los cierres. Sin selección activa, el hover de una celda muestra un tooltip breve con tipo, estado de construcción, altura y sus bonos de torre. Ver [ADR-0072](DECISION_HISTORY.md#adr-0072) y ADR-0112.
- Los conjuntos conectados de Grass o Mountain brillan suavemente desde tres hexágonos; el resplandor es algo más intenso desde cinco. En esta fase es únicamente señal visual de combo, sin bonus de gameplay.
- Path, Grass y Mountain usan tres variantes PNG por terreno. Grass tiene un 25 % de probabilidad de generar un obstáculo y Mountain un 15 %; el pool runtime contiene ocho obstáculos. Cada uno de los props decorativos compatibles tiene un 10 % de probabilidad independiente por celda; la selección no repite un asset en la misma celda y conserva como máximo dos. Los props son solo visuales y no se pueden seleccionar ni modificar. Un obstáculo bloquea construcción igual que Path y no altera la navegación; se dibuja centrado y por delante de los props.
- Una pieza de expansión de siete hexágonos admite como máximo dos obstáculos en total. El tablero inicial admite como máximo un obstáculo en total y nunca en la base ni en sus seis vecinos. Ver [ADR-0079](DECISION_HISTORY.md#adr-0079) y [ADR-0087](DECISION_HISTORY.md#adr-0087).
- Una celda Grass/Mountain sin obstáculo tiene una probabilidad base del 1 % de generar un cofre. La mejora permanente «Suerte del explorador» añade cinco puntos porcentuales por nivel en cuatro niveles y queda limitada a 20 %. La tirada de una expansión ocurre al confirmar la colocación, no al elegir una pieza; las miniaturas y el ghost no muestran cofres. Si aparece, su sprite salta una vez y luego queda en la celda. Abrirlo entrega Gold; el valor inicial de 25 Gold es provisional y configurable. Los cofres no cambian la ruta ni se pueden construir hasta abrirlos. Al hacer hover, el cofre bota y recibe un resplandor dorado para invitar a recogerlo.
- El catálogo actual contiene cinco piezas de terreno originales y diez plantillas adicionales con mezclas de campo/montaña, macizos, lomos, giros, ramales y bifurcaciones. Cada pieza conserva siete hexágonos conectados; las conexiones PATH internas son recíprocas y la lógica axial valida la colocación.
- Los bordes hexagonales del hover atenúan progresivamente sus dos anillos axiales. No se dibujan sockets PATH sobre la celda resaltada; las flechas de flujo PATH avanzan hacia la base durante el juego normal y se ocultan al elegir y colocar una expansión para despejar el tablero. Cada salida alcanzable se representa con un sprite PNG independiente de portal pulsante, de silueta sencilla y sin etiqueta `SPAWN`; un contorno blanco de alfa permanece visible, como en los obstáculos, mientras el hover conserva su resplandor contextual. Ver [ADR-0098](DECISION_HISTORY.md#adr-0098).
- Las caras superiores forman polígonos hexagonales cerrados y su textura se recorta con UV por vértice, sin estirarse fuera de la tapa. Un único mapeo axial entero calcula las seis esquinas: las celdas vecinas obtienen exactamente las mismas coordenadas para cada vértice compartido. Las fachadas usan UV a escala estable. El preview y las miniaturas comparten la geometría y la regla de desnivel del tablero: cada fachada delantera cubre solo la diferencia de altura con su celda vecina; en el borde vacío llega al suelo. La tapa hexagonal permanece completa y ninguna pared invade su polígono. No se dibujan caras laterales/traseras, extrusión radial ni cierres de vértice. La cámara top-down isométrica permanece fija. Una copia texturada de cada tapa elevada se ordena por la superficie; las fachadas se anclan en el borde inferior expuesto, cubren a actores que pasan detrás y quedan debajo de los que pasan delante. Un tinte multiplicativo neutro oscurece progresivamente las tapas un 5 % por nivel lógico (h0 100 %, h1 95 %, h2 90 %, h3 85 %); por separado, las fachadas Grass/Mountain usan como tono superior #407850 y #3b3c41, respectivamente, con un quad negro que pasa de opaco abajo a transparente arriba, sin cambiar las tapas (ADR-0121). Esto no altera celda, navegación, alcance ni posición lógica. Los sprites de torre completos se anclan por el centro de su borde inferior (la base) al centro del hexágono y se extienden hacia arriba sin recortarse al contorno de la celda (ADR-0123). Al pasar el cursor por una casilla durante la selección/colocación de una torre, la ficha lateral y el ghost muestran el daño y el alcance efectivos de esa altura, incluidos los modificadores de run y permanentes; ambos usan la misma fórmula que la torre construida. El ghost distingue de forma intensa verde válido y rojo inválido. Las torres muestran siempre el radio de ataque efectivo al hacer hover o estar seleccionadas. Las sombras individuales proyectadas por sprites siguen desactivadas; un shader procedural animado de nubes sombrea de forma uniforme el mundo (terreno, base, torres, enemigos, obstáculos, props y portales) en una capa bajo el HUD. En una colocación válida los portales indican las salidas previstas del grafo candidato; al pasar el cursor por uno se perfila su sprite y su tooltip muestra la composición de enemigos de la siguiente ronda que usará esa salida. Al clicar un portal, el mismo listado queda visible en Tower Info hasta cambiar de selección y su tooltip se cierra. No se dibujan iconos de enemigos sobre el portal; la composición presenta retrato, nombre y cantidad por tipo según el reparto real de `WaveDirector`. Ver ADR-0112 y ADR-0114 para la selección, el feedback de colocación y el alcance de torre.
- Los VFX puntuales de combate, muerte, terreno y progresión quedan anclados a la posición del mundo que originó el evento mientras se reproduce su animación. Paneo y zoom los transforman junto al terreno/actores; se dibujan en una capa superior de feedback y no quedan pegados a la pantalla. El feedback UI de click permanece junto al cursor. Ver [ADR-0101](DECISION_HISTORY.md#adr-0101) y su corrección [ADR-0106](DECISION_HISTORY.md#adr-0106).
- Las tapas dibujan un contorno continuo por cada región conectada que comparte terreno y altura. Solo se trazan los bordes contra otra región o contra el vacío; las aristas internas entre celdas de la misma región permanecen ocultas. Si dos regiones distintas se tocan, cada una conserva su propio trazo: verde para Grass, gris para Mountain y amarillo para Path. Las miniaturas usan la misma regla y el hover conserva su contorno de interacción. Ver [ADR-0091](DECISION_HISTORY.md#adr-0091).
- Las paredes visibles de desnivel usan texturas separadas para roca y césped y se dibujan únicamente en las dos fachadas delanteras del hex. Cada pared cubre el desnivel respecto a su vecino, o llega al suelo cuando el borde está vacío; no invade las tapas hexagonales. No genera profundidad en las caras laterales/traseras ni vértices de cierre; las fachadas usan Grass #407850 o Mountain #3b3c41 y un gradiente negro que se desvanece de opaco abajo a transparente arriba. El efecto queda limitado a las paredes. La altura sigue siendo lógica 2D y las paredes participan en el orden de profundidad de unidades y props.
- Enemigos: el modelo de cada enemigo incluye las capas `Health`, `Armor` y `Shield`, con regeneración separada; cada perfil configura sus máximos y cero desactiva una capa para esa unidad. El daño directo afecta solo a la capa activa en orden `Shield → Armor → Health`. Cada torre usa su multiplicador de la capa activa. `Bleed` detiene la regeneración de `Health` y suma +1 al multiplicador de `Health` de los ataques; `Burn` hace lo mismo con `Armor`; `Poison`, con `Shield`. Los ticks usan el multiplicador completo en la capa asociada y la mitad en las otras. Enemy dibuja las barras de las capas presentes y segmenta la de `Health`. Esta regla sigue la mecánica de capas y estados descrita en Rogue Tower; el descarte del exceso al vaciar una capa y las cifras de contenido de la demo se mantienen configurables/provisionales. Ver [ADR-0023](DECISION_HISTORY.md#adr-0023).
- La campaña usa los 26 tipos de enemigo y los 1.093 enemigos directos de la tabla aprobada en [14 — Campaña de 45 rondas](CONTENT_AND_ASSETS.md#campaign). En las rondas 17 y 19 no hay designaciones especiales de Miniboss. Los perfiles normales adoptan las estadísticas individuales y habilidades enlazadas en Rogue Tower Wiki; la velocidad se convierte a 45 px/s por unidad RT y no escala por ronda. Ooogie von Ooogovich conserva balance propio y una fase Bat. Las invocaciones suman enemigos por encima del conteo directo; la oleada espera a que todos mueran o lleguen a base. Ver [ADR-0037](DECISION_HISTORY.md#adr-0037).
- Todo enemigo que aparece en el camino muestra su ciclo de correr desde el primer instante visible; los 26 usan una hoja canónica de cuatro poses. La forma técnica y las dimensiones del asset están en [Arquitectura](#architecture) y el inventario en [Auditoría de sprites](CONTENT_AND_ASSETS.md#sprite-audit); ver [ADR-0116](DECISION_HISTORY.md#adr-0116).
- Las siete torres jugables se llaman Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder.
- Frost Keep sigue el perfil de Rogue Tower: daño base 6, 180 RPM más 18 por PATH cubierto, copos de impacto individual, Slow equivalente al 50% del daño aplicado (cap 60, decaimiento 6/s) y drenaje continuo de 2 Mana/s durante combate. Tesla Coil empieza con 9 de daño base. Ver CONTENT_AND_ASSETS.md#content-roster y ADR-0059.
- Regla propia de Ballista: si el enemigo objetivo muere por otra fuente antes de que llegue el proyectil, la Ballista dueña del disparo recupera 33 % de la recarga completa, descontado del tiempo restante hasta cero. El tiro que mata por su propio impacto no reembolsa; el ciclo es independiente por torre y por disparo. Ver [ADR-0034](DECISION_HISTORY.md#adr-0034).
- Estados de torre `Bleed`, `Burn`, `Poison` y `Slow`; habilidades enemigas también aplican `Haste` y `Fortification`.
- Upgrade Cards durante la run, reducidas/simplificadas.
- Permanent Upgrades entre runs, reducidas/simplificadas.
- Las upgrade cards usan una superficie oscura sencilla, sin sprite ni marco por rareza. Un aura radial con partículas orbitantes cambia de color según la rareza; los valores positivos y negativos usan verde y rojo. Las reglas de oferta tienen propietario único en [Progresión](#progression).
- Al desbloquear permanentemente una torre, sus tres mejoras de daño contra Health, Armor y Shield quedan disponibles como ramas paralelas. Comprar una no exige ni bloquea las otras; el unlock de torre es el requisito común. Ver [ADR-0081](DECISION_HISTORY.md#adr-0081).
- Demoler una torre devuelve el precio marginal del slot que ocupaba, calculado con precio base, incremento y cantidad de ese tipo antes de retirarla. El nivel y las mejoras de la torre no cambian la devolución. Ver [ADR-0064](DECISION_HISTORY.md#adr-0064).
- El jugador recibe XP de perfil al acabar una run, incluso si pierde pronto. El saldo persistente compra desbloqueos de torres y mejoras permanentes. La interfaz de la tienda representa saldo, costes y recompensas únicamente con `assets/sprites/ui/icons/exp.png`, sin escribir «XP», «EXP» ni «experiencia» en pantalla.
- Desbloqueos permanentes iniciales: Ballista, Mortar y Tesla Coil. El roster construible de cada run empieza únicamente con Ballista; Mortar y Tesla Coil aparecen como cartas de reclutamiento en la primera oferta programada. Las demás torres se añaden a las ofertas de run futuras al desbloquearlas permanentemente y solo se construyen después de reclutarlas con una carta. Frost Keep, Flame Thrower y Poison Sprayer cuestan 50 XP de perfil cada una; Shredder cuesta 100. El reinicio completo de prueba restaura los tres desbloqueos iniciales. Ver [ADR-0069](DECISION_HISTORY.md#adr-0069) y [ADR-0076](DECISION_HISTORY.md#adr-0076).
- Una run empieza con 1.000 Gold; Starting Coffers añade 100 por nivel permanente, hasta 10 niveles y un máximo de 2.000 Gold. Gold sigue siendo temporal de run. Ver [ADR-0076](DECISION_HISTORY.md#adr-0076).
- `Mana` existe como recurso/sistema; la moneda de run se llama `Gold`.
- **No existen support buildings.**
- Mana y sus mejoras se obtienen mediante cards/permanentes/sistemas de progresión, no edificios de soporte.
- La base usa un sprite RGBA intercambiable desde `BaseData` y conserva la resolución PNG de origen. Su escala X/Y es independiente: actualmente se dibuja a 1,8 × el radio de huella de ancho por 2,8 × de alto, con el borde inferior fijo. Esta deformación visual es provisional; la huella hexagonal lógica sigue separada del arte. Ver [ADR-0096](DECISION_HISTORY.md#adr-0096).
- La base usa el outline blanco de dilatación alfa compartido por torres y obstáculos, con grosor reducido (`outline_size_px = 6`). Los enemigos usan el mismo shader a `outline_size_px = 2`, con un tono claro asignado por `EnemyData.id`; su contorno sigue el sprite al saltar, girar o transformarse y conserva el orden Y-sort. Las barras y estados permanecen delante del retrato. Los portales mantienen un borde blanco permanente con el valor 3 de los obstáculos, más el resplandor contextual de hover. Ver [ADR-0097](DECISION_HISTORY.md#adr-0097) y [ADR-0098](DECISION_HISTORY.md#adr-0098).
- Main Tower comienza con 10/10 HP. Fortification permanente añade +1 HP máximo por nivel, hasta 20/20 en nivel X, con costes de 20, 40, …, 200 XP (1.100 XP total); las cards de run Fortification I–III son independientes y cada una añade +3 HP máximo. Si un enemigo con `boss_tier > 0` alcanza la base, la run termina inmediatamente aunque aún quede HP. Ver [ADR-0074](DECISION_HISTORY.md#adr-0074).
- La vida de la base aparece arriba a la izquierda, en una barra de HUD ampliada aproximadamente un 50 %, con un segmento por HP, incluidos los máximos ampliados. Al perder vida, cada segmento desaparece con un breve flash y encogimiento; el relleno transita continuamente de verde a ámbar y rojo según la vida restante. Con 3 HP aparece una viñeta roja suave alrededor de la pantalla; aumenta con 2 HP y, con 1 HP, respira lentamente con baja amplitud para sostener la tensión sin entorpecer una run larga. El botón compacto de pausa comparte la fila de vida: muestra solo `P` junto al glyph de pausa/play y conserva la tecla `P`. Gold y Mana aparecen arriba a la derecha en paneles 9-slice idénticos, de 176 × 52 px, con icono y cifra del mismo tamaño. Cada cambio de Gold anima con escalado, rebote y vibración tanto el icono como la cifra, al ganar o gastar; abrir un cofre también activa el feedback aunque no se acepte Gold por estar al límite. Ver [ADR-0119](DECISION_HISTORY.md#adr-0119).
- Al recibir daño, el sprite de la base se tiñe brevemente de rojo y la cámara hace una sacudida corta. Durante ofertas de mejora y elección de terreno, un velo negro translúcido oscurece el tablero detrás de las cards; desaparece al seleccionar terreno para colocarlo y vuelve si se cancela y se muestra otra vez la oferta. Ver [ADR-0055](DECISION_HISTORY.md#adr-0055).
- La partida puede pausarse y reanudarse con `P` o con el botón de glyph situado junto a la barra de vida. El botón de iniciar ronda siempre quita la pausa cuando la fase es `ROUND_PREP`. Mientras se elige o coloca terreno, no se pueden seleccionar torres, iniciar rondas, abrir cofres ni usar controles de construcción; permanecen disponibles la elección/rotación/confirmación/cancelación de la pieza y la pausa. No existe panel de terreno/debug accesible con F3.
- En Tower Info, Daño, Rango, RPM y Crítico comparan el valor efectivo con el perfil de la torre: las bonificaciones de elevación y mejoras se colorean de verde, las reducciones de rojo y los valores iguales al perfil conservan el color normal. Los cambios de efecto en cards de run y nodos permanentes usan la misma lectura verde/rojo.
- `Escape` abre la escena de pausa, con acciones para reanudar o volver al menú principal. La derrota cambia a la escena de menú y abre automáticamente la tienda; el menú, la run y la pausa son escenas separadas. El Game Over resume por tipo únicamente las torres construidas durante esa run, con la cantidad desplegada y el daño acumulado; las torres desbloqueadas pero no construidas no aparecen. Ver [ADR-0076](DECISION_HISTORY.md#adr-0076) y ADR-0114.
- El Mana se repone hasta su máximo efectivo al iniciar cada ronda de campaña y el HUD muestra valores enteros, sin decimales.
- El control de ronda muestra siempre 15 puntos de las 45 rondas, sin selector de tamaño. La ronda actual queda al inicio mientras haya espacio; al final se muestra 31–45 para conservar los 15 puntos. El extremo futuro se desvanece y los círculos conservan el hover de unidades y conteos. El botón de iniciar ronda usa un sprite 9-slice y se ajusta al texto. Ver [ADR-0083](DECISION_HISTORY.md#adr-0083).
- Las tres cards para expandir el tablero usan superficies planas oscuras y un borde fino que indica hover o selección, sin marcos decorativos ni panel compartido. El preview ocupa la mayor parte de cada card; debajo aparece el conteo de `Path`, `Grass` y `Mountain`, omitiendo cualquier tipo con cero celdas.
- Los botones de torre disponibles en la run tienen fondo propio con estilo de carta, un indicador de tecla y un panel horizontal compartido para su precio de Gold. Solo aparece Ballista al iniciar; las demás se muestran tras ser reclutadas y Ballista usa la tecla 1 y las nuevas torres reciben en orden las teclas siguientes (2, 3, 4…) según el roster visible. Las mejoras permanentes usan un mapa desplazable de nodos conectados y una tarjeta común: los siete desbloqueos de torre están en una misma fila y cada uno habilita sus nodos Health, Armor y Shield en paralelo, elegibles en cualquier orden. Cada nodo muestra icono temático; el precio presenta la cifra centrada y `exp.png` a su derecha. Los tooltips explican requisitos y las partículas confirman cada desbloqueo. Ver [ADR-0077](DECISION_HISTORY.md#adr-0077), [ADR-0107](DECISION_HISTORY.md#adr-0107) y ADR-0114.
- El panel lateral de torre usa una superficie plana y compacta, se ajusta a su contenido, no tiene scroll y reduce su escala si la ventana no permite el alto natural. El retrato pequeño comparte cabecera con el nombre y el nivel. En build mode muestra las estadísticas y el bonus medido de Mountain frente a Grass; no repite instrucciones del preview. Health, Armor y Shield conservan icono, nivel, barra de XP de 88 × 8 px y precio en una fila horizontal de tres botones cuadrados; sus iconos son grandes. Demoler una torre u obstáculo usa `demolish_tower_icon.png` y muestra el texto `DEMOLER`. El botón de torre informa el reembolso marginal con icono Gold y signo `+`; el de obstáculo muestra el coste de retirada con icono Gold y signo `−`. Los portales indican `RETIRAR` y su coste. El reembolso de una torre depende del precio marginal del slot ocupado según tipo/conteo, sin incluir niveles (ADR-0064). Ver [ADR-0039](DECISION_HISTORY.md#adr-0039), [ADR-0064](DECISION_HISTORY.md#adr-0064), [ADR-0107](DECISION_HISTORY.md#adr-0107) y [ADR-0111](DECISION_HISTORY.md#adr-0111).
- Los PNG de juego se organizan bajo la raíz común `assets/sprites/`, en subcarpetas para base, enemigos, terreno, UI y recursos licenciados. Cada torre carga su PNG completo de `assets/sprites/ui/icons/` sin recortar regiones. El centro del sprite coincide con el centro lógico de la celda y el arte se desplaza 8 px hacia abajo; mundo y ghost usan escala 0,9504 × 1,12, las cards muestran 126×126 px y Tower Info 152×176 px. Estos tamaños son solo visuales y no cambian ocupación ni colisión. Los perfiles usan enemigos estándar de 72 px con jefes configurados por separado, obstáculos de 208×208 px dibujados a 94,6×94,6 px, props de 96×96 px dibujados a 39,6×39,6 px con 10 % de probabilidad independiente por asset/celda y base de 270×352 px mostrada a 1,8 × el radio de huella de ancho por 2,8 × el radio de alto, sin remuestrear el PNG. El portal usa siete cuadros no repetidos del spritesheet 4×2 a 96×96 px y asigna fases distintas por endpoint. Props y unidades comparten ordenación Y por profundidad; el obstáculo se dibuja por delante de los props. Las fachadas elevadas también participan en Y-sort: cubren unidades detrás y quedan debajo de unidades delante. La paleta/gradiente de fachada pertenece a [Terreno hexagonal](#terrain); no se repiten sus colores aquí. El contorno de región de terreno agrupa por tipo y altura, tiene uniones redondeadas y usa un color plano: Grass `#406e4d`, Mountain `#646567` y Path amarillo. Nada de esto cambia la ocupación hexagonal, alcance, selección lógica, colisiones ni movimiento. Ver [ADR-0087](DECISION_HISTORY.md#adr-0087), [ADR-0089](DECISION_HISTORY.md#adr-0089), [ADR-0091](DECISION_HISTORY.md#adr-0091), [ADR-0095](DECISION_HISTORY.md#adr-0095), [ADR-0096](DECISION_HISTORY.md#adr-0096), [ADR-0104](DECISION_HISTORY.md#adr-0104) y [ADR-0105](DECISION_HISTORY.md#adr-0105).
- Patrick Hand es la fuente predeterminada del proyecto y se usa en la interfaz, incluidos los textos dibujados manualmente. Se distribuye con su licencia SIL Open Font License 1.1. Ver [ADR-0054](DECISION_HISTORY.md#adr-0054).
- Las rutas muestran flechas animadas en sus bifurcaciones, avanzando hacia la base; el flujo se calcula desde `PathGraph` y no altera el recorrido del enemigo. Los disparos e impactos de las siete torres, los seis estados usados, el daño a la base y los feedback de muerte, cofre, nivel, clic, terreno y Game Over usan las hojas locales de `assets/sprites/ui/Cozy_Chunky/`; sus eventos y mapeos están en [ADR-0101](DECISION_HISTORY.md#adr-0101) y la cadencia/escala actual en [ADR-0102](DECISION_HISTORY.md#adr-0102). El puntero distingue estado normal, hover interactivo, acción inválida y colocación de torre. Los cursores Tiny Swords siguen como dependencia local con licencia que impide incluir sus PNG fuente en Git; ver [ADR-0040](DECISION_HISTORY.md#adr-0040), [ADR-0041](DECISION_HISTORY.md#adr-0041) y [Origen](CONTENT_AND_ASSETS.md#origin-and-sources).

### 3. Core loop
1. Comienza run.
2. Cargar desbloqueos y mejoras permanentes.
3. Preparación de ronda.
4. Oleada: cada grupo genera exactamente la cantidad directa indicada; las unidades se reparten round-robin entre los endpoints PATH alcanzables.
5. Jugador construye/mejora torres y administra recursos.
6. Resolver victoria/derrota de ronda.
7. Si sigue vivo: recompensa de ronda.
8. Tras limpiar rondas 1–44, ofrecer tres cards visuales de piezas distintas de siete hexágonos; la ronda 45 es el final.
9. Rotar y colocar la pieza elegida legalmente; `Esc` vuelve a la misma oferta.
10. Cerrar con Grass/Mountain los huecos interiores, resolver nuevas conexiones/rutas y activar todas las salidas PATH abiertas.
11. Fase de carta/mejora cuando corresponda.
12. Siguiente ronda.
13. Ronda 45 superada = demo completada.
14. Al perder o completar: otorgar XP de perfil.
15. Volver a tienda/meta.
16. Comprar mejoras/desbloqueos.
17. Nueva run.

### Cartas de mejora durante la run
Las cartas `CardData` se ofrecen tras colocar terreno después de las rondas 3, 6, 9, …, 42 y antes de la ronda siguiente; al completar la 45 no hay otra oferta. Cada oferta tiene tres opciones y bloquea el avance hasta elegir. La elegibilidad, reclutamiento garantizado, sorteo de las demás cartas y filtros son propiedad de [Progresión](#progression). Las cartas afectan solo a esa run; los Resources y sus cifras se indexan en [Catálogo](CONTENT_AND_ASSETS.md#content-roster).

### Reglas confirmadas y decisiones provisionales de combate
- `EnemyData` y cada instancia runtime de Enemy modelan `Health`, `Armor` y `Shield`, con regeneración independiente. Los tres pools tienen valores por perfil; un máximo cero indica que ese enemigo no usa esa capa. La capa activa es `Shield → Armor → Health`.
- La torre aplica daño base por el multiplicador de la capa activa. Sigue sin decidirse si el excedente al vaciar una capa pasa a la siguiente; el código lo descarta provisionalmente y no se considera regla confirmada.
- `Bleed`/`Burn`/`Poison` detienen la regeneración de `Health`/`Armor`/`Shield` correspondiente. Sus ticks causan daño completo en la capa asociada y la mitad en las otras; además, los ataques directos contra un enemigo afectado ganan +1 al multiplicador de esa capa, una sola vez mientras el estado esté activo, sin escalar por acumulaciones. El modelo y la barra de las tres capas se implementaron en M12A. Los perfiles normales de Rogue Tower adoptan sus parámetros base sin crecimiento por ronda; el balance de los jefes y Ooogie propio, además de la política de daño excedente descrita en ADR-0023, sigue configurable/provisional.
- Cada nivel de torre añade +1 de daño base y +1 a un multiplicador de capa elegido; el XP de mantener un objetivo en rango añade el mismo incremento según el HP actual de ese enemigo. La ganancia automática de XP de seguimiento usa un multiplicador ×5 respecto de la fórmula base, y las subidas automáticas emiten el mismo efecto visual de nivel que las manuales. Elevación añade +1 daño y +0.5 de rango por nivel. Estos valores y la tabla H/A/S/RPM/Mana/precio que pegó el usuario son el perfil inicial de la demo y siguen configurables. Ver [Progresión](CONTENT_AND_ASSETS.md#progression-audit) y [ADR-0107](DECISION_HISTORY.md#adr-0107).
- Se pueden escoger hasta tres prioridades de target en orden; por defecto solo se presenta la primera y un botón `+` revela cada selector secundario, que desempata al anterior. El cambio de orden intercambia los criterios afectados. Las mejoras Health/Armor/Shield progresan de forma independiente: cada capa admite 15 subidas, hasta 45 mejoras totales por torre. El XP automático y el coste Gold de cada capa tienen curvas exponenciales configurables; cada mejora añade +1 de daño base y +1 al multiplicador de la capa escogida. Los tres botones muestran su nivel y una barra de XP de esa capa. Críticos avanzan por bandas ×2/×3/×4 hasta 150%; precios de construcción crecen por cantidad del mismo tipo y Frost Keep acelera por PATH cubierto. La selección pulsa en la card inferior y en el sprite con brillo recortado; el panel de información permanece quieto y el radio de ataque se muestra con un anillo de alto contraste al hacer hover o seleccionar la torre (M63/ADR-0114). Ver [ADR-0023](DECISION_HISTORY.md#adr-0023), [ADR-0046](DECISION_HISTORY.md#adr-0046) y [ADR-0047](DECISION_HISTORY.md#adr-0047); esta fuente conserva abierta la regla de overkill.
- Las rondas 17 y 19 siguen la tabla de composición directa y no marcan Minibosses. Ooogie von Ooogovich invoca dos Bats cada 2 s y se transforma en Bat con 2.500 Health como fase final; su balance es provisional y la recompensa se conserva hasta la derrota final. Fallen Ooogie y Ooogiehedron tienen las habilidades de invocación encadenadas registradas en el catálogo.

### 4. Fantasía estratégica
El mapa debe ser una decisión. Una pieza puede:
- aumentar la longitud de una ruta;
- abrir una bifurcación peligrosa;
- crear una convergencia/kill zone;
- dar una posición elevada excepcional;
- ampliar superficie construible;
- introducir un nuevo punto de entrada.

No debe existir una única decisión obvia en todas las expansiones.

### 5. Dificultad
Objetivo: conservar la sensación de presión de Rogue Tower. La progresión permanente debe ayudar, pero no sustituir la toma de decisiones.

Principio: un jugador nuevo probablemente no completa la run. Las derrotas alimentan meta-progresión y desbloqueos.

### 6. Sistemas deliberadamente fuera de scope
- Support buildings.
- Campaña narrativa compleja.
- Multijugador.
- PvP.
- Mundo 3D real.
- Terreno 3D/meshes como base del tablero.
- Generación procedural libre de geometría: las piezas son plantillas diseñadas.
- Más de 45 rondas en esta demo.
- Contenido final masivo antes de validar vertical slice.

### 7. Decisiones todavía abiertas
No inventar como definitivas:
- Número total de torres del juego final. Para la demo, el usuario confirmó siete perfiles jugables en ADR-0014.
- Roster final de enemigos.
- Lista final de status.
- Fórmula exacta de altura.
- Rarezas y valores finales de Upgrade Cards; su oferta está fijada en tres cartas y la oferta de expansión continúa usando tres piezas.
- Economía/balance numérico final.
- Número exacto de piezas de terreno.
- Balance final de Ooogie von Ooogovich y Tesla Coil; sus parámetros actuales son configurables y provisionales. La caída/contacto del copo de Frost Keep también queda configurable, pendiente de aceptación manual.
- Balance definitivo para múltiples entradas sigue pendiente. La demo asigna los enemigos de cada ronda en orden round-robin global entre endpoints PATH alcanzables; reinicia el reparto al iniciar cada ronda. La vista previa por portal refleja exactamente esa política.
- Arte/temática final.

### Terreno interactivo y lectura de altura

Durante `ROUND_PREP`, el jugador puede seleccionar cualquier obstáculo y consultar su nombre en el panel, o pagar para quitarlo. La retirada n cuesta `25 × n²` Gold, donde n es su ordinal dentro de las retiradas de obstáculos de la run: 25, 100, 225, 400… Los portales muestran por clic una lista de los tipos de enemigos asignados, con sus sprites. Se permite quitar un portal si quedan más de tres; cuesta el doble del siguiente precio de obstáculo y los enemigos de la oleada se redistribuyen entre los endpoints restantes. La elevación lógica vigente va de 0 a 3, con 28 px visuales por nivel; la distribución por terreno y el bonus de torre pertenecen a [terreno hexagonal](#terrain) y [ADR-0073](DECISION_HISTORY.md#adr-0073).

Para el prototipo usar valores temporales centralizados y fáciles de sustituir.

### 8. Velocidad de la partida

El jugador puede alternar la velocidad global de la simulación entre ×1, ×2 y ×3 con el botón junto al control de pausa. El botón muestra el multiplicador activo. Pausar detiene la partida y conserva la velocidad elegida para cuando se reanude; una run nueva comienza en ×1. Ver [ADR-0120](DECISION_HISTORY.md#adr-0120).

<a id='architecture'></a>
## Arquitectura técnica

### Enfoque
**2D real con falsa elevación visual.** La elevación es un dato lógico (`0..3`), no una coordenada Z 3D. El modelo de terreno, su generación y las torres rechazan niveles fuera de ese rango.

Usar escenas para entidades y custom Resources para datos. Mantener los datos de contenido fuera de la lógica.

### Estructura propuesta

```text
res://
  autoload/
    game_state.gd
    run_manager.gd
    meta_progression.gd
    save_manager.gd
  core/
    hex/
      hex_coord.gd
      hex_math.gd
      hex_cell.gd
      hex_grid.gd
    modifiers/
      modifier.gd
      modifier_stack.gd
  data/
    terrain/
    towers/
    enemies/
    run/
      run_economy_data.gd
      run_economy_m9.tres
    status_effects/
    waves/
    cards/
    upgrades/
  game/
    menu/
      main_menu.tscn
      pause_menu.tscn
    main/
      main.tscn
      main.gd
    progression/
      meta_shop_panel.tscn
      meta_progression_map.tscn
      meta_upgrade_node.tscn
    board/
      board.tscn
      board.gd
      terrain_renderer.gd
      terrain_piece_preview.gd
      path_graph.gd
    combat/
      damage_service.gd
      status_effect_controller.gd
    enemies/
      enemy.tscn
      enemy.gd
    towers/
      tower.tscn
      tower.gd
      projectile.tscn
      projectile.gd
    waves/
      wave_director.gd
    economy/
      run_economy_service.gd
    build/
      build_controller.gd
    cards/
      card_system.gd
    ui/
      hud.tscn
      terrain_choice.tscn
      card_offer.tscn
      shop.tscn
      run_end.tscn
  assets/
    terrain/
    base/
    towers/
    enemies/
    ui/
  tests/
  docs/
```

### Main scene
```text
Main (Node2D)
├── Board
│   ├── PiecePreview (suelo y caras superiores)
│   ├── PathFlowOverlay
│   ├── Entities (Y-sort)
│   │   ├── GameBase
│   │   ├── Tower instances (M6)
│   │   ├── Enemy instances
│   │   ├── Props and spawn portals
│   │   └── Terrain cliff occluders
│   ├── Projectiles
│   └── Effects
├── WaveDirector
├── BuildController
├── DamageService (escena-local; inyectado a las torres)
├── RunEconomyService (escena-local; Gold/Mana de esta run)
├── Camera2D
├── CanvasLayer
    └── HUD
└── BuildCursorLayer (CanvasLayer superior; cursor visual al construir)
```

`BuildController` configura cada torre en el centro axial de su celda; `Tower` aplica la escala de mundo vigente `0,9504 × 1,12` y el ghost usa la misma escala y ancla. M55 la reduce un 10 % respecto a M54. El offset artístico de apoyo está emparejado en ambas presentaciones y no desplaza la posición de combate ni la celda ocupada.

`TerrainPiecePreview` y las miniaturas dibujan las fachadas delanteras y las tapas con la misma geometría axial. La elevación desplaza la superficie sin cambiar la prioridad de profundidad del grid. `HexMath` define una retícula entera de vértices pointy-top; tapas, fachadas, hover y copias Y-sorted derivan de sus claves axiales compartidas, sin repetir cálculos trigonométricos que puedan separar vértices contiguos. Solo las fachadas delanteras 1 y 2 generan paredes. Cada quad cubre la diferencia de altura con la celda vecina; si el borde no tiene vecino, llega al suelo. Ninguna pared invade una tapa hexagonal, y no se generan cierres de esquina, grosor radial ni caras laterales/traseras. Las fachadas usan las texturas Grass/Mountain y el degradado se limita a sus vértices, nunca a las tapas superiores. `TerrainPiecePreview` mantiene además una copia texturada por cada hex elevado como nodo hijo de `Entities`; su origen de Y-sort es el centro axial proyectado a la altura de la celda para interponerse entre objetos detrás y delante de esa superficie. Cada fachada se ordena desde su borde inferior para cubrir actores que pasan detrás y quedar detrás de los que pasan por delante. En empates entre copias elevadas, la Y de suelo y las coordenadas axiales resuelven el orden de forma estable; las copias permanecen antes que actores y props. Un preview válido de expansión deriva endpoints del `PathGraph` candidato y traslada los portales a sus coordenadas exteriores antes de confirmar. `Main` distribuye la composición de la `WaveData` por endpoint usando la misma política que `WaveDirector`; cada portal recibe sus tipos y cantidades para mostrar retratos, nombres y cantidades en un tooltip al hover; no dibuja iconos de enemigos sobre el portal. Cada opción de terreno es una copia por oferta con obstáculos fijados; miniatura y ghost los muestran, pero el cofre solo se sortea al confirmar la pieza. La cuadrícula y los sockets PATH se dibujan bajo demanda al hacer hover (celda actual y dos anillos con opacidad decreciente); el `PathFlowOverlay` continúa mostrando el flujo de ruta. Si no hay torre ni pieza seleccionadas, `Main` presenta un tooltip compacto con terreno, estado de construcción, elevación y bonificación de las torres compatibles, calculada desde `TowerData`; desaparece al activar selecciones o paneles contextuales. Ver [ADR-0090](DECISION_HISTORY.md#adr-0090).

Las tapas además dibujan contornos por región `(terrain_type, elevation)`: se omiten lados compartidos por celdas de la misma región y se incluyen los límites contra terreno distinto y vacío. Cada lado conserva el color de su propia región, y la misma geometría se usa en el tablero, las miniaturas y las superficies elevadas Y-sorted. El hover sigue usando su contorno de interacción independiente. Ver [ADR-0091](DECISION_HISTORY.md#adr-0091).

Las fachadas elevadas se dibujan como quads texturizados, con PNG intercambiables separados para roca y césped, usando los vértices exactos de la retícula axial. Solo las dos aristas delanteras generan paredes: cada una cubre el desnivel respecto a su vecina y llega al suelo si no hay celda vecina. No se calculan paredes en aristas laterales/traseras ni polígonos de cierre; ninguna pared invade las tapas hexagonales. Las fachadas usan Grass #407850 o Mountain #3b3c41; un quad negro superpuesto se desvanece en alfa de opaco abajo a transparente arriba, exclusivamente en estas paredes (M69/ADR-0121). El HUD mantiene salud y atajos en la esquina superior izquierda, Gold/Mana en la esquina superior derecha y el progreso de ronda centrado. `RoundProgressStrip` recibe los 45 `WaveData`, muestra una ventana fija de 15 rondas y construye tooltips con los retratos y conteos agrupados del `EnemyData` real; en el tramo final conserva visibles las rondas 31–45. Las cards de expansión resumen las cantidades de terreno por tipo y usan las mismas tapas hexagonales, fachadas texturadas y orden de celdas que el tablero.

El portal es una escena sustituible con un `AnimatedSprite2D` que recorre en bucle siete frames del atlas 4×2 `assets/sprites/terrain/spawn_portal_SpriteSheet.png` a 10 FPS; el octavo cuadro se omite porque duplica el primero. Se dibuja a 96×96 px y lleva una capa outline-only blanca permanente mediante `interactable_outline.gdshader`, con `outline_size_px = 3`, igual que los obstáculos. La capa sigue el frame y la escala de pulso; el contorno/resplandor contextual de hover, candidato y cierre queda por encima. El inicio de cada portal se desfasa de manera determinista por endpoint; al cerrar o retirar un portal se limpia su hover y tooltip antes de mostrar otras ofertas. `assets/sprites/terrain/spawn_portal.png` queda como icono estático del panel de selección. El cursor pequeño usa una `TextureRect` sobre CanvasLayer, oculta temporalmente el puntero nativo solo durante la colocación y lo restaura al volver a la interfaz. Las flechas se dibujan por arista real de `PathGraph`, con fase de animación continua hacia la base; se descarta un shader espacial basado en UV de voxels porque no representa directamente las ramas axiales compartidas.

La tienda permanente vive en `MetaShopPanel` como escena superpuesta tanto al menú como al resultado de run. El mapa (`MetaProgressionMap`) es un `Control` de gran tamaño dentro de `ScrollContainer`; el panel gestiona el arrastre izquierdo/central y delega la selección de nodos a sus botones. La escena conserva únicamente encabezado, saldo, mapa y cierre fijo arriba a la derecha; el inicio de run pertenece al menú. Cada unlock de torre conecta con los tres nodos H/A/S en paralelo, colocados horizontalmente y con sus iconos del `IconCatalog`.

### Estado de la run
`RunManager` controla una máquina de estados:

```text
RUN_SETUP
ROUND_PREP
COMBAT
ROUND_REWARD
TERRAIN_EXPANSION
CARD_OFFER
ROUND_TRANSITION
RUN_VICTORY
RUN_DEFEAT
```

Las UI reaccionan al estado. No permitir construcción/colocación cuando el estado no corresponda.

### Comunicación
Preferir señales para eventos:
- `round_started(round)`
- `round_completed(round)`
- `enemy_killed(enemy: Enemy)` — señal local `WaveDirector` → `Main`; la recompensa se emite aparte como `reward_earned(amount, reason)`.
- `base_damaged(amount)`
- `terrain_piece_placed(piece)`
- `paths_changed()`
- `tower_built(tower)`
- `card_selected(card)`
- `run_ended(result)`

Evitar dependencias circulares.

### Datos
Custom Resources:
- TerrainPieceData
- TowerData
- EnemyData
- WaveData
- CardData
- PermanentUpgradeData
- StatusEffectData

Esto permite editar contenido desde Inspector sin cambiar scripts.

### Pathfinding
El mapa es discreto. No usar NavigationRegion2D como fuente primaria para el camino de enemigos. Mantener un **grafo lógico de celdas Path** y resolver rutas en ese grafo. Es más determinista para bifurcaciones, convergencias y colocación dinámica.

M4 implementa `PathGraph` como `RefCounted` y usa BFS propio porque todos los enlaces actuales tienen coste uniforme. Cada nodo representa el `HexCoord` axial de una celda PATH; una arista exige sockets complementarios recíprocos en `path_edges | flexible_path_edges`. Un socket flexible sin pareja no crea una arista. Las salidas exactas abiertas fuera del tablero son candidatos de spawn; el tablero de campaña define la base en `(-1,0)` y una ruta recta en `StartingBoardData`, según [ADR-0056](DECISION_HISTORY.md#adr-0056). `PathGraph` produce una `PathRoute` determinista por candidato y preserva las bifurcaciones/convergencias en su adyacencia; no activa oleadas ni selecciona los spawns activos.

La escena conserva el snapshot activo del grafo al iniciar y al confirmar una pieza. Mientras se mueve un ghost geométricamente válido, `Main` crea un snapshot candidato separado que incluye los futuros hexes y los huecos que se cerrarían; `TerrainPiecePreview` lo compara con el grafo activo para marcar spawns que continúan, aparecen o se cierran. Esta vista previa no muta el tablero ni reemplaza el grafo activo. El botón de confirmar requiere que el candidato pase la misma validación de base, salidas emparejadas, rutas de spawn y conectividad PATH. El overlay debug de rutas lo dibuja `TerrainPiecePreview` al pulsar `Ctrl+D`; el grafo sigue siendo la autoridad lógica y el preview solo lo representa. La decisión base está en [ADR-0007](DECISION_HISTORY.md#adr-0007) y la vista previa de spawn en [ADR-0029](DECISION_HISTORY.md#adr-0029).

`PathGraph` conserva el conjunto runtime de endpoints retirados y expone `get_active_routes()`. El jugador puede quitar portales en preparación mientras queden más de tres; el coste es el doble del coste actual de obstáculo. `WaveDirector` y los previews usan solo las rutas activas y conservan el total de enemigos de `WaveData`, repartiéndolos round-robin entre esos endpoints. El estado de endpoints retirados y el contador de obstáculos limpiados duran solo una run.

AStar2D podría sustituir BFS si las rutas adquieren costes diferentes; si se usa, los IDs deben representar HexCoord. No incorporar NavigationRegion2D al modelo lógico.

### Rendering
No hacer que la lógica dependa de TileMapLayer. `HexGrid` es la autoridad.

TileMapLayer puede utilizarse como renderer/optimización más adelante, pero para el vertical slice es válido renderizar cada celda mediante nodos/sprites si facilita cliffs y elevación. Mantener una interfaz de renderer para poder optimizar sin reescribir gameplay.

El preview M2 actual dibuja polígonos vectoriales temporales desde `TerrainPieceCellData`: aplica offset por elevación, genera caras laterales en desniveles, ordena las caras superiores por profundidad lógica y detecta hover sobre esas caras. No depende de sprites finales. Las caras no dibujan iniciales ni coordenadas; el hover comunica tipo/altura/coordenada axial al HUD y cambia el color según terreno. Los clusters conectados de Grass/Mountain reciben feedback luminoso de combo 3/5 solo visual. La escena principal incluye un contenedor `Entities` con Y-sort habilitado para actores.

La separación visual de cada nivel lógico se fija en 28 px, compartida por terrenos, overlays, fantasmas y torres. PATH usa 0, Grass usa 1–2 y Mountain usa 2–3; las alturas se asignan de forma reproducible por seed/identidad de oferta. El preview conserva el dato al confirmar. Las torres reciben +1 daño base y +0.5 hex de alcance por nivel, hasta +3 de daño y +1,5 hex; su insignia numérica de bonus solo aparece al pasar el cursor sobre la torre. El renderer activo solo dibuja las dos fachadas delanteras como quads verticales, sin cierres de vértice ni profundidad lateral; M38/ADR-0085 sustituye las cuñas de las iteraciones anteriores. ADR-0073 fija el máximo lógico en 3.

El ghost de una expansión se deriva del mismo `Dictionary[Vector2i, HexCell]` candidato que confirma `Main`: alturas, variantes, obstáculos, props, cofres y celdas auto-rellenadas se preparan de forma determinista y no se recalculan al confirmar. Esto hace que tapas y fachadas coincidan antes y después de colocar. El contorno de región de terreno comparte vértices sin inset y usa un disco redondo en las uniones, con un solo color opaco por terreno: Grass `#406e4d`, Mountain `#646567` y Path amarillo; no tiene keyline ni relleno interior. M69/ADR-0121 fija el color de las fachadas y el gradiente negro de opaco abajo a transparente arriba; el ajuste de contorno sigue ADR-0095.

`TerrainVisualCatalog.get_elevation_tint()` es la fuente común del tinte multiplicativo neutro de las tapas: h0 usa 1,00; h1, 0,95; h2, 0,90 en RGB, igual en tablero, previews y copias elevadas Y-sorted. No modifica las UV, el polígono ni el orden de profundidad. `CloudShadowOverlay` aplica una sombra procedural de nubes en movimiento a los sprites del mundo desde un ColorRect full-screen en `CloudShadowLayer`, justo debajo del HUD. El shader recibe el centro/zoom de Camera2D para mantener el patrón anclado al terreno cuando la cámara se desplaza; la opacidad vigente es 0,20. La interfaz conserva su brillo normal y el efecto continúa si se oculta el HUD. `UpgradeOfferCard` usa una superficie plana común definida en la escena, sin sprite de marco ni variantes por rareza; el tier, icono, título y descripción están en el contenido, y un shader procedural dibuja detrás un aura radial con partículas cuyo color depende de la rareza. El hover refuerza el aura sin cambiar la superficie compartida. El tinte vigente está fijado por ADR-0100 y el efecto de nube por ADR-0109/0099; ADR-0082, ADR-0088 y ADR-0080 conservan el historial de altura y tier/ramas.

En M3, `HexGrid` es autoridad para las celdas confirmadas; `TerrainPlacementValidator` es un `RefCounted` puro que evalúa la candidata y devuelve `TerrainPlacementResult`; `Main` orquesta selección/confirmación y `TerrainPiecePreview` dibuja tablero y ghost, sin cambiar la autoridad lógica. Las conexiones internas usan los bordes PATH explícitos; las conexiones entre piezas también aceptan las aperturas laterales flexibles derivadas en cada salida de borde, según [ADR-0006](DECISION_HISTORY.md#adr-0006). M4 ya incorpora la conectividad global mediante el snapshot `PathGraph` descrito arriba.

La navegación del mapa la controla un `Camera2D` en `Main`: `WASD` mueve la cámara de manera continua (diagonales normalizadas y velocidad compensada por zoom) y el botón central con arrastre panea; la rueda acerca/aleja alrededor del cursor, también mientras se coloca terreno; Ctrl+rueda gira la pieza en esa fase. El paneo se limita al tablero confirmado más un margen configurable; ese margen crece de 1,5 a 2,5 hexes entre rondas 1 y 45. Los límites de zoom progresan de 0,82×–1,35× en la ronda 1 al rango completo vigente de 0,45×–2,5× en la ronda 45. `R` centra el tablero actual y restablece 1×. `Ctrl+D` conserva el overlay diagnóstico de rutas sin ocupar la tecla `D`. El HUD vive en `CanvasLayer` y no se desplaza ni escala con la cámara. Las teclas mantenidas se limpian al perder el foco de la ventana.

El mar mantiene `WaterBackgroundLayer` a pantalla completa, pero su posición visible deriva solo el 62 % del paneo de cámara y sus ondas son lentas. `ShorelineFoamOverlay` dibuja espuma blanca de banda ancha y animada mediante distorsión Voronoi, solo en aristas costeras sin celda vecina del tablero o de islas descubiertas; no dibuja juntas internas. En los bordes delanteros de celdas elevadas, la espuma se ancla a la base de la fachada expuesta, a la altura del agua, en vez de quedarse en la tapa superior (ADR-0123/0124). Cada run contiene seis islas reproducibles por seed: una aparece desde R1 a no más de 8 hexes de Main Tower; las otras cinco aparecen progresivamente en R10, 19, 28, 37 y 45 en anillos cada vez más alejados. Cada isla tiene 3–7 celdas Grass/Mountain decorativas de altura 0–2 y permanece fuera de `HexGrid`. Cuando el borde de una isla entra en la vista de cámara, se revela completa y muestra un cofre especial; su brújula se activa dentro de 12 hexes por isla sin cobrar. Los cofres especiales usan la interacción de clic del tablero, el rebote de aparición, brillo y respuesta al cursor de los cofres habituales, sin texto instructivo sobre el sprite; al abrirse emiten el mismo feedback de partículas. El juego se pausa hasta elegir una de tres cartas; al terminar vuelve a la misma fase, sin reemplazar la oferta programada cada tres rondas. Si una expansión alcanza una isla no cobrada, la isla y el cofre se mueven a agua segura. Ninguna isla interviene en rutas, construcción ni validación. La niebla procedural de `MapFog` se mide radialmente desde `Main Tower`: su radio cubre el punto más distante del tablero o de las islas descubiertas, más un margen configurable que crece de 1,5 a 3 hexes entre rondas 1 y 45; al alejar la cámara, oscurece progresivamente el mundo sin tapar el HUD ni bloquear acciones. Ver [ADR-0122](DECISION_HISTORY.md#adr-0122), [ADR-0123](DECISION_HISTORY.md#adr-0123) y [ADR-0124](DECISION_HISTORY.md#adr-0124).

M5 añade `GameBase` y `WaveDirector` a la escena principal. `GameBase` posee un `HealthComponent` y dibuja una huella hexagonal completa del mismo radio que una celda; `Enemy` compone su propio `HealthComponent` y `PathFollowerComponent`. `WaveDirector` recibe la oleada, el snapshot M4, la base y el contenedor Y-sort; crea enemigos desde sus Resources y escucha sus señales de llegada o muerte. La UI de `Main` presenta Health, recuento y estado, y traduce las señales de oleada a fases de `RunManager`. Durante `COMBAT` se bloquean las entradas de colocación de terreno. El tablero semilla de campaña usa `StartingBoardData` con radio axial 2 (19 celdas) y configuración de camino mínima de cuatro celdas PATH por spawn; el grafo vuelve a aplicar ese límite tras cada expansión. Al iniciar cada run, el tablero entero y sus sockets PATH rotan un paso de 60°; el contador persistente avanza por seis orientaciones sin cambiar la coordenada de la base.

M6 añade `BuildController` a `Main`; recibe el `HexGrid`, `Entities`, el origen y el radio del mapa. El controlador valida fase, terreno construible y ocupación antes de instanciar una escena desde `TowerData`, y registra la torre en `HexCell.occupied/tower_id`. Solo Grass y Mountain permiten construir, así que las torres no cambian `PathGraph`. `Tower` es una escena Y-sorted con datos, nivel, selección, prioridad de objetivo, alcance y cadencia; consulta los nodos del grupo `enemies` cada 0.1 s y usa `PathFollowerComponent.get_progress_ratio()` para first/last progress. Su placeholder vectorial dibuja pedestal, orientación, anillo de alcance al seleccionarlo y un flash hitscan al atacar. `TerrainPiecePreview` representa el marcador/rango de colocación. La UI de `Main` alterna build mode, muestra errores, cambia la prioridad y mejora la torre. En M6 las mejoras no tenían coste; M9 incorpora costes configurables. ADR-0009 recoge las reglas temporales.

M7 añade `DamageService` como hijo de `Main`, no como Autoload global. `BuildController` lo inyecta al configurar cada `Tower`, y cada disparo crea un `DamagePacket` con origen, tags y perfil desde `TowerData`. `DamageService.preview_damage()` calcula el resultado sin mutar al enemigo para el HUD; `apply_damage()` usa ese mismo cálculo, aplica daño y contrarregeneración y emite `damage_resolved`. `Enemy` mantiene su `HealthComponent` y regenera en `_process` con fracciones acumuladas. En M7 las respuestas de muerte seguían conectadas a las señales M5 y todavía no pagaban recompensa; M9 conecta ahora el evento al `RunEconomyService`. La fórmula plana y los HUD/fixtures de diagnóstico descritos por ADR-0010/0011 son históricos; M12A documenta el daño actual por capas. M61 retiró el panel F3 y el selector de oleadas DEBUG; M64 retiró las oleadas/dummies M7/M8 sin consumidor. Los perfiles de torre de diagnóstico `8`, `9` y `0` permanecen accesibles, pero no existe una oleada de entrenamiento seleccionable. `H` sigue ocultando el HUD entero. Los scripts de combate cargan packet/result por rutas `preload` y exponen interfaces base `RefCounted`/`Node` en las fronteras, evitando referencias de tipo a clases globales recién creadas antes de que Godot refresque su caché. ADR-0010 fija el contrato histórico y ADR-0011 registra el HUD temporal.

M8 añade `StatusEffectData` como Resource y `StatusEffectController` como hijo de cada `Enemy`; los Resources de configuración se comparten como datos, pero stacks, duración restante, temporizador de tick y origen activo pertenecen a cada enemigo. `TowerData.status_effects` proporciona los payloads del impacto; `DamageService` aplica el daño directo y, si el objetivo sigue vivo, aplica los estados. El controlador combina modificadores de velocidad tomando el mínimo multiplicador activo, ejecuta ticks periódicos llamando al mismo `DamageService` (sin payloads recursivos) y limpia al expirar el estado, morir el enemigo o llegar a la base. La instancia del servicio de combate continúa siendo local a `Main` e inyectada al enemigo por `WaveDirector`. Los Resources Slow/Burn/Bleed y la Status Probe son datos configurables provisionales; la oleada/dummy de entrenamiento se retiró en M64. No hay barra de prueba ni inspector F3 en runtime. Las reglas de acumulación y propiedad del tick están registradas en ADR-0012.

M9 añade `RunEconomyService` como nodo local de `Main`, configurado desde `RunEconomyData`; conserva Gold y Mana de la run sin mezclar la moneda meta. `BuildController` recibe el servicio y aplica compras atómicas de torres/mejoras con costes de `TowerData`. TowerTower` recibe la misma instancia: antes de un impacto con coste de Mana intenta gastar el recurso y no dispara si el saldo no alcanza. El servicio regenera Mana durante la run, acotado por su capacidad, y emite señales de saldo; el HUD refleja Gold, Mana, regeneración, costes de atajos y coste de mejora. `WaveDirector` guarda la recompensa de cada instancia enemiga, la paga una vez al derrotarla y descarta el pago al llegar a base; entrega la recompensa de ronda solo al limpiar todos los grupos. `Main` pasa brevemente a `ROUND_REWARD` antes de permitir la siguiente oleada. La remuneración por baja ya emitida se conserva aunque otro enemigo haga fallar esa oleada; no se paga el bonus de ronda fallida. Los valores de M9 son fixtures provisionales. ADR-0013 registra el contrato y las provisionalidades.

M9.5, adelantado por petición del usuario antes de la progresión completa M10 y las cartas M11, introduce siete `TowerData`: Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder. Las decisiones posteriores M12A/ADR-0023 amplían el modelo a Shield/Armor/Health y sustituyen la afirmación histórica de que Shield faltaba. Ballista usa un proyectil dirigido; Mortar un proyectil con explosión al aterrizar; Tesla alcanza todos los enemigos en su rango circular; Frost deja caer copos sobre PATH dentro de un cuadrado y aplica daño/Slow solo por contacto individual; Flame y Poison usan cono; Shredder recorre PATH, daña y añade Bleed mientras pierde daño base por enemigo. Todos pasan por `DamageService`. El roster principal tiene atajos `1–7`; los perfiles M7/M8 siguen en `8`, `9` y `0`. Las cifras de sus Resources parten de la tabla compartida por el usuario, son configurables y no representan balance final.

M10 carga y valida 45 WaveData ordenadas y un total fijo de 1.093 enemigos directos. WaveEnemyGroupData.count es la cantidad exacta por grupo; WaveDirector crea una unidad a la vez y la distribuye round-robin entre rutas alcanzables. Abrir varios endpoints no multiplica el total. El contador de spawns pendientes cubre el calendario directo; el contador de enemigos activos incluye invocaciones. Una transformación conserva la misma instancia activa y el pago de baja para que la ronda no se cierre hasta derrotar la fase final.

EnemyData contiene boss_tier y una lista tipada de EnemyAbilityData. WaveData deriva Standard, Boss o Tier 2 Boss del boss_tier presente; no asigna Miniboss a las rondas 17/19. WaveDirector ejecuta habilidades de aparición, proximidad, agotamiento de capas, muerte y temporizador, con radios configurables. Ooogie von Ooogovich (Haunted) usa un perfil propio provisional, invoca dos Bats cada 2 s y se transforma en Bat con 2.500 Health. Otros perfiles adoptan las habilidades individuales seleccionadas para el roster; las formas encadenadas de Ooogiehedron usan overrides de capas/speed sin mutar sus Resources base.

La campaña termina al limpiar la ronda 45 y solo expande el terreno después de limpiar las rondas 1–44. En cada victoria intermedia, TerrainPiecePreview conserva su comparación del grafo candidato; la siguiente ronda se habilita después de una colocación válida, y M11 puede intercalar su oferta de cartas. Los fixtures de diagnóstico M7/M8 se mantienen aislados de avance, pagos y daño a base. Las habilidades, los perfiles de enemigo y sus sprites se detallan en CONTENT_AND_ASSETS.md#content-roster; la tabla exacta de cantidad/orden está en CONTENT_AND_ASSETS.md#campaign. ADR-0037 sustituye el contrato de calendario y spawn de ADR-0016/0018 y las selecciones de contenido de ADR-0032/0033/0035/0036.
M11 usa `CardData`, `CardModifierOperation`, `CardPoolData`, `CardCatalogData` y `RunCardService`. El servicio es local a `Main`: combina el pool base con catálogos, resuelve prerequisitos entre catálogos y filtra por unlock, roster de run, selecciones y límite. El catálogo de mejora tiene 190 IDs únicos, que representan 173 entradas compatibles; M35 añade seis Resources de reclutamiento y el pool de run contiene 196 IDs. Tras colocar la expansión cada tres rondas entre la 3 y la 42, mantiene `CARD_OFFER` hasta elegir; luego habilita la ronda siguiente. `CardPoolData`, `RunCardService`, la escena y el panel comparten una oferta fija de tres opciones. Si hay un reclutamiento elegible, el servicio garantiza uno, sortea por peso los otros espacios y limita a dos reclutas por oferta; las cartas no elegidas permanecen elegibles en ofertas futuras. Los cofres de las islas usan el mismo pool y selector para una oferta bonus de tres cartas: pausan preparación o combate hasta la elección y luego reanudan esa fase, sin modificar el calendario regular. Torres, estados, base y economía consultan modificadores temporales sin mutar `.tres`. La frecuencia está confirmada; cifras y rarezas son configurables/provisionales. Ver ADR-0021/0062/0076/0093/0118 y ADR-0123.

La barra de vida de Main Tower es un `SegmentedHealthBar` del HUD configurado a un segmento por HP; al perder vida dibuja temporalmente los segmentos salientes con flash/encogimiento. `Main` calcula el color progresivo y controla el shader `BaseHealthVignette` en una capa a pantalla completa bajo el HUD, con niveles por HP absoluto y pulso lento a 1 HP. El valor, el máximo y el daño siguen perteneciendo a `GameBase`/`HealthComponent`; el feedback no cambia las reglas de combate. Ver ADR-0119.

M12 extiende el Autoload `MetaProgression` para separar moneda/unlocks de `RunEconomyService` y mantenerlos entre escenas. `MetaProgressionData` combina su catálogo base con `PermanentUpgradeCatalogData`; hay 31 IDs en los Resources y 30 mejoras comprables en el mapa. `card_draw` se conserva como ID legado para perfiles guardados, pero queda retirado de la tienda porque la oferta siempre tiene tres opciones. Las mejoras disponibles tienen operaciones por nivel para economía, daño H/A/S, Gold por baja, vida/reparación de base y unlocks. La tienda terminal aparece al acabar por victoria o derrota, cobra y persiste, y sus efectos se activan en la siguiente run. La compra revierte si falla la persistencia. `BuildController` comprueba el unlock además de que el HUD oculte torres bloqueadas. JSON `SaveData` conserva versión, moneda, IDs, niveles, contadores y el último resumen; no guarda nodos ni Resources. La escritura usa `user://`, temporal, backup y rename. Un archivo corrupto o incompatible no se sobrescribe y deja la tienda en lectura segura. Importes y efectos siguen configurables; ver [ADR-0022](DECISION_HISTORY.md#adr-0022) y [ADR-0062](DECISION_HISTORY.md#adr-0062).
M12 extiende el Autoload `MetaProgression` para separar moneda/unlocks de `RunEconomyService` y mantenerlos entre escenas. `MetaProgressionData` combina su catálogo base con `PermanentUpgradeCatalogData`; 31 IDs persisten en los Resources, de los cuales 30 se ofrecen para compra y `card_draw` se conserva como ID legado oculto. La presentación terminal por pestañas de M12 es histórica y quedó sustituida por M35: la misma tienda se monta en el menú y tras Game Over, usando `MetaProgressionMap` con nodos/conexiones. Los efectos se activan en la run siguiente. La compra revierte si falla la persistencia. `BuildController` y el roster temporal distinguen unlock persistente de reclutamiento en run. JSON `SaveData` conserva versión, moneda, IDs, niveles, contadores y el último resumen; no guarda nodos ni Resources. La escritura usa `user://`, temporal, backup y rename. Un archivo corrupto o incompatible no se sobrescribe y deja la tienda en lectura segura. Importes y efectos siguen configurables; ver [ADR-0022](DECISION_HISTORY.md#adr-0022), [ADR-0076](DECISION_HISTORY.md#adr-0076) y [ADR-0077](DECISION_HISTORY.md#adr-0077).

M12A completa la resolución de combate por capas. `EnemyData` y `Enemy` modelan Health, Armor y Shield con regeneración por capa; cada perfil configura los tres máximos y un máximo cero desactiva esa capa. Los estados suprimen la regeneración correspondiente y el dibujo renderiza en filas las capas presentes (fragmenta Health). `DamagePacket` lleva un multiplicador por capa y marca los ticks periódicos; `DamageService` resuelve la capa activa Shield→Armor→Health y añade +1 al multiplicador de ataque cuando Bleed/Burn/Poison coincide con Health/Armor/Shield. Los ticks no reciben el bonus y usan la relación de daño por capa 1.0/0.5. `Tower` mantiene un total de mejoras y tres contadores independientes de 0 a 15; cada subida manual o automática añade +1 de daño base y +1 solo a la capa afectada. El XP y los costes Gold crecen exponencialmente por nivel de esa capa según factores configurables del `TowerData`. `BuildController` cobra el coste de la capa seleccionada, calcula precio por torre del mismo tipo y permite demoler para reducir el precio futuro. La interfaz pone el nivel y la barra XP bajo cada mejora y ordena tres criterios de targeting en selectores numerados. Ballista y Mortar usan `TowerProjectile`; Mortar impacta un área, y Frost calcula cobertura cuadrada/PATH. El fixture DEBUG Health/Armor/Shield descrito en la aceptación histórica se retiró en M64; las capas actuales se verifican con perfiles de campaña que tengan esos máximos configurados. Los factores iniciales son provisionales; ver [ADR-0023](DECISION_HISTORY.md#adr-0023) y [ADR-0046](DECISION_HISTORY.md#adr-0046).

M13 organiza la presentación sin modificar las reglas de combate. M22 actualiza el layout del HUD normal en `CanvasLayer`: salud y atajos arriba a la izquierda, Gold/Mana arriba a la derecha, ronda centrada y datos/acciones de torre bajo los recursos a la derecha. Salud y ronda no tienen fondos de panel compartido. Gold y Mana comparten un panel horizontal 9-slice de 176 × 52 px, según M61/ADR-0112. La salud de base se dibuja cada 10 puntos y su texto queda superpuesto; `BaseData` expone el sprite RGBA y `GameBase` lo dibuja a escala nativa 1:1. `RunEconomyService` repone Mana al máximo efectivo en las rondas de campaña; la interfaz redondea su lectura a entero. Cada cambio de Gold anima en conjunto su icono y cifra con escala, rebote y destello. La fila muestra solo las torres reclutadas en la run: Ballista empieza disponible y las demás entran tras elegir su carta de reclutamiento. Las tarjetas numeran secuencialmente las torres visibles y las teclas 1, 2, 3… seleccionan ese orden, que se compacta al reclutar nuevas torres. El precio usa el mismo panel 9-slice que Iniciar ronda. El panel derecho se ajusta a su contenido sin scroll; si la ventana no alcanza su alto natural, escala verticalmente para mantener toda la información dentro de pantalla. El preview se dibuja por encima del tablero y señala con verde/rojo la validez de la colocación; al colocar cualquier torre, la ficha y el ghost calculan daño y alcance efectivos para la elevación bajo el cursor, incluyendo modificadores de run/permanentes (M63/ADR-0114). La distribución de selección, las mejoras H/A/S, targeting, debug, iconos de torre, estados y feedback de daño siguen los contratos de las versiones anteriores de M13. `MetaShopPanel` comparte una única tienda entre las escenas de menú y final de run; menú, partida y pausa son escenas separadas, Escape abre pausa y perder devuelve al menú con la tienda abierta. Game Over presenta cantidad y daño por tipo construido durante la run; omite los tipos desbloqueados pero no desplegados (M63/ADR-0114). La tienda permanente usa `MetaProgressionMap` y nodos de una escena común; conexiones muestran prerequisitos, iconos grandes identifican la mejora, tooltips describen bloqueos y partículas confirman la compra. El progreso de ronda usa una ventana móvil de 15 puntos, mantiene hover de enemigos y desvanece el extremo futuro. Ver [ADR-0076](DECISION_HISTORY.md#adr-0076), [ADR-0077](DECISION_HISTORY.md#adr-0077) y [ADR-0083](DECISION_HISTORY.md#adr-0083), además de [ADR-0049](DECISION_HISTORY.md#adr-0049) y [ADR-0105](DECISION_HISTORY.md#adr-0105).

Actualización de arquitectura (ADR-0049): el antiguo helper de estilos fue retirado en favor del Theme local `game/ui/themes/rogue_hud_theme.tres`, aplicado a raíces UI concretas y sin sobrescribir el Theme global. Los controles repetidos de torre/capa/mejora, oferta de cartas, tienda/mapa permanente, menús y filas del tooltip de ronda tienen escenas editables y scripts de presentación asociados; el mapa dibuja conexiones y crea su etiqueta central/partículas de feedback en runtime. El arranque de `project.godot` apunta al menú principal; menú, partida y pausa son escenas distintas. `Main` sigue coordinando partida, entradas y señales, mientras los sistemas existentes conservan la autoridad sobre progreso, compras, economía y reglas. La oferta presenta exactamente tres cards; las cartas de reclutamiento elegibles se mezclan con las mejoras. El dibujo de progreso de ronda sigue procedural, ahora sobre ventana móvil. La aceptación de la implementación actual queda pendiente en ventana. Ver ADR-0049, ADR-0076–0078 y ADR-0093.

Actualización histórica de recursos visuales (ADR-0050): 20 recursos Texture2D (16 iconos generales y cuatro cursores) viven como propiedades de `game/ui/resources/icon_catalog.tres`, referenciado también por el Inspector de la raíz `Main`. Las tarjetas de torre y capa exponen texturas por instancia y las sincronizan con sus `TextureRect` para previsualizarlas en el editor. Gold/Mana, el sprite 9-slice de iniciar ronda y los marcos de expansión permanecen asignados en sus escenas. Las upgrade cards ya no usan los marcos PNG de aquella etapa; M40 las define como una superficie plana común con aura procedural según ADR-0088. El Theme local es la autoridad editable para los paneles de fondo plano. Los Resources de gameplay no incorporan campos UI.

Históricamente M15 asignaba obstáculos y cofres por seed/coordenada, y refería los objetos decorativos como props; aquella selección de cinco imágenes y el desplazamiento vertical de 6 px quedaron sustituidos por M39. La asignación de cofres sigue al confirmar una expansión, con base de 1 % y el modificador persistente vigente hasta 20 %. El hover del cofre mantiene su salto y resplandor; el premio inicial de 25 Gold sigue configurable/provisional. Las flechas animadas muestran el flujo PATH y se actualizan con un grafo candidato legal. Ver ADR-0040, ADR-0041, ADR-0060 y ADR-0087.

En el renderer vigente, `TerrainVisualCatalog` asigna determinísticamente elevación, obstáculos y decoración a partir de seed/coordenada o identidad de oferta. Cada uno de los 18 props compatibles con el terreno tiene un 10 % de probabilidad independiente por celda; se limita a dos props únicos, que se dibujan bajo el obstáculo y no tienen input ni hitbox. La oferta conserva los mismos IDs entre miniatura, ghost y tablero; si una celda vecina a la base se normaliza de Mountain a Grass, el ghost y la colocación regeneran juntos los props compatibles con Grass usando la coordenada global. Los PNG de props tienen 96×96 px y se muestran a 39,6×39,6 px con offsets que impiden que dos sprites se solapen. Los ocho obstáculos se generan con las tasas existentes (Grass 25 %, Mountain 15 %), usan PNG de 208×208 px, se muestran centrados a 94,6×94,6 px y se dibujan por delante de los props. Las celdas vecinas inmediatas a la base no superan altura 1: una Mountain se normaliza a Grass 1 y Path permanece 0. La base conserva su PNG fuente de 270×352 px y se dibuja estirado en una caja de 1,8 × el radio de huella de ancho por 2,8 × el radio de alto, con el borde inferior visual anclado y una huella lógica de un hexágono. Las fachadas se ordenan con `Entities.y_sort_enabled` desde el borde inferior expuesto, a la altura de la tapa vecina o del suelo; cubren actores detrás y quedan detrás de actores delante. Ver [ADR-0087](DECISION_HISTORY.md#adr-0087), [ADR-0089](DECISION_HISTORY.md#adr-0089), [ADR-0090](DECISION_HISTORY.md#adr-0090) y [ADR-0096](DECISION_HISTORY.md#adr-0096).

Actualización de assets M15 (ADR-0058): se sustituyeron los 23 PNG de terreno, obstáculos, base, portal e iconos de torre en sus rutas runtime. Path_01/02/03 ahora muestran el arte Dirt_01/02/03 sin camino pintado. `TerrainVisualCatalog`, los sockets PATH, el `PathGraph` y el overlay de flechas no cambiaron; los originales están respaldados en `art_generation/originals_replaced/2026-10-13/`.

M16 conecta `Tower.impact_effect_requested` con `AnimatedImpactVfx`, que toma cada sprite sheet local y anima sus frames en el hex objetivo. `Main` aplica cuatro cursores locales por estado de interacción: normal, objeto/control interactivo, acción inválida o colocación. Todos los sprites se guardan bajo `assets/sprites/`; los PNG del pack Tiny Swords se mantienen como dependencia local ignorada por Git en `assets/sprites/third_party/tiny_swords/`, cuya README explica su instalación. La procedencia y licencia están en [Origen](CONTENT_AND_ASSETS.md#origin-and-sources).

Cada torre se dibuja con un único Sprite2D que carga directamente el PNG completo de `assets/sprites/ui/icons/`, sin recortes ni composición por regiones. TowerBuildGhost, la card de construcción y el retrato de Tower Info reutilizan la misma textura cacheada. El centro coincide con el de la celda, el arte baja 8 px, y solo usa flip_h para seguir enemigos a la izquierda; no hay rotación visual. Mundo/ghost comparten escala 0,9504 × 1,12 para dejar margen al sprite completo, mientras las imágenes de cards y Tower Info mantienen su caja de UI. Las torres y los obstáculos interactuables usan `interactable_outline.gdshader` para dilatar alfa y producir el contorno blanco. `GameBase` reutiliza el shader con `outline_size_px = 6`; `SpawnPortal` lo usa en modo outline-only permanente con tamaño 3; los obstáculos también usan tamaño 3. `Enemy` crea una capa de sprite outline-only detrás de su dibujo manual, a tamaño 2, la sincroniza con textura, escala, orientación y salto, y obtiene un color claro por `EnemyData.id`; los perfiles sin asignación usan el tono de reserva. Las capas no agrupan actores en `CanvasGroup`, así cada sprite conserva su Y-sort; las barras y los estados se pintan encima del enemigo. El ghost de construcción mantiene su tinte verde/rojo de legalidad. No se generan sombras proyectadas individuales por terreno u obstáculo; el velo animado de nubes vive en una capa global bajo el HUD. El flujo PATH se oculta durante la previsualización/colocación de una expansión y el hover no dibuja los sockets sobre el camino. El Tower Info muestra la bonificación de daño y alcance de la elevación de la torre seleccionada. El XP de perfil existente financia tanto desbloqueos de torres como mejoras permanentes. Véanse [ADR-0069](DECISION_HISTORY.md#adr-0069), [ADR-0070](DECISION_HISTORY.md#adr-0070), [ADR-0093](DECISION_HISTORY.md#adr-0093), [ADR-0097](DECISION_HISTORY.md#adr-0097) y [ADR-0098](DECISION_HISTORY.md#adr-0098). La fuente Patrick Hand está asignada al tema predeterminado del proyecto, incluidos los contadores pintados en `_draw()`.

M51/ADR-0101 define el feedback visual activo. `AnimatedImpact` recorta hojas en tira o cuadrícula; el overlay de evento `FeedbackVfxLayer` vive en CanvasLayer 130, sigue la transformación de viewport/cámara y usa `PROCESS_MODE_ALWAYS`. Los VFX de juego reciben y conservan su posición del mundo durante toda la animación: paneo y zoom los transforman junto al terreno y los actores, sin desplazarlos respecto del evento que los originó. Aun así, la capa se dibuja sobre HUD, cards y preview; los efectos de una sola vez se liberan al acabar, mientras los iconos de estado y el resplandor del cofre persisten con su condición. El marcador `ui_click` usa `CursorFeedbackVfxLayer` en viewport para permanecer sobre el cursor. Las siete torres disponen de hojas `shoot` e `impact`; M52 dosifica `shoot` en las torres de fuego continuo y mantiene un efecto por cada disparo de Ballista/Mortar, mientras `impact` se reproduce al aplicar daño. Mortar marca el objetivo previsto con `tap_ripple`. La muerte final de enemigo emite `enemy_killed`, y cada subida manual/automática emite `level_up_effect_requested`; las hojas de base, cofre, terreno y Game Over se lanzan desde sus eventos de dominio/UI. Ver [ADR-0106](DECISION_HISTORY.md#adr-0106).

El antiguo uso de Tiny Swords para impactos de M16 se conserva solo como historial: M51/ADR-0101 lo sustituye por las hojas locales Cozy Chunky. M52/ADR-0102 reemplaza la composición por regiones de torre por los PNG completos; `Tower` y `TowerBuildGhost` usan el mismo recurso, centrado en la celda con un desplazamiento visual compartido de 8 px hacia abajo. Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder limitan su VFX `shoot` con cooldown aleatorio individual de 2,0–2,5 s; Ballista y Mortar mantienen un efecto por proyectil. No se limitan impactos ni ataques. `pickup.png` se muestra al construir torres y retirar obstáculos.

Actualización visual (ADR-0053/0054): el panel de expansión y Tower Info usan superficies planas; se retiraron los marcos PNG y la placa oscura que se pintaba bajo las torres. `rogue_hud_theme.tres` es el tema global, y sus tamaños de texto existentes se conservan al establecer Patrick Hand como fuente predeterminada.

M32/M33 retiraron los fondos PNG por tier y las variantes por rareza. M36 introdujo un sprite vertical NinePatch, que M40 elimina: una card plana compartida, icono grande y datos legibles; la rareza solo controla el aura radial procedural y sus partículas. La oferta de mejoras tiene siempre tres opciones; el panel mantiene exactamente tres botones activos y Card Draw está retirado del mapa. M66 exige un reclutamiento si hay uno elegible, sortea las demás opciones por peso y limita a dos los reclutamientos de la oferta. `TerrainPieceCardPreview` omite sockets/ramificaciones PATH, pero usa las mismas tapas hexagonales y fachadas delanteras que el tablero, ordenadas por el anclaje axial; las alturas mostradas son las de la oferta real. Durante la colocación, `Q` y `E` giran la pieza; Ctrl+rueda también la gira durante la colocación y la rueda sin Ctrl siempre conserva el zoom. `T` busca un ancla y rotación aleatorias, las valida con `TerrainPlacementValidator` y `PathGraph`, y confirma automáticamente si la expansión conserva una continuación futura. Si no hay candidata, no modifica el tablero. Sin torre ni pieza seleccionadas, el hover de celda presenta el tooltip compacto descrito arriba. Ver ADR-0071, ADR-0072, ADR-0075, ADR-0080, ADR-0083, ADR-0088 y [ADR-0093](DECISION_HISTORY.md#adr-0093).

M56 añade `BalatroCardHover` como componente visual común para cards de mejora de run, selección de terreno y selección de torre: al pasar el cursor anima escala/inclinación y un brillo radial ligado a la posición del cursor, sin cambiar la lógica de botones. El brillo se adjunta diferido tras completar el montaje de la card, evitando modificar la lista de hijos durante `_ready()`. `WaterBackgroundLayer` dibuja agua procedural en CanvasLayer -10, detrás del tablero, partículas y HUD, y no forma parte de la simulación ni de los sprites del mundo. M57 reemplaza su paleta oscura por azul y espuma casi blanca, con manchas grandes y movimiento lento. Al emitir la baja final, `WaveDirector` envía el `Enemy` a `Main`; este toma una instantánea visual antes de que el actor salga del árbol y la envía a `EnemyDeathParticlePool`, que copia textura/frame/modulación/espejo y escala a un emisor GPU one-shot. Los emisores bajo `FeedbackVfxLayer` 130 conservan coordenadas locales al paneo/zoom y duplican su material para bajas simultáneas. La tienda permanente muestra iconos pertinentes en todos sus nodos y representa cada coste/saldo/recompensa con el icono local de perfil, sin imprimir el nombre de esa moneda. Ver [ADR-0107](DECISION_HISTORY.md#adr-0107) y [ADR-0108](DECISION_HISTORY.md#adr-0108).

M58 refuerza la sombra del shader de nubes a opacidad 0,20. El shader de `WaterBackgroundLayer` conserva el fondo a pantalla completa y convierte UV de pantalla en coordenadas del mundo con posición, viewport y zoom de `Camera2D`, de modo que el patrón acompañe el paneo sin mover el rectángulo. La actualización comparte el ciclo del sombreado; ver [ADR-0109](DECISION_HISTORY.md#adr-0109).

M59 dibuja `UpgradeHealth`, `UpgradeArmor` y `UpgradeShield` como controles cuadrados de 128 × 128 dentro de un `HBoxContainer` centrado; el importe y el icono se envuelven con el mismo `StyleBox` y dimensiones de precio que la tarjeta de atajo. Para la cámara, `Main` suma el offset base, el impulso de daño y una oscilación ambiental pequeña activa entre `wave_started` y `wave_completed`/`wave_failed`; así ambos shakes coexisten y el ambiental termina junto con la ronda. Ver [ADR-0110](DECISION_HISTORY.md#adr-0110).

M60 fija `XPBar` de `TowerLayerUpgradeButton` en 88 × 8 px y la centra dentro de la card. La acción de demoler torre es un botón horizontal con icono, texto `DEMOLER` y un panel de Gold que muestra `+<reembolso>`; el cálculo sigue viniendo de `BuildController.get_demolition_refund()`. La acción sobre obstáculos muestra `DEMOLER` más el coste calculado por `Main` con signo `−`; la acción sobre portales muestra `RETIRAR` más su coste, también con signo `−`. Las tres presentan el icono de Gold dentro del panel. Ver [ADR-0111](DECISION_HISTORY.md#adr-0111).

### Ciclo de correr de enemigos — M65

Actualización de feedback (ADR-0055): al recibir daño, la base pulsa en rojo y la cámara aplica una sacudida breve mediante `Camera2D.offset`, sin cambiar posición ni zoom. Gold anima el grupo de icono y cifra con rebote, destello e inclinación; el cofre llama al mismo feedback incluso si el saldo ya alcanzó su límite. Una capa negra translúcida de `CanvasLayer` queda debajo de las cards durante las ofertas de terreno/mejoras, se oculta al elegir una pieza para colocar y vuelve al cancelar. M41 sustituye parcialmente el portal de 64×96 px por el atlas animado de 96×96 px; conserva la interacción y el preview. El juego se pausa mediante la acción `toggle_pause` (P) o el botón `PauseButton`, cuyo proceso continúa durante la pausa; `StartWave` también procesa la entrada y despeja la pausa al iniciar desde `ROUND_PREP`. Durante `TERRAIN_EXPANSION` y `CARD_OFFER`, `Main` y `BuildController` impiden selección/construcción de torres y apertura de cofres. Véase [ADR-0061](DECISION_HISTORY.md#adr-0061) y [ADR-0089](DECISION_HISTORY.md#adr-0089).

`EnemyData.sprite_texture` references one canonical RGBA PNG per profile. The 26 canonical enemy PNGs are four-frame horizontal run sheets (512×128 px, four 128×128 frames). `Enemy._draw()` selects the active region, centers/scales it, and keeps health bars/status icons above it; the run cycle advances at 8 FPS while `MOVING`, starting before the enemy is shown on the path. No separate source-image directory exists in the current checkout; see the [sprite inventory](CONTENT_AND_ASSETS.md#sprite-audit) and [ADR-0116](DECISION_HISTORY.md#adr-0116).

### Save
Guardar solo datos estables:
- versión de save;
- XP de perfil (`meta_currency` en el formato de guardado para mantener compatibilidad);
- IDs desbloqueados;
- niveles de permanentes;
- settings.

No serializar nodos/Resources completos.

### Interfaz actualizada en M61

`Main` centraliza el color de los valores numéricos de efectos para que las cards de run y los nodos permanentes compartan verde para mejoras y rojo para perjuicios. Tower Info compara los stats efectivos de `Tower` con `TowerData`, marca sus aumentos/disminuciones y presenta por separado el bonus de elevación; el coste efectivo de Mana usa el criterio inverso, verde si baja y rojo si sube. El botón compacto de pausa es un `PauseToggleButton` junto a la vida: el script dibuja glyph de pausa/play y `P`, mantiene su propio proceso durante pausa y conserva la acción de teclado. El panel técnico de terreno y los fixtures de oleada desaparecen del árbol runtime; la campaña sigue inicializando su lista de 45 `WaveData` para `RoundProgressStrip` y avanza en secuencia. `TerrainPlacementPrompt` aparece solo con una pieza seleccionada, encima de la barra inferior, y comparte su estado de validación con `TerrainPlacementPreview`. La selección de portal oculta el tooltip de hover, reproduce el efecto `ui_click` y rellena `WorldObjectEnemyList` dentro de Tower Info con el reparto asignado. `GoldPanel` y `ManaPanel` comparten `gold_panel_style.tres`, dimensiones 176 × 52, iconos 32 × 32 y cifra de 23 px. Ver [ADR-0112](DECISION_HISTORY.md#adr-0112).

### Correcciones de interfaz en M62

`Main` exporta los límites y márgenes responsivos del panel Tower Info para editarlos desde el Inspector; el ajuste automático no toca la escala del contenedor interno ni los márgenes de escena. `TowerLayerUpgradeButton` coloca su icono bajo un `CenterContainer` y declara el tamaño en `tower_layer_upgrade_button.tscn`. Los badges de demolición están fuera de los botones y la escena mantiene toda la jerarquía de coste bajo `RemoveWorldObjectRow`, incluido el nodo único `%RemovalCostLabel`. La selección de portal retiene su `SpawnPortal` mientras muestra el reparto en `WorldObjectEnemyList`. El shader de agua sustituye el reloj global `TIME` por el uniforme `water_time`, que solo avanza desde el proceso pausable de `Main`. Ver [ADR-0113](DECISION_HISTORY.md#adr-0113).

### Control de velocidad de simulación en M68

`GameSpeedButton` alterna `Engine.time_scale` entre ×1, ×2 y ×3 y muestra el valor activo. Pausar detiene el gameplay y conserva el multiplicador para reanudar; el menú modal de pausa cubre los controles del HUD. `Main` inicializa y restablece la escala a ×1 al entrar o salir de la run, por lo que no se filtra al menú ni a una partida posterior. Ver [ADR-0120](DECISION_HISTORY.md#adr-0120).

### Preview de torre y progresión en M63

`Tower.get_damage_for`, `Tower.get_range_hexes_for` y `Tower.get_cell_world_position` son las funciones compartidas por la torre construida, el panel de selección y el ghost de colocación. La elevación, las cartas activas y la progresión permanente se incluyen antes de construir, de modo que la cifra y el círculo de alcance previstos coinciden con el estado efectivo al confirmar. El radio de ataque se muestra con un anillo de alto contraste mientras la torre esté bajo el cursor o seleccionada. La colocación de terreno usa verde lima para una oferta válida y rojo intenso para una inválida, con relleno y contorno reforzados.

`RunManager` registra las instancias construidas y agrega daño por ID de torre; el resumen final omite los tipos cuyo contador de construcción sea cero y no filtra por desbloqueo permanente. `MetaProgressionMap` alinea los siete nodos de desbloqueo de torre en la misma fila y coloca sus mejoras Health/Armor/Shield como tres opciones horizontales independientes. Cada `MetaUpgradeNode` asigna el icono del catálogo con fallback de perfil y, en última instancia, de daño; su precio queda centrado y grande con el icono de perfil (`exp.png`) a su derecha. La aceptación visual e interactiva queda pendiente según M63 de `IMPLEMENTATION_AND_QA.md#acceptance`; ver [ADR-0114](DECISION_HISTORY.md#adr-0114).

### Interfaz editable y recursos en M64

Los valores persistentes de UI se guardan en escenas, Themes, StyleBoxes y propiedades `@export`: fuentes, tamaños, separaciones, márgenes, estilos, geometría y estados semánticos. Los scripts de controles actualizan estado/contenido, pero no reinstalan estilos o tamaños al iniciar. `Main` expone configuración de Tower Info, filas/tooltip de enemigo y portal, inventario/ofertas de terreno, colores HUD, botón de ronda, cursor y tamaños de VFX; las escenas de mejora, mapa permanente, timeline, portal y H/A/S exponen sus propios parámetros. `Enemy` declara fuente/tamaño de iconos de estado y números flotantes, junto a sus barras H/A/S. El número flotante sigue siendo un control creado en runtime, pero obtiene aspecto del Inspector de Enemy. El mapa expone sus partículas de desbloqueo y el resumen de menú el tamaño del confeti. Los iconos de estado se dibujan a 28×28 px; límites de importación (iconos 256, portal 768 y cofre 168) reducen textura cargada sin alterar archivos fuente. M64 también retiró el script no instanciado de preview de portal y los Resources de demo M7/M8 sin consumidores. Ver [ADR-0115](DECISION_HISTORY.md#adr-0115).

### Oferta de run en M66

`RunCardService` centraliza la elegibilidad y construcción de ofertas a partir del estado de la run y el catálogo de cartas. La política exacta de reclutamiento y sorteo tiene como propietario único [Progresión](#progression); su implementación está en `game/cards/run_card_service.gd` y el motivo en [ADR-0118](DECISION_HISTORY.md#adr-0118).

### HUD de vida de base en M67

`SegmentedHealthBar` presenta cada HP actual como un segmento, reproduce la pérdida de segmentos y gradúa el color del relleno según la proporción de vida. `BaseHealthVignette` recibe la vida actual y escala el feedback en 3/2/1 HP; el efecto no altera Health ni la derrota. La altura objetivo de la barra es 42 px (+50 % sobre los 28 px anteriores). Ver [ADR-0119](DECISION_HISTORY.md#adr-0119).

### Tonos de fachada en M69

El catálogo del renderer es dueño de los tonos objetivo: Grass `#407850`, Mountain `#3b3c41`. El dibujo aplica ese color a la textura de fachada y superpone un quad negro cuya alfa pasa de opaca en el borde inferior a transparente en el superior. Tablero, ghost/preview y miniaturas usan la misma regla; la tapa hexagonal no recibe el gradiente. La especificación completa está en [05 — Terreno hexagonal](#terrain), el estado de aceptación en M69 y el motivo en [ADR-0121](DECISION_HISTORY.md#adr-0121).

### Determinismo
La run debe tener `run_seed`.
Toda selección aleatoria importante debe derivar de un RNG de run para poder reproducir bugs.

<a id='data-models'></a>
## Modelos de datos y Resources

Este documento es propietario de los contratos de datos: campos, validación y responsabilidades. La regla de juego que consume cada dato pertenece a la página temática asignada en el [índice maestro](README.md#index). Los valores runtime se leen de código y Resources `.tres`; este documento no es una segunda tabla de balance. Los nombres de clases de los ejemplos son conceptuales si no coinciden con los tipos presentes en el proyecto.

### HexCoord
```gdscript
class_name HexCoord
extends RefCounted

var q: int
var r: int

func s() -> int:
    return -q - r
```

Operaciones:
- add
- neighbor(direction)
- distance_to
- rotated60(steps)
- equality/hash/key

### HexCell
```text
coord: HexCoord
terrain_type: PATH | GRASS | MOUNTAIN
elevation: int 0..3; PATH 0, GRASS 1..2, MOUNTAIN 2..3
buildable: bool
occupied: bool
tower_id: optional
obstacle_type: NONE | BRAMBLE_BUSH | FALLEN_LOG | BRANCH_PILE | TREE_STUMP | ROCK_AND_WOOD | SUPPLY_CRATE | EXPOSED_ROOTS | MOSSY_ROCK_CLUSTER
chest_available: bool
decorative_prop_ids: Array[StringName]
piece_instance_id
path_edges: bitmask/array[6]
flexible_path_edges: bitmask/array[6] derivada en runtime
visual_variant
```

Reglas:
- PATH: elevation 0; buildable false.
- GRASS: buildable true; elevation 1 o 2, sorteada por mapa/oferta.
- MOUNTAIN: elevation 2 o 3; buildable true.
- Las seis celdas adyacentes a la base tienen elevación máxima 1; si el terreno generado allí fuera Mountain, se normaliza a Grass. PATH permanece a 0.
- `obstacle_type` y `chest_available` son estado de contenido visual/runtime de una celda; no cambian el tipo de terreno, elevación ni PathGraph. Un obstáculo o cofre sin abrir bloquea construcción. En `ROUND_PREP`, el obstáculo se selecciona por su hex y muestra el nombre correspondiente a su sprite. Retirarlo cuesta `25 × n²` Gold, con `n` igual al número de obstáculos retirados previamente en esa run.
- `decorative_prop_ids` contiene cero, uno o dos props visuales, sin selección, hitbox ni efecto de gameplay. Cada PNG compatible del pool del terreno tiene un 10 % de probabilidad independiente por celda; la tirada es determinista por seed/coordenada u oferta y no repite el mismo ID en la celda. Si hay obstáculo, este se dibuja delante.
- Elevation no cambia coordenada lógica.

`TerrainVisualCatalog` asigna `elevation`, `visual_variant`, obstáculos y props determinísticamente según seed y coordenadas/identidad de oferta. PATH siempre queda en 0; Grass sortea 1 o 2; Mountain sortea 2 o 3, excepto en el anillo de base donde la elevación no supera 1 y Mountain se convierte en Grass. Card, ghost y tablero confirmado conservan el contenido asignado a la oferta. En una expansión, el cofre se sortea al confirmar la colocación con seed de run y coordenada axial. Hay tres variantes de cada tipo de terreno; obstáculos con tasas Grass 25 % y Mountain 15 %; y cofres con base 1 %, más +5 puntos porcentuales por nivel de `CHEST_SPAWN_CHANCE_ADD`, hasta 20 % en cuatro niveles (el último incremento se limita por el tope). PATH recibe props decorativos, pero nunca obstáculos ni cofres. El tablero de inicio limita a uno el total de obstáculos y excluye la base y sus seis vecinas; una pieza de expansión admite como máximo dos. Cada uno de los 18 PNG de props tiene un 10 % de probabilidad independiente, con tope de dos IDs únicos por celda. El orden top-down isométrico hace que las celdas delanteras cubran las que quedan detrás. Props, obstáculos y cofres se dibujan en el contenedor Y-sort; los obstáculos de 208×208 se estiran a 94,6×94,6 px, centrados sin desplazamiento, y los props de 96×96 a 39,6×39,6 px con offsets sin solapamiento. Al abrir el cofre, `RunEconomyService` añade Gold temporal; el valor inicial 25 es provisional y configurable en el catálogo.

### TerrainPieceCellData
```text
local_coord: Vector2i
terrain_type: PATH | GRASS | MOUNTAIN
elevation: int 0..3; PATH 0, GRASS 1..2, MOUNTAIN 2..3
path_edges: bitmask[6]
flexible_path_edges: bitmask[6] derivada de las salidas externas
visual_variant: StringName
obstacle_type: int # runtime; contenido de la oferta
chest_available: bool # runtime; se asigna al confirmar colocación
decorative_prop_ids: Array[StringName] # runtime; de 0 a 2 IDs decorativos
```

Cada pieza de catálogo contiene exactamente 7 celdas. La forma hexagonal centrada en `(0,0)` más sus seis vecinos es la plantilla de losetas; el tablero de inicio de 19 celdas es un Resource aparte. Las coordenadas exactas y la vista de colores están en [PROJECT_SPEC.md#terrain](#terrain). Cada celda conserva su tipo de terreno al rotar. `obstacle_type`, `chest_available` y `decorative_prop_ids` son contenido runtime, no parte del catálogo compartido. El obstáculo y los props se fijan en la copia de oferta y se trasladan a miniatura, ghost y terreno confirmado. Si una celda queda adyacente a la base y se normaliza de Mountain a Grass, el ghost y la colocación regeneran juntos los props compatibles con Grass usando la coordenada global; la miniatura sin ancla conserva el tipo y contenido ofertado. `chest_available` queda falso en la oferta y se determina al confirmar el terreno.

Validación vigente del Resource: ID y nombre no vacíos; peso no negativo; coordenadas únicas y conectadas; pivote `(0,0)`; tipos/elevaciones permitidos; PATH a altura 0, Grass a altura 1 o 2 y Mountain a altura 2 o 3; solo PATH declara `path_edges`; y toda conexión interna PATH es recíproca y llega a otra celda PATH. `requires_path_connection` exige al menos un socket PATH hacia fuera de la huella. `flexible_path_edges` se deriva al rotar la pieza a partir de las salidas externas y abre las dos caras laterales contiguas que también queden fuera de la huella; no se configura en el `.tres`. Las reglas completas de enlace están en [PROJECT_SPEC.md#terrain](#terrain).

### TerrainPieceData : Resource
```text
id
display_name
cells: Array[TerrainPieceCellData] # exactamente 7
weight
tags
requires_path_connection: bool
```

`weight` y `tags` quedan disponibles para el pool de contenido; M3 no selecciona piezas al azar. Las piezas expansivas activan `requires_path_connection`. El tablero semilla ya no se construye con `TerrainPieceData`.

### StartingBoardData : Resource
```text
id
display_name
base_coord: Vector2i
minimum_spawn_route_cells: int
cells: Array[TerrainPieceCellData] # exactamente 19 en la campaña
```

`data/terrain/starting_board.tres` define el hexágono axial de radio 2, la celda de base `(-1,0)` y el camino inicial recto `(-1,0) → (0,0) → (1,0) → (2,0)`, con salida exterior `(3,0)`. Valida coordenadas únicas, elevaciones/terrenos válidos y conectividad de la huella. `Main` instancia sus datos en `HexCell`; la ruta se valida con `PathGraph`, que exige como mínimo cuatro celdas PATH desde cada endpoint activo hasta la base durante la campaña. La base se conserva en `(-1,0)` al rotar el tablero alrededor de ella. Véase [ADR-0056](DECISION_HISTORY.md#adr-0056).

Rotación:
- rotar coordenadas locales alrededor del origen.
- rotar `path_edges` el mismo número de pasos.
- derivar y rotar también `flexible_path_edges` sin modificar el Resource original.
- nunca editar el Resource original; generar transformación temporal.

### TerrainPlacementResult / TerrainPlacementValidator
El validador de M3 recibe la pieza, el pivote axial, la rotación y las celdas actuales del `HexGrid`. Devuelve legalidad, errores, celdas instanciadas, si toca el tablero y cuántas conexiones compatibles tiene. Comprueba solapamiento, contacto por borde, sockets PATH explícitos/flexibles y una conexión a PATH existente cuando la pieza la requiere. Las conexiones internas usan exclusivamente `path_edges`; para conectar dos piezas se acepta una pareja complementaria en la unión de `path_edges` y `flexible_path_edges`. Una salida explícita no puede apuntar a terreno que no sea PATH. No busca rutas globales spawn-base; eso corresponde a `PathGraph` de M4.

### PathEndpoint / PathRoute / PathGraph
`PathEndpoint` identifica su rol (`SPAWN` o `BASE`), la celda PATH axial, la dirección de borde y la coordenada externa para un spawn. `PathRoute` contiene un candidato spawn, el objetivo base y la secuencia ordenada de celdas PATH que une ambos; M4 cachea una ruta mínima por candidato.

`PathGraph.rebuild(board_cells, base_coord, minimum_spawn_route_cells = 1)` deriva `nodes` y `adjacency` desde las celdas PATH. Solo crea adyacencia si ambos lados ofrecen un socket recíproco mediante `path_edges | flexible_path_edges`. Identifica como candidatos spawn las salidas `path_edges` que apuntan fuera del mapa; no convierte sockets solo flexibles en endpoints. `find_route(start, goal)` usa BFS de coste unitario con desempate estable por orden de las direcciones axiales; `get_branch_count()` cuenta nodos PATH con al menos tres vecinos conectados. El snapshot expone `spawn_endpoints`, `base_endpoint`, `routes`, `errors` e `is_valid`.

Un snapshot válido necesita que la base esté sobre PATH, que haya al menos un candidato spawn, que cada spawn tenga ruta a la base y que todos los nodos PATH pertenezcan a la red de la base; `Main` pasa el mínimo de cuatro celdas PATH para el tablero inicial y la campaña. El tablero inicial vigente coloca `GameBase` en `(-1,0)`; esa ubicación y su camino recto sustituyen la muestra M4/M5 en `(0,0)` según [ADR-0056](DECISION_HISTORY.md#adr-0056). El snapshot activo se reconstruye al iniciar o confirmar expansión. Mientras se mueve un ghost legal, `Main` construye aparte un snapshot candidato para actualizar en vivo la vista previa de rutas, spawns y cambios de recorrido; ese cálculo no sustituye ni muta el grafo activo. `TerrainPiecePreview` dibuja ese candidato y la información de debug. `removed_spawn_endpoint_keys` conserva las retiradas de la run, y `get_active_routes()` filtra sus endpoints sin mutar la topología PATH ni la cantidad directa de `WaveData`; con más de tres spawns activos, `WaveDirector` distribuye el total de enemigos entre las salidas restantes. El coste portal es dos veces el coste vigente de retirada de obstáculo, sin incrementar el contador de obstáculos retirados. El algoritmo y sus límites están registrados en [ADR-0007](DECISION_HISTORY.md#adr-0007), [ADR-0025](DECISION_HISTORY.md#adr-0025) y [ADR-0063](DECISION_HISTORY.md#adr-0063).

### TowerData : Resource
```text
id
unlock_id
display_name
build_cost
meta_unlock_cost
upgrade_base_cost_by_layer[Health, Armor, Shield]
upgrade_cost_growth_factor
targeting_xp_required_per_level
targeting_xp_growth_factor
max_layer_upgrades
base_damage
attack_rate
range_hexes
damage_profile
targeting_mode
status_to_apply
mana_cost_or_usage (si aplica)
attack_pattern + area/chain/cone parameters
visual_archetype + placeholder_color
visual_icon_size
allowed_terrain
height_rules
scene
```

M6 implementa en `data/towers/tower_data.gd`: identidad, daño base, RPM/cadencia, alcance, terrenos, prioridades, elevación, niveles, costes y escena. M12 agrega `unlock_id` y `meta_unlock_cost`, que se presenta como coste en XP de perfil. Ballista, Mortar y Tesla Coil se desbloquean al inicio; el roster construible de una run comienza únicamente con Ballista. Mortar/Tesla y las torres que se desbloqueen permanentemente entran como opciones de reclutamiento de cartas, no como botones de construcción hasta ser reclutadas. Frost Keep, Flame Thrower y Poison Sprayer requieren 50 XP de perfil y Shredder 100. M12A añade build-cost increment, Mana por ataque/segundo y escalado, RPM de base, multiplicadores Health/Armor/Shield, chance crítica, bonus de elevación, umbral de XP y parámetros Frost. Frost incluye cadencia por PATH, fracción de daño convertida en Slow y parámetros configurables de caída/contacto del copo. M13 añade `visual_icon_size`, que dimensiona por Resource el sprite y el pedestal de cada torre. Tras ADR-0041, los perfiles usan 84 px frente a los 54 px originales; el icono de preview usa el mismo tamaño. Los patrones soportan objetivo único, área, chain, cono, sawblade, todos-en-rango (Tesla) y caída/contacto de copos (Frost). Tesla Coil y Flame Thrower siguen los ajustes del changelog oficial en ADR-0036; Frost Keep usa daño 6 y 180 RPM según changelog oficial, con comportamiento de copos basado en su página específica comunitaria y ADR-0059. La progresión actual usa tres contadores de mejoras de 0 a 15, tres costes base por capa y factores exponenciales configurables para coste Gold y XP. Los valores iniciales 1,15 son provisionales; mejorar no muta el Resource compartido.

`Tower` mantiene un total de mejoras para el +1 de daño base por subida y un nivel independiente por capa. Cada capa empieza en 0/15; la compra Gold o el XP de la capa activa sube solo esa capa y su multiplicador, mientras que el XP de las otras capas y sus niveles no cambian. El primer requisito de XP y el primer coste usan el valor base del Resource; cada subida multiplica el siguiente requisito/coste por su factor exponencial. El XP runtime sigue `0.5 + 1 / (2 × alcance_hex)` por segundo mientras conserva un objetivo válido. La UI muestra XP/umbral y progreso visual por capa; el total es 0–45. Elevación añade +1 daño base y +0.5 de rango por nivel. El RPM es fijo salvo Frost Keep, cuya cobertura suma 18 RPM por PATH cubierto. Build price escala como `build_cost + same_type_count × build_cost_increment`; demoler reduce ese conteo y devuelve el precio marginal del slot que libera (ADR-0064). `TowerData` contiene los patrones `SINGLE_TARGET`, `AREA`, `CHAIN`, `CONE`, `SAWBLADE`, `ALL_IN_RANGE` y `FROST_SNOWFALL`; Ballista/Mortar tienen proyectiles, Mortar hace splash al aterrizar, Frost deja caer copos sobre PATH dentro de su cobertura cuadrada y Shredder sigue una ruta PATH. Ver [ADR-0023](DECISION_HISTORY.md#adr-0023), [ADR-0046](DECISION_HISTORY.md#adr-0046) y [ADR-0059](DECISION_HISTORY.md#adr-0059).
Los campos antiguos `upgrade_damage_per_level`, `upgrade_range_per_level` y `upgrade_attack_rate_per_level` se retiraron de `TowerData` y sus Resources porque no controlaban la fórmula real. El incremento vigente es fijo: +1 daño base y +1 al multiplicador de la capa que sube. `frost_slow_fraction` determina cuánto del daño aplicado se convierte en fuerza Slow para Frost; no se usa para los demás perfiles. `max_targets` solo limita el patrón `CHAIN`; no limita `ALL_IN_RANGE` (Tesla Coil), por lo que su Resource usa 1 como valor neutral. La revisión detallada está en la [auditoría del sistema de torres](CONTENT_AND_ASSETS.md#tower-audit).

Las prioridades incluyen progreso, menor suma actual de Health+Armor+Shield, valores más altos/bajos por capa y velocidad. Tres selectores numerados guardan posiciones 1–3; repetir un criterio en otra posición lo intercambia con el criterio de esa posición, para mantener opciones únicas y hacer explícito el orden. `DamageService.apply_damage` centraliza daño directo, crítico, tags y las tres capas. El modelo de cada enemigo contiene Health, Armor y Shield; cada perfil configura los tres máximos y cero desactiva una capa para esa unidad. Los ataques directos solo afectan a la capa activa en orden Shield→Armor→Health y usan su multiplicador. Si el objetivo tiene Bleed, Burn o Poison, los ataques directos suman +1 al multiplicador de Health, Armor o Shield, respectivamente; es un bonus único por estado activo y no escala con sus acumulaciones. Los ticks de estado usan los multiplicadores por capa del efecto: 1.0 en la capa asociada y 0.5 en las otras. `Enemy` dibuja una fila por cada capa con máximo positivo, y segmenta Health. La demo incluye el dummy DEBUG y los 45 perfiles de campaña; los perfiles que tengan Shield muestran esa capa en juego. El exceso al vaciar una capa se descarta en el mismo impacto; el artículo de referencia confirma el orden y el acceso solo a la capa activa, pero no especifica expresamente el destino del exceso, así que esta política sigue marcada como provisional.

### EnemyData : Resource
```text
id
display_name
max_health
armor
shield
regen_per_second
armor_regen_per_second
shield_regen_per_second
move_speed
base_damage
kill_reward
boss_tier
abilities: Array[EnemyAbilityData]
physical_damage_multiplier
fire_damage_multiplier
arcane_damage_multiplier
poison_damage_multiplier
placeholder_color
placeholder_radius
sprite_texture: Texture2D opcional
sprite_extent
scene
```

Históricamente M5 introdujo Health, M7 Armor/regen y M12A completó Shield con regeneración separada; el modelo vigente de cada enemigo contiene los tres pools. Cada perfil configura los máximos, y un máximo cero omite esa capa en el juego. El orden activo es Shield→Armor→Health. Bleed/Burn/Poison detienen la regeneración de Health/Armor/Shield y aumentan en +1 el multiplicador de ataque de esa capa; sus ticks aplican el daño por capa 1.0/0.5/0.5 según la capa activa. Los multiplicadores recibidos por múltiples tags se multiplican. `sprite_texture` referencia el PNG individual del perfil; si no hay textura, `Enemy` conserva el dibujo vectorial placeholder. La barra dibuja las capas con máximo positivo en filas diferenciadas y fragmenta Health.

`EnemyData.sprite_extent` configura individualmente el lado del PNG de cada enemigo en juego; los perfiles estándar pasan a 72 px y los perfiles grandes escalan proporcionalmente. La ilustración se dibuja 6 px por debajo del anclaje del PathFollower. `placeholder_radius` se usa para el placeholder vectorial y la colocación de barras/estados; no representa una hitbox ni cambia movimiento, selección, ocupación o colisión lógica. Si no hay textura se conserva el dibujo vectorial. `EnemyData` no exporta `defense_tags` ni `status_resistances`: los tags del paquete se definen en `DamagePacket` y el Resource sí configura multiplicadores recibidos por cada tag. Las resistencias de estado no están implementadas.

`Enemy` usa el `EnemyData.id` estable para elegir el color claro del outline del sprite; los perfiles DEBUG sin color dedicado usan el valor de reserva. El mapa de colores es de presentación y no se serializa dentro de `EnemyData`. Ver [ADR-0097](DECISION_HISTORY.md#adr-0097).

### BaseData / HealthComponent

`BaseData` configura el ID, nombre, Health máxima y `sprite_texture` de la base. La textura RGBA es un PNG individual sustituible desde el Resource; `GameBase` conserva intacto el PNG de 270×352 px y actualmente lo dibuja con escalas independientes X/Y, a 1,8 × el radio de huella de ancho por 2,8 × de alto, con el borde inferior anclado. La deformación es visual/provisional y no altera la huella lógica de un hexágono, según [ADR-0096](DECISION_HISTORY.md#adr-0096). `HealthComponent` inicializa Health, aplica daño/curación acotados y emite `health_changed` y `health_depleted`; en M5 lo consumen `GameBase` y `Enemy`. La barra del HUD usa un segmento por HP; al perder vida, cada segmento que desaparece recibe una animación breve de flash, encogimiento y desvanecimiento. `Main` colorea el relleno con una transición verde→ámbar→rojo y controla una viñeta de peligro a 3/2/1 HP. La coordenada inicial vigente de la base es `(-1,0)`, según [ADR-0056](DECISION_HISTORY.md#adr-0056). `data/base/base_data.tres` define 10 HP base; `MetaProgression` suma +1 por cada nivel de Fortification permanente hasta 20 HP en nivel X, con costes y requisito secuencial de [ADR-0074](DECISION_HISTORY.md#adr-0074). Las cards de run aplican sus propios aumentos acumulables de +3 HP. Ver [ADR-0119](DECISION_HISTORY.md#adr-0119).

### DamagePacket
```text
raw_damage
critical_multiplier
source_id
damage_tags
armor_multiplier # compatibilidad histórica M7
health_multiplier # compatibilidad histórica M7
health_damage_multiplier
armor_damage_multiplier
shield_damage_multiplier
is_status_damage # marca los ticks para no aplicarles el bonus de ataque directo
regen_counter_strength
regen_counter_duration
status_payloads
status_total_damage_overrides # presupuesto bruto total opcional por estado, distribuido entre sus ticks
```

El contrato M7 de mitigación plana de Armor queda sustituido por M12A. `DamagePacket` es transitorio y `DamageResult` registra la capa activa y daño por cada HP. Para un ataque directo, el daño es `floor(raw_damage × critical_multiplier × (layer_multiplier + status_bonus) × damage_tag_multiplier)`, limitado a la capa activa: Shield antes que Armor, después Health. `status_bonus` es +1 si Bleed/Health, Burn/Armor o Poison/Shield coincide con la capa activa. Los ticks llevan `is_status_damage` y no reciben ese bonus: sus multiplicadores propios determinan daño completo en su capa asociada y mitad en las otras. El excedente no desborda provisionalmente. Chance crítica produce ×1/×2/×3/×4 con bandas de 50%. Los multiplicadores de tag vienen de `EnemyData` y los tags simultáneos se multiplican. M8 consume payloads si el objetivo sigue vivo; cada tick de DoT vuelve al mismo servicio. Un override de total fija presupuesto bruto por aplicación de estado sin mutar Resources. Ver ADR-0010 para el contrato histórico y [ADR-0023](DECISION_HISTORY.md#adr-0023) para la regla vigente.

### StatusEffectData
```text
id
display_name
duration
tick_interval
max_stacks
stack_rule: REFRESH | ADD_STACKS
speed_multiplier
damage_per_tick
damage_tags
health_layer_multiplier
armor_layer_multiplier
shield_layer_multiplier
```

M8 implementa estos campos en `game/combat/status_effect_data.gd`. `duration` siempre es positiva; `tick_interval` puede ser cero si el efecto no hace daño periódico. `REFRESH` deja una acumulación y reinicia la duración; `ADD_STACKS` suma una acumulación hasta `max_stacks` y también reinicia la duración. Reaplicar no reinicia el reloj del próximo tick. El daño por tick se multiplica por las acumulaciones y pasa por `DamageService` con los `damage_tags` configurados. Si una torre reaplica el mismo ID, la definición y el `source_id` activos pasan a ser los de la aplicación más reciente. Cada enemigo guarda sus propias instancias runtime y no modifica los Resources compartidos. Los efectos de velocidad se combinan usando el menor multiplicador activo; al quitar el último efecto se restaura `1.0`. Slow puede declarar `strength_cap` y `strength_decay_per_second`: su fuerza se convierte en reducción porcentual de movimiento y decae linealmente. Frost usa ese modo y pasa al controlador la mitad del daño realmente aplicado por impacto. Muerte y llegada a la base limpian todos los estados. El campo de resistencias queda fuera mientras el diseño no lo necesite. Slow, Burn, Bleed y el Poison de M9.5 son datos configurables provisionales; el fixture de oleada M8 se retiró en M64 y Bleed también se usa en Shredder.

`TowerData.status_effects` es una lista de estos Resources, sin IDs repetidos dentro de una torre. `DamagePacket.status_payloads` transporta esa lista del impacto al `DamageService`, y `DamageResult.applied_status_ids` permite auditar qué se aplicó. El override de presupuesto no modifica el Resource compartido: el controlador guarda el total y los ticks restantes en la instancia del estado de cada enemigo.

### EnemyAbilityData

EnemyData incluye boss_tier y abilities: Array[EnemyAbilityData]. Cada habilidad declara un trigger (aparición, cerca de la base, armor agotado, shield agotado, muerte o periódica), un efecto (Haste, Fortification, invocar, transformar o teletransportar), política de objetivo, fuerza/intervalo/radio y los datos u overrides del enemigo afectado. Los radios de juego aprobados son cinco hexágonos para cercanía a la base y dos hexágonos para auras. Haste/Fortification tienen fuerza máxima 60 y decaen 6 puntos por segundo; Haste suma su porcentaje a la velocidad y Fortification resta cinco al daño base recibido por golpe. Los parámetros de invocación y transformación pertenecen a cada perfil.

### WaveData

Campos: round_number, encounter_type STANDARD/BOSS/TIER_2_BOSS, groups, round_reward. Cada grupo declara enemy_data, count, spawn_interval, spawn_endpoint_policy y delay_before_group.

M5 implementa WaveData y WaveEnemyGroupData como Resources validados. Los fixtures de diagnóstico conservan FIRST_SORTED/ROUND_ROBIN como políticas configurables.

En la campaña, count es la cantidad directa de enemigos del grupo. WaveDirector crea un enemigo por intervalo y rota las rutas alcanzables round-robin; la cantidad no depende del número de endpoints abiertos. Los grupos se ejecutan en el orden de la tabla, que define [14 — Campaña de 45 rondas](CONTENT_AND_ASSETS.md#campaign). Los enemigos invocados cuentan como apariciones adicionales y permanecen dentro de la misma oleada. Una transformación conserva la instancia, progreso y recompensa de la baja original.

WaveCampaignData exige 45 WaveData consecutivas y 1.093 enemigos directos. Valida el número de ronda, el tipo de encuentro calculado desde boss_tier y el total fijo. Las tasas globales de Health, daño a base y recompensa por baja están en cero; no se cambia EnemyData al escalar la ronda. Las recompensas de limpieza y cadencias se especifican en ADR-0037 y se mantienen provisionales donde se indica. El juego termina al limpiar la ronda 45; tras las rondas 1–44 hay una expansión. No existen designaciones Miniboss propias en 17/19. Los diagnósticos siguen aislados de la campaña.

### RunEconomyData / RunEconomyService
`RunEconomyData` es una configuración Resource de una run: `starting_gold`, `starting_mana`, `maximum_mana` y `mana_regen_per_second`. `RunEconomyService` es un Node hijo de `Main`, no Autoload: es dueño de los saldos runtime de esa escena, valida compras/gastos, limita el Mana a la capacidad y emite `gold_changed`/`mana_changed`. `refill_mana_to_max()` restaura el Mana al máximo efectivo al comenzar cada ronda de campaña. La UI escucha esas señales, pero no modifica los saldos directamente; el contador de Mana se presenta como entero y el Gold aplica feedback visual al cambiar. El Gold de construcción se reinicia con el perfil de arranque de la run y no es `MetaProgression.meta_currency`; `MetaProgression` conserva la moneda permanente y entrega los bonuses antes de configurar la siguiente economía. La configuración activa inicia con 1.000 Gold y 100/100 Mana; Starting Coffers suma 100 Gold por nivel hasta +1.000 y el máximo de 2.000. La tasa interna base de Mana es 1.5/s. Las tasas fraccionarias se describen al jugador como equivalencias de cantidades enteras por intervalos enteros, sin cambiar el valor runtime.

### CardModifierOperation
```text
type
affected_tower_id: optional
affected_damage_tags: optional bitmask
affected_status_id: optional
value
```

Tipos disponibles: daño plano/multiplicador, alcance, radio de área, coste de Mana, duración de estado, Mana máximo/regeneración, crítico, suma al multiplicador H/A/S, daño/cap/fuerza de estados, alcance por elevación, radio porcentual, conversión de daño de Mana, Mana por baja, Gold por baja, daño a base, vida de base y crítico por nivel. Los efectos nuevos que no tienen equivalencia directa se implementan como operaciones configurables. Frost Keep también añade RPM por cobertura PATH; ninguna de las 190 cards de mejora define una operación de RPM. Las seis cards de reclutamiento tampoco tienen operaciones de modificador.

### CardData
```text
id
display_name
description
rarity
unlock_requirement: optional content ID
grant_tower_id: optional TowerData ID
required_card_ids[]
any_required_card_ids[]
tags[]
modifier_operations: Array[CardModifierOperation]
offer_weight
max_per_run
```

Una carta describe una mejora temporal de la run o, si `grant_tower_id` está definido, recluta una torre sin aplicar modificadores. Las operaciones no modifican el `TowerData` ni otros `.tres` compartidos. Las operaciones aditivas se suman y los multiplicadores se combinan multiplicando. `unlock_requirement` vacío indica una carta global; los IDs de torre usan `tower:<TowerData.id>`. `required_card_ids` y `any_required_card_ids` expresan las cadenas y ramas del árbol de cartas; solo se ofrecen tras elegir sus prerrequisitos. Las cartas de reclutamiento requieren el unlock permanente y desaparecen cuando la torre ya está en el roster de esa run; los modificadores específicos solo aparecen después de reclutar la torre afectada.

### CardPoolData / RunCardService
`CardPoolData` combina las 18 cards propias (incluida Advanced Circuits) y 172 Resources nuevos en catálogos `CardCatalogData`: son 190 IDs de mejora que representan 173 entries compatibles de referencia. M35 añade seis Resources de reclutamiento; el pool runtime contiene 196 IDs. Un catálogo puede requerir cards del pool anfitrión; `CardPoolData` resuelve los prerequisitos después de unir todos los catálogos. La fuente de verdad fija tres opciones y el calendario configurable. La demo ofrece una mejora después de las rondas 3–42 en intervalos de tres, una vez colocada la expansión de la ronda; no hay oferta posterior a la 45. `RunCardService` filtra por unlock permanente, roster de run, peso, prerequisitos y límite de copias, y construye una oferta de exactamente tres cartas sin duplicados. Si existe al menos un reclutamiento elegible, garantiza uno y sortea las opciones restantes por peso entre cartas aún elegibles, con máximo de dos reclutamientos en total. Cada torre reclutada queda disponible para construir y habilita sus mejoras específicas; los reclutamientos no elegidos permanecen elegibles en ofertas futuras. `card_draw` se conserva como ID legado en el catálogo persistente, pero no se muestra en el mapa ni altera el tamaño fijo de oferta. `RunCardService` es local a `Main`; `MetaProgression` alimenta los filtros con los IDs persistentes y `RunManager` con los IDs reclutados en la run. Ver [ADR-0118](DECISION_HISTORY.md#adr-0118).

### RunManager
`RunManager` es Autoload de estado efímero de partida. `begin_run()` reinicia el roster a Ballista y limpia los contadores de construcción/daño. Un `grant_tower_id` seleccionado añade una torre al roster actual. Cada instancia construida asocia su ID de torre para sumar daño de `DamageResult` a su categoría; el resumen incluye cantidad construida y daño por tipo, filtrado por los unlocks permanentes al terminar. No se persiste el roster ni las métricas temporales.

### PermanentUpgradeData
```text
id
display_name
description
max_level
cost_by_level[]
prerequisites[]
prerequisite_unlock_ids[]
operations_by_level[]: PermanentUpgradeOperation
```

`PermanentUpgradeOperation` expresa una sola operación por nivel: economía inicial, Mana, daño de torre, desbloqueo, cofre, Gold por baja, vida/reparación de base y bonus H/A/S de torre. El tamaño de oferta ya no es una operación activa; el tipo antiguo y el ID `card_draw` se conservan solo para compatibilidad con perfiles anteriores. `prerequisites` conecta mejoras usando el ID exacto de `PermanentUpgradeData.id`; la validación rechaza IDs que no existan. Por ejemplo, Archivo de cartas requiere `meta:chest_finder`, ID persistente de Suerte del explorador. `prerequisite_unlock_ids` limita las mejoras de torre al unlock persistente correspondiente. Las tres mejoras H/A/S de cada torre comparten ese unlock y no se prerequisitan entre sí; en el mapa sus tres conexiones salen directamente del nodo de torre. Fortification I–X añade +1 HP por nivel, cuesta 20, 40, 60, 80, 100, 120, 140, 160, 180 y 200 XP (1.100 en total); solo se compra el siguiente nivel, por lo que cada nivel superior requiere el anterior. No se añaden requisitos de cantidad de cartas desbloqueadas. El mapa de tienda comparte una escena de nodo para todas las categorías, muestra el icono del sistema o torre afectada, el coste y los prerequisitos y emite partículas al comprar; los tooltips describen cómo habilitar nodos bloqueados. La tienda se reutiliza desde menú y final de run; los efectos comprados se aplican desde la siguiente run y el Resource de definición no se modifica. `MetaProgressionData` combina el catálogo propio con catálogos `PermanentUpgradeCatalogData`. El contenido actual reúne seis mejoras propias y 25 mejoras incorporadas de referencia, incluida la entrada legada `card_draw` que no está disponible para comprar; los valores y límites continúan configurables. Ver [ADR-0081](DECISION_HISTORY.md#adr-0081) y ADR-0093.

### SaveData
```json
{
  "version": 1,
  "meta_currency": 0,
  "unlocked_towers": ["tower:ballista_demo"],
  "permanent_upgrade_levels": {},
  "settings": {},
  "total_runs_started": 0,
  "total_runs_completed": 0,
  "total_victories": 0,
  "best_round_reached": 0,
  "total_meta_earned": 0,
  "last_run_summary": {}
}
```

`SaveData` convierte a/desde primitivas JSON y valida tipos/rangos. La ruta es `user://rogue_tower_meta.json`; se escribe un temporal, conserva el anterior como `.bak` y reemplaza el archivo. Versiones distintas y JSON inválido no se cargan ni se sobrescriben automáticamente. El resumen almacena outcome, ronda alcanzada/completada, recompensa, saldo, número y seed; no se serializa el estado temporal de una run.

<a id='terrain'></a>
## Grid hexagonal y terreno

### 1. Coordenadas
Usar coordenadas axiales `(q,r)` con 6 vecinos. La orientación provisional del prototipo es pointy-top, registrada en [ADR-0001](DECISION_HISTORY.md#adr-0001); mantenerla en todo el grid y reabrirla solo al revisar el arte propio.

Toda lógica usa coordenadas hex. Nunca inferir conectividad mirando píxeles.

### 2. Pieza de 7 hexágonos
La pieza es una agrupación lógica. No debe ser un único sprite gigante como fuente de gameplay.

Requisito:
- 7 `TerrainPieceCellData`.
- una celda origen/pivote.
- seis rotaciones posibles.
- preview de toda la pieza.
- cada celda conserva terreno, altura y conexiones tras rotar.

La plantilla de loseta de 7 hexágonos confirmada por el usuario usa el centro `(0,0)` y sus seis vecinos inmediatos: `(0,-1)`, `(1,-1)`, `(1,0)`, `(0,1)`, `(-1,1)` y `(-1,0)`. Sus seis orientaciones válidas se obtienen rotando en pasos de 60° alrededor de `(0,0)`. Esa huella define el tamaño de cada pieza de terreno, no el tamaño del tablero de inicio.

Las celdas de la plantilla pueden ser PATH, GRASS o MOUNTAIN. La vista diferencia esos tipos mediante arte PNG en tres variantes por terreno; no dibuja iniciales ni coordenadas encima de las caras. El panel de terreno muestra axial `(q,r)`, tipo y altura al pasar el cursor por una cara superior. El conjunto tiene tres variantes por tipo. Desde la sustitución artística del 2026-10-13, las caras PATH usan el arte genérico Dirt_01/02/03, sin camino pintado; PATH conserva su identidad lógica y las flechas animadas siguen indicando el recorrido. Ver [ADR-0058](DECISION_HISTORY.md#adr-0058).

El tablero inicial está separado de las piezas de expansión y se configura en `data/terrain/starting_board.tres`: ocupa un hexágono axial de radio 2 (19 celdas) y coloca la base en `(-1,0)` para permitir un camino recto sin ampliar el tablero. `StartingBoardData` valida 19 coordenadas únicas, terreno/elevaciones permitidos, una huella conectada y que las seis celdas vecinas a la base no superen elevación 1. PATH permanece a 0 y Grass junto a la base a 1; Mountain no puede formar parte de ese anillo. La generación vuelve a aplicar el límite, y normaliza a Grass cualquier Mountain que llegase a una posición vecina de la base. La ruta inicial va en línea recta por `(-1,0) → (0,0) → (1,0) → (2,0)` y la salida exterior queda en `(3,0)`: cuatro celdas PATH contando base y spawn. En campaña, `PathGraph` además rechaza cualquier endpoint cuya ruta mínima a la base tenga menos de cuatro celdas PATH; se conserva esa distancia también al colocar expansiones. El tablero lineal se registra en [ADR-0056](DECISION_HISTORY.md#adr-0056); las elevaciones se mantienen dentro de [ADR-0073](DECISION_HISTORY.md#adr-0073) con el límite adicional de [ADR-0087](DECISION_HISTORY.md#adr-0087).

Desde M10, las expansiones rellenan al azar con Grass o Mountain los espacios vacíos completamente encerrados dentro de la envolvente axial del tablero. Un espacio conectado a un borde exterior o a una salida PATH abierta queda vacío. Los rellenos son celdas construibles y no forman parte de una pieza del jugador. Grupos conectados de 3–4 Grass/Mountain reciben un brillo tenue de combo 3; grupos de 5 o más reciben un brillo algo más intenso de combo 5. Es señal visual sin bonus numérico confirmado. El catálogo contiene las cinco plantillas originales y diez Resources adicionales: Pradera de colinas, Macizo montañoso, Llanura abierta, Cresta escalonada, Loma aislada, Picos gemelos, Pradera con ramal sin salida, Curva junto al acantilado, Camino serpenteante y Bifurcación del barranco. Todas conservan la huella central de siete celdas y las conexiones PATH internas son recíprocas; cuatro piezas nuevas amplían rutas y giros.

### Obstáculos, cofres y variantes visuales

Actualización artística (ADR-0058): Path_01/02/03 usa las ilustraciones Dirt_01/02/03 sin camino pintado. Es un cambio de textura únicamente; `PATH`, sus sockets, el `PathGraph` y las flechas animadas mantienen su comportamiento.

Cada celda de Path, Grass o Mountain recibe props decorativos deterministas a partir del seed y de su coordenada axial; en una oferta se usa su seed estable de oferta y coordenada local. Cada asset compatible con el terreno tiene una tirada independiente del 10 % por celda. La selección evita repetir el mismo asset dentro de la celda y conserva como máximo dos; no ocupa ni bloquea la celda y no crea una superficie interactiva. Los PNG se recortan al alfa y normalizan a 96×96 px, se dibujan a 39,6×39,6 px en posiciones separadas y nunca se seleccionan. Si comparten celda con obstáculo, este se dibuja delante. La miniatura sin ancla enseña el contenido de oferta; al colocar junto a la base, el ghost y el tablero confirmado convierten Mountain a Grass y regeneran juntos los props compatibles con el terreno resultante a partir de la coordenada global.

Los portales usan `assets/sprites/terrain/spawn_portal_SpriteSheet.png`, un atlas de 4×2 con ocho frames cuadrados de 443×443 px. La animación recorre los primeros siete frames en bucle continuo a 10 FPS; se omite el último porque es igual al primero. Cada endpoint recibe una fase inicial determinista y única, guardada durante la run; al actualizar una colocación, los portales existentes no se reinician ni se sincronizan. Si la colocación elimina un portal bajo el cursor, se limpia de inmediato su estado de hover y el tooltip.

Grass tiene 25 % de probabilidad de obstáculo, Mountain 15 %; PATH no genera obstáculos. El pool runtime reemplaza los antiguos cinco sprites con ocho assets: matorral, tronco caído, montón de ramas, tocón, rocas y madera, caja de suministros, raíces expuestas y roca musgosa. El panel de selección muestra el nombre que corresponde al sprite. El obstáculo es contenido del hex, no un tipo de terreno, elevación, nodo ni borde de `PathGraph`; bloquea construir en esa celda igual que una celda PATH. Una pieza de expansión admite como máximo dos obstáculos entre sus siete hexes. El tablero inicial admite uno como máximo en total y excluye la celda de base y sus seis vecinas inmediatas. En `ROUND_PREP`, el jugador puede seleccionar y pagar para quitar un obstáculo. La retirada n cuesta `25 × n²` Gold, donde n es el ordinal de retirada: 25, 100, 225, 400… Las retiradas de portales no incrementan ese contador. Ver [ADR-0079](DECISION_HISTORY.md#adr-0079) y [ADR-0087](DECISION_HISTORY.md#adr-0087).

Una celda Grass/Mountain sin obstáculo tiene un 1 % de probabilidad base de cofre. «Suerte del explorador» suma cinco puntos porcentuales por nivel en cuatro niveles; el último incremento queda limitado por el tope y la posibilidad máxima es 20 %. En expansiones, la probabilidad se calcula al confirmar la colocación: ni la miniatura de la pieza ni el ghost muestran cofres. Si la tirada tiene éxito, el cofre aparece en el tablero con un salto único. PATH, obstáculos y cofres son excluyentes. Hacer clic en un cofre cerrado lo abre y entrega Gold; la recompensa inicial del juego es 25 Gold por cofre y se considera balance provisional configurable. Una celda con cofre cerrado no admite construcción. Al pasar el cursor por un cofre, este bota y recibe un resplandor dorado.

Todos los PNG de juego están centralizados bajo `assets/sprites/`; `assets/sprites/terrain/` contiene terreno, fachadas, obstáculos y props. El PNG de terreno contiene nueve imágenes: tres variantes por cada tipo Path/Grass/Mountain. `TerrainVisualCatalog` recorta por variante el área visible y la coloca en el rectángulo exacto de la cara hexagonal; así elimina el desfase que producía el padding distinto entre casillas del atlas. Los ocho obstáculos actuales son PNG separados con nomenclatura `obstacle_<nombre>.png`, normalizados a 208×208 px; la caja común de dibujo es 94,6×94,6 px (`OBSTACLE_DISPLAY_SIZE`), sin desplazamiento del centro de celda. La textura se estira para ocupar la caja completa tanto en el tablero como en las cards. Los props viven en `random_props/{grass,mountain,path}/`, usan nombres `prop_<terreno>_<nombre>.png`, mantienen alfa y miden 96×96 px. Se dibujan a 39,6×39,6 px con una tirada del 10 % por asset y celda, hasta dos props sin solaparse. El contenido visual no cambia huellas, sockets, elevación ni selección axial.

Cada oferta crea copias de sus piezas y fija el roll de obstáculo y props por seed, ronda, índice de oferta, ID de pieza y coordenada local. Ghost y tablero confirmado conservan la oferta; en el anillo de base, la normalización de terreno y props se refleja de forma idéntica en ambos. La miniatura no tiene ancla global y conserva los tipos/props sin colocar. Las miniaturas usan las tapas hexagonales texturadas, las fachadas y el orden axial del tablero, además de las alturas de esa copia de oferta. Los cofres se sortean únicamente al confirmar la colocación y se muestran después en el tablero. El tablero inicial y los rellenos interiores usan los rolls reproducibles por seed y coordenada axial. El tamaño de obstáculo continúa el objetivo de caja de [ADR-0046](DECISION_HISTORY.md#adr-0046); arte, centro y props se actualizan en [ADR-0087](DECISION_HISTORY.md#adr-0087). La consistencia de preview sigue [ADR-0060](DECISION_HISTORY.md#adr-0060) y [ADR-0083](DECISION_HISTORY.md#adr-0083).

Las aristas del hex y los sockets PATH permanecen ocultos mientras no haya hover. Al pasar el cursor por una celda se dibujan su borde y conexiones de ruta; los bordes de los anillos vecinos se atenúan por distancia axial. Las flechas de flujo siguen visibles en la ruta para enseñar el sentido hacia la base. Cada spawn alcanzable muestra un portal PNG pulsante en su celda exterior, sin texto ni cartel. Al pasar el cursor sobre el portal, su silueta recibe un contorno y un tooltip enumera retratos, tipos y cantidades asignados a esa salida en la siguiente ronda. Al hacer clic, el panel de información presenta la misma asignación como lista con el sprite de cada enemigo. No se dibujan iconos enemigos sobre los portales; M55 sustituye los antiguos badges flotantes. El reparto se calcula con la misma política de `WaveDirector`: en campaña, round-robin global entre endpoints alcanzables, reiniciado al iniciar cada ronda; en los fixtures DEBUG históricos se respetaba la política configurada por grupo (retirados en M64). La previsión se actualiza al cambiar la ronda y al mover el grafo candidato. Al seleccionar una pieza y mover el preview a una colocación válida, los portales pasan al `PathGraph` candidato y se sitúan en sus endpoints previstos; el tono verde indica ese estado. Una colocación inválida o cancelada restaura los portales del grafo activo. En `ROUND_PREP`, también se puede quitar un portal pagando el doble del precio actual de obstáculo (50 Gold inicialmente). Deben permanecer al menos tres spawns; al retirarlo, el total de enemigos de la oleada se conserva y el `WaveDirector` los reparte de nuevo entre las salidas activas. Ver [ADR-0105](DECISION_HISTORY.md#adr-0105).

La silueta NO tiene por qué ser siempre el hexágono central + seis vecinos si en el futuro se diseñan otras formas de 7 celdas. El sistema debe soportar cualquier conjunto conectado de 7 hexes.

Sin una torre seleccionada ni una pieza en colocación, el hover muestra un tooltip pequeño junto al cursor: tipo de terreno, disponibilidad/ocupación y altura. En Grass/Mountain añade el bonus calculado para las torres compatibles desde sus `TowerData`; en el roster vigente cada nivel aporta +1 daño y +0,5 hex de alcance. PATH se identifica como ruta no construible. El tooltip se oculta durante una selección, sobre la interfaz o mientras otro panel contextual está activo. Ver [ADR-0072](DECISION_HISTORY.md#adr-0072).

### 3. Validación de colocación
Una colocación es legal si:
1. Ninguna de sus 7 celdas solapa una celda existente.
2. La pieza toca el mapa existente por al menos un borde.
3. Si el diseño requiere conexión de camino, al menos una entrada de Path de la pieza conecta con un Path existente.
4. Ninguna salida PATH explícita apunta a terreno que no sea PATH; las ofertas flexibles solo conectan con otra celda PATH.
5. Tras colocarla, el/los spawns que deban conservar ruta hacia la base siguen teniendo una ruta válida de al menos cuatro celdas PATH.
6. No se crea una celda construible inaccesible visualmente por error de renderer (solo validación de desarrollo).

Regla de diseño: las conexiones de camino se definen explícitamente por borde; no asumir que dos celdas PATH adyacentes conectan si la plantilla visual dice lo contrario.

Contrato ejecutado por M3, registrado en [ADR-0004](DECISION_HISTORY.md#adr-0004):
- `path_edges` es una máscara de seis bits. Dirección 0 = este `(1,0)`, 1 = sureste `(0,1)`, 2 = suroeste `(-1,1)`, 3 = oeste `(-1,0)`, 4 = noroeste `(0,-1)`, 5 = noreste `(1,-1)`; el borde opuesto es `(dirección + 3) mod 6`.
- Las conexiones internas de una pieza requieren `path_edges` recíprocos entre dos PATH. Si una conexión interna apunta a otra clase de terreno o no es recíproca, el Resource es inválido.
- Cuando un `path_edges` externo sale de la huella, se derivan dos sockets laterales flexibles en las caras contiguas que también queden fuera de la huella. Se rotan con la pieza y se ven como brazos laterales más tenues. Permiten conectar una pieza por el borde central o por cualquiera de esos laterales, siempre que los hexágonos vecinos sean PATH y la otra cara ofrezca el borde exacto o flexible complementario.
- Las salidas explícitas sin pareja siguen siendo errores si enfrentan una celda existente; una salida flexible es opcional y puede quedar abierta o mirar a terreno que no sea PATH. `requires_path_connection` exige al menos una salida externa explícita y que durante la colocación una conexión compatible llegue a un PATH existente.
- El `HexGrid` confirma las siete celdas de forma atómica después de validar. El Resource original no se modifica; las celdas rotadas son copias y reciben un `piece_instance_id`.
- M3 muestra una torre fantasma con shader verde translúcido cuando la colocación es legal y rojo cuando no lo es, por encima de terreno y props. El cursor se ajusta a coordenadas axiales; clic izquierdo o el botón del HUD confirma, `Esc`, clic derecho o Cancelar abandona el preview. Durante una colocación de terreno, `Q`/`E` giran 60°; en la regla actual M55, `Ctrl+rueda` también gira y la rueda sin modificador hace zoom incluso durante la colocación. `T` confirma una ubicación automática válida conservando las reglas de ruta.
- Las miniaturas de cards de expansión no dibujan los brazos/ramificaciones de conexión PATH: muestran las superficies del terreno y los props para comunicar la forma y el contenido sin superponer el grafo de navegación.
- M4 implementa la verificación global mediante `PathGraph`: el snapshot activo solo cambia al iniciar o confirmar terreno. Mientras se mueve un ghost geométricamente válido, `Main` deriva un snapshot candidato independiente y `TerrainPiecePreview` actualiza la comparación de spawns sin mutar el tablero ni sustituir el grafo activo. La confirmación usa esa misma validación y se rechaza si falta la base, no queda ningún endpoint spawn, una salida exacta no encuentra socket complementario o una celda PATH/spawn no tiene ruta a la base. El control visual de celdas construibles inaccesibles sigue siendo revisión de desarrollo.

### 4. Bifurcaciones y convergencias
El grafo permite grado > 2.
- Bifurcación: un nodo/ruta puede tener varias salidas.
- Convergencia: varias ramas pueden llegar a una misma sección.
- El comportamiento exacto de selección de rama del enemigo debe ser configurable/determinista.

Prototipo recomendado:
- cada spawn calcula la ruta de menor coste hasta la base;
- si hay empate, usar tie-break determinista basado en coordenadas/run seed.

### 5. Spawn endpoints
No asumir que cada endpoint es siempre un spawn.
`PathGraph` expone endpoints; `WaveDirector` decide cuáles están activos según ronda/reglas.

Esto permite que ampliar terreno "haga que puedan venir desde más sitios" sin obligar a activar todos inmediatamente.

En M4, cada salida exacta `path_edges` que queda abierta hacia una coordenada fuera del tablero se presenta como candidato spawn. Las aperturas exclusivamente flexibles no son endpoints; solo forman conexión cuando una celda PATH vecina ofrece la cara recíproca. El endpoint guarda la celda PATH, la dirección axial y la coordenada exterior para que M5 pueda colocar el enemigo antes de recorrer la ruta. Durante la previsualización, los endpoints que cerrarían permanecen en su sitio con una X roja y el estado indica el número de cierres. En campaña, cada oferta incluye una card `EXTIENDE RUTA` con una colocación validada para prolongar una ruta alcanzable; la forma sugerida varía entre recta, curva y bifurcación, y algunas ofertas no contienen ninguna recta. Una colocación de campaña se rechaza si su tablero resultante no conserva al menos una siguiente colocación legal que extienda una ruta. Durante toda la selección de terreno se deshabilitan las acciones de torres, construcción y cofres; el jugador elige, rota, coloca o cancela la pieza y puede pausar con `P` o el botón bajo la vida. En `ROUND_PREP`, iniciar ronda quita la pausa; durante la selección de terreno no se puede iniciar. En campaña M10 se activan todos los endpoints PATH abiertos con ruta a la base y cada enemigo se asigna en round-robin global a uno de ellos; los fixtures DEBUG históricos seguían la política de spawn de cada grupo y se retiraron en M64. Cada portal alcanzable muestra el icono y conteo de tipos asignados a esa salida en la siguiente ronda, y al hover presenta el detalle y un contorno de su silueta alfa. Flechas luminosas en movimiento siguen cada arista de ruta hacia la base; se conservan las ramificaciones y los enlaces compartidos se dibujan una sola vez. `Ctrl+D` alterna el overlay de diagnóstico de rutas BFS y base; `WASD` desplaza la cámara. El mapa recalcula estos indicadores junto con el `PathGraph` al confirmar terreno. La partida usa ahora un tablero semilla de 19 celdas, `GameBase` en `(-1,0)` y la ruta recta descrita arriba; cada ruta de spawn a base debe contener cuatro o más celdas PATH. Véase [ADR-0007](DECISION_HISTORY.md#adr-0007), [ADR-0025](DECISION_HISTORY.md#adr-0025), [ADR-0051](DECISION_HISTORY.md#adr-0051), [ADR-0056](DECISION_HISTORY.md#adr-0056), [ADR-0057](DECISION_HISTORY.md#adr-0057), [ADR-0060](DECISION_HISTORY.md#adr-0060) y [ADR-0061](DECISION_HISTORY.md#adr-0061).

`PathGraph` mantiene una arista cuando ambas caras PATH ofrecen socket exacto o flexible complementario. Resuelve una ruta mínima por número de enlaces con BFS y desempate por orden de direcciones de `HexCoord`. La adyacencia conserva caminos alternativos en bifurcaciones y convergencias aunque cada spawn tenga una ruta cacheada escogida para el prototipo. El grafo activo se recalcula al iniciar/confirmar; durante el movimiento de un ghost legal se crea el grafo candidato separado para actualizar la vista previa. El flujo animado usa la ruta candidata si la colocación es válida; `Ctrl+D` muestra la información estática de diagnóstico.

### 6. Elevación
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

Cada nivel eleva visualmente la cara superior 28 px (antes 18 px), valor único definido en `HexMath`; la elevación lógica vigente va de 0 a 3 y no cambia reglas de movimiento. PATH usa 0, Grass 1–2 y Mountain 2–3. Las alturas se asignan de forma reproducible a partir del seed, coordenada e identidad de oferta. Una torre en altura h gana +h de daño base y +0.5 × h de alcance, con un máximo de +3 de daño y +1,5 hex; la lógica de alcance aplica este bonus. En torres cuyo `TowerData.mana_cost_scales_with_damage` esté activo, el aumento de daño también escala el coste efectivo de Mana por ataque. La geometría usa una única retícula entera axial de vértices pointy-top: una clave entera `(u,v)` identifica cada vértice común a las celdas vecinas y se transforma a pantalla una sola vez. Tapa, fachada, selección y copia Y-sorted usan esa misma geometría; ya no se recalculan las esquinas con seno/coseno por celda. Las tapas son polígonos cerrados de seis vértices y la textura se recorta con UV normalizados, no como rectángulo deformable. Las cards usan las mismas tapas y muestran la elevación de la oferta. Las dos fachadas delanteras conservan la textura PNG de su terreno. Grass usa #407850 y Mountain #3b3c41 en la parte superior; encima, un gradiente negro pasa de opaco en el borde inferior a transparente arriba, limitado al quad de pared (M69/ADR-0121). El contorno de región de terreno usa Grass `#406e4d` y Mountain `#646567` en un trazo sólido de color único; no lleva keyline ni relleno interior y no altera las tapas. Los UV mantienen densidad estable y repiten el PNG sin estirar la textura. Cada pared cubre solo la diferencia entre la elevación de su celda y la de la celda vecina que comparte ese borde, a razón de 28 px por nivel; si el borde da al vacío, llega al suelo. Las paredes no invaden la tapa vecina y una arista entre tapas a igual altura no genera pared. En pointy-top solo se dibujan las aristas delanteras de las direcciones axiales 1 y 2; las dos aristas laterales y las dos traseras no generan geometría de pared. Cada pared es un quad derivado de la arista original y su copia desplazada verticalmente: no se añaden tapas, cierres, profundidad radial ni vértices extra de esquina. Las dos fachadas delanteras conservan así el contorno del hex y se encuentran sin rellenos de otro color. La tapa superior permanece como polígono axial cerrado de seis vértices y ninguna pared se dibuja por encima; tablero, ghost y miniaturas comparten esta regla. Las copias de tapas elevadas participan en `Entities.y_sort_enabled` en el centro proyectado de su superficie y permiten que la tapa oculte objetos situados detrás; cada fachada se ordena por su borde inferior, a la altura de la tapa vecina o del suelo. Base, torres, enemigos, portales y props comparten la capa Z para la profundidad. TowerArtCatalog carga y cachea el PNG completo de cada torre, sin composición por regiones; Tower, el ghost, la card de construcción y el retrato de Tower Info usan la misma imagen en un solo sprite. La torre mira a derecha o izquierda mediante espejo horizontal, sin rotación visual. El preview de colocación de Ballista muestra el bonus de daño de la celda bajo el cursor. El renderer modula la textura superior con un tinte multiplicativo neutro: h0 = 1,00, h1 = 0,95, h2 = 0,90 y h3 = 0,85 en RGB, igual en tablero, previews y copias elevadas Y-sorted, sin sustituir texturas ni alterar polígonos, UV o cámara. La insignia numérica de elevación de una torre solo aparece al hacer hover; el ghost conserva su indicador contextual. Un ColorRect con shader procedural dibuja nubes irregulares en movimiento sobre los sprites del mundo, bajo el HUD y sin afectar geometría ni gameplay. Ver [ADR-0102](DECISION_HISTORY.md#adr-0102), [ADR-0100], [ADR-0099], [ADR-0082](DECISION_HISTORY.md#adr-0082), [ADR-0084](DECISION_HISTORY.md#adr-0084), [ADR-0085](DECISION_HISTORY.md#adr-0085), [ADR-0090](DECISION_HISTORY.md#adr-0090), [ADR-0092](DECISION_HISTORY.md#adr-0092) y [ADR-0093](DECISION_HISTORY.md#adr-0093). Véase [ADR-0043](DECISION_HISTORY.md#adr-0043), [ADR-0048](DECISION_HISTORY.md#adr-0048), [ADR-0073](DECISION_HISTORY.md#adr-0073), además de [ADR-0079](DECISION_HISTORY.md#adr-0079) y [ADR-0083](DECISION_HISTORY.md#adr-0083).
No se proyectan sombras individuales desde terreno ni obstáculos. Un velo procedural de nubes cubre el mundo bajo el HUD según ADR-0099; las fachadas texturadas, el desplazamiento visual, el tinte de tapas y el orden Y-sort comunican la elevación. Las caras laterales/traseras y los cierres de vértice no se dibujan. ADR-0085 limita el modelo geométrico de ADR-0084.

El hover solo detecta las caras superiores. Refuerza de forma tenue el contorno de región de terreno con los mismos colores planos: Grass #406e4d, Mountain #646567 y Path amarillo; solo varía la opacidad del resaltado. Los anillos axiales vecinos se atenúan por distancia. Sin hover no se muestran bordes blancos del grid ni sockets PATH. El hover no dibuja líneas de sockets encima del camino. Al seleccionar una pieza de expansión, las flechas de flujo se ocultan hasta cancelar o confirmar. En el preview aislado, el HUD muestra coordenadas locales; sobre el tablero M3 muestra las coordenadas axiales globales (q,r), el terreno y la altura. Los cliffs no son superficies seleccionables. Desde M10 los clusters de terreno muestran un leve brillo animado para combos visuales de 3/5, sin cambiar sus stats.

Estado del preview M3: las 19 celdas del tablero inicial y las piezas confirmadas se dibujan desde HexGrid; el ghost se compone sobre esas celdas. Durante expansión, Main entrega a preview y confirmación el mismo snapshot de celdas candidatas, incluidas alturas, contenido y auto-rellenos deterministas; no se recrean al pulsar confirmar. El tablero y el preview técnico permiten distinguir sockets PATH exactos y sus brazos laterales flexibles; las miniaturas de las cards de expansión los omiten según ADR-0071, pero comparten el material y el Y-sort axial del terreno normal. El HUD informa coordenada axial global, terreno, altura, legalidad y cantidad de conexiones. Las caras superiores usan PNG recortados por variante y las fachadas elevadas usan sprites de Grass/Mountain. La base reserva la celda lógica PATH (-1,0); conserva su PNG fuente de 270×352 px y se estira a 1,8 × el radio de huella de ancho por 2,8 × el radio de alto, anclada por el borde inferior y sin cambiar su huella lógica. Ver ADR-0096.

### 7. Filosofía visual Urtuk-like
- Grid estricta por debajo.
- Arte orgánico por encima.
- Top de terreno, cliffs y props son capas separables.
- Árboles/rocas pueden sobresalir del footprint visual.
- El footprint lógico nunca cambia por decoración.
- La elevación se ve con una cara superior y sprites de pared/fachada cerrados, no geometría 3D.
- Variantes visuales rompen repetición.
- Un trazo de color recorre el perímetro de cada región conectada de igual terreno y altura; no se dibuja una línea alrededor de cada celda.

### 8. Orden de dibujo
Prioridad aproximada:
1. fachadas delanteras, limitadas al desnivel expuesto respecto a la celda vecina;
2. tapas hexagonales completas; ninguna pared puede cubrirlas;
3. contornos cromáticos sobre las tapas, en cambios de terreno/altura, límites contra vacío y perímetro exterior de cada región;
4. ruta y flujo de flechas sobre las caras PATH;
5. superficies elevadas texturadas junto con props y entidades bajo `Entities.y_sort_enabled`;
6. proyectiles/VFX;
7. overlays de selección.

El contorno agrupa por tipo de terreno y elevación. Se omiten aristas entre vecinos del mismo grupo; cada región dibuja su perímetro exterior y el límite frente a otra región sobre vértices axiales compartidos, sin inset. El trazo vigente es Grass #406e4d, Mountain #646567 y Path amarillo, sin keyline ni línea de apoyo oscura. Estos tonos pertenecen al contorno regional, no a las fachadas; estas últimas siguen el propietario de color/gradiente definido en M69/ADR-0121. Ver ADR-0091, ADR-0095 y ADR-0121.

El filtro lineal se aplica a la ilustración de suelo, torres, enemigos, base, props y cofres. Unidades, decoraciones de mundo, tapas elevadas y fachadas usan `Entities.y_sort_enabled`, con la posición Y proyectada del anclaje como autoridad; la posición Z permanece igual para que Godot pueda compararlas. Las tapas se ordenan por la superficie elevada; cada fachada tiene un nodo propio anclado a su borde inferior, que coincide con la tapa vecina o el suelo. Un sesgo de un píxel en el origen de Y-sort solo resuelve empates a favor de la fachada; no desplaza la geometría ni cambia el orden de actores que ya están claramente delante o detrás. Así una fachada cubre actores que pasan detrás y queda detrás de los que pasan por delante, pero no se prolonga sobre las tapas. La malla lógica axial entera es la única autoridad de los seis vértices de cada tapa; cada celda dibuja solo sus dos fachadas delanteras como quads verticales, sin geometría de pared en laterales/trasera ni cierres de esquina. Las fachadas usan tonos objetivo Grass #407850 y Mountain #3b3c41, con un quad negro cuyo alfa es opaco abajo y desaparece hasta transparencia arriba; el efecto se limita a las paredes, nunca a las tapas. Tablero, preview y miniaturas comparten la presentación (M69/ADR-0121). En el preview y las miniaturas se conserva el dibujo por celda back-to-front y la misma regla de desnivel. Los VFX y la interfaz conservan sus capas propias. Ver [ADR-0084](DECISION_HISTORY.md#adr-0084), [ADR-0085](DECISION_HISTORY.md#adr-0085), [ADR-0090](DECISION_HISTORY.md#adr-0090), [ADR-0107](DECISION_HISTORY.md#adr-0107) y M41/ADR-0089.

Probar oclusión con torre en altura 2 y enemigo en camino 0.

### 9. Preview
Durante expansión:
- pieza fantasma;
- verde = legal;
- rojo = ilegal;
- destacar bordes de camino que conectan/no conectan;
- tecla/botón para rotar izquierda/derecha en pasos de 60° (seis orientaciones sobre el grid);
- confirmar colocación solo si legal.

Al confirmar una pieza, `Main` calcula el centro del conjunto de hexes recién añadidos y reproduce `sparkle_twinkle_white_loop` durante dos ciclos. El VFX se convierte a coordenadas de viewport y permanece sobre el panel de expansión; no altera el snapshot de colocación, el grid axial ni la elevación. Ver [ADR-0101](DECISION_HISTORY.md#adr-0101).

### 10. Debug obligatorio
Toggle para mostrar:
- coordenadas q,r;
- elevation;
- terrain type;
- path edges;
- endpoints;
- ruta de cada spawn;
- footprint de pieza.

En el prototipo M4, `Ctrl+D` alterna el overlay de rutas cacheadas y el marcador de base. Los puntos de spawn alcanzables se muestran siempre mediante el portal pulsante en la celda exterior. Desde ADR-0041, las rutas alcanzables también muestran cheurones animados que recorren las conexiones hacia la base; las ramas y convergencias permanecen visibles. El overlay no rotula hexes: coordenadas, terreno y altura se consultan al hacer hover y el panel HUD resume nodos, endpoints y bifurcaciones. La animación es solo informativa; no modifica la ruta ni la selección de camino del enemigo.

### 11. Navegación del mapa
- `Camera2D` controla el tablero; `CanvasLayer` mantiene la interfaz fija.
- Botón central del ratón + arrastre desplaza el mapa. La velocidad compensa el zoom actual.
- `W`, `A`, `S`, `D` desplazan la cámara de forma continua; las diagonales se normalizan y el zoom mantiene una velocidad aparente estable. Al perder el foco se limpian las teclas mantenidas.
- Rueda del ratón acerca o aleja alrededor del cursor, dentro del rango provisional `0.45×`–`2.5×`.
- `H` muestra u oculta el HUD. `R` devuelve el zoom a `1×` y centra la cámara sobre el tablero colocado. `Ctrl+D` muestra u oculta el overlay diagnóstico de rutas.
- Estos controles y límites son decisiones provisionales de interfaz, registradas en [ADR-0005](DECISION_HISTORY.md#adr-0005).

### Integración M5

La muestra histórica M5 instanciaba `GameBase` en PATH `(0,0)`; la campaña actual usa `(-1,0)` según [ADR-0056](DECISION_HISTORY.md#adr-0056). El enemigo aparece en la coordenada exterior del endpoint seleccionado, avanza por los centros de `PathRoute.cells` y alcanza el objetivo; la llegada aplica `EnemyData.base_damage`. La base puede agotarse y emitir derrota. Su ubicación y valores no cambian la autoridad axial del tablero.

<a id='combat'></a>
## Combate

### Objetivo
Conservar la lectura estratégica de Rogue Tower: enemigos con defensas distintas y torres que funcionan mejor/peor según el objetivo.

### Enemy survivability
El modelo de cada enemigo contiene pools de Health, Armor y Shield; cada perfil configura sus máximos y cero desactiva una capa para esa unidad. Se consumen en orden **Shield → Armor → Health**. La barra sobre el enemigo muestra una fila por cada capa activa, con Health fragmentada, y el HUD informa valores actuales/máximos. Bleed contrarresta regeneración de Health, Burn la de Armor y Poison la de Shield. Ver [ADR-0023](DECISION_HISTORY.md#adr-0023).

La campaña usa 26 enemigos hasta la ronda 45 según la composición aprobada en [14 — Campaña de 45 rondas](CONTENT_AND_ASSETS.md#campaign). Los datos individuales seleccionados, las habilidades y el escalado están en [13 — Catálogo de contenido](CONTENT_AND_ASSETS.md#content-roster) y ADR-0037. La velocidad RT se convierte a 45 px/s por unidad. No se añade crecimiento global por ronda. La wiki aporta fichas individuales; la tabla adjunta del usuario es la fuente de cantidades y orden.

### Damage pipeline
Centralizar el cálculo:
1. torre crea `DamagePacket`;
2. aplicar modificadores de run;
3. resolver crítico, tag y multiplicador para la capa activa Shield/Armor/Health;
4. aplicar daño;
5. aplicar status;
6. emitir eventos;
7. si health <= 0 -> kill/reward.

No repartir fórmulas entre cada torre.

#### Feedback visual de impacto

Un impacto válido muestra su daño en un número flotante con entrada de escala rápida (`punch`), desplazamiento ascendente en arco que alterna izquierda/derecha, contorno oscuro y desvanecimiento. Tres alturas de salida ayudan a que golpes seguidos no coincidan exactamente. Health conserva texto rojo, Armor ámbar y Shield cian. El tamaño se ajusta con límites respecto a la media móvil de daño de ese enemigo; un crítico añade `CRIT`, crece más y conserva el color de la capa afectada. El sprite del enemigo recibe un breve flash del color de la capa. Todo es presentación y no modifica `DamageResult`, HP ni la cadencia de combate. Referencia visual: reel de CapyEmber, «How I make damage numbers that feel good, with hundreds of enemies on screen», Instagram, consultado 2026-10-10; ver [ADR-0052](DECISION_HISTORY.md#adr-0052).

### Counters
El modelo debe permitir que una torre sea:
- fuerte contra Health;
- fuerte contra Armor;
- anti-regeneración;
- especializada en status;
- generalista.

Los multiplicadores concretos son balance, no arquitectura.

### Regeneración
Regeneración por segundo o tick. Debe poder ser reducida/contrarrestada por efectos o torres si se define una build anti-regen.

### Targeting
Cada torre puede combinar hasta tres criterios únicos: progreso, Health/Armor/Shield altos o bajos, menor HP de la capa activa y velocidad rápida/lenta. El segundo criterio se usa solo si empata el primero; el tercero si ambos empatan.

No implementar 15 modos antes de necesitarlos.

### Height advantage
Framework:
```text
height_delta = tower_elevation - target_elevation
```
Debe existir una función única que traduzca `height_delta` a bonus.

Regla de demo: cada nivel de elevación suma +1 al daño base y +0.5 hex al alcance. Son valores configurables y provisionales.

### Auditoría del sistema de torres

La implementación de los siete perfiles, sus fórmulas, límites del sistema de niveles, XP, Mana, críticos, estados y discrepancias con la referencia externa está desglosada en [15 — Auditoría del sistema de torres](CONTENT_AND_ASSETS.md#tower-audit). Esa auditoría describe código y Resources; por sí sola no aprueba balance nuevo.

### Status framework
Catálogo reducido inicial:
- Slow: modifica velocidad.
- Burn: DoT.
- Bleed: DoT que permanece en las pruebas M8 y se asigna a Shredder.
- Poison: DoT/tag de daño añadido para el roster M9.5; parámetros provisionales.

El framework debe soportar:
- duración;
- refresh;
- stack;
- tick;
- source;
- limpieza al morir.

### M8 — Estados implementados

`StatusEffectData` configura ID/nombre, duración, intervalo de tick, máximo de stacks, regla, multiplicador de velocidad, daño por tick y tags del daño periódico. `TowerData.status_effects` adjunta uno o más efectos a cada impacto. El flujo actual en `DamageService` resuelve primero el daño directo y la contrarregeneración; después aplica los payloads a un objetivo que siga `MOVING`. Los DoT construyen un paquete independiente sin payloads, usan el `source_id` almacenado en el estado y regresan a `DamageService`, por lo que respetan Armor y multiplicadores de `EnemyData` como cualquier otro daño.

Reglas runtime: `REFRESH` conserva una acumulación; `ADD_STACKS` incrementa hasta `max_stacks`. En ambos casos la aplicación renueva la duración completa y conserva la fase del próximo tick. Una reaplicación del mismo ID usa los datos y el origen de la aplicación más reciente. Cada enemigo tiene sus propios contadores aunque varios compartan el mismo Resource. Los multiplicadores de velocidad se combinan por mínimo; `1.0` significa velocidad normal. Un estado desaparece al llegar su duración a cero y todos se limpian cuando el enemigo muere o llega a la base. Los ticks aplicados antes de que expire el tiempo restante se resuelven; no hay daño periódico después de la expiración.

Histórico: la muestra DEBUG M8 reunía Slow, Burn y Bleed; su oleada/dummy se retiró en M64. Status Probe sigue disponible como torre de diagnóstico con el atajo `0`, sin un objetivo/oleada especial. Frost Keep hace 6 de daño base a 180 RPM, deja caer copos sobre PATH dentro de un cuadrado y cada impacto inflige daño a un solo enemigo. Añade Slow equivalente al 50% del daño aplicado, con fuerza máxima 60 y decaimiento de 6 puntos/s. Consume 2 Mana/s durante combate. Tesla Coil hace 9 de daño base.

### M9.5 — Roster de siete torres

Los siete perfiles viven en `TowerData`, pero el roster construible de una run empieza únicamente con Ballista. Mortar/Tesla Coil están desbloqueadas de inicio y se reclutan desde cards; las otras torres pasan a las ofertas después de su unlock permanente. Solo se muestran en la barra y se pueden construir tras el reclutamiento. `8`, `9` y `0` retienen Armor Piercing Bolt, Sapping Bolt y Status Probe para diagnóstico M7/M8.

Los patrones disponibles son objetivo único, área, cadena, cono, hoja por PATH, todos-en-alcance y copos de Frost. Ballista dispara un proyectil; Mortar lanza una granada a la posición seleccionada y explota con daño de área al aterrizar; Tesla descarga sobre todos los enemigos en alcance circular. Shredder lanza una hoja por la ruta actual del objetivo, hace impacto directo, añade Bleed por el 100% del daño base restante y pierde 1 de daño base por enemigo atravesado. Frost Keep suelta copos sobre PATH dentro de un cuadrado alineado a pantalla cuyo semilado es su alcance; cada copo daña un solo enemigo al contacto, aumenta Slow según el 50% del daño aplicado, hasta fuerza 60 que decae 6/s. Su perfil es 6 daño base y 180 RPM, más 18 RPM por PATH cubierto; drena 2 Mana/s mientras dura combate. Flame/Poison afectan un cono y convierten el 100% del daño base en Burn/Poison. Bleed/Burn/Poison detienen la regeneración de su capa y dan +1 al multiplicador de ataques directos contra esa capa; los ticks aplican daño 100%/50% según su capa. Ver CONTENT_AND_ASSETS.md#initial-content y ADR-0023.

Regla especial de Ballista: cada torre conserva su propio cooldown de ataque. Si el enemigo objetivo muere por otra fuente mientras su proyectil sigue en vuelo, esa Ballista recupera el 33 % del cooldown completo del disparo (se resta del tiempo restante, hasta cero). El disparo que mata al objetivo no da reembolso; tampoco se aplica después de que el proyectil ya impactó o si el enemigo alcanza la base. Cada proyectil solo puede reembolsar una vez. Ver [ADR-0034](DECISION_HISTORY.md#adr-0034).

Poison es el tag 8 de daño; `EnemyData.poison_damage_multiplier` participa junto con los otros multiplicadores por tag. Shield se implementa en M12A y ocupa la capa superior del enemigo. Los multiplicadores por capa de los siete perfiles parten de la tabla del usuario; otros valores siguen provisionales. Ver [ADR-0014](DECISION_HISTORY.md#adr-0014), [ADR-0023](DECISION_HISTORY.md#adr-0023) y [CONTENT_AND_ASSETS.md#initial-content](CONTENT_AND_ASSETS.md#initial-content).

### Torre
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

### Habilidades enemigas de campaña

EnemyData declara habilidades tipadas con triggers de aparición, cercanía a la base, agotamiento de Armor/Shield, muerte o temporizador. Haste suma movimiento hasta 60% y decae 6 puntos por segundo; Fortification resta 5 al daño base recibido por golpe, con la misma fuerza máxima y decaimiento. La cercanía a base activa dentro de 5 hexágonos y las auras afectan un radio de 2. Las invocaciones cuentan por encima de los 1.093 enemigos directos de la campaña; transformaciones conservan la instancia y la recompensa de baja, y WaveDirector no termina hasta su derrota final. Los valores y habilidades por perfil están en CONTENT_AND_ASSETS.md#content-roster y ADR-0037.

Los PNG de enemigos miran a la derecha por defecto. PathFollowerComponent emite cambios de dirección horizontal y Enemy refleja el sprite al moverse a la izquierda; al dirigirse a la derecha restablece el sprite sin reflejar.
### Enemy path movement
Movimiento visual continuo entre centros de hexes de la ruta.
El enemigo conoce:
- path actual;
- índice;
- progress normalizado.

M5 consume la secuencia axial `PathRoute` cacheada por M4 para inicializar el camino del enemigo y conserva sus propios waypoints, índice y progreso. Si cambia el mapa solo entre rondas, no hace falta recalcular rutas con enemigos vivos. `WaveDirector` escoge candidatos spawn según la política de cada grupo; la muestra usa `FIRST_SORTED`, mientras que la configuración final por ronda sigue abierta. M4 expone candidatos y no decide esa política.

La primera integración M5 implementa `HealthComponent`, `GameBase`, `Enemy`, `PathFollowerComponent` y `WaveDirector`. El enemigo se mueve continuamente entre centros de hex, inicia en la coordenada exterior del endpoint y aplica su daño configurado al llegar; el director retira enemigos llegados o derrotados y termina la oleada al concluir los spawns y quedar cero enemigos activos. La regla actual termina la run cuando la base llega a 0 HP o cuando cualquier enemigo con `boss_tier > 0` toca la base, aunque quede HP; la oleada ordinaria superada habilita `TERRAIN_EXPANSION`.

### M10 — Campaña de 45 rondas

La campaña M10 tiene 45 WaveData consecutivas y valida el total directo 1.093 según la tabla de CONTENT_AND_ASSETS.md#campaign. WaveEnemyGroupData.count es cantidad real y no se multiplica por endpoints; WaveDirector distribuye los enemigos por round-robin. El contador activo incluye invocaciones y transformaciones. Cyclops/Werewolf no son Minibosses especiales en 17/19. Ooogie von Ooogovich invoca dos Bats cada 2 s y se transforma en Bat con 2.500 Health; la recompensa se conserva hasta la derrota final. La demo termina al limpiar ronda 45. Los perfiles, habilidades y velocidades adoptados están en ADR-0037/CONTENT_AND_ASSETS.md#content-roster; salud, daño y Gold por baja no escalan por ronda. Tras 1–44 se ofrece expansión y M11 puede abrir una card después de colocar terreno. Los fixtures M7/M8 se pueden repetir aislados. El calendario previo se conserva solo en los ADR históricos sustituidos.

M6 añadió el primer ciclo defensivo con una torre `Basic Bolt`, nombre del prototipo que hoy solo se conserva como fixture `Basic Bolt (DEBUG)`; no forma parte del roster actual. La aceptación de ese prototipo es histórica: para los nombres y comportamiento del roster vigente, consulta M9.5 y la nomenclatura canónica. En su primera etapa se podía colocar en una celda Grass o Mountain libre, seleccionar, cambiar prioridad y mejorar. La prioridad consultaba enemigos vivos en alcance cada 0.1 s: primero/último por fracción recorrida de `PathRoute`, mayor Health actual o mayor Armor configurada. El ataque ocurría durante `COMBAT`, dentro del alcance, a la cadencia configurada, y mostraba un breve flash vectorial de hitscan. La torre no bloqueaba PATH ni exigía recalcular rutas. M7 enrutó el ataque por `DamageService`.

La regla M6 de `height_range_bonus_per_level` y los valores iniciales del prototipo Basic Bolt (10 de daño, 1 ataque/s, 3 hexes de alcance, +5 daño y +0.25 hex por nivel hasta nivel 3) eran placeholders para validar el sistema. El bonus de altura de ese prototipo (+0.25 hex por nivel) quedó sustituido en M34 por la regla vigente de ADR-0073: +1 daño base y +0,5 hex de alcance por nivel de elevación. M9 añadió costes configurables de construcción/mejora; desde M7 el armor mitigaba según el paquete de daño.

### M7 — Pipeline histórico (sustituido por M12A)

Esta sección conserva el comportamiento de M7 para registrar su evolución. Su fórmula plana de Armor y los daños esperados en la prueba manual inferior ya no describen el combate vigente; usa los criterios M12A para verificar las capas y el daño actual.

`DamageService` es dueño de la fórmula de combate entre una torre y un enemigo. `Tower` arma un `DamagePacket` a partir de su `TowerData` y no calcula mitigación ni Health por su cuenta. La instancia de servicio pertenece a `Main` y se inyecta a `BuildController`/torres para que no haya un Autoload global con estado de combate.

Orden implementado para esta etapa:
1. construir paquete con daño bruto, ID de origen, tags y counters configurables;
2. dejar preparado el paso de modificadores de run (no hay proveedor de modificadores antes de M11);
3. absorber armor plano: `min(raw_damage, armor * armor_multiplier)`;
4. aplicar el daño restante, el multiplicador recibido por tags de `EnemyData` y `health_multiplier`, redondeando hacia abajo a HP entero;
5. aplicar HP a través de `HealthComponent` y contrarregeneración temporal;
6. emitir `DamageService.damage_resolved`; `Enemy` emite sus señales de Health/muerte existentes;
7. M8 añade efectos de estado después del daño; M9 conecta pagos por baja y por ronda limpia mediante eventos del director de oleada.

Tags provisionales: Físico, Fuego y Arcano. Cada enemigo puede definir un multiplicador recibido por tag; varios tags de un paquete se combinan multiplicándose. Regeneración se acumula como fracción por segundo, no supera HP máximo y solo se ejecuta mientras el enemigo vive y avanza. Un counter de fuerza `0..1` reduce proporcionalmente la regen durante una duración configurada; impactos sucesivos mantienen la fuerza más alta y el mayor tiempo restante, sin acumularse por encima de 100%.

El HUD M7 permite elegir Basic Bolt, Armor Piercing Bolt o Sapping Bolt y seleccionar la oleada de diagnóstico con un `Armored Regenerator`. La línea debug muestra HP, Armor, regen base/efectiva y daño estimado para la torre seleccionada. Los tres perfiles y el enemigo diagnóstico son muestras temporales, no contenido o balance confirmados. Ver ADR-0010 y el procedimiento manual de `IMPLEMENTATION_AND_QA.md#acceptance`.

El fixture de M5 es histórico y conserva una base de 50 HP, enemigo 20 HP, velocidad 90 px/s, daño de llegada 10, tres enemigos con intervalo 1 s y política `FIRST_SORTED`; no representa el balance vigente de 10 HP base fijado en ADR-0074. Con M6 las torres pueden derrotar esos enemigos; M7 añade el pipeline de mitigación, tipos y regeneración. M9 añade recompensas provisionales por bajas y ronda completada, además de economía de Gold/Mana; la repetición actual es de diagnóstico y no representa la secuencia de rondas M10 ni balance final.

### M9 — Economía y Mana

`TowerData` declara `build_cost`, el coste base por capa `upgrade_base_cost_by_layer`, el factor exponencial de coste y `mana_cost_per_attack`. `BuildController` rechaza una compra sin Gold y solo marca ocupada la celda cuando el cobro se acepta. Una mejora cobra `round(coste_base_de_capa × factor_coste^nivel_de_capa)`; si la capa está en el máximo de 15 o falta saldo, no se cobra. La barra de atajos y cada botón H/A/S muestran el coste correspondiente y se deshabilitan si no hay saldo; los atajos también atenúan su contenido para que la indisponibilidad sea visible.

Antes de ejecutar el paquete de daño, una torre con coste de Mana solicita el gasto al `RunEconomyService`. Sin saldo suficiente no dispara y vuelve a intentarlo después de una espera corta; no se acumula deuda ni se permite saldo negativo. El servicio regenera Mana durante las fases activas de run y limita el total a `maximum_mana`. M9 no tiene edificios de soporte ni fuentes de Mana por torre.

`WaveDirector` paga `EnemyData.kill_reward` exactamente una vez cuando el enemigo muere, incluidos kills de DoT. Un enemigo que llega a la base no cobra. `WaveData.round_reward` se paga cuando terminaron todos los spawns y no queda ningún enemigo activo; una derrota no da el bonus de limpieza, pero tampoco revierte pagos por bajas ya efectuadas. La UI pasa por `ROUND_REWARD` durante 0.8 s y después habilita `TERRAIN_EXPANSION`. Si el calendario M11 lo indica, al colocar el terreno se abre `CARD_OFFER` y la próxima ronda no pasa a `ROUND_PREP` hasta seleccionar una carta.

La configuración M9 histórica usaba 150 Gold; el saldo vigente de una run nueva es 1.000 Gold, más 100 por nivel de Starting Coffers hasta 2.000 (ADR-0076). Mana comienza con 100/100 y su tasa base es 1.5/s (equivalente a 3 Mana cada 2 s). La interfaz presenta las mejoras de regeneración con equivalencias de cantidades enteras por intervalos enteros y sin decimales; conserva internamente la tasa exacta. El Gold de run es distinto al XP de perfil que M12 conserva entre runs. Sin economía inyectada, los callers antiguos de `Tower`/`BuildController` mantienen compatibilidad para fixtures previos; `Main` siempre inyecta el servicio configurado. Ver ADR-0013/0030/0076 y `IMPLEMENTATION_AND_QA.md#acceptance`.

### M11 — Modificadores de carta

`Main` configura un `RunCardService` local desde `CardPoolData` y lo inyecta a `BuildController`, las torres nuevas y `RunEconomyService`. Las torres consultan efectos runtime de daño, alcance, área, coste, crítico, H/A/S y estados. El pool de mejora conserva 190 IDs (173 entradas compatibles); M35 añade seis cards de reclutamiento para 196 IDs runtime. Las cards de reclutamiento añaden al roster temporal una torre desbloqueada; las mejoras específicas solo se ofrecen para torres reclutadas. Ninguna modifica RPM. Frost Keep aumenta RPM por cobertura PATH. Los payloads de estado se duplican antes de ajustarlos. La economía consulta bonus de Mana, Gold y efectos por baja; las cartas también pueden modificar la base y el daño recibido por ella. La frecuencia cada tres rondas está confirmada; cifras y rarezas son provisionales. Ver ADR-0021/0023/0062/0076.

### M12A — Stats de torre y capas de HP

`TowerData` contiene valores base/Health/Armor/Shield/RPM/rango/Mana/precio. El precio escala por cantidad del mismo perfil; demoler devuelve el precio marginal del slot ocupado, calculado por precio base, incremento y conteo; niveles y mejoras no lo alteran (ADR-0064). Daño por golpe usa el multiplicador de la capa activa y se limita a su HP; no hay overflow de una capa a otra en el mismo hit. Los críticos usan chance en bandas 0–150% y multiplicadores ×2/×3/×4. Upgrades comprados o XP acumulada añaden +1 de daño base y +1 al multiplicador de una sola capa; cada capa progresa de forma independiente de 0 a 15 mejoras (45 totales por torre). Costes Gold y XP escalan por capa con factores exponenciales configurables; parten de los valores base del Resource. XP solo se acumula mientras la torre sostiene un objetivo en alcance y va a la capa activa de ese enemigo. Tres selectores numerados muestran los criterios 1–3; al elegir un criterio ya usado en otra posición, se intercambia con el criterio desplazado. Los botones de mejora muestran nivel, XP actual/umbral en una barra teñida por la capa, coste y efecto. Enemy dibuja filas Shield azul, Armor beige y Health verde cuando el máximo de esa capa es positivo; la barra Health está fragmentada. Bleed/Burn/Poison bloquean regeneración Health/Armor/Shield y añaden +1 al multiplicador de ataque de la capa correspondiente; los ticks hacen daño completo a su capa y mitad a las otras. Cartas globales pueden sumar +1 adicional a un multiplicador de capa. La barra y los stats pueden comprobarse en DEBUG `capas Shield/Armor/Health`; los perfiles de campaña con Shield también muestran esa barra durante las 45 rondas. Ver [ADR-0023](DECISION_HISTORY.md#adr-0023) y [ADR-0046](DECISION_HISTORY.md#adr-0046).

### Feedback visual de combate y estados (M51)

Las siete torres emiten sus spritesheets locales `shoot` al disparar y `impact` cuando se resuelve daño: `ballista`, `mortar`, `teslaCoil`, `ice`, `fire`, `poisonSprayer` y `shredder`. El impacto de Mortar conserva su explosión de área y marca la celda objetivo con `tap_ripple` desde el momento del lanzamiento. `base_hit` se reproduce sobre la base cuando `WaveDirector` emite daño. La derrota final de cada enemigo activa `coins_top`; las transformaciones activadas al morir no generan un falso evento de baja.

Los iconos encima de cada enemigo son hojas animadas asociadas al estado activo: Bleed usa `bleed`, Burn `burn`, Poison `poison`, Slow `frost`, Haste/Fortification `buff` y Stun `stun`. Su tamaño visible es 44×44 px (el doble de los 22×22 px anteriores) y se mantiene el número de acumulaciones junto al icono. `AnimatedImpact` admite tiras y cuadrículas; el overlay de eventos continúa procesándose en `PROCESS_MODE_ALWAYS` por encima de la UI para no congelar una animación ya iniciada al abrir cards o terreno. Ver [ADR-0101](DECISION_HISTORY.md#adr-0101) y [ADR-0107](DECISION_HISTORY.md#adr-0107).

M52/ADR-0102 limita únicamente las hojas `shoot` de fuego continuo: Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder muestran el primer disparo inmediatamente y luego respetan su intervalo aleatorio propio de 2,0–2,5 s. Ballista y Mortar conservan un efecto por disparo discreto. Las hojas de impacto continúan en cada daño resuelto y la cadencia de ataque, proyectiles y daño no cambia.

M56/ADR-0107 multiplica por cinco la XP de seguimiento de objetivo de todas las torres; al subir de nivel automáticamente se emite la misma señal de feedback de nivel que al comprar una mejora manual. Este factor afecta solo al progreso de torres durante la run, no a la moneda persistente de la tienda.

M57/ADR-0108 añade una explosión de píxeles a la baja final. `WaveDirector` emite el enemigo a `Main`, que captura la textura visible y su escala, frame, modulación y espejo antes de liberar el actor; `EnemyDeathParticlePool.emit_death_particles_at(coords, sprite)` configura un `GPUParticles2D` one-shot con una partícula por píxel de la textura fuente. Se conserva `coins_top` y su recompensa. El efecto vive en `FeedbackVfxLayer` con coordenadas del mundo, por lo que sigue el paneo/zoom y no se desplaza respecto del punto donde murió el enemigo. Ver [ADR-0108](DECISION_HISTORY.md#adr-0108).

M59/[ADR-0110](DECISION_HISTORY.md#adr-0110) añade una sacudida de cámara sutil mientras la ronda está activa. `Main` la inicia en `wave_started` y la detiene al completar o fallar la ronda; su offset se compone con el impulso independiente que ya acompaña al daño de base.

<a id='progression'></a>
## Progresión roguelike

### Dos capas

#### Dentro de la run
- construcción;
- upgrades de torre;
- mapa;
- Gold de construcción (saldo temporal de `RunEconomyService`);
- Mana (saldo temporal, capacidad y regeneración configurables);
- cartas;
- status/build synergies.

#### Entre runs
- XP de perfil (`MetaProgression.meta_currency`, persistente y separada del Gold de construcción; se conserva ese nombre interno para no invalidar guardados versión 1);
- tienda;
- desbloqueo de torres;
- mejoras permanentes.

Los desbloqueos permanentes de una instalación nueva son Ballista, Mortar y Tesla Coil, pero el roster temporal de construcción empieza únicamente con Ballista. Tras la expansión de la ronda 3, la primera selección programada incluye reclutamientos de Mortar y Tesla Coil. Una torre desbloqueada permanentemente puede aparecer en las siguientes ofertas como reclutamiento; al elegir su card se añade al roster de esa run y se habilitan sus cartas de mejora. No se puede construir una torre que no se haya reclutado en la run. Frost Keep, Flame Thrower y Poison Sprayer cuestan 50 XP de perfil cada una; Shredder cuesta 100. El hack de reinicio de prueba restablece los unlocks a las tres torres iniciales, pone a cero las mejoras permanentes y devuelve el XP gastado en ellas. El saldo XP no gastado se conserva. La fórmula propia de XP ganada por run sigue configurable; no se importa la fórmula de Rogue Tower. Ver ADR-0069/0076.

Cada run comienza con 1.000 Gold de construcción. Starting Coffers suma +100 Gold por nivel permanente hasta +1.000, para un máximo de 2.000 al nivel X. El Gold no se persiste y se mantiene separado del XP de perfil. Al perder, el juego pasa al menú principal con la tienda abierta; al pausar con Escape, la escena permite reanudar o volver al menú. Volver desde pausa abandona la run sin cobrar la recompensa de derrota. El resumen final agrupa torres construidas y daño por tipo, mostrando solo las torres con unlock permanente. Ver [ADR-0076](DECISION_HISTORY.md#adr-0076).

Main Tower empieza con 10/10 HP. Fortification I–X añade +1 HP máximo por nivel hasta 20/20, con costes secuenciales 20/40/60/80/100/120/140/160/180/200 XP (1.100 XP total); cada nivel superior requiere el anterior. Fortification I–III de run son independientes y añaden +3 HP cada una. Un enemigo con `boss_tier > 0` que alcanza la base termina la run al instante, aunque conserve HP. Ver [ADR-0074](DECISION_HISTORY.md#adr-0074).

### Recompensa por derrota
El jugador debe recibir moneda aunque no llegue a ronda 45.

Crear fórmula configurable basada principalmente en progreso de ronda. Evitar que farmear ronda 1 sea óptimo.

### Permanent shop
Tipos iniciales:
- unlock tower;
- pequeño bonus global;
- mejora de economía inicial;
- mejora de Mana;
- ampliar/alterar pool de cartas.
- aumentar permanentemente la probabilidad de encontrar cofres.

No introducir support buildings.

M9 implementa solo economía runtime: Gold inicial, gasto en construcción/mejoras, recompensas por baja y ronda superada, y Mana con coste por ataque y regeneración. Por decisión UX posterior, el Mana se repone al máximo efectivo al comenzar cada ronda de campaña y el HUD lo presenta sin decimales. El Gold no se guarda ni se convierte en XP de perfil en M9. M12 conserva la responsabilidad de recompensas de fin de run, tienda permanente, desbloqueos y guardado. No hay edificios que generen Gold o Mana.

M10 implementa la campaña de 45 rondas. La secuencia de terreno se produce después de limpiar las rondas 1–44 y la ronda 45 termina la demo. WaveData contiene la cantidad directa exacta de cada grupo; cada enemigo se distribuye secuencialmente entre rutas alcanzables sin multiplicar cantidades por endpoints. Hay 1.093 enemigos directos en total según la tabla de usuario, más los enemigos que aparezcan por habilidades. Cyclops/Werewolf no son Minibosses especiales en las rondas 17/19. Ooogie von Ooogovich usa sus invocaciones y fase Bat adaptadas con balance propio, y la ronda espera su derrota final. Las reglas vigentes, apariciones y premios están en CONTENT_AND_ASSETS.md#campaign, CONTENT_AND_ASSETS.md#content-roster y ADR-0037.

M11 ofrece cartas temporales después de colocar terreno y antes de preparar la ronda siguiente. Para las 173 entradas compatibles de referencia se añaden 172 Resources; Advanced Circuits ya existía entre las 18 cards propias y se reutiliza, por lo que hay 190 IDs de mejora. M35 añade seis cards de reclutamiento y eleva el pool runtime a 196 IDs. El catálogo cubre las siete torres y mejoras generales/de estado. `RunCardService` filtra por unlock permanente, roster, prerequisitos, peso y límite por run; la oferta no repite carta. Las operaciones modifican daño, alcance, área, Mana, críticos, multiplicadores H/A/S, estados, economía o base sin mutar recursos compartidos. No hay mejoras de RPM por carta; Frost Keep escala por cobertura PATH. La oferta aparece cada tres rondas completadas, después de 3–42, y contiene siempre tres cards. Si existe un reclutamiento disponible, uno se garantiza; los otros dos espacios se sortean entre todas las cartas elegibles y la oferta nunca tiene tres reclutamientos. Así pueden combinarse reclutamientos, cartas globales y pasivas de torres ya reclutadas; una torre no elegida continúa disponible para futuras ofertas. `CardPoolData`, `RunCardService` y el panel comparten ese límite. La cadencia está confirmada; los números/rareza son provisionales. Ver ADR-0062/0076/0093/0118.

M12 implementa `MetaProgression` como propietario del estado permanente y conserva intactos el Gold/Mana de cada `RunEconomyService`. En cada run, `begin_run()` crea un seed que se comparte con la selección aleatoria de cartas y piezas; `finish_run()` entrega moneda una sola vez tanto por derrota como por victoria y persiste un resumen. La fórmula provisional es `5 + 5 × rondas completadas`, más 30 por victoria, limitada a 1000; perder durante ronda 1 todavía concede 5 y progresar aumenta la recompensa. La regla de interfaz de M12 presentaba tienda terminal con pestañas y todos los unlocks en la barra; esa presentación fue sustituida en M35: escenas separadas de menú/run/pausa, roster reclutado por run y tienda como mapa conectado de nodos. El archivo versionado JSON usa `user://`, validación, temporal y backup. Si el guardado es corrupto o incompatible se preserva y las compras se desactivan. La economía inicial y el roster actuales están fijados en [ADR-0076](DECISION_HISTORY.md#adr-0076); las decisiones de persistencia y fórmula conservan [ADR-0022](DECISION_HISTORY.md#adr-0022).

M12A aplica las reglas de torre/capas de HP descritas en [ADR-0023](DECISION_HISTORY.md#adr-0023), con demolición actualizada por [ADR-0064](DECISION_HISTORY.md#adr-0064): cada nivel da +1 daño base y +1 al multiplicador Health/Armor/Shield elegido; una torre también sube por XP al retener objetivos, y la capa activa del enemigo asigna esa experiencia. Los upgrades se cobran con Gold de run. Construir una torre del mismo tipo suma el incremento al precio; demoler devuelve el precio marginal del último slot ocupado, calculado solo con precio base, incremento y cantidad del tipo antes de retirarla. Los niveles y mejoras no alteran el reembolso. El modelo de cada enemigo contiene Health, Armor y Shield; cada perfil configura los máximos, y cero desactiva una capa en esa unidad. La barra dibuja las capas activas en el orden Shield→Armor→Health. Bleed/Burn/Poison bloquean la regeneración correspondiente y aumentan en +1 el multiplicador del ataque en su capa. Los ticks de estado hacen daño completo en su capa asociada y mitad en las otras. El test Health/Armor/Shield vive en DEBUG; el perfil provisional de Ooogie von Ooogovich también porta Shield para mostrar la barra en campaña.

«Suerte del explorador» persiste entre runs: una celda construible sin obstáculo empieza con 1 % de probabilidad de generar cofre. Cuatro niveles añaden +5 puntos porcentuales cada uno; el tope de 20 % limita el último incremento. Los costes 10/20/35/55 y el premio provisional de 25 Gold por abrir un cofre son configurables. El cofre paga Gold de la run, nunca XP de perfil.

### Filosofía
Las permanentes facilitan progreso y variedad, pero no deben convertir el juego en "ganar por estadísticas" sin estrategia.

### Cards
Las cartas sustituyen parte del espacio sistémico que en Rogue Tower ocupan upgrades/support.

Categorías:
- tower-specific;
- tower-family;
- status;
- economy;
- mana;
- global utility.

Las cartas pueden aumentar:
- capacidad de Mana;
- regeneración de Mana;
- eficiencia;
- estadísticas de torre;
- status;
- economía.

Las cartas de oferta usan una superficie plana común sin sprites de borde/fondo. El tier aparece escrito, una separación pequeña distingue cada opción y el aura radial con partículas comunica la rareza con su color, sin cambiar el panel ni el resto de la card. La oferta siempre tiene tres columnas y tres opciones; no hay ampliación por Card Draw. Ver [ADR-0088](DECISION_HISTORY.md#adr-0088) y ADR-0093; ADR-0080 conserva el historial del sprite vertical ya retirado.

### Desbloqueos
Una torre bloqueada permanentemente no aparece en las opciones de reclutamiento ni en sus cartas específicas. Un unlock permanente tampoco la hace construible inmediatamente durante la run: primero debe reclutarse con una card de run. La barra de construcción muestra únicamente el roster temporal reclutado.

### Tienda permanente
La tienda usa un mapa desplazable de nodos conectados y una escena de tarjeta compartida por todas las mejoras. Cada nodo muestra icono grande del sistema o torre afectada, título, descripción, coste y estado. Las conexiones reflejan `prerequisites`; un nodo bloqueado explica sus requisitos en tooltip. Las mejoras Health, Armor y Shield de cada torre son tres ramas hermanas habilitadas por el unlock permanente de esa torre, y se pueden comprar en cualquier orden. Comprar un nodo emite partículas y actualiza las dependencias afectadas. La escena se reutiliza en el menú principal y tras Game Over. Ver [ADR-0077](DECISION_HISTORY.md#adr-0077) y [ADR-0081](DECISION_HISTORY.md#adr-0081).

La vista de tienda no muestra instrucciones en el pie ni un botón para iniciar una run; el menú principal conserva esa acción. Un botón × fijo en la esquina superior derecha cierra el mapa. El árbol tiene espacio horizontal entre sus clusters, usa iconos propios en todos los nodos y permite desplazarse con rueda o arrastrar la vista con el botón izquierdo o central del ratón. Las tres ramas Health/Armor/Shield de cada torre aparecen en una misma fila, conectadas desde su nodo de desbloqueo. Los detalles completos y requisitos se conservan en el tooltip; los títulos del mapa se priorizan y las descripciones se resumen. Ver [ADR-0094](DECISION_HISTORY.md#adr-0094).

### Run seed
Guardar seed en resumen de run para reproducir:
- ofertas de cartas;
- selección de piezas;
- variaciones de wave que se autoricen.

### Victoria/derrota
- Base health <= 0 -> derrota; cualquier boss (`boss_tier > 0`) que toca la base también termina la run inmediatamente.
- Completar ronda 45 -> victoria demo.
- Ambos casos calculan recompensa meta y muestran resumen.
