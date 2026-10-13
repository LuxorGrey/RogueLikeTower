# Reestilización de arte para Rogue Tower

Este paquete documenta la dirección artística y la sustitución de los 23 PNG solicitados por sus equivalentes nuevos en las rutas runtime existentes.

## Estado

1. Las cinco muestras representativas fueron aprobadas por el usuario el 2026-10-13; después se generaron las otras 18 piezas.
2. Los 23 sprites están instalados. Los originales se conservaron en `originals_replaced/2026-10-13/`.
3. El verificador coteja los píxeles instalados con cada salida asignada y la alfa con el original preservado.
4. El único mapeo entre categorías es explícito: Dirt_01/02/03 reemplazan el arte de Path_01/02/03. La topología PATH, sockets, grafo y flechas se mantienen.
5. La integración no cambia código, escenas, Resources ni configuración de importación. La revisión visual de los sprites dentro del runtime queda abierta.

La dirección traduce el brief del usuario a un lenguaje visual propio para Rogue Tower: fantasía gótica dibujada a mano, contornos de tinta y color terroso. Don't Starve Together se usa como referencia verbal de alto nivel; no se incorporaron imágenes ni assets de ese juego.

Las tres piezas Dirt son propuestas nuevas porque no existían originales ni categoría Dirt en el catálogo. Se usó Grass_01 como proxy geométrico para generar su canvas y luego se ajustó el alfa de cada una a la silueta del Path equivalente, conforme a la decisión del usuario.

## Archivos

- [Mapa de sustitución de los 23 sprites](replacement_map.md)
- [Manifiesto técnico](asset_manifest.md)
- [Guía de estilo](style_guide/rogue_tower_art_direction.md)
- [Estado de referencias](references/README.md)
- [Galería de las cinco muestras](previews/sample_gallery.md)
- [Galería de los 23 assets](previews/full_asset_gallery.md)
- [Composición conjunta](previews/full_asset_composition.png)
- [Informe de validación](validation/final_validation.md)
- [Revisión de muestras](validation/sample_validation.md)
