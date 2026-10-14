# ADR-0075: Panel único y aura de rareza para upgrade cards

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; ampliado por [ADR-0080](ADR-0080-sprite-vertical-y-tier-de-upgrade-cards.md), aceptación visual pendiente.
- Sustituye la distinción de fondos y marcos de Upgrade Cards de [ADR-0065](ADR-0065-panel-y-iconos-de-upgrade-cards.md) y [ADR-0071](ADR-0071-marco-de-cards-y-colocacion-automatica.md). Mantiene sus iconos y el resto de decisiones de esos ADR.

## Contexto

Las texturas de borde y los fondos por rareza se veían recargados y poco legibles en las ofertas de mejoras cada tres rondas.

## Decisiones

1. Todas las rarezas usan una sola escena y la misma superficie de tarjeta. El requerimiento posterior de un sprite vertical común, etiqueta de tier y separación se registra en ADR-0080.
2. La rareza se comunica mediante el color del aura alrededor del panel; el hover aumenta su intensidad sin crear una variante de superficie.
3. Icono, título y descripción mantienen sus posiciones y usan el espacio interior del panel. Los iconos de efecto no cambian.
4. Las imágenes PNG anteriores de marco y fondos de rareza dejan de formar parte del catálogo/runtime; el único sprite compartido posterior está definido en ADR-0080.

## Consecuencias

- `UpgradeOfferCard` ya no depende de la rareza para elegir textura ni necesita los sprites de `CardFrame`/`TierBackground`.
- Los colores de aura son configuración visual interna del componente; rarezas y pesos del catálogo de cartas no cambian.
- La aceptación visual en ofertas de tres a seis opciones y textos largos queda pendiente en M34 de `10_ACCEPTANCE_TESTS.md`.

## Referencias

- Petición explícita del usuario, 2026-10-14.
- [ADR-0065](ADR-0065-panel-y-iconos-de-upgrade-cards.md) y [ADR-0071](ADR-0071-marco-de-cards-y-colocacion-automatica.md), decisiones anteriores de presentación, consultadas el 2026-10-14.
