# Torres — borrador personal

> **Estado:** resumen de referencia externa; no está confirmado ni integrado. Para el diseño del proyecto prevalecen [la fuente de verdad](../fuente_de_verdad/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [los modelos de datos](../fuente_de_verdad/04_DATA_MODELS.md) y el [ADR del roster de siete torres](../decisiones/ADR-0014-roster-jugable-de-siete-torres.md). Los valores de Rogue Tower no son balance aprobado.

## Roster de referencia y encaje con la demo

| Referencia | Función resumida | Perfil actual más cercano |
|---|---|---|
| Ballista | Proyectil a un objetivo; económica, floja contra armadura y escudo. | Ballesta — objetivo único. |
| Mortar | Proyectil explosivo de largo alcance; lento, fuerte contra armadura. | Mortero — área/antiarmadura. |
| Tesla Coil | Descargas a varios enemigos cercanos; fuerte contra escudo. | Bobina Tesla — cadena. |
| Frost Keep | Ventisca de área; ralentiza en proporción al 50% de su daño y consume maná. | Guardafría — área corta y Slow. |
| Flame Thrower | Ataque de fuego que aplica daño periódico; consume maná. | Lanzallamas — cono y Burn. |
| Poison Sprayer | Ataque de veneno periódico; consume maná. | Pulverizador venenoso — cono y Poison. |
| Shredder | Lanza hojas que recorren el camino y aplican Bleed. | Trituradora — hoja que recorre PATH. |

La demo ya confirma siete perfiles con estos patrones generales. La tabla solo relaciona arquetipos; no implica que se adopten los nombres, cifras o árboles de cartas de la referencia.

## Reglas generales extraídas de la referencia

- Cada torre tiene daño base y multiplicadores distintos para la capa de vida actual. En Rogue Tower se resuelven las capas en orden **escudo → armadura → salud**. Para el juego propio, el usuario confirma ese orden y la fórmula **daño base × multiplicador de la capa activa**.
- Al subir de nivel, la referencia suma +1 al daño base y +1 a uno de los multiplicadores. La torre gana experiencia por el tiempo que mantiene objetivos, según la capa que esté atacando, o puede comprar niveles con oro; el coste de compra crece con el nivel. El extracto no trae la fórmula de XP por segundo.
- En la referencia, cada nivel de elevación añade +1 al daño base y +0,5 al alcance. No se trasladan esos incrementos: el proyecto ya tiene reglas provisionales propias para altura en [ADR-0009](../decisiones/ADR-0009-torres-y-construccion-m6.md).
- Algunas torres consumen maná por ataque, normalmente ligado al daño base; Frost Keep usa 2 maná/s constante. La elevación también puede aumentar el coste de maná. La cadencia suele ser fija; Frost Keep y Encampment son excepciones en la referencia cuando cubren más caminos.
- Las torres empiezan con 0% de crítico y algunas cartas lo aumentan. También pueden aplicar una parte de su daño como estado si se escogen las cartas correspondientes.
- Las prioridades de objetivo incluyen progreso, vida restante/máxima por capa, velocidad y marcado. La referencia permite hasta tres criterios; la demo implementa por ahora cuatro modos más limitados.
- El coste de construir se encarece por cada torre del mismo tipo presente; demoler reduce ese coste. El nivel de las torres no interviene en el precio de compra/demolición. La economía y los costes de la demo están configurados por separado.
- La probabilidad crítica de referencia escala por tramos: hasta 50% para daño ×2, el siguiente 50% para ×3 y el siguiente 50% para ×4; por encima de 150% no aporta más.

## Cifras que no conviene copiar todavía

El cuadro de atributos pegado parece tener columnas o celdas desplazadas: por ejemplo, el Mortar muestra `0` y `200` en posiciones que corresponderían a RPM y maná, incompatibles con su descripción de torre de disparo lento. Además, falta la fórmula de daño. Por eso este borrador conserva roles y sistemas, pero no reproduce esa tabla como datos válidos; habría que contrastarla con las fichas individuales antes de convertirla en configuración.

**Diseño confirmado por el usuario (2026-10-08), pendiente de implementación:** añadir multiplicadores de salud, armadura y escudo con la fórmula **daño base × multiplicador de la capa activa**, preservando los resultados y el funcionamiento actuales contra salud y armadura. Los valores todavía están pendientes. El usuario confirmó también las tres capas para enemigos en orden escudo → armadura → salud; falta definir si el daño sobrante al agotar una capa pasa a la siguiente. Nada de esto está implementado en este borrador.

## Fuentes

- Texto aportado por el usuario: extracción de las fichas y cartas de torres de Rogue Tower.
- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers), comunidad Fandom, consulta: 2026-10-08.
- [Ballista](https://rogue-tower.fandom.com/wiki/Ballista), [Mortar](https://rogue-tower.fandom.com/wiki/Mortar), [Tesla Coil](https://rogue-tower.fandom.com/wiki/Tesla_Coil), [Frost Keep](https://rogue-tower.fandom.com/wiki/Frost_Keep), [Flame Thrower](https://rogue-tower.fandom.com/wiki/Flame_Thrower), [Poison Sprayer](https://rogue-tower.fandom.com/wiki/Poison_Sprayer) y [Shredder](https://rogue-tower.fandom.com/wiki/Shredder), Rogue Tower Wiki, consulta: 2026-10-08.
- El contenido comunitario de Rogue Tower Wiki se identifica como CC BY-SA salvo indicación distinta. Este texto es un resumen propio; mantener atribución al reutilizarlo.
