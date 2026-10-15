# ADR-0110: Mejoras de capa en fila y shake de ronda

- Fecha: 2026-10-15
- Estado: Implementado en código; aceptación visual pendiente.
- Refina: la disposición de los botones H/A/S descrita en [ADR-0107](ADR-0107-feedback-de-progresion-y-presentacion-de-cards.md).

## Contexto

Los botones de mejora de Health, Armor y Shield ocupaban una columna en el panel de acciones de torre. El precio de cada botón no compartía el panel visual de `TowerShortcutCard`. Además, faltaba una señal visual ligera para indicar que una ronda estaba activa.

## Decisiones

1. `UpgradeRow` pasa a ser una fila horizontal centrada con tres botones H/A/S de `128 × 128` unidades, de modo que cada botón es cuadrado y conserva su tamaño al repartirse el ancho.
2. `TowerLayerUpgradeButton` presenta icono de coste y cantidad dentro de un `PanelContainer` que reutiliza `gold_panel_style.tres`, las dimensiones y la composición de `TowerShortcutCard`.
3. Al recibir `wave_started`, `Main` inicia una sacudida ambiental de cámara de baja amplitud. Se detiene inmediatamente en `wave_completed` o `wave_failed`.
4. La sacudida ambiental y el impulso de daño a base se componen como offsets separados; el shake continuo no reemplaza ni cancela el feedback de daño ya existente.

## Consecuencias

- Las tres mejoras se ven juntas y el panel usa menos altura que la disposición vertical.
- Los precios de torre y los costes H/A/S comparten el mismo lenguaje visual.
- La cámara transmite actividad mientras hay combate y recupera el offset base al acabar la ronda.
- La aceptación visual/interactiva queda pendiente.

## Fuentes

- Solicitud del usuario en Codex, 2026-10-15.
- Implementación de `main.tscn`, `tower_layer_upgrade_button.tscn` y `main.gd`, 2026-10-15.
