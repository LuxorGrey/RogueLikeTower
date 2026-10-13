# Terreno y props

Los PNG activos de terreno, fachadas, obstáculos, portal y cofre están en [`assets/pixel_art/terrain/`](../pixel_art/terrain/) y se centralizan en `game/board/terrain_visual_catalog.gd`.

Las nueve tapas de Path/Grass/Mountain miden 180×208 px y se dibujan a aproximadamente 90×104 unidades: encajan con la cara pointy-top de radio 52. Las fachadas se mapean por arista visible a los quads de elevación. Los cinco obstáculos usan una caja común de 86×86; cofre y portal tienen tamaños propios.

Las variantes pixel art actuales conservan transparencia y muestreo nearest. Las copias raster antiguas y sus sidecars de importación se retiraron de esta rama por [ADR-0057](../../docs/rogue_tower/decisions/ADR-0057-assets-pixel-art-activos-y-encaje-hexagonal.md). Los assets Tiny Swords siguen en `assets/third_party/tiny_swords/` de acuerdo con su licencia.
