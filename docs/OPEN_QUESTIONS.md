# Decisiones y preguntas pendientes

## Confirmado

- Proyecto objetivo: Godot 4.7; juego 2D isométrico fijo 2:1.
- La especificación adjunta es la fuente de verdad para crear terreno. Ver [sistema de losetas](diseno/rogue-tower/sistemas/sistema-losetas-isometricas.md) y [ADR-0013](diseno/rogue-tower/decisiones/ADR-0013-sistema-de-losetas-isometricas.md).
- ChunkGrid compuesto por chunks 3×3 exactos; terrenos PATH, GRASS y STONE; datos lógicos separados de TileMapLayer.
- Puertos N/E/S/W en el centro de cada lado; validación con cada vecino y rutas construidas solo por PATH.
- GRASS/STONE son construibles si están libres; PATH no. STONE tiene altura inicial 1 y multiplicador de alcance configurable, con 1.15 como valor inicial.
- El juego objetivo conserva veinte rondas; mini-jefes en 5/10/15 y jefe final en 20.

## Pendiente

1. Balance final del multiplicador de alcance de STONE, cuyo valor inicial 1.15 no es cifra definitiva.
2. Catálogo y pesos de chunks A–Y tras vectorizar sus conexiones desde las referencias aportadas.
3. Frecuencia de oferta, reglas de partida inicial y cómo se combinan la base y el primer camino con los chunks.
4. Economía, roster/balance, cartas, progresión persistente y controles/accesibilidad.
5. Licencia de los PNG de CellTile antes de distribuirlos dentro de una build.

La transformación visual exacta de cada PNG, las coordenadas del atlas y la técnica de orden de profundidad se deben validar en la implementación con las dimensiones de los assets actuales; no alteran la fuente lógica del terreno.
