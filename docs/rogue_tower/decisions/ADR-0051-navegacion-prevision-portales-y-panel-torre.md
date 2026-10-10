# ADR-0051: Navegación, previsión por portal y panel de torre

- Fecha: 2026-10-10.
- Estado: aceptado; cambios de código y recursos integrados, aceptación visual/interactiva pendiente.
- Complementa: ADR-0042, ADR-0043, ADR-0046, ADR-0047, ADR-0048 y ADR-0050.
- Sustituye: la tecla `D` deja de alternar el overlay diagnóstico para permitir mover la cámara a la derecha; el overlay pasa a `Ctrl+D`.

## Contexto

El mapa ya permitía panear con el botón central y arrastre. Los portales mostraban de dónde podían venir enemigos, pero no anunciaban la composición por entrada. El ghost de torre no diferenciaba suficientemente el modo de colocación. Tower Info tenía un panel plano, información de mejora principalmente textual y un botón Demoler ancho. Las sombras proyectadas que se dibujaban bajo entidades y decoración añadían manchas que no forman parte del arte.

La composición activa de la campaña se reparte en `WaveDirector._select_campaign_route`: cada enemigo de la ronda usa el siguiente endpoint alcanzable en un round-robin global que se reinicia al empezar la oleada. Los fixtures de diagnóstico, en cambio, siguen la política declarada en cada `WaveEnemyGroupData`. Una previsión visual debe respetar esta diferencia para mostrar datos correctos.

## Decisiones

1. `W`, `A`, `S`, `D` panean la cámara continuamente. Las diagonales se normalizan y la velocidad del mundo compensa el zoom. Las teclas mantenidas se limpian cuando la ventana pierde el foco. El pan con botón central, zoom, `H` y `R` conservan su función. El overlay de diagnóstico de rutas se asigna a `Ctrl+D`.
2. Cada portal alcanzable recibe la lista agregada de tipos de enemigo y el conteo que le corresponde en la ronda seleccionada. El tooltip al hover indica ronda, total y grupos por tipo; retratos sobre el portal anticipan los tipos, con contador visible si hay más de uno. La previsión se recalcula al elegir otra ronda, confirmar o mover una expansión válida y sigue el mismo reparto de `WaveDirector`.
3. El sprite alfa del portal recibe contorno cuando el puntero está sobre su área interactiva. El tooltip vive en la escena de HUD y se mantiene por encima del mundo sin capturar el puntero.
4. El sprite de la torre en construcción usa un `ShaderMaterial` fantasma verde translúcido si la casilla es legal y rojo si no lo es. Mantiene prioridad Z por encima de terrenos, elevaciones y decoración.
5. Se eliminan las sombras proyectadas dibujadas por código bajo enemigos, props y trazos de flujo. No se sustituyen por otro tipo de sombra procedural.
6. Tower Info usa el PNG de marco `assets/ui/tower_info_panel_frame.png`. Muestra el retrato grande arriba, el título y `NIVEL X DE 45` en la cabecera, donde X cuenta las mejoras acumuladas. Cada capa Health/Armor/Shield conserva XP independiente y lo presenta con una barra; la cifra exacta se consulta en su tooltip. Los niveles de capa aparecen en negrita y sus iconos aumentan de tamaño.
7. Demoler ocupa un botón cuadrado de 64×64 con el PNG `assets/ui/demolish_tower_icon.png` dibujado en un `TextureRect` fijo de 36×36. El PNG de alta resolución no se asigna como icono intrínseco del botón para que su tamaño fuente no infle el control ni la altura automática del panel. El marco 9-slice del panel y el icono/estilos del botón quedan editables en la escena `game/main/main.tscn`.

## Consecuencias

- La vista previa por entrada describe la asignación de enemigos de la ronda que el jugador tiene seleccionada, incluyendo una expansión candidata válida. El tooltip no promete habilidades o variantes de invocación; enumera los `EnemyData` de la composición directa.
- El nivel principal empieza en `0 DE 45` porque representa mejoras compradas de las 45 posibles. Los niveles 0–15 de Health, Armor y Shield siguen siendo independientes.
- La barra de experiencia comunica proporción y progreso restante sin repetir las cifras en el panel; el tooltip del botón de mejora conserva acceso a los números exactos.
- Se conserva el arte de las sombras ya pintado dentro de PNGs; solo desaparecen las elipses y trazos de sombra generados en runtime.
- Falta revisar la legibilidad, el orden de dibujo y la interacción en ventana a 1280×720 y 1440×900.

## Validación pendiente

Seguir la revisión manual M23 en [Aceptación](../design/10_ACCEPTANCE_TESTS.md). No se han ejecutado pruebas ni inspección en ventana para este cambio.

## Referencias

- [ADR-0046: progresión de mejoras y feedback de selección](ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md).
- [ADR-0047: herramientas de depuración y claridad de selección](ADR-0047-herramientas-de-depuracion-y-claridad-de-seleccion.md).
- [ADR-0048: HUD, oleadas, cards y paredes texturizadas](ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md).
