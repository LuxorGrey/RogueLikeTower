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
- Crear cinco piezas placeholder iniciales (ampliadas a quince en M18).
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

Contrato técnico del prototipo: grafo axial propio y BFS determinista sin costes; aplica las ofertas exactas/flexibles de [ADR-0006](../decisions/ADR-0006-sockets-laterales-flexibles-de-camino.md). La base actual `(0,0)` es provisional y se documenta en [ADR-0007](../decisions/ADR-0007-grafo-logico-de-caminos.md). M4 solo expone candidatos; M5 añade a `WaveDirector` una política configurable por grupo y usa `FIRST_SORTED` en la demo.

## M5 — Enemigo básico + objetivo
- Base/objetivo con Health.
- Enemy scene.
- Movimiento por ruta.
- Spawn wave.
- Llegada a base causa daño.
- Health y muerte.
- Resultado: primera oleada funcional.

Contrato histórico del prototipo M5: la base temporal se dibujaba sobre PATH `(0,0)` y la primera oleada salía del primer endpoint ordenado. La campaña actual conserva la base, pero usa un tablero semilla de radio axial 2 (19 celdas) con un mínimo de cuatro celdas PATH por ruta spawn-base, según [ADR-0025](../decisions/ADR-0025-tablero-inicial-y-ruta-minima.md). Los valores de enemigos y base descritos en ADR-0008 eran fixtures provisionales de M5; la campaña actual usa los Resources de `data/waves/` y `data/enemies/`. Durante combate se bloquea la colocación; al completar se habilita expansión. Los fixtures de depuración M7/M8 no son la progresión de campaña M10.

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

Contrato de la primera implementación M7: toda torre inyecta un `DamagePacket` en el `DamageService` de la escena `Main`; el servicio único resuelve tags de daño, Armor, Health y contrarregeneración. `EnemyData` configura Armor, regeneración por segundo y multiplicadores recibidos de daño físico/fuego/arcano. La regeneración acumula fracciones y nunca supera la Health máxima. Los perfiles de `Basic Bolt`, `Armor Piercing Bolt` y `Sapping Bolt`, además de la oleada de diagnóstico con un Armored Regenerator, son placeholders verificables y no balance final. El HUD de M7 ofrecía atajos 1–3; tras el roster M9.5 Ballista ocupa `1` y los perfiles de diagnóstico se acceden con `8`/`9`. `F3` mantiene el panel técnico y las oleadas básica/diagnóstica se pueden repetir para pruebas. M7 no procesa aún status, modificadores de run, recompensas ni economía: corresponden a M8/M11/M9. ADR-0010 registra fórmula, propiedad del servicio y provisionalidades; ADR-0011 documenta el HUD temporal de prueba.

## M8 — Status Effects
Implementar framework, no catálogo enorme.
- Slow.
- Burn.
- Poison o Bleed (elegir uno como tercer ejemplo provisional).
- Duración, stacks/reglas configurables.
- Resistencias si se necesitan.
- Resultado: status combinables con torres.

Contrato de la primera implementación: `StatusEffectData` es un Resource configurable; cada `Enemy` posee un controlador de efectos con estado runtime propio y cada torre declara payloads en `TowerData`. Slow reduce velocidad, Burn y Bleed hacen daño periódico a través del `DamageService`, y los estados duran, refrescan o acumulan según sus datos. Se selecciona Bleed como tercer ejemplo M8 provisional; no confirma por sí mismo el catálogo final. No se añaden resistencias porque el diseño todavía no define resistencias de estado. La escena de depuración ofrece `Status Probe (DEBUG)` y una oleada de un enemigo de entrenamiento para verificar acumulación, refresco, ticks, expiración y limpieza; el roster M9.5 reasigna la Status Probe al atajo `0`. Poison se incorpora como cuarto tag/status para el arquetipo M9.5. La aceptación manual sigue pendiente; ver [10_ACCEPTANCE_TESTS.md](10_ACCEPTANCE_TESTS.md) y [ADR-0012](../decisions/ADR-0012-framework-de-estados-m8.md).

## M9 — Economía de run + Mana
- Moneda de construcción.
- Costes de torres/upgrades.
- Recompensa por kills/ronda.
- Mana.
- Regen/capacidad.
- Sin support buildings.
- Resultado: economía jugable.

Contrato de implementación M9: `RunEconomyService` pertenece a `Main` y configura su estado desde `RunEconomyData`; el Gold de la run no usa `MetaProgression.meta_currency`. `TowerData` define coste de construcción, coste por cada nivel de mejora y Mana por ataque; `EnemyData` define recompensa por baja y `WaveData` la recompensa de ronda. Una baja concede su recompensa una sola vez; llegar a la base no la concede. La recompensa de ronda solo se paga al completar todos los spawns con cero enemigos vivos. Mejoras y construcciones verifican y cobran antes de confirmar la mutación; el atajo de una torre inasequible queda deshabilitado y atenuado. El Mana se consume antes de disparar y, si falta, la torre espera; la regeneración y capacidad son configurables. El perfil provisional empieza con la reserva completa, y la regeneración se describe sin decimales mediante equivalencias enteras sin cambiar su tasa interna. Los costes y cifras de arranque de esta primera integración son provisionales, no balance final. La escena de prueba mantiene replay de oleadas M7/M8; esto no implementa la secuencia completa M10.

## M9.5 — Roster jugable de demo (prioridad del usuario)
- Crear los siete perfiles aceptados: Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder.
- Dar a cada perfil un ataque, estado/coste de Mana si aplica, forma vectorial provisional y acceso de construcción en gameplay.
- Mantener los fixtures de diagnóstico M7/M8 disponibles sin desplazar el roster principal.
- Actualizar datos, aceptación y ADR antes de comenzar Cards.
- Resultado: siete torres seleccionables y construibles que pueden probarse en la escena principal.

El usuario pidió expresamente cerrar este roster antes de avanzar a M10/M11. Por ello M9.5 se ejecuta tras M9; al aceptar esta fase, M10 vuelve a ser el siguiente milestone del roadmap. La decisión histórica de aplazar Shield quedó sustituida por el alcance añadido en M12A y ADR-0023.

## M10 — Campaña de 45 rondas

- Cargar las 45 WaveData del roster y la tabla de composición aprobada.
- Crear exactamente el número directo de cada grupo, con orden y cantidad de la tabla.
- Repartir spawns secuencialmente entre endpoints alcanzables con round-robin; más rutas cambian la distribución, no el total.
- Mantener por separado spawns pendientes y enemigos activos; invocaciones y transformaciones participan en la vida de la ronda.
- Implementar habilidades configuradas por EnemyAbilityData y el kit propio de Ooogie von Ooogovich.
- Finalizar la demo después de limpiar la ronda 45.
- Tras limpiar 1–44, ofrecer y colocar una expansión; mantener el loop de terreno y la fase de cartas M11.
- Resultado: campaña de 45 rondas completa.

Contrato vigente: WaveCampaignData valida 45 entradas, continuidad de round_number, tipo de encuentro derivado de boss_tier y 1.093 enemigos directos. WaveEnemyGroupData.count es la cantidad real del grupo. Cada enemigo se asigna a una ruta por vez; las invocaciones añaden unidades fuera del total directo. Cyclops y Werewolf no son Minibosses especiales en las rondas 17/19: la tabla seleccionada manda. Ooogie von Ooogovich conserva su identidad y kit adaptado, con balance propio provisional, invoca dos Bats cada 2 s y se transforma en Bat con 2.500 Health. Su instancia y recompensa sobreviven la transformación; la oleada espera la derrota final. Los perfiles normales adoptan parámetros base y habilidades documentados en ADR-0037; no hay crecimiento global de Health, daño ni recompensa por baja. Frost Keep usa daño 2, 120 RPM y Slow ×0,85 durante 1 s; Tesla Coil usa daño 9. La tabla exacta y las cadencias/recompensas provisionales están en [14 — Campaña de 45 rondas](14_CAMPANA_45_RONDAS.md), el contenido y escalado por entidad en [13 — Catálogo de contenido](13_CONTENT_ROSTER.md), y las decisiones en [ADR-0037](../decisions/ADR-0037-campana-de-45-rondas-y-habilidades.md). Los acuerdos previos de M10 se conservan solo como historial en sus ADR sustituidos.

## M11 — Cards
- `CardModifierOperation`, `CardData`, `CardPoolData` y `RunCardService` mantienen definición de contenido, calendario/oferta y selección separados.
- En las rondas configuradas, presentar tres cartas de mejora distintas después de colocar la expansión de terreno y antes de habilitar la ronda siguiente. Una elección obligatoria conserva la fase en `CARD_OFFER` hasta seleccionar.
- Pool con filtro `unlock_requirement`, peso de oferta, `max_per_run` y selección sin reemplazo dentro de cada oferta.
- Aplicar operaciones runtime sin mutar `.tres`: daño plano/multiplicador, alcance, multiplicador H/A/S, crítico, radio de área, coste de Mana, duración de estados, capacidad y regeneración de Mana. RPM permanece fijo, salvo el Frost Keep por cobertura PATH.
- El servicio se inyecta en torres y economía de la escena; los efectos modifican también torres ya colocadas y el preview correspondiente.
- Primer pool de 12 cartas placeholder; siete requieren unlock de torre, las demás son globales/Mana. M12 provee la fuente persistente de estos IDs y añade dos cartas ligadas al Archivo; M12A suma una carta global de crítico y tres de multiplicador H/A/S (18 Resources en total).
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

Contrato M12 implementado: `MetaProgression` conserva su estado fuera de las escenas de run; cada run concede moneda al terminar por victoria o derrota, con recompensa calculada a partir de rondas completas y un bonus de victoria configurable. La tienda terminal permite desbloquear perfiles `TowerData`, comprar niveles de `PermanentUpgradeData` y empezar otra run. Las torres bloqueadas no aparecen en la barra de construcción ni habilitan cartas específicas; el desbloqueo del Archivo de cartas suma contenido al pool M11. Las mejoras afectan Gold inicial, capacidad/regeneración de Mana y daño de torres en runs posteriores. `SaveData` serializa solo primitivas en JSON versionado dentro de `user://`, con escritura temporal y copia `.bak`; un save corrupto o de otra versión se conserva sin sobrescribirse y bloquea las compras. Ballista como única torre inicial, la economía/recompensa, costes, incrementos y los cinco upgrades actuales son fixtures provisionales configurables en Resources, no balance confirmado. La prueba manual M12 sigue pendiente; ver `10_ACCEPTANCE_TESTS.md` y [ADR-0022](../decisions/ADR-0022-meta-progression-y-guardado.md).

## M12A — Reglas de torres, mejoras y capas H/A/S
- `EnemyData` y Enemy modelan los pools de Health, Armor y Shield con regeneración independiente. Cada perfil configura sus tres máximos; un máximo cero desactiva esa capa para ese enemigo. Resolver Shield→Armor→Health y dibujar una fila por capa con máximo positivo, con Health segmentada.
- Alinear los siete `TowerData` con la tabla que compartió el usuario; todos los stats permanecen configurables y el balance se considera provisional.
- Implementar disparos de Ballista/Mortar, área de Mortar, descarga de Tesla contra todos los enemigos en rango, rango/área cuadrada y RPM por cobertura de Frost, conos de Flame/Poison y hoja perforante de Shredder.
- Cada nivel añade +1 de daño base y +1 a una capa H/A/S, al comprarse con Gold o al subir por XP mientras mantiene un objetivo. La torre muestra stats y XP por capa.
- Añadir crítico por bandas, hasta tres prioridades de objetivo, precio por cantidad de torres del mismo tipo y demolición que reduce el siguiente precio.
- Añadir una oleada DEBUG Health/Armor/Shield para verificar barra, daño, bonus +1 de ataque de cada estado y bloqueo de regeneración Bleed/Burn/Poison. Los ticks aplican daño completo a su capa asociada y mitad a las otras.
- Resultado: los siete perfiles y las capas defensivas se pueden inspeccionar, mejorar y probar en `Main` sin alterar stats compartidos ni la campaña.

M12A está implementado en código; la aceptación manual sigue pendiente. Las reglas de capas y estados coinciden con las páginas de referencia indicadas en ADR-0023 y con la confirmación del usuario. Las cifras del roster y el pool siguen siendo configurables/provisionales. El exceso de daño al vaciar una capa se descarta según la implementación; la página de referencia no describe expresamente el overkill, por lo que esa decisión permanece provisional. Los criterios están en `10_ACCEPTANCE_TESTS.md` y [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md).

## M13 — UX/UI
- HUD en tres paneles: recursos arriba a la izquierda, ronda/progreso/acción arriba al centro y estadísticas/acciones de torre a la derecha.
- Barra de Health de base con valor superpuesto y segmentos de 10; sprite de base intercambiable desde `BaseData`. Gold y Mana usan iconos reutilizables, con mayor énfasis para Gold; al cambiar, su icono y cifra escalan y rebotan.
- El Mana se repone al máximo efectivo cuando empieza cada ronda de campaña, y se presenta como entero sin alterar la precisión de los cálculos internos.
- Al seleccionar una torre, mostrar en líneas legibles nivel, daño, multiplicadores H/A/S con iconos de Health/Armor/Shield, alcance, RPM, crítico, patrón, Mana y XP; conservar prioridades, mejoras y demolición en el panel derecho, que desaparece al deseleccionar.
- PNG RGBA transparentes e independientes, uno por objeto, para moneda, energía, Health/Armor/Shield, siete torres y cuatro estados; no se usa atlas. Los atajos inferiores usan un fondo individual estilo carta y los mismos iconos de la selección, preview y torre colocada; el contenedor no dibuja un panel común.
- Hover/selección de torre muestra alcance y contorno; el panel lateral ajusta su altura al contenido, nunca usa scroll, y un menú de prioridades permite seleccionar hasta tres criterios.
- Enemigos muestran barras apiladas por Shield/Armor/Health con Health fragmentada, iconos de estados y contador de acumulaciones; el daño tiene destello, salto y texto flotante coloreado por capa.
- Las cards de mejora incluyen el icono de torre afectada. Los textos de economía/campaña y descripciones convierten Gold/Mana en iconos PNG reutilizables.
- La inspección técnica de enemigos y la selección de fixtures DEBUG se pliegan bajo `F3`; las estadísticas de objetivo siguen accesibles como tooltip de la torre seleccionada.
- Preview/selección de pieza y controles de rotación/confirmación/cancelación conservan indicaciones de uso y tooltips.
- Pantalla terminal clara para victoria/derrota: resultado, ronda alcanzada, rondas completas, recompensa y saldo de moneda meta.
- Tienda de fin de run separa desbloqueos de torres y mejoras permanentes en categorías; muestra coste, estado de compra, efecto y acción de nueva run sin mezclar la moneda meta con el Gold de partida.
- Tooltips explican atajos, coste, patrón de ataque, mejoras, prioridades y operaciones de terreno.
- Lenguaje visual consistente con el tablero: placas oscuras azul pizarra, bordes de acero, acciones ámbar, éxitos verde bosque y derrota terracota; sin assets externos.
- Resultado: todos los sistemas comprensibles sin debug.

Contrato base de M13 registrado en [ADR-0026](../decisions/ADR-0026-jerarquia-ux-ui.md); la distribución en tres paneles, iconos raster transparentes y feedback de combate se especifican en [ADR-0027](../decisions/ADR-0027-hud-en-tres-paneles-e-iconos-vectoriales.md), [ADR-0028](../decisions/ADR-0028-iconos-png-y-feedback-visual.md), [ADR-0031](../decisions/ADR-0031-png-individuales-por-objeto.md) y [ADR-0038](../decisions/ADR-0038-base-sprite-y-feedback-del-hud.md). La interfaz está implementada en código; falta la aceptación manual en ventana Godot según `10_ACCEPTANCE_TESTS.md`. El roster, las cifras y la economía no se rebalancean en este milestone.

## M14 — Vertical Slice
Contenido provisional suficiente:
- 7 torres de demo (roster confirmado y adelantado a M9.5; número total del juego final sigue abierto).
- 5-8 arquetipos de enemigo.
- 4 status placeholder: Slow, Burn, Bleed y Poison.
- 12-20 cartas.
- 15 piezas de terreno disponibles tras M18.
- 8-15 permanentes.
Estas cantidades NO son compromiso de diseño final.
- Balance preliminar de campaña de 45 rondas.
- Resultado: demo jugable de principio a fin.

## M15 — Arte Urtuk-like pipeline
- Sustituir placeholders sin tocar lógica.
- Top sprites de hex.
- Cliffs por elevación/bordes.
- Props que pueden sobresalir visualmente.
- Mantener footprint lógico limpio.
- Variantes visuales.
- Tres variantes PNG por tipo Path/Grass/Mountain y cinco obstáculos transparentes asignados por semilla a celdas reales. Obstáculos bloquean construcción.
- Resultado: mapa orgánico que oculta la rigidez de la grid.

## M16 — Polish
- Audio.
- VFX; los primeros efectos de impacto se integran por torre con las hojas locales Tiny Swords proporcionadas por el usuario.
- Cursores de Tiny Swords para normal, hover interactivo, acción inválida y colocación de torre.
- Feedback impactos.
- Transiciones.
- Cámara.
- Performance profiling.
- Balance.
- QA/save migration.

## M17 — Profundidad, arte y flujo de rutas
- Alinear atlas/terreno con caras hexagonales y separar props en nodos individuales.
- Ordenar profundidad compartida entre unidades, base, torres y decoración.
- Mostrar flechas animadas sobre cada ruta hacia la base y reducir la tasa inicial de cofres al 1 %.
- Revisar tamaño individual de sprites y documentar la aceptación visual.
- Resultado: oclusión y rutas legibles en mapas con expansiones.

## M18 — Elevación, feedback y diversidad de terreno
- Ordenar copias texturadas de las tapas elevadas con base, torres, enemigos, portales y props. Las fachadas quedan bajo las entidades y se omiten los bordes traseros; consulta [ADR-0043](../decisions/ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md).
- Ocultar bordes y sockets de grid hasta hover, con dos anillos vecinos de opacidad decreciente.
- Reemplazar etiquetas de spawn por un sprite PNG de portal pulsante; conservar flechas animadas del `PathGraph` hacia la base.
- Reducir y pulsar el cursor de construcción, animar el icono de torre construida y compactar/aumentar la barra de torres.
- Añadir diez piezas de terreno equilibradas sobre la huella estándar de siete hexes.
- Actualizar diseño, aceptación, ADR y progreso; revisar visualmente profundidad y navegación.
- Resultado: lectura del tablero clara con variedad de composición y sin cambiar la topología lógica.
