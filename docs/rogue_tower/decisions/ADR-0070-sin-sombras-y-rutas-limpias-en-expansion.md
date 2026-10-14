# ADR-0070: Sin sombras generadas y rutas limpias durante expansión

- Fecha: 2026-10-13
- Estado: Aceptado por petición explícita del usuario; código integrado, aceptación visual pendiente.
- Sustituye: la parte de sombras de [ADR-0066](ADR-0066-cofres-al-colocar-y-sombras-de-elevacion.md) y toda la implementación de sombras de [ADR-0068](ADR-0068-sombras-recortadas-por-elevacion.md). Mantiene la regla visual base de [ADR-0054](ADR-0054-tipografia-global-y-sin-sombras-de-codigo.md).

## Contexto

El usuario pidió borrar el script usado para generar sombras y dejar el videojuego sin sombras por ahora. También indicó que, al elegir una loseta de expansión, el camino y sus trazos se ven confusos.

## Decisiones

1. Eliminar `TerrainShadowOverlay`, su shader y archivos UID, sus referencias en `TerrainPiecePreview` y toda proyección de sombras generada por código para terreno u obstáculos. No se sustituyen por otro renderer.
2. El hover de terreno conserva el contorno de selección, pero no dibuja sockets PATH sobre las caras.
3. Mientras hay una pieza de expansión seleccionada para previsualizar/colocar, se ocultan las flechas de flujo PATH y las polilíneas de diagnóstico. Al cancelar/confirmar se restaura el flujo normal del tablero.
4. La altura continúa leyéndose con el desplazamiento visual, fachadas y oclusión Y-sort. El bonus de combate se expone en Tower Info según ADR-0069.

## Consecuencias

- No quedan scripts, shaders ni referencias runtime que dibujen sombras.
- Se conservan las texturas originales como arte del terreno y los obstáculos, pero no se añaden imágenes auxiliares, shaders ni proyecciones para representar sombras.
- El grafo y la simulación PATH no cambian; solo se oculta su feedback visual durante el preview de expansión.
- Falta inspeccionar la ausencia de sombras y el retorno de las flechas tras confirmar/cancelar en ventana.
