# Progresión y selección de torres

Esta página explica la progresión vigente implementada para las siete torres. Las reglas aprobadas están en [Diseño del juego](01_GAME_DESIGN_SOURCE_OF_TRUTH.md); los Resources `data/towers/*.tres` son la configuración ejecutable. Los valores de curva siguen provisionales. Las reglas de progreso están en [ADR-0046](../decisions/ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md) y su UI de targeting/selección en [ADR-0047](../decisions/ADR-0047-herramientas-de-depuracion-y-claridad-de-seleccion.md).

## Tres niveles separados

Cada torre tiene tres niveles independientes:

| Capa | Rango | Qué cambia al subirla |
|---|---:|---|
| Health | 0–15 | +1 al daño base total y +1 al multiplicador Health |
| Armor | 0–15 | +1 al daño base total y +1 al multiplicador Armor |
| Shield | 0–15 | +1 al daño base total y +1 al multiplicador Shield |

Una torre puede recibir como máximo 45 mejoras. Subir una capa deja las otras dos intactas. El daño de cada ataque usa el daño base agregado de la torre y el multiplicador correspondiente a la capa activa del enemigo.

Una mejora puede llegar de dos formas: el jugador paga Gold en el botón de esa capa, o la torre obtiene suficiente XP manteniendo un objetivo válido. Ambos caminos incrementan el mismo nivel de capa. La XP sobrante se conserva y puede pagar más de un nivel si alcanza el siguiente umbral.

## Curvas configurables

Sea `n` el nivel actual de la capa antes de mejorar:

```text
coste Gold siguiente = round(coste_base_de_capa × factor_coste^n)
XP requerida siguiente = XP_base × factor_XP^n
XP/s con objetivo = 0,5 + 1 / (2 × alcance_en_hexes)
```

Las torres jugables usan 10 Gold base para Ballista/Mortar, 20 para Tesla Coil/Frost Keep y 30 para Flame Thrower/Poison Sprayer/Shredder. El umbral inicial es 100 XP por capa. El factor de coste y el factor de XP parten de 1,15. `TowerData` expone los valores para balancearlos independientemente; 1,15 es provisional y no se presenta como el balance exacto de Rogue Tower. Al nivel 15 esa capa ya no recibe XP ni permite compras.

La torre gana XP en la capa de HP activa del objetivo que mantiene en alcance, aunque no lo esté dañando. Si el enemigo cambia de capa durante el seguimiento, la XP nueva va a la capa que esté activa en ese momento. Cada capa conserva su propia XP no gastada.

## Controles y feedback

- Los tres botones muestran capa, nivel `n/15`, XP actual/umbral en barra coloreada, incremento y precio.
- Un solo botón mejora una sola capa; los niveles y barras de las otras capas no cambian. El resumen de torre también enseña cada nivel y el total `n/45`.
- Las prioridades se eligen con un selector inicial y un botón `+` contiguo. Cada pulsación revela la prioridad siguiente, hasta tres; las opciones 2 y 3 quedan ocultas por defecto. La segunda opción solo decide empates de la primera; la tercera solo decide empates anteriores. Si se selecciona un criterio ocupado en otra posición, ambos se intercambian; si se intenta duplicar en una posición vacía, la selección se revierte. La prioridad 1 es obligatoria y no hay criterios duplicados. Los tooltips explican cada métrica; «Menos HP total» suma los puntos actuales de Health, Armor y Shield.
- La card inferior de la torre seleccionada pulsa. En build mode, el sprite y el alcance del preview se dibujan por delante del terreno y los obstáculos. Verde significa ubicación válida; rojo, no disponible.
- El panel de información no pulsa. Conserva altura natural y, cuando la ventana no tiene espacio vertical suficiente, reduce su escala vertical desde el borde superior para permanecer entero en pantalla.
- `Ctrl+K` abre herramientas temporales de depuración: Gold, Mana, curación de base, inicio de ronda, reinicio de run y desbloqueo temporal de torres/cartas. Los desbloqueos solo modifican el estado de memoria de la run y no se escriben al guardado.
- Al ganar o gastar Gold, moneda e importe rebotan juntos en el HUD. El feedback escala el grupo completo y no desplaza controles hijos dentro del contenedor de recursos.
- El hover sobre un obstáculo dibuja una aureola a partir del alfa del mismo PNG, siguiendo su silueta recortada.
- Los seis hexes alrededor de Main Tower están a elevación 0 para que una loseta alta no oculte el edificio.
- Obstáculos y cards usan la misma caja 86×86 px y el mismo centro visual ligeramente desplazado hacia abajo.

## Límites de la referencia

La [wiki de Rogue Tower](https://rogue-tower.fandom.com/wiki/Towers) documenta las reglas generales de daño y experiencia que se comparan en [Auditoría del sistema de torres](15_AUDITORIA_SISTEMA_DE_TORRES.md). El tope de 15 niveles por capa y los factores exponenciales iniciales de 1,15 son configuración propia. No se importan árboles de investigación, cartas ni valores de progreso del juego de referencia como reglas automáticas.
