# ADR-0007: nueve celdas lógicas de construcción por chunk

- **Estado:** Confirmada, conforme a ADR-0013.
- **Fecha:** 2026-10-06; alineada el 2026-10-07.
- **Sustituye:** ADR-0004 (cuatro posiciones en las esquinas).
- **Regla autoritativa de terreno:** [Sistema de losetas isométricas](../sistemas/sistema-losetas-isometricas.md).

## Contexto y decisión

Cada chunk tiene una cuadrícula lógica de 3×3: cuatro esquinas, cuatro centros de borde y centro. Son nueve celdas de terreno, no nueve columnas dentro de un volumen visual de 3×3×3.

Una celda puede alojar como máximo una torre/ocupación. Solo se construye en GRASS o STONE cuando la celda está libre. PATH es transitable y no construible. STONE aporta un multiplicador configurable al alcance (1.15 inicial, sujeto a balance). Altura y ocupación son datos lógicos independientes del sprite.

## Consecuencias

- La rotación del chunk rota las nueve celdas de terreno y sus puertos.
- La interfaz explica bloqueo por PATH u ocupación.
- No se aplican para esta regla el bloqueo por monasterio/campamento ni el bono histórico de daño por nivel de montaña.
- El render no es autoridad para permitir la construcción.

## Referencias

- [ADR-0013: chunks lógicos y terreno isométrico](ADR-0013-sistema-de-losetas-isometricas.md)
- [GDD](../../../GDD.md)
