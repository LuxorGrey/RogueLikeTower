# ADR-0114 — Preview de torre, resumen de run y mapa permanente

- Fecha: 2026-10-15
- Estado: Aceptado; código/documentación integrados; aceptación visual e interactiva pendiente.
- Decisiones relacionadas: refina ADR-0093/0094 para el preview de torre y ADR-0076 para el resumen de fin de run; desarrolla el mapa de ADR-0077.

## Contexto

El radio de ataque solo se intuía al pasar el cursor y no permanecía visible al seleccionar una torre. El ghost y la ficha de selección podían calcular daño/alcance por caminos distintos, mostrando una elevación diferente a la que recibía la torre al construirse. La colocación de terreno necesitaba una señal más evidente de validez. El resumen final filtraba los tipos por unlock permanente, y el mapa de mejoras no alineaba todos los unlocks de torre en una fila común. Algunos nodos de mejora podían quedar sin icono y su precio no compartía una jerarquía visual uniforme.

## Decisiones

1. `Tower.get_damage_for`, `Tower.get_range_hexes_for` y `Tower.get_cell_world_position` son los cálculos compartidos por torre construida, ficha y ghost. El preview incorpora elevación, cartas activas y multiplicador permanente, por lo que se puede comprobar el resultado antes de confirmar la colocación.
2. Una torre dibuja un anillo de alcance de alto contraste mientras está bajo el cursor o seleccionada. El radio usa el alcance efectivo actual, incluidos modificadores de run.
3. Las celdas de una pieza en colocación usan un tinte y un contorno lima intenso cuando la pieza es válida y rojo intenso cuando no lo es.
4. `RunManager` presenta en el Game Over solo los IDs que registraron al menos una torre construida durante la run, agrupando por tipo el número construido y el daño total. El resumen no depende de los unlocks permanentes.
5. Los siete nodos de unlock de torre se disponen en la misma fila del mapa. Cada torre habilita tres opciones H/A/S alineadas horizontalmente; ninguna requiere comprar antes una de las otras dos, aparte de desbloquear la torre.
6. Cada nodo permanente tiene un icono del `IconCatalog`, usando primero el icono de perfil y, en última instancia, el icono común de daño como fallback. En nodos con coste, la cifra se centra en grande y el icono de perfil (`exp.png`) se muestra a su derecha en la misma fila.

## Consecuencias

- El jugador puede comparar el alcance de torres con rapidez y evaluar la elevación antes de gastar Gold.
- Un tipo desbloqueado pero nunca construido no añade ruido al resumen de la run.
- El árbol presenta las opciones H/A/S en paralelo, con lectura común de icono y coste.
- No se ejecutó Godot ni una revisión en ventana; la aceptación visual/interactiva está descrita en [M63](../design/10_ACCEPTANCE_TESTS.md#m63--alcance-ghost-exacto-y-mapa-de-mejoras).
