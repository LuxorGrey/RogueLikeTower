# ADR-0098 — Ajuste de grosor del outline y contorno permanente de portales

- Fecha: 2026-10-14.
- Estado: integrado en código; aceptación visual pendiente.
- Contexto: el outline blanco de la base necesitaba reducirse y el de los enemigos ganar un poco de presencia. Los portales debían conservar su acento de hover y, además, mostrar el contorno blanco interactivo de forma permanente, igual que los obstáculos.

## Decisión

1. Reducir `outline_size_px` de `GameBase` de 12 a 6, manteniendo el shader compartido y el color blanco.
2. Aumentar `outline_size_px` de los enemigos de 1.5 a 2.0, conservando la paleta clara por `EnemyData.id` y la sincronización de su capa con el sprite.
3. Añadir a cada portal una capa outline-only permanente con `interactable_outline.gdshader`, color blanco y `outline_size_px = 3.0`, el mismo valor usado por obstáculos. La capa acompaña el frame y la escala de pulsación del portal.
4. Mantener encima el resplandor temporal que marca hover, candidato y cierre previsto; el nuevo borde blanco no sustituye esas señales.

## Consecuencias

- Base, torres, obstáculos y portales usan el mismo estilo de dilatación alfa blanca; los enemigos comparten el shader con su color por tipo.
- El contorno del portal se ve durante toda la partida y no cambia la interacción, el tamaño del hitbox ni la animación desfasada.
- Queda pendiente validar en ventana el grosor, el recorte de alfa durante el loop y la convivencia entre el borde blanco y el resplandor de hover.

## Fuentes y alcance

- Implementación: `game/main/game_base.gd`, `game/enemies/enemy.gd`, `game/board/spawn_portal.gd` y `game/board/interactable_outline.gdshader`.
- Refina los grosores definidos en [ADR-0097](ADR-0097-outline-de-base-y-enemigos.md) y extiende su contorno a los portales. No sustituye otras decisiones.
