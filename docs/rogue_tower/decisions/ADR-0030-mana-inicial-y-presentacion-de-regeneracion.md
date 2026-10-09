# ADR-0030: Maná inicial y presentación de la regeneración

- Estado: aceptada para implementación; balance provisional.
- Fecha: 2026-10-08.
- Alcance: perfil de economía M9 y presentación de accesibilidad de los atajos de torre.

## Contexto

El perfil M9 comenzaba con 30 de 100 maná y algunas mejoras mostraban tasas fraccionarias como `0,5` y `0,25` por segundo. Además, el contenido personalizado de los botones de torre mantenía sus colores aunque el botón estuviera deshabilitado por falta de oro.

## Decisiones

1. El perfil predeterminado inicia la run con su capacidad completa: 100/100 maná. `RunEconomyData.starting_mana` sigue siendo configurable y las bonificaciones de inicio se conservan; el cambio afecta al valor por defecto.
2. Las tasas runtime siguen siendo precisas y configurables. Las descripciones visibles expresan las fracciones como equivalencias enteras: 1,5 maná/s se presenta como 3 maná cada 2 s; 0,5 como 1 cada 2 s; 0,25 como 1 cada 4 s. No se redondea ni altera el cálculo de regeneración.
3. Los atajos de torre siguen deshabilitándose ante saldo insuficiente y ahora atenúan también el contenido personalizado (icono, nombre y precio). El tooltip explica que falta oro.

## Consecuencias

- El jugador empieza con recursos para desplegar torres consumidoras de maná sin esperar a regeneración.
- La representación de tasas evita decimales sin ocultar su equivalencia ni cambiar el balance efectivo.
- La falta de oro se comunica tanto por interacción como visualmente. La compra sigue validándose en `BuildController` antes de ocupar terreno.
- Los valores y costes de M9 continúan siendo provisionales. Ver la prueba manual M9/M13 de `10_ACCEPTANCE_TESTS.md`.

## Referencias

- [ADR-0013: Economía de run y maná M9](ADR-0013-economia-de-run-y-mana-m9.md).
- [Modelos de datos](../design/04_DATA_MODELS.md).
