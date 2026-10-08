# Implementation Roadmap

Codex debe ejecutar estos milestones en orden. **No saltar al contenido final.**

## M0 — Bootstrap
- Crear/validar proyecto Godot 4.7.
- Configurar resolución, input básico, carpetas.
- Crear escena `Main`.
- Crear Autoloads mínimos: `GameState`, `RunManager`, `MetaProgression`.
- Añadir pantalla debug simple.
- Añadir `.gitignore`.
- Resultado: proyecto ejecutable vacío.

## M1 — Hex Grid lógico
- Implementar coordenadas hex axiales `q,r`.
- Vecinos 6 direcciones.
- Conversión axial <-> world/screen.
- Rotación alrededor de origen.
- Distancia hex.
- Diccionario de `HexCell`.
- Debug draw de grid.
- Tests para vecinos, rotación y conversión.
- Resultado: grid navegable y verificable.

## M2 — Terrain rendering 2D
- Implementar capas visuales.
- Placeholder para Path/Grass/Mountain.
- Elevation 0/1/2.
- Offset visual por elevación.
- Cliff/fachada visual separada de la celda lógica.
- Y-sort correcto para torres/enemigos/decoración.
- Hover en cara superior con color por terreno y coordenadas axiales en HUD.
- Resultado: pequeño mapa estilo "2.5D dibujado" sin 3D real.

## M3 — TerrainPiece de 7 hexágonos
- Resource `TerrainPieceData`.
- Exactamente 7 celdas locales por pieza.
- Preview fantasma.
- Rotación 60°.
- Validación de overlap.
- Validación de adyacencia.
- Validación de conexiones de camino.
- Confirmar/cancelar colocación.
- Crear 5 piezas placeholder.
- Resultado: expansión manual robusta.

## M4 — Grafo de caminos
- Derivar grafo desde celdas Path.
- Identificar endpoints.
- Spawn endpoints vs objetivo/base.
- Encontrar ruta válida mediante AStar2D o grafo propio sobre hexes.
- Soportar bifurcación y convergencia.
- Recalcular solo al colocar pieza.
- Visualización debug de rutas.
- Resultado: varias rutas válidas sobre mapa dinámico.

Contrato técnico del prototipo: grafo axial propio y BFS determinista sin costes; aplica las ofertas exactas/flexibles de [ADR-0006](../decisiones/ADR-0006-sockets-laterales-flexibles-de-camino.md). La base actual `(0,0)` es provisional y se documenta en [ADR-0007](../decisiones/ADR-0007-grafo-logico-de-caminos.md). M4 solo expone candidatos; M5 añade a `WaveDirector` una política configurable por grupo y usa `FIRST_SORTED` en la demo.

## M5 — Enemigo básico + objetivo
- Base/objetivo con vida.
- Enemy scene.
- Movimiento por ruta.
- Spawn wave.
- Llegada a base causa daño.
- Vida y muerte.
- Resultado: primera oleada funcional.

Contrato del prototipo: la base temporal se dibuja sobre PATH `(0,0)` y los enemigos consumen `PathRoute` de M4; `WaveDirector` inicia una sola oleada de demostración desde el primer endpoint ordenado. La muestra usa 3 enemigos, 20 de vida, velocidad 90 px/s y 10 de daño a base, con una base de 50 de vida. Son valores y política de spawn provisionales editables como Resources, no balance confirmado. La colocación de terreno queda bloqueada durante combate; al completar se habilita expansión, sin iniciar otra ronda (eso corresponde a M10). Las decisiones están en [ADR-0008](../decisiones/ADR-0008-primera-oleada-y-movimiento-de-enemigos.md).

## M6 — Torres
- Build mode.
- Solo construir en celdas construibles libres.
- TowerData Resource.
- Targeting.
- Rango.
- Cadencia.
- Projectile/hitscan básico.
- Upgrade de torre.
- Venta opcional solo como placeholder configurable.
- Resultado: Tower Defense mínimo jugable.

## M7 — Damage model
- Health.
- Armor.
- Regeneration.
- Tipos/counters configurables.
- Pipeline de daño central.
- UI debug de estadísticas.
- Resultado: enemigos requieren respuestas diferentes.

## M8 — Status Effects
Implementar framework, no catálogo enorme.
- Slow.
- Burn.
- Poison o Bleed (elegir uno como tercer ejemplo provisional).
- Duración, stacks/reglas configurables.
- Resistencias si se necesitan.
- Resultado: status combinables con torres.

## M9 — Economía de run + maná
- Moneda de construcción.
- Costes de torres/upgrades.
- Recompensa por kills/ronda.
- Maná.
- Regen/capacidad.
- Sin support buildings.
- Resultado: economía jugable.

## M10 — Rondas 1-20
- `WaveData` data-driven.
- Director de oleadas.
- Escalado provisional.
- Ronda termina solo cuando no quedan enemigos pendientes/vivos.
- Tras ronda: bloquear combate y abrir expansión.
- Ronda 20 completa demo.
- Resultado: run completa técnicamente.

## M11 — Cards
- `CardData`.
- Offer UI.
- Selección.
- Modificadores de torre/globales/maná.
- Pool filtrada por desbloqueos.
- Primer set pequeño de cartas.
- Resultado: builds diferentes por run.

## M12 — Meta-progression
- Moneda permanente.
- Recompensa al perder/completar.
- Tienda.
- PermanentUpgradeData.
- Desbloqueo de torres.
- Mejoras permanentes simples.
- SaveGame.
- Resultado: morir -> mejorar -> nueva run.

## M13 — UX/UI
- HUD ronda/20.
- Vida base.
- Moneda.
- Maná.
- Torre seleccionada.
- Panel stats.
- Preview de pieza y controles de rotación.
- Pantalla derrota/victoria.
- Tienda.
- Tooltips.
- Resultado: todos los sistemas comprensibles sin debug.

## M14 — Vertical Slice
Contenido provisional suficiente:
- 4-6 torres.
- 5-8 arquetipos de enemigo.
- 3 status.
- 12-20 cartas.
- 8-12 piezas de terreno.
- 8-15 permanentes.
Estas cantidades NO son compromiso de diseño final.
- Balance preliminar de 20 rondas.
- Resultado: demo jugable de principio a fin.

## M15 — Arte Urtuk-like pipeline
- Sustituir placeholders sin tocar lógica.
- Top sprites de hex.
- Cliffs por elevación/bordes.
- Props que pueden sobresalir visualmente.
- Mantener footprint lógico limpio.
- Variantes visuales.
- Resultado: mapa orgánico que oculta la rigidez de la grid.

## M16 — Polish
- Audio.
- VFX.
- Feedback impactos.
- Transiciones.
- Cámara.
- Performance profiling.
- Balance.
- QA/save migration.
