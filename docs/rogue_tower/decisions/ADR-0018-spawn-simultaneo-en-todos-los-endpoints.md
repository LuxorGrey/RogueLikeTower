# ADR-0018 — Spawn simultáneo en todos los endpoints abiertos

- Estado: **sustituido por ADR-0037**. Las cantidades ahora son fijas por oleada y se reparten round-robin; ya no se crea un enemigo por cada endpoint en cada pulso.
- Contexto: `WaveDirector` seleccionaba un único endpoint por enemigo, aunque `PathGraph` ya enumeraba todas las salidas PATH abiertas con ruta a la base. El comportamiento pedido para la demo es presión simultánea desde todos los lados abiertos.

## Decisiones

1. En oleadas de campaña, cada pulso genera en el mismo frame un enemigo por cada `PathRoute` alcanzable del grafo. Un endpoint PATH explícito abierto con retorno a la base equivale a una salida activa.
2. `WaveEnemyGroupData.count` representa pulsos por endpoint en campaña; `spawn_interval` separa pulsos. La población pendiente inicial y el total anunciado en HUD son `count × endpoints alcanzables` sumado para los grupos.
3. Las políticas `FIRST_SORTED` y `ROUND_ROBIN` continúan limitando los fixtures M5/M7/M8 de diagnóstico. Los diagnósticos no multiplican su grupo por todos los endpoints y siguen aislados de campaña/economía/base.
4. La selección por endpoints no cambia las rutas cacheadas, el BFS ni las bifurcaciones/convergencias; cada enemigo recibe el `PathRoute` concreto de su spawn.

## Consecuencias

- Abrir más finales PATH aumenta el tamaño de cada grupo y el HUD lo refleja. Los valores de campaña actuales son provisionales y el balance debe revisarse después de aceptar el comportamiento visual.
- En el primer spawn de cada pulso se ven enemigos en todos los finales abiertos a la vez; la finalización todavía exige generador detenido, pendientes cero y enemigos vivos cero.
- Ver criterios manuales en [M10 de aceptación](../design/10_ACCEPTANCE_TESTS.md#prueba-manual-m10-en-el-juego).
