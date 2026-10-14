# ADR-0072: Controles y tooltip compacto de celdas

- Fecha: 2026-10-14
- Estado: Aceptado e implementado; M55 sustituye parcialmente la decisión de rueda. Aceptación visual/interactiva pendiente.
- Actualiza los controles de colocación de [ADR-0071](ADR-0071-marco-de-cards-y-colocacion-automatica.md).

## Contexto

La asignación de auto-colocación a Q desplazó la rotación manual que ya usaba ese atajo. El jugador también necesita entender el tipo de superficie, su ocupación y el beneficio de construir en altura sin abrir el panel técnico.

## Decisiones

1. `Q` gira 60° en sentido antihorario y `E` 60° en sentido horario durante una colocación.
2. Regla histórica de M33: la rueda giraba la pieza durante colocación. M55 la sustituye: la rueda sin modificador siempre controla el zoom, también durante colocación; `Ctrl+rueda` gira la pieza. `Q`/`E` siguen girando en ambas direcciones.
3. `T` ejecuta la auto-colocación validada y mantiene el aviso visible en la fase de expansión. Las validaciones de geometría, grafo y continuación PATH no cambian.
4. Si no hay torre seleccionada ni pieza en colocación, el hover muestra un tooltip pequeño, junto al puntero, con terreno, estado de construcción y altura. Para Grass/Mountain calcula el bonus de daño y alcance desde los perfiles compatibles de `TowerData`; en PATH indica que es ruta y no admite torres.
5. El tooltip no aparece sobre la interfaz, una selección activa de torre/objeto/pieza ni cuando otro panel contextual está activo. Es visual únicamente y no modifica reglas de terreno ni construcción.

## Consecuencias

- La rotación manual vuelve a ser inmediata y la opción automática queda en un atajo separado.
- El comportamiento de la rueda descrito originalmente aquí quedó reemplazado por M55/ADR-0105.
- Altura y bonus se muestran con los valores efectivos de las torres compatibles; el tooltip evita tapar el tablero y no compite con paneles de selección.
- La aceptación visual/interactiva queda pendiente en M33 de `10_ACCEPTANCE_TESTS.md`.

## Verificación

No se ejecutaron pruebas ni se hizo inspección visual durante esta actualización.
