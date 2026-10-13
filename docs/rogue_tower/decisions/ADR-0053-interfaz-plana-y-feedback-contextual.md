# ADR-0053: Interfaz plana y feedback contextual

- Fecha: 2026-10-10.
- Estado: implementación integrada; smoke y arranque de escena aprobados con Godot 4.7; aceptación visual en ventana pendiente.
- Contexto relacionado: [ADR-0038](ADR-0038-base-sprite-y-feedback-del-hud.md), [ADR-0045](ADR-0045-auditoria-torres-y-feedback-visual.md), [ADR-0048](ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md), [ADR-0049](ADR-0049-arquitectura-hibrida-ui-editable.md), [ADR-0050](ADR-0050-recursos-visuales-ui-en-inspector.md), [ADR-0051](ADR-0051-navegacion-prevision-portales-y-panel-torre.md) y [ADR-0052](ADR-0052-numeros-de-dano-animados-y-legibles.md).
- Sustituye parcialmente: el aspecto de marco/textura de los botones de ronda, cards de terreno, tarjetas de torre y Tower Info de ADR-0048/0050/0051. Conserva su jerarquía, contenido y acciones, salvo tamaño de tarjeta descrito abajo.

## Contexto

El jugador ya recibe varias señales útiles: daño por Health/Armor/Shield con énfasis de crítico, estados sobre enemigos, barra segmentada de la base, ghost verde/rojo, precio/estado de compra, XP y progreso por torre, Gold animado, previsión de ronda y composición por portal. Añadir sistemas paralelos de números, alertas grandes o paneles persistentes duplicaría información y cubriría el tablero.

La auditoría encontró huecos: el preview de torre no explicaba por texto por qué una celda era inválida; Tower Info describía coste de Mana pero no hacía evidente que un ataque estaba pausado; una pérdida de vida de la base solo actualizaba su relleno/valor; Ballista/Mortar carecían de señal visual en el instante de lanzamiento y sus proyectiles no dejaban una dirección visual clara. Además, los paneles y tarjetas mezclaban texturas enmarcadas, bordes y radios, y la tienda tenía una fila panel dentro del panel principal. La tienda terminal todavía informaba `/20` aunque el diseño vigente define 45 rondas.

## Decisiones

1. Los paneles, tarjetas y tooltips usan superficies rectangulares planas del Theme compartido, sin radios, bordes decorativos o marcos PNG. Los estados normal/hover/pressed/disabled cambian el relleno y mantienen una diferencia visible. El botón de acción primaria de ronda conserva jerarquía mediante color, no textura. La barra de HUD continúa sin fondo compartido.
2. Cards de terreno conservan sus previews, conteos y estado de selección, pero el área de acción usa rellenos planos. Las siete cards de torre conservan icono, nombre, precio, bloqueo y estado activo en 132×132 px; se libera algo de altura y anchura del tablero.
3. Las cards de mejora conservan rareza, título y descripción. Una línea izquierda de 3 px comunica rareza sin volver al marco alrededor de toda la tarjeta. Las filas de la tienda terminal dejan de pintar superficies repetidas dentro de su panel contenedor.
4. Durante construcción, `BuildStatus` responde al hover con «Posición válida» o el error real que devuelve `BuildController.get_placement_error()`. El ghost y el cursor mantienen sus estados existentes. La confirmación muestra el coste dinámico real capturado antes de construir; no aparece otro popup.
5. Ballista y Mortar reciben un destello de salida local al crear con éxito un proyectil. Bolt y shell dibujan una estela corta alineada con su rumbo. La recuperación gráfica escala la torre hasta un 2,5 % de forma breve. No se crea pre-ataque, retraso, nueva colisión, cambio a proyectil hitscan, alteración de cadencia/velocidad/daño ni VFX de impacto adicional.
6. Si el gasto de Mana bloquea el ataque de la torre seleccionada, Tower Info agrega el texto «Ataque pausado · falta Mana». La señal depende de `Tower.is_mana_blocked()` y no se muestra como una alerta global.
7. Al recibir daño la base, su barra dibuja un contorno rojo transitorio de 0,24 s. El contador y segmentos siguen representando los datos de `Base`; el efecto no cambia Health, invulnerabilidad o resultado.
8. Ofertas de expansión/mejora, tienda terminal y paneles de depuración/tooltip son excluyentes durante su transición. Abrir una oferta, comenzar combate o cerrar una run oculta los overlays temporales previos. `F3` y `Ctrl+K` no abren paneles encima de la oferta obligatoria o tienda. Al pasar a colocación se conserva el flujo existente.
9. La tienda terminal usa `/45`, como la campaña confirmada. No se importan los antiguos 20 encuentros descritos en documentación histórica.
10. Los números actuales de daño siguen siendo el único indicador numérico de impactos a enemigos. Las referencias externas de [game feel y UX](../references/02_gamefeel_yux.md) solo inspiran legibilidad, feedback oportuno e información bajo demanda; no definen balance ni reglas propias.

## Consecuencias

- El jugador obtiene causa textual del rechazo en el propio HUD sin una ventana modal; los iconos/colores continúan acompañando el estado y el control de ratón.
- Proyectiles y ataques con coste de Mana comunican el evento/estado cuando el jugador lo necesita, sin añadir una capa de efectos sobre toda la pantalla.
- La interfaz comparte una sola geometría y lenguaje de estados; se mantienen el mundo, las texturas de terreno y las ilustraciones de gameplay. Los PNG decorativos de botones/panel/card dejan de usarse en estas escenas, pero no se borran del repositorio.
- Las tarjetas de torre ocupan menos espacio que antes. Debe comprobarse legibilidad de iconos y textos en las resoluciones de aceptación.
- Cambios de código solo presentan estado calculado por los sistemas existentes. No se modifican reglas ni datos de run.

## Verificación

- `tests/ui_migration_smoke.tscn`: aprobado con Godot 4.7, código 0 y salida `UI migration smoke: PASS`. `game/main/main.tscn`: arranque headless durante 10 iteraciones sin errores de carga/parseo. El host avisó que el certificado raíz del sistema y el guardado `user://` no estaban disponibles.
- Revisión manual a 1280×720 y 1440×900: pendiente; ver M25 en [Aceptación](../design/10_ACCEPTANCE_TESTS.md).
- La inspección por captura de ventana no estuvo disponible en esta sesión; el host no expone aplicaciones nativas a la herramienta de captura. La revisión interactiva sigue pendiente.
- `git diff --check`: aprobado sin errores de whitespace.

## Referencias

- [Referencias comparativas de game feel y UX](../references/02_gamefeel_yux.md), consultadas el 2026-10-10.
- [Feedback de daño animado](ADR-0052-numeros-de-dano-animados-y-legibles.md).
- [Godot 4.7: Custom drawing in 2D](https://docs.godotengine.org/en/4.7/tutorials/2d/custom_drawing_in_2d.html).
