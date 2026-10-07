# CellTile

Sprites isométricos recibidos del usuario para su uso en RogueLikeTower.

Incluye diez variantes de césped (`grass1`–`grass10`), dos de tierra (`dirt2`, `dirt3`), dos caminos, una escalera, cuatro piedras y una hoja de bloques de naturaleza. Mantener estos originales sin sobrescribir; la escala, el punto de apoyo y el mapeo de cada sprite se definirán al crear el importador del juego.

## Mapeo pendiente

La hoja `spritesheet_nature-blocks.png` reúne variantes visuales. Antes de generar el tablero se debe fijar una tabla de sprite/atlas-rect → tipo de celda, orientación y altura. El arte representa; el modelo lógico determina caminos, bloqueos y reglas.
