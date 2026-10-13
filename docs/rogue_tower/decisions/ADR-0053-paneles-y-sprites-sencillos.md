# ADR-0053: Paneles y sprites sencillos

- Fecha: 2026-10-13.
- Estado: aceptado; implementación y arte integrados, aceptación visual pendiente.
- Complementa: ADR-0040, ADR-0048 y ADR-0051.
- Sustituye: los acabados visuales ornamentales de las cards de expansión descritos en ADR-0048 y los puntos visuales 6–7 de Tower Info en ADR-0051. No cambia la previsión de oleadas, la navegación ni las reglas de selección/mejora.

## Contexto

Los paneles de selección de terreno y Tower Info usaban marcos ilustrados, y Tower Info reservaba mucho espacio para un retrato grande y controles de mejora altos. El cofre y el portal también tenían sprites muy detallados. Se pidió reducir al mínimo la decoración y trabajar sobre `main`, manteniendo el alcance de cualquier cambio de pixel art de otra rama independiente.

## Decisiones

1. Los `PanelContainer` del HUD usan superficies oscuras planas, borde fino de bajo contraste y esquinas casi rectas. La selección de terreno tiene tres cards separadas, sin marco PNG; hover y selección se señalan con un cambio sobrio de borde y relleno. Los previews y conteos se conservan.
2. Tower Info retira el marco ornamental. Un icono de 36×36 comparte cabecera con el nombre y `NIVEL X DE 45`. El contenido se ajusta a su ancho: estado compacto, tres botones de mejora de 96×98 con iconos de 32 px, nivel, barra de XP y coste, y un botón horizontal de texto `Demoler`. Prioridades, XP independiente, tooltips y acciones conservan su comportamiento.
3. El cofre y el portal se reemplazan por sprites originales de pixel art de paleta limitada y silueta simple. Se dibujan con filtro nearest. El import limita el cofre a 168 px y el portal a 336 px en su dimensión mayor; SpawnPortal calcula la escala a partir del tamaño real de la textura importada.
4. El cambio solo afecta presentación y recursos visuales. No cambia terrenos, cofres, oleadas, rutas, economía, mejoras ni selección lógica.

## Consecuencias

- La selección de expansión da prioridad visual al terreno y al preview; el estado de selección sigue visible con una línea de borde.
- Tower Info ocupa menos alto y ancho sin quitar acceso a cifras detalladas, gracias a los tooltips existentes.
- Los PNG fuente mantienen transparencia. El sprite del cofre se ajusta a su caja conservando proporción; el del portal conserva su proporción y tamaño lógico de 112×168 px.
- Queda pendiente revisar legibilidad, alineación y escala de ambos sprites y los dos paneles a 1280×720 y 1440×900 en una ventana Godot.

## Referencias

- [Diseño activo](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md).
- [Aceptación M23](../design/10_ACCEPTANCE_TESTS.md).
- [ADR-0048: HUD, oleadas, cards y paredes texturizadas](ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md).
- [ADR-0051: navegación, previsión por portal y panel de torre](ADR-0051-navegacion-prevision-portales-y-panel-torre.md).
