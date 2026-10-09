# ADR-0038: Sprite de base y feedback del HUD

- Fecha: 2026-10-09
- Estado: Aceptado por petición explícita del usuario; implementación integrada. El tamaño inicial de 112×112 fue ampliado por ADR-0039; la aceptación visual sigue pendiente.
- Ámbito: arte intercambiable de la base, lectura de recursos y botones de torre.
- Decisiones relacionadas: ADR-0026, ADR-0027, ADR-0031.

## Contexto

La base se dibujaba con polígonos dentro de `GameBase`, así que cambiar su aspecto exigía editar lógica. La vida de la base no indicaba bloques de 10, el HUD mostraba Mana fraccionario, y la barra de torres tenía un panel compartido detrás de todos los botones. Los cambios solicitados mantienen las reglas de combate y afectan la presentación, salvo el refill explícito de Mana al inicio de cada ronda.

## Decisiones

1. El aspecto de la base se carga desde `BaseData.sprite_texture` con un tamaño visual configurable. El PNG `assets/base/main_tower.png` es arte original generado para este proyecto; la huella lógica hexagonal permanece independiente y el recurso permite intercambiar la imagen sin modificar `GameBase`.
2. La barra de Health de base dibuja un segmento por cada 10 puntos, con el último segmento parcial cuando el máximo no es múltiplo de diez. El valor actual/máximo permanece centrado sobre la barra.
3. Al comenzar cada ronda de campaña, `RunEconomyService.refill_mana_to_max()` restaura Mana hasta su capacidad efectiva. La vista lo redondea a enteros, sin alterar precisión del saldo runtime.
4. Cada cambio no nulo de Gold anima el icono y la cifra mediante escalado y rebote vertical, tanto al ganar como al gastar.
5. Cada botón del roster tiene un marco PNG de estilo carta (`assets/ui/tower_card_button.png`). El control que alinea los botones es transparente y no dibuja un panel común.

## Consecuencias

- El sprite de la base se cambia en `data/base/base_data.tres` o en un `BaseData` alternativo; tamaño y huella no se infieren de la imagen.
- La presentación entera del Mana puede diferir del saldo fraccionario interno por redondeo; costes y regeneración continúan usando el valor preciso.
- La barra inferior ocupa el mismo espacio de HUD, pero ahora cada botón tiene contraste y estados propios a través de su textura de nueve cortes.
- La aceptación de legibilidad, rebote, segmentación y encaje en 1280×720/1440×900 sigue pendiente de revisión manual en Godot; ver M13 en `design/10_ACCEPTANCE_TESTS.md`. ADR-0039 amplía el sprite configurable de la base y añade la presentación detallada de torres.

## Fuentes

- Petición directa del usuario en la sesión del 2026-10-09.
- `assets/base/main_tower.png` y `assets/ui/tower_card_button.png`, arte original generado para el proyecto el 2026-10-09.
