# ADR-0071: Marco perimetral de cards y colocación automática de terreno

- Fecha: 2026-10-13
- Estado: Parcialmente sustituido por ADR-0075 en la presentación de cards; miniaturas y auto-colocación vigentes, aceptación visual/interactiva pendiente.
- Actualiza la presentación de Upgrade Cards de [ADR-0065](ADR-0065-panel-y-iconos-de-upgrade-cards.md) y detalla la interacción de terreno de [ADR-0060](ADR-0060-ofertas-de-terreno-y-contenido-determinista.md).

## Contexto

La textura de marco 9-slice de Upgrade Cards estaba usando un parche central y márgenes insuficientes; parte de su decoración aparecía estirada detrás del icono y los textos. Las miniaturas de expansión también dibujaban líneas de sockets que hacían que bifurcaciones y convergencias parecieran una maraña. El usuario pidió un atajo para colocar terreno automáticamente cuando exista un sitio legal.

## Decisiones

1. La textura de tier se mantiene como fondo de la card. El marco común utiliza cortes 9-slice ajustados a sus adornos perimetrales y no dibuja el centro; iconos y textos quedan dentro del borde.
2. Las miniaturas de cards muestran terreno y obstáculos, sin brazos, ramificaciones o flechas de conexión PATH. Esto solo cambia su representación: el grafo, las conexiones de la pieza y las validaciones siguen intactas.
3. Mientras hay una pieza seleccionada para colocar, la UI indica `Q · Colocar automáticamente (no recomendado)`. Pulsar Q busca una ubicación y orientación entre las adyacentes al tablero, en orden aleatorio del RNG de terreno de la run.
4. Cada candidata debe pasar `TerrainPlacementValidator`, producir un `PathGraph` válido y, durante una expansión de campaña, dejar una opción de continuación PATH futura. Si encuentra una, Q la confirma de inmediato. Si no encuentra ninguna, informa del resultado y deja el tablero y la pieza sin cambios.
5. E y los botones siguen rotando manualmente. Q conserva el giro antihorario fuera de una colocación activa.

## Consecuencias

- Las tres rarezas comparten un marco perimetral y ya no muestran una banda escalada por el centro.
- Las formas PATH se leen sin líneas superpuestas en las cards; la navegación real continúa dependiendo del grafo.
- La colocación automática puede elegir cualquier ubicación legal del contorno actual del tablero. Nunca omite las restricciones de conectividad ni de continuidad.
- La asignación de Q para auto-colocación descrita aquí es histórica y queda sustituida por ADR-0072: Q/E y la rueda giran; T auto-coloca.
- Falta inspeccionar el marco en ofertas de distintos tamaños y probar T con ubicación válida y sin ubicación válida, además de rotación Q/E y con rueda, en Godot.

## Verificación

Godot 4.7 abrió `game/main/main.tscn` sin errores tras el cambio de M32. La inspección visual e interactiva de marco, miniaturas y auto-colocación queda pendiente según M32–M33 de `10_ACCEPTANCE_TESTS.md`; los controles vigentes constan en ADR-0072.
