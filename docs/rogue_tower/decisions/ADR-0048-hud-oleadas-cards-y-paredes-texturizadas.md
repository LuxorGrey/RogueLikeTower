# ADR-0048: HUD, progreso de oleadas, cards de terreno y paredes texturizadas

- Fecha: 2026-10-10
- Estado: progreso de oleadas, HUD y fachadas vigentes; la piel texturizada de los botones/cards fue sustituida parcialmente por ADR-0053. Aceptación visual pendiente.
- Decisión relacionada: [ADR-0047](ADR-0047-herramientas-de-depuracion-y-claridad-de-seleccion.md).

## Contexto

El HUD mantenía un fondo conjunto para la salud, Gold y Mana; `%GoldGroup` se intentaba resolver aunque el nodo no estaba marcado como nombre único en `main.tscn`, lo que dejaba nulo el grupo de animación. La línea de progreso anterior representaba las rondas con segmentos uniformes y no informaba la composición. Las ofertas de expansión tenían un contenedor con panel detrás y no resumían cuántos hexes había de cada terreno. Las fachadas elevadas se componían con dos triángulos vectoriales; algunas juntas podían quedar visibles y el material no diferenciaba Grass de Mountain. La primera versión texturizada cerró cada quad, pero estiraba el PNG entero sobre cada cara y dejaba pequeñas aperturas donde las extrusiones se encontraban en ángulo.

## Decisiones

1. Marcar `GoldGroup` como nombre único de escena, para que `%GoldGroup` y el rebote de Gold apunten al grupo que contiene icono y saldo.
2. Quitar el fondo compartido del HUD principal y del bloque de ronda. La salud queda arriba a la izquierda y los atajos debajo; Gold/Mana conservan su disposición y pasan arriba a la derecha. El panel de información de torre empieza debajo de los recursos para no cubrirlos.
3. (Sustituido parcialmente por ADR-0053.) El botón «Iniciar ronda» dibujaba el PNG completo conservando su proporción 3:1. Se mantiene el ancho que sigue el texto visible; el fondo actual es plano y ya no carga ese marco PNG.
4. La tira de 45 rondas dibuja una línea con un punto por cada `WaveData`. El radio depende de la cantidad directa y añade énfasis si la ronda declara jefe o contiene `EnemyData.boss_tier`. Al hacer hover, el tooltip informa el total y agrega retratos/conteos por tipo de enemigo solo si su suma en esa ronda es mayor que uno.
5. (Sustituido parcialmente por ADR-0053.) Las tres cards de terreno conservan su preview, el panel compartido queda sin fondo y ya no se usa el marco PNG. La oferta conserva cards de al menos 320×420 px y previews de 264×340 px contenidas dentro de su área. El estado reducido de colocación usa cards de 184×126 px y previews de 132×54 px. Su etiqueta inferior cuenta Path, Grass y Mountain en ese orden y omite los tipos con cero celdas.
6. Las fachadas de elevación se dibujan como un quad texturizado por cada borde visible y usan `mountain_cliff_face.png` o `grass_cliff_face.png`. Los UV muestrean regiones del PNG proporcionales al ancho y la altura del desnivel con una densidad estable; los vértices compartidos reciben cuñas de unión para cerrar las esquinas. La fachada continúa debajo de unidades/props y no cambia el hex lógico, su elevación, el Y-sort ni la oclusión de la cara superior. Los triángulos vectoriales ya no definen el material visible.
7. Los cuatro PNG nuevos se generaron para este proyecto el 2026-10-10 con el generador de imágenes integrado: marco de card, marco horizontal de botón, roca facetada y suelo con césped. No proceden de un pack externo.

## Consecuencias

- Las oleadas se leen de forma comparativa; su tooltip usa datos runtime cargados y suma grupos repetidos por ID de enemigo.
- Un tipo que aparece una sola vez queda fuera de la lista de retratos, aunque sí cuenta en el total de la ronda.
- La imagen del botón de ronda conserva su proporción al adaptarse a la longitud de su texto, y la preview de cada pieza queda contenida dentro de su card tanto en la oferta como durante la colocación.
- Históricamente los marcos se editaban en `assets/ui/terrain_expansion_card_frame.png` y `assets/ui/start_round_button.png`; ADR-0053 deja de referenciar esos PNG desde estas escenas sin borrar los archivos.
- Los materiales de fachada pueden sustituirse en `assets/terrain/tiles/` sin alterar la geometría lógica ni el cálculo de altura.
- El mapeo de UV y las uniones de vértice mantienen las fachadas de elevación 1 y 2 sin estirar el sprite ni dejar huecos angulares.
- El cambio de layout y la legibilidad de los recursos junto al panel lateral requieren revisión manual a 1280×720 y 1440×900.

## Verificación pendiente

- Ejecutar la escena y confirmar que GoldGroup se enlaza, anima al ganar/gastar y no emite el error de nodo nulo.
- Inspeccionar el HUD sin paneles de fondo, y verificar el espacio superior derecho con el panel de torre seleccionado.
- Pasar el cursor por rondas estándar, con varios tipos, y con encuentros especiales; confirmar tamaño relativo de puntos, total, retratos y omisión de tipos con conteo 1.
- Comprobar las tres cuentas de terreno, la ausencia del panel compartido y que las previews ocupen el marco sin salirse, tanto en oferta como en el estado reducido de colocación. Verificar además que el botón de ronda conserva su arte y muestra completo cada texto dinámico.
- Inspeccionar fachadas Grass/Mountain en elevaciones 1 y 2, comparar la escala de textura entre alturas, revisar los encuentros angulares y confirmar cierres y oclusión de entidades.
