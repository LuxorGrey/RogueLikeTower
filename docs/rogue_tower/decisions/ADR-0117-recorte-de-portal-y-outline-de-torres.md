# ADR-0117 — Recorte del spritesheet de portal y outline de torres

- Fecha: 2026-10-15.
- Estado: código y documentación integrados; aceptación visual pendiente.
- Decisiones relacionadas: conserva la optimización de importación de ADR-0115 y refina el contorno compartido de ADR-0098.

## Contexto

ADR-0115 redujo la textura importada del portal a 768×384 px para conservar dos píxeles de textura por cada píxel de dibujo. `SpawnPortal` todavía usaba regiones fijas de 443×443 px, medidas de la imagen fuente de 1774×887. Esas regiones no coinciden con la textura ya reducida y recortan frames incorrectos. Además, las torres fijaban su outline blanco en 12 px, un grosor visual excesivo.

## Decisiones

1. Mantener intacto el PNG fuente y el límite de importación de 768 px.
2. Dividir la cuadrícula 4×2 calculando el tamaño de cada región a partir de `PORTAL_SPRITE_SHEET.get_size()`. El loop conserva los siete frames únicos a 10 FPS y omite el octavo, que repite el primero.
3. Reducir `outline_size_px` de los sprites de torre de 12 a 6, la mitad del grosor anterior. El shader, color, orientación, escala y orden del sprite permanecen iguales.
4. Añadir la comprobación visual de torres y frames del portal a M48.

## Consecuencias

- Cambiar el límite de importación no deja coordenadas de atlas desfasadas, siempre que se conserve la cuadrícula 4×2.
- La hoja de portal conserva su resolución importada optimizada y la animación usa regiones de 192×192 px.
- El contorno de torre conserva el estilo blanco existente con la mitad de grosor.
- Falta la revisión visual en una ventana Godot; no se ejecutaron pruebas automatizadas.

## Implementación

- `game/board/spawn_portal.gd`
- `game/towers/tower.gd`
- `assets/sprites/terrain/README.md`
- `docs/rogue_tower/design/10_ACCEPTANCE_TESTS.md`
