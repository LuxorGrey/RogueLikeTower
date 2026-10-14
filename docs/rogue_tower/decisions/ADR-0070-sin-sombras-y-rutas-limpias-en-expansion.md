# ADR-0070: Sin sombras generadas y rutas limpias durante expansión

- Fecha: 2026-10-13
- Estado: Sustituido parcialmente por [ADR-0099](ADR-0099-tinte-de-altura-y-sombra-animada-de-nubes.md): sigue vigente la retirada de sombras proyectadas por sprite y la limpieza de rutas durante preview; el nuevo velo de nubes procedural es una capa global distinta.
- Sustituyó la parte de sombras de [ADR-0066](ADR-0066-cofres-al-colocar-y-sombras-de-elevacion.md) y la implementación de [ADR-0068](ADR-0068-sombras-recortadas-por-elevacion.md). En su periodo vigente mantuvo la regla de sombras por sprite de [ADR-0054](ADR-0054-tipografia-global-y-sin-sombras-de-codigo.md); el alcance actual queda precisado por ADR-0099.

## Contexto

El usuario pidió borrar el script usado para generar sombras y dejar el videojuego sin sombras por ahora. También indicó que, al elegir una loseta de expansión, el camino y sus trazos se ven confusos.

## Decisiones

1. Eliminar `TerrainShadowOverlay`, su shader y archivos UID, sus referencias en `TerrainPiecePreview` y toda proyección de sombras individuales para terreno u obstáculos. No reintroducir sombras geométricas por sprite; el velo procedural global posterior está definido en ADR-0099.
2. El hover de terreno conserva el contorno de selección, pero no dibuja sockets PATH sobre las caras.
3. Mientras hay una pieza de expansión seleccionada para previsualizar/colocar, se ocultan las flechas de flujo PATH y las polilíneas de diagnóstico. Al cancelar/confirmar se restaura el flujo normal del tablero.
4. La altura continúa leyéndose con el desplazamiento visual, fachadas y oclusión Y-sort. El bonus de combate se expone en Tower Info según ADR-0069.

## Consecuencias

- No quedan scripts ni referencias runtime para sombras proyectadas individualmente; CloudShadowOverlay es una pasada global distinta, añadida después por ADR-0099.
- Se conservan las texturas originales y no se añaden sombras por sprite; el único shader de sombra actual es el overlay global de nubes descrito en ADR-0099.
- El grafo y la simulación PATH no cambian; solo se oculta su feedback visual durante el preview de expansión.
- Falta inspeccionar que el velo global de nubes no tape la UI y que las flechas PATH vuelvan tras confirmar/cancelar en ventana.
