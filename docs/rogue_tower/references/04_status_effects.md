# Efectos de estado — borrador personal

> **Estado:** resumen de reglas de Rogue Tower para comparar; no confirmado como balance. El contrato vigente del proyecto está en [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md); ADR-0012 conserva el estado histórico al cierre de M8.

## Regla propia confirmada por el usuario

Bleed detiene la regeneración de Health, Burn la de Armor y Poison la de Shield. En el proyecto, además, el estado activo suma +1 una sola vez al multiplicador de los ataques directos de su capa (no por acumulación); los ticks usan multiplicador 1.0 en la capa asociada y 0.5 en las otras. Las cifras y valores de la tabla siguiente son de referencia y no son los valores de la demo.

## Efectos principales

| Efecto | Regla resumida de Rogue Tower | Función táctica |
|---|---|---|
| **Bleed** | 24 de daño/s hasta agotar el Bleed acumulado. Hace la mitad contra Armor o Shield. Mientras está activo, detiene la regeneración de Health y añade +1 al multiplicador de Health de los ataques directos. | Contrarresta regeneración de Health y prepara al enemigo para ese daño. |
| **Burn** | 24 de daño/s hasta agotarse. Hace la mitad si la capa actual es Health o Shield. Detiene la regeneración de Armor y añade +1 al multiplicador de Armor de los ataques directos. | Contrarresta regeneración de Armor. |
| **Poison** | 24 de daño/s hasta agotarse. Hace la mitad si la capa actual es Health o Armor. Detiene la regeneración de Shield y añade +1 al multiplicador de Shield de los ataques directos. | Contrarresta regeneración de Shield. |
| **Slow** | Reduce la velocidad hasta 60%; escala con el daño que lo aplica. Decae a 6 puntos/s y se debilita conforme baja. Frost Keep y ciertas cartas Ballista lo aplican. | Mantiene enemigos más tiempo dentro del alcance. |
| **Freeze** | Control breve; las cartas descritas dan 3% en Ballista o hasta 15% en Frost Keep, durante 1 s. | Detiene el movimiento temporalmente. |
| **Haste** | Aumenta movimiento hasta 60%; se debilita y decae a 6 puntos/s. Varios monstruos lo aplican. | Mejora temporal de movimiento del enemigo. |
| **Fortification** | Reduce en 5 el daño base de cada ataque; decae a 6 puntos/s, con máximo indicado de 60. | Mitigación temporal que protege al enemigo. |

## Mejoras e interacciones de la referencia

- **Límites de daño periódico:** Bleed, Burn y Poison comienzan en 24/s. Las mejoras específicas elevan su máximo primero a 50/s y después a 80/s; **Make them Suffer** añade +40/s a los tres.
- **Sinergias de daño:** Trail of Blood añade hasta +3 daño a salud contra enemigos con Bleed; Fire and Flames, hasta +3 a armadura con Burn; Vile Consumption, hasta +3 a escudo con Poison.
- **Sinergias entre estados:** Slow Cooker hace que Slow acelere Burn (hasta +50%, +100% y +150% según nivel). Creeping Cough añade Slow equivalente al 5% del Poison aplicado.
- **Críticos:** Eviscerate aporta +5% crítico contra objetivos con Bleed. Exsanguinate, Ignite y Expunge convierten una fracción del DoT correspondiente en daño extra en golpes críticos; la referencia los mejora hasta 20%. Ese daño adicional también se reduce a la mitad cuando la capa actual no coincide con la capa principal del efecto.
- **Origen:** Bleed suele venir de Shredder o de cartas para otras torres; Burn, de Flame Thrower o cartas; Poison, de Poison Sprayer o cartas; Slow, de Frost Keep, Ballista con Frost Bolts y otras cartas. Haste y Fortification proceden de habilidades enemigas.

## Diferencias con el prototipo

La demo mantiene parámetros configurables: Slow refresca sin acumular y Burn acumula hasta tres cargas; los valores de Bleed y Poison también son fixtures. Rogue Tower describe DoT mediante daño por segundo acumulado y límites propios. Haste, Fortification y Freeze no forman parte del catálogo confirmado del proyecto. Estas diferencias son intencionales por ahora: la referencia no convierte automáticamente sus cifras y catálogo en contenido de la demo.

## Fuentes

- Texto aportado por el usuario sobre Bleed, Burn, Poison y Slow; [Status Effects — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Status_Effects), comunidad Fandom, consulta: 2026-10-08.
- Reglas actuales del prototipo: [ADR-0023 — capas y estados](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md) y [progreso](../design/09_PROGRESS.md). ADR-0012 solo describe el cierre histórico de M8.
- El contenido comunitario de Rogue Tower Wiki se identifica como CC BY-SA salvo indicación distinta; este documento lo resume y debe conservar atribución al reutilizarlo.
