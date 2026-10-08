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

Contrato histórico del prototipo M5: la base temporal se dibujaba sobre PATH `(0,0)` y la primera oleada salía del primer endpoint ordenado. La campaña actual conserva la base, pero usa un tablero semilla de radio axial 2 (19 celdas) con un mínimo de cuatro celdas PATH por ruta spawn-base, según [ADR-0025](../decisiones/ADR-0025-tablero-inicial-y-ruta-minima.md). Los valores de enemigos y base descritos en ADR-0008 eran fixtures provisionales de M5; la campaña actual usa los Resources de `data/waves/` y `data/enemies/`. Durante combate se bloquea la colocación; al completar se habilita expansión. Los fixtures de depuración M7/M8 no son la progresión de campaña M10.

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

El usuario pidió expresamente cerrar este roster antes de avanzar a M10/M11. Por ello M9.5 se ejecuta tras M9; al aceptar esta fase, M10 vuelve a ser el siguiente milestone del roadmap. La decisión histórica de aplazar Shield quedó sustituida por el alcance añadido en M12A y ADR-0023.

## M10 — Rondas 1-20
- `WaveData` data-driven.
- Director de oleadas.
- Escalado provisional.
- Ronda termina solo cuando no quedan enemigos pendientes/vivos.
- Cada pulso de campaña genera enemigos simultáneamente en todos los endpoints PATH abiertos y alcanzables.
- Tras ronda: ofrecer tres piezas distintas, bloquear el combate hasta seleccionar y colocar una, y rellenar huecos interiores con Grass/Montaña aleatorios.
- Ronda 20 completa demo.
- Resultado: run completa técnicamente.

Contrato M10: la campaña contiene un `WaveData` validado por ronda y una sola ronda de campaña puede iniciarse por vez. Las rondas 17 y 19 contienen minijefe y la 20 un jefe Tier 2 genérico hasta elegir variante; estos hitos provienen de las reglas propias confirmadas en `docs/borradores_personales/02_monstruos.md`. Las estadísticas, composición normal y crecimiento de salud/daño/recompensa son placeholders configurables; no se copian valores ni habilidades de Rogue Tower. En cada pulso de campaña se genera simultáneamente un enemigo por cada endpoint PATH abierto y alcanzable; `WaveEnemyGroupData.count` representa pulsos por endpoint y el contador pendiente refleja el total de rutas. Cada oleada termina con cero spawns pendientes y cero enemigos vivos. Tras las rondas 1–19, `TERRAIN_EXPANSION` ofrece tres piezas distintas y bloquea el combate hasta elegir una y confirmar exactamente una colocación válida conectada; `Esc` durante esa colocación vuelve a la oferta existente. Tras confirmar, los huecos encerrados del tablero se rellenan al azar con Grass/Montaña, preservando aberturas PATH de spawn, y después se prepara la siguiente ronda, salvo que M11 solicite primero una elección de mejora. La ronda 20 pasa a `RUN_VICTORY`. Los fixtures M7/M8 quedan etiquetados `DEBUG`, sin avance de campaña, pagos ni daño a base. Esta oferta selecciona piezas de terreno; las cartas de mejoras `CardData` siguen en M11. Capas Shield/Armor/Health y meta-progresión no forman parte de M10.

## M11 — Cards
- `CardModifierOperation`, `CardData`, `CardPoolData` y `RunCardService` mantienen definición de contenido, calendario/oferta y selección separados.
- En las rondas configuradas, presentar tres cartas de mejora distintas después de colocar la expansión de terreno y antes de habilitar la ronda siguiente. Una elección obligatoria conserva la fase en `CARD_OFFER` hasta seleccionar.
- Pool con filtro `unlock_requirement`, peso de oferta, `max_per_run` y selección sin reemplazo dentro de cada oferta.
- Aplicar operaciones runtime sin mutar `.tres`: daño plano/multiplicador, alcance, multiplicador H/A/E, crítico, radio de área, coste de maná, duración de estados, capacidad y regeneración de maná. RPM permanece fijo, salvo el Frost Keep por cobertura PATH.
- El servicio se inyecta en torres y economía de la escena; los efectos modifican también torres ya colocadas y el preview correspondiente.
- Primer pool de 12 cartas placeholder; siete requieren unlock de torre, las demás son globales/maná. M12 provee la fuente persistente de estos IDs y añade dos cartas ligadas al Archivo; M12A suma una carta global de crítico y tres de multiplicador H/A/E (18 Resources en total).
- Calendario provisional centralizado en `data/cards/demo_card_pool.tres`: primera oferta al limpiar ronda 3, después cada 3 rondas (3, 6, 9, 12, 15, 18). No cierra la frecuencia ni el balance finales.
- Resultado: elecciones que producen builds diferentes dentro de la run. La persistencia y desbloqueos entre runs siguen siendo M12.

## M12 — Meta-progression
- Moneda permanente.
- Recompensa al perder/completar.
- Tienda.
- PermanentUpgradeData.
- Desbloqueo de torres.
- Mejoras permanentes simples.
- SaveGame.
- Resultado: morir -> mejorar -> nueva run.

Contrato M12 implementado: `MetaProgression` conserva su estado fuera de las escenas de run; cada run concede moneda al terminar por victoria o derrota, con recompensa calculada a partir de rondas completas y un bonus de victoria configurable. La tienda terminal permite desbloquear perfiles `TowerData`, comprar niveles de `PermanentUpgradeData` y empezar otra run. Las torres bloqueadas no aparecen en la barra de construcción ni habilitan cartas específicas; el desbloqueo del Archivo de cartas suma contenido al pool M11. Las mejoras afectan oro inicial, capacidad/regeneración de maná y daño de torres en runs posteriores. `SaveData` serializa solo primitivas en JSON versionado dentro de `user://`, con escritura temporal y copia `.bak`; un save corrupto o de otra versión se conserva sin sobrescribirse y bloquea las compras. Ballista como única torre inicial, la economía/recompensa, costes, incrementos y los cinco upgrades actuales son fixtures provisionales configurables en Resources, no balance confirmado. La prueba manual M12 sigue pendiente; ver `10_ACCEPTANCE_TESTS.md` y [ADR-0022](../decisiones/ADR-0022-meta-progression-y-guardado.md).

## M12A — Reglas de torres, mejoras y capas H/A/E
- Completar `EnemyData` con escudo y regeneración independiente por Shield, Armor y Health; resolver capas en ese orden y mostrar una barra segmentada para el jugador.
- Alinear los siete `TowerData` con la tabla que compartió el usuario; todos los stats permanecen configurables y el balance se considera provisional.
- Implementar disparos de Ballista/Mortar, área de Mortar, descarga de Tesla contra todos los enemigos en rango, rango/área cuadrada y RPM por cobertura de Frost, conos de Flame/Poison y hoja perforante de Shredder.
- Cada nivel añade +1 de daño base y +1 a una capa H/A/E, al comprarse con oro o al subir por XP mientras mantiene un objetivo. La torre muestra stats y XP por capa.
- Añadir crítico por bandas, hasta tres prioridades de objetivo, precio por cantidad de torres del mismo tipo y demolición que reduce el siguiente precio.
- Añadir una oleada DEBUG H/A/E para verificar barra, daño y bloqueo de regeneración Bleed/Burn/Poison.
- Resultado: los siete perfiles y las capas defensivas se pueden inspeccionar, mejorar y probar en `Main` sin alterar stats compartidos ni la campaña.

Contrato M12A implementado en código, con aceptación manual pendiente. Las reglas/números de la tabla que pegó el usuario prevalecen para este conjunto de perfiles. Son provisionales el overkill (el excedente no atraviesa de una capa a otra), los costes de upgrade, umbrales de XP, áreas exactas, velocidades y la falta de reembolso al demoler. Los criterios están en `10_ACCEPTANCE_TESTS.md` y las decisiones en [ADR-0023](../decisiones/ADR-0023-reglas-de-torres-y-capas-de-vida.md).

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
