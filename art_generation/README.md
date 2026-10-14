# Reestilización de arte para Rogue Tower

> **Histórico:** este paquete registra la integración de arte del 2026-10-13. El pool de obstáculos y los props activos cambiaron en M39. La autoridad de contenido/rutas/dimensiones vigente está en [assets/sprites/terrain/README.md](../assets/sprites/terrain/README.md); los archivos de esta carpeta son fuentes, respaldos y materiales de proceso.

Este paquete documenta la dirección artística y la sustitución de los 23 PNG solicitados por sus equivalentes nuevos en las rutas runtime existentes.

## Estado

1. Las cinco muestras representativas fueron aprobadas por el usuario el 2026-10-13; después se generaron las otras 18 piezas.
2. Ese lote de 23 sprites quedó instalado en 2026-10-13 y sus originales se conservaron en `originals_replaced/2026-10-13/`; M39 reemplazó después los obstáculos.
3. El verificador conserva la comparación de ese lote histórico para los destinos que no se sustituyeron en M39.
4. El único mapeo entre categorías es explícito: Dirt_01/02/03 reemplazan el arte de Path_01/02/03. La topología PATH, sockets, grafo y flechas se mantienen.
5. La integración de 2026-10-13 no cambiaba código, escenas ni Resources. M39 integra código y assets nuevos; consulta la documentación vigente enlazada arriba. La revisión visual dentro del runtime queda abierta.

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
