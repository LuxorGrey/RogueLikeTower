# Propuestas visuales iniciales

Se generaron seis exploraciones el 2026-10-06 como concept art histórico. La dirección aprobada después es 2D isométrica fija 2:1 con assets CellTile, según ADR-0009; estas imágenes no fijan cámara ni assets de producción.

Estas exploraciones son concept art histórico y pueden mostrar piezas/ideas que ya no son reglas vigentes. La generación puede simplificar o inventar conexiones; la fuente lógica actual es [Sistema de losetas isométricas](../../sistemas/sistema-losetas-isometricas.md). No asumir campamentos, monasterios ni montañas como mecánicas activas.

| N.º | Imagen | Cámara y tratamiento | Qué permite evaluar |
|---|---|---|---|
| 1 | [2.5D: bosque y tinta](01-2-5d-bosque-tinta.png) | Cámara oblicua ortográfica de altura media; contorno dibujado, bosque oscuro y relieve legible | Dirección más cercana a la profundidad ilustrada que se busca; relación entre casillas visibles y atmósfera |
| 2 | [Diorama isométrico](02-isometrico-diorama.png) | Isométrica marcada; tablero como maqueta flotante, mosaico modular y relieve pronunciado | Lectura de losetas y alturas; muestra más el tablero entero, pero puede alejarse de la perspectiva de referencia |
| 3 | [Mapa táctico 2D](03-mapa-2d-tactico.png) | Vista elevada casi cenital; terreno ilustrado y caminos con lectura clara | Legibilidad topológica y colocación; reduce la sensación de profundidad y cámara de *Don't Starve Together* |
| 4 | [Diorama 2.5D de cámara baja](04-diorama-2-5d-camara-baja.png) | Ángulo más bajo, espesor de losetas visible y profundidad de campo | Sensación física del terreno; mayor riesgo de que montañas/props tapen caminos |
| 5 | [Ruinas con luz cálida](05-ruinas-luz-calida.png) | Perspectiva ortográfica oblicua; ruinas y bosque luminoso con contraste suave | Variante cálida y más aventurera; evalúa si la escena puede ser rica sin perder lectura de piezas |
| 6 | [Bosque nocturno](06-bosque-nocturno.png) | Cámara oblicua 2.5D; paleta oscura, iluminación de antorchas y alto contraste local | Dirección más misteriosa; comprueba si la iluminación nocturna conserva rutas, unidades y emplazamientos |

## Criterios de selección

- Que las nueve celdas lógicas 3×3, los tipos PATH/GRASS/STONE y su ocupación se lean con claridad.
- Que se lea cada extremo abierto, bifurcación y segmento que termina en campamento.
- Que el relieve STONE se lea sin tapar PATH. La regla vigente define altura lógica 1 para STONE; el sistema visual puede representar esa elevación con las huellas disponibles.
- Que la cámara mantenga tablero, enemigos y defensas legibles al desplazarse y hacer zoom.
- Elegir por separado encuadre/cámara, tratamiento del terreno, contorno y paleta; no es obligatorio seleccionar una propuesta completa.

## Estado

Las propuestas quedan archivadas como exploraciones anteriores a la decisión de 2D isométrico fijo. La dirección vigente es [ADR-0009](../../decisiones/ADR-0009-presentacion-2d-isometrica-y-celltile.md).
