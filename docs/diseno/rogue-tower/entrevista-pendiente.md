# Entrevista de diseño: decisiones vigentes y preguntas

Esta página registra decisiones del usuario; las reglas técnicas detalladas se enlazan a su fuente canónica. «Rogue Tower» es el nombre de trabajo.

## Decisiones vigentes

| Tema | Decisión | Pendiente |
|---|---|---|
| Partida | 20 rondas, mini-jefes 5/10/15, jefe final 20; objetivo 30–45 min. Base 20 de integridad; fuga normal 1 daño y fuga de jefe letal. | Ajustar con balance. |
| Terreno | Se adopta como verdad absoluta la especificación DOCX del usuario: chunks 3×3, nueve datos de celda, tipos PATH/GRASS/STONE, cuatro puertos, lógica separada de la vista. | Véase [sistema de losetas](sistemas/sistema-losetas-isometricas.md); balance STONE y catálogo quedan abiertos. |
| Construcción | PATH no construible; GRASS/STONE construibles si libres; una ocupación por celda. | Catálogo de defensas y costes. |
| Vista | 2D isométrica fija 2:1 en Godot 4.7; recursos TileSet/TileMapLayer como presentación. | Ajuste visual a huellas reales de PNG y cámara. |
| Topología | Cuadrícula ortogonal de chunks; rotación 90°, sin reflejos; validar todos los vecinos y rutas antes de confirmar. | Vectorizar los patrones de referencia A–Y. |
| Economía | Oro y maná separados; XP persiste para metaprogresión. | Cantidades, regeneración, costes y progresión. |
| Fase | Construir/mejorar durante preparación; se bloquea en combate. | Detalles de UI y tutorial. |
| Referencias | *Rogue Tower* es el baseline general de gameplay; adaptaciones expresas del usuario prevalecen. Carcassonne inspira únicamente la adyacencia/topología, no el arte. | Mantener atribución y resolver diferencias de versión. |
| Assets | PNG CellTile proporcionados por el usuario, inventariados en `assets/CellTile/README.md`. | Confirmar licencia de distribución antes de publicar una build. |
| Mantenimiento | Cada cambio actualiza los documentos dependientes. | Norma registrada en `AGENTS.md`. |

## Reglas anteriores sustituidas

La documentación antigua indicaba volumen CellTile 3×3×3, terreno `dirt`, `path_variant_1`, escenas prefab por pieza, posiciones de montaña y bonificaciones por monasterio. Esas reglas no son vigentes para la creación de terreno. Se conservan como historia en los ADR sustituidos; [ADR-0013](decisiones/ADR-0013-sistema-de-losetas-isometricas.md) registra el cambio.

## Entrevista pendiente

1. ¿Qué patrones A–Y se implementan primero y con qué conectividad interna vectorizada?
2. ¿Qué regla de oferta y mapa inicial se aplica junto a la expansión por chunks?
3. ¿Qué balance, progresión persistente, pool de cartas y catálogos entran en la beta?
4. ¿Qué cámara, navegación y opciones de accesibilidad se desean?

## Exportación de Rogue Tower Wiki

El usuario pidió un dossier completo de artículos y tablas, no solo una síntesis. La wiki cuenta con 99 artículos según el inventario de referencia existente. La extracción/reconciliación de páginas, tablas, enlaces, fecha y discrepancias de changelog continúa pendiente; las cifras de referencia no se convierten automáticamente en balance del proyecto. La licencia indicada por la wiki debe conservar atribución donde corresponda. Ver [índice y cobertura](referencias/indice-y-cobertura.md) y [dossier de referencia](referencias/rogue-tower-wiki.md).
