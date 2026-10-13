# ADR-0058 — Arte Dirt en las texturas PATH

- **Fecha:** 2026-10-13
- **Estado:** aceptado e integrado
- **Contexto:** El lote artístico incluye Dirt_01/02/03, pero el proyecto no contiene una categoría Dirt ni destinos runtime Dirt. Las texturas Path existentes son los tres destinos de suelo equivalentes disponibles. El usuario indicó sustituir Path con Dirt y conservar el grafo y las flechas de ruta.

## Decisiones

1. Asignar Dirt_01/02/03, respectivamente, a `assets/terrain/tiles/path_01.png`, `path_02.png` y `path_03.png`.
2. Adaptar la máscara alfa de cada ilustración a la silueta hexagonal del PNG Path original y conservar las variantes bajo los nombres que ya carga `TerrainVisualCatalog`.
3. Mantener PATH como tipo lógico. No modificar sus sockets, topología, construcción, `PathGraph`, overlay ni flechas animadas.
4. Sustituir los otros veinte PNG del lote por sus equivalentes directos en las rutas runtime existentes y respaldar los 23 PNG originales bajo `art_generation/originals_replaced/2026-10-13/`.

## Consecuencias

- Las celdas PATH se ven como suelo Dirt genérico sin camino pintado. El recorrido se identifica con el overlay animado de flechas y los sockets interactivos existentes.
- No se crea una categoría Dirt ni se alteran reglas de terreno. La sustitución de los otros sprites conserva sus rutas, dimensiones y uso actuales.
- El arte instalado coincide píxel por píxel con las salidas documentadas; su canal alfa coincide con cada original respaldado. La inspección visual de la partida queda pendiente.
- El manifiesto y el [mapa completo de sustitución](../../../art_generation/replacement_map.md) registran las equivalencias y las copias de respaldo.

## Relación con decisiones anteriores

Esta decisión cambia únicamente la presentación de Path/Grass/Mountain descrita en [ADR-0040](ADR-0040-terreno-obstaculos-cofres-y-feedback.md) y [ADR-0041](ADR-0041-occlusion-arte-terreno-y-flujo-de-rutas.md). No sustituye sus reglas de terreno, generación, oclusión ni flujo de rutas.
