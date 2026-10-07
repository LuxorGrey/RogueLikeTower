# RogueLikeTower — diseño del juego

Este documento resume la visión y distingue las decisiones confirmadas de los detalles que siguen abiertos. “RogueLikeTower” es el nombre del repositorio; no queda fijado como nombre comercial definitivo.

## Resumen

Juego roguelite de defensa de torres donde se construye el terreno con losetas durante la preparación, se moldea la ruta de los enemigos y se combinan defensas para sobrevivir veinte oleadas. Toma Rogue Tower como referencia de género y de sus sistemas de torres, mejoras, enemigos, cartas y progresión; usa la colocación ortogonal de losetas de Carcassonne como inspiración topológica, sin reutilizar su arte.

La presentación acordada es 2D isométrica fija, con proyección 2:1, sprites ordenados por profundidad, paneo y zoom sin giro. El arte CellTile se usará para representar terreno, caminos, piedra y elevación.

## Bucle de partida

1. Se muestra una oferta de tres patrones de loseta diferentes.
2. El jugador elige uno, lo gira en cuartos de vuelta y lo coloca junto al mapa. No hay reflejos.
3. El juego valida conexiones, salidas, zonas y posiciones construibles, y previsualiza el resultado.
4. En preparación, el jugador construye o mejora defensas y administra oro/maná.
5. Al iniciar la oleada, la construcción y las mejoras quedan bloqueadas.
6. Los enemigos recorren sus rutas y las defensas actúan automáticamente.
7. Se liquidan recompensas, cartas o recompensas de jefe que correspondan y comienza la preparación siguiente.

La partida tiene veinte rondas, con mini-jefes en 5, 10 y 15, y jefe principal en 20. Derrotar al jefe de la ronda 20 es la victoria. La duración objetivo es 30–45 minutos.

## Mapa, topología y terreno

- La referencia inicial es una cuadrícula ortogonal y patrones A–Y de losetas. Cada pieza conecta por sus cuatro lados, admite giros de 90° y no se refleja.
- El mapa inicial tiene una pieza de base y una pieza de camino. Se coloca una loseta por ronda; la red se amplía durante preparación.
- Toda pieza que tenga camino debe conectarse a la red iniciada en la base. No se permiten caminos aislados.
- Los enemigos entran por extremos abiertos distintos del ocupado por la base. Se permiten circuitos en el tablero, pero cada enemigo recibe antes de la oleada una ruta simple sin nodos repetidos; la ruta queda fija durante el combate.
- Los cruces incluyen campamento. Las ramas terminan/se separan en el campamento; su conectividad exacta se registra por patrón.
- Los patrones que en la referencia forman ciudad se representan como montaña y conservan sus bordes. Una formación conectada de 2–3 losetas alcanza nivel 1; 4–6, nivel 2; 7 o más, nivel 3. Cada nivel añade, como punto de partida, +1 daño base y +0,5 alcance. Se debe validar el balance.
- Los monasterios A/B son zonas que acumulan bonificaciones de daño, alcance y cadencia para torres dentro de su área. Magnitudes y radio siguen pendientes.
- El terreno afecta a torres y enemigos mientras permanecen en él. Las regiones pueden completarse por contorno cerrado o por un grupo de terreno conectado; umbrales y recompensas siguen pendientes de balance.
- Losetas sin camino pueden añadir terreno y altura sin alterar el grafo de rutas, conforme a la regla de trabajo actual.

### Tres escalas que se deben mantener separadas

- **Tablero inicial:** cuadrícula fija de 9×9 casillas (81 casillas lógicas).
- **Volumen visual por casilla/loseta grande:** hasta 3×3×3 CellTiles, con el camino en la capa más baja. Las capas vacías no necesitan instanciar sprites.
- **Emplazamientos de defensa:** cada casilla/loseta grande conserva nueve posiciones lógicas de construcción en 3×3: cuatro esquinas, cuatro centros de borde y una central. Esta cuadrícula de interacción es distinta del volumen visual de hasta 27 posiciones CellTile.

El tablero de 9×9, el volumen visual y la cuadrícula de construcción son capas separadas. El modelo debe poder cambiar una sin alterar las reglas de las otras.

## Construcción y economía

- Se puede construir y mejorar únicamente durante preparación.
- Cada loseta grande tiene nueve emplazamientos lógicos. Caminos, campamentos y muros perimetrales de montaña bloquean las posiciones que ocupan; el interior de montaña puede construirse y se beneficia de la elevación.
- Oro y maná son recursos distintos. Hay recompensa fija por oleada y bonus por bajas/regiones; cantidades, costes y regeneración quedan pendientes.
- XP persiste entre runs y alimenta metaprogresión.
- Se prevén torres, edificios de apoyo, mejoras, efectos de estado, cartas, enemigos y jefes inspirados en Rogue Tower. El catálogo de referencia completo no implica que todo entre en la primera beta.

## Enemigos, daño y victoria

- Los enemigos siguen caminos abiertos hacia la base con reglas fijas y deterministas.
- Como base de balance, rápidos/móviles prefieren ruta corta; pesados/resistentes y jefes, ruta larga. Es una regla propia, no un dato atribuido a la referencia.
- La base comienza con 20 de integridad. Un enemigo normal que se filtra causa 1 de daño; un jefe filtrado es letal. Llegar a cero termina la run.
- Cada tipo puede tener habilidades propias; el roster y las estadísticas iniciales se decidirán para la beta.

## Cartas y metaprogresión

Las cartas de mejora entre oleadas y las recompensas de jefes forman parte del baseline. La beta debe introducir este sistema de manera gradual, con pocas cartas y opciones legibles al principio, y ampliar pool, sinergias y complejidad más adelante. No están fijados el calendario, la cantidad de opciones por elección, rarezas, exclusiones ni desbloqueos.

La progresión entre runs está confirmada. Falta determinar qué desbloquea, a qué ritmo y cuánto poder concede al inicio de una nueva partida. Solo se planea un modo de dificultad al principio.

## Primera beta

La beta debe recorrer las veinte rondas e incluir cada familia de sistemas: losetas y rutas, construcción, oleadas, torres/mejoras, oro/maná, terreno/regiones, cartas, edificios de apoyo, estados, jefes y metaprogresión. Se simplifica el volumen de contenido y balance, no se elimina una familia completa. Se usará un modo y un conjunto pequeño de opciones representativas por sistema.

Las cantidades exactas de contenido todavía no están elegidas. El plan de implementación propone cuándo introducir cada sistema, no convierte cantidades de ejemplo en decisiones confirmadas.

## Interfaz y feedback

- El tablero es el elemento central y la interfaz debe dejar visible suficiente mapa mientras ofrece controles y estado de partida.
- La celda enfocada, seleccionada, ocupada, construible y bloqueada deben distinguirse sin depender solo del color.
- Al pasar/enfocar una celda se muestra su tipo de terreno, altura, contenido y motivo de bloqueo, si lo hay.
- Al elegir una loseta, el juego presenta una previsualización translúcida en la posición prevista; los conectores válidos y las incompatibilidades se distinguen antes de confirmar.
- La rotación modifica previsualización, conectores y máscara de construcción de forma conjunta.
- Los estados de preparación y combate deben ser visibles; en combate se explican los motivos por los que no se pueden construir o mejorar.
- Controles exactos, accesibilidad, zoom mínimo/máximo y reglas finales de selección están por definir.
