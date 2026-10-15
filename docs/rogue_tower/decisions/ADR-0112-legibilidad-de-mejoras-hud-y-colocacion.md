# ADR-0112 — Legibilidad de mejoras, pausa y colocación de terreno

- Fecha: 2026-10-15
- Estado: Aceptado; implementación integrada; aceptación visual e interactiva pendiente.
- Decisiones relacionadas: refina ADR-0061 (pausa y fases de expansión), ADR-0072 (controles de terreno), ADR-0093 (selección de portales) y ADR-0105 (presentación de spawns y panel de Gold).

## Contexto

Los textos de mejoras no diferenciaban visualmente las cifras positivas y negativas. El HUD mantenía un panel técnico de terreno/debug accesible con F3 que ya no forma parte del flujo esperado. El botón de pausa ocupaba una fila separada bajo la vida, Mana no compartía el panel de Gold y la colocación de terreno no mostraba sus atajos de forma suficientemente visible. La composición de enemigos de un portal estaba disponible en hover, aunque el usuario también necesita consultarla desde el panel lateral.

## Decisiones

1. Las cifras de efectos beneficiosos se muestran en verde y las de efectos perjudiciales en rojo, tanto en cards de run como en nodos de mejoras permanentes. En Tower Info, cada estadística efectiva se compara con el valor base: una subida aparece verde, una reducción roja y un valor sin cambio conserva el color normal. Los bonuses por elevación y los efectos positivos H/A/S usan verde. El coste de Mana se interpreta al revés: consumir menos es verde y consumir más, rojo.
2. El botón de pausa comparte la fila de la barra de vida. Su único carácter visible es `P`, junto a un glyph de pausa mientras la partida corre y de play mientras está pausada. `P` conserva su atajo de teclado.
3. Se retira de la escena y del código runtime el panel F3, su selector de oleadas de diagnóstico y su inspector técnico. La campaña normal mantiene sus 45 rondas en orden; los controles de terreno siguen funcionando con teclado, ratón y cards.
4. Al seleccionar una pieza para colocar aparece un panel grande, encima de las cards de torre, con `Q / E` para rotar y `T` para colocación automática. El texto de validación de la posición permanece debajo.
5. Clicar un portal produce el mismo feedback `ui_click` que los demás objetos interactuables, cierra su tooltip y deja en Tower Info la composición de enemigos asignada a esa salida para la ronda actual.
6. Gold y Mana usan paneles 9-slice iguales, con dimensiones, altura, icono y composición coincidentes.

## Consecuencias

- Se elimina la superficie de diagnóstico F3 del flujo de juego. Los criterios históricos de esa herramienta se consideran sustituidos por M61.
- Los colores describen el efecto relativo en combate, no rareza ni tipo de recurso.
- No se ejecutaron pruebas de escena; las comprobaciones visuales e interactivas quedan en [Aceptación](../design/10_ACCEPTANCE_TESTS.md#m61--legibilidad-de-mejoras-hud-y-colocacion-de-terreno).
