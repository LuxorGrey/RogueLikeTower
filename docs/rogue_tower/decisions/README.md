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
| [ADR-0026](ADR-0026-jerarquia-ux-ui.md) | Jerarquía UX/UI | Vigente con detalles posteriores. |
| [ADR-0028](ADR-0028-iconos-png-y-feedback-visual.md) | Iconos y atlas | La decisión de atlas fue sustituida por ADR-0031. |
| [ADR-0031](ADR-0031-png-individuales-por-objeto.md) | PNG separados por objeto | Vigente; aceptación visual pendiente según Progreso. |
| [ADR-0032](ADR-0032-oogie-von-oogovich-jefe-de-ronda-20.md) | Ooogie von Ooogovich (Haunted) en ronda 20 | Identidad y kit adaptado aceptados; ubicación la determina ADR-0037; balance propio provisional implementado. |
| [ADR-0033](ADR-0033-nomenclatura-rogue-tower.md) | Nomenclatura canónica del proyecto | Nombres aceptados; las designaciones Miniboss 17/19 fueron retiradas por ADR-0037. |
| [ADR-0034](ADR-0034-reembolso-de-cooldown-ballista.md) | Reembolso de cooldown al perder el objetivo | Aceptado; código implementado, verificación pendiente. |
| [ADR-0035](ADR-0035-roster-rogue-tower-hasta-ronda-20.md) | Parámetros RT del roster enemigo hasta wave 20 | Parcialmente sustituido por ADR-0037, que expande a 45 rondas e integra la tabla exacta. |
| [ADR-0036](ADR-0036-parametros-torres-segun-changelog-oficial.md) | Parámetros de torre según changelog oficial | Histórico; Frost Keep y Tesla Coil reciben overrides propios de balance en ADR-0037. |
| [ADR-0037](ADR-0037-campana-de-45-rondas-y-habilidades.md) | Campaña de 45 rondas, roster, habilidades y nerfs | Aceptado; datos y código integrados, aceptación de gameplay pendiente. Sustituye partes de ADR-0016/0018/0032/0033/0035/0036. |
| [ADR-0038](ADR-0038-base-sprite-y-feedback-del-hud.md) | Sprite de base y feedback de HUD | Aceptado; implementación integrada, inspección visual pendiente. |
| [ADR-0039](ADR-0039-panel-torre-y-escalado-individual.md) | Panel lateral de torre y escala visual por objeto | Aceptado con apartados de scroll/escalado sustituidos por ADR-0040/0041. |
| [ADR-0040](ADR-0040-terreno-obstaculos-cofres-y-feedback.md) | Terreno, obstáculos, cofres, VFX/cursor y panel sin scroll | Aceptado; la tasa de cofre fue revisada por ADR-0041. El premio sigue provisional. |
| [ADR-0041](ADR-0041-occlusion-arte-terreno-y-flujo-de-rutas.md) | Oclusión, ajuste del arte, flujo de rutas, escala y rareza de cofres | Aceptado; código integrado, aceptación visual pendiente. Sustituye parcialmente ADR-0039/0040. |
| [ADR-0042](ADR-0042-orden-por-elevacion-y-feedback-del-tablero.md) | Oclusión por elevación, grid hover, portales, cursor, botones y catálogo de piezas | Aceptado; el criterio de oclusión de fachadas fue sustituido parcialmente por ADR-0043. Los demás puntos siguen vigentes. |
| [ADR-0043](ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md) | Oclusión de superficies, portales candidatos y props en cards | Corrección implementada; aceptación visual pendiente. Sustituye parcialmente ADR-0042. |
| [ADR-0044](ADR-0044-caja-estandar-de-obstaculos.md) | Caja estándar para los sprites de obstáculos | Implementada en el tablero y las cards; aceptación visual pendiente. Sustituye el tamaño/proporción de obstáculos de ADR-0041. |
| [ADR-0045](ADR-0045-auditoria-torres-y-feedback-visual.md) | Auditoría de torres, pulso de selección, hover elevado y assets compactos | Auditoría documentada y cambios visuales integrados; aceptación manual pendiente. |
| [ADR-0046](ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md) | Progresión independiente de mejoras, targeting, preview y terreno inicial | Código integrado; aceptación manual pendiente. Sustituye la caja visual de obstáculos de ADR-0044 y actualiza UX de mejoras/prioridades de ADR-0028/0039/0045. |
| [ADR-0047](ADR-0047-herramientas-de-depuracion-y-claridad-de-seleccion.md) | Hacks temporales, prioridades bajo demanda y claridad visual de selección | Código y documentación integrados; aceptación manual pendiente. |
| [ADR-0048](ADR-0048-hud-oleadas-cards-y-paredes-texturizadas.md) | HUD sin paneles compartidos, progreso de oleadas, cards con marco y fachadas con sprites | Código y arte integrados; aceptación visual pendiente. |

## Regla para nuevos ADR

Indica fecha, estado, contexto, decisiones enumeradas, consecuencias, fuentes y ADR sustituidos. Precisa qué queda confirmado, provisional o pendiente y actualiza los enlaces desde el diseño activo. No marques “implementado” si solo se aprobó el diseño.
