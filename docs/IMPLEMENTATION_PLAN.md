# Plan de implementación

La arquitectura de terreno y sus criterios de aceptación están en [Sistema de losetas isométricas](diseno/rogue-tower/sistemas/sistema-losetas-isometricas.md). Se implementa en incrementos que dejan el proyecto ejecutable.

## 0. Proyecto y primera escena visible

- [x] Proyecto dirigido a Godot 4.7 y assets CellTile de referencia.
- [x] Especificación del usuario adoptada como fuente de verdad; GDD, ADR y guías sincronizados.
- [ ] Configurar la escena principal para mostrar un chunk isométrico formado al pulsar Play.
- [ ] Confirmar el resultado visual en Godot 4.7 y dejar instrucciones de ejecución en README.

## 1. Modelo de terreno

- [ ] `TerrainType`, `CellData`, `ChunkCellDefinition` y `ChunkDefinition` como datos de autoridad.
- [ ] Validar exactamente nueve celdas, alturas y puertos cardinales.
- [ ] Catálogo de variantes visuales por categoría, sin inferencia lógica desde los nombres en runtime.
- [ ] Resolución determinista de variantes por semilla y coordenada.

## 2. ChunkGrid, conectividad y rutas

- [ ] Almacenar chunks y sus orientaciones en un mapa lógico independiente de los TileMapLayer.
- [ ] Rotar celdas y puertos como una misma transformación de 90°.
- [ ] Validar puertos contra todos los vecinos existentes antes de confirmar una colocación.
- [ ] Construir/verificar el grafo PATH y rechazar extensiones que desconecten la ruta requerida.
- [ ] Mantener bordes sin vecino como posibles frentes de expansión.

## 3. Vista isométrica

- [ ] Crear TileSet isométrico con tamaño de celda y orígenes ajustados a las huellas CellTile.
- [ ] Dibujar el estado lógico con TileMapLayer y profundidad estable entre capas/chunks.
- [ ] Incorporar decoraciones solo como vista, sin autoridad de reglas.
- [ ] Añadir controles de cámara después de confirmar encuadre y lectura de la escena inicial.

## 4. Construcción y guardado

- [ ] Permitir construcción sobre GRASS/STONE libres y bloquear PATH/ocupación.
- [ ] Hacer configurable el multiplicador de alcance de STONE, inicialmente 1.15.
- [ ] Persistir semilla, IDs/orientaciones de chunks y estado de torres; reconstruir vista determinísticamente.

## 5. Juego y beta

- Oleadas, enemigos, combate, recursos, cartas y metaprogresión se incorporan conforme al GDD y a los ADR relacionados.
- Conservar el objetivo de 20 oleadas y todos los grupos de sistemas previstos para la beta con catálogos compactos.
