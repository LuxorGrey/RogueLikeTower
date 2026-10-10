# Game Design — Source of Truth

Esta página es la autoridad de diseño activo junto con sus páginas temáticas enlazadas desde [el índice](README.md). Las decisiones explícitas del usuario prevalecen sobre el paquete inicial; la implementación actual y los estados se registran por separado.

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
- Los conjuntos conectados de Grass o Mountain brillan suavemente desde tres hexágonos; el resplandor es algo más intenso desde cinco. En esta fase es únicamente señal visual de combo, sin bonus de gameplay.
- Path, Grass y Mountain usan tres variantes PNG por terreno. Grass tiene un 25 % de probabilidad de generar un obstáculo y Mountain un 15 %; el pool provisional contiene roca, esquirla, hierba alta, tótem y piedras. Un obstáculo bloquea construcción igual que Path y no altera la navegación.
- Una celda Grass/Mountain sin obstáculo tiene una probabilidad base del 1 % de generar un cofre. La mejora permanente «Suerte del explorador» añade cinco puntos porcentuales por nivel en cuatro niveles y queda limitada a 20 %. Abrirlo entrega Gold; el valor inicial de 25 Gold es provisional y configurable. Los cofres no cambian la ruta ni se pueden construir hasta abrirlos.
- El catálogo actual contiene cinco piezas de terreno originales y diez plantillas adicionales con mezclas de campo/montaña, macizos, lomos, giros, ramales y bifurcaciones. Cada pieza conserva siete hexágonos conectados; las conexiones PATH internas son recíprocas y la lógica axial valida la colocación.
- Los bordes de los hexágonos y sockets PATH solo se dibujan al hacer hover: la celda activa aparece con mayor opacidad y se atenúan progresivamente sus dos anillos axiales. Las flechas de flujo PATH permanecen visibles y avanzan hacia la base. Cada salida alcanzable se representa con un sprite PNG independiente de portal pulsante, sin una etiqueta `SPAWN`.
- Las caras superiores se dibujan según su altura visual. Una copia texturada de la tapa elevada participa en el Y-sort; las paredes quedan debajo de los actores y las fachadas traseras no se dibujan. Así una montaña delantera puede ocultar entidades situadas detrás sin cambiar su celda, navegación, alcance ni posición lógica. En una colocación válida los portales indican las salidas previstas del grafo candidato; las cards de terreno muestran obstáculos representativos y la generación real sigue ocurriendo al colocar. El cursor de colocación es pequeño y pulsante; el icono de la torre construida vibra brevemente y los siete botones usan tarjetas mayores y más juntas. La implementación y aceptación visual están registradas en [ADR-0043](../decisions/ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md).
- Las paredes visibles de desnivel usan texturas separadas para roca y suelo con césped, mapeadas a una fachada cerrada por arista. Son sprites intercambiables; la altura sigue siendo lógica 2D y sus fachadas permanecen debajo de unidades y props en el orden de profundidad.
- Enemigos: el modelo de cada enemigo incluye las capas `Health`, `Armor` y `Shield`, con regeneración separada; cada perfil configura sus máximos y cero desactiva una capa para esa unidad. El daño directo afecta solo a la capa activa en orden `Shield → Armor → Health`. Cada torre usa su multiplicador de la capa activa. `Bleed` detiene la regeneración de `Health` y suma +1 al multiplicador de `Health` de los ataques; `Burn` hace lo mismo con `Armor`; `Poison`, con `Shield`. Los ticks usan el multiplicador completo en la capa asociada y la mitad en las otras. Enemy dibuja las barras de las capas presentes y segmenta la de `Health`. Esta regla sigue la mecánica de capas y estados descrita en Rogue Tower; el descarte del exceso al vaciar una capa y las cifras de contenido de la demo se mantienen configurables/provisionales. Ver [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md).
- La campaña usa los 26 tipos de enemigo y los 1.093 enemigos directos de la tabla aprobada en [14 — Campaña de 45 rondas](14_CAMPANA_45_RONDAS.md). En las rondas 17 y 19 no hay designaciones especiales de Miniboss. Los perfiles normales adoptan las estadísticas individuales y habilidades enlazadas en Rogue Tower Wiki; la velocidad se convierte a 45 px/s por unidad RT y no escala por ronda. Ooogie von Ooogovich conserva balance propio y una fase Bat. Las invocaciones suman enemigos por encima del conteo directo; la oleada espera a que todos mueran o lleguen a base. Ver [ADR-0037](../decisions/ADR-0037-campana-de-45-rondas-y-habilidades.md).
- Las siete torres jugables se llaman Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder.
- Balance propio confirmado para esta campaña: Frost Keep empieza con 2 de daño base, 120 RPM y Slow ×0,85 durante 1 s; Tesla Coil empieza con 9 de daño base. Los valores se detallan en 13_CONTENT_ROSTER.md y ADR-0037.
- Regla propia de Ballista: si el enemigo objetivo muere por otra fuente antes de que llegue el proyectil, la Ballista dueña del disparo recupera 33 % de la recarga completa, descontado del tiempo restante hasta cero. El tiro que mata por su propio impacto no reembolsa; el ciclo es independiente por torre y por disparo. Ver [ADR-0034](../decisions/ADR-0034-reembolso-de-cooldown-ballista.md).
- Estados de torre `Bleed`, `Burn`, `Poison` y `Slow`; habilidades enemigas también aplican `Haste` y `Fortification`.
- Upgrade Cards durante la run, reducidas/simplificadas.
- Permanent Upgrades entre runs, reducidas/simplificadas.
- El jugador recibe moneda meta al acabar una run, incluso si pierde pronto.
- Tienda permanente: mejoras y desbloqueo de nuevas torres.
- `Mana` existe como recurso/sistema; la moneda de run se llama `Gold`.
- **No existen support buildings.**
- Mana y sus mejoras se obtienen mediante cards/permanentes/sistemas de progresión, no edificios de soporte.
- La base usa un sprite RGBA intercambiable desde `BaseData`; la huella hexagonal lógica sigue separada del arte.
- La vida de la base se representa en segmentos de 10 puntos (con un último segmento parcial si el máximo no es múltiplo de 10). Aparece arriba a la izquierda, sin panel de fondo, con el atajo de terreno/interfaz debajo. Gold y Mana aparecen arriba a la derecha con su disposición horizontal actual, también sin panel de fondo. Cada cambio de Gold anima con escalado y rebote tanto el icono como la cifra, al ganar o gastar.
- El Mana se repone hasta su máximo efectivo al iniciar cada ronda de campaña y el HUD muestra valores enteros, sin decimales.
- El control de ronda muestra una línea con 45 puntos; su tamaño aumenta con la cantidad configurada y destaca los encuentros especiales. Al pasar el cursor muestra el total de unidades de esa ronda y retratos/conteos solo para tipos que aparecen más de una vez. El botón de iniciar ronda usa un sprite 9-slice y se ajusta al texto.
- Las tres cards para expandir el tablero usan marcos PNG individuales sin panel compartido. Debajo muestran el conteo de `Path`, `Grass` y `Mountain`, omitiendo cualquier tipo con cero celdas.
- Los siete botones de torre tienen fondo propio con estilo de carta. La barra que los alinea no dibuja un panel compartido alrededor.
- El panel lateral se ajusta a su contenido, muestra toda la información sin scroll y reduce la escala del contenido si la ventana no permite el alto natural. En build mode muestra el retrato y las estadísticas de la torre, junto al bonus medido de Mountain frente a Grass; no repite instrucciones que ya comunica el preview. Health, Armor y Shield se distinguen con negrita y color. Los upgrades muestran capa, precio y efecto en botones grandes casi cuadrados, con Demoler debajo. Ver [ADR-0039](../decisions/ADR-0039-panel-torre-y-escalado-individual.md) y [ADR-0040](../decisions/ADR-0040-terreno-obstaculos-cofres-y-feedback.md).
- Los sprites de torres, enemigos, props, cofres y base son configurables por objeto y se dibujan con filtrado lineal. Los perfiles actuales usan torres de 84 px, enemigos estándar de 72 px con jefes configurados por separado, obstáculos estirados dentro de una caja común de 86×86 px, centrados con un pequeño desplazamiento hacia abajo, y base de 176×176 px. Los props y las unidades comparten ordenación Y por profundidad. El arte de terreno se recorta por variante para ocupar exactamente la cara del hexágono. Nada de esto cambia la ocupación hexagonal, alcance, selección lógica, colisiones ni movimiento. El tamaño de obstáculos fue refinado por [ADR-0046](../decisions/ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md), que sustituye la medida anterior de [ADR-0044](../decisions/ADR-0044-caja-estandar-de-obstaculos.md).
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
14. Al perder o completar: otorgar moneda meta.
15. Volver a tienda/meta.
16. Comprar mejoras/desbloqueos.
17. Nueva run.

## Cartas de mejora durante la run
Las cards `CardData` son distintas de las cards visuales que ofrecen piezas de terreno. En las rondas que configure el pool, el jugador elige una mejora después de colocar la expansión de esa ronda y antes de iniciar la siguiente. Las cards pueden modificar estadísticas de torres, estados o `Mana`; el efecto dura solo en la run actual. Los nombres con equivalencia directa y los títulos propios están registrados en [Nomenclatura](12_NOMENCLATURE.md). La primera oferta de M11 contiene tres opciones y aparece tras las rondas 3, 6, 9, 12, 15 y 18 como calendario provisional de demo. Tanto calendario como número de opciones son datos configurables, no decisiones de balance final.

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
- Número final de cartas de mejora ofrecidas; M11 usa tres opciones como valor provisional y la oferta de expansión sigue siendo tres piezas.
- Frecuencia final de cartas; el calendario de prototipo de M11 sigue siendo provisional.
- Economía/balance numérico final.
- Número exacto de piezas de terreno.
- Balance final de Ooogie von Ooogovich y de las torres Frost Keep/Tesla Coil; sus parámetros actuales son configurables y provisionales.
- Balance definitivo para múltiples entradas; en la demo se usan todos los finales PATH abiertos y se spawnea por ellos simultáneamente.
- Arte/temática final.

Para el prototipo usar valores temporales centralizados y fáciles de sustituir.
