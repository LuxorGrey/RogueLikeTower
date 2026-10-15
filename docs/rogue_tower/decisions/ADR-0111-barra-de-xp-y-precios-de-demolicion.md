# ADR-0111: Barra de XP y precios de demolición

- Fecha: 2026-10-15
- Estado: Implementado en código; aceptación visual pendiente.
- Refina: la presentación de mejoras y demolición descrita en [ADR-0107](ADR-0107-feedback-de-progresion-y-presentacion-de-cards.md) y [ADR-0110](ADR-0110-mejoras-de-capa-en-fila-y-shake-de-ronda.md). Mantiene el cálculo económico de reembolso aprobado por [ADR-0064](ADR-0064-reembolso-al-demoler-torres.md).

## Contexto

La barra de XP de `TowerLayerUpgradeButton` era demasiado fina y se extendía por todo el ancho de la card. Los botones de demolición usaban principalmente el icono, por lo que no dejaban claro el nombre de la acción ni el importe que se cobraría o devolvería.

## Decisiones

1. `XPBar` mide `88 × 8` unidades y usa alineación de encogimiento centrada. Es más gruesa y ocupa menos ancho que la barra anterior.
2. La acción sobre torres muestra el icono de demolición, el texto `DEMOLER` y un panel de Gold con `+<importe>` cuando hay una torre seleccionada. El valor se obtiene de `BuildController.get_demolition_refund()`; no se recalcula ni se altera la regla de reembolso.
3. La acción sobre obstáculos muestra el icono, el texto `DEMOLER` y el coste actual de retirada como `−<importe>` con el icono de Gold.
4. La acción sobre portales conserva el verbo `RETIRAR` y muestra su coste como `−<importe>` con icono de Gold, que sigue siendo el doble del coste actual de retirar un obstáculo.

## Consecuencias

- El jugador puede leer de un vistazo la progresión de XP de capa y la longitud de la barra no domina la card.
- Antes de confirmar una retirada, el jugador ve si pagará Gold o recibirá Gold.
- La economía, las curvas progresivas, las restricciones de fase y el mínimo de portales activos permanecen sin cambios.
- La aceptación visual/interactiva queda pendiente.

## Fuentes

- Solicitud del usuario en Codex, 2026-10-15.
- Implementación en `game/ui/components/tower_layer_upgrade_button.tscn`, `game/main/main.tscn` y `game/main/main.gd`, 2026-10-15.

## ADR sustituidos

- Ninguno. Este ADR refina la presentación sin sustituir la regla de reembolso de ADR-0064.
