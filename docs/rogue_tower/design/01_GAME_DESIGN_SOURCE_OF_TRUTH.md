# Game Design — Source of Truth

Esta página es la autoridad de diseño activo junto con sus páginas temáticas enlazadas desde [el índice](README.md). Las decisiones explícitas del usuario prevalecen sobre el paquete inicial; la implementación actual y los estados se registran por separado.

**Estado de la build (2026-10-13):** el alcance de campaña, roster, combate, economía, progresión y HUD descrito en esta página está integrado en código según [Progreso](09_PROGRESS.md). La sincronización de contenido de terreno, la pausa por `P`/botón, el bloqueo de acciones durante la selección y la oferta variable de rutas también están implementados; su aceptación interactiva y visual sigue pendiente en [Aceptación](10_ACCEPTANCE_TESTS.md). Este estado indica integración, no validación en una sesión de juego.

## 1. Pitch
Tower Defense Roguelike de runs cortas/medias donde el jugador no solo construye torres: **construye el propio tablero que tendrá que defender**.

La referencia sistémica principal es Rogue Tower, reducida a un scope de demo pequeño. Los nombres canónicos y las equivalencias aprobadas están en [Nomenclatura](12_NOMENCLATURE.md); compartir un nombre no importa las cifras ni la mecánica. La referencia visual/técnica del tablero es Urtuk: The Desolation: grid hexagonal lógica, arte 2D que simula volumen y elevaciones discretas.

## 2. Scope confirmado
- Motor: **Godot 4.7**.
- Género: Tower Defense + Roguelike.
- Demo: **45 rondas**, con la composición directa exacta de [la campaña](14_CAMPANA_45_RONDAS.md).
- Grid: hexagonal.
- Expansión del mapa: tras limpiar las rondas 1–44 se ofrecen tres piezas distintas de siete hexágonos como cards visuales. La ronda 45 completa la demo.
- El jugador coloca una pieza predefinida compuesta por **7 hexágonos**.
- La pieza puede rotarse en las 6 orientaciones hexagonales.
- Si contiene camino, sus conexiones deben ser válidas con el mapa existente.
- El mapa puede generar prolongaciones, bifurcaciones y convergencias.
- Tres niveles lógicos de altura: 0, 1, 2.
- Terrenos principales:
  - Path: altura 0, transitable por enemigos, no construible.
  - Grass: construible; normalmente altura 1, pudiendo existir variantes elevadas según definición de pieza.
  - Mountain: altura 2, construible y con ventaja de altura.
- La base ocupa la huella visual completa de un hexágono y reserva su celda axial. Las seis celdas vecinas inmediatas, incluido el tramo PATH junto a la base, permanecen a elevación 0 para que el terreno no tape el edificio.
- Tras una expansión, los huecos completamente encerrados dentro de la envolvente axial del mapa se rellenan al azar con Grass o Mountain. Una abertura PATH que funcione como salida/spawn nunca se rellena. El tablero inicial y cada expansión confirmada deben conservar al menos un spawn PATH exterior con ruta válida hasta Main Tower; la opción de colocar terreno se rechaza si el grafo candidato no cumple esa condición.
- Cada oferta de terreno incluye una pieza con una colocación comprobada que prolonga una ruta PATH existente. Se identifica como `EXTIENDE RUTA` y muestra una posición sugerida; la forma varía entre recta, curva y bifurcación. Si la pieza sugerida no es recta, la oferta no añade una recta como alternativa. Las miniaturas muestran terreno y obstáculos, sin ramificaciones ni flechas de conexión PATH. Durante la colocación, `Q`/`E` y la rueda del ratón giran la pieza; la rueda conserva el zoom cuando no se está colocando terreno. `T` busca y confirma automáticamente una posición legal aleatoria, manteniendo las validaciones de grafo y continuidad. Las otras piezas mantienen la variedad del terreno y la confirmación solo se permite si el tablero conserva una continuación legal. Antes de confirmar, los spawns que cerrarían permanecen visibles con una marca roja y el texto cuenta los cierres. Sin selección activa, el hover de una celda muestra un tooltip breve con tipo, estado de construcción, altura y sus bonos de torre. Ver [ADR-0072](../decisions/ADR-0072-controles-y-tooltip-de-celdas.md).
- Los conjuntos conectados de Grass o Mountain brillan suavemente desde tres hexágonos; el resplandor es algo más intenso desde cinco. En esta fase es únicamente señal visual de combo, sin bonus de gameplay.
- Path, Grass y Mountain usan tres variantes PNG por terreno. Grass tiene un 25 % de probabilidad de generar un obstáculo y Mountain un 15 %; el pool contiene roca, cristal, hierba alta, tótem y montón de piedra. Un obstáculo bloquea construcción igual que Path y no altera la navegación.
- Una celda Grass/Mountain sin obstáculo tiene una probabilidad base del 1 % de generar un cofre. La mejora permanente «Suerte del explorador» añade cinco puntos porcentuales por nivel en cuatro niveles y queda limitada a 20 %. La tirada de una expansión ocurre al confirmar la colocación, no al elegir una pieza; las miniaturas y el ghost no muestran cofres. Si aparece, su sprite salta una vez y luego queda en la celda. Abrirlo entrega Gold; el valor inicial de 25 Gold es provisional y configurable. Los cofres no cambian la ruta ni se pueden construir hasta abrirlos. Al hacer hover, el cofre bota y recibe un resplandor dorado para invitar a recogerlo.
- El catálogo actual contiene cinco piezas de terreno originales y diez plantillas adicionales con mezclas de campo/montaña, macizos, lomos, giros, ramales y bifurcaciones. Cada pieza conserva siete hexágonos conectados; las conexiones PATH internas son recíprocas y la lógica axial valida la colocación.
- Los bordes hexagonales del hover atenúan progresivamente sus dos anillos axiales. No se dibujan sockets PATH sobre la celda resaltada; las flechas de flujo PATH avanzan hacia la base durante el juego normal y se ocultan al elegir y colocar una expansión para despejar el tablero. Cada salida alcanzable se representa con un sprite PNG independiente de portal pulsante, de silueta sencilla y sin etiqueta `SPAWN`.
- Las caras superiores se dibujan según su altura visual. Una copia texturada de la tapa elevada participa en el Y-sort; las paredes quedan debajo de los actores y las fachadas traseras no se dibujan. Así una montaña delantera puede ocultar entidades situadas detrás sin cambiar su celda, navegación, alcance ni posición lógica. La proyección de sombras generadas por el juego está desactivada temporalmente para todos los elementos. En una colocación válida los portales indican las salidas previstas del grafo candidato; al pasar el cursor por uno se perfila su sprite y se muestra el conteo de enemigos de la siguiente ronda que usará esa salida. Retratos sobre el portal anticipan sus tipos y cantidades repetidas, calculados con el reparto real de `WaveDirector`. La torre en modo colocación aparece como fantasma translúcido verde o rojo según la validez. Los obstáculos se fijan en la oferta; los cofres se sortean al confirmar terreno y no aparecen en su miniatura ni ghost. El icono de la torre construida vibra brevemente y los siete botones usan tarjetas mayores y más juntas. La implementación de cofres queda en [ADR-0066](../decisions/ADR-0066-cofres-al-colocar-y-sombras-de-elevacion.md); el estado sin sombras, en [ADR-0070](../decisions/ADR-0070-sin-sombras-y-rutas-limpias-en-expansion.md).
- Las paredes visibles de desnivel usan texturas separadas para roca y suelo con césped, mapeadas a una fachada cerrada por arista. Son sprites intercambiables; la altura sigue siendo lógica 2D y sus fachadas permanecen debajo de unidades y props en el orden de profundidad.
- Enemigos: el modelo de cada enemigo incluye las capas `Health`, `Armor` y `Shield`, con regeneración separada; cada perfil configura sus máximos y cero desactiva una capa para esa unidad. El daño directo afecta solo a la capa activa en orden `Shield → Armor → Health`. Cada torre usa su multiplicador de la capa activa. `Bleed` detiene la regeneración de `Health` y suma +1 al multiplicador de `Health` de los ataques; `Burn` hace lo mismo con `Armor`; `Poison`, con `Shield`. Los ticks usan el multiplicador completo en la capa asociada y la mitad en las otras. Enemy dibuja las barras de las capas presentes y segmenta la de `Health`. Esta regla sigue la mecánica de capas y estados descrita en Rogue Tower; el descarte del exceso al vaciar una capa y las cifras de contenido de la demo se mantienen configurables/provisionales. Ver [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md).
- La campaña usa los 26 tipos de enemigo y los 1.093 enemigos directos de la tabla aprobada en [14 — Campaña de 45 rondas](14_CAMPANA_45_RONDAS.md). En las rondas 17 y 19 no hay designaciones especiales de Miniboss. Los perfiles normales adoptan las estadísticas individuales y habilidades enlazadas en Rogue Tower Wiki; la velocidad se convierte a 45 px/s por unidad RT y no escala por ronda. Ooogie von Ooogovich conserva balance propio y una fase Bat. Las invocaciones suman enemigos por encima del conteo directo; la oleada espera a que todos mueran o lleguen a base. Ver [ADR-0037](../decisions/ADR-0037-campana-de-45-rondas-y-habilidades.md).
- Las siete torres jugables se llaman Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder.
- Frost Keep sigue el perfil de Rogue Tower: daño base 6, 180 RPM más 18 por PATH cubierto, copos de impacto individual, Slow equivalente al 50% del daño aplicado (cap 60, decaimiento 6/s) y drenaje continuo de 2 Mana/s durante combate. Tesla Coil empieza con 9 de daño base. Ver 13_CONTENT_ROSTER.md y ADR-0059.
- Regla propia de Ballista: si el enemigo objetivo muere por otra fuente antes de que llegue el proyectil, la Ballista dueña del disparo recupera 33 % de la recarga completa, descontado del tiempo restante hasta cero. El tiro que mata por su propio impacto no reembolsa; el ciclo es independiente por torre y por disparo. Ver [ADR-0034](../decisions/ADR-0034-reembolso-de-cooldown-ballista.md).
- Estados de torre `Bleed`, `Burn`, `Poison` y `Slow`; habilidades enemigas también aplican `Haste` y `Fortification`.
- Upgrade Cards durante la run, reducidas/simplificadas.
- Permanent Upgrades entre runs, reducidas/simplificadas.
- Las upgrade cards reutilizan un panel común; su fondo identifica la rareza y cada efecto mostrado tiene un icono. El sprite de efecto/torre es grande y cada rareza usa un PNG propio. Ver [ADR-0065](../decisions/ADR-0065-panel-y-iconos-de-upgrade-cards.md).
- Demoler una torre devuelve el precio marginal del slot que ocupaba, calculado con precio base, incremento y cantidad de ese tipo antes de retirarla. El nivel y las mejoras de la torre no cambian la devolución. Ver [ADR-0064](../decisions/ADR-0064-reembolso-al-demoler-torres.md).
- El jugador recibe XP de perfil al acabar una run, incluso si pierde pronto. El saldo persistente compra desbloqueos de torres y mejoras permanentes.
- Arsenal inicial: Ballista, Mortar y Tesla Coil. Frost Keep, Flame Thrower y Poison Sprayer cuestan 50 XP de perfil cada una; Shredder cuesta 100. Los unlocks comprados persisten al empezar una run normal; el reinicio completo de prueba vuelve al arsenal inicial. Ver [ADR-0069](../decisions/ADR-0069-desbloqueos-xp-y-feedback-de-altura.md).
- `Mana` existe como recurso/sistema; la moneda de run se llama `Gold`.
- **No existen support buildings.**
- Mana y sus mejoras se obtienen mediante cards/permanentes/sistemas de progresión, no edificios de soporte.
- La base usa un sprite RGBA intercambiable desde `BaseData`; la huella hexagonal lógica sigue separada del arte.
- La vida de la base se representa en segmentos de 10 puntos (con un último segmento parcial si el máximo no es múltiplo de 10). Aparece arriba a la izquierda, sin panel de fondo, con el atajo de terreno/interfaz debajo. Gold y Mana aparecen arriba a la derecha con su disposición horizontal actual, también sin panel de fondo. Cada cambio de Gold anima con escalado, rebote y vibración tanto el icono como la cifra, al ganar o gastar; abrir un cofre también activa el feedback aunque no se acepte Gold por estar al límite.
- Al recibir daño, el sprite de la base se tiñe brevemente de rojo y la cámara hace una sacudida corta. Durante ofertas de mejora y elección de terreno, un velo negro translúcido oscurece el tablero detrás de las cards; desaparece al seleccionar terreno para colocarlo y vuelve si se cancela y se muestra otra vez la oferta. Ver [ADR-0055](../decisions/ADR-0055-feedback-base-seleccion-y-recompensas.md).
- La partida puede pausarse y reanudarse con `P` o con el botón bajo la barra de vida. El botón de iniciar ronda siempre quita la pausa cuando la fase es `ROUND_PREP`. Mientras se elige o coloca terreno, no se pueden seleccionar torres, iniciar rondas, abrir cofres ni usar controles de construcción; permanecen disponibles la elección/rotación/confirmación/cancelación de la pieza y la pausa.
- El Mana se repone hasta su máximo efectivo al iniciar cada ronda de campaña y el HUD muestra valores enteros, sin decimales.
- El control de ronda muestra una línea con 45 puntos; su tamaño aumenta con la cantidad configurada y destaca los encuentros especiales. Al pasar el cursor muestra el total de unidades de esa ronda y retratos/conteos solo para tipos que aparecen más de una vez. El botón de iniciar ronda usa un sprite 9-slice y se ajusta al texto.
- Las tres cards para expandir el tablero usan superficies planas oscuras y un borde fino que indica hover o selección, sin marcos decorativos ni panel compartido. El preview ocupa la mayor parte de cada card; debajo aparece el conteo de `Path`, `Grass` y `Mountain`, omitiendo cualquier tipo con cero celdas.
- Los siete botones de torre tienen fondo propio con estilo de carta. La barra que los alinea no dibuja un panel compartido alrededor.
- El panel lateral de torre usa una superficie plana y compacta, se ajusta a su contenido, no tiene scroll y reduce su escala si la ventana no permite el alto natural. El retrato pequeño comparte cabecera con el nombre y el nivel. En build mode muestra las estadísticas y el bonus medido de Mountain frente a Grass; no repite instrucciones del preview. Health, Armor y Shield conservan icono, nivel, barra de XP y precio en tres botones compactos; el detalle de XP y el efecto completo se consultan en el tooltip. Demoler es un botón de texto sencillo y devuelve el precio marginal del slot ocupado según tipo/conteo, sin reembolsar niveles (ADR-0064). Ver [ADR-0039](../decisions/ADR-0039-panel-torre-y-escalado-individual.md), [ADR-0040](../decisions/ADR-0040-terreno-obstaculos-cofres-y-feedback.md) y [ADR-0053](../decisions/ADR-0053-paneles-y-sprites-sencillos.md).
- Los sprites de torres, enemigos, props y base son configurables por objeto y se dibujan con filtrado lineal. Cofre y portal usan pixel art de paleta limitada, formas planas y filtrado nearest, sin adornos de entorno. Los perfiles actuales usan torres de 84 px, enemigos estándar de 72 px con jefes configurados por separado, obstáculos estirados dentro de una caja común de 86×86 px, centrados con un pequeño desplazamiento hacia abajo, y base de 176×176 px. Los props y las unidades comparten ordenación Y por profundidad. El arte de terreno se recorta por variante para ocupar exactamente la cara del hexágono. Nada de esto cambia la ocupación hexagonal, alcance, selección lógica, colisiones ni movimiento. El tamaño de obstáculos fue refinado por [ADR-0046](../decisions/ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md), que sustituye la medida anterior de [ADR-0044](../decisions/ADR-0044-caja-estandar-de-obstaculos.md).
- Patrick Hand es la fuente predeterminada del proyecto y se usa en la interfaz, incluidos los textos dibujados manualmente. Se distribuye con su licencia SIL Open Font License 1.1. Ver [ADR-0054](../decisions/ADR-0054-tipografia-global-y-sin-sombras-de-codigo.md).
- Las rutas muestran flechas animadas en sus bifurcaciones, avanzando hacia la base; el flujo se calcula desde `PathGraph` y no altera el recorrido del enemigo. Los impactos usan VFX animados de Tiny Swords para Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder. El puntero distingue estado normal, hover interactivo, acción inválida y colocación de torre. El pack se instala localmente; su licencia no permite incluir los PNG fuente en Git. Ver [ADR-0040](../decisions/ADR-0040-terreno-obstaculos-cofres-y-feedback.md), [ADR-0041](../decisions/ADR-0041-occlusion-arte-terreno-y-flujo-de-rutas.md) y [Origen](../references/ORIGEN.md).

## 3. Core loop
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

## Cartas de mejora durante la run
Las cards `CardData` son distintas de las cards visuales que ofrecen piezas de terreno. Tras colocar la expansión de las rondas 3, 6, 9, …, 42, el jugador elige una mejora antes de iniciar la siguiente ronda. El calendario cada tres rondas es una regla confirmada; la partida termina al completar la 45 y no ofrece una carta sin una ronda posterior. La oferta base contiene tres opciones; los upgrades permanentes Card Draw pueden ampliarla hasta seis. Las cards modifican estadísticas de torres, estados, base, economía o `Mana`, y sus efectos duran solo en la run actual. Se representan las 173 Upgrade Cards compatibles de referencia para las siete torres y efectos generales: 172 Resources nuevos y una Advanced Circuits ya existente con operación y prerequisitos equivalentes. Junto a las 18 cards propias previas, el pool contiene 190 IDs únicos. Las cifras y rarezas importadas son configuración provisional. Ver [ADR-0062](../decisions/ADR-0062-catalogo-de-upgrade-cards-y-permanent-upgrades.md) y [Nomenclatura](12_NOMENCLATURE.md).

## Reglas confirmadas y decisiones provisionales de combate
- `EnemyData` y cada instancia runtime de Enemy modelan `Health`, `Armor` y `Shield`, con regeneración independiente. Los tres pools tienen valores por perfil; un máximo cero indica que ese enemigo no usa esa capa. La capa activa es `Shield → Armor → Health`.
- La torre aplica daño base por el multiplicador de la capa activa. Sigue sin decidirse si el excedente al vaciar una capa pasa a la siguiente; el código lo descarta provisionalmente y no se considera regla confirmada.
- `Bleed`/`Burn`/`Poison` detienen la regeneración de `Health`/`Armor`/`Shield` correspondiente. Sus ticks causan daño completo en la capa asociada y la mitad en las otras; además, los ataques directos contra un enemigo afectado ganan +1 al multiplicador de esa capa, una sola vez mientras el estado esté activo, sin escalar por acumulaciones. El modelo y la barra de las tres capas se implementaron en M12A. Los perfiles normales de Rogue Tower adoptan sus parámetros base sin crecimiento por ronda; el balance de los jefes y Ooogie propio, además de la política de daño excedente descrita en ADR-0023, sigue configurable/provisional.
- Cada nivel de torre añade +1 de daño base y +1 a un multiplicador de capa elegido; el XP de mantener un objetivo en rango añade el mismo incremento según el HP actual de ese enemigo. Elevación añade +1 daño y +0.5 de rango por nivel. Estos valores y la tabla H/A/S/RPM/Mana/precio que pegó el usuario son el perfil inicial de la demo y siguen configurables.
- Se pueden escoger hasta tres prioridades de target en orden; por defecto solo se presenta la primera y un botón `+` revela cada selector secundario, que desempata al anterior. El cambio de orden intercambia los criterios afectados. Las mejoras Health/Armor/Shield progresan de forma independiente: cada capa admite 15 subidas, hasta 45 mejoras totales por torre. El XP automático y el coste Gold de cada capa tienen curvas exponenciales configurables; cada mejora añade +1 de daño base y +1 al multiplicador de la capa escogida. Los tres botones muestran su nivel y una barra de XP de esa capa. Críticos avanzan por bandas ×2/×3/×4 hasta 150%; precios de construcción crecen por cantidad del mismo tipo y Frost Keep acelera por PATH cubierto. La selección pulsa en la card inferior y en el sprite con brillo recortado; el panel de información permanece quieto y el sprite no muestra círculos de selección. Ver [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md), [ADR-0046](../decisions/ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md) y [ADR-0047](../decisions/ADR-0047-herramientas-de-depuracion-y-claridad-de-seleccion.md); esta fuente conserva abierta la regla de overkill.
- Las rondas 17 y 19 siguen la tabla de composición directa y no marcan Minibosses. Ooogie von Ooogovich invoca dos Bats cada 2 s y se transforma en Bat con 2.500 Health como fase final; su balance es provisional y la recompensa se conserva hasta la derrota final. Fallen Ooogie y Ooogiehedron tienen las habilidades de invocación encadenadas registradas en el catálogo.

## 4. Fantasía estratégica
El mapa debe ser una decisión. Una pieza puede:
- aumentar la longitud de una ruta;
- abrir una bifurcación peligrosa;
- crear una convergencia/kill zone;
- dar una posición elevada excepcional;
- ampliar superficie construible;
- introducir un nuevo punto de entrada.

No debe existir una única decisión obvia en todas las expansiones.

## 5. Dificultad
Objetivo: conservar la sensación de presión de Rogue Tower. La progresión permanente debe ayudar, pero no sustituir la toma de decisiones.

Principio: un jugador nuevo probablemente no completa la run. Las derrotas alimentan meta-progresión y desbloqueos.

## 6. Sistemas deliberadamente fuera de scope
- Support buildings.
- Campaña narrativa compleja.
- Multijugador.
- PvP.
- Mundo 3D real.
- Terreno 3D/meshes como base del tablero.
- Generación procedural libre de geometría: las piezas son plantillas diseñadas.
- Más de 45 rondas en esta demo.
- Contenido final masivo antes de validar vertical slice.

## 7. Decisiones todavía abiertas
No inventar como definitivas:
- Número total de torres del juego final. Para la demo, el usuario confirmó siete perfiles jugables en ADR-0014.
- Roster final de enemigos.
- Lista final de status.
- Fórmula exacta de altura.
- Rarezas y valores finales de Upgrade Cards; la oferta base de tres puede crecer con Card Draw y la oferta de expansión continúa usando tres piezas.
- Economía/balance numérico final.
- Número exacto de piezas de terreno.
- Balance final de Ooogie von Ooogovich y Tesla Coil; sus parámetros actuales son configurables y provisionales. La caída/contacto del copo de Frost Keep también queda configurable, pendiente de aceptación manual.
- Balance definitivo para múltiples entradas sigue pendiente. La demo asigna los enemigos de cada ronda en orden round-robin global entre endpoints PATH alcanzables; reinicia el reparto al iniciar cada ronda. La vista previa por portal refleja exactamente esa política.
- Arte/temática final.

## Terreno interactivo y lectura de altura

Durante `ROUND_PREP`, el jugador puede seleccionar cualquier obstáculo y consultar su nombre en el panel, o pagar para quitarlo. La retirada n cuesta `25 × n²` Gold, donde n es su ordinal dentro de las retiradas de obstáculos de la run: 25, 100, 225, 400… Los portales muestran por clic una lista de los tipos de enemigos asignados, con sus sprites. Se permite quitar un portal si quedan más de tres; cuesta el doble del siguiente precio de obstáculo y los enemigos de la oleada se redistribuyen entre los endpoints restantes. La elevación lógica permanece en 0–2, con 28 px visuales por nivel para hacer más legible el desnivel. Ver [terreno hexagonal](05_HEX_GRID_AND_TERRAIN.md) y [ADR-0063](../decisions/ADR-0063-seleccion-y-retirada-de-objetos-del-terreno.md).

Para el prototipo usar valores temporales centralizados y fáciles de sustituir.
