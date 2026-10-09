# Torres — borrador personal

> **Estado:** resumen de referencia externa. El usuario promovió los parámetros base publicados para las siete torres, con los cambios del parche oficial anotados en [ADR-0036](../decisions/ADR-0036-parametros-torres-segun-changelog-oficial.md). Sus roles generales también informan el diseño; los árboles completos, reglas no seleccionadas y economía propia siguen en esta referencia. Para números ejecutables consulta el [catálogo activo](../design/13_CONTENT_ROSTER.md) y los Resources.

## Roster de referencia y encaje con la demo

| Referencia | Función resumida | Perfil actual más cercano |
|---|---|---|
| Ballista | Proyectil a un objetivo; económica, floja contra Armor y Shield. | Ballista — objetivo único. |
| Mortar | Proyectil explosivo de largo alcance; lento, fuerte contra Armor. | Mortar — área/anti-Armor. |
| Tesla Coil | Descargas a varios enemigos cercanos; fuerte contra Shield. | Tesla Coil — cadena. |
| Frost Keep | Ventisca de área; ralentiza en proporción al 50% de su daño y consume Mana. | Frost Keep — área corta y Slow. |
| Flame Thrower | Ataque de fuego que aplica daño periódico; consume Mana. | Flame Thrower — cono y Burn. |
| Poison Sprayer | Ataque de veneno periódico; consume Mana. | Poison Sprayer — cono y Poison. |
| Shredder | Lanza hojas que recorren el camino y aplican Bleed. | Shredder — hoja que recorre Path. |

La demo confirma siete perfiles con estos nombres y patrones generales. Se promueven los parámetros base de las torres, corregidos con la fuente oficial cuando la wiki conserva un valor obsoleto. Los árboles completos no se copian; las cartas aprobadas de la demo y sus excepciones están en [Nomenclatura](../design/12_NOMENCLATURE.md) y el catálogo activo.

## Reglas generales extraídas de la referencia

- Cada torre tiene daño base y multiplicadores distintos para la capa de vida actual. En Rogue Tower se resuelven las capas en orden **escudo → armadura → salud**. Para el juego propio, el usuario confirma ese orden y la fórmula **daño base × multiplicador de la capa activa**.
- Al subir de nivel, la referencia suma +1 al daño base y +1 a uno de los multiplicadores. La torre gana experiencia por el tiempo que mantiene objetivos, según la capa que esté atacando, o puede comprar niveles con oro; el coste de compra crece con el nivel. El extracto no trae la fórmula de XP por segundo.
- En la referencia, cada nivel de elevación añade +1 al daño base y +0,5 al alcance. No se trasladan esos incrementos: el proyecto ya tiene reglas provisionales propias para altura en [ADR-0009](../decisions/ADR-0009-torres-y-construccion-m6.md).
- Algunas torres consumen maná por ataque, normalmente ligado al daño base; Frost Keep usa 2 maná/s constante. La elevación también puede aumentar el coste de maná. La cadencia suele ser fija; Frost Keep y Encampment son excepciones en la referencia cuando cubren más caminos.
- Las torres empiezan con 0% de crítico y algunas cartas lo aumentan. También pueden aplicar una parte de su daño como estado si se escogen las cartas correspondientes.
- Las prioridades de objetivo incluyen progreso, vida restante/máxima por capa, velocidad y marcado. La referencia permite hasta tres criterios; la demo implementa por ahora cuatro modos más limitados.
- El coste de construir se encarece por cada torre del mismo tipo presente; demoler reduce ese coste. El nivel de las torres no interviene en el precio de compra/demolición. La economía y los costes de la demo están configurados por separado.
- La probabilidad crítica de referencia escala por tramos: hasta 50% para daño ×2, el siguiente 50% para ×3 y el siguiente 50% para ×4; por encima de 150% no aporta más.

## Cifras y mecánicas fuera del perfil promovido

Algunos valores de tablas comunitarias parecen desalineados o desactualizados. Los parámetros base vigentes son los Resources enlazados desde el catálogo; las diferencias verificadas con notas oficiales se documentan en ADR-0036. Las reglas propias de nivel, altura, mejora manual, economía y estados no se deducen automáticamente del juego de referencia. Los árboles comunitarios completos permanecen aquí como contexto, no como contenido aprobado de la demo.

**Estado vigente del proyecto:** el modelo de cada enemigo contiene pools de Salud, Armadura y Escudo; cada perfil configura sus máximos y cero desactiva una capa para esa unidad. El daño directo afecta a una sola capa activa en orden Escudo→Armadura→Salud. Las torres tienen multiplicadores para las tres capas. Bleed/Burn/Poison bloquean la regeneración de su capa y suman +1 al multiplicador de ataques directos contra esa capa; los ticks hacen daño completo en la capa asociada y mitad en las otras. La implementación actual descarta el exceso al agotar la capa activa; la referencia no documenta expresamente el overkill, por lo que esta política sigue provisional. Ver [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md).

## Fuentes

- Texto aportado por el usuario: extracción de las fichas y cartas de torres de Rogue Tower.
- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers), comunidad Fandom, consulta: 2026-10-09.
- [Ballista](https://rogue-tower.fandom.com/wiki/Ballista), [Mortar](https://rogue-tower.fandom.com/wiki/Mortar), [Tesla Coil](https://rogue-tower.fandom.com/wiki/Tesla_Coil), [Frost Keep](https://rogue-tower.fandom.com/wiki/Frost_Keep), [Flame Thrower](https://rogue-tower.fandom.com/wiki/Flame_Thrower), [Poison Sprayer](https://rogue-tower.fandom.com/wiki/Poison_Sprayer) y [Shredder](https://rogue-tower.fandom.com/wiki/Shredder), Rogue Tower Wiki, consulta: 2026-10-09.
- El contenido comunitario de Rogue Tower Wiki se identifica como CC BY-SA salvo indicación distinta. Este texto es un resumen propio; mantener atribución al reutilizarlo.
