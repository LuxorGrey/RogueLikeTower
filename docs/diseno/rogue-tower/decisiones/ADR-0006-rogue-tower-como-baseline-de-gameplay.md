# ADR-0006: Rogue Tower como baseline de gameplay

- **Estado:** Confirmada
- **Fecha:** 2026-10-06

## Contexto

El usuario ha aclarado que el gameplay general debe ser como *Rogue Tower* y que la wiki y sus guías son referencias esenciales. El concepto propio añade la construcción del terreno mediante losetas de Carcassonne durante la fase de preparación; no pretende reemplazar el resto del género por un sistema distinto.

## Decisión

Usar los sistemas de *Rogue Tower* como baseline para el gameplay que todavía no esté definido. Investigar sus reglas en la wiki, consultar la página oficial para entender el núcleo anunciado y usar guías comunitarias como orientación táctica secundaria. Las decisiones explícitas del usuario prevalecen y se registran como adaptaciones. No inferir mecánicas a partir de guías comunitarias como si fueran reglas oficiales.

## Adaptaciones expresas del proyecto

| Área | Baseline de referencia | Regla del proyecto |
|---|---|---|
| Duración/objetivo | La referencia tiene 45 oleadas, jefes de hito y minibosses desde rondas tardías | 20 oleadas; mini-jefes en 5/10/15; vencer al jefe principal de la ronda 20 gana la run; 30–45 min objetivo |
| Construcción de terreno | El camino se expande y el jugador influye en su forma | El jugador construye mapa colocando losetas girables 90° durante preparación; además cada loseta tiene cuadrícula de construcción 3×3; sin reflejos |
| Catálogo | Torres, Support Buildings, cartas, enemigos y estados | El catálogo completo guía el diseño; la beta conserva todos los sistemas con un conjunto pequeño y representativo (ADR-0010) |
| Economía | Oro para compras y maná para ciertas torres/edificios | Dos recursos confirmados: oro y maná. Recompensas por oleada, bajas/regiones y cantidades se detallan y balancean aparte (ADR-0008) |
| Topología enemiga | Enemigos avanzan por caminos hacia la base de una partida con ruta ramificada | Usar las losetas/patrones, extremos abiertos, campamentos y criterios fijos de ruta acordados en ADR-0001; congelar el grafo durante oleada |
| Daño a base | Enemigo común causa 1; jefe puede ser letal | Base con 20 de integridad; una fuga común causa 1 y la fuga de jefe es letal |
| Modo | Single, Double y Triple Defense | Un modo inicial; accesible pero desafiante |
| Cámara y arte | Dirección visual del proyecto | 2D isométrico fijo 2:1, assets CellTile, orden por profundidad y camino a cota mínima (ADR-0009) |

Las cartas de mejora después de oleadas y los cofres de jefe se consideran parte del baseline, según la wiki; su frecuencia y selección deben adaptarse al formato de 20 rondas. La regla de construcción solo en preparación queda fijada en ADR-0005.

## Consecuencias

- Antes de inventar un sistema aún no definido, investigar cómo funciona en *Rogue Tower* y presentar la adaptación recomendada.
- Mantener tablas con trazabilidad entre wiki, guías comunitarias, página oficial y reglas propias.
- Los nombres originales se mantienen provisionalmente por decisión del usuario. Esto no implica copiar sprites, ilustraciones u otros assets protegidos como contenido final.
- Si el usuario aprueba o cambia una adaptación, actualizar este ADR y todos los documentos de diseño que dependan de ella.

## Fuentes

- [Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Rogue_Tower_Wiki)
- [Descripción oficial de Rogue Tower en Steam](https://store.steampowered.com/app/1843760/Rogue_Tower/)
- [Guías comunitarias de Rogue Tower en Steam](https://steamcommunity.com/app/1843760/guides/)
- [Rogue Tower: Upgrade Cards](https://rogue-tower.fandom.com/wiki/Upgrade_Cards)
- [ADR-0003: decisión económica inicial, sustituida](ADR-0003-economia-de-un-recurso.md)
- [ADR-0008: economía con oro y maná](ADR-0008-economia-oro-mana.md)
