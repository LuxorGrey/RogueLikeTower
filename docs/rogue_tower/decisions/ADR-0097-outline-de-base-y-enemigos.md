# ADR-0097 — Outline de base y enemigos

- Fecha: 2026-10-14.
- Estado: integrado en código; grosores refinados por [ADR-0098](ADR-0098-ajuste-de-outline-y-contorno-de-portales.md); aceptación visual pendiente.
- Contexto: torres y obstáculos ya usan `interactable_outline.gdshader`, mientras que la base no tenía contorno y los enemigos pintaban sus sprites manualmente. Hace falta conservar el mismo trazo alfa sin interferir con animación, barras ni orden de profundidad.

## Decisión

1. Reutilizar `interactable_outline.gdshader` para el sprite de `GameBase`, con contorno blanco como el de las torres y obstáculos.
2. Añadir al mismo shader el modo `outline_only`, que dibuja solo la dilatación del alfa y deja el relleno al sprite del enemigo.
3. Cada `Enemy` añade una capa `Sprite2D` detrás de su dibujo, a partir de la misma textura, tamaño, orientación y desplazamiento vertical. El outline sigue el salto de impacto, el giro horizontal y las transformaciones de perfil.
4. Los perfiles de campaña y de diagnóstico reciben un color claro por `EnemyData.id`, con tonos variados entre perfiles; los que no tengan color explícito usan un azul pálido. Los placeholders vectoriales usan la misma asignación de color.
5. La capa de outline no cambia el Y-sort del actor. Las barras de Health/Armor/Shield, los iconos de estado y el sprite original permanecen dibujados por encima.

## Consecuencias

- Base, torres y obstáculos comparten el trazo alfa blanco. Los enemigos conservan el mismo algoritmo de contorno con una paleta pastel diferenciada por tipo.
- Las texturas, el movimiento, la colisión, la selección y el combate no cambian.
- Falta aceptar en ventana el grosor, contraste por perfil y oclusión visual de enemigos delante y detrás de fachadas.

## Fuentes y alcance

- Implementación: `game/board/interactable_outline.gdshader`, `game/main/game_base.gd` y `game/enemies/enemy.gd`.
- Extiende parcialmente [ADR-0093](ADR-0093-preview-de-terreno-oferta-fija-y-torres-articuladas.md), que introdujo el outline para torres y obstáculos. No sustituye otras decisiones.
