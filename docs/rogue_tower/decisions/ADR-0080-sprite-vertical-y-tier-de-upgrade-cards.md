# ADR-0080: Sprite vertical y tier visible en upgrade cards

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código integrado, aceptación visual pendiente.
- Amplía la presentación unificada de [ADR-0075](ADR-0075-panel-unico-y-aura-de-rareza.md); mantiene una única superficie común y los iconos de efecto.

## Contexto

El usuario quiere cards de mejora verticales con el tier escrito, espacio perceptible entre opciones y un aura de rareza. Debe seguir existiendo un diseño compartido por todas las rarezas.

## Decisiones

1. Todas las ofertas usan la misma textura PNG vertical `game/ui/cards/upgrade_card_universal.png`, escalada con nueve cortes para conservar el contorno al variar el tamaño.
2. La card muestra su tier/rareza en texto dentro de la cabecera. El aura exterior comunica la rareza mediante color e intensidad; icono, título y descripción conservan el tratamiento común.
3. Las cards se separan con un pequeño espacio y se agrupan centradas en la oferta. No se seleccionan paneles, bordes ni fondos distintos por rareza.
4. El aura cambia solo la presentación; no altera la rareza, el contenido, el peso ni el efecto de la carta.

## Consecuencias

- `UpgradeOfferCard` combina un sprite común NinePatch, etiqueta de tier e icono de catálogo; el panel transparente dibuja el aura y su realce al hacer hover.
- La aceptación visual en ofertas de tres y seis opciones, con textos cortos y largos, sigue pendiente en M36 de `10_ACCEPTANCE_TESTS.md`.

## Referencias

- Petición explícita del usuario, 2026-10-14.
- [ADR-0075](ADR-0075-panel-unico-y-aura-de-rareza.md), consultado el 2026-10-14.
