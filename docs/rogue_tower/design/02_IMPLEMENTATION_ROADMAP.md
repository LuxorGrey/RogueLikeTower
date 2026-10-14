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

Contrato técnico del prototipo: grafo axial propio y BFS determinista sin costes; aplica las ofertas exactas/flexibles de [ADR-0006](../decisions/ADR-0006-sockets-laterales-flexibles-de-camino.md). La referencia M4 a la base `(0,0)` es histórica; el tablero activo usa `(-1,0)` y una ruta recta según [ADR-0056](../decisions/ADR-0056-tablero-inicial-lineal.md). M4 solo expone candidatos; M5 añade a `WaveDirector` una política configurable por grupo y usa `FIRST_SORTED` en la demo.

## M5 — Enemigo básico + objetivo
- Base/objetivo con Health.
- Enemy scene.
- Movimiento por ruta.
- Spawn wave.
- Llegada a base causa daño.
- Health y muerte.
- Resultado: primera oleada funcional.

Contrato histórico del prototipo M5: la base temporal se dibujaba sobre PATH `(0,0)` y la primera oleada salía del primer endpoint ordenado. La campaña actual usa un tablero semilla de radio axial 2 (19 celdas), base en `(-1,0)` y un mínimo de cuatro celdas PATH por ruta spawn-base, con trazado recto según [ADR-0025](../decisions/ADR-0025-tablero-inicial-y-ruta-minima.md) y [ADR-0056](../decisions/ADR-0056-tablero-inicial-lineal.md). Los valores de enemigos y base descritos en ADR-0008 eran fixtures provisionales de M5; la campaña actual usa los Resources de `data/waves/` y `data/enemies/`. Durante combate se bloquea la colocación; al completar se habilita expansión. Los fixtures de depuración M7/M8 no son la progresión de campaña M10.

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

Contrato vigente: WaveCampaignData valida 45 entradas, continuidad de round_number, tipo de encuentro derivado de boss_tier y 1.093 enemigos directos. WaveEnemyGroupData.count es la cantidad real del grupo. Cada enemigo se asigna a una ruta por vez; las invocaciones añaden unidades fuera del total directo. Cyclops y Werewolf no son Minibosses especiales en las rondas 17/19: la tabla seleccionada manda. Ooogie von Ooogovich conserva su identidad y kit adaptado, con balance propio provisional, invoca dos Bats cada 2 s y se transforma en Bat con 2.500 Health. Su instancia y recompensa sobreviven la transformación; la oleada espera la derrota final. Los perfiles normales adoptan parámetros base y habilidades documentados en ADR-0037; no hay crecimiento global de Health, daño ni recompensa por baja. Frost Keep usa copos individuales de daño 6 a 180 RPM, Slow proporcional al daño y gasto continuo de 2 Mana/s, según ADR-0059; Tesla Coil usa daño 9. La tabla exacta y las cadencias/recompensas provisionales están en [14 — Campaña de 45 rondas](14_CAMPANA_45_RONDAS.md), el contenido y escalado por entidad en [13 — Catálogo de contenido](13_CONTENT_ROSTER.md), y las decisiones en [ADR-0037](../decisions/ADR-0037-campana-de-45-rondas-y-habilidades.md). Los acuerdos previos de M10 se conservan solo como historial en sus ADR sustituidos.

## M11 — Cards
- `CardModifierOperation`, `CardData`, `CardPoolData` y `RunCardService` mantienen definición de contenido, calendario/oferta y selección separados.
- En las rondas configuradas, presentar tres cartas de mejora distintas después de colocar la expansión de terreno y antes de habilitar la ronda siguiente. Una elección obligatoria conserva la fase en `CARD_OFFER` hasta seleccionar.
- Pool con filtro `unlock_requirement`, peso de oferta, `max_per_run` y selección sin reemplazo dentro de cada oferta.
- Aplicar operaciones runtime sin mutar `.tres`: daño plano/multiplicador, alcance, multiplicador H/A/S, crítico, radio de área, coste de Mana, duración de estados, capacidad y regeneración de Mana. RPM permanece fijo, salvo el Frost Keep por cobertura PATH.
- El servicio se inyecta en torres y economía de la escena; los efectos modifican también torres ya colocadas y el preview correspondiente.
- Pool inicial M11 de 18 cards placeholder, descrito como historial de implementación. Su catálogo vigente combina 172 Resources nuevos y la Advanced Circuits existente para representar 173 entradas compatibles (190 IDs únicos con las 18 propias). Ver ADR-0062.
- Calendario vigente centralizado en `data/cards/demo_card_pool.tres`: tras colocar expansión, ofrecer carta cada tres rondas entre 3 y 42. La cadencia está confirmada por ADR-0062; tamaños, rarezas y balance siguen provisionales.
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

Contrato M12 implementado: `MetaProgression` conserva su estado fuera de las escenas de run; cada run concede moneda al terminar por victoria o derrota, con recompensa calculada a partir de rondas completas y un bonus de victoria configurable. La tienda terminal permite desbloquear perfiles `TowerData`, comprar los 31 `PermanentUpgradeData` y empezar otra run. Las torres bloqueadas no aparecen en la barra de construcción ni habilitan cartas específicas; el Archivo de cartas suma contenido al pool M11. Los upgrades afectan Gold, Mana, daño H/A/S de torres, opciones de cards y vida/reparación de la base en runs posteriores. `SaveData` serializa solo primitivas en JSON versionado dentro de `user://`, con escritura temporal y copia `.bak`; un save corrupto o de otra versión se conserva sin sobrescribirse y bloquea las compras. Ballista como única torre inicial, economía/recompensa, costes e incrementos son configurables/provisionales, no balance confirmado. La prueba manual M12 sigue pendiente; ver `10_ACCEPTANCE_TESTS.md` y [ADR-0022](../decisions/ADR-0022-meta-progression-y-guardado.md)/[ADR-0062](../decisions/ADR-0062-catalogo-de-upgrade-cards-y-permanent-upgrades.md).

## M12A — Reglas de torres, mejoras y capas H/A/S
- `EnemyData` y Enemy modelan los pools de Health, Armor y Shield con regeneración independiente. Cada perfil configura sus tres máximos; un máximo cero desactiva esa capa para ese enemigo. Resolver Shield→Armor→Health y dibujar una fila por capa con máximo positivo, con Health segmentada.
- Alinear los siete `TowerData` con la tabla que compartió el usuario; todos los stats permanecen configurables y el balance se considera provisional.
- Implementar disparos de Ballista/Mortar, área de Mortar, descarga de Tesla contra todos los enemigos en rango, caída e impacto individual de los copos Frost sobre PATH en rango cuadrado y RPM por cobertura, conos de Flame/Poison y hoja perforante de Shredder.
- Cada nivel añade +1 de daño base y +1 a una capa H/A/S, al comprarse con Gold o al subir por XP mientras mantiene un objetivo. La torre muestra stats y XP por capa.
- Añadir crítico por bandas, hasta tres prioridades de objetivo, precio por cantidad de torres del mismo tipo y demolición que reduce el siguiente precio.
- Añadir una oleada DEBUG Health/Armor/Shield para verificar barra, daño, bonus +1 de ataque de cada estado y bloqueo de regeneración Bleed/Burn/Poison. Los ticks aplican daño completo a su capa asociada y mitad a las otras.
- Resultado: los siete perfiles y las capas defensivas se pueden inspeccionar, mejorar y probar en `Main` sin alterar stats compartidos ni la campaña.

M12A está implementado en código; la aceptación manual sigue pendiente. Las reglas de capas y estados coinciden con las páginas de referencia indicadas en ADR-0023 y con la confirmación del usuario. Las cifras del roster y el pool siguen siendo configurables/provisionales. El exceso de daño al vaciar una capa se descarta según la implementación; la página de referencia no describe expresamente el overkill, por lo que esa decisión permanece provisional. Los criterios están en `10_ACCEPTANCE_TESTS.md` y [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md).

## M13 — UX/UI
- HUD final según M22: salud y atajos arriba a la izquierda; Gold/Mana arriba a la derecha; oleada centrada con una línea de 45 puntos y botón responsivo. Salud, recursos y ronda no tienen un panel compartido; la información de torre comienza bajo los recursos. Ver [ADR-0048](../decisions/ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md).
- Barra de Health de base con valor superpuesto y segmentos de 10; sprite de base intercambiable desde `BaseData`. Gold y Mana usan iconos reutilizables, con mayor énfasis para Gold; al cambiar, su icono y cifra escalan y rebotan.
- El Mana se repone al máximo efectivo cuando empieza cada ronda de campaña, y se presenta como entero sin alterar la precisión de los cálculos internos.
- Al seleccionar una torre, mostrar en líneas legibles nivel, daño, multiplicadores H/A/S con iconos de Health/Armor/Shield, alcance, RPM, crítico, patrón, Mana y XP; conservar prioridades, mejoras y demolición en el panel derecho, que desaparece al deseleccionar.
- PNG RGBA transparentes e independientes, uno por objeto, para moneda, energía, Health/Armor/Shield, siete torres y cuatro estados; no se usa atlas. Los atajos inferiores usan un fondo individual estilo carta y los mismos iconos de la selección, preview y torre colocada; el contenedor no dibuja un panel común.
- Hover/selección de torre muestra alcance y contorno; el panel lateral ajusta su altura al contenido y nunca usa scroll. Tres selectores numerados ordenan hasta tres criterios de targeting sin duplicados.
- Enemigos muestran barras apiladas por Shield/Armor/Health con Health fragmentada, iconos de estados y contador de acumulaciones; el daño tiene destello, salto y texto flotante coloreado por capa.
- Las cards de mejora incluyen el icono de torre afectada. Los textos de economía/campaña y descripciones convierten Gold/Mana en iconos PNG reutilizables.
- La inspección técnica de enemigos y la selección de fixtures DEBUG se pliegan bajo `F3`; las estadísticas de objetivo siguen accesibles como tooltip de la torre seleccionada.
- Preview/selección de pieza y controles de rotación/confirmación/cancelación conservan indicaciones de uso y tooltips.
- Pantalla terminal clara para victoria/derrota: resultado, ronda alcanzada, rondas completas, recompensa XP y saldo de XP de perfil.
- Tienda de fin de run separa desbloqueos de torres y mejoras permanentes en categorías; muestra coste, estado de compra, efecto y acción de nueva run sin mezclar el XP de perfil con el Gold de partida.
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

## M19 — Auditoría de torres y detalle visual
- Documentar fórmulas runtime frente a la referencia, distinguiendo progresión, Mana, cadencia, crítico, status y capas de daño; mantener las discrepancias propias configurables.
- Corregir la representación de Frost Keep para que Resource/UI describan el cuadrado de alcance que ya aplica el código.
- Añadir pulso de selección en panel, icono, brillo alpha y rango; asegurar que la torre seleccionada se dibuje al frente con celdas elevadas.
- Colocar el hover del tablero sobre superficies por elevación; bajar velocidad, densidad y opacidad de flechas.
- Reforzar feedback de Gold, pulsar cofres al aparecer y desfasar el ciclo de los portales.
- Reducir el almacenamiento de cuatro PNG conservando su dimensión de dibujo y separar 9 tiles + 5 obstáculos en PNG runtime; conservar los atlas fuente.
- Resultado: sistema de torres auditable y respuesta visual inequívoca; aceptación visual manual pendiente.

## M20 — Progresión independiente y selección de torre
- Separar el nivel de Health, Armor y Shield: 15 mejoras posibles por capa, 45 por torre.
- Mantener +1 de daño base por mejora y sumar +1 solo al multiplicador de la capa elegida; compras Gold y XP automática incrementan el mismo nivel individual.
- Aplicar curvas exponenciales configurables para coste y XP, con factores iniciales provisionales de 1,15.
- Mostrar bajo cada mejora el nivel, XP actual/umbral en una barra teñida por capa y el coste de esa capa.
- Sustituir el control de targeting por tres selectores ordenados, con criterios únicos e intercambio visible al reordenarlos.
- Dibujar el preview de construcción delante de todos los sprites; rojo indica colocación inválida y verde una ubicación válida. Pulsar la card inferior activa de torre.
- Estandarizar obstáculos en caja 86×86 px, centrada con un pequeño offset visual, en tablero y cards.
- Validar que las seis celdas junto a la base tienen elevación 0.
- Resultado: progresión por capa legible, máximo de 45 subidas y selección/colocación sin feedback contradictorio.

## M21 — Depuración y claridad de selección
- Añadir hacks de run desde `Ctrl+K`, usando servicios runtime y sin editar el guardado salvo el ciclo normal de run.
- Mostrar progresivamente las prioridades de targeting; mantener el panel estable y sin recorte.
- Reforzar hover alfa de obstáculos, rebote de Gold y feedback de selección.
- Resultado: controles de diagnóstico y selección legibles; implementación integrada, aceptación manual pendiente.

## M22 — HUD, oleadas, cards y fachadas
- Distribuir vida/atajos a la izquierda, recursos arriba a la derecha y ronda en el centro, sin paneles compartidos.
- Presentar el progreso configurable de 45 rondas y tooltip alimentado por `WaveData`/`EnemyData`.
- Usar marcos editables para iniciar ronda y para las cards de terreno; simplificar conteos a tipos presentes.
- Sustituir fachadas vectoriales por texturas de roca/suelo con césped sobre quads cerrados.
- Resultado: HUD acorde al roster y terreno con lectura visual consistente; aceptación visual pendiente.

## M23 — Navegación, portales y Tower Info
- Añadir paneo WASD, previews de portales, distribución de spawns y tooltip de composición.
- Mantener un ghost de torre verde/rojo, quitar las sombras generadas por código y simplificar Tower Info.
- Simplificar los sprites de cofre/portal y sus filtros; conservar cursor, hitbox y navegación lógica.
- Resultado: navegación y selección legibles; código/arte integrados, revisión visual/interactiva pendiente.

## M24 — Feedback de daño
- Animar números de daño por capa, alternando trayectorias/carriles para reducir solapamiento.
- Diferenciar críticos y mantener el cálculo en `DamageService`.
- Resultado: feedback de impactos legible sin cambiar el daño runtime; aceptación visual pendiente.

## M25 — Oferta de terreno, pausa y control de fases
- Crear por oferta una copia de cada pieza con rolls fijos de obstáculos/cofres; reutilizarlos en miniatura, ghost y tablero confirmado.
- Elegir una colocación válida de continuidad entre piezas rectas, curvas y bifurcadas; al ofrecer una curva/bifurcación, omitir la recta como alternativa.
- Bloquear construcción, selección de torres, cofres e inicio de ronda durante selección/colocación de terreno y cards.
- Añadir pausa/reanudación con `P` y botón bajo la vida; `StartWave` despeja la pausa desde `ROUND_PREP`.
- Animar el hover de cofres con bote y resplandor dorado.
- Resultado: oferta con contenido visual fiel, expansión segura y fases sin acciones de torre; código integrado, aceptación interactiva pendiente. Ver [ADR-0060](../decisions/ADR-0060-ofertas-de-terreno-y-contenido-determinista.md) y [ADR-0061](../decisions/ADR-0061-pausa-y-fases-de-expansion.md).

## M26 — Selección y retirada de objetos, y lectura de elevación
- Seleccionar obstáculos y portales desde el tablero y mostrar su información en el panel HUD, con los nombres del catálogo y lista de enemigos con sprites por portal.
- Permitir pagar para quitar obstáculos con coste `25 × n²` por obstáculo retirado; retirar portales cuesta el doble del siguiente precio de obstáculo y mantiene al menos tres activos.
- Repartir el total de enemigos de cada oleada entre los portales que sigan activos.
- Cerrar las cuñas estrechas de fachadas en vértices sin descartar triángulos pequeños y aumentar el offset visual de elevación de 18 a 28 px por nivel sin cambiar el rango lógico 0–2.
- Resultado: limpieza de mapa y selección informada integradas; aceptación interactiva y revisión visual de fachadas/alturas pendientes. Ver [ADR-0063](../decisions/ADR-0063-seleccion-y-retirada-de-objetos-del-terreno.md).

## M27 — Cards, economía de demolición y lectura de altura
- Reutilizar un panel de Upgrade Card con fondos por rareza, marco compartido e icono grande para toda operación que aparezca en una oferta.
- Devolver al demoler el precio marginal del slot ocupado según tipo y cantidad; los niveles de la torre no afectan al reembolso.
- Sortear cofres al confirmar una expansión, no en la miniatura/ghost, y animar su aparición con un salto.
- Proyectar sombras alfa de losetas y obstáculos con distancia vinculada a elevación y orientación rotatoria lenta.
- Corregir las advertencias de GDScript reportadas.
- Resultado: cards completas y una lectura más clara de recompensa y altura; código/PNG integrados, revisión visual/interactiva pendiente. Ver ADR-0064/0065/0066.

## M28 — Hacks de progresión para pruebas
- Añadir un hack que salte a la siguiente ronda con oferta programada de cards y use el pool real.
- Abrir la tienda de mejoras generales desde el panel de hacks.
- Añadir un reinicio de prueba que quite los niveles de mejoras permanentes, devuelva el XP invertido y vuelva al arsenal inicial, conservando XP no gastado y estadísticas.
- Resultado: probar cards y compras desde el inicio sin esperar el loop normal; no se simulan recompensas de las rondas omitidas. Ver ADR-0067.

## M29 — Sombras receptoras por elevación (retirado)
- La primera versión se implementó brevemente y luego se retiró por petición explícita; no forma parte del estado actual del juego.
- Ver ADR-0068 como historial técnico y ADR-0070 para el estado vigente sin sombras.

## M30 — Eliminar sombras generadas y despejar preview PATH
- Eliminar el overlay, el shader, los UID y todas las llamadas que proyectaban sombras de terreno y obstáculos.
- Durante la selección/colocación de una pieza de expansión, ocultar flechas PATH y trazos de sockets/diagnóstico encima del camino.
- Resultado: tablero sin sombras generadas y preview de terreno claro; aceptación visual pendiente. Ver [ADR-0070](../decisions/ADR-0070-sin-sombras-y-rutas-limpias-en-expansion.md).

## M31 — Arsenal inicial, XP y lectura de altura
- Dejar Ballista, Mortar y Tesla Coil como torres gratuitas iniciales; fijar costes de XP de perfil de 50 para Frost Keep/Flame Thrower/Poison Sprayer y 100 para Shredder.
- Hacer que el hack de reinicio restablezca mejoras permanentes y el arsenal inicial; las runs normales conservan compras.
- Mostrar en Tower Info la altura y el bonus real de daño/rango de la torre seleccionada.
- Resultado: el jugador ve una progresión de desbloqueo y entiende el efecto de construir en altura. Ver [ADR-0069](../decisions/ADR-0069-desbloqueos-xp-y-feedback-de-altura.md).

## M32 — Marco de Upgrade Cards y colocación automática
- Dibujar la textura de tier como fondo y el marco común como borde 9-slice alrededor del panel, sin parche central escalado.
- Quitar de las miniaturas de expansión las ramificaciones y flechas de conexión PATH.
- Mostrar durante la colocación el atajo `T` y buscar/confirmar una posición válida al pulsarlo; respetar validador, grafo y continuación futura. Si no existe, informar al jugador sin modificar el tablero.
- Resultado: cards legibles y alternativa rápida que conserva las reglas de expansión. Ver [ADR-0071](../decisions/ADR-0071-marco-de-cards-y-colocacion-automatica.md).

## M33 — Rotación y tooltip compacto de terreno
- Restaurar `Q`/`E` para rotar en ambos sentidos; la rueda rota durante una colocación y mantiene el zoom fuera de ella.
- Asignar `T` a la colocación automática existente y mantener visible su aviso durante la expansión.
- Mostrar al hover sin selección un tooltip pequeño con tipo/estado de terreno, elevación y bonus de daño/alcance de las torres compatibles; ocultarlo ante selecciones o paneles contextuales.
- Resultado: interacción de colocación consistente y lectura rápida de los hexes; revisión visual/interactiva pendiente. Ver [ADR-0072](../decisions/ADR-0072-controles-y-tooltip-de-celdas.md).
