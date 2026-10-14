# ADR-0102: Sprites completos de torre, escala y feedback

- **Estado:** aceptado e implementado en código; aceptación visual pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** los siete PNG de torre se sustituyeron por ilustraciones completas, pero `TowerArtCatalog` seguía recortando las coordenadas de las antiguas láminas de base/cañón. Esto encogía o cortaba el arte. Además, las torres de ataque rápido repetían demasiado el efecto `shoot`.

## Decisiones

1. Cada perfil canónico carga directamente su PNG completo desde `assets/sprites/ui/icons/`. `TowerArtCatalog` conserva una textura compartida cacheada por perfil, pero no recorta ni recompone regiones. El mismo recurso se utiliza en torre colocada, ghost, card de selección y Tower Info.
2. El centro del sprite coincide con el centro lógico de la celda y conserva un offset visual fijo de +8 px en Y. No se rota: el sprite completo solo usa espejo horizontal para apuntar al lado contrario. `TOWER_VISUAL_SCALE` sube a 1,44 y `TowerArtCatalog.DISPLAY_HEIGHT_MULTIPLIER` mantiene 1,12; mundo y ghost comparten el mismo cálculo. El icono de la card mide 126×126 px, la card 162×198 px y el retrato de Tower Info 152×176 px.
3. Las torres de fuego continuo (Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder) emiten el primer efecto `shoot` inmediatamente y luego limitan ese VFX con un intervalo aleatorio propio de 2,0–2,5 s. Ballista y Mortar conservan el efecto de cada disparo discreto. El límite no afecta a las hojas `impact`, los proyectiles ni el daño.
4. La hoja `pickup.png` también se reproduce al construir una torre y al retirar correctamente un obstáculo, en el centro visual del objeto. La apertura de cofres conserva `coin_burst_gold` y `pickup`.

## Consecuencias

- Los sprites completos ya no dependen de rectángulos/pivotes definidos a mano; cambios de resolución o de encuadre de esas imágenes no requieren rehacer el montaje.
- `TOWER_VISUAL_SCALE` y el tamaño de las imágenes de UI son valores de presentación. No cambian la celda ocupada, el rango ni la colisión.
- El cooldown solo dosifica el efecto visual de disparo. No modifica frecuencia de ataque, proyectiles, daño ni efectos de impacto.
- El ajuste fino del tamaño y la legibilidad queda pendiente de aceptación manual en Godot.

## Referencias

- Petición explícita del usuario y sprites PNG completos de `assets/sprites/ui/icons/`, 2026-10-14.
- [Diseño del juego](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md), [combate](../design/06_COMBAT_SYSTEM.md), [progresión](../design/16_PROGRESION_Y_SELECCION_DE_TORRES.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md).

## Sustituye

- Sustituye el montaje por regiones de la lámina descrito en [ADR-0100](ADR-0100-sprite-unico-de-torre-y-tinte-de-altura.md). Su sprite único, espejo, crecimiento por nivel y tinte de elevación siguen vigentes.
- Amplía [ADR-0101](ADR-0101-vfx-animados-de-cozy-chunky-por-evento.md) con la limitación temporal de `shoot` y la reutilización de `pickup.png` en construcción y retirada de obstáculos.
- La escala de tablero/ghost de la decisión 2 fue refinada por [ADR-0103](ADR-0103-escala-de-torre-sin-recorte.md); los tamaños de interfaz de esta decisión permanecen vigentes.
