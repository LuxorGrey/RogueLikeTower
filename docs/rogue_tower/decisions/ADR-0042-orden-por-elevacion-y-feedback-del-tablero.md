# ADR-0042: Orden por elevación y feedback del tablero

- Fecha: 2026-10-09.
- Estado: aceptado por petición explícita del usuario; código y contenido integrados, aceptación visual pendiente.
- Ámbito: profundidad de terreno elevado, grid/hover, spawns, flujo PATH, cursor, barra de torres y catálogo de piezas.
- Sustituye parcialmente: ADR-0041, en cuanto el Y-sort solo seguía la coordenada terrestre y a la representación estática de endpoints spawn. El punto 1 sobre ordenar fachadas/cliffs fue reemplazado por [ADR-0043](ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md) tras la revisión visual del usuario.

## Contexto

La base y los enemigos parecían dibujarse por encima de hexágonos elevados. El jugador también pidió ocultar la grid hasta hacer hover, cambiar los carteles `SPAWN` por un portal animado, reducir y pulsar el cursor de construcción, mejorar la lectura de la barra de torres y añadir más diversidad a las piezas de siete hexes. La imagen adjunta mostraba el estilo de flechas móviles deseado.

## Decisiones

1. **Decisión sustituida parcialmente por ADR-0043:** esta revisión ordenaba el centro de cada tapa de terreno según su altura proyectada y añadía cada fachada como nodo individual dentro de `Entities.y_sort_enabled`, anclada al borde inferior. La observación visual mostró que esa pared aparecía encima de enemigos/base; el contrato actual para superficies y fachadas está en ADR-0043. Ninguna regla axial, de navegación o de gameplay cambia.
2. Los bordes de los hexes y las líneas/sockets PATH permanecen ocultos cuando no hay hover. Al seleccionar una celda se dibujan su borde y conexiones; los anillos vecinos axialmente a distancia 1 y 2 se atenúan progresivamente. El overlay de flechas de navegación sigue visible aun sin hover.
3. Los endpoints spawn usan la escena `SpawnPortal` y el asset intercambiable `assets/terrain/spawn_portal.png`. El sprite tiene alfa y anima escala/brillo con Tween; no se imprime texto ni cartel `SPAWN`. Los endpoints se crean/retiran desde el `PathGraph` alcanzable activo o candidato.
4. Las flechas mantienen dibujo 2D por arista a partir de `PathGraph`, pero usan silueta llena, ancha, con sombra y un movimiento más legible hacia la base. La referencia *Moving Arrow on Tiles/Cells for Voxel Engines/Games* describe un shader espacial y UV para celdas de voxel; no se copia ese shader porque el juego no usa voxel/mesh y necesita deduplicar las ramas de su grafo axial. El dibujo por segmento preserva orientación, bifurcaciones y tramos compartidos, y permite actualizar el candidato mientras se coloca terreno.
5. Durante el modo de construcción el puntero nativo se oculta y una `TextureRect` de 32×32 sigue el ratón con una pulsación de escala pequeña. El mismo overlay presenta el cursor válido o el de error; al pasar a controles interactuables se restaura el cursor normal de la interfaz.
6. Los siete botones de torre aumentan a 144×148 px y reducen su separación a 2 px para conservar una fila compacta. Al construir una torre, su icono correspondiente vibra con una secuencia de rotación y escala. El feedback de Gold ya anima icono y cifra tanto al cobrar como al gastar y se conserva.
7. El catálogo asciende a quince piezas totales. Las cinco existentes siguen disponibles y se añaden `meadow_hills`, `mountain_massif`, `open_grassland`, `staggered_ridge`, `mountain_islet`, `twin_peaks`, `dead_end_spur`, `cliff_turn`, `meadow_switchback` y `three_way_ravine`. Cada pieza nueva contiene el centro y sus seis vecinos axiales. Seis amplían paisajes construibles; las otras cuatro introducen una rama sin salida más una continuación, una curva, un serpenteo y una bifurcación. Las conexiones internas se declaran recíprocamente. No se ajustan el balance ni las reglas de colocación.

## Consecuencias y estado

- Históricamente, este ADR permitió que las fachadas taparan entidades. Esa oclusión quedó sustituida por la tapa texturada descrita en ADR-0043; las fachadas siguen siendo representación y no crean celdas ni colisiones.
- Ocultar el contorno reduce ruido en el mapa. El hover revela localmente la geometría y el sentido de conexión sin quitar el flujo global de ruta.
- El portal queda en un PNG separado fácil de intercambiar. La animación se configura en su escena.
- Se prefiere el flujo basado en `PathGraph` sobre UV/shader espacial para que una ruta 2D con ramificaciones mantenga dirección y continuidad. Se mantiene el shader simple como posible opción futura si la representación cambia a una textura/mesh continua.
- Los diez `.tres` nuevos pasan por los mismos validadores que las piezas originales. La aceptación de rotación, conexión y legibilidad en ventana Godot queda pendiente.
- No se ejecutaron pruebas automatizadas en este hito. La revisión manual está definida en M18 de `design/10_ACCEPTANCE_TESTS.md`.

## Referencias

- Petición directa del usuario y la imagen adjunta de referencia en la sesión del 2026-10-09.
- Sentry456123, *Moving Arrow on Tiles/Cells for Voxel Engines/Games*, Godot Shaders, publicación del 2026-09-18; consultado el 2026-10-09: <https://godotshaders.com/shader/moving-arrow-on-tiles-cells-for-voxel-engines-games/>. Referencia visual para flechas animadas; su implementación usa UV/shader espacial para voxel cells.
- Godot Engine, *CanvasItem*, documentación oficial estable, consultada el 2026-10-09: <https://docs.godotengine.org/en/stable/classes/class_canvasitem.html>. Y-sort 2D y comparación de CanvasItem con mismo Z.
- [ADR-0041](ADR-0041-occlusion-arte-terreno-y-flujo-de-rutas.md) para el sistema de assets, escalado individual, filtros, cofres y líneas de ruta.
