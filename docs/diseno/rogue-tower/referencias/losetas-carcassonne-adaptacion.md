# Referencia de patrones de losetas A–Y

Este documento registra una imagen de referencia aportada por el usuario. Describe rasgos visibles y cantidades; no establece tipos de terreno ni reglas actuales. La arquitectura vigente es [Sistema de losetas isométricas](../sistemas/sistema-losetas-isometricas.md). No reutilizar las ilustraciones de Carcassonne en el juego.

## Inventario visual de la imagen

| ID | Cantidad visible | Rasgo orientativo |
|---|---:|---|
| A | 2 | Caseta/monasterio y camino |
| B | 4 | Caseta/monasterio sin camino |
| C | 1 | Formación completa marrón |
| D | 4 | Recta y borde marrón |
| E | 5 | Borde marrón y camino que termina junto a él |
| F | 2 | Formaciones marrones opuestas con camino atravesando |
| G | 1 | Formación marrón en lados opuestos con detalles |
| H | 3 | Dos formaciones opuestas y camino recto |
| I | 2 | Formación marrón en dos bordes adyacentes |
| J | 3 | Curva de camino junto a formación marrón |
| K | 3 | Camino curvo que llega al borde opuesto |
| L | 3 | Cruce junto a una formación marrón |
| M | 3 | Unión T junto a formación marrón |
| N | 3 | Formaciones marrones adyacentes, sin camino visible |
| O | 2 | Formación marrón conectada a camino por un lado |
| P | 2 | Formación marrón con camino hacia el lado opuesto |
| Q | 3 | Curva de camino y formación marrón |
| R | 1 | Formación marrón con detalle, sin camino visible |
| S | 3 | Formación marrón central, sin camino visible |
| T | 2 | Camino que termina en formación marrón |
| U | 1 | Formación marrón conectada a camino recto |
| V | 8 | Camino curvo que cruza la pieza |
| W | 9 | Camino curvo en gancho/vuelta |
| X | 4 | Bifurcación de tres brazos con detalle central |
| Y | 1 | Cruce de cuatro brazos con detalle central |

La lectura de caminos es aproximada. Antes de crear un `ChunkDefinition`, deben verificarse puertos y conexiones internas en la imagen original ampliada; no inferir una conexión desde la cercanía de líneas.

## Conteo y proporciones de referencia

Transcripción literal: `A2 B4 C1 D4 E5 F2 G1 H3 I2 J3 K3 L3 M3 N3 O2 P2 Q3 R1 S3 T2 U1 V8 W9 X4 Y1`. La suma es **75**. Devir describe una edición base con 72 piezas; se conserva la diferencia sin corregir ni convertir el número en cantidad de piezas del juego.

La tabla se puede estudiar como distribución relativa al diseñar ofertas futuras, pero no está adoptada todavía como peso de producción. Una sola oferta sin duplicados, máximo de colocación por ronda y regla del mapa inicial son decisiones de juego pendientes.

## Estado de adaptación

- La referencia visual puede guiar conectores cardinales y formas de camino.
- Antiguas adaptaciones de «ciudad a montaña», campamento, monasterio y bonos por región quedan sustituidas/no confirmadas para el sistema de terreno actual. Solo vuelven si se especifican como una mecánica compatible con PATH/GRASS/STONE.
- Las reglas actuales de puerto, vecinos, rotación y ruta PATH pertenecen a la especificación del sistema y ADR-0013.
- El arte final debe ser propio o contar con licencia compatible; esta imagen es material de referencia, no asset distribuible.

## Procedencia

Imagen de referencia suministrada por el usuario, archivada en [imagenes-de-referencia.md](imagenes-de-referencia.md). Fuentes externas consultadas para comparar el conteo: [guía de losetas de Devir](https://deviramericas.com/guia-de-losetas-de-carcassonne/), [edición 20.º aniversario de Devir](https://deviramericas.com/product/carcassonne-20mo-aniversario/) y [reglamento Big Box](https://cundco.de/media/84/a4/ac/1773930056/CC_BigBox_2010_Rule.pdf?ts=1773930056). Estas fuentes contextualizan el juego de referencia; no dictan reglas de Rogue Tower.
