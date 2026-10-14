# ADR-0087: Props, obstáculos y altura junto a base

- Fecha: 2026-10-14
- Estado: Aceptado; código y assets integrados, aceptación visual pendiente.
- Ámbito: renderer de terreno, generación de contenido visual por celda, recursos de base y documentación activa.

## Contexto

La base usa un sprite de resolución original, y su anillo de seis hexes debe conservar un perfil bajo para mantener legible el acceso. Los props disponibles llegaron agrupados por terreno, mientras los obstáculos nuevos vivían en una carpeta separada y tenían tamaños/rutas distintas al pool runtime anterior. La presentación previa también desplazaba obstáculos hacia abajo. Se requiere una nomenclatura uniforme, contenido decorativo reproducible y un único comportamiento visual coherente en miniatura, ghost y tablero.

## Decisión

1. Las seis celdas axialmente adyacentes a Main Tower tienen elevación máxima 1. PATH conserva elevación 0; Grass queda en elevación 1; una Mountain generada para una celda vecina se normaliza a Grass. La validación inicial también rechaza una celda de base vecina por encima de 1. El ghost aplica la misma conversión y enseña esa altura antes de confirmar.
2. El sprite de la base se dibuja a escala 1:1. Se elimina el tamaño configurable que permitía deformarlo; el asset actual mide 352×352 px.
3. Cada PNG de props se nombra `prop_<terreno>_<elemento>.png` y se prepara a 96×96 px con transparencia. Cada asset compatible con el terreno realiza un roll independiente de 5 % en cada celda; se permiten hasta dos IDs distintos por celda. La selección se hace determinísticamente por la seed y la identidad de celda/oferta; el límite se aplica después de los rolls. Si el terreno se normaliza junto a la base, se regeneran los props desde el catálogo del tipo resultante y se comparte la misma tirada entre ghost y tablero confirmado. Los props solo son decoración, no tienen input/hitbox ni efectos, y no se colocan superpuestos entre sí.
4. Los props aparecen en Path, Grass o Mountain de su carpeta y se muestran a 30×30 px. La oferta se conserva entre miniatura, ghost y tablero; si la colocación cae en el anillo de base y Mountain se normaliza a Grass, el ghost y el tablero regeneran juntos los props compatibles con Grass a partir de la coordenada global. La miniatura, al no tener ancla, conserva el terreno/props ofertados. Se dibujan debajo del obstáculo.
5. Los cinco obstáculos anteriores se sustituyen por ocho assets, renombrados `obstacle_<nombre>.png`, ubicados directamente en `assets/terrain/obstacles/` y preparados a 208×208 px, igual que la resolución fuente anterior. En tablero/miniatura se muestran en caja de 86×86 px, centrados en la celda y por delante de props. La probabilidad y la lógica de bloqueo/retirada no cambian.
6. Se eliminan las imágenes antiguas, sidecars y referencias runtime; la herramienta de preparación de arte ya no regenera la lista anterior.

## Consecuencias

- La elevación junto a base queda acotada sin cambiar las reglas aleatorias de las demás celdas.
- Los props siguen siendo decorativos y no alteran ocupación, construcción, navegación, obstáculos ni cofres.
- El resultado de prop y obstáculo se transfiere sin nueva aleatoriedad entre preview y tablero confirmado.
- Los nombres visibles de obstáculos y las rutas se enumeran en [Nomenclatura](../design/12_NOMENCLATURE.md) y [README de assets](../../../assets/terrain/README.md); esta ADR y esas páginas enlazan el criterio activo.
- La inspección visual en ventana de posiciones, escalas y capas continúa pendiente; no se declara aceptación de arte.

## Decisiones relacionadas

- [ADR-0079](ADR-0079-limites-de-obstaculos-y-cierre-visual-del-terreno.md): límites de cantidad de obstáculos.
- [ADR-0084](ADR-0084-render-axial-de-terreno-y-profundidad-por-celda.md) y [ADR-0085](ADR-0085-solo-fachadas-delanteras-y-degradado-de-cliffs.md): renderer axial, fachadas y profundidad.
- Sustituye el catálogo de assets/props de las versiones anteriores de ADR-0040, ADR-0044, ADR-0058 y ADR-0060; mantiene sus reglas de obstáculos, cofres y ofertas que no se contradicen aquí.
