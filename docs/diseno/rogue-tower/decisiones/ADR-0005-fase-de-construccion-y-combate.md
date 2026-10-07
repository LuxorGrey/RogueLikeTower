# ADR-0005: fase de construcción y combate

- **Estado:** Decisión confirmada
- **Fecha:** 2026-10-06

## Contexto

Cada ronda combina colocación de loseta, planificación de defensas y una oleada de enemigos. Los caminos y las rutas enemigas quedan fijados al comenzar el combate; la construcción reactiva durante la oleada podría introducir microgestión y alterar las decisiones espaciales ya tomadas.

## Decisión

Las torres se construyen y mejoran únicamente durante la preparación previa a una oleada. El jugador pulsa **«Siguiente oleada»** cuando está listo; esa acción cierra la preparación e inicia el combate automático. Al iniciarse, construcción y mejoras quedan bloqueadas hasta que finalice la oleada y empiece la siguiente preparación. La preparación también contiene la elección y colocación/giro de la loseta de terreno.

## Consecuencias

- El jugador debe anticipar el comportamiento de la oleada y completar su configuración antes de iniciarla.
- No se permite reaccionar comprando/mejorando torres en mitad de combate; las torres existentes siguen funcionando según sus reglas.
- La colocación de losetas y las conexiones de camino tampoco cambian durante el combate.
- La interfaz debe mostrar claramente cuándo puede construirse/mejorarse y cuándo la oleada está activa.

## Decisiones relacionadas

- [ADR-0008: economía con oro y maná](ADR-0008-economia-oro-mana.md)
- [ADR-0004: emplazamientos de torres por esquina](ADR-0004-emplazamientos-de-torres.md)
