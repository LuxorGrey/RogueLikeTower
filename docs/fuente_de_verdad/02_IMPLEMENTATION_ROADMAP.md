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

Contrato del prototipo M5: la base temporal se dibuja sobre PATH `(0,0)` y los enemigos consumen `PathRoute` de M4; la oleada inicial sale del primer endpoint ordenado. La muestra usa 3 enemigos, 20 de vida, velocidad 90 px/s y 10 de daño a base, con una base de 50 de vida. Son valores y política de spawn provisionales editables como Resources, no balance confirmado. La colocación de terreno queda bloqueada durante combate y al completar se habilita expansión. Desde el HUD de depuración M7 se pueden repetir dos fixtures para verificar daño; eso no es la progresión de rondas M10. Las decisiones están en [ADR-0008](../decisiones/ADR-0008-primera-oleada-y-movimiento-de-enemigos.md) y [ADR-0011](../decisiones/ADR-0011-hud-de-depuracion-m7.md).

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

Contrato de M6: `BuildController` construye solo sobre `GRASS`/`MOUNTAIN` libres durante preparación, combate o expansión; una torre no puede ocupar PATH, así que no altera ni bloquea la ruta M4. `Basic Bolt` usa `TowerData`; ofrece prioridades first/last progress, highest health y highest armor, alcance y cadencia configurables, y ataque hitscan. La muestra habilita mejoras gratuitas hasta nivel 3 porque los costes pertenecen a M9; la venta queda omitida. Daño 10, cadencia 1/s, alcance 3 hexes, mejoras +5 daño/+0.25 hex por nivel y bonus de alcance +0.25 por nivel de elevación son placeholders, no balance confirmado. M7 sustituyó el puente inicial de daño directo por `DamagePacket`/`DamageService` y activó mitigación de armor; ADR-0009/0010 registran el cambio y sus reglas.

## M7 — Damage model
- Health.
- Armor.
- Regeneration.
- Tipos/counters configurables.
- Pipeline de daño central.
- UI debug de estadísticas.
- Resultado: enemigos requieren respuestas diferentes.

Contrato de la primera implementación M7: toda torre inyecta un `DamagePacket` en el `DamageService` de la escena `Main`; el servicio único resuelve tags de daño, armadura, vida y contrarregeneración. `EnemyData` configura armadura, regeneración por segundo y multiplicadores recibidos de daño físico/fuego/arcano. La regeneración acumula fracciones y nunca supera la vida máxima. Los perfiles de `Basic Bolt`, `Perforadora M7` y `Drenadora M7`, además de la oleada de diagnóstico con un blindado regenerador, son placeholders verificables y no balance final. El HUD de M7 ofrecía atajos 1–3; tras el roster M9.5 Ballista ocupa `1` y los perfiles de diagnóstico se acceden con `8`/`9`. `F3` mantiene el panel técnico y las oleadas básica/diagnóstica se pueden repetir para pruebas. M7 no procesa aún status, modificadores de run, recompensas ni economía: corresponden a M8/M11/M9. ADR-0010 registra fórmula, propiedad del servicio y provisionalidades; ADR-0011 documenta el HUD temporal de prueba.

## M8 — Status Effects
Implementar framework, no catálogo enorme.
- Slow.
- Burn.
- Poison o Bleed (elegir uno como tercer ejemplo provisional).
- Duración, stacks/reglas configurables.
- Resistencias si se necesitan.
- Resultado: status combinables con torres.

Contrato de la primera implementación: `StatusEffectData` es un Resource configurable; cada `Enemy` posee un controlador de efectos con estado runtime propio y cada torre declara payloads en `TowerData`. Slow reduce velocidad, Burn y Bleed hacen daño periódico a través del `DamageService`, y los estados duran, refrescan o acumulan según sus datos. Se selecciona Bleed como tercer ejemplo M8 provisional; no confirma por sí mismo el catálogo final. No se añaden resistencias porque el diseño todavía no define resistencias de estado. La escena de depuración ofrece `Sonda de estados M8` y una oleada de un enemigo de entrenamiento para verificar acumulación, refresco, ticks, expiración y limpieza; el roster M9.5 reasigna la Sonda al atajo `0`. Poison se incorpora como cuarto tag/status para el arquetipo M9.5. La aceptación manual sigue pendiente; ver [10_ACCEPTANCE_TESTS.md](10_ACCEPTANCE_TESTS.md) y [ADR-0012](../decisiones/ADR-0012-framework-de-estados-m8.md).

## M9 — Economía de run + maná
- Moneda de construcción.
- Costes de torres/upgrades.
- Recompensa por kills/ronda.
- Maná.
- Regen/capacidad.
- Sin support buildings.
- Resultado: economía jugable.

Contrato de implementación M9: `RunEconomyService` pertenece a `Main` y configura su estado desde `RunEconomyData`; el oro de la run no usa `MetaProgression.meta_currency`. `TowerData` define coste de construcción, coste por cada nivel de mejora y maná por ataque; `EnemyData` define recompensa por baja y `WaveData` la recompensa de ronda. Una baja concede su recompensa una sola vez; llegar a la base no la concede. La recompensa de ronda solo se paga al completar todos los spawns con cero enemigos vivos. Mejoras y construcciones verifican y cobran antes de confirmar la mutación. El maná se consume antes de disparar y, si falta, la torre espera; la regeneración y capacidad son configurables. Los costes y cifras de arranque de esta primera integración son provisionales, no balance final. La escena de prueba mantiene replay de oleadas M7/M8; esto no implementa la secuencia completa M10.

## M9.5 — Roster jugable de demo (prioridad del usuario)
- Crear los siete perfiles aceptados: Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder.
- Dar a cada perfil un ataque, estado/coste de maná si aplica, forma vectorial provisional y acceso de construcción en gameplay.
- Mantener los fixtures de diagnóstico M7/M8 disponibles sin desplazar el roster principal.
- Actualizar datos, aceptación y ADR antes de comenzar Cards.
- Resultado: siete torres seleccionables y construibles que pueden probarse en la escena principal.

El usuario pidió expresamente cerrar este roster antes de avanzar a M10/M11. Por ello M9.5 se ejecuta tras M9; al aceptar esta fase, M10 vuelve a ser el siguiente milestone del roadmap. Los números quedan configurables. M9.5 no implementa todavía Shield; las tres capas y sus counters están confirmados para un hito posterior. No se copia el balance comunitario.

## M10 — Rondas 1-20
- `WaveData` data-driven.
- Director de oleadas.
- Escalado provisional.
- Ronda termina solo cuando no quedan enemigos pendientes/vivos.
- Cada pulso de campaña genera enemigos simultáneamente en todos los endpoints PATH abiertos y alcanzables.
- Tras ronda: ofrecer tres piezas distintas, bloquear el combate hasta seleccionar y colocar una, y rellenar huecos interiores con Grass/Montaña aleatorios.
- Ronda 20 completa demo.
- Resultado: run completa técnicamente.

Contrato M10: la campaña contiene un `WaveData` validado por ronda y una sola ronda de campaña puede iniciarse por vez. Las rondas 17 y 19 contienen minijefe y la 20 un jefe Tier 2 genérico hasta elegir variante; estos hitos provienen de las reglas propias confirmadas en `docs/borradores_personales/02_monstruos.md`. Las estadísticas, composición normal y crecimiento de salud/daño/recompensa son placeholders configurables; no se copian valores ni habilidades de Rogue Tower. En cada pulso de campaña se genera simultáneamente un enemigo por cada endpoint PATH abierto y alcanzable; `WaveEnemyGroupData.count` representa pulsos por endpoint y el contador pendiente refleja el total de rutas. Cada oleada termina con cero spawns pendientes y cero enemigos vivos. Tras las rondas 1–19, `TERRAIN_EXPANSION` ofrece tres piezas distintas y bloquea el combate hasta elegir una y confirmar exactamente una colocación válida conectada; `Esc` durante esa colocación vuelve a la oferta existente. Tras confirmar, los huecos encerrados del tablero se rellenan al azar con Grass/Montaña, preservando aberturas PATH de spawn, y después se prepara la siguiente ronda. La ronda 20 pasa a `RUN_VICTORY`. Los fixtures M7/M8 quedan etiquetados `DEBUG`, sin avance de campaña, pagos ni daño a base. Esta oferta selecciona piezas de terreno; las cartas de mejoras `CardData` siguen en M11. Capas Shield/Armor/Health y meta-progresión no forman parte de M10.

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
- 7 torres de demo (roster confirmado y adelantado a M9.5; número total del juego final sigue abierto).
- 5-8 arquetipos de enemigo.
- 4 status placeholder: Slow, Burn, Bleed y Poison.
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
