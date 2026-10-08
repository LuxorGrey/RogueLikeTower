# ADR-0019 — Lectura visual de hexes, combos y base

- Estado: aceptado para el renderer placeholder, 2026-10-08.
- Contexto: las iniciales de terreno y coordenadas dibujadas en cada cara saturaban el mapa. La base provisional era un círculo pequeño dentro de una cara PATH, y el usuario pidió una lectura de hover, señal discreta de combos y una huella completa para la base.

## Decisiones

1. Las caras de terreno no dibujan letras ni coordenadas. El mapa comunica PATH/Grass/Montaña mediante sus colores y el hover conserva el highlight por terreno más la ficha HUD con `(q,r)`, tipo y altura.
2. Clusters hex-conectados de Grass o Montaña se detectan por componente: de 3–4 celdas reciben resplandor tenue de combo 3; de 5 o más, un poco más visible de combo 5. PATH no participa. El feedback es visual y no aplica todavía oro, stats, daño ni otra recompensa.
3. `GameBase` ocupa la cara hexagonal completa en su coordenada axial (radio visual igual al radio de terreno). La decoración del placeholder queda dentro de esa huella y no amplía la ocupación lógica.

## Consecuencias

- El hover HUD se vuelve la única lectura textual de una celda del mapa; los paneles técnicos F3 y el toggle de rutas D siguen disponibles.
- Los clusters también se reconocen cuando incluyen celdas auto-rellenadas, y el ghost permite previsualizar un combo potencial.
- El aspecto/animación del brillo y el arte final de la base son provisionales; la huella axial completa es el contrato confirmado.
