# ADR-0016 — Campaña de veinte rondas

- Estado: **sustituido para calendario, roster y cantidades** por ADR-0037. Conservado como historia del ciclo de expansión M10.
- Contexto: M5 ya podía crear una oleada desde `WaveData`, pero la escena principal permitía repetir cualquier fixture, no contaba spawns pendientes y no obligaba a expandir una sola vez antes de continuar. El roadmap define 20 rondas y el jugador indicó que `docs/rogue_tower/references/02_monstruos.md` recoge reglas propias confirmadas además de datos comunitarios.

## Decisiones

1. `WaveCampaignData` mantiene exactamente veinte `WaveData` consecutivos, valida que la ronda 17 y 19 sean encuentros de minijefe y la 20 un jefe Tier 2. Las reglas de calendario se promueven a la fuente de verdad; la identidad aprobada posteriormente se registra en ADR-0032; el balance propio del jefe permanece abierto.
2. La campaña usa datos propios placeholder: Asaltante básico, Asaltante acorazado, Regenerador, Minijefe genérico y Jefe Tier 2 genérico. La cifra de vida del Asaltante básico de esta decisión queda sustituida por ADR-0024 para que la Ballista inicial lo elimine de un impacto. Los demás perfiles no importan estadísticas o habilidades de la wiki comunitaria. La identidad inicialmente genérica se actualizó a Ooogie von Ooogovich (Haunted) en ADR-0032; el Resource ejecutable sigue genérico hasta implementar ese diseño. Color y radio son representación vectorial temporal.
3. `WaveCampaignData` configura crecimiento por ronda para vida máxima (+5% por ronda posterior a la primera), daño a base (+2.5%) y recompensa por baja (+2%). Son valores experimentales, editables y no balance aprobado.
4. Antes de configurar cada enemigo de campaña, el director duplica su `EnemyData` y escala la copia runtime. No modifica Resources compartidos. La composición, intervalos y bonus de limpieza viven en `round_01.tres`–`round_20.tres`.
5. El director cuenta `pending_spawn_count` y enemigos vivos por separado. Solo termina cuando no quedan grupos/spawns pendientes, el generador se detuvo y no hay enemigos vivos. El bonus de ronda se emite una vez tras ese punto.
6. Después de limpiar las rondas 1–19, la run entra en `TERRAIN_EXPANSION`; combate real queda bloqueado hasta confirmar una pieza válida de siete hexágonos y actualizar la ruta. Esa confirmación incrementa una sola vez el número de ronda y devuelve a `ROUND_PREP`. No hay expansión tras la 20: limpiar su jefe entra a `RUN_VICTORY`.
7. Los fixtures M7/M8 siguen accesibles como `DEBUG` durante preparación/expansión. El modo diagnóstico vuelve a la fase de origen sin progresar el contador, gastar/recompensar oro o dañar la base. Los diagnósticos no sustituyen ni permiten saltar una ronda real.
8. Alcance histórico de M10: este hito no incluyó las capas Shield→Armor→Health, cartas M11 ni meta-progresión M12; estas llegaron en hitos posteriores. La afirmación de que las capas y counters quedaban pendientes está sustituida por M12A y ADR-0023. La campaña conserva estadísticas propias configurables en vez de copiar cifras de la wiki.

## Configuración provisional de enemigos M10

| Perfil | HP base | Velocidad | Daño a base | Armadura | Regen HP/s | Oro por baja |
|---|---:|---:|---:|---:|---:|---:|
| Asaltante básico | 100 | 90 | 10 | 0 | 0 | 5 |
| Asaltante acorazado | 46 | 76 | 12 | 5 | 0 | 7 |
| Regenerador | 58 | 70 | 10 | 1 | 3 | 8 |
| Minijefe placeholder | 320 | 42 | 24 | 12 | 1 | 60 |
| Jefe Tier 2 placeholder | 1600 | 26 | 50 | 45 | 5 | 200 |

Todos los valores de la tabla se escalan por ronda donde aplique y pueden cambiarse en `.tres`. Las estadísticas salvo la salud del Asaltante básico no se obtuvieron de la tabla de Rogue Tower.

## Consecuencias y aceptación

- El selector HUD muestra el contenido 1–20, etiqueta encuentros especiales y solo permite jugar la ronda activa.
- La expansión de una pieza se vuelve una puerta de progresión; las acciones de build siguen permitidas en preparación/expansión según `BuildController`.
- La demo se completa técnicamente al limpiar la ronda 20. El estado de victoria bloquea nuevos combates, colocaciones y compras.
- Verificar contadores, recompensa, bloqueo, expansión única, encuentros 17/19/20, aislamiento de DEBUG y victoria con la prueba manual M10 en [10_ACCEPTANCE_TESTS.md](../design/10_ACCEPTANCE_TESTS.md#prueba-manual-m10-en-el-juego).
- Estado de esta revisión: implementación y documentación en código; aceptación visual/manual pendiente. No se ejecutó Godot ni pruebas en esta revisión.
