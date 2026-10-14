# Registro de decisiones

Los ADR preservan el porqué y el alcance de decisiones de diseño y arquitectura. La regla vigente se lee en [Diseño activo](../design/README.md), no buscando el ADR de número más alto. Los estados aceptados, implementados y sustituidos describen aspectos distintos y pueden coexistir.

## Índice

Los ADR documentan decisiones de terreno, combate, campaña, progresión y UX en orden cronológico; consulta la lista de archivos de este directorio. Los que cambiaron parcialmente mantienen su alcance histórico y deben enlazar a la decisión sustituta.

| ADR | Tema | Estado |
|---|---|---|
| [ADR-0014](ADR-0014-roster-jugable-de-siete-torres.md) | Siete perfiles jugables para la demo | Aceptado; progreso de desbloqueo definido por ADR-0022 y datos actuales. |
| [ADR-0015](ADR-0015-shredder-bleed-y-recorrido.md) | Trituradora, Bleed y recorrido PATH | Parcialmente sustituido por ADR-0023. |
| [ADR-0016](ADR-0016-campana-de-veinte-rondas.md) | Campaña de 20 rondas y ciclo de ronda | Calendario de 20 rondas sustituido por ADR-0037; se conserva como historial del ciclo de expansión. |
| [ADR-0022](ADR-0022-meta-progression-y-guardado.md) | Meta-progresión, tienda y guardado | Aceptado; balance de configuración provisional. |
| [ADR-0023](ADR-0023-reglas-de-torres-y-capas-de-vida.md) | Roster, combate, capas y estados | Contrato vigente del combate; ver decisiones posteriores para UX. |
| [ADR-0025](ADR-0025-tablero-inicial-y-ruta-minima.md) | Tablero inicial y longitud mínima de ruta | Parcialmente sustituido por ADR-0056 en posición de base y trazado; se conserva el mínimo de cuatro PATH. |
| [ADR-0026](ADR-0026-jerarquia-ux-ui.md) | Jerarquía UX/UI | Vigente con detalles posteriores. |
| [ADR-0028](ADR-0028-iconos-png-y-feedback-visual.md) | Iconos y atlas | La decisión de atlas fue sustituida por ADR-0031. |
| [ADR-0031](ADR-0031-png-individuales-por-objeto.md) | PNG separados por objeto | Vigente; aceptación visual pendiente según Progreso. |
| [ADR-0032](ADR-0032-oogie-von-oogovich-jefe-de-ronda-20.md) | Ooogie von Ooogovich (Haunted) en ronda 20 | Identidad y kit adaptado aceptados; ubicación la determina ADR-0037; balance propio provisional implementado. |
| [ADR-0033](ADR-0033-nomenclatura-rogue-tower.md) | Nomenclatura canónica del proyecto | Nombres aceptados; las designaciones Miniboss 17/19 fueron retiradas por ADR-0037. |
| [ADR-0034](ADR-0034-reembolso-de-cooldown-ballista.md) | Reembolso de cooldown al perder el objetivo | Aceptado; código implementado, verificación pendiente. |
| [ADR-0035](ADR-0035-roster-rogue-tower-hasta-ronda-20.md) | Parámetros RT del roster enemigo hasta wave 20 | Parcialmente sustituido por ADR-0037, que expande a 45 rondas e integra la tabla exacta. |
| [ADR-0036](ADR-0036-parametros-torres-segun-changelog-oficial.md) | Parámetros de torre según changelog oficial | Histórico; Frost Keep fue ajustado por ADR-0037 y recupera las cifras oficiales por ADR-0059; Tesla mantiene el override de ADR-0037. |
| [ADR-0037](ADR-0037-campana-de-45-rondas-y-habilidades.md) | Campaña de 45 rondas, roster, habilidades y nerfs | Aceptado; datos y código integrados, aceptación de gameplay pendiente. Sustituye partes de ADR-0016/0018/0032/0033/0035/0036. |
| [ADR-0038](ADR-0038-base-sprite-y-feedback-del-hud.md) | Sprite de base y feedback de HUD | Aceptado; implementación integrada, inspección visual pendiente. |
| [ADR-0039](ADR-0039-panel-torre-y-escalado-individual.md) | Panel lateral de torre y escala visual por objeto | Aceptado con apartados de scroll/escalado sustituidos por ADR-0040/0041. |
| [ADR-0040](ADR-0040-terreno-obstaculos-cofres-y-feedback.md) | Terreno, obstáculos, cofres, VFX/cursor y panel sin scroll | Aceptado; la tasa de cofre fue revisada por ADR-0041. El premio sigue provisional. |
| [ADR-0041](ADR-0041-occlusion-arte-terreno-y-flujo-de-rutas.md) | Oclusión, ajuste del arte, flujo de rutas, escala y rareza de cofres | Aceptado; código integrado, aceptación visual pendiente. Sustituye parcialmente ADR-0039/0040. |
| [ADR-0042](ADR-0042-orden-por-elevacion-y-feedback-del-tablero.md) | Oclusión por elevación, grid hover, portales, cursor, botones y catálogo de piezas | Aceptado; el criterio de oclusión de fachadas fue sustituido parcialmente por ADR-0043 y la sombra de flechas por ADR-0054. |
| [ADR-0043](ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md) | Oclusión de superficies, portales candidatos y props en cards | Corrección implementada; aceptación visual pendiente. Sustituye parcialmente ADR-0042. |
| [ADR-0044](ADR-0044-caja-estandar-de-obstaculos.md) | Caja estándar para los sprites de obstáculos | Implementada en el tablero y las cards; aceptación visual pendiente. Sustituye el tamaño/proporción de obstáculos de ADR-0041. |
| [ADR-0045](ADR-0045-auditoria-torres-y-feedback-visual.md) | Auditoría de torres, pulso de selección, hover elevado y assets compactos | Auditoría documentada y cambios visuales integrados; aceptación manual pendiente. |
| [ADR-0046](ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md) | Progresión independiente de mejoras, targeting, preview y terreno inicial | Código integrado; aceptación manual pendiente. Sustituye la caja visual de obstáculos de ADR-0044 y actualiza UX de mejoras/prioridades de ADR-0028/0039/0045. |
| [ADR-0047](ADR-0047-herramientas-de-depuracion-y-claridad-de-seleccion.md) | Hacks temporales, prioridades bajo demanda y claridad visual de selección | Código y documentación integrados; aceptación manual pendiente. |
| [ADR-0048](ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md) | HUD sin paneles compartidos, progreso de oleadas, cards con marco y fachadas con sprites | Código y arte integrados; aceptación visual pendiente. |
| [ADR-0049](ADR-0049-arquitectura-hibrida-ui-editable.md) | Arquitectura híbrida, componentes UI editables y Theme local | Implementación integrada; smoke headless pasado; aceptación visual/interactiva pendiente. |
| [ADR-0050](ADR-0050-recursos-visuales-ui-en-inspector.md) | Sprites y estilos de UI visibles y editables en el Inspector | Implementado; smoke y escaneo del editor pasados; aceptación visual pendiente. |
| [ADR-0051](ADR-0051-navegacion-prevision-portales-y-panel-torre.md) | WASD, preview exacto de spawns, torre fantasma, sombras y panel Tower Info | Código y recursos integrados; aceptación visual/interactiva pendiente. |
| [ADR-0052](ADR-0052-numeros-de-dano-animados-y-legibles.md) | Números de daño animados, alternancia, color y énfasis de críticos | Código integrado; aceptación visual pendiente. |
| [ADR-0053](ADR-0053-paneles-y-sprites-sencillos.md) | Simplificación visual de paneles, cofre y portal | Código y arte integrados; aceptación visual pendiente. Sustituye los acabados de panel de ADR-0048/0051. |
| [ADR-0054](ADR-0054-tipografia-global-y-sin-sombras-de-codigo.md) | Patrick Hand como fuente del proyecto y eliminación de sombras generadas por código | Implementado; aceptación visual pendiente. |
| [ADR-0055](ADR-0055-feedback-base-seleccion-y-recompensas.md) | Feedback de daño a la base, recompensas, selección y escala del portal | Código integrado; aceptación visual pendiente. |
| [ADR-0056](ADR-0056-tablero-inicial-lineal.md) | Tablero inicial sencillo con camino recto | Datos y código integrados; aceptación visual pendiente. |
| [ADR-0057](ADR-0057-expansion-con-prolongacion-garantizada.md) | Ofertas de terreno con prolongación garantizada y aviso de cierre de spawn | Código integrado; aceptación interactiva pendiente. |
| [ADR-0058](ADR-0058-arte-dirt-en-texturas-path.md) | Sustitución visual de Path con variantes Dirt y reemplazo del lote de 23 sprites | Assets integrados; inspección visual runtime pendiente. |
| [ADR-0059](ADR-0059-frost-keep-comportamiento-de-copos.md) | Frost Keep: copos individuales, daño y Slow de referencia | Implementado; aceptación manual pendiente. Sustituye parcialmente ADR-0037 y ADR-0045 para Frost Keep. |
| [ADR-0060](ADR-0060-ofertas-de-terreno-y-contenido-determinista.md) | Ofertas variables de camino y props idénticos en card, ghost y tablero | Código integrado; aceptación interactiva pendiente. Sustituye la card recta garantizada de ADR-0057; mantiene la continuidad PATH. |
| [ADR-0061](ADR-0061-pausa-y-fases-de-expansion.md) | Pausa, exclusividad de la expansión y feedback hover de cofres | Código integrado; aceptación interactiva pendiente. |
| [ADR-0062](ADR-0062-catalogo-de-upgrade-cards-y-permanent-upgrades.md) | Catálogo compatible de cartas temporales y mejoras permanentes | Catálogos y operaciones integrados; aceptación manual pendiente. Confirma ofertas cada tres rondas. |
| [ADR-0063](ADR-0063-seleccion-y-retirada-de-objetos-del-terreno.md) | Selección/retirada de obstáculos y portales, redistribución de spawns y elevación visual | Código integrado; aceptación visual/interactiva pendiente. |
| [ADR-0064](ADR-0064-reembolso-al-demoler-torres.md) | Reembolso al demoler según la curva de precio por tipo | Código integrado; revisión manual de cálculo pendiente. Sustituye el no reembolso provisional de ADR-0023. |
| [ADR-0065](ADR-0065-panel-y-iconos-de-upgrade-cards.md) | Panel reutilizable, fondos de tier e iconos de cada operación | La presentación por fondos/marcos fue sustituida por ADR-0075; se conservan los iconos. |
| [ADR-0066](ADR-0066-cofres-al-colocar-y-sombras-de-elevacion.md) | Tirada de cofres al colocar y sombras rotatorias de altura | Tirada de cofres vigente; las sombras fueron retiradas por ADR-0070. |
| [ADR-0067](ADR-0067-hacks-de-progresion-y-run-limpia.md) | Salto a cards, tienda desde hacks y reinicio limpio de mejoras | Código integrado; ADR-0069 actualiza el reinicio para volver al arsenal inicial. |
| [ADR-0068](ADR-0068-sombras-recortadas-por-elevacion.md) | Sombras de losetas recortadas a receptores de menor altura | Sustituido; overlay y shader eliminados por ADR-0070. |
| [ADR-0069](ADR-0069-desbloqueos-xp-y-feedback-de-altura.md) | Arsenal inicial, XP de perfil y lectura de altura | Código integrado; aceptación visual/interactiva pendiente. |
| [ADR-0070](ADR-0070-sin-sombras-y-rutas-limpias-en-expansion.md) | Retirada de sombras generadas y preview PATH limpio | Código integrado; aceptación visual pendiente. |
| [ADR-0071](ADR-0071-marco-de-cards-y-colocacion-automatica.md) | Marco perimetral de mejoras, miniaturas de terreno limpias y colocación automática | La parte del marco quedó sustituida por ADR-0075; miniaturas/auto-colocación vigentes. |
| [ADR-0072](ADR-0072-controles-y-tooltip-de-celdas.md) | Rotación Q/E y con rueda, auto-colocación T y tooltip compacto de terreno | Código integrado; aceptación visual/interactiva pendiente. |
| [ADR-0073](ADR-0073-elevaciones-y-bonus-de-torre.md) | Elevaciones 0–3 aleatorias y bonus de altura para torres | Código integrado; aceptación visual pendiente. Amplía ADR-0063/0069. |
| [ADR-0074](ADR-0074-vida-de-base-y-derrota-por-jefe.md) | Main Tower 10 HP, Fortification I–X y derrota por boss | Datos/código integrados; aceptación manual pendiente. |
| [ADR-0075](ADR-0075-panel-unico-y-aura-de-rareza.md) | Un solo panel de upgrade card y aura por rareza | Código integrado; aceptación visual pendiente. Sustituye parcialmente ADR-0065/0071. |
| [ADR-0076](ADR-0076-economia-inicial-roster-de-run-y-flujo-de-escenas.md) | Gold inicial, reclutamiento de torres y flujo de run | Código integrado; aceptación interactiva pendiente. Actualiza ADR-0022/0069. |
| [ADR-0077](ADR-0077-mapa-de-mejoras-permanentes-con-nodos.md) | Tienda permanente como mapa de nodos conectados | Código integrado; aceptación visual pendiente. |
| [ADR-0078](ADR-0078-ventana-zoom-del-timeline-de-rondas.md) | Timeline móvil ampliado de 10/15 rondas | Sustituido en el tamaño de ventana por ADR-0083; conserva el historial de hover/fade. |
| [ADR-0079](ADR-0079-limites-de-obstaculos-y-cierre-visual-del-terreno.md) | Límites de obstáculos y cierre visual del terreno elevado | Código integrado; aceptación visual pendiente. |
| [ADR-0080](ADR-0080-sprite-vertical-y-tier-de-upgrade-cards.md) | Sprite vertical compartido y tier visible en upgrade cards | Código integrado; aceptación visual pendiente. Amplía ADR-0075. |
| [ADR-0081](ADR-0081-mejoras-de-torre-en-ramas-paralelas.md) | Mejoras de torre H/A/S disponibles en paralelo | Catálogo y mapa integrados; aceptación interactiva pendiente. Amplía ADR-0077. |
| [ADR-0082](ADR-0082-tinte-multiplicativo-por-elevacion.md) | Tinte multiplicativo tenue por altura de las tapas | Renderer integrado; aceptación visual pendiente. |
| [ADR-0083](ADR-0083-timeline-fijo-de-quince-rondas-y-preview-fiel.md) | Timeline fijo de 15 rondas y preview fiel de terreno | Código integrado; aceptación visual pendiente. Amplía ADR-0079 y sustituye el tamaño configurable de ADR-0078. |
| [ADR-0084](ADR-0084-render-axial-de-terreno-y-profundidad-por-celda.md) | Retícula de vértices compartidos y orden de fachadas por celda | Retícula vigente; cierres sustituidos por ADR-0085 y extensión/oclusión de pared actualizadas por ADR-0090. |
| [ADR-0085](ADR-0085-solo-fachadas-delanteras-y-degradado-de-cliffs.md) | Solo las dos fachadas delanteras; sin grosor lateral y con degradado inferior | Selección de caras y material vigentes; extensión/oclusión parcialmente sustituidas por ADR-0090. Verificación de matriz completa pendiente. |
| [ADR-0086](ADR-0086-oferta-de-cards-y-cierre-de-derrota.md) | Oferta de mejora independiente de ranuras UI y teardown seguro al perder | Corrección y regresión integradas; smokes de Godot pendientes. |
| [ADR-0087](ADR-0087-props-obstaculos-y-altura-junto-a-base.md) | Props decorativos, nuevo pool de obstáculos y límite de elevación junto a base | Código y assets integrados; aceptación visual pendiente. Sustituye el catálogo visual previo de ADR-0040/0044/0058/0060. |
| [ADR-0088](ADR-0088-presentacion-compacta-de-upgrade-cards.md) | Cards compactas de panel plano y aura procedural por rareza | Código integrado; aceptación visual pendiente. Sustituye el sprite-panel de ADR-0080; conserva tier y ramas de ADR-0081. |
| [ADR-0089](ADR-0089-ajustes-escala-occlusion-portales-props.md) | Escala de base, oclusión de fachadas, portales animados y props | Base, portal y props vigentes; alcance de fachadas actualizado por ADR-0090. Sustituye parcialmente ADR-0055 y ADR-0087. |
| [ADR-0090](ADR-0090-fachadas-limitadas-a-la-diferencia-de-elevacion.md) | Fachadas limitadas al desnivel para conservar tapas hexagonales visibles | Código integrado; aceptación visual en Godot pendiente. Sustituye parcialmente la extensión y oclusión de paredes de ADR-0085. |

## Regla para nuevos ADR

Indica fecha, estado, contexto, decisiones enumeradas, consecuencias, fuentes y ADR sustituidos. Precisa qué queda confirmado, provisional o pendiente y actualiza los enlaces desde el diseño activo. No marques “implementado” si solo se aprobó el diseño.
