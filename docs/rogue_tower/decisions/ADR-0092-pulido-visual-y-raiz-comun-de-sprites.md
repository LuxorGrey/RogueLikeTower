# ADR-0092: Pulido visual y raíz común de sprites

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita del usuario; código y recursos integrados, aceptación visual pendiente.
- Alcance: dibujo de torres, contorno de terreno, fachadas Grass/Mountain, escala de props/obstáculos, animación/interacción de portales y organización de assets.
- Sustituye: parámetros de presentación de sprites descritos en ADR-0087 y ADR-0089; mantiene las reglas de elevación, Y-sort y fachadas de ADR-0084/0085/0090 y la silueta regional de ADR-0091.

## Contexto

El usuario pidió centrar las torres en su hexágono y ampliar su presentación un 20 %, suavizar las uniones del perímetro, hacer coincidir el tono superior de las fachadas con Grass/Mountain, ampliar props y obstáculos un 10 %, eliminar el cuadro duplicado del loop del portal, limpiar tooltips cuando desaparece un portal y reunir los sprites dispersos en una única raíz.

## Decisiones

1. Las torres y su ghost usan la misma coordenada axial central. El arte conserva su ancla inferior centrada en la tapa; el tamaño visible se multiplica por 1,2 y el pequeño ajuste de arte pasa de 6 a 8 px para mantener el apoyo centrado después de escalar. No cambia ocupación, alcance, daño, hitbox ni selección.
2. Los segmentos de contorno del tablero, las superficies elevadas, el hover y las miniaturas terminan con uniones redondeadas que rellenan los huecos en los vértices. Las fronteras de región y sus colores siguen ADR-0091.
3. `grass_cliff_face.png` usa el tono base dominante de Grass (`#53B56F`) y `mountain_cliff_face.png` el de Mountain (`#8A8B91`). El degradado oscuro de vértice continúa solo hacia la parte baja de las fachadas; las tapas no se modifican.
4. Props pasan de 36 a 39,6 px y obstáculos de 86 a 94,6 px de caja visual. Sus PNG fuente, probabilidades, distribución determinista, límite de dos props y orden (props detrás de obstáculos) permanecen iguales.
5. El portal conserva su atlas 4×2 y recorre solo los frames 0–6. El frame 7, idéntico al frame 0, no participa en el loop. El desfasado por endpoint permanece igual.
6. Un portal limpia su estado de hover y notifica su salida antes de `queue_free`; el cierre de una salida oculta su tooltip inmediatamente, antes de que aparezcan cards.
7. Todos los sprites del proyecto, incluidos iconos de interfaz, enemigos, terreno, obstáculos, props, portales y sprites de Tiny Swords, viven bajo `assets/sprites/` con subcarpetas por categoría. Se trasladan sus sidecars `.import` y se actualizan las rutas de código, Resources, escenas y herramientas. El contenido Tiny Swords sigue ignorado por Git por su restricción de redistribución. Tipografías y fuentes/previas de `art_generation/` no son sprites runtime y conservan su ubicación.

## Consecuencias

- Los iconos colocados y el ghost usan una escala compartida de torre, evitando discrepancias al construir.
- Los trazos de terreno se conectan en los vértices sin cortar el perímetro de regiones.
- Las fachadas mantienen el degradado inferior y su extremo superior adopta el color del terreno correspondiente.
- Las cajas de decoración ocupan más superficie, pero no cambian la lógica hexagonal ni las probabilidades.
- Se rompe la ruta antigua de los sprites; el proyecto y las herramientas apuntan a `assets/sprites/` y deben seguir usando esa raíz.
- La revisión visual en Godot queda pendiente; no se ejecutó una sesión de juego en esta actualización.

## Referencias

- [Fuente de verdad de diseño](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md)
- [Grid hexagonal y terreno](../design/05_HEX_GRID_AND_TERRAIN.md)
- [Aceptación M43](../design/10_ACCEPTANCE_TESTS.md)
- [Catálogo central de sprites](../../../assets/sprites/README.md)
- [Catálogo de sprites de terreno](../../../assets/sprites/terrain/README.md)
