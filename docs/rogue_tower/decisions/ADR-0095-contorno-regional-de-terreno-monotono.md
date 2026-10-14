# ADR-0095: Contorno regional de terreno de un solo tono

- **Estado:** aceptado por petición explícita del usuario; código/documentación integrados, aceptación visual pendiente.
- **Fecha:** 2026-10-14.
- **Alcance:** stroke regional de las tapas de terreno en tablero, copias elevadas, previews y miniaturas.
- **Nombre canónico:** **contorno de región de terreno** (clase runtime `TerrainRegionOutline`).

## Contexto

El contorno anterior dibujaba una línea oscura más ancha debajo del stroke de terreno. El resultado parecía tener un reborde exterior y una franja interior más clara. El usuario pidió un aspecto más oscuro y uniforme e indicó tonos exactos para Grass y Mountain.

## Decisiones

1. Se conserva la agrupación por `(terrain_type, elevation)`, la malla axial compartida, la omisión de aristas internas y los extremos/uniones redondeados. Estas reglas geométricas de ADR-0091 siguen vigentes.
2. El **contorno de región de terreno** se dibuja con un solo stroke opaco por arista, sin keyline exterior ni segunda línea o relleno de otro color. Grass usa `#406e4d`; Mountain usa `#646567`.
3. Path conserva el amarillo configurado. El hover puede variar la opacidad, pero mantiene el mismo RGB de cada terreno.
4. No se modifican las texturas de las tapas, el sombreado de fachadas, la cámara ni la geometría hexagonal.

## Consecuencias

- Las regiones siguen conectándose visualmente sin retícula interior, pero sus bordes son más oscuros y uniformes.
- Tablero, superficie elevada, hover y miniaturas continúan usando el mismo helper para evitar diferencias entre vistas.
- La apariencia debe aceptarse visualmente en Godot; el cambio no se considera validado solo por integrar el código.

## Sustituye

El color/keyline de ADR-0091, ADR-0093 y ADR-0094 queda sustituido parcialmente. Se conservan su agrupación, límites, geometría y uniones redondeadas.
