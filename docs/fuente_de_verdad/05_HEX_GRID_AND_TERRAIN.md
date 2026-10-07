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
4. No existe una conexión Path->no Path a través de un borde marcado como salida de camino.
5. Tras colocarla, el/los spawns que deban conservar ruta hacia la base siguen teniendo una ruta válida.
6. No se crea una celda construible inaccesible visualmente por error de renderer (solo validación de desarrollo).

Regla de diseño: las conexiones de camino se definen explícitamente por borde; no asumir que dos celdas PATH adyacentes conectan si la plantilla visual dice lo contrario.

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

En el preview M2, cada nivel desplaza temporalmente la cara superior 18 px hacia arriba. Los desniveles se dibujan como caras laterales sombreadas; en la pieza aislada, una celda vecina ausente se trata como altura 0. Las caras superiores se ordenan por profundidad lógica (Y de base, con X como desempate), y muestran `h0/h1/h2` para depuración. Este offset y estos polígonos son placeholders visuales, no especificación de arte final. La escena principal incluye un contenedor `Entities` con Y-sort habilitado para los actores.

El hover solo detecta las caras superiores: PATH resalta en `#82BFE6`, GRASS en `#80E085` y MOUNTAIN en `#F5C25C`. El HUD superior muestra la coordenada axial local `(q,r)`, el terreno y la altura de la celda. Los cliffs no son superficies seleccionables. El proyecto ya inicia en Godot 4.7 sin errores; la interacción real del puntero está pendiente de inspección manual.

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
