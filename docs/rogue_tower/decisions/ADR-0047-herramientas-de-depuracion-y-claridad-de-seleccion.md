# ADR-0047: Herramientas de depuración y claridad de selección

- **Fecha:** 2026-10-10
- **Estado:** código y documentación integrados; aceptación visual/manual pendiente
- **Decide:** petición explícita del usuario
- **Actualiza:** presentación de targeting y selección documentada en ADR-0045/0046

## Contexto

Las pruebas repetidas requerían alterar Gold, Mana, Health y desbloqueos sin depender de progresar manualmente. La experiencia visual también conservaba pulso en el panel lateral, tres prioridades visibles todo el tiempo y círculos alrededor de una torre seleccionada. El feedback de Gold existente cambiaba la posición de controles que viven dentro de un contenedor, lo que hacía que el rebote de la cifra no se percibiera con fiabilidad. Los obstáculos usan PNG con transparencia y necesitan un hover que siga el contorno del arte.

## Decisiones

1. `Ctrl+K` abre un menú de depuración temporal con `+1000 Gold`, `+100 Mana`, restaurar Mana, curar la base, activar/desactivar todos los desbloqueos, iniciar la ronda seleccionada y reiniciar la run.
2. El override de desbloqueos se mantiene en memoria. Hace visibles todas las torres configuradas y permite cartas cuyo requisito sea un unlock; no escribe `SaveData`. Se reinicia al crear otra run. Los límites por run y las cartas con peso cero continúan vigentes.
3. «Empezar una run desde cero» recarga `Main`: restablece tablero, ronda, economía y cartas de la run y genera una nueva seed; conserva la meta-progresión permanente.
4. El panel de información de torre no pulsa. Mantiene alto natural y escala verticalmente desde su borde superior si el viewport no tiene espacio para mostrarlo entero. El pulso de la card inferior seleccionada continúa.
5. La prioridad 1 aparece sola. Un botón `+` revela prioridad 2 y luego prioridad 3, sin alterar la regla de desempate o unicidad. Al cambiar de torre, la UI muestra solo hasta la prioridad más alta configurada en esa torre.
6. La selección de una torre conserva el brillo recortado y el pulso de escala del sprite, pero no dibuja anillos circulares de alcance o contorno. El radio y contorno de hover siguen disponibles sobre una torre no seleccionada.
7. El hover de obstacle dibuja una copia del PNG mediante shader CanvasItem que expande su alfa. La aureola sigue la silueta transparente, no una forma geométrica.
8. Un cambio de Gold escala y hace rebotar el grupo de UI que contiene icono e importe. No se anima la posición de controles administrados por `HBoxContainer`.
9. La condición de spawn de terreno se mantiene como invariante: el grafo debe contener al menos una salida PATH externa, todas las salidas deben llegar a Main Tower y cumplir la longitud mínima. El tablero inicial se valida al arrancar; cada propuesta de terreno crea un grafo candidato, y el botón de confirmar exige que sea válido. No se aceptan piezas que dejen el tablero sin spawn alcanzable.

## Consecuencias

- Los hacks reducen el tiempo de preparación de pruebas sin contaminar moneda meta, desbloqueos o niveles permanentes.
- Reiniciar una run incrementa el contador persistente de runs iniciadas por el flujo normal de `MetaProgression.begin_run`; el resto del estado de run se inicializa nuevamente.
- Añadir prioridades ocupa altura solo cuando el jugador las solicita; el panel limita su extensión al viewport y no incorpora scroll.
- El shader requiere el mismo PNG usado por la decoración y añade un overlay solo al obstáculo bajo el cursor.
- La validación de rutas ya se aplicaba en `PathGraph` y `Main`; este ADR la hace explícita como garantía para la selección/confirmación de expansiones.

## Fuentes

- Petición directa del usuario en la sesión del 2026-10-10.
- `game/board/path_graph.gd`, `game/main/main.gd` y validación del tablero inspeccionados el 2026-10-10.

## Decisiones sustituidas

- ADR-0045 describía pulso del panel lateral y círculo de alcance al seleccionar; ambas presentaciones quedan reemplazadas por este ADR.
- ADR-0046 describía las tres prioridades como controles siempre visibles; ahora se despliegan bajo demanda. La lógica lexicográfica y las reglas de unicidad continúan vigentes.
