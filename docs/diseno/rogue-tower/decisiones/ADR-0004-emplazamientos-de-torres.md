# ADR-0004: emplazamientos de torres por esquina (sustituido)

- **Estado:** Sustituido por ADR-0007 el 2026-10-06
- **Fecha:** 2026-10-06

## Contexto

**Esta decisión está obsoleta.** El usuario la sustituyó por una cuadrícula de construcción 3×3 por loseta, documentada en [ADR-0007](ADR-0007-cuadricula-de-construccion-3x3.md). El texto siguiente se conserva como historial de decisión.

Las torres deben aprovechar la forma y elevación de las piezas, mientras sus posiciones lógicas permanecen claras en 2D isométrico (ADR-0009).

## Decisión

Cada loseta ofrece como máximo **cuatro emplazamientos de torre**, uno en cada esquina. Un emplazamiento se habilita únicamente si la loseta concreta permite construir allí. Los emplazamientos son anclajes lógicos propios de la cuadrícula, independientes de la proyección de cámara y de la posición de los píxeles del arte. Cada anclaje admite una sola torre.

## Pendiente de especificación

Este ADR histórico está completamente sustituido por ADR-0007 y ADR-0013: cada chunk tiene nueve celdas lógicas; PATH bloquea construcción y GRASS/STONE permiten construir si están libres. Las antiguas reglas de campamento, monasterio y montaña no se aplican al terreno vigente.

## Consecuencias

- El límite global de torres no se deduce solo del número de losetas: depende de cuántos emplazamientos válidos tenga cada pieza y puede llegar a cuatro por loseta.
- La interfaz debe mostrar con claridad las esquinas construibles y las razones por las que una esquina no está disponible.
- El estado vigente de construcción y terreno se define en ADR-0007 y ADR-0013.
- Las decisiones sobre distancias, alcance y oclusión deberán usar las coordenadas lógicas de esos anclajes.

## Referencias relacionadas

- [Visión y diseño](../vision-y-diseno.md)
- [ADR-0009: presentación 2D isométrica](ADR-0009-presentacion-2d-isometrica-y-celltile.md)
- [Adaptación de patrones A–Y](../referencias/losetas-carcassonne-adaptacion.md)
- [ADR-0005: fase de construcción y combate](ADR-0005-fase-de-construccion-y-combate.md)
