# ADR-0120 — Control de velocidad de la partida

- Fecha: 2026-10-15.
- Estado: código y documentación integrados; aceptación visual e interactiva pendiente.
- Decisiones relacionadas: ADR-0061 define pausa; ADR-0112 fija el botón de pausa junto a la vida.

## Contexto

El jugador necesita acelerar oleadas y tiempos de espera de una run de tower defense sin alterar las reglas de combate ni cambiar de escena.

## Decisiones

1. Añadir un botón junto a Pausa en la fila de vida del HUD. Su texto muestra el multiplicador activo y alterna en este orden: ×1 → ×2 → ×3 → ×1.
2. Aplicar el multiplicador global con `Engine.time_scale`, para que procesos, física y temporizadores de gameplay avancen según la velocidad elegida.
3. La pausa modal detiene el gameplay y cubre los controles del HUD; conserva el multiplicador seleccionado para cuando la partida se reanude.
4. Empezar cada run en ×1 y restaurar ×1 cuando la escena de run sale del árbol, evitando filtrar la velocidad al menú o a otra escena.

## Consecuencias

- El jugador puede acelerar el ritmo de la partida desde el HUD y ver el valor activo en todo momento.
- Las animaciones y temporizadores que usan el reloj de juego también avanzan más rápido; la pausa conserva el valor elegido sin permitir interacción con los controles cubiertos del HUD.
- Falta inspección visual e interactiva en Godot; no se ejecutó el motor ni se añadieron pruebas.

## Implementación

- `game/ui/game_speed_button.gd`
- `game/main/main.tscn`
- `game/main/main.gd`
- `docs/rogue_tower/design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md`
- `docs/rogue_tower/design/03_TECHNICAL_ARCHITECTURE.md`
- `docs/rogue_tower/design/09_PROGRESS.md`
- `docs/rogue_tower/design/10_ACCEPTANCE_TESTS.md`
