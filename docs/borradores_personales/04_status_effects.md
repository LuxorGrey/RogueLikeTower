# Efectos de estado — borrador personal

> **Estado:** resumen de reglas de Rogue Tower para comparar; no confirmado como balance. El proyecto ya tiene reglas propias provisionales en [ADR-0012](../decisiones/ADR-0012-framework-de-estados-m8.md). No sustituirlas sin decisión de diseño.

## Regla propia confirmada por el usuario

Bleed detendrá la regeneración de salud, Burn la de armadura y Poison la de escudo. Se conservará el comportamiento actual de esos estados en el proyecto; esta decisión confirma la interacción con regeneración, no las cifras de daño periódico de Rogue Tower.

## Efectos principales

| Efecto | Regla resumida de Rogue Tower | Función táctica |
|---|---|---|
| **Bleed** | 24 de daño/s hasta agotar el Bleed acumulado. Hace la mitad contra armadura o escudo. Mientras está activo, detiene la regeneración de salud y añade +1 daño a salud de todos los ataques. | Contrarresta regeneración de salud y prepara al enemigo para daño a salud. |
| **Burn** | 24 de daño/s hasta agotarse. Hace la mitad si la capa actual es salud o escudo. Detiene la regeneración de armadura y añade +1 daño a armadura de todos los ataques. | Contrarresta regeneración de armadura. |
| **Poison** | 24 de daño/s hasta agotarse. Hace la mitad si la capa actual es salud o armadura. Detiene la regeneración de escudo y añade +1 daño a escudo de todos los ataques. | Contrarresta regeneración de escudo. |
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

El prototipo documenta estados como datos configurables; Slow refresca sin acumular y Burn acumula hasta tres cargas. Bleed y Poison tienen valores de prueba propios. En cambio, Rogue Tower describe sus DoT mediante daño por segundo acumulado y valores máximos. Haste, Fortification y Freeze no forman parte del catálogo confirmado de estados del proyecto. Revisar estas diferencias antes de incorporar reglas o cifras; la referencia no modifica automáticamente el comportamiento actual.

## Fuentes

- Texto aportado por el usuario sobre Bleed, Burn, Poison y Slow; [Status Effects — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Status_Effects), comunidad Fandom, consulta: 2026-10-08.
- Reglas actuales del prototipo: [ADR-0012 — framework de estados](../decisiones/ADR-0012-framework-de-estados-m8.md) y [progreso](../fuente_de_verdad/09_PROGRESS.md).
- El contenido comunitario de Rogue Tower Wiki se identifica como CC BY-SA salvo indicación distinta; este documento lo resume y debe conservar atribución al reutilizarlo.
