# Rogue Tower — implementación y aceptación

Usa primero el estado actual. El roadmap describe el orden histórico; la lista de aceptación conserva las comprobaciones pendientes. El diseño aprobado pertenece a PROJECT_SPEC.md; este archivo no cambia sus reglas.

## Navegación

- [Estado y próximo paso](#progress)
- [Roadmap](#roadmap)
- [Criterios de aceptación](#acceptance)
- [Auditoría documental actual](#doc-audit)
- [Snapshot de engine smoke M64](#m64-audit)
- [Auditoría documental histórica](#import-audit)

<a id='progress'></a>
## Estado actual, milestones y siguiente paso

### Estado
Última actualización: 2026-10-15

**Resumen vigente:** M69 es el último milestone integrado. M65–M69 cubren animación de correr, ofertas de reclutamiento, HUD de vida de base, velocidad ×1/×2/×3 y colores/gradiente de fachadas. La aceptación visual o interactiva sigue pendiente; la tabla de milestones es la fuente única del estado y la sección «Próximo paso» fija el orden de revisión. La última verificación de motor registrada es M64: no se afirma que M65–M69 hayan pasado pruebas o inspección visual.

Actualización M69 (2026-10-15; [ADR-0121](DECISION_HISTORY.md#adr-0121)): las paredes de elevación muestran Grass `#407850` y Mountain `#3b3c41`; se conserva encima un gradiente negro opaco abajo que llega a alfa cero arriba. Tablero, preview y miniaturas comparten el efecto; las tapas y los contornos regionales no cambian. Código/documentación integrados; aceptación visual pendiente; no se ejecutó Godot.

Actualización M68 (2026-10-15; [ADR-0120](DECISION_HISTORY.md#adr-0120)): se añade junto a Pausa un botón que alterna entre ×1, ×2 y ×3 y muestra la velocidad activa. Pausar detiene el juego y conserva el multiplicador para reanudar; cada run empieza en ×1. Código/documentación integrados; aceptación visual e interactiva pendiente; no se ejecutó Godot.

Actualización M67 (2026-10-15; [ADR-0119](DECISION_HISTORY.md#adr-0119)): la barra de base crece aproximadamente un 50 %, usa un segmento por HP con flash/encogimiento al perderlo y gradúa el relleno de verde a ámbar/rojo. Una viñeta de pantalla escala con 3/2/1 HP y respira suavemente a 1 HP. Código/documentación integrados; aceptación visual pendiente; no se ejecutó Godot.

Actualización M66 (2026-10-15; [ADR-0118](DECISION_HISTORY.md#adr-0118)): cuando hay un reclutamiento disponible, la oferta garantiza uno; las otras opciones se sortean por peso entre las cartas elegibles y nunca puede haber más de dos reclutamientos en las tres cartas. Se conservan filtros, no repetición y reclutamientos no elegidos. Código/documentación integrados; aceptación interactiva pendiente; no se ejecutó Godot.

Actualización M64 (2026-10-15; [ADR-0115](DECISION_HISTORY.md#adr-0115)): las propiedades visuales de las interfaces modificadas se trasladan a escenas, Themes, StyleBoxes o exports (incluidos Tower Info, filas de portal/enemigos, oferta/inventario de terreno, cards, timeline, mapa permanente, H/A/S, feedback de Enemy, colores HUD, tamaño de botón/cursor y VFX); el código conserva estado y contenido sin reimponer esos estilos. Los iconos de estado quedan en 28×28 px, con separación de 5 px. Se limitan texturas importadas a 256 px (iconos UI), 768 px (portal) y el cofre mantiene 168 px, sin editar PNG fuente. Se borran 26 PNG alternativos, el marco antiguo de Tower Info, 8 Resources de demo M7/M8 sin consumidor y `SpawnPortalPreviewLayer`; permanecen los perfiles de torre de diagnóstico `8`, `9` y `0`. Se alineó la aceptación para retirar referencias ejecutables a las oleadas descartadas. El escaneo headless del editor y el smoke headless de `main.tscn` pasan sin errores GDScript ni recursos faltantes; el entorno aislado impide guardar la partida de prueba. Aceptación visual/interactiva pendiente.

Actualización de arte enemigo (2026-10-15; [ADR-0116](DECISION_HISTORY.md#adr-0116)): los 26 PNG canónicos son hojas de correr de 512×128 px, con cuatro cuadros de 128×128 px y transparencia. Los Resources mantienen rutas y tamaños visuales; `EnemyData` detecta las cuatro poses y `Enemy` las anima a 8 FPS desde `MOVING`, estado fijado antes de mostrar al enemigo. Los sprites miran a la derecha y usan espejo horizontal al avanzar hacia la izquierda. La carpeta de fuentes `assets/sprites/enemies/new/` no está en este checkout, como registra la auditoría de sprites. Queda pendiente la revisión visual en Godot; no se ejecutaron pruebas.

Corrección visual M48 (2026-10-15; [ADR-0117](DECISION_HISTORY.md#adr-0117)): el portal conserva la importación optimizada de 768×384 y divide sus ocho celdas usando las dimensiones reales de la textura importada, reproduciendo los siete frames únicos a 10 FPS. El outline blanco de las torres baja de 12 a 6 px. Se actualiza el criterio de aceptación visual; no se ejecutó Godot ni una revisión en ventana.

Actualización M60 (2026-10-15; [ADR-0111](DECISION_HISTORY.md#adr-0111)): la barra de XP H/A/S ahora mide 88 × 8 px y queda centrada. Los botones muestran `DEMOLER`; al demoler torre, informan el reembolso con `+` y el icono Gold, y al demoler obstáculo muestran el coste con `−` y Gold. Los portales conservan `RETIRAR` y muestran el coste con `−`. Código/documentación integrados; no se ejecutó Godot ni revisión visual.

Actualización M61 (2026-10-15; [ADR-0112](DECISION_HISTORY.md#adr-0112)): las cifras positivas/negativas de mejoras se muestran en verde/rojo en cards de run y nodos permanentes; Tower Info colorea stats frente a su base, bonuses de altura en verde y costes de Mana reducidos en verde/aumentados en rojo. La pausa pasa junto a la vida como botón `P` con glyph de pausa/play. Se eliminan la escena y el código runtime del panel F3 y del selector de fixtures; la campaña conserva sus 45 rondas secuenciales. La colocación de terreno muestra Q/E y T de forma prominente sobre las cards de torre. Clicar portal da `ui_click`, cierra el tooltip y deja el reparto de enemigos en Tower Info. Mana comparte el panel 176 × 52 de Gold. Cambios integrados; no se ejecutó Godot ni revisión visual/interactiva, aceptación pendiente.

Actualización M62 (2026-10-15; [ADR-0113](DECISION_HISTORY.md#adr-0113)): se corrige la ruta serializada del coste de retirada y se eliminan los nodos huérfanos; precios/reembolsos de demolición quedan a la derecha y fuera del botón. Los iconos H/A/S se centran a 64 × 64 en la escena reutilizable, sin tamaños impuestos desde `_configure_tower_upgrade_visuals()`. Los valores responsivos de Tower Info se exponen en el Inspector y se preservan escala/márgenes de contenido. La selección de portal mantiene una referencia válida para mostrar el reparto de enemigos en el panel lateral. El tiempo del shader de agua avanza con `_process` y se congela en pausa. Cambios integrados; no se ejecutó Godot ni revisión visual/interactiva, aceptación pendiente.

Actualización M59 (2026-10-15; [ADR-0110](DECISION_HISTORY.md#adr-0110)): Tower Actions muestra Health/Armor/Shield en una fila centrada de botones cuadrados de 128 × 128. El coste comparte `gold_panel_style.tres`, la composición y dimensiones de `TowerShortcutCard`. Una sacudida ambiental de cámara empieza con la ronda y se detiene en victoria o fallo; el impulso de daño a base sigue siendo independiente y se suma al offset ambiental. Código/documentación integrados; no se ejecutó Godot ni revisión visual.

Actualización M58 (2026-10-15; [ADR-0109](DECISION_HISTORY.md#adr-0109)): la opacidad de `CloudShadowOverlay` sube de 0,16 a 0,20. El shader del agua usa las coordenadas visibles del mundo calculadas desde centro/zoom de cámara y viewport; conserva el rectángulo a pantalla completa y el patrón acompaña el paneo. Código/documentación integrados; no se ejecutó Godot ni revisión visual.

Actualización M57 (2026-10-15; [ADR-0108](DECISION_HISTORY.md#adr-0108)): el fondo sustituye el agua oscura de M56 por un patrón Wind Waker azul, espuma casi blanca, manchas de mayor escala y animación lenta, manteniendo `CanvasLayer -10`. Cada baja final conserva `coins_top` y añade una explosión GPU formada con el sprite real del enemigo, su frame, escala, espejo y modulación. El pool reutiliza emisores y mantiene su posición en el mundo durante paneo/zoom. Código y documentación integrados; no se ejecutaron pruebas ni revisión visual o de rendimiento.

Actualización M56 (2026-10-15; [ADR-0107](DECISION_HISTORY.md#adr-0107)): los iconos de estado de enemigos pasan a 44×44 px; la XP automática de seguimiento de todas las torres se multiplica ×5 y las subidas automáticas usan el mismo VFX que las manuales. Los tres botones H/A/S se muestran en columna, ocupan el ancho disponible y agrandan el icono de capa. Los botones cuadrados de demoler torre/obstáculo comparten `demolish_tower_icon.png`; el precio de retirada incluye el icono Gold. La tienda asigna iconos temáticos a todas las mejoras y muestra la moneda persistente solo con `exp.png`. Cards de mejora, terreno y torre reciben hover inclinado con brillo; su brillo se añade tras terminar el montaje de la escena para evitar mutaciones de hijos durante `_ready()`. M56 añadió un fondo procedural oscuro, cuya presentación fue sustituida visualmente por M57. La fachada de terreno tiene una prioridad de un píxel únicamente al empatar en Y-sort. Cambios integrados en código y documentación; no se ejecutaron pruebas ni revisión visual, por lo que la aceptación queda pendiente.

Actualización M49 (2026-10-14; [ADR-0099](DECISION_HISTORY.md#adr-0099)): las tapas se oscurecen con un multiplicador neutro del 4 % por nivel; la insignia de bonus de torre solo aparece al hacer hover y el tooltip de celda se separa 24 px horizontalmente del cursor. `CloudShadowOverlay` añade ruido irregular animado sobre los sprites del mundo mediante un velo de baja opacidad que queda bajo el HUD. El inventario de `assets/sprites/` identifica las referencias runtime encontradas y dos PNG candidatos a legado. Código/documentación integrados; no se ejecutó Godot ni revisión visual, por lo que la aceptación queda pendiente.

Actualización histórica M50 (2026-10-14; [ADR-0100](DECISION_HISTORY.md#adr-0100)): las láminas existentes se alinean y componen una vez en una textura RGBA cacheada por torre. Mundo y ghost usan un único Sprite2D; apunta a izquierda mediante espejo horizontal, sin rotación. La barra, el panel de información y el ghost reutilizan la misma imagen, con retrato, nombre y coste ampliados. El tinte de las tapas subió del 4 % al 5 % por nivel (1,00/0,95/0,90/0,85); h3 sigue vigente para altura 3. La aceptación visual queda pendiente; no se ejecutó Godot ni pruebas.

Actualización M51 (2026-10-14; [ADR-0101](DECISION_HISTORY.md#adr-0101), anclaje corregido por [ADR-0106](DECISION_HISTORY.md#adr-0106)): los eventos de disparo/impacto de las siete torres, estados, muertes, cofres, subida de nivel, daño a base, clic, colocación de terreno y Game Over usan spritesheets Cozy Chunky. Los VFX de juego conservan coordenadas del mundo en una capa superior que sigue la transformación de la cámara y procesa ALWAYS; así panean y hacen zoom junto al terreno sin perder el anclaje al evento. El marcador UI de clic conserva una capa independiente anclada al viewport para permanecer en el cursor. Los iconos de estado y el glow de cofre persisten mientras su condición siga activa. La torre/ghost conserva un único sprite compuesto con el anclaje centrado y arte 8 px más abajo. No se ejecutó Godot ni revisión visual, por lo que la aceptación queda pendiente.

Actualización M52 (2026-10-14; [ADR-0102](DECISION_HISTORY.md#adr-0102)): los siete sprites completos se cargan directamente, sin recortes ni montaje de regiones. Mundo y ghost comparten escala 1,44 × 1,12 y centro de celda con offset visual +8 px; las cards muestran sprites de 126×126 px y Tower Info de 152×176 px. Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder dosifican su partícula `shoot` con intervalo aleatorio propio de 2,0–2,5 s; Ballista y Mortar conservan un efecto por disparo discreto. Ningún ataque o impacto se limita. `pickup.png` aparece al construir una torre o retirar un obstáculo. Código y documentación integrados; la aceptación visual queda pendiente y no se ejecutó Godot.

Actualización M53 (2026-10-14; [ADR-0103](DECISION_HISTORY.md#adr-0103)): se reduce la escala compartida de torre/ghost de 1,44 a 1,32 para dar margen y evitar recorte al colocar. Se conservan el offset visual de +8 px y las dimensiones de cards/Tower Info. No se ejecutó Godot; la comprobación visual queda pendiente.

Actualización M54 (2026-10-14; [ADR-0104](DECISION_HISTORY.md#adr-0104)): la escala de las torres colocadas y su ghost baja otro 20 %, de 1,32 a 1,056. La interfaz mantiene los iconos sin cambios; se conservan el sprite íntegro y su offset de +8 px. No se ejecutó Godot; la comprobación visual queda pendiente.

Actualización M55 (2026-10-14; [ADR-0105](DECISION_HISTORY.md#adr-0105)): los portales ya no dibujan retratos flotantes; el tooltip de hover muestra tipos, retratos y cantidades. Las torres reclutadas reciben atajos secuenciales visibles en sus cards. Ctrl+rueda rota terreno y la rueda sin Ctrl hace zoom durante cualquier fase. Precios de torre y Gold del HUD reutilizan el panel 9-slice de Iniciar ronda. La escala de mundo/ghost baja 10 % adicional a 0,9504. Cambios integrados en código/documentación; no se ejecutó Godot y queda pendiente la revisión visual/interactiva.

Actualización de implementación (2026-10-14, M39–M44): las celdas adyacentes a la base se limitan a altura 1 (Path 0, Grass 1; Mountain se convierte en Grass). M46/ADR-0096 reemplaza la escala visual uniforme de 86×86 px por una silueta de base estirada a 1,8 × el radio de huella de ancho por 2,8 × de alto, con el borde inferior anclado y la huella lógica de un hexágono intacta. Los 18 props decorativos tienen 10 % de probabilidad independiente por asset/celda, se dibujan a 39,6×39,6 px y mantienen un máximo de dos; los obstáculos de 208×208 px se dibujan a 94,6×94,6 px y mantienen las tasas existentes. Las fachadas de elevación pasan a nodos Y-sorted para ocluir enemigos según pasen por detrás o por delante; su extensión vigente y su relación con las tapas se detallan en ADR-0090. Los portales usan los primeros siete frames del atlas 4×2, a 10 FPS y con fases distintas por endpoint. En M44, el preview y la confirmación reutilizan el mismo snapshot determinista de celdas, los contornos quedan en colores de terreno sin inset, y las ofertas de mejora se fijan en tres opciones. Los nuevos sprites dividen cada torre en base fija y cabeza pivotante; torres y obstáculos reciben un outline blanco por sprite. Todos los sprites están bajo `assets/sprites/`; Tiny Swords conserva la exclusión de Git por licencia. Las upgrade cards usan una card plana común con tier, icono y aura radial procedural por rareza. No se ejecutó Godot ni se hizo revisión visual en esta actualización.

Actualización M47 (2026-10-14; [ADR-0097](DECISION_HISTORY.md#adr-0097)): la base reutiliza el shader alfa blanco de torres y obstáculos. Los enemigos añaden una capa de outline-only detrás del dibujo del sprite, con un tono claro distinto por perfil de campaña; la capa sigue escala, orientación y salto de impacto y conserva el Y-sort. Los placeholders usan la misma paleta por tipo. La aceptación de grosor, contraste y oclusión queda pendiente; no se ejecutó Godot ni se hizo revisión visual.

Actualización M48 (2026-10-14; [ADR-0098](DECISION_HISTORY.md#adr-0098)): la base reduce su contorno a `outline_size_px = 6`; el de enemigos sube a `2`. Los portales incorporan un borde blanco permanente de tamaño 3, igual que los obstáculos, sincronizado con el frame y la escala de pulso. Se conserva el resplandor de hover/candidato/cierre. La aceptación visual queda pendiente; no se ejecutó Godot.

Actualización M46 (2026-10-14; [ADR-0095](DECISION_HISTORY.md#adr-0095) y [ADR-0096](DECISION_HISTORY.md#adr-0096)): el efecto se denomina **contorno de región de terreno** y usa un solo trazo opaco sin keyline: Grass `#406e4d`, Mountain `#646567` y Path amarillo. La base conserva el PNG 270×352 px y la huella lógica de un hexágono; se estira a 1,8 radios de ancho por 2,8 de alto y se ancla por el borde inferior para crecer hacia arriba. La escala es provisional. Código/documentación integrados; no se ejecutó Godot ni revisión visual, por lo que la aceptación sigue pendiente.

Actualización M45 (2026-10-14; [ADR-0094](DECISION_HISTORY.md#adr-0094)): el mapa de mejoras ya no muestra instrucciones ni el botón de nueva run; un cierre superior vuelve al menú. Los nodos usan iconos, mayor tamaño y separación; el mapa admite rueda y arrastre izquierdo/central, y dispone las ramas H/A/S en horizontal por torre. Las torres crecen hasta +12 % a lo largo de 45 niveles. M46/ADR-0095 sustituye el color del perímetro y elimina su keyline; las dos fachadas delanteras conservan sombreado oscuro diferenciado por lado sin cambiar la geometría. Código y documentación integrados; no se ejecutó Godot ni revisión visual, por lo que la aceptación queda pendiente.

Corrección visual (2026-10-14; [ADR-0090](DECISION_HISTORY.md#adr-0090)): las fachadas se generan por borde y solo ocupan el desnivel respecto a la celda vecina; si no hay vecino llegan al suelo. Tablero, ghost y miniaturas comparten el cálculo para que las paredes no cubran tapas hexagonales. No se ejecutó Godot ni inspección visual; aceptación pendiente.

Comprobación de arranque histórica (2026-10-13, M32; antes del cambio de atajos de M33): Godot 4.7 abrió `game/main/main.tscn` en modo debug después de corregir el marco de las cards, quitar ramas PATH de las miniaturas y añadir la colocación automática con Q; devolvió `errors: []`. No se hizo recorrido visual/interactivo ni se ejecutaron suites automatizadas en esta comprobación.

Actualización de código (2026-10-14, M33): se restauró Q/E para girar, la rueda giraba durante colocación y hacía zoom fuera de ella, T ejecuta auto-colocación, y se añadió tooltip compacto de terreno/elevación condicionado por selección. La rueda se actualizó en M55: sin modificador hace zoom también al colocar; Ctrl+rueda gira. No se ejecutaron pruebas ni se hizo inspección visual en esta actualización.

Actualización de código (2026-10-14, M34): PATH quedaba en elevación 0, Grass sorteaba 1–2 y Mountain 2–3; las torres elevadas mostraban el bonus de daño. La base pasa a 10 HP, Fortification permanente cuesta 20–200 XP por nivel hasta +10 HP y un boss termina la run al tocarla. Las upgrade cards usan un panel único con aura de rareza. No se ejecutaron pruebas ni se hizo inspección visual/interactiva.

Actualización de código (2026-10-14, M35): una run comienza con 1.000 Gold (hasta 2.000 mediante Starting Coffers), Ballista es la única torre de inicio y las demás se reclutan con cards si están desbloqueadas permanentemente. Menú, run y pausa son escenas separadas; la derrota vuelve al menú con tienda abierta y el resultado agrupa torres/daño. La tienda permanente usa un mapa de nodos, el timeline muestra 15 rondas con desplazamiento y fade, el terreno limita obstáculos y corrige tapa/UV/profundidad, y el ghost de Ballista señala el bonus de altura. La primera corrección de fachadas usó una envolvente convexa en pantalla; tras reportarse que aún había recortes y juntas abiertas, M37 la sustituyó por claves axiales enteras y un pase de fachada/cierre/tapa por celda. Las tapas base siguen la profundidad axial y las copias elevadas resuelven empates de Y-sort de forma estable. Se alinearon los IDs exactos del prerrequisito de Archivo de cartas, el cálculo entero de posición de nodos sueltos y la referencia del perfil Ballista en el selector de torres. Godot 4.7 arrancó la escena de menú sin errores de GDScript; no se hizo revisión visual/interactiva en esa actualización.

Actualización de código (2026-10-14, M36; presentación de card sustituida por M40): todas las ofertas de mejora compartían un sprite vertical de tarjeta, tier escrito, separación y aura de rareza. M40 elimina ese sprite y vuelve a la superficie plana común. Las mejoras Health, Armor y Shield de cada torre desbloqueada son ramas paralelas independientes, habilitadas por el unlock de esa torre. Las tapas normales y las copias elevadas Y-sorted reciben el mismo tinte multiplicativo por altura, actualizado en M49. No se ejecutaron pruebas ni se hizo revisión visual/interactiva en esta actualización.

Actualización solicitada (2026-10-14, M35): `RoundProgressStrip` ahora muestra siempre 15 rondas, elimina el selector 10/15 y mantiene visibles 31–45 al final. `TerrainPieceCardPreview` usa tapas hexagonales, fachadas texturadas cerradas y Y-sort axial como el tablero; representa las alturas de la oferta real, incluida Camino serpenteante. ADR-0083 amplía ADR-0079 y sustituye el tamaño configurable de ADR-0078. No se ejecutaron pruebas ni se hizo inspección visual/interactiva de esta actualización.

Última verificación automatizada (2026-10-10): Godot 4.7 ejecutó los smokes M4, M5 y M6 con código 0; el fixture M6 se alineó con las reglas M12A para mejoras, capas y proyectiles. Un cotejo automático de tabla y Resources encontró las mismas 45 rondas, orden, grupos, 1.093 enemigos directos y 26 perfiles usados. Los 26 sprites tienen canal alfa y transparencia; los doce PNG nuevos miden 256×256. El smoke de UI ejecutó `Main._ready()` con `user://` aislado, comprobó el catálogo de 20 iconos y las texturas Inspector de botones, cargó las escenas y pasó; no se modificó el guardado del usuario. El escaneo headless del editor terminó; la aceptación visual/interactiva sigue pendiente. Godot solo informó que no pudo leer el almacén de certificados raíz del host.

| Milestone | Estado | Notas |
|---|---|---|
| M0 Bootstrap | Implementado; arranque verificado | Configuración limpia, escena principal, autoloads mínimos, pantalla debug y `.gitignore` presentes. |
| M1 Hex Grid | Implementado; arranque verificado | Coordenadas axiales, seis vecinos, conversión pointy-top, rotación, distancia, diccionario de celdas y selección debug añadidos. |
| M2 Terrain Rendering | Implementado; revisión visual pendiente | Preview PATH/GRASS/MOUNTAIN con alturas, caras laterales, orden por profundidad, hover por terreno y coordenada axial en HUD; ya no se dibujan iniciales ni coordenadas sobre los hexes. Base con huella completa de un hex y clusters Grass/Mountain con brillo visual de combo 3/5. Falta comprobar renderer, brillo y base en ventana Godot. |
| M3 7-Hex Pieces | Implementación en código; interacción por revisar | Quince Resources de 7 hexes, rotación no destructiva a seis orientaciones, sockets explícitos con aperturas laterales flexibles, validador de solapamiento/adyacencia y conexión compatible, tablero persistente, ghost legal/ilegal, selección, hover global, confirmación/cancelación. Diez piezas nuevas amplían campos, montañas, curvas, ramales y bifurcaciones. Sockets y colocación aún necesitan inspección en Godot. |
| M4 Path Graph | Implementado; 7 escenarios smoke correctos | `PathGraph` axial con sockets exactos/flexibles complementarios, endpoints spawn/base, BFS de coste unitario determinista, rutas mínimas cacheadas por spawn, bifurcaciones y rechazo de subredes/salidas sin ruta. El snapshot activo solo se reconstruye al iniciar o confirmar pieza; el ghost legal de expansión calcula aparte un grafo candidato para previsualizar cambios de spawn sin mutar el tablero. Overlay `Ctrl+D` (antes `D`, ahora reservado a WASD). La escena principal y `tests/path_graph_smoke.tscn` cargan en Godot 4.7; las siete pruebas lógicas pasan. Falta inspección visual manual del overlay y preview. Provisionalidades en ADR-0007/0029. |
| M5 Enemy + Base | Implementado; smoke histórico correcto | Base con Health, `Enemy` data-driven, movimiento sobre `PathRoute`, `WaveDirector`, daño por llegada, derrota y fases `COMBAT`/`RUN_DEFEAT`/`TERRAIN_EXPANSION`. El smoke original terminaba con base en 20/50 HP; es un fixture histórico, no el máximo actual de 10 HP. Falta revisar visualmente la integración en ventana. Valores/política provisionales en ADR-0008; derrota de boss actualizada en ADR-0074. |
| M6 Towers | Prototipo sustituido; Resource conservado como `Basic Bolt (DEBUG)` | El primer ciclo de construcción, targeting, alcance y mejora se conserva como historial y fixture. La prueba manual M6 ya no describe el HUD/roster vigente; validar las torres actuales con M9.5, M12A y M13 en `IMPLEMENTATION_AND_QA.md#acceptance`. Provisionalidades históricas en ADR-0009. |
| M7 Damage Model | Pipeline implementado; fórmula plana histórica sustituida por M12A | `DamagePacket`, `DamageResult` y `DamageService` centralizan impactos; las fórmulas de M7 ya no son el contrato vigente. Los perfiles de diagnóstico estuvieron en `8`/`9`; el antiguo panel F3 se retiró del runtime por M61. Los detalles históricos de esa etapa se guardan en ADR-0010/0011; el comportamiento actual se valida con M12A. |
| M8 Status Effects | Implementado en código; aceptación manual pendiente | `StatusEffectData`, controlador runtime por enemigo, Slow/Burn/Bleed, payloads de `TowerData` procesados por `DamageService`, ticks DoT y ralentización real. Status Probe se conserva con `0`, pero la oleada y el dummy de entrenamiento se retiraron en M64; comprobar efectos sobre enemigos de campaña según M64/M12A. ADR-0012 registra la configuración provisional; no se añaden resistencias porque el diseño no las requiere. |
| M9 Economy + Mana | Implementación en código; aceptación manual pendiente | `RunEconomyData` y `RunEconomyService` locales a `Main`; Gold separado de meta moneda; costes configurables de compra/mejora; recompensas por bajas únicas y por oleada limpia; gasto de Mana antes del ataque y regen/capacidad; HUD de saldos/costes y transición `ROUND_REWARD`. Valores provisionales en ADR-0013. Falta ejecutar el procedimiento M9 de `IMPLEMENTATION_AND_QA.md#acceptance` en la ventana del juego; no se ha ejecutado Godot ni la suite en esta revisión. |
| M9.5 Demo Tower Roster | Código implementado; aceptación manual pendiente | Siete perfiles construibles con patrones single/area/chain/cone/sawblade/all-in-range/Frost snowfall, Poison como tag, Slow/Burn/Poison/Bleed, Mana y costes visibles. Frost Keep deja caer copos sobre PATH; cada contacto daña a un enemigo y añade Slow por el 50% del daño aplicado. Ballista reembolsa 33 % de la recarga si su objetivo muere por otra fuente antes del impacto; cada torre y cada disparo controlan su ciclo por separado (ADR-0034). Los enemigos de campaña dibujan PNGs individuales; sus perfiles se registran en ADR-0037. Tesla afecta a todos los enemigos dentro de su alcance. Shredder hace daño directo y aplica Bleed equivalente al 100% del daño base restante por enemigo, con pérdida de 1 por perforación. Atajos `1–7`; diagnósticos `8`/`9`/`0`. No se ha hecho aceptación interactiva en ventana. |
| M10 Campaign 45 Rounds | Código/datos integrados; aceptación manual pendiente | 45 WaveData validadas, total 1.093 directos, distribución round-robin, 26 perfiles con habilidades y PNGs, Ooogie von Ooogovich con invocaciones/fase Bat, espejo horizontal hacia la izquierda. Frost Keep: daño 6, 180 RPM, Slow proporcional al daño aplicado y drenaje de 2 Mana/s durante combate (ADR-0059); Tesla Coil: daño 9. Cada oferta contiene una colocación validada `EXTIENDE RUTA`; su forma varía y algunas ofertas no presentan una pieza recta. No se confirma una expansión que deje cero colocaciones legales de camino y los spawns que se cerrarían se marcan antes. ADR-0037/0057/0060. Pendiente gameplay visual completo hasta la victoria 45/45. |
| M11 Upgrade Cards | Catálogo ampliado en código; oferta fija de tres; aceptación interactiva pendiente | Se combinan 18 cards propias y 172 Resources nuevos, más la Advanced Circuits existente; son 190 cards de mejora que representan las 173 entradas compatibles. M35 suma seis reclutamientos para un pool runtime de 196 IDs. `RunCardService` filtra por unlock, roster, peso, prerequisitos y máximo por run. La frecuencia queda confirmada cada tres rondas tras colocar expansión (3–42); cada oferta garantiza un reclutamiento si hay alguno elegible, sortea el resto por peso y limita a dos reclutas. Los reclutamientos no elegidos siguen disponibles para ofertas futuras. El flujo programado no prepara la ronda siguiente si no logra abrir una oferta. Los efectos son temporales y no mutan Resources compartidos. ADR-0062/0076/0086/0093/0118. |
| M12 Meta Progression | Catálogo ampliado en código; aceptación manual pendiente | `MetaProgression` Autoload y `SaveData` JSON versión 1 con validación, guardado temporal y backup; XP de perfil/recompensa por victoria o derrota; tienda al terminar cada run; 31 IDs en catálogo, 30 mejoras comprables (seis propias y 24 incorporadas) y el ID legado `card_draw`, no mostrado ni disponible para compra. Incluye ramas H/A/S para las siete torres, Gold por baja, vida y reparación de base, además de economía existente. Las compras se aplican desde la run posterior y los costes siguen configurables. ADR-0022/0062/0069/0093 y `IMPLEMENTATION_AND_QA.md#acceptance`. No se ejecutó Godot ni aceptación manual en esta revisión. |
| M12A Tower Rules + HP Layers | Código integrado; aceptación manual pendiente | Modelo H/A/S, estados, torres, reglas de daño, recompensas y progresión se mantienen. La campaña activa usa los perfiles 45 rondas y la fase Bat de Ooogie; ver M10/ADR-0037. Falta aceptación visual/manual. |
| M13 UX/UI | Implementación en código; aceptación visual pendiente | El HUD se actualizó en M22; el timeline fijo se sustituyó en M35 por una ventana de 15 rondas sin selector. La fila de torres muestra solo el roster reclutado durante la run; menú, pausa, tienda de nodos y resumen se detallan en M35. Salud/atajos arriba a la izquierda, Gold/Mana arriba a la derecha. El panel lateral no tiene scroll y el preview de Ballista muestra el bonus de altura. Mejoras muestran capas Health/Armor/Shield. ADR-0041/0048/0076–0079/0083; falta inspección visual en ventana. |
| M14 Vertical Slice | Parcialmente implementado; aceptación manual pendiente | Integradas las primeras reglas y assets de terreno: obstáculos Grass 25 %/Mountain 15 % (el pool previo de cinco fue sustituido por M39), props iniciales, cofres 1 % base y mejora permanente en cuatro niveles hasta 20 %, recompensa provisional +25 Gold, bloqueo de construcción y apertura. Falta recorrer la demo y validar todas las interacciones en ventana. ADR-0040/0041 y prueba M14 en `IMPLEMENTATION_AND_QA.md#acceptance`. |
| M15 Art Pipeline | Arte histórico integrado; obstáculos reemplazados en M39 | Los nueve tiles Path/Grass/Mountain, el arte de base, portal e iconos se conservan. El pool de cinco obstáculos descrito en este hito es histórico; M39 lo reemplaza por ocho PNG nuevos. Por decisión del usuario, Dirt_01/02/03 reemplaza visualmente Path_01/02/03; no cambia la topología PATH ni el flujo de flechas. Ver [ADR-0058](DECISION_HISTORY.md#adr-0058) y [validación de arte](CONTENT_AND_ASSETS.md#art-validation). |
| M16 Polish | Integración inicial; aceptación manual pendiente | VFX de impacto enlazados por torre con spritesheets locales Tiny Swords y animación por frames. Cursor distinto para normal, interactuable, inválido y colocación; el cursor de construcción ahora usa un overlay de 32 px con pulsación. Los PNG del pack son dependencia local ignorada por Git debido a su licencia; el README de instalación y la procedencia están documentados. Falta comprobar impactos/cursor en partida. |
| M17 Oclusión y flujo de rutas | Implementado en código; aceptación visual pendiente | Props individuales bajo `Entities.y_sort_enabled`, filtros lineales y offsets de arte por objeto; terreno recortado al footprint exacto; flechas animadas siguen las aristas de cada ruta hasta base. M18 ordena tapas según elevación; M41 añade fachadas delanteras Y-sorted. El tamaño histórico de la base se actualiza en M41. Cofre base 1 %, con cuatro mejoras de +5 puntos porcentuales limitadas a 20 %. ADR-0041/0042/0043/0089; falta comprobar en ventana la oclusión, el encaje y el flujo a varios zooms. |
| M18 Orden visual y piezas | Código integrado; aceptación visual pendiente | Superficies hexagonales superiores ordenadas por elevación y fachadas traseras omitidas; grid y sockets visibles al hover con dos anillos atenuados; portales pulsantes se trasladan al grafo candidato válido; cards, ghost y tablero confirmado comparten el mismo contenido de obstáculo/cofre por pieza; flechas PATH animadas, cursor de construcción pulsante y pequeño, animación del icono de torre construida, tarjetas de torre más grandes/juntas y diez piezas nuevas (15 en total). ADR-0042/0043/0044/0046/0060; falta la inspección visual y de colocación descrita en M18 de `IMPLEMENTATION_AND_QA.md#acceptance`. |
| M19 Auditoría y pulido visual | Código/documentación integrados; aceptación pendiente | Informe comparativo de daño, upgrades, XP, rango, RPM, Mana, crítico, estados y cartas; Frost Keep mantiene cobertura cuadrada y ahora usa copos con impactos individuales (ADR-0059); Tesla deja neutral el límite no aplicable. Panel/icono/radio de torre seleccionada pulsan y la torre gana prioridad visual; hover elevado usa overlay por elevación; flechas más lentas/espaciadas/tenues, Gold ganado rebota con fuerza, cofre pulsa al aparecer y portales tienen fases individuales. Se ajustaron cuatro PNG a su escala fuente 2× y se separó runtime en 9 tiles + 5 obstáculos; M39 sustituyó posteriormente ese pool de obstáculos. Atlas fuente conservados. ADR-0045/0059; falta inspección completa en ventana Godot. |
| M20 Mejoras independientes y selección | Código y documentación integrados; aceptación visual/manual pendiente | Cada capa tiene niveles 0–15, XP/coste con curvas exponenciales configurables y barra teñida por Health/Armor/Shield; total 0–45. Tres selectores únicos ordenados permiten priorizar objetivos. El preview de torre queda sobre el tablero y marca inválido en rojo/válido en verde; la card activa pulsa. Obstáculos usan caja centrada 86×86 px. La regla histórica de dejar las seis celdas alrededor de la base a altura 0 fue sustituida por las elevaciones aleatorias de M34/ADR-0073. ADR-0046; seguir el procedimiento M20 de `IMPLEMENTATION_AND_QA.md#acceptance`. |
| M21 Herramientas de depuración y claridad de selección | Implementado en código y documentado; aceptación manual pendiente | `Ctrl+K` abre hacks de Gold/Mana, curación, ronda, reinicio y unlock temporal de torres/cartas sin alterar guardado. El panel lateral ya no pulsa y se ajusta entero a pantalla; las prioridades empiezan con una fila y `+` revela las siguientes. La selección de torre mantiene pulso/brillo sin círculos. Hover de obstáculos usa expansión del alfa PNG. Gold anima el grupo de icono y cifra. El `PathGraph` exige al menos un spawn exterior alcanzable antes de confirmar terreno. ADR-0047. |
| M22 HUD, oleadas, cards y paredes | Implementado en código/arte; aceptación visual pendiente | Se corrigió la referencia `%GoldGroup`; salud queda arriba a la izquierda y Gold/Mana arriba a la derecha sin paneles compartidos en M22. M55 añade un panel 9-slice solo a Gold y a los precios de torre; Mana, salud y ronda siguen sin él. El timeline fijo de 45 puntos descrito en este milestone es histórico y fue sustituido por una ventana de 15 rondas en M35/ADR-0083; su hover de retratos se conserva. El botón de ronda adapta el ancho al texto. Las cards omiten conteos en cero. Grass/Mountain usan sprites de fachada con UV a escala estable y uniones cerradas; M35 corrige además las tapas para usar polígonos hexagonales texturados. ADR-0048/0079; falta inspección visual. |
| M23 Navegación, portales y Tower Info | Código y arte integrados; aceptación visual/interactiva pendiente | Cámara paneable con WASD (diagonales normalizadas, compensación de zoom y limpieza de teclas al perder foco); overlay de rutas reasignado a Ctrl+D. Cada portal conserva la composición de enemigos por distribución real de WaveDirector y la muestra al hover; los badges flotantes de este milestone fueron retirados por M55. El ghost de torre usa shader verde/rojo translúcido por validez. Se retiraron las sombras y el pedestal oscuro dibujados por código. Tower Info ahora usa una superficie plana, icono pequeño en la cabecera, mejoras compactas y botón Demoler de texto; las cards de expansión también son planas. Cofre y portal usan sprites pixel art de paleta limitada con filtro nearest. ADR-0051/0053/0054/0105; falta aceptación visual en ventana. |
| M24 Feedback de daño | Implementado en código; revisión visual pendiente | Los números de daño hacen punch de entrada, recorren arcos alternos y usan tres carriles verticales; el tamaño responde acotadamente al promedio móvil de daño por enemigo, los colores identifican Health/Armor/Shield y los críticos añaden `CRIT` con más énfasis. El flash del sprite sigue el color de la capa afectada. No cambia el cálculo de combate. ADR-0052; falta inspección visual y de legibilidad con impactos simultáneos. |
| M25 Oferta de terreno, pausa y fases | Implementado en código; aceptación interactiva pendiente | Los obstáculos de cada card se fijan y se comparten entre miniatura, ghost y tablero confirmado; M27 difiere la tirada de cofre hasta confirmar la pieza. Las ofertas eligen una pieza de continuidad recta, curva o bifurcada; al elegir una no recta, la oferta omite la recta. En `TERRAIN_EXPANSION`/`CARD_OFFER` se bloquean selección de torres, construcción, inicio de ronda y apertura de cofres. `P` y el botón bajo la vida pausan/reanudan; `StartWave` despeja la pausa desde `ROUND_PREP`. El hover de cofre bota y resplandece en dorado. ADR-0060/0061; falta aceptación manual en ventana. |
| M26 Selección/retirada de objetos y altura | Código integrado; aceptación interactiva/visual pendiente | Los obstáculos seleccionables muestran nombre y se quitan por 25 × n² Gold (n es ordinal de retirada); portales muestran una lista de enemigos con sprites y se quitan por el doble del precio vigente, si quedan al menos tres. El total de enemigos permanece en WaveData y el director filtra las salidas retiradas para distribuir de nuevo entre las activas. El cierre de cuñas ya no descarta uniones estrechas y cada nivel visual pasa de 18 a 28 px; M34 amplía la lógica a elevación 0–3. Falta probar selección, pagos, reparto real y costuras en ventana. ADR-0063/0073. |
| M27 Cards, demolición y lectura de altura | Código integrado; aceptación visual/interactiva pendiente | Las Upgrade Cards conservan iconos grandes para torres y efectos generales. Los fondos por rareza de M27 quedaron sustituidos por la superficie común de M34; el sprite vertical de M36 quedó sustituido por la card plana de M40. Demoler devuelve el precio marginal del slot del tipo, sin reembolsar niveles. La tirada de cofre ocurre tras confirmar el terreno y aparece con salto; miniaturas/ghost no lo muestran. La implementación temporal de sombras M27/M29 quedó retirada en M30. ADR-0064/0066/0070/0075/0088. |
| M28 Hacks de prueba | Código integrado; aceptación manual pendiente | Desde `Ctrl+K` se puede saltar a la siguiente oferta real de cartas (cada tres rondas), abrir la tienda general y comenzar una run limpia que restablece niveles permanentes y devuelve el XP invertido en mejoras; el arsenal vuelve a Ballista/Mortar/Tesla Coil, pero el XP no gastado se conserva. Falta comprobar salto y recompra en ventana. ADR-0067/0069. |
| M29 Sombras receptoras por elevación | Sustituido; no forma parte del juego actual | El overlay de sombras de terreno/obstáculos se implementó y fue eliminado después a petición del usuario. Ver ADR-0068 como historial y ADR-0070 como decisión vigente. |
| M30 Sin sombras y preview PATH despejado | Código integrado; aceptación visual pendiente | Eliminados el script, shader, UID y llamadas del sistema de sombras. Las flechas PATH y trazos de socket se ocultan durante la selección/colocación de terreno; el juego normal recupera su flujo al cerrar el preview. ADR-0070. |
| M31 Desbloqueos iniciales, XP y lectura de altura | Código integrado; aceptación visual/interactiva pendiente | Una instalación nueva tiene desbloqueadas Ballista, Mortar y Tesla Coil, pero M35 establece que en una run solo Ballista está reclutada al comienzo; Mortar/Tesla entran con cards. Las demás torres se ofertan después de su desbloqueo permanente. Frost Keep/Flame Thrower/Poison Sprayer cuestan 50 XP de perfil y Shredder 100. Tower Info muestra altura y bonus de daño/rango. ADR-0069/0076. |
| M32 Marco de cards y colocación automática | Código integrado; presentación actualizada por M40 | El marco 9-slice por rareza fue la implementación temporal; M34 lo sustituyó por una superficie común, M36 añadió un sprite-panel vertical y M40 volvió a superficie plana común con aura. Las miniaturas omiten conexiones PATH; durante la colocación aparece la ayuda de T y la búsqueda auto-confirma una ubicación que supere las mismas validaciones de terreno/ruta. Si no hay lugar, conserva tablero y pieza. ADR-0071/0072/0075/0088. |
| M33 Rotación y tooltip de terreno | Código integrado; aceptación visual/interactiva pendiente | Q/E y rueda giraban la pieza; M55 cambia la regla vigente a Ctrl+rueda para girar y rueda sin modificador para zoom, también durante colocación. T auto-coloca. Sin selección se muestra un tooltip pequeño con tipo/estado, altura y bonuses efectivos de torres compatibles; se oculta ante selección, interfaz u otros paneles. No se hizo validación visual/interactiva. ADR-0072. |
| M34 Elevaciones, vida de base, jefes y upgrade cards | Código y datos integrados; aceptación visual/interactiva pendiente | Elevaciones válidas PATH 0, Grass 1–2 y Mountain 2–3, reproducibles por seed. El bonus +1 daño/+0,5 rango por nivel se conserva; badge visible al hacer hover (ajustado en M49). Base 10 HP, Fortification permanente +1 HP hasta 20 por 20–200 XP por nivel; cards de run +3 HP cada una. Boss en la base termina la run. Panel único y aura cromática por rareza. ADR-0073/0074/0075. |
| M35 Flujo de run, mapa de upgrades y lectura del tablero | Código/datos integrados; aceptación visual/interactiva pendiente | Gold inicial 1.000 +100 por nivel de Starting Coffers, hasta 2.000; Ballista única de inicio, reclutamiento de torres desbloqueadas mediante cards y bloqueo de construcción hasta reclutar. Menú principal, partida y pausa en escenas separadas; derrota vuelve al menú con tienda abierta; resumen conciso de cantidad/daño por tipo desbloqueado. Tienda como mapa conectado de nodos/tarjetas compartidas, iconografía y partículas. Timeline fijo de 15 rondas con fade futuro y ventana final 31–45; sin selector 10/15. Las cards de terreno comparten texturas, elevaciones y orden axial del tablero. Máximo dos obstáculos por pieza y uno en tablero inicial, excluidos base/vecinas; tapas hexagonales cerradas, UV sin estirar, profundidad isométrica y badge de elevación en ghost Ballista. ADR-0076–0079 y ADR-0083. |
| M36 Cards de tier, ramas paralelas y tinte de altura | Implementado; presentación de card sustituida por M40 | El sprite vertical/tier de M36 fue sustituido por M40. Siguen vigentes la etiqueta de tier, las ramas paralelas Health/Armor/Shield por torre y el tinte multiplicativo oscuro neutro por altura, compartido por tapas, previews y copias elevadas (actualizado en M49). ADR-0080–0082/0088/0099. |
| M37 Grid axial y renderer de elevación | Geometría y orden de dibujo integrados; fachada sustituida por M38 | `HexMath` calcula vértices pointy-top desde claves axiales enteras compartidas. La pasada original por celda incluía cierres de vértice; M38 los elimina y deja solo fachadas delanteras sin profundidad lateral. La retícula axial compartida sigue vigente para tablero, ghost, miniaturas y copias Y-sorted. ADR-0084/0085. |
| M38 Fachadas delanteras y degradado | Renderer integrado; revisión completa de alturas/oclusión pendiente | Vigente: cada celda renderiza solo sus dos fachadas delanteras como quads y no crea cierres ni profundidad lateral; el degradado oscuro afecta solo a las fachadas. La revisión del usuario aprobó el aspecto visual de referencia, pero la matriz completa de combinaciones sigue pendiente. ADR-0085. |
| M39 Props, obstáculos y base | Código/assets integrados; caja visual actualizada en M43 | Anillo inmediato de base limitado a altura 1; ocho obstáculos nuevos de 208×208, centrados en la celda, máximo dos por pieza y uno en el tablero inicial fuera del anillo de base. M43 aumenta la caja de dibujo a 94,6×94,6 px. ADR-0087/0089/0092. |
| M40 Card compacta y aura | Código integrado; aceptación visual pendiente | Se elimina el sprite vertical; todas las opciones usan superficie plana compartida con tier e icono, separación y aura radial animada por rareza. La oferta tiene tres columnas y siempre tres opciones. ADR-0088/0093; M36 mantiene sus ramas H/A/S paralelas y tinte de elevación. |
| M41 Escala de base, oclusión y contenido decorativo | Integrado; algunos parámetros visuales actualizados en M43/M46 | Base con PNG fuente 270×352 intacto; la caja visual de 86×86 fue sustituida en M46 por una silueta más alta. Fachadas delanteras Y-sorted para ocultar actores detrás; portales desfasados y en loop a 10 FPS; props al 10 % por asset/celda, máximo dos sin solaparse. M43 amplía props y obstáculos y omite el frame de portal duplicado. Se corrigió el parseo de `TerrainPiecePreview`. ADR-0089/0092/0096. |
| M42 Contornos compartidos por región | Código integrado; aceptación visual pendiente | El tablero, las superficies elevadas y las miniaturas omiten aristas internas entre hexes de igual terreno/altura y dibujan el perímetro contra vacío y otras regiones. Cada terreno aporta su propio color en la frontera; el hover sigue siendo temporal. ADR-0091. |
| M43 Centrado y pulido visual, y raíz común de sprites | Código/assets/documentación integrados; presentación de fachadas afinada por M45 | Torres y ghost usan escala 1,2 y ancla axial de hex; perímetros con uniones redondeadas, fachadas con color superior Grass/Mountain, props a 39,6 px y obstáculos a 94,6 px. M45 restaura contraste direccional oscuro sin modificar esa geometría. El portal omite su último frame repetido y limpia el tooltip cuando se elimina. PNGs e imports centralizados en `assets/sprites/`, con subcarpetas y dependencia Tiny Swords todavía ignorada por Git. ADR-0092/0094. |
| M44 Preview exacto, oferta fija y arte de torre | Código/assets/documentación integrados; montaje de torre actualizado por M50 | El preview reutiliza el tablero candidato al confirmar, con celdas de relleno deterministas. Los contornos se dibujan sin inset y con uniones redondas; M45 había fijado la paleta y el keyline, que M46 sustituye por un trazo plano. Cada oferta muestra exactamente tres opciones seleccionables; reclutamientos sin elegir persisten para futuras ofertas y el nodo legado Card Draw queda retirado de la tienda. En M50 el runtime compuso las láminas en un sprite por torre; M52 sustituye ese montaje por los PNG completos. El outline blanco sigue vigente. ADR-0093/0094/0095/0100/0102. |
| M45 Mapa de mejoras y legibilidad del terreno | Código/documentación integrados; aceptación visual/interactiva pendiente | El mapa permanente elimina el pie instructivo y “Empezar nueva run”, añade cierre arriba a la derecha, iconos por nodo, clusters espaciados, scroll y arrastre. Las tres ramas H/A/S se muestran en una fila. Cada nivel de torre suma crecimiento visual hasta +12 % en 45 mejoras. M46/ADR-0095 actualiza después el contorno; las fachadas delanteras conservan sombreado direccional oscuro. ADR-0094. |
| M46 Contorno regional y base visible | Código/documentación integrados; aceptación visual pendiente | El contorno de región de terreno es un trazo único: Grass `#406e4d`, Mountain `#646567`, sin keyline ni interior claro. El PNG de base se estira en pantalla a 1,8 × el radio de ancho por 2,8 × el radio de alto, conservando su ancla inferior y huella lógica. ADR-0095/0096. |
| M47 Outline de base y enemigos | Código/documentación integrados; aceptación visual pendiente | Base con outline blanco mediante el shader compartido. Enemigos con capa outline-only sincronizada al sprite y color claro por `EnemyData.id`; placeholders coloreados igual. Barras/estados permanecen delante y la ordenación Y no cambia. ADR-0097. |
| M48 Grosor de outlines y contorno de portales | Código/documentación integrados; aceptación visual pendiente | Base usa tamaño 6, enemigos tamaño 2 y portales tamaño 3 en el shader compartido. El borde blanco del portal es permanente y conserva el glow contextual. ADR-0098. |
| M49 Lectura de altura, nubes animadas y auditoría de sprites | Implementado; tinte actualizado por M50 | La insignia elevada aparece solo al hacer hover; tooltip con offset horizontal; la versión M49 del tinte era 4 % por nivel y M50 la sube a 5 %. La sombra procedural animada cubre los sprites del mundo bajo el HUD. La auditoría enumera PNG y referencias, con dos candidatos a legado sin uso runtime localizado. ADR-0099/0100. |
| M50 Sprite único de torre y tinte de altura | Código/documentación integrados; aceptación visual pendiente | Una textura compuesta cacheada alimenta un único Sprite2D en torre/ghost y los retratos de cards/panel. Orientación derecha por defecto, espejo horizontal hacia enemigos a la izquierda, sin rotación visual. Retratos y rótulos de coste/nombre ampliados. Tinte de tapa 5 % acumulado por nivel. ADR-0100. |
| M51 VFX de combate, estados y feedback de juego | Código/assets/documentación integrados; aceptación visual/interactiva pendiente | Cozy Chunky cubre los siete pares de disparo/impacto, estados, subida de nivel, baja, cofre, daño de base, clic, colocación y Game Over. El overlay de evento sigue activo durante cards/terreno y conserva anclaje a coordenadas del mundo al paneo/zoom. Torre y ghost usan un único sprite compuesto, centrado con desplazamiento visual inferior de 8 px. ADR-0101 y ADR-0106. |
| M52 Sprites completos de torre, escala y cadencia de feedback | Implementado; escala de mundo/ghost refinada por M53 | Catálogo carga los siete PNG completos sin recortar regiones; mundo/ghost comparten escala y anclaje; cards y Tower Info muestran el icono más grande. El VFX `shoot` de las cinco torres de fuego continuo se limita a 2,0–2,5 s; Ballista y Mortar conservan un efecto por disparo y no se dosifican impactos. `pickup.png` aparece al construir torre y retirar obstáculo. ADR-0102. |
| M53 Escala de torre sin recorte | Código/documentación integrados; aceptación visual pendiente | La escala compartida de torre/ghost baja de 1,44 a 1,32, manteniendo el offset de 8 px y los iconos UI. ADR-0103. |
| M54 Reducción adicional de escala de torre | Implementado; escala supersedida por M55 | La escala de tablero/ghost bajó un 20 %, de 1,32 a 1,056; M55 la redujo otro 10 %. Los iconos UI mantienen su tamaño. ADR-0104/0105. |
| M55 Tooltip de spawn, atajos, zoom y panel de Gold | Código/documentación integrados; aceptación visual/interactiva pendiente | Sin retratos sobre portales; composición con retratos en tooltip. Atajos secuenciales reordenados al reclutar. Rueda hace zoom y Ctrl+rueda gira. Panel 9-slice común para Gold y precios de torre. Escala mundo/ghost 0,9504. ADR-0105. |
| M56 Feedback de progresión, cards y oclusión | Integrado; aceptación visual pendiente; agua sustituida por M57 e iconos por M64 | XP automática ×5; VFX compartido de nivel; iconos temáticos; hover con brillo; oclusión refinada. Ver ADR-0107 y el historial superior. |
| M57 Agua luminosa y explosión pixel de enemigos | Código/documentación integrados; aceptación visual y revisión de rendimiento pendientes | Agua azul y espuma casi blanca con patrón grande y lento en CanvasLayer -10. La baja final añade una explosión GPU muestreada desde el sprite real y conserva `coins_top`; emisores pooled quedan anclados al mundo. ADR-0108; sustituye la presentación del agua de ADR-0107. |
| M58 Sombra de nubes y agua anclada a cámara | Código/documentación integrados; aceptación visual pendiente | Opacidad de nubes 0,20; agua a pantalla completa con patrón en coordenadas visibles del mundo para acompañar paneo/zoom. ADR-0109; refina ADR-0099/0108. |
| M59 Mejoras de torre en fila y shake de ronda | Código/documentación integrados; aceptación visual pendiente | Tres botones H/A/S cuadrados en una fila; precio con panel compartido; shake sutil activo desde inicio hasta fin/fallo de ronda, compuesto con el impulso por daño. ADR-0110. |
| M60 Barra de XP y precios de demolición | Código/documentación integrados; aceptación visual pendiente | XPBar 88 × 8 px centrada. Botón de torre muestra `DEMOLER` y el reembolso `+N` con Gold; obstáculo muestra `DEMOLER` y coste `−N`; portal indica `RETIRAR` con coste `−N`. ADR-0111. |
| M61 Legibilidad de mejoras, HUD y colocación | Implementado; aceptación visual/interactiva pendiente | Colores semánticos de stats, pausa compacta, prompt de terreno, selección de portal y panel común para Gold/Mana; se retiró F3 runtime. ADR-0112. |
| M62 Correcciones de paneles y pausa de agua | Implementado; aceptación de escena pendiente | Precios de demolición fuera del botón, iconos H/A/S centrados, layout Tower Info editable desde Inspector, detalle de portal y agua pausada. ADR-0113. |
| M63 Radio de torre, ghost exacto y mapa permanente | Código/documentación integrados; aceptación visual/interactiva pendiente | Radio efectivo visible en hover/selección. Panel y ghost calculan daño/alcance con elevación y modificadores antes de confirmar; validez de terreno usa lima/rojo intenso. Game Over agrupa únicamente tipos construidos. Los siete desbloqueos comparten fila y H/A/S se abren como tres opciones horizontales independientes; todos los nodos llevan icono y precio centrado con `exp.png` a la derecha. ADR-0114. |
| M64 UI editable y limpieza de recursos | Escaneo headless y smoke de escena principal pasados; aceptación visual pendiente | Se exponen en Inspector tamaños, fuentes, espacios, estilos y geometrías de las interfaces dinámicas; los marcadores y estilos estáticos vuelven a escenas/recursos. Iconos de estado 28×28 px; límites importados 256 px para iconos, 768 px portal, 168 px cofre. Se eliminan exactamente 26 PNG alternativos, un PNG de UI antiguo, ocho Resources de diagnóstico y una capa de preview sin uso. ADR-0115. |
| M65 Spritesheets de correr de enemigos | Assets y rutas de Resources integrados; revisión visual pendiente | Los 26 enemigos usan PNG canónicos con cuatro cuadros horizontales de 128×128 px en una hoja de 512×128 px. El ciclo comienza al aparecer en estado `MOVING`, a 8 FPS, con espejo al desplazarse a la izquierda. La carpeta de arte fuente citada en registros previos no está en el checkout actual; ver la auditoría 17. ADR-0116. |
| M66 Oferta aleatoria de reclutamientos | Código/documentación integrados; aceptación interactiva pendiente | Una torre elegible sin reclutar se garantiza; los demás espacios se sortean por peso entre cartas elegibles; máximo dos reclutamientos en tres opciones. ADR-0118. |
| M67 Feedback de vida de base | Código/documentación integrados; aceptación visual pendiente | Barra 42 px, un segmento por HP, pérdida animada, color progresivo y viñeta de baja vida desde 3 HP. ADR-0119. |
| M68 Velocidad de simulación | Código/documentación integrados; aceptación visual/interactiva pendiente | Botón junto a Pausa para ×1/×2/×3; pausa conserva el multiplicador y cada run comienza en ×1. ADR-0120. |
| M69 Tonos y gradiente de fachadas | Código/documentación integrados; aceptación visual pendiente | Grass `#407850`, Mountain `#3b3c41`; overlay negro opaco abajo a transparente arriba, compartido por tablero y previews. ADR-0121. |

Actualización transversal (2026-10-13, ADR-0055): se añadió tinte rojo y sacudida de cámara al daño de la base, inclinación/vibración del grupo de Gold al recibir recompensas y abrir cofres, velo translúcido detrás de las ofertas de terreno/mejoras con reaparición al cancelar la colocación, y portal reducido a 64×96 px. M41 sustituye parcialmente ese tamaño por el portal animado de 96×96 px. Implementación integrada; revisión visual/interactiva pendiente según `IMPLEMENTATION_AND_QA.md#acceptance`. No se ejecutaron pruebas en esta actualización.

Actualización histórica (2026-10-13, ADR-0057; la política de oferta fue sustituida por ADR-0060): la oferta incluía siempre una pieza recta marcada `ALARGA CAMINO`, con ancla/rotación de una colocación validada; una colocación de campaña quedaba bloqueada si no conservaba otra expansión legal de ruta. La previsualización conserva los portales que cerrarían, los tiñe de rojo y dibuja una X; el estado de terreno anuncia el número de cierres. La continuidad y el aviso de cierres siguen vigentes; la variedad geométrica actual está descrita en M25. No se ejecutaron pruebas en esta actualización.

### Trabajo técnico transversal — arquitectura híbrida de UI (2026-10-10)

Implementada sin crear un milestone de gameplay nuevo: `MetaShopPanel`, hacks `Ctrl+K`, tarjetas repetidas de torre/capa/mejora y tooltip de ronda usan jerarquías `.tscn`; se añadieron filas visuales reutilizables; el Theme local centraliza estilos; el catálogo de iconos y sprites de botón quedan visibles en Inspector. `Main` conserva la coordinación, señales, entradas, datos y reglas de partida. El único control creado por código sigue siendo `Label.new()` para el número flotante de daño, que pertenece al mundo. Smoke y escaneo del editor pasaron en Godot 4.7 el 2026-10-10. La comparación visual/interactiva en ventana sigue pendiente; seguir «UI — migración híbrida» en `IMPLEMENTATION_AND_QA.md#acceptance`. Decisiones: [ADR-0049](DECISION_HISTORY.md#adr-0049) y [ADR-0050](DECISION_HISTORY.md#adr-0050).

### Decisiones provisionales introducidas durante desarrollo
- M1 usa orientación pointy-top y radio visual de 38 px para el tablero debug. La orientación está registrada como provisional en `docs/rogue_tower/DECISION_HISTORY.md`.
- La antigua muestra M3 de siete hexágonos coloreaba 2 PATH, 3 GRASS y 2 MOUNTAIN en `data/terrain/starting_terrain_piece.tres`; el tablero inicial actual es un Resource independiente de 19 hexágonos (`data/terrain/starting_board.tres`). El preview usa radio de 52 px por hexágono.
- El preview M2 usa polígonos vectoriales de placeholder, sin sprites importados; cada nivel se eleva 18 px y los bordes enfrentados a terreno más bajo reciben una cara sombreada.
- El hover solo selecciona caras superiores; cambia a un color específico del terreno y el HUD presenta `(q,r)`, el tipo y la altura de la casilla.
- M3 define las cinco piezas `straight`, `gentle_turn`, `hard_turn`, `fork` y `convergence` como contenido visual provisional. `weight`/`tags` quedan reservados para el pool futuro y no alteran la selección en esta fase.
- Las conexiones PATH internas son sockets recíprocos exactos; los sockets de borde derivan aperturas laterales flexibles descritas en [ADR-0006](DECISION_HISTORY.md#adr-0006). Una pieza expansiva exige al menos un enlace compatible con PATH existente. El tablero inicial actual tiene 19 celdas, base en `(-1,0)`, camino recto por `(-1,0) → (0,0) → (1,0) → (2,0)` y salida abierta en `(3,0)`, según [ADR-0056](DECISION_HISTORY.md#adr-0056).
- M3 dibuja el tablero con el renderer vectorial temporal y el ghost sobre las celdas confirmadas; confirmar añade siete `HexCell` de forma atómica y cierra el modo de colocación.
- La navegación M3 usa `Camera2D`: botón central + arrastre panea, rueda hace zoom centrado en cursor, `H` oculta/muestra HUD y `R` centra el tablero. El HUD permanece en `CanvasLayer`.
- M4 deriva una ruta mínima en BFS por cada salida exacta externa abierta y conserva la topología de ramas en el grafo. El prototipo M5 activaba el primer candidato en orden determinista; la campaña actual activa todos los spawns alcanzables y exige cuatro celdas PATH por ruta según ADR-0025.
- El smoke histórico M5 usó una base de 50 HP y enemigos de 20 HP, velocidad 90 px/s y 10 de daño a base, tres enemigos con 1 s de separación y selección `FIRST_SORTED`. La campaña actual usa sus Resources de ronda; estos números siguen documentando el smoke original, no el balance de campaña.
- M6 añade Basic Bolt con 10 de daño, 1 ataque/s, rango base 3 hexes, mejoras +5 daño/+0.25 hex hasta nivel 3 y alcance +0.25 hex por nivel de elevación. Son placeholders históricos configurables; el bonus de altura vigente quedó fijado en M34 por ADR-0073 (+1 daño y +0,5 hex por nivel). M9 incorpora costes de run editables; ADR-0009 registra el estado histórico y ADR-0013 los valores actuales provisionales.
- M7 (contrato histórico, sustituido por M12A) usó tags de daño bitmask Físico/Fuego/Arcano y mitigación plana por Armor; `health_multiplier` modificaba el daño restante. La fuerza anti-regen `0..1` suprimía regeneración por una duración. Valores de esa etapa en ADR-0010.
- Los perfiles Armor Piercing Bolt y Sapping Bolt y el enemigo/oleada de diagnóstico M7 reutilizan arte vectorial de placeholder; se exponen en el HUD solo para probar counters. No comprometen el catálogo ni el balance final.
- El HUD de prueba de esa etapa mostraba diagnóstico del objetivo y controles de terreno bajo `F3`; el panel y selector de oleadas se retiraron en M61. M64 retiró también los Resources de oleada/dummy M7/M8 sin consumidores; permanecen únicamente los perfiles de torre de diagnóstico seleccionables con `8`, `9` y `0`. `H` sigue ocultando todo el HUD y `1–7` corresponden al roster reclutado.
- M8 añade la Status Probe, ahora disponible con `0`, y la oleada de objetivo lento. Slow refresca sin acumular; Burn acumula hasta 3 y causa daño de Fuego; Bleed causa daño Físico periódico y tiene una duración provisional menor que el intervalo entre ataques para dejar observar su expiración. M9.5 añade Poison y un aro verde. El panel debug del objetivo seleccionado muestra estados activos y tiempo restante. No hay resistencias de estado ni catálogo definitivo.
- Histórico M9: el fixture de arranque tenía 150 Gold/100 Mana y valores de coste/recompensa que no definen la campaña vigente. M64 retiró las oleadas y dummies de prueba, pero conserva Armor Piercing Bolt, Sapping Bolt y Status Probe en `8`, `9` y `0`. El saldo runtime inicial se rige por la campaña y Starting Coffers (M35/ADR-0076); Sapping Bolt conserva su coste configurado de 4 Mana por ataque.
- M10 ofrece tres piezas del pool sin reemplazo; `WaveDirector` asigna los enemigos de campaña a endpoints alcanzables en round-robin global. `HexGrid` detecta vacíos encerrados y rellena cada uno al azar con Grass/Mountain salvo las salidas PATH que deben seguir abiertas. La expansión aún debe aceptarse visualmente en juego.
- La base conserva una huella hexagonal completa en el tablero y ahora su edificio se representa con un PNG configurable en `BaseData`; la barra de salud del HUD tenía segmentos de 10 hasta M67, que la cambió a un segmento por HP. Las letras y coordenadas se quitaron de las caras y la lectura axial/tipo/altura queda en el HUD al hacer hover. Los clusters conectados de 3–4 y 5+ Grass/Mountain tienen brillo leve/medio solo como feedback visual.
- M11 histórico: el catálogo de mejora de 190 cards se compone de 18 propias, 172 Resources nuevos y la equivalencia Advanced Circuits, para representar 173 entradas compatibles. M35 añade seis cards de reclutamiento (196 IDs runtime). La cadencia cada tres rondas hasta 42 está confirmada; la oferta tiene tres opciones y M66 exige un reclutamiento cuando sea elegible, con máximo dos. Valores y rarezas permanecen configurables.

### Bugs/deuda conocida
- Falta comprobar manualmente con el puntero los colores y coordenadas del hover, además de la rotación. `run_project` confirmó que Godot 4.7 inicia la escena sin errores, pero no automatizó el movimiento del puntero.
- En M3, el usuario reportó juntas abiertas en `_draw_cliffs()`. La corrección anterior aumentaba el grosor y usaba dos triángulos; ADR-0048 la sustituye por una fachada texturizada cerrada en un quad. La nueva escena aún requiere revisión visual.
- Las aperturas laterales flexibles de PATH, sus encajes por rotación y la colocación válida/ilegal aún requieren inspección visual e interacción en Godot. También falta revisar cancelación, cámara y continuidad fuera del área inicial.
- HISTÓRICO: las pruebas M7/M8 dependían de oleadas y dummies retirados en M64. No ejecutar sus procedimientos antiguos. Las reglas vigentes de daño por capas se aceptan con M12A; Slow/Burn/Bleed y el perfil Status Probe se revisan sobre enemigos de campaña según `IMPLEMENTATION_AND_QA.md#acceptance`.
- M9 requiere comprobar en ventana el HUD inicial, compras y mejoras descontadas, rechazo por saldo insuficiente, recompensas únicas por bajas/oleada, gasto y bloqueo sin Mana, regeneración hasta capacidad y bloqueo temporal de la siguiente oleada en `ROUND_REWARD`. Procedimiento completo en `IMPLEMENTATION_AND_QA.md#acceptance`.
- M9.5 requiere observar los siete perfiles en la ventana, la diferencia de ataques, estados, Mana y el recorrido/perforación de Shredder. La inspección visual y la aceptación manual siguen pendientes; seguir el procedimiento actualizado de `IMPLEMENTATION_AND_QA.md#acceptance`.
- M10 requiere recorrer la campaña, validar el bloqueo entre ronda y expansión, ambos contadores del director, las rondas Standard 17/19 y los jefes fijados por la tabla, el aislamiento DEBUG y la victoria 45/45. La validación de recursos/código pasó; falta gameplay visual de campaña. Seguir la prueba manual M10 de `IMPLEMENTATION_AND_QA.md#acceptance`.
- M11 requiere ejecutar su aceptación manual en una partida: confirmar ofertas de exactamente tres cards en rondas 3/6/9/42 tras colocar terreno, prerequisitos/unlocks y efectos de las familias nuevas sin mutar Resources. Confirmar que el ID legado Card Draw no aparece en la tienda ni altera la oferta. Ver `IMPLEMENTATION_AND_QA.md#acceptance`.
- HISTÓRICO: la documentación de una revisión anterior describió salidas simultáneas; la distribución vigente es round-robin global por enemigo, según `WaveDirector` y la tabla de M10. También se añadieron auto-relleno interior, ofertas de tres piezas, retorno con Escape, brillo de combos, base hexagonal y un tablero inicial de 19 celdas con rutas de spawn de al menos cuatro PATH. Aún deben revisarse visualmente en ventana.

### Última verificación de motor registrada
- M64 (2026-10-15; [ADR-0115](DECISION_HISTORY.md#adr-0115)): Godot 4.7 completó el escaneo headless del editor con código 0, sin errores de parseo ni recursos faltantes. `game/main/main.tscn` arrancó en headless durante tres frames con código 0 y sin errores de script; no pudo guardar el inicio de run porque el sandbox no permite escribir el guardado temporal. El editor también avisó que no puede guardar sus preferencias fuera del workspace. Este resultado solo cubre el snapshot M64; no valida M65–M69. Falta la comprobación visual/interactiva en ventana y que los cambios de Inspector sobrevivan al ciclo de vida de los controles.
- Actualización M38 (2026-10-14; [ADR-0085](DECISION_HISTORY.md#adr-0085)): se elimina la geometría de cierres y cualquier extrusión radial; cada hex solo dibuja sus dos fachadas delanteras pointy-top. Grass/Mountain conservan su PNG y reciben un degradado multiplicativo por vértice exclusivo de las paredes. La inspección inicial en Godot 4.7 aprobó material y silueta, pero una petición posterior corrigió la extensión de las paredes y la visibilidad permanente de las tapas; la regla vigente está en [ADR-0090](DECISION_HISTORY.md#adr-0090). La matriz completa de alturas, vecinos y oclusión sigue pendiente.
- Corrección de regresiones M11/derrota (2026-10-14; [ADR-0086](DECISION_HISTORY.md#adr-0086)): la oferta base de tres cartas se descartaba al compararla con las seis ranuras del panel, por lo que la campaña avanzaba sin tienda. En esa revisión se aceptaba cualquier oferta no vacía dentro de la capacidad; esa regla quedó sustituida por la oferta y panel fijos de tres de ADR-0093. Si la oferta programada falla, la campaña queda bloqueada y muestra el diagnóstico en vez de saltarse la selección. En derrota se retorna después del cambio de escena y el preview no consulta el ratón fuera del árbol. Los smokes de UI, grafo M4, torre M6 y oleada M5 pasaron en aquella revisión; no se ejecutaron en la actual.
- M37 (2026-10-14; [ADR-0084](DECISION_HISTORY.md#adr-0084)) queda vigente para la retícula axial compartida y el orden por celda. Su cierre por vértices y cálculo de pared por desnivel vecino quedan sustituidos por M38/ADR-0085.
- Ampliación de cards y tienda permanente (2026-10-13; [ADR-0062](DECISION_HISTORY.md#adr-0062)): el pool de mejora combina 18 cards propias con 172 recursos nuevos y mapea Advanced Circuits al equivalente existente; son 190 IDs de mejora que representan 173 entradas compatibles. M35 añade seis reclutamientos (196 IDs runtime). En esa revisión el catálogo tenía 31 mejoras; ADR-0093 mantiene 30 comprables y retira `card_draw` del mapa. Se documentan exclusiones por torres/sistemas ausentes, Freeze y conflicto con la cadencia elegida por el usuario. Auditoría textual anterior: IDs únicos y prerequisitos resueltos. No se ejecutó Godot ni aceptación manual en esa revisión.
- Actualización M13 (2026-10-09; [ADR-0039](DECISION_HISTORY.md#adr-0039)): build mode muestra el retrato y stats de la torre con el bonus configurado de Mountain frente a Grass; el panel mide su contenido, los nombres/valores de capas usan color y negrita, los botones H/A/S son cuadrados con efecto y coste y Demoler queda debajo. Su escala anterior quedó sustituida en M16; el panel mantiene el contrato sin scroll. La geometría axial y reglas no cambian.
- Actualización M14–M16 (2026-10-09; [ADR-0040](DECISION_HISTORY.md#adr-0040), [ADR-0041](DECISION_HISTORY.md#adr-0041)): integrados obstáculos y cofres deterministas por seed/coordenada, mejora permanente con base 1 %, arte de terreno y props alineado, ordenación de objetos por Y, escala visual individual mayor, flechas animadas por las rutas, bloqueo de construcción, animaciones de impacto y cursores del pack local. El panel de torre se adapta a su contenido y no tiene scroll. El proyecto se abrió en Godot 4.7 durante la revisión anterior tras importar los PNG; la aceptación visual/interactiva de esta revisión sigue pendiente. Los PNG fuente Tiny Swords permanecen locales y fuera de Git; el premio del cofre (25 Gold) es provisional.
- Actualización de M13 (2026-10-09; [ADR-0038](DECISION_HISTORY.md#adr-0038)): se creó el sprite PNG de la base configurable en `BaseData`, la salud del HUD ahora se divide por bloques de 10, Gold anima icono/cifra al cambiar, Mana se repone a máximo al inicio de las rondas de campaña y se muestra entero. La barra de torres ya no tiene fondo común y cada botón usa una textura-carta propia. `git diff --check` no reportó errores de whitespace; no se ejecutó Godot ni la inspección visual, pendiente en M13.
- Auditoría documental y de Enemy/DamageService (2026-10-09): se alinearon README, fuente de verdad, roadmap, modelos, progreso, criterios, borradores y ADR con los tres pools de enemigo y su representación actual; M7 queda claramente como contrato histórico sustituido por M12A. Se aclaró el snapshot candidato del grafo en la vista previa. Godot 4.7 completó un escaneo headless del editor con código 0 y sin errores GDScript; no se abrió gameplay ni se aceptó visualmente M12A/M13.
- HISTÓRICO (2026-10-09, previo a ADR-0037): `Enemy` dibujaba filas Shield/Armor/Health cuando sus máximos eran positivos; el perfil genérico asignado entonces a la ronda 20 tenía Shield 100 y regen 1/s para exponerlo en campaña. Esa asignación fue sustituida por la tabla de 45 rondas y Ooogie von Ooogovich con balance propio. `DamageService` añade +1 al multiplicador de la capa asociada a Bleed/Burn/Poison en ataques directos; los ticks no reciben el bonus. Falta la aceptación visual/manual M12A/M13 según `IMPLEMENTATION_AND_QA.md#acceptance`.
- Godot 4.7 ejecutó `tests/path_graph_smoke.tscn`: pasan siete escenarios M4 (ruta inicial, pareja exacta/flexible, flexible que no crea spawn, salida inválida hacia GRASS, socket exacto sin pareja, PATH desconectado y bifurcación/convergencia con BFS determinista).
- Godot 4.7 ejecutó `tests/m5_wave_smoke.tscn`: ruta M4, muerte de enemigo, derrota de base y oleada completa correctos; la base queda en 20/50 HP y no hay enemigos activos.
- Godot 4.7 ejecutó `tests/m6_tower_smoke.tscn`: fases `RUN_SETUP`/prep/combat/expansión/derrota; construcción en Grass/Mountain; rechazo de PATH/ocupado; ocupación axial; mejoras y límite; bonus de elevación; prioridades first/last/highest health/highest armor; filtro de rango, cadencia, daño hitscan y descarte seguro de una referencia tras liberar el objetivo. La aserción de daño del fixture se alineó con la regla vigente M12A (+1 por nivel y elevación), pues su valor anterior pertenecía al prototipo sustituido.
- Actualización de verificación M11/derrota (2026-10-14; ADR-0086): `tests/ui_migration_smoke.tscn` pasa y comprueba que las tres cartas configuradas se abren en `CARD_OFFER` en las rondas 3, 6 y 9, aunque el panel tenga seis ranuras, y que el preview no consulta el ratón fuera del árbol. `tests/path_graph_smoke.tscn` confirma siete escenarios M4; `tests/m5_wave_smoke.tscn` y `tests/m6_tower_smoke.tscn` también pasan. La smoke M6 ahora usa un duplicado de datos con tope de dos niveles para probar el límite y confirma que la construcción no se permite durante `TERRAIN_EXPANSION`. Cada ejecución imprime su resultado PASS; Godot avisa que el host no puede leer el almacén de certificados raíz.
- Godot 4.7 arrancó `game/main/main.tscn` durante tres frames headless sin errores de escena ni GDScript. El host reportó que no pudo leer su almacén de certificados raíz, sin afectar el arranque o smoke.
- Los smokes M5/M6 pasan usando `--log-file` dentro del workspace. Sin esa opción, este host intentó escribir en un `user://logs` no disponible y Godot falló antes de imprimir el resultado; no es un fallo reproducible con la ruta de log explícita.
- Tras indexar las nuevas clases globales, Godot 4.7 cargó `game/main/main.tscn` durante tres frames headless sin errores de escena ni GDScript. El host sigue avisando que no pudo leer su almacén de certificados raíz. No se ha ejecutado la oleada de diagnóstico ni se ha revisado la UI en ventana.
- En la revisión de M7 se eliminaron referencias de tipo de `Tower`/`BuildController`/datos a las nuevas clases globales; las instancias de packet/result se crean desde `preload` y se comunican por `RefCounted`/`Node`. Esto evita que una caché de `class_name` sin regenerar impida cargar `TowerData`.
- Después de simplificar el HUD y separar clases globales, Godot 4.7 completó el escaneo de clases globales y abrió `game/main/main.tscn` durante tres frames headless sin errores de GDScript/escena. Se mantiene el aviso del host sobre certificados raíz; el escaneo headless también informó que no podía guardar preferencias del editor, sin afectar el arranque de la escena. No se hizo inspección visual ni se ejecutaron los smokes M6/M7 en esta revisión.
- M8 se ha implementado y documentado en código en esta revisión; la prueba de escena y la aceptación visual todavía no se han ejecutado. La prueba manual queda descrita en la sección M8 de `IMPLEMENTATION_AND_QA.md#acceptance`.
- M9 se implementó y documentó en la revisión anterior y se subió a `main` en `feb657a`; su aceptación manual sigue pendiente.
- M9.5 incluye perfiles y comportamientos provisionales; esta revisión alinea Tesla con descarga a todos los enemigos en alcance y elimina un multiplicador de daño oculto ligado a estados. Shredder aplica daño directo y Bleed por el 100% del daño base restante; la hoja pierde 1 por enemigo y se reparte el DoT entre sus ticks. No se ejecutó Godot ni prueba visual.
- HISTÓRICO, ampliado por ADR-0062: M11 implementaba oferta/selección y 18 cartas placeholder; M12 implementaba tienda y los upgrades permanentes propios iniciales. El estado vigente y las ramas añadidas están descritos en la tabla de hitos y el ADR-0062.
- HISTÓRICO, sustituido parcialmente por ADR-0056: una revisión anterior rotaba el tablero inicial un paso axial de 60° por run y conservaba la base en `(0,0)`. El tablero actual conserva la rotación persistente de seis orientaciones, con base en `(-1,0)` y ruta recta. La Ballista coincide con la referencia consultada: 20 RPM/3 s por disparo; su cooldown runtime es `60 / RPM`. La causa del error del save era que `JSON.parse` entrega como `float` números enteros del archivo, incluidos `version`, moneda y contadores, mientras el validador exigía `int`; ahora se convierten valores finitos integrales y se conservan los límites. También migra formato 0 o sin versión con respaldo `.bak`. La verificación headless de Godot 4.7 comprobó las seis orientaciones/rutas, la cadencia 20 RPM/3 s, la migración v0, `version: 1.0` y el JSON real del usuario. El escaneo del editor terminó con código 0; solo apareció el aviso del almacén de certificados raíz del host. Se corrigen `best_target` sin inicializar y el identificador `seed` que sombreaba la función global. No se ejecutó la escena completa ni se hizo prueba visual.
- HISTÓRICO (2026-10-08): M13 retiró el selector de campaña y datos de objetivo del panel habitual, mostrando el estado esencial, estadísticas compactas y el progreso de 20 rondas según el alcance de ese momento. ADR-0037 actualiza ahora el progreso visible a 45 rondas. La tienda de victoria/derrota separa desbloqueos y mejoras permanentes; la aceptación manual sigue pendiente en `IMPLEMENTATION_AND_QA.md#acceptance`.
- Actualización M13 (2026-10-08; [ADR-0031](DECISION_HISTORY.md#adr-0031)): los 16 iconos actuales se separaron en PNG RGBA transparentes de 256×256 bajo `assets/sprites/ui/icons/`. `IconCatalog` carga cada `Texture2D` individual y se retiraron el atlas PNG y su `.import`. Se validaron dimensiones, modo RGBA, transparencia y encuadre de varios sprites; no se ejecutó Godot ni la aceptación visual en ventana.
- Los spawns alcanzables ahora se señalan con un portal PNG independiente de pulsación suave y sin etiqueta; las flechas animadas recorren el snapshot actual del grafo. Los indicadores se refrescan al cambiar el terreno.
- Corrección M18 (2026-10-09; [ADR-0043](DECISION_HISTORY.md#adr-0043)): se quitaron las fachadas traseras y el Y-sort de paredes; cada hex elevado ahora ordena solo su superficie superior texturada, sin cubrir unidades situadas delante. En esa versión las cards dibujaban props representativos; M25 reemplazó esa política con un plan fijo compartido entre miniatura, ghost y tablero confirmado. No se ejecutó Godot ni la aceptación visual en esta revisión.
- Estandarización de props (2026-10-09; ADR-0044, tamaño después sustituido por ADR-0046): los cinco obstáculos se estiran a un destino común de 86×86 px en juego y cards, configurado en `TerrainVisualCatalog`, centrado con el desplazamiento artístico común de 6 px hacia abajo. No se ejecutó Godot ni aceptación visual en esta revisión.
- M19 (2026-10-09; [ADR-0045](DECISION_HISTORY.md#adr-0045)): se compararon fórmula de daño, niveles/XP, capas, alcance, cadencia, Mana, crítico, DoT y cards con la wiki solicitada; se documentaron las diferencias y decisiones pendientes sin importar balance. La metadata y la UI de Frost Keep ahora describen su cuadrado de alcance real; Tesla declara neutralmente el límite ignorado por `ALL_IN_RANGE`. Se añadieron pulsos de selección, brillo alfa y prioridad visual de torre, hover por elevación, feedback fuerte de Gold, aparición animada de cofre, fase lenta/desfasada de portales y flechas más lentas/escasas/tenues. Cuatro PNG se redujeron a 2× su tamaño lógico; los atlas se mantienen como fuente y sus catorce extracciones PNG son las texturas runtime. No se ejecutó Godot ni se confirmó la inspección visual.
- M20 (2026-10-09; [ADR-0046](DECISION_HISTORY.md#adr-0046)): se separaron los niveles, XP, límites y compras de Health/Armor/Shield (15 por capa; 45 total), con factores exponenciales configurables inicializados a 1,15. La UI añade nivel y barra XP por capa; las prioridades pasan a tres selectores ordenados; el ghost de torre queda por encima del mundo y usa verde/rojo por validez; la card inferior activa pulsa. Los obstáculos bajan a caja 86×86 px, y el anillo de seis celdas junto a la base se validaba históricamente a elevación 0; esa restricción queda sustituida por M34/ADR-0073. Se retiraron campos de mejora sin efecto de `TowerData`. No se ejecutó Godot ni la aceptación visual/manual.
- M22 (2026-10-10; [ADR-0048](DECISION_HISTORY.md#adr-0048)): se reparó el nombre único de `GoldGroup`, se movieron recursos arriba a la derecha y se retiraron fondos compartidos del HUD y la ronda. El botón de ronda usa sprite 9-slice; el progreso dibuja 45 puntos variables con tooltip basado en `WaveData`/`EnemyData`; las cards de expansión usan marcos individuales y conteos Path/Grass/Mountain sin ceros. Las fachadas vectoriales pasaron a sprites de roca y suelo con césped mapeados a quads cerrados. No se ejecutó Godot ni aceptación visual.
- Actualización visual (2026-10-13; [ADR-0054](DECISION_HISTORY.md#adr-0054)): Patrick Hand queda como fuente predeterminada del proyecto, también en contadores dibujados manualmente. Se eliminaron el polígono oscuro bajo las torres, el trazo ancho bajo las flechas PATH y la copia de texto desplazada de contadores; la revisión de código no encontró sombras procedurales equivalentes bajo obstáculos, enemigos o base. No se ejecutó Godot; aceptación visual pendiente.
- Actualización de tablero y renderer (2026-10-13; [ADR-0056](DECISION_HISTORY.md#adr-0056)): el camino inicial pasa a cuatro celdas PATH en línea recta dentro de los mismos 19 hexágonos, la base se mueve a `(-1,0)` y su anillo inmediato queda plano y sencillo. El preview de fachadas descarta triángulos de cierre con área degenerada antes de dibujarlos; los estados de cursor existentes vuelven a aplicarse al puntero nativo fuera del overlay de construcción. No se ejecutó Godot ni aceptación visual/interactiva.
- Actualización de Frost Keep (2026-10-13; [ADR-0059](DECISION_HISTORY.md#adr-0059)): se reemplaza el daño garantizado a todo enemigo dentro del cuadrado por copos que caen sobre PATH y solo aplican daño/Slow al contacto individual. Se adoptan daño 6, 180 RPM, Slow proporcional al daño y drenaje continuo de 2 Mana/s durante combate; las medidas de caída/contacto quedan configurables. No se ejecutó Godot ni aceptación manual.
- Actualización transversal M25 (2026-10-13; [ADR-0060](DECISION_HISTORY.md#adr-0060), [ADR-0061](DECISION_HISTORY.md#adr-0061)): cada oferta clona las piezas y fija obstáculos/cofres por seed/ronda/índice de oferta/pieza/celda local; miniatura, ghost y tablero confirmado leen los mismos datos. La pieza validada que extiende ruta se escoge con orden aleatorio entre rectas, curvas y bifurcaciones; al ser curva/bifurcación, se excluye la recta de las otras cards. Se bloquean torre/construcción/cofre/inicio durante selección de terreno, se puede pausar con `P` o el botón bajo la vida, e iniciar desde `ROUND_PREP` despeja la pausa. Los cofres botan y resplandecen en hover. Código integrado; no se ejecutó Godot ni se hizo aceptación manual.
- Actualización M26 (2026-10-13; [ADR-0063](DECISION_HISTORY.md#adr-0063)): obstáculos y portales se seleccionan en el mapa y reutilizan el panel lateral; la lista del portal muestra retratos y cantidades. La retirada n de obstáculo cuesta `25 × n²`; los portales cuestan el doble del siguiente precio de obstáculo y no se retiran si quedan tres. `PathGraph` mantiene endpoints retirados como estado de run y `WaveDirector` redistribuye el total de la oleada entre rutas activas. La extrusión visual por nivel sube a 28 px y la unión de vértice se rellena sin descartar cuñas estrechas. La escena arrancó con Godot 4.7 sin errores de parseo/runtime; quedan avisos de GDScript y la aceptación visual/interactiva.
- Las pruebas no sustituyen la inspección visual con ratón: quedan por revisar el hover/cliffs, rotación/colocación y overlay `Ctrl+D` en ventana Godot.

### Próximo paso
Completar las revisiones manuales pendientes de `IMPLEMENTATION_AND_QA.md#acceptance` en este orden: M65–M69; M63–M64; M62 y M55; M50, M49, M48, M47 y M45; M41, M40, M39, M38, M36, M35 y M34; luego M33, M32, M30, M31, M28, M27, M26 y M25. Después, completar las inspecciones M8–M14 y M17–M24; el contrato histórico M7 se verifica con M12A. La última ejecución de Godot sigue siendo M64; no se ejecutaron pruebas ni inspección visual/interactiva para M65–M69.

<a id='roadmap'></a>
## Roadmap e historial de milestones

Este documento conserva la secuencia y el alcance histórico de los milestones; no es el estado actual. El último milestone integrado es M69. La lista de trabajo pendiente y aceptación vive solo en [09 — Progreso](#progress); los contratos de diseño y sistema están asignados en el [índice maestro](README.md#index). Al trabajar, no uses una fila histórica para revivir una regla sustituida.

Los milestones se implementan en orden cuando la petición del usuario es «avanza». **No saltar al contenido final.**

### M0 — Bootstrap
- Crear/validar proyecto Godot 4.7.
- Configurar resolución, input básico, carpetas.
- Crear escena `Main`.
- Crear Autoloads mínimos: `GameState`, `RunManager`, `MetaProgression`.
- Añadir pantalla debug simple.
- Añadir `.gitignore`.
- Resultado: proyecto ejecutable vacío.

### M1 — Hex Grid lógico
- Implementar coordenadas hex axiales `q,r`.
- Vecinos 6 direcciones.
- Conversión axial <-> world/screen.
- Rotación alrededor de origen.
- Distancia hex.
- Diccionario de `HexCell`.
- Debug draw de grid.
- Tests para vecinos, rotación y conversión.
- Resultado: grid navegable y verificable.

### M2 — Terrain rendering 2D
- Implementar capas visuales.
- Placeholder para Path/Grass/Mountain.
- Elevation 0/1/2 was the original M2 prototype range; current terrain accepts 0–3 under M34/ADR-0073.
- Offset visual por elevación.
- Cliff/fachada visual separada de la celda lógica.
- Contorno cromático compartido por regiones del mismo terreno y elevación; solo en perímetros exteriores, cambios de terreno/altura y bordes contra vacío.
- Y-sort correcto para torres/enemigos/decoración.
- Hover en cara superior con color por terreno y coordenadas axiales en HUD.
- Resultado: pequeño mapa estilo "2.5D dibujado" sin 3D real.

### M3 — TerrainPiece de 7 hexágonos
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

### M4 — Grafo de caminos
- Derivar grafo desde celdas Path.
- Identificar endpoints.
- Spawn endpoints vs objetivo/base.
- Encontrar ruta válida mediante AStar2D o grafo propio sobre hexes.
- Soportar bifurcación y convergencia.
- Recalcular solo al colocar pieza.
- Visualización debug de rutas.
- Resultado: varias rutas válidas sobre mapa dinámico.

Contrato técnico del prototipo: grafo axial propio y BFS determinista sin costes; aplica las ofertas exactas/flexibles de [ADR-0006](DECISION_HISTORY.md#adr-0006). La referencia M4 a la base `(0,0)` es histórica; el tablero activo usa `(-1,0)` y una ruta recta según [ADR-0056](DECISION_HISTORY.md#adr-0056). M4 solo expone candidatos; M5 añade a `WaveDirector` una política configurable por grupo y usa `FIRST_SORTED` en la demo.

### M5 — Enemigo básico + objetivo
- Base/objetivo con Health.
- Enemy scene.
- Movimiento por ruta.
- Spawn wave.
- Llegada a base causa daño.
- Health y muerte.
- Resultado: primera oleada funcional.

Contrato histórico del prototipo M5: la base temporal se dibujaba sobre PATH `(0,0)` y la primera oleada salía del primer endpoint ordenado. La campaña actual usa un tablero semilla de radio axial 2 (19 celdas), base en `(-1,0)` y un mínimo de cuatro celdas PATH por ruta spawn-base, con trazado recto según [ADR-0025](DECISION_HISTORY.md#adr-0025) y [ADR-0056](DECISION_HISTORY.md#adr-0056). Los valores de enemigos y base descritos en ADR-0008 eran fixtures provisionales de M5; la campaña actual usa los Resources de `data/waves/` y `data/enemies/`. Durante combate se bloquea la colocación; al completar se habilita expansión. Los fixtures de depuración M7/M8 no son la progresión de campaña M10.

### M6 — Torres
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

### M7 — Damage model
- Health.
- Armor.
- Regeneration.
- Tipos/counters configurables.
- Pipeline de daño central.
- UI debug de estadísticas.
- Resultado: enemigos requieren respuestas diferentes.

Histórico de la primera implementación M7: toda torre inyectaba un `DamagePacket` en el `DamageService` de `Main`; el servicio resolvía tags de daño, Armor, Health y contrarregeneración. `EnemyData` configuraba Armor, regeneración por segundo y multiplicadores recibidos de daño físico/fuego/arcano. Los perfiles `Basic Bolt`, `Armor Piercing Bolt` y `Sapping Bolt`, además de la oleada con Armored Regenerator, eran placeholders. El antiguo HUD tenía atajos 1–3 y un panel F3 para repetir diagnósticos; M61 retiró F3 y M64 eliminó la oleada/dummy. Hoy los perfiles `8`/`9` se conservan sin selector de oleadas. M12A define el daño vigente por capas. ADR-0010/0011 preservan el alcance histórico.

### M8 — Status Effects
Implementar framework, no catálogo enorme.
- Slow.
- Burn.
- Poison o Bleed (elegir uno como tercer ejemplo provisional).
- Duración, stacks/reglas configurables.
- Resistencias si se necesitan.
- Resultado: status combinables con torres.

Contrato histórico de la primera implementación M8: `StatusEffectData` configura payloads y cada `Enemy` posee su estado runtime; Slow cambia movimiento y Burn/Bleed hacen ticks por `DamageService`. La oleada/dummy de entrenamiento se retiró en M64; Status Probe se conserva con `0` y se prueba sobre enemigos de campaña. Bleed/Poison y sus valores siguen provisionales; no hay resistencias confirmadas. ADR-0012 conserva el historial y la aceptación vigente está en [IMPLEMENTATION_AND_QA.md#acceptance](#acceptance).

### M9 — Economía de run + Mana
- Moneda de construcción.
- Costes de torres/upgrades.
- Recompensa por kills/ronda.
- Mana.
- Regen/capacidad.
- Sin support buildings.
- Resultado: economía jugable.

Contrato de implementación M9: `RunEconomyService` pertenece a `Main` y configura su estado desde `RunEconomyData`; el Gold de la run no usa `MetaProgression.meta_currency`. `TowerData` define coste de construcción, coste por cada nivel de mejora y Mana por ataque; `EnemyData` define recompensa por baja y `WaveData` la recompensa de ronda. Una baja concede su recompensa una sola vez; llegar a la base no la concede. La recompensa de ronda solo se paga al completar todos los spawns con cero enemigos vivos. Mejoras y construcciones verifican y cobran antes de confirmar la mutación; el atajo de una torre inasequible queda deshabilitado y atenuado. El Mana se consume antes de disparar y, si falta, la torre espera; la regeneración y capacidad son configurables. El perfil provisional empieza con la reserva completa, y la regeneración se describe sin decimales mediante equivalencias enteras sin cambiar su tasa interna. Los costes y cifras de arranque de esta primera integración son provisionales, no balance final. La antigua escena permitía repetir oleadas M7/M8; esos recursos se retiraron en M64 y no forman parte del loop M10.

### M9.5 — Roster jugable de demo (prioridad del usuario)
- Crear los siete perfiles aceptados: Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder.
- Dar a cada perfil un ataque, estado/coste de Mana si aplica, forma vectorial provisional y acceso de construcción en gameplay.
- (HISTÓRICO; retirado en M64) Mantener fixtures de diagnóstico M7/M8 sin desplazar el roster principal; permanecen solo las torres de diagnóstico `8`, `9` y `0`.
- Actualizar datos, aceptación y ADR antes de comenzar Cards.
- Resultado: siete torres seleccionables y construibles que pueden probarse en la escena principal.

El usuario pidió expresamente cerrar este roster antes de avanzar a M10/M11. Por ello M9.5 se ejecuta tras M9; al aceptar esta fase, M10 vuelve a ser el siguiente milestone del roadmap. La decisión histórica de aplazar Shield quedó sustituida por el alcance añadido en M12A y ADR-0023.

### M10 — Campaña de 45 rondas

- Cargar las 45 WaveData del roster y la tabla de composición aprobada.
- Crear exactamente el número directo de cada grupo, con orden y cantidad de la tabla.
- Repartir spawns secuencialmente entre endpoints alcanzables con round-robin; más rutas cambian la distribución, no el total.
- Mantener por separado spawns pendientes y enemigos activos; invocaciones y transformaciones participan en la vida de la ronda.
- Implementar habilidades configuradas por EnemyAbilityData y el kit propio de Ooogie von Ooogovich.
- Finalizar la demo después de limpiar la ronda 45.
- Tras limpiar 1–44, ofrecer y colocar una expansión; mantener el loop de terreno y la fase de cartas M11.
- Resultado: campaña de 45 rondas completa.

Contrato vigente: WaveCampaignData valida 45 entradas, continuidad de round_number, tipo de encuentro derivado de boss_tier y 1.093 enemigos directos. WaveEnemyGroupData.count es la cantidad real del grupo. Cada enemigo se asigna a una ruta por vez; las invocaciones añaden unidades fuera del total directo. Cyclops y Werewolf no son Minibosses especiales en las rondas 17/19: la tabla seleccionada manda. Ooogie von Ooogovich conserva su identidad y kit adaptado, con balance propio provisional, invoca dos Bats cada 2 s y se transforma en Bat con 2.500 Health. Su instancia y recompensa sobreviven la transformación; la oleada espera la derrota final. Los perfiles normales adoptan parámetros base y habilidades documentados en ADR-0037; no hay crecimiento global de Health, daño ni recompensa por baja. Frost Keep usa copos individuales de daño 6 a 180 RPM, Slow proporcional al daño y gasto continuo de 2 Mana/s, según ADR-0059; Tesla Coil usa daño 9. La tabla exacta y las cadencias/recompensas provisionales están en [14 — Campaña de 45 rondas](CONTENT_AND_ASSETS.md#campaign), el contenido y escalado por entidad en [13 — Catálogo de contenido](CONTENT_AND_ASSETS.md#content-roster), y las decisiones en [ADR-0037](DECISION_HISTORY.md#adr-0037). Los acuerdos previos de M10 se conservan solo como historial en sus ADR sustituidos.

### M11 — Cards
- `CardModifierOperation`, `CardData`, `CardPoolData` y `RunCardService` mantienen definición de contenido, calendario/oferta y selección separados.
- En las rondas configuradas, presentar tres cartas de mejora distintas después de colocar la expansión de terreno y antes de habilitar la ronda siguiente. Una elección obligatoria conserva la fase en `CARD_OFFER` hasta seleccionar.
- Pool con filtro `unlock_requirement`, peso de oferta, `max_per_run` y selección sin reemplazo dentro de cada oferta.
- Aplicar operaciones runtime sin mutar `.tres`: daño plano/multiplicador, alcance, multiplicador H/A/S, crítico, radio de área, coste de Mana, duración de estados, capacidad y regeneración de Mana. RPM permanece fijo, salvo el Frost Keep por cobertura PATH.
- El servicio se inyecta en torres y economía de la escena; los efectos modifican también torres ya colocadas y el preview correspondiente.
- Pool inicial M11 de 18 cards placeholder, descrito como historial de implementación. Su catálogo de mejora vigente combina 172 Resources nuevos y la Advanced Circuits existente para representar 173 entradas compatibles (190 IDs de mejora). M35 agrega 6 cards de reclutamiento, para 196 IDs runtime. Ver ADR-0062/0076.
- Calendario vigente centralizado en `data/cards/demo_card_pool.tres`: tras colocar expansión, ofrecer carta cada tres rondas entre 3 y 42. La cadencia está confirmada por ADR-0062; tamaños, rarezas y balance siguen provisionales.
  - La cantidad configurada es la cantidad de cartas que se muestran, no la capacidad máxima de seis ranuras de la UI. Una oferta programada válida abre `CARD_OFFER` antes de preparar la ronda siguiente; un error de creación no avanza la campaña.
  - Resultado: elecciones que producen builds diferentes dentro de la run. La persistencia y desbloqueos entre runs siguen siendo M12. Regresión del panel de tres cartas cubierta por `ui_migration_smoke`; ver ADR-0086.

### M12 — Meta-progression
- Moneda permanente.
- Recompensa al perder/completar.
- Tienda.
- PermanentUpgradeData.
- Desbloqueo de torres.
- Mejoras permanentes simples.
- SaveGame.
- Resultado: morir -> mejorar -> nueva run.

Contrato M12 implementado: `MetaProgression` conserva su estado fuera de las escenas de run; cada run concede moneda al terminar por victoria o derrota, con recompensa calculada a partir de rondas completas y un bonus de victoria configurable. La tienda permite desbloquear perfiles `TowerData` y comprar los 31 `PermanentUpgradeData`; la presentación terminal por pestañas es histórica y se sustituyó en M35 por un mapa de nodos, menú separado y acceso desde el menú principal. `SaveData` serializa solo primitivas en JSON versionado dentro de `user://`, con escritura temporal y copia `.bak`; un save corrupto o de otra versión se conserva sin sobrescribirse y bloquea las compras. La regla vigente de roster y Gold de inicio está en ADR-0076; ver M35, `IMPLEMENTATION_AND_QA.md#acceptance` y [ADR-0022](DECISION_HISTORY.md#adr-0022)/[ADR-0062](DECISION_HISTORY.md#adr-0062).

<a id='m12a-reglas-de-torres-y-capas-de-vida'></a>
### M12A — Reglas de torres, mejoras y capas H/A/S
- `EnemyData` y Enemy modelan los pools de Health, Armor y Shield con regeneración independiente. Cada perfil configura sus tres máximos; un máximo cero desactiva esa capa para ese enemigo. Resolver Shield→Armor→Health y dibujar una fila por capa con máximo positivo, con Health segmentada.
- Alinear los siete `TowerData` con la tabla que compartió el usuario; todos los stats permanecen configurables y el balance se considera provisional.
- Implementar disparos de Ballista/Mortar, área de Mortar, descarga de Tesla contra todos los enemigos en rango, caída e impacto individual de los copos Frost sobre PATH en rango cuadrado y RPM por cobertura, conos de Flame/Poison y hoja perforante de Shredder.
- Cada nivel añade +1 de daño base y +1 a una capa H/A/S, al comprarse con Gold o al subir por XP mientras mantiene un objetivo. La torre muestra stats y XP por capa.
- Añadir crítico por bandas, hasta tres prioridades de objetivo, precio por cantidad de torres del mismo tipo y demolición que reduce el siguiente precio.
- (HISTÓRICO; retirado en M64) Se había añadido una oleada DEBUG Health/Armor/Shield para verificar barra, daño, bonus +1 de ataque de cada estado y bloqueo de regeneración Bleed/Burn/Poison. Las capas se aceptan ahora con enemigos de campaña configurados; no se recrea el fixture.
- Resultado: los siete perfiles y las capas defensivas se pueden inspeccionar, mejorar y probar en `Main` sin alterar stats compartidos ni la campaña.

M12A está implementado en código; la aceptación manual sigue pendiente. Las reglas de capas y estados coinciden con las páginas de referencia indicadas en ADR-0023 y con la confirmación del usuario. Las cifras del roster y el pool siguen siendo configurables/provisionales. El exceso de daño al vaciar una capa se descarta según la implementación; la página de referencia no describe expresamente el overkill, por lo que esa decisión permanece provisional. Los criterios están en `IMPLEMENTATION_AND_QA.md#acceptance` y [ADR-0023](DECISION_HISTORY.md#adr-0023).

### M13 — UX/UI
- HUD según M22: salud y atajos arriba a la izquierda; Gold/Mana arriba a la derecha; oleada centrada. El timeline fijo de 45 puntos fue sustituido en M35 por una ventana fija de 15 rondas con fade futuro (ADR-0083). M55 añade el panel 9-slice compartido por Gold y los precios de torre; Mana, salud y ronda no tienen ese panel. La información de torre comienza bajo los recursos.
- Barra de Health de base con valor superpuesto y segmentos (inicialmente de 10; M67 la actualiza a un segmento por HP); sprite de base intercambiable desde `BaseData`. Gold y Mana usan iconos reutilizables, con mayor énfasis para Gold; al cambiar, su icono y cifra escalan y rebotan.
- El Mana se repone al máximo efectivo cuando empieza cada ronda de campaña, y se presenta como entero sin alterar la precisión de los cálculos internos.
- Al seleccionar una torre, mostrar en líneas legibles nivel, daño, multiplicadores H/A/S con iconos de Health/Armor/Shield, alcance, RPM, crítico, patrón, Mana y XP; conservar prioridades, mejoras y demolición en el panel derecho, que desaparece al deseleccionar.
- PNG RGBA transparentes e independientes, uno por objeto, para moneda, energía, Health/Armor/Shield, siete torres y cuatro estados; no se usa atlas. Los atajos inferiores usan un fondo individual estilo carta y los mismos iconos de la selección, preview y torre colocada; el contenedor no dibuja un panel común.
- Hover/selección de torre muestra alcance y contorno; el panel lateral ajusta su altura al contenido y nunca usa scroll. Tres selectores numerados ordenan hasta tres criterios de targeting sin duplicados.
- Enemigos muestran barras apiladas por Shield/Armor/Health con Health fragmentada, iconos de estados y contador de acumulaciones; el daño tiene destello, salto y texto flotante coloreado por capa.
- Las cards de mejora incluyen el icono de torre afectada. Los textos de economía/campaña y descripciones convierten Gold/Mana en iconos PNG reutilizables.
- En la etapa M7/M10, la inspección técnica y las fixtures DEBUG se plegaban bajo `F3`. El panel F3 fue retirado del runtime por M61; estas notas solo describen el flujo histórico de diagnóstico.
- Preview/selección de pieza y controles de rotación/confirmación/cancelación conservan indicaciones de uso y tooltips.
- Pantalla terminal clara para victoria/derrota: resultado, ronda alcanzada, rondas completas, recompensa XP y saldo de XP de perfil.
- Tienda de fin de run separa desbloqueos de torres y mejoras permanentes en categorías; muestra coste, estado de compra, efecto y acción de nueva run sin mezclar el XP de perfil con el Gold de partida.
- Tooltips explican atajos, coste, patrón de ataque, mejoras, prioridades y operaciones de terreno.
- Lenguaje visual consistente con el tablero: placas oscuras azul pizarra, bordes de acero, acciones ámbar, éxitos verde bosque y derrota terracota; sin assets externos.
- Resultado: todos los sistemas comprensibles sin debug.

Contrato base de M13 registrado en [ADR-0026](DECISION_HISTORY.md#adr-0026); la distribución en tres paneles, iconos raster transparentes y feedback de combate se especifican en [ADR-0027](DECISION_HISTORY.md#adr-0027), [ADR-0028](DECISION_HISTORY.md#adr-0028), [ADR-0031](DECISION_HISTORY.md#adr-0031) y [ADR-0038](DECISION_HISTORY.md#adr-0038). La interfaz está implementada en código; falta la aceptación manual en ventana Godot según `IMPLEMENTATION_AND_QA.md#acceptance`. El roster, las cifras y la economía no se rebalancean en este milestone.

### M14 — Vertical Slice
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

### M15 — Arte Urtuk-like pipeline (catálogo de obstáculos sustituido por M39)
- Sustituir placeholders sin tocar lógica.
- Top sprites de hex.
- Cliffs por elevación/bordes.
- Props que pueden sobresalir visualmente.
- Mantener footprint lógico limpio.
- Variantes visuales.
- Tres variantes PNG por tipo Path/Grass/Mountain y el pool inicial de cinco obstáculos transparentes asignados por semilla a celdas reales. M39 sustituye los obstáculos por ocho assets y agrega props decorativos. Obstáculos bloquean construcción.
- Resultado: mapa orgánico que oculta la rigidez de la grid.

### M16 — Polish
- Audio.
- VFX históricos de M16: los primeros impactos usaron hojas Tiny Swords; el runtime actual queda sustituido por Cozy Chunky en M51/ADR-0101.
- Cursores de Tiny Swords para normal, hover interactivo, acción inválida y colocación de torre.
- Feedback impactos.
- Transiciones.
- Cámara.
- Performance profiling.
- Balance.
- QA/save migration.

### M17 — Profundidad, arte y flujo de rutas
- Alinear atlas/terreno con caras hexagonales y separar props en nodos individuales.
- Ordenar profundidad compartida entre unidades, base, torres y decoración.
- Mostrar flechas animadas sobre cada ruta hacia la base y reducir la tasa inicial de cofres al 1 %.
- Revisar tamaño individual de sprites y documentar la aceptación visual.
- Resultado: oclusión y rutas legibles en mapas con expansiones.

### M18 — Elevación, feedback y diversidad de terreno
- Ordenar copias texturadas de las tapas elevadas con base, torres, enemigos, portales y props. Las fachadas quedan bajo las entidades y se omiten los bordes traseros; consulta [ADR-0043](DECISION_HISTORY.md#adr-0043).
- Ocultar bordes y sockets de grid hasta hover, con dos anillos vecinos de opacidad decreciente.
- Reemplazar etiquetas de spawn por un sprite PNG de portal pulsante; conservar flechas animadas del `PathGraph` hacia la base.
- Reducir y pulsar el cursor de construcción, animar el icono de torre construida y compactar/aumentar la barra de torres.
- Añadir diez piezas de terreno equilibradas sobre la huella estándar de siete hexes.
- Actualizar diseño, aceptación, ADR y progreso; revisar visualmente profundidad y navegación.
- Resultado: lectura del tablero clara con variedad de composición y sin cambiar la topología lógica.

### M19 — Auditoría de torres y detalle visual
- Documentar fórmulas runtime frente a la referencia, distinguiendo progresión, Mana, cadencia, crítico, status y capas de daño; mantener las discrepancias propias configurables.
- Corregir la representación de Frost Keep para que Resource/UI describan el cuadrado de alcance que ya aplica el código.
- Añadir pulso de selección en panel, icono, brillo alpha y rango; asegurar que la torre seleccionada se dibuje al frente con celdas elevadas.
- Colocar el hover del tablero sobre superficies por elevación; bajar velocidad, densidad y opacidad de flechas.
- Reforzar feedback de Gold, pulsar cofres al aparecer y desfasar el ciclo de los portales.
- Reducir el almacenamiento de cuatro PNG conservando su dimensión de dibujo y separar 9 tiles + 5 obstáculos en PNG runtime; conservar los atlas fuente.
- Resultado: sistema de torres auditable y respuesta visual inequívoca; aceptación visual manual pendiente.

### M20 — Progresión independiente y selección de torre
- Separar el nivel de Health, Armor y Shield: 15 mejoras posibles por capa, 45 por torre.
- Mantener +1 de daño base por mejora y sumar +1 solo al multiplicador de la capa elegida; compras Gold y XP automática incrementan el mismo nivel individual.
- Aplicar curvas exponenciales configurables para coste y XP, con factores iniciales provisionales de 1,15.
- Mostrar bajo cada mejora el nivel, XP actual/umbral en una barra teñida por capa y el coste de esa capa.
- Sustituir el control de targeting por tres selectores ordenados, con criterios únicos e intercambio visible al reordenarlos.
- Dibujar el preview de construcción delante de todos los sprites; rojo indica colocación inválida y verde una ubicación válida. Pulsar la card inferior activa de torre.
- Estandarizar obstáculos en caja 86×86 px, centrada con un pequeño offset visual, en tablero y cards.
- Criterio histórico: el anillo de la base se mantenía plano; esta restricción queda sustituida por las elevaciones aleatorias de M34.
- Resultado: progresión por capa legible, máximo de 45 subidas y selección/colocación sin feedback contradictorio.

### M21 — Depuración y claridad de selección
- Añadir hacks de run desde `Ctrl+K`, usando servicios runtime y sin editar el guardado salvo el ciclo normal de run.
- Mostrar progresivamente las prioridades de targeting; mantener el panel estable y sin recorte.
- Reforzar hover alfa de obstáculos, rebote de Gold y feedback de selección.
- Resultado: controles de diagnóstico y selección legibles; implementación integrada, aceptación manual pendiente.

### M22 — HUD, oleadas, cards y fachadas
- Distribuir vida/atajos a la izquierda, recursos arriba a la derecha y ronda en el centro. M55 añade un panel horizontal exclusivo para Gold y precios de torre; no crea un panel común de HUD.
- Presentar el progreso configurable de 45 rondas y tooltip alimentado por `WaveData`/`EnemyData`.
- Usar marcos editables para iniciar ronda y para las cards de terreno; simplificar conteos a tipos presentes.
- Sustituir fachadas vectoriales por texturas de roca/suelo con césped sobre quads cerrados.
- Resultado: HUD acorde al roster y terreno con lectura visual consistente; aceptación visual pendiente.

### M23 — Navegación, portales y Tower Info
- Añadir paneo WASD, previews de portales, distribución de spawns y tooltip de composición.
- Mantener un ghost de torre verde/rojo, quitar las sombras generadas por código y simplificar Tower Info.
- Simplificar los sprites de cofre/portal y sus filtros; conservar cursor, hitbox y navegación lógica.
- Resultado: navegación y selección legibles; código/arte integrados, revisión visual/interactiva pendiente.

### M24 — Feedback de daño
- Animar números de daño por capa, alternando trayectorias/carriles para reducir solapamiento.
- Diferenciar críticos y mantener el cálculo en `DamageService`.
- Resultado: feedback de impactos legible sin cambiar el daño runtime; aceptación visual pendiente.

### M25 — Oferta de terreno, pausa y control de fases
- Crear por oferta una copia de cada pieza con rolls fijos de obstáculos/cofres; reutilizarlos en miniatura, ghost y tablero confirmado.
- Elegir una colocación válida de continuidad entre piezas rectas, curvas y bifurcadas; al ofrecer una curva/bifurcación, omitir la recta como alternativa.
- Bloquear construcción, selección de torres, cofres e inicio de ronda durante selección/colocación de terreno y cards.
- Añadir pausa/reanudación con `P` y botón bajo la vida; `StartWave` despeja la pausa desde `ROUND_PREP`.
- Animar el hover de cofres con bote y resplandor dorado.
- Resultado: oferta con contenido visual fiel, expansión segura y fases sin acciones de torre; código integrado, aceptación interactiva pendiente. Ver [ADR-0060](DECISION_HISTORY.md#adr-0060) y [ADR-0061](DECISION_HISTORY.md#adr-0061).

### M26 — Selección y retirada de objetos, y lectura de elevación
- Seleccionar obstáculos y portales desde el tablero y mostrar su información en el panel HUD, con los nombres del catálogo y lista de enemigos con sprites por portal.
- Permitir pagar para quitar obstáculos con coste `25 × n²` por obstáculo retirado; retirar portales cuesta el doble del siguiente precio de obstáculo y mantiene al menos tres activos.
- Repartir el total de enemigos de cada oleada entre los portales que sigan activos.
- Cerrar las cuñas estrechas de fachadas en vértices sin descartar triángulos pequeños y aumentar el offset visual de elevación de 18 a 28 px por nivel. El rango lógico 0–2 descrito en este hito histórico se amplió a 0–3 en M34/ADR-0073.
- Resultado: limpieza de mapa y selección informada integradas; aceptación interactiva y revisión visual de fachadas/alturas pendientes. Ver [ADR-0063](DECISION_HISTORY.md#adr-0063).

### M27 — Cards, economía de demolición y lectura de altura (presentación sustituida en M34/M36/M40)
- Diseño original: reutilizar un panel de Upgrade Card con fondos por rareza, marco compartido e icono grande para toda operación que aparezca en una oferta. M34/ADR-0075 sustituyó los fondos por rareza por una superficie común; M36 añadió temporalmente un sprite vertical/tier y M40/ADR-0088 volvió a una superficie plana sin sprite.
- Devolver al demoler el precio marginal del slot ocupado según tipo y cantidad; los niveles de la torre no afectan al reembolso.
- Sortear cofres al confirmar una expansión, no en la miniatura/ghost, y animar su aparición con un salto.
- Proyectar sombras alfa de losetas y obstáculos con distancia vinculada a elevación y orientación rotatoria lenta.
- Corregir las advertencias de GDScript reportadas.
- Resultado: cards completas y una lectura más clara de recompensa y altura; código/PNG integrados, revisión visual/interactiva pendiente. Ver ADR-0064/0065/0066.

### M28 — Hacks de progresión para pruebas
- Añadir un hack que salte a la siguiente ronda con oferta programada de cards y use el pool real.
- Abrir la tienda de mejoras generales desde el panel de hacks.
- Añadir un reinicio de prueba que quite los niveles de mejoras permanentes, devuelva el XP invertido y vuelva al arsenal inicial, conservando XP no gastado y estadísticas.
- Resultado: probar cards y compras desde el inicio sin esperar el loop normal; no se simulan recompensas de las rondas omitidas. Ver ADR-0067.

### M29 — Sombras receptoras por elevación (retirado)
- La primera versión se implementó brevemente y luego se retiró por petición explícita; no forma parte del estado actual del juego.
- Ver ADR-0068 como historial técnico y ADR-0070 para el estado vigente sin sombras.

### M30 — Eliminar sombras generadas y despejar preview PATH
- Eliminar el overlay, el shader, los UID y todas las llamadas que proyectaban sombras de terreno y obstáculos.
- Durante la selección/colocación de una pieza de expansión, ocultar flechas PATH y trazos de sockets/diagnóstico encima del camino.
- Resultado: tablero sin sombras generadas y preview de terreno claro; aceptación visual pendiente. Ver [ADR-0070](DECISION_HISTORY.md#adr-0070).

### M31 — Arsenal inicial, XP y lectura de altura
- Dejar Ballista, Mortar y Tesla Coil como unlocks permanentes gratuitos iniciales; M35 fija únicamente a Ballista en el roster de construcción al inicio de la run y recluta Mortar/Tesla mediante cards. Fijar costes de XP de perfil de 50 para Frost Keep/Flame Thrower/Poison Sprayer y 100 para Shredder.
- Hacer que el hack de reinicio restablezca mejoras permanentes y el arsenal inicial; las runs normales conservan compras.
- Mostrar en Tower Info la altura y el bonus real de daño/rango de la torre seleccionada.
- Resultado: el jugador ve una progresión de unlock/reclutamiento y entiende el efecto de construir en altura. Ver [ADR-0069](DECISION_HISTORY.md#adr-0069) y [ADR-0076](DECISION_HISTORY.md#adr-0076).

### M32 — Marco de Upgrade Cards y colocación automática (presentación sustituida en M34/M36/M40)
- Diseño original: dibujar la textura de tier como fondo y el marco común como borde 9-slice alrededor del panel. M34/ADR-0075 retiró los fondos por rareza; M36 añadió temporalmente sprite-panel vertical y tier; M40/ADR-0088 sustituye el sprite por una superficie plana con aura procedural.
- Quitar de las miniaturas de expansión las ramificaciones y flechas de conexión PATH.
- Mostrar durante la colocación el atajo `T` y buscar/confirmar una posición válida al pulsarlo; respetar validador, grafo y continuación futura. Si no existe, informar al jugador sin modificar el tablero.
- Resultado: cards legibles y alternativa rápida que conserva las reglas de expansión. Ver [ADR-0071](DECISION_HISTORY.md#adr-0071).

### M33 — Rotación y tooltip compacto de terreno
- Restaurar `Q`/`E` para rotar en ambos sentidos; M33 asignó la rueda a rotación durante colocación. M55 sustituye esa parte: rueda sin modificador hace zoom siempre y `Ctrl+rueda` rota durante colocación.
- Asignar `T` a la colocación automática existente y mantener visible su aviso durante la expansión.
- Mostrar al hover sin selección un tooltip pequeño con tipo/estado de terreno, elevación y bonus de daño/alcance de las torres compatibles; ocultarlo ante selecciones o paneles contextuales.
- Resultado: interacción de colocación consistente y lectura rápida de los hexes; revisión visual/interactiva pendiente. Ver [ADR-0072](DECISION_HISTORY.md#adr-0072).

### M34 — Elevaciones 0–3, vida de base y presentación de cards
- Permitir PATH 0, Grass 1–2 y Mountain 2–3, sorteados de forma reproducible por mapa/oferta; aplicar +1 daño base y +0.5 de alcance por nivel y mostrar el bonus de daño sobre cada torre elevada.
- Fijar la base en 10 HP iniciales; Fortification permanente añade +1 HP por nivel hasta 20, con costes 20–200 XP y compra secuencial. Fortification I–III de run suman +3 HP cada una. Un boss que toca la base termina la run inmediatamente.
- Sustituir las variantes PNG por rareza por un panel común; M36 añade temporalmente un sprite vertical y etiqueta de tier, y M40 vuelve a un panel plano compartido sin sprite. La rareza controla el aura de color, no la superficie.
- Resultado: código y datos integrados; aceptación visual/interactiva pendiente. Ver [ADR-0073](DECISION_HISTORY.md#adr-0073), [ADR-0074](DECISION_HISTORY.md#adr-0074) y [ADR-0075](DECISION_HISTORY.md#adr-0075).

### M35 — Menú, reclutamiento, tienda de nodos y correcciones de lectura
- Iniciar cada run con 1.000 Gold (+100 por nivel Starting Coffers, hasta 2.000) y únicamente Ballista en la barra; reclutar Mortar/Tesla y torres permanentemente desbloqueadas con cards en las ofertas cada tres rondas. Una torre no reclutada no se puede construir.
- Separar menú, partida y pausa en escenas; Escape pausa; tras derrota se vuelve al menú con tienda abierta. Mostrar un resumen compacto de número de torres construidas y daño por tipo desbloqueado.
- Mostrar la tienda permanente como mapa conectado de tarjetas/nodos compartidos, icono grande, tooltip de prerequisitos y partículas al desbloquear.
- Mostrar 15 rondas en el timeline, sin selector, conservando hover y fade al futuro; limitar obstáculos a dos por pieza y a uno en tablero inicial excluyendo base/anillo vecino.
- Cerrar las tapas hexagonales, mantener UV de terreno sin estirar, ordenar celdas delanteras/detrás en la cámara isométrica fija y mostrar bonus de elevación en el ghost de Ballista.
- Resultado: código/datos integrados; aceptación visual/interactiva pendiente. Ver M35 en `IMPLEMENTATION_AND_QA.md#acceptance` y ADR-0076–0079.

### M36 — Cards de tier, ramas paralelas y lectura cromática de altura (presentación de card sustituida por M40)
- La implementación temporal usó un sprite vertical compartido para las upgrade cards, el tier visible y separación entre opciones; M40 reemplaza el sprite por una superficie plana común con aura radial procedural.
- Al desbloquear permanentemente una torre, exponer como opciones hermanas sus mejoras Health, Armor y Shield, comprables en cualquier orden.
- Añadir a las tapas un tinte multiplicativo según elevación, usando el mismo cálculo en superficies normales y Y-sorted; M49 introdujo 1,00/0,96/0,92/0,88 y M50 actualiza el tinte vigente a 1,00/0,95/0,90/0,85.
- Resultado: código y catálogo integrados; aceptación visual/interactiva pendiente. Ver [ADR-0080](DECISION_HISTORY.md#adr-0080), [ADR-0081](DECISION_HISTORY.md#adr-0081) y [ADR-0082](DECISION_HISTORY.md#adr-0082).

### M37 — Retícula geométrica axial y profundidad de terreno
- Calcular las seis esquinas pointy-top desde claves enteras axiales, de modo que celdas vecinas compartan exactamente el mismo punto en tapa, fachada, hover, miniatura y copia Y-sorted.
- Pintar cada celda como una unidad de profundidad y mantener la cámara fija; el detalle vigente de las paredes se concreta en M38.
- Conservar UV de terreno/cliff, cámara fija, elevación lógica y oclusión de entidades por sus superficies Y-sorted.
- Resultado: geometría axial y orden por celda integrados; la aceptación visual pendiente cubre elevaciones 0–3. Ver [ADR-0084](DECISION_HISTORY.md#adr-0084).

### M38 — Fachadas delanteras simples y degradado de cliff
- Renderizar solo las dos aristas delanteras del hex pointy-top como quads verticales; no dibujar paredes en las caras laterales/traseras, extrusión radial ni cierres de vértice.
- Mantener la tapa hexagonal completa: cada pared llega solo a la altura de la tapa vecina (o al suelo si el borde está vacío) y nunca la invade. Ver [ADR-0090](DECISION_HISTORY.md#adr-0090).
- Aplicar a las paredes Grass/Mountain un degradado multiplicativo por vértice desde el color actual arriba hasta un tono muy oscuro abajo; las tapas superiores no cambian.
  - Resultado: renderer y fuente activa de documentación integrados; el usuario aprobó el aspecto actual como referencia visual. La revisión de todas las combinaciones de altura/oclusión sigue pendiente. Ver [ADR-0085](DECISION_HISTORY.md#adr-0085).

### M39 — Props, obstáculos y base en su hexágono
- Limitar a altura 1 las seis celdas adyacentes a la base: Path continúa a 0, Grass queda en 1 y Mountain se normaliza a Grass.
- Conservar el PNG fuente 270×352 px de la base, pero escalarlo uniformemente para que ocupe una celda hexagonal dentro de una caja máxima de 86×86 px.
- Importar los 18 props como PNG de 96×96 px con nombres `prop_<terreno>_<elemento>.png`; cada asset compatible tiene una probabilidad independiente de 10 % por celda, sin IDs duplicados y con máximo dos props de 36×36 px separados para no solaparse. Los props son solo decorativos y los obstáculos se dibujan encima.
- Reemplazar los cinco obstáculos antiguos por los ocho nuevos PNG de 208×208 px en la carpeta raíz de obstáculos. Mantener sus tasas de aparición, la caja de dibujo de 86×86 px y centrar el sprite en el hex; retirar archivos antiguos y referencias runtime.
- Resultado: datos, recursos, renderer, herramienta de arte y documentación integrados; aceptación visual pendiente. Ver [ADR-0087](DECISION_HISTORY.md#adr-0087).

### M40 — Presentación compacta de upgrade cards
- Usar una card compartida con superficie plana, sin sprites/marcos variantes por tier o rareza. Mantener icono grande, etiqueta de tier, título y descripción legibles y separación entre opciones.
- Mostrar exactamente tres opciones en tres columnas; Card Draw queda retirado del mapa porque la oferta no puede ampliarse.
- Dibujar detrás de cada card un aura radial tenue con partículas animadas. El color del aura expresa rareza y el hover puede intensificarlo, sin cambiar la superficie.
- Resultado: escena y shader integrados; aceptación visual en ventana pendiente. Sustituye la presentación de ADR-0080 y conserva las ramas paralelas de ADR-0081. Ver [ADR-0088](DECISION_HISTORY.md#adr-0088).

### M41 — Escala, oclusión y animación del terreno
- Mantener la resolución fuente de la base y reducir solo su escala de presentación a un footprint máximo de 86×86 px.
- Ordenar las fachadas delanteras por Y con las entidades, de modo que los enemigos detrás queden cubiertos y los que pasan delante permanezcan visibles.
- Usar los ocho frames del atlas `spawn_portal_SpriteSheet.png` (4×2, 443×443 px por frame) en un bucle continuo a 10 FPS; asignar una fase inicial diferente a cada endpoint visible.
- Subir los props a 36×36 px y la probabilidad independiente por asset/celda al 10 %, manteniendo un máximo de dos sin solapamiento y el obstáculo delante.
- Corregir el error de parseo de `TerrainPiecePreview` en la normalización del anillo de base.
- Resultado: código y documentación integrados; aceptación visual e interactiva pendiente según [M41](#acceptance). Ver [ADR-0089](DECISION_HISTORY.md#adr-0089).

### M42 — Contornos compartidos por región
- Omitir las aristas internas entre celdas del mismo tipo de terreno y elevación; dibujar los bordes contra vacío y otras regiones con el color propio de cada terreno.
- Compartir la regla entre tablero, superficies elevadas, hover y miniaturas, conservando tapas, elevación y oclusión axial.
- Resultado: código integrado; M43 añade uniones redondeadas para evitar cortes en vértices. Ver [ADR-0091](DECISION_HISTORY.md#adr-0091).

### M43 — Centrado, pulido y organización de sprites
- Dibujar todas las torres un 20 % más grandes y con su ancla centrada en el hexágono; usar el mismo tamaño y posición para el ghost.
- Cerrar suavemente las juntas de los contornos, y hacer que las fachadas Grass/Mountain empiecen desde su color de terreno actual y mantengan el degradado oscuro inferior.
- Ampliar props y obstáculos un 10 % (39,6 y 94,6 px de caja visual) sin cambiar sus reglas de aparición ni orden.
- Omitir el octavo frame repetido de la animación del portal y ocultar inmediatamente el tooltip al eliminar bajo hover ese portal.
- Reunir los sprites y sus `.import` bajo `assets/sprites/`, conservar subcarpetas por categoría y actualizar rutas de código, datos, escenas y herramientas. Mantener Tiny Swords ignorado por Git.
- Resultado: código, assets y documentación integrados; aceptación visual pendiente. La escala original de +20 % fue refinada por M53/M54 y reducida otro 10 % por M55. Ver [ADR-0092](DECISION_HISTORY.md#adr-0092) y [ADR-0104](DECISION_HISTORY.md#adr-0104).

### M44 — Preview exacto, oferta fija y torres articuladas
- Reutilizar el mismo snapshot de celdas candidatas para dibujar la expansión y confirmarla, incluyendo elevación, contenido determinista y celdas auto-rellenadas.
- Dibujar contornos sin inset y compartir uniones redondeadas en superficies, preview y miniaturas. La paleta y el trazo plano vigentes quedan fijados por M46/ADR-0095.
- Mantener todas las ofertas de mejora exactamente en tres cartas; garantizar un reclutamiento elegible, limitar a dos el total de reclutamientos y sortear por peso los demás espacios. Preservar para después los reclutamientos no seleccionados.
- Reemplazar los siete iconos canónicos por las imágenes entregadas. El montaje articulado original quedó sustituido en M50: una textura compuesta cacheada por torre alimenta un solo sprite en mundo y ghost, que mira lateralmente con espejo horizontal.
- Añadir trazo blanco con shader alfa a sprites de torre y obstáculos, conservando el orden Y-sort individual.
- Resultado: código/assets/documentación integrados; aceptación visual e interactiva pendiente. Ver [ADR-0093](DECISION_HISTORY.md#adr-0093).

### M45 — Navegación de mejoras y contorno legible del terreno
- Quitar del mapa permanente las instrucciones del pie y el botón de nueva run; poner un cierre fijo arriba a la derecha que vuelve a la escena principal.
- Separar y ampliar los clusters de progreso, conservar iconos por nodo y permitir scroll o arrastre con botón izquierdo/central. Las ramas Health/Armor/Shield de cada torre ocupan una fila horizontal común.
- Hacer que cada nivel de torre aumente su escala suavemente, con un máximo visual de +12 % tras sus 45 mejoras posibles.
- Conservar el perímetro por región `(terrain_type, elevation)` y el hover de baja intensidad. M46/ADR-0095 sustituye la paleta y elimina la línea oscura de separación; las dos fachadas delanteras mantienen sombreado direccional distinto, sin cambiar sus quads ni dibujar caras laterales/traseras.
- Resultado: implementación de código/documentación integrada; aceptación visual/interactiva pendiente. Ver [ADR-0094](DECISION_HISTORY.md#adr-0094).

### M46 — Contorno regional oscuro y base más visible
- Nombrar el efecto **contorno de región de terreno**. Mantener el perímetro agrupado por `(terrain_type, elevation)`, sus vértices axiales y uniones redondeadas; dibujarlo con un único tono plano, sin keyline ni relleno interior. Grass usa `#406e4d`, Mountain `#646567` y Path conserva amarillo.
- Mantener intacto el PNG de la base y su huella lógica de un hexágono. Estirar su sprite a 1,8 × el radio de huella de ancho y 2,8 × de alto, anclando el borde inferior para ampliar la silueta hacia arriba; el valor es visual provisional.
- Resultado: código y documentación integrados; aceptación visual pendiente. Ver [ADR-0095](DECISION_HISTORY.md#adr-0095) y [ADR-0096](DECISION_HISTORY.md#adr-0096).

### M47 — Outline de base y enemigos
- Aplicar a la base el mismo contorno blanco de dilatación alfa de las torres y los obstáculos.
- Aplicar el mismo shader a los sprites de enemigos mediante una capa outline-only que siga el tamaño, orientación y salto de impacto de la ilustración; asignar un color claro distinto según el ID de perfil y mantener barras/estados por encima.
- Conservar el Y-sort de las entidades y fachadas.
- Resultado: código y documentación integrados; aceptación visual pendiente. Ver [ADR-0097](DECISION_HISTORY.md#adr-0097).

### M48 — Grosor de outlines y contorno de portales
- Reducir el grosor del outline blanco de la base a `outline_size_px = 6` y aumentar ligeramente el de los enemigos a `2`.
- Mantener en portales un contorno blanco permanente con el mismo shader y tamaño `3` que los obstáculos; conservar el resplandor contextual que aparece en hover, candidato y cierre previsto.
- Sincronizar el borde de portal con los frames y el pulso de su animación, sin cambiar su hitbox ni su fase independiente.
- Resultado: código y documentación integrados; aceptación visual pendiente. Ver [ADR-0098](DECISION_HISTORY.md#adr-0098).

### M49 — Lectura de altura y velo de nubes
- Mostrar la insignia de bonus de altura de las torres construidas solo durante hover; mantener la lectura del bonus en el ghost de colocación. Separar el tooltip de celda 24 px horizontalmente del cursor.
- Oscurecer las tapas de forma neutra y acumulativa por nivel (h0 1,00; h1 0,95; h2 0,90; h3 0,85), compartiendo el cálculo con tablero, previews y superficies Y-sorted.
- Añadir una capa procedural animada de sombra de nubes sobre los sprites del mundo y debajo del HUD; las sombras individuales por sprite siguen desactivadas.
- Auditar cada PNG de `assets/sprites/` y registrar referencias activas y archivos sin uso localizado en la documentación.
- Resultado: código/documentación integrados; aceptación visual pendiente. Ver [ADR-0099](DECISION_HISTORY.md#adr-0099).

### M50 — Sprite único de torre y tinte de altura
- Componer y cachear una textura RGBA por torre alineando las partes existentes; usar un solo Sprite2D en el mapa y el ghost, sin pivote ni rotación visual. Apuntar a izquierda con espejo horizontal y mantener la orientación derecha por defecto.
- Usar el mismo sprite compuesto en la carta de construcción y el retrato de Tower Info; ampliar retrato, nombre y precio para aprovechar el panel.
- Ajustar el tinte multiplicativo de las tapas a 5 % por nivel (h0 1,00; h1 0,95; h2 0,90; h3 0,85), compartido por tablero, previews y copias elevadas.
- Resultado: código/documentación integrados; aceptación visual pendiente. Ver [ADR-0100](DECISION_HISTORY.md#adr-0100).

### M51 — VFX de combate, estados y feedback de juego
- Integrar los spritesheets Cozy Chunky para disparos e impactos de las siete torres; Mortar marca con `tap_ripple` la posición objetivo.
- Mostrar `star_burst_gold` y `level_up` en cada subida manual o automática; `base_hit` al recibir daño; `coins_top` al derrotar enemigos; `coin_burst_gold` y `pickup` al abrir cofres; `item_glow` detrás de cofres disponibles; `ui_click` en el cursor al interactuar con objetos; `sparkle_twinkle_white_loop` al confirmar terreno y `confetti_burst_01` al volver al menú tras acabar la run.
- Reemplazar iconos estáticos por hojas animadas de estado y cubrir Bleed, Burn, Poison, Slow, Haste, Fortification y Stun con los recursos Cozy Chunky correspondientes.
- Ejecutar VFX de evento en una capa superior persistente que no se congele durante cards/terreno; mantener la torre como un solo sprite compuesto centrado en el hexágono con desplazamiento visual uniforme de 8 px hacia abajo en torre y ghost.
- Resultado: código/assets/documentación integrados; inspección visual e interactiva en Godot pendiente. Ver [ADR-0101](DECISION_HISTORY.md#adr-0101).

### M52 — Sprites completos de torre y cadencia de feedback
- Cargar directamente los siete PNG completos de torre, eliminar recortes/pivotes antiguos y compartir el mismo sprite centrado en mundo, ghost, selección y Tower Info; mantener el offset visual de 8 px y ampliar la escala.
- Dosificar la partícula `shoot` en las torres de fuego continuo (Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder) con intervalo aleatorio de 2,0–2,5 s; Ballista y Mortar conservan el efecto de cada disparo. No se limitan impactos ni ataques.
- Reproducir `pickup.png` al construir una torre y al retirar un obstáculo, además de conservarlo al abrir cofres.
- Resultado: código/documentación integrados; aceptación visual pendiente. Ver [ADR-0102](DECISION_HISTORY.md#adr-0102).

### M53 — Escala de torre sin recorte
- Reducir ligeramente la escala de los sprites de torre en tablero y ghost de 1,44 a 1,32, manteniendo su alineación y el offset visual de 8 px.
- Mantener sin cambios el tamaño de los iconos de cards y Tower Info.
- Resultado: código/documentación integrados; aceptación visual pendiente. Ver [ADR-0103](DECISION_HISTORY.md#adr-0103).

### M54 — Reducción adicional de escala de torre
- Reducir exactamente un 20 % la escala de tablero/ghost vigente de 1,32 a 1,056, manteniendo alineación, offset de 8 px y PNG completo.
- Mantener sin cambios el tamaño de cards y Tower Info.
- Resultado: código/documentación integrados; aceptación visual pendiente. Ver [ADR-0104](DECISION_HISTORY.md#adr-0104).

### M55 — Tooltip de spawn, atajos de torres, panel de Gold y zoom
- Retirar los retratos flotantes de enemigos sobre cada portal y conservar los tipos/conteos en un tooltip de hover con retratos.
- Numerar las torres reclutadas en orden visible y asignarles atajos dinámicos `1–N`; mostrar la tecla en su card.
- Reservar la rueda sin modificadores para zoom, incluso durante colocación de terreno; `Ctrl+rueda` rota la pieza y Q/E siguen disponibles.
- Compartir el panel 9-slice del botón Iniciar ronda entre precios de torre y el Gold del HUD; Mana quedó sin panel en esta etapa, sustituido por M61/ADR-0112.
- Reducir un 10 % adicional la escala de torres colocadas y ghost: 1,056 → 0,9504; los iconos de UI no cambian.
- Resultado: código/documentación integrados; aceptación visual e interactiva pendiente. Ver [ADR-0105](DECISION_HISTORY.md#adr-0105).

### M56 — Feedback de progresión, cards y oclusión
- Ampliar y ordenar los iconos de estado; multiplicar por cinco la XP automática de seguimiento y usar el mismo feedback visual para subidas automáticas y manuales.
- Dar iconos temáticos a las mejoras permanentes y hover inclinado con brillo radial a las cards de mejora, terreno y torre.
- Mantener la oclusión Y-sort de las fachadas. La columna H/A/S y el agua oscura de esta etapa quedaron sustituidas por M59 y M57.
- Resultado: integrado; aceptación visual e interactiva pendiente. Ver [ADR-0107](DECISION_HISTORY.md#adr-0107).

### M57 — Agua luminosa y explosión pixel de enemigos
- Sustituir el agua oscura por manchas azules grandes y espuma casi blanca con movimiento lento.
- Al morir un enemigo, muestrear su sprite/frame/orientación/escala en una ráfaga GPU reutilizable y conservar el feedback `coins_top`.
- Resultado: integrado; aceptación visual y revisión de rendimiento pendientes. Ver [ADR-0108](DECISION_HISTORY.md#adr-0108).

### M58 — Sombra de nubes y agua anclada a cámara
- Reforzar la opacidad de la sombra de nubes y anclar el patrón del agua a las coordenadas visibles del mundo durante paneo y zoom.
- Resultado: integrado; aceptación visual pendiente. Ver [ADR-0109](DECISION_HISTORY.md#adr-0109).

### M59 — Mejoras de torre en fila y shake de ronda
- Presentar Health, Armor y Shield en una fila de botones cuadrados y compartir el panel de coste con las cards de torre.
- Añadir una sacudida de cámara ambiental durante la ronda y combinarla con el impacto separado por daño a base.
- Resultado: integrado; aceptación visual pendiente. Ver [ADR-0110](DECISION_HISTORY.md#adr-0110).

### M60 — Barra de XP y precios de demolición
- Hacer la barra XP H/A/S más legible y mostrar `DEMOLER` con el reembolso/coste Gold; los portales mantienen `RETIRAR` con su coste.
- Resultado: integrado; aceptación visual pendiente. Ver [ADR-0111](DECISION_HISTORY.md#adr-0111).

### M61 — Legibilidad de mejoras, HUD y colocación
- Colorear ganancias y pérdidas, compactar la pausa y hacer visibles Q/E/T durante la colocación de terreno.
- Mostrar la composición de un portal seleccionado en Tower Info, unificar los paneles Gold/Mana y retirar el panel técnico F3 y el selector runtime de fixtures.
- Resultado: integrado según la especificación; aceptación visual e interactiva pendiente. Ver [ADR-0112](DECISION_HISTORY.md#adr-0112).

### M62 — Correcciones de paneles y pausa de agua
- Corregir rutas y jerarquía de paneles de retirada, centrar iconos H/A/S y exponer en Inspector el layout de Tower Info.
- Mantener el detalle del portal seleccionado y congelar el patrón de agua durante pausa.
- Resultado: integrado; aceptación de escena pendiente. Ver [ADR-0113](DECISION_HISTORY.md#adr-0113).

### M63 — Alcance, ghost exacto y mapa de mejoras
- Compartir cálculos efectivos de daño/alcance entre torre, ficha y ghost; mostrar el radio de ataque en hover/selección y reforzar el color de validez del terreno.
- Resumir solo los tipos de torre desplegados y alinear los siete unlocks con tres opciones H/A/S independientes en paralelo.
- Resultado: integrado; aceptación visual e interactiva pendiente. Ver [ADR-0114](DECISION_HISTORY.md#adr-0114).

### M64 — UI editable desde Inspector y limpieza de recursos
- Hacer que fuentes, tamaños, márgenes, separaciones, estilos de card, timeline, mapa permanente, portales y feedback H/A/S se editen desde escenas, Themes, StyleBoxes o propiedades exportadas, sin valores visuales ocultos que reemplacen la configuración guardada.
- Reducir iconos de estado a 28×28 px y limitar la resolución importada de iconos, portal y cofre según su tamaño de dibujo, conservando los PNG originales.
- Retirar recursos sin consumidores: 26 PNG alternativos autorizados, el marco antiguo de Tower Info, la capa de preview de portal no instanciada y Resources de enemigo/oleada M7/M8 que ya no puede seleccionar el juego.
- Conservar los perfiles de torre DEBUG `8`, `9` y `0`, todavía funcionales en partidas normales.
- Resultado: código/documentación integrados; aceptación de escena y revisión visual pendientes. Ver [ADR-0115](DECISION_HISTORY.md#adr-0115).

### M65 — Ciclos de correr para el roster enemigo
- Sustituir los 26 sprites canónicos por hojas de cuatro cuadros de correr y conectarlas a los Resources actuales, sin cambiar datos de combate.
- Mantener orientación a la derecha, animar desde que entran en `MOVING` y usar el espejo horizontal para rutas hacia la izquierda.
- Resultado: assets/código/documentación integrados; revisión visual en Godot pendiente. Ver [ADR-0116](DECISION_HISTORY.md#adr-0116).

### M66 — Reclutamientos garantizados dentro de una oferta aleatoria
- Garantizar una carta de reclutamiento si hay una torre elegible que aún no esté en el roster; evitar que reclutamientos ocupen los tres espacios.
- Sortear por peso las demás opciones entre cartas elegibles, con máximo de dos reclutamientos y sin reemplazo.
- Resultado: código/documentación integrados; aceptación interactiva pendiente. Ver [ADR-0118](DECISION_HISTORY.md#adr-0118).

### M67 — Feedback ampliado de vida de la base
- Aumentar aproximadamente 50 % el indicador de salud del HUD y mostrar un cuadro por HP, con animación al perder cada cuadro y color que transita de verde a rojo.
- Añadir una viñeta progresiva a 3/2/1 HP y pulso lento y suave al permanecer en 1 HP.
- Resultado: código/documentación integrados; aceptación visual pendiente. Ver [ADR-0119](DECISION_HISTORY.md#adr-0119).

### M68 — Velocidad de simulación de la partida
- Añadir junto a la pausa un botón que alterne ×1, ×2 y ×3, con el multiplicador actual visible.
- Conservar la velocidad al pausar/reanudar y restablecer ×1 al iniciar otra run.
- Resultado: código/documentación integrados; aceptación visual e interactiva pendiente. Ver [ADR-0120](DECISION_HISTORY.md#adr-0120).

### M69 — Color y gradiente de las fachadas elevadas
- Aclarar las fachadas de Grass a `#407850` y las de Mountain a `#3b3c41`.
- Mantener sobre cada pared un gradiente negro opaco en la base que se desvanece hasta transparente arriba, sin afectar las tapas.
- Compartir color y gradiente entre el tablero, el preview de expansión y las miniaturas.
- Resultado: código/documentación integrados; aceptación visual pendiente. Ver [ADR-0121](DECISION_HISTORY.md#adr-0121).

<a id='acceptance'></a>
## Criterios de aceptación y revisión manual

> **Vigencia M61:** cualquier criterio histórico de M7–M13 que pida abrir o conservar el panel F3 quedó sustituido. El juego ya no contiene ese panel ni un selector runtime de oleadas DEBUG; usa el apartado M61 para la aceptación vigente de HUD y controles de terreno.

### Grid
- Rotar un HexCoord 6 veces devuelve la posición original.
- Cada celda tiene exactamente 6 vecinos potenciales.
- Distancia A->B == B->A.

### TerrainPiece
- Toda plantilla cargada contiene 7 celdas únicas, conectadas, con pivote `(0,0)`.
- Se cargan las cinco plantillas originales M3 (`straight`, `gentle_turn`, `hard_turn`, `fork`, `convergence`) y las diez piezas añadidas en M18; el catálogo suma 15 piezas.
- No se puede confirmar una pieza que solape celdas existentes o no toque el tablero por un borde.
- Rotar 6 veces devuelve la pieza original.
- Path edges y sockets laterales flexibles rotan junto a la geometría.
- Las conexiones internas requieren `path_edges` recíprocos; en el borde entre piezas puede emparejarse un socket explícito con uno flexible o dos sockets flexibles complementarios.
- Un borde explícito sin pareja frente a una celda existente es inválido, una salida flexible puede permanecer abierta, y ninguna salida explícita puede entrar en terreno no PATH.
- La salida externa de una celda PATH abre visualmente los laterales contiguos que también queden fuera de la huella y permite colocar una pieza conectada por cualquiera de esos lados.
- Una pieza expansiva requiere enlazar al menos un PATH existente por un par de sockets compatibles.
- El ghost legal se muestra verde; el ilegal, rojo con el motivo en HUD. Solo la colocación legal confirma.
- Confirmar inserta las siete celdas en el tablero; Cancelar, Esc y clic derecho no alteran el tablero.
- La plantilla inicial admite su socket de salida al exterior sin exigir una conexión entrante.
- La verificación de ruta global spawn-base se realiza con el snapshot M4 de `PathGraph` antes de confirmar una pieza.

### Paths
- Solo se crea arista entre PATH adyacentes si ambos sockets ofrecen caras recíprocas en la unión de máscaras exactas/flexibles.
- Un socket exacto abierto fuera del mapa produce endpoint spawn; una oferta flexible sola no produce endpoint.
- Una salida exacta hacia no-PATH o hacia PATH sin socket complementario invalida el snapshot.
- El tablero de campaña coloca la base en PATH `(-1,0)` y usa el camino recto `(-1,0) → (0,0) → (1,0) → (2,0)`, con salida exterior `(3,0)`; una base ausente invalida el grafo.
- Cada endpoint spawn y cada nodo PATH tiene una ruta a la base; los caminos huérfanos invalidan la colocación candidata.
- Una recta produce ruta válida, bifurcación conserva nodo de grado 3 o mayor y convergencia vuelve a compartir nodos.
- BFS devuelve una ruta mínima por número de enlaces; repetir sobre el mismo estado produce la misma secuencia usando el orden de direcciones como desempate.
- El snapshot activo se reconstruye al iniciar y confirmar. Al mover un ghost legal, se deriva un snapshot candidato independiente para actualizar en vivo la vista previa de spawns; no muta ni sustituye el snapshot activo hasta confirmar.
- No se confirma una pieza que dejaría un endpoint o subred PATH sin ruta a base.
- Cada endpoint spawn alcanzable muestra siempre un portal PNG pulsante en su coordenada exterior, sin texto `SPAWN`; debe coincidir con los lugares de aparición de enemigos.
- `Ctrl+D` alterna el overlay con rutas por spawn y marcador de base; los portales y el flujo de flechas permanecen visibles con el overlay apagado.
- Ningún spawn activo puede iniciar ronda sin ruta a base; `WaveDirector` selecciona únicamente entre rutas válidas según la política configurada en el grupo.
- Smoke M4: siete escenarios automatizados cubren ruta inicial, pareja exacta-flexible, flexible sin endpoint, salida inválida hacia GRASS, socket exacto sin pareja, PATH desconectado y bifurcación/convergencia con BFS determinista.

### Elevation
- Path = 0.
- Grass = 1 o 2; Mountain = 2 o 3.
- Grass se asigna de forma reproducible según seed de run/oferta; Mountain queda en 2. Los valores no cambian entre card, ghost y tablero confirmado.
- Una torre de altura h recibe +h de daño base y +0.5 × h de alcance; su insignia numérica aparece únicamente al hacer hover y muestra el bonus de daño.
- La fachada, hover, preview y selección siguen funcionando en desniveles de hasta dos niveles.
- Torre conserva su HexCoord aunque sprite se dibuje elevado.
- Click/selección funciona sobre sprite desplazado.
- Hover sobre una cara superior resalta con un color que distingue PATH, GRASS y MOUNTAIN.
- En el tablero, el HUD superior muestra coordenadas axiales globales `(q,r)`, terreno y altura; al salir del top face se limpia.
- Un cliff no se detecta como cara superior.
- Las caras cliff se dibujan sin avisos de triangulación y conservan el desnivel de cada borde.
- Los hijos del contenedor `Entities` se ordenan por Y.

### Map navigation
- `H` alterna el HUD sin mover ni escalar el mapa.
- Arrastrar con el botón central pannea el tablero y el ghost juntos.
- La rueda acerca/aleja con zoom uniforme y mantiene el punto bajo el cursor.
- El zoom queda acotado entre `0.45×` y `2.5×`.
- `R` centra la cámara sobre las celdas colocadas y restablece zoom `1×`.

### Combat
- La base inicializa Health desde `BaseData`, recibe daño y emite derrota al llegar a 0.
- Enemy acepta `EnemyData` y `PathRoute`, comienza fuera del endpoint y recorre los centros axiales hasta base.
- La muerte de un enemigo detiene su movimiento y lo retira una sola vez.
- La primera oleada genera todos los enemigos configurados y solo termina tras completar los spawns y quedar cero enemigos vivos.
- Cada llegada aplica `EnemyData.base_damage`; si llega un enemigo con `boss_tier > 0`, la run termina inmediatamente aunque reste Health.
- La base comienza con 10/10 HP; Fortification permanente añade hasta +10 HP y las cards Fortification I–III dan +3 HP cada una de forma independiente.
- Durante `COMBAT` no se puede colocar terreno; derrota bloquea la expansión y victoria de la muestra habilita `TERRAIN_EXPANSION`.
- Smoke M5 histórico: su fixture terminaba con 20/50 HP y cero enemigos activos. Esa cifra no describe la vida inicial actual, que es 10 HP.
- Enemy llega a base y causa daño.
- Tower adquiere target y lo daña.
- Armor/health/regen alteran el resultado.
- Status expira correctamente.
- Matar enemigo entrega recompensa una vez.

### M6 Towers

> Se conserva este procedimiento como registro del prototipo `Basic Bolt`. El perfil ahora se llama `Basic Bolt (DEBUG)` y el roster visible vigente está en M9.5; estos pasos ya no son la aceptación manual actual de la interfaz. Sigue las pruebas M9.5/M12A/M13 para comprobar las torres y el HUD activos.

- `Basic Bolt` carga desde `TowerData`; ID, daño, cadencia, alcance, terreno permitido, prioridades y mejoras están configurados en Resource.
- Regla histórica de M6: el prototipo permitía build mode en `TERRAIN_EXPANSION`. ADR-0061 sustituyó ese permiso: el runtime vigente solo permite construir en `ROUND_PREP` y `COMBAT`; también bloquea `RUN_SETUP`, `TERRAIN_EXPANSION`, `CARD_OFFER` y `RUN_DEFEAT`.
- Una torre se coloca en una celda `GRASS` o `MOUNTAIN` construible y libre; PATH, una celda vacía del mapa, terreno no permitido y una celda ocupada se rechazan con explicación en HUD.
- Confirmar construcción marca `HexCell.occupied` y `tower_id`, crea una sola torre en la escena y la selecciona; no cambia el `PathGraph`.
- El preview de construcción aparece en la casilla bajo el cursor: verde si es legal, rojo si no, con el alcance provisional. Al seleccionar una torre, su marcador de alcance coincide con sus estadísticas actuales.
- La UI selecciona cada prioridad: más avanzado, menos avanzado, más Health actual y más Armor. Los empates conservan orden estable por ID de instancia.
- Una torre solo adquiere y ataca enemigos `MOVING` dentro de su alcance durante `COMBAT`; mantiene la cadencia configurada y el daño reduce la Health del objetivo. Fuera de alcance o fuera de combate no ataca.
- La elevación suma el bonus de alcance configurable de TowerData. La elevación no modifica la coordenada ni la ocupación lógica de la torre.
- Mejorar aumenta los stats configurados hasta `max_level`; una mejora posterior se bloquea. En el alcance histórico M6 las mejoras eran gratuitas; el flujo vigente con coste se verifica en la sección M9.
- El placeholder muestra la torre en `Entities` Y-sorted, orientación hacia el objetivo y un flash de ataque; el anillo de alcance se ve al seleccionar.
- El `armor` de `EnemyData` permite ordenar por highest armor. La mitigación plana de M7 es histórica y fue sustituida por las capas consumibles de M12A.
- Smoke M6: `tests/m6_tower_smoke.tscn` comprueba fases, Grass/Mountain, rechazo de PATH/ocupado, ocupación axial, niveles/alcance, elevación, las cuatro prioridades, filtro de rango, cooldown/cadencia, daño hitscan y descarte seguro de una referencia a enemigo eliminado.

#### Prueba manual de M6 en el juego
1. Ejecutar `game/main/main.tscn`; en `ROUND_PREP` pulsar el botón **1 · BOLT** o la tecla `1` para entrar en modo de construcción.
2. Pasar el cursor por el camino `(0,0)`: el HUD debe explicar que solo vale Grass o Mountain y el preview debe marcarlo rojo. Hacer clic no debe ocupar esa casilla.
3. Pasar el cursor por Grass `(1,-1)`: el preview debe ser verde y mostrar el anillo de alcance. Hacer clic; debe aparecer una torre seleccionada y el resumen compacto de nivel/daño/alcance. Intentar construir otra en el mismo hex debe ser rechazado.
4. Elegir prioridades distintas en el selector; la prioridad elegida debe aplicarse a la torre. Usar **Mejorar** dos veces: nivel 3/3, daño 20 y alcance mayor que en nivel 1; el botón queda deshabilitado al máximo.
5. Iniciar la oleada seleccionada. Enemigos dentro del radio deben perder Health al ritmo de la cadencia, la torre debe girar hacia un objetivo y mostrar el flash de ataque. La oleada termina cuando el director no tiene enemigos activos; no se deben crear recompensas ni cobrarse costes todavía.
6. (Opcional) Repetir la colocación en Mountain `(0,1)`: debe aceptar la casilla y el estado/preview debe reflejar su bonus provisional de elevación.

Para dar M6 por aceptado deben pasar todos los bullets de la sección y la prueba manual debe confirmar el feedback visual e interacción. El smoke prueba reglas deterministas; la prueba manual cubre el render y el input de la escena.

### M7 Damage model (histórico, fórmula sustituida por M12A)

M7 registró el primer `DamageService`, los `DamagePacket` y una fórmula plana de Armor/Health. Esa fórmula, las cifras contra `Armored Regenerator`, el inspector F3 y su procedimiento manual ya no describen el juego: M12A define el daño actual por capas, M61 retiró F3 y M64 eliminó la oleada/dummy M7. Se conserva este hito solo como historial; no ejecutar ni usar sus cifras como criterio vigente. Las estructuras compartidas de combate siguen en `DamageService` y se aceptan con los criterios M12A y las rondas activas.

### M8 Status Effects

Las reglas de estados implementadas siguen vigentes: `StatusEffectData` valida payloads; `TowerData.status_effects` configura efectos sin mutar Resources; REFRESH conserva una acumulación y reinicia duración; ADD_STACKS acumula hasta el límite; Slow cambia la velocidad real; Burn/Bleed pasan sus ticks por `DamageService`; muerte o llegada a base limpia efectos y señales. No hay resistencia de estado definida en el diseño. Los valores provisionales viven en los Resources y ADR-0012, no en una oleada de test.

La oleada `m8_status_test` y `status_training_dummy.tres` se retiraron en M64. Para una revisión visual actual, usar un enemigo de campaña y el perfil Status Probe accesible con `0`; comprobar iconos, acumulaciones, movimiento y ticks sin asumir la composición ni los valores del dummy retirado. La aceptación automatizada de reglas internas debe usar los smokes existentes o una futura prueba que instancie Resources activos, no recrear una opción de selector DEBUG.

### M9 Economy + Mana
- Fixture histórico de M9: su perfil de prueba inicia con 150 Gold, 100/100 Mana y regen interna de 1.5/s. La economía de campaña vigente empieza con 1.000 Gold y Starting Coffers puede elevarlo a 2.000; véase M35. El tooltip del Mana expresa tasas como equivalencias enteras sin alterar el valor runtime.
- El Gold de construcción es runtime de esta run y no altera `MetaProgression.meta_currency` (XP de perfil) ni se persiste.
- Los siete perfiles principales y sus costes aparecen en la barra según sus Resources: Ballista 10, Mortar 200, Tesla Coil 200, Frost Keep 250, Flame Thrower 300, Poison Sprayer 300 y Shredder 500 Gold, antes de incrementos por cantidad y mejoras de run. Los atajos `8`, `9` y `0` mantienen Armor Piercing Bolt/Sapping Bolt/Status Probe a 40 Gold; Sapping Bolt indica 4 Mana por ataque.
- Una construcción legal cobra una sola vez antes de ocupar la celda. Terreno inválido, casilla ocupada o saldo insuficiente no cobran ni crean torre/ocupación.
- Una mejora cobra `TowerData.get_upgrade_cost(nivel_actual)`: en los fixtures M9, nivel 1→2 cuesta 20 Gold y nivel 2→3 cuesta 35. El nivel/stats aumentan una sola vez; tope o fondos insuficientes dejan nivel y saldo intactos.
- Cada enemigo derrotado paga una sola vez el `EnemyData.kill_reward`, también si la muerte procede de DoT. Un enemigo que llega a base no paga recompensa de baja. Repetir callbacks no duplica el pago.
- La recompensa de `WaveData.round_reward` solo se paga una vez cuando acabaron los spawns y no queda enemigo activo. Si una baja ya pagó y luego la oleada falla, esa recompensa por baja se conserva, pero no se concede el bonus de limpieza.
- Una torre con `mana_cost_per_attack` descuenta Mana antes de cada impacto; con saldo insuficiente no ejecuta daño/status, no genera saldo negativo y muestra el estado sin Mana en Tower Info. Una torre sin coste de Mana no consulta ni consume el saldo.
- El Mana regenera en preparación, combate, recompensa y expansión; no supera `maximum_mana` y se detiene en setup/derrota/victoria. No existe una fuente de Mana de Support Building.
- Al terminar una ronda de campaña, `RunManager` entra a `ROUND_REWARD` durante 0.8 s: no se puede iniciar otra oleada, comprar ni colocar terreno. Después pasa a `TERRAIN_EXPANSION` y ofrece tres piezas; torre/construcción, cofres e inicio de ronda siguen bloqueados durante la oferta y colocación. Al confirmar una pieza válida, pasa a `ROUND_PREP` y se habilita la construcción para la siguiente ronda.
- Los costes, recompensas y tasas actuales son fixtures configurables y provisionales, no balance confirmado.

#### Prueba manual de M9 en el juego
1. Iniciar una run desde el menú. Registrar Gold y Mana iniciales desde la configuración activa; no esperar el valor de fixture histórico M9 (150/100) ni una oleada de test. El tooltip de Mana debe reflejar la tasa configurada y la barra de torres debe mostrar solo el roster reclutado.
2. Construir Ballista en una casilla legal. El coste visible y el saldo deben diferir por el precio configurado del Resource; la celda se ocupa y aparece una única torre. Mejorarla: cada compra cobra una vez y actualiza nivel/stats según el Resource; tope o fondos insuficientes no cobran. Una casilla inválida tampoco cobra.
3. Completar una ronda activa. Cada baja paga su `kill_reward` como máximo una vez y la limpieza paga el `round_reward` solo cuando no quedan spawns/enemigos; comparar el saldo con el aviso y la composición real de `WaveData`, sin usar cantidades de un fixture antiguo.
4. Con una torre que tenga coste de Mana y esté disponible en la run, comprobar que cada ataque descuenta el coste del Resource y que, al no alcanzar el saldo, no ejecuta daño/estados ni permite saldo negativo. Tower Info debe mostrar «sin Mana»; una torre sin coste no consume Mana.
5. Observar la regeneración en las fases donde está permitida: no supera el máximo efectivo, se detiene en setup/derrota/victoria y reanuda según las reglas de la fase. La ronda entra en `ROUND_REWARD` durante 0,8 s, bloquea acciones y después ofrece expansión.
6. Repetir con rondas de campaña y comprobar que una llegada a base no paga recompensa de baja; una ronda fallida no concede bonus de limpieza, aunque conserva bajas ya recompensadas. La campaña no se reinicia ni avanza por usar los perfiles de torre de diagnóstico `8`, `9` y `0`.

Para dar M9 por aceptado deben pasar todos los criterios de la sección y la prueba manual debe confirmar saldos y mensajes en pantalla, cobros atómicos, pago único por evento, rechazo sin fondos, bloqueo de disparos sin Mana y regeneración acotada. La prueba debe incluir una llegada a base para verificar que no se confunde con una baja; el bonus de ronda se comprueba aparte. El smoke/validación automática de gameplay queda pendiente; la prueba descrita es interactiva.

### Roster jugable M9.5
> Estos criterios de acceso describen la etapa anterior al reclutamiento de M35. El combate de cada perfil sigue siendo comprobable al reclutarlo; en una run normal solo Ballista está disponible al comenzar. Ver M35.
- La barra principal muestra los siete perfiles en orden. Los valores iniciales de coste/ataque/H/A/S se validan ahora en M12A; M9.5 conserva el requisito de acceso por botón/tecla y terreno legal, pero los precios históricos 30/80/70/50/65/65/100 ya no aplican.
- Los atajos `1–7` seleccionan el mismo perfil que el botón y permiten construir solo en Grass/Mountain libre. PATH, terreno ocupado o saldo insuficiente no cobran ni crean torre. Cada una de las siete formas placeholder debe distinguirse en el mapa.
- Ballista solo daña el objetivo elegido. Mortar lanza un proyectil y afecta a enemigos agrupados dentro de su radio al aterrizar; los copos de Frost pueden fallar y cada contacto daña a un único enemigo y añade Slow proporcional al daño aplicado.
- Tesla descarga sobre todos los enemigos válidos dentro del alcance circular, gasta 5 Mana por ataque y no daña/aplica estado si el saldo no alcanza.
- Flame daña a los enemigos del cono frontal y aplica Burn; Poison hace lo mismo con su tag Poison y aplica el estado Poison. El aro verde Poison aparece y los ticks pasan por `DamageService` y `EnemyData.poison_damage_multiplier`.
- Shredder lanza la hoja desde la torre hasta la posición actual del objetivo, luego avanza por sus waypoints restantes hacia la base. Cada enemigo en el recorrido recibe un impacto como máximo; cada impacto posterior pierde 1 de daño base. Cada contacto hace daño directo y añade Bleed por el 100% del daño base restante de la hoja; prueba la interacción con H/A/S en el fixture M12A.
- Las torres con Mana gastan el coste indicado por disparo; al quedar sin saldo esperan y vuelven a atacar al regenerar. Las torres sin coste no lo consumen.
- Los perfiles de diagnóstico siguen disponibles en `8` (Armor Piercing Bolt), `9` (Sapping Bolt) y `0` (Status Probe); no ocupan botones del roster reclutable ni tienen oleadas DEBUG asociadas desde M64.
- Daño, costes, RPM, radios, cono, multiplicadores y efectos restantes son configurables. Las cifras compartidas se validan en M12A; la capa Shield ya forma parte del modelo.

#### Prueba manual M9.5 en el juego
1. Iniciar una run desde el menú. La disponibilidad de los siete botones/atajos es histórica y está reemplazada por el roster de run descrito en M35; tras reclutar una torre, probar su botón/atajo y revisar rol, coste, patrón y coste de Mana.
2. Reiniciar la escena entre perfiles para recuperar el Gold inicial. Construir cada torre cerca del camino y verificar el coste que muestre el botón, el color y la silueta. La tabla de costes ya no es la antigua configuración M9.
3. Ejecutar una ronda de campaña adecuada para observar ataques contra uno o varios objetivos. Ballista debe seguirlo; Mortar debe mostrar su impacto; Tesla debe alcanzarlo dentro de su alcance circular; los copos Frost deben caer sobre PATH y ralentizar solo al enemigo que toquen. Para confirmar impactos de área y cadenas sobre varios objetivos, usar la Ronda 07 (22 enemigos directos) u otra composición activa equivalente.
4. Probar Flame y Poison sobre enemigos alineados delante de la torre. El cono solo aplica estado a enemigos dentro del ángulo y rango; verificar aros Burn naranja y Poison verde, y que el HP cae por ticks equivalentes al 100% del daño base por aplicación. En Poison, el diagnóstico debe identificar `veneno`, no `arcano`.
5. Construir Shredder (`7`) cerca de una ruta de campaña con varios objetivos. Iniciar la ronda: la hoja debe llegar a la posición actual del objetivo y seguir sus waypoints restantes. Cada contacto aplica daño directo y Bleed por el 100% del daño base restante; cada impacto posterior pierde 1 de daño base. En M12A se desglosan las capas de daño.
6. Dejar que las torres Tesla/Frost/Flame/Poison gasten su Mana. Cuando falte, confirmar que se bloquean sin infligir impacto ni aplicar nuevos estados; esperar regeneración y confirmar que reanudan fuego. Ballista, Mortar y Shredder no deben gastar Mana.
7. Si están disponibles, usar `8`, `9` y `0` para comprobar que los perfiles de diagnóstico siguen seleccionables y funcionales sin aparecer como parte del roster reclutable. No existe un selector de oleadas de diagnóstico.

M9.5 queda aceptado cuando pasan todos los criterios y se observa cada perfil en la ventana del juego. La implementación está en código; la revisión visual/interactiva todavía está pendiente. Registrar cualquier ajuste de balance como provisional.

### M10 Campaña de 45 rondas

- Una run normal comienza en Ronda 01/45. El selector habilita solo la ronda actual, y limpiar la 45 produce RUN_VICTORY con 45/45.
- WaveCampaignData valida las 45 entradas consecutivas y exactamente 1.093 enemigos directos. Contrastar cada grupo y su orden con CONTENT_AND_ASSETS.md#campaign; cada WaveData debe contener los mismos tipos y cantidades.
- WaveEnemyGroupData.count cuenta unidades directas. Con una y varias salidas alcanzables, los enemigos se asignan round-robin y el total por grupo no cambia. Los spawns pendientes y enemigos activos se muestran por separado.
- La oleada solo se limpia si acabaron todos los grupos y no quedan enemigos vivos. Las invocaciones cuentan como adicionales; no se incluyen en el total 1.093. Transformar un enemigo mantiene la instancia, no paga una baja intermedia y no reduce el contador; la recompensa final se paga una vez tras derrotar la forma final.
- La expansión de terreno aparece tras las rondas 1–44, nunca tras la ronda 45. Mantiene la oferta de tres piezas, preview del grafo, colocación conectada y cierre de huecos interiores. Si la ronda está configurada para una carta M11, el orden es expansión, carta y preparación de la siguiente ronda.
- Las rondas 17 y 19 muestran el encuentro `Boss` por la presencia de Ooogie. Cyclops y Werewolf no tienen designación especial de Miniboss y conservan sus perfiles normales cuando aparecen en la tabla.
- Ooogie von Ooogovich (Haunted) invoca dos Bats cada 2 s y, al agotarse Health, reaparece como Bat con 2.500 Health. Mantiene la recompensa asociada a la instancia hasta derrotar la fase final.
- Comprobar las habilidades de EnemyAbilityData activadas por aparición, cerca de base, agotamiento de Armor/Shield, muerte y temporizador. Las reglas de radio son 5 hexágonos desde la base y 2 hexágonos para auras. Haste aumenta velocidad según fuerza, Fortification reduce 5 del daño base recibido por golpe, ambas alcanzan 60 puntos y decaen 6 puntos/s. Revisar también teletransporte, invocaciones y transformaciones de los perfiles que los declaran en CONTENT_AND_ASSETS.md#content-roster.
- Confirmar que todos los 26 perfiles de campaña tienen PNG transparente visible. Sus sprites miran a la derecha cuando el recorrido avanza hacia la derecha y quedan reflejados horizontalmente al navegar a la izquierda.
- Confirmar el perfil Frost: daño base 6, 180 RPM más 18 por PATH cubierto, Slow de 50% del daño aplicado con cap 60 y decaimiento 6/s, y 2 Mana/s durante combate. Confirmar que los copos no causan daño ni Slow si no hay contacto. Tesla Coil inicia con daño 9; las mejoras de carta pueden cambiar el resultado runtime y los Resources compartidos no deben mutarse.
- Los perfiles de torre de diagnóstico `8`, `9` y `0` no permiten elegir/repetir oleadas ni alteran el orden secuencial de la campaña.
- Verificar victoria al limpiar ronda 45; después se deshabilitan inicio, selector, construcción/mejora y colocación. Las recompensas de limpieza de las rondas 21–45 son provisionales según ADR-0037.

#### Prueba manual M10 en el juego

1. Iniciar una run nueva y confirmar Ronda 01/45, el tablero inicial de 19 celdas, base en `(-1,0)` y camino recto por `(-1,0) → (0,0) → (1,0) → (2,0)` hasta la salida `(3,0)`. Confirmar cuatro celdas PATH en cada ruta y mantener la inspección previa de orientación, terreno y preview.
2. En cada oleada muestreada, comparar los grupos visibles/activos con la tabla de la ronda. Verificar que dos o más endpoints no multipliquen la cantidad anunciada y que la distribución alterne rutas.
3. En una oleada con grupos espaciados, comprobar que pendientes llega a cero antes de que la ronda termine si aún hay enemigos vivos. Probar también muerte/llegada a base mientras quedan grupos pendientes.
4. Completar varias rondas y expansiones, incluyendo una ronda con oferta M11. Verificar bloqueo de acciones entre fases y orden expansión→carta→siguiente ronda.
5. En cada oferta, comprobar que una card está marcada `EXTIENDE RUTA` y que su ghost empieza en una posición/rotación legales guardadas. La pieza sugerida debe variar entre recta, curva y bifurcación; cuando la elegida no sea recta, las otras cards no deben introducir una recta. Confirma que conecta con una ruta existente, aumenta su longitud y deja otra opción legal para la expansión siguiente. Para las otras cards, mueve y gira el ghost hasta una posición que bloquearía toda futura prolongación: debe verse inválido, explicar el motivo y no permitir confirmar.
6. Elige una pieza con obstáculos visibles y compara la miniatura, el ghost durante el movimiento/rotación y el tablero tras confirmar: cada obstáculo debe quedar en el mismo hex. La miniatura y el ghost no muestran cofres; el contenido de obstáculos de la oferta se conserva al volver a ella.
7. Previsualiza una posición que cierre uno o más spawns. Los portales afectados deben quedarse visibles en su ubicación y mostrar una X roja; el texto debe indicar claramente cuántos se cerrarían. Al cancelar, los portales activos recuperan su estado normal. No debe ser posible confirmar una posición que deje cero opciones legales para alargar la ruta.
7. En la ronda 24, observar el jefe Ooogie von Ooogovich, las invocaciones, la transición a Bat y la espera del contador/recompensa hasta la derrota final.
8. Inspeccionar al menos un enemigo que mira a cada lado del eje horizontal. El sprite debe voltearse solo al moverse hacia la izquierda y volver a su orientación original hacia la derecha.
9. Abrir el inspector técnico y seleccionar Frost Keep y Tesla Coil. Comparar daño, RPM, Slow y duración con el perfil documentado; comprobar que sus modificadores runtime se reflejan sin cambiar los Resources.
10. Repetir una prueba de expansión desde preparación. La oferta/campaña conserva su estado al cancelar y reabrir la colocación según las reglas actuales.
11. Completar la ronda 45 y confirmar 45/45, RUN_VICTORY, una sola recompensa de limpieza, sin expansión posterior y sin acciones de combate/construcción disponibles.

La implementación de campaña, recursos, perfiles, habilidades y sprites está integrada. El arranque headless se comprobó en esta revisión; la aceptación completa de gameplay/arte requiere completar los pasos interactivos anteriores en la ventana del juego.


### M11 Cartas de mejora
- Después de colocar una expansión de las rondas 1 y 2, la fase pasa directamente a `ROUND_PREP`; no aparece una carta de mejora fuera del calendario.
- Después de colocar la expansión de cada ronda múltiplo de tres entre 3 y 42, `RunManager` entra a `CARD_OFFER` antes de `ROUND_PREP`. La oferta muestra exactamente tres cartas distintas, con título, rareza y efecto descrito; el panel solo deja seleccionar esos tres botones. Si hay torres elegibles sin reclutar, siempre hay al menos una carta de reclutamiento y nunca más de dos; los otros espacios se sortean por peso entre cartas elegibles. Las cartas no elegidas siguen disponibles en ofertas futuras. Tras la 45 no hay carta porque la run termina.
- Hasta elegir una carta se mantienen bloqueados inicio de ronda, construcción, mejora y colocación. `Esc`/clic derecho no descartan ni saltan la elección. Tras seleccionar una, se aplican sus efectos y se habilita una sola vez la siguiente ronda.
- Las definiciones viven en Resources. Seleccionar una carta no cambia ningún `TowerData`, `StatusEffectData`, economía de arranque ni archivo `.tres` compartido. Las cartas específicas de torre requieren unlock permanente y reclutamiento durante la run; las cartas de reclutamiento aparecen para torres desbloqueadas que aún no están en el roster. Las cartas globales no requieren unlock.
- Las 173 entradas compatibles de referencia y las 18 cartas propias se representan con 190 IDs únicos: 172 Resources nuevos y la Advanced Circuits propia, que ya ejecuta el mismo efecto. Sus familias incluyen daño plano/multiplicador, alcance por elevación, área, Mana, estados/caps/sinergias, críticos, H/A/S, economía y base. Las cartas de torre se filtran por unlock permanente, roster reclutado y prerequisitos; los efectos elegidos afectan también a torres construidas previamente, no mutan Resources compartidos y no alteran RPM fijo; Frost Keep solo gana RPM por cobertura PATH.
- Las ofertas futuras excluyen cartas que llegaron a `max_per_run`; las no elegidas siguen disponibles. Una escena/run nueva reinicia las selecciones. Los efectos no persisten entre runs (la persistencia y unlocks guardados son M12).
- La frecuencia cada tres rondas está confirmada por ADR-0062. Números, rarezas y tamaño base siguen configurables/provisionales y no se presentan como balance aprobado de Rogue Tower.

#### Prueba manual M11 en el juego
1. Ejecutar `game/main/main.tscn` y jugar la campaña normal. Limpiar y expandir las rondas 1 y 2: tras cada colocación debe comenzar la preparación siguiente sin aparecer panel de mejoras.
2. Antes de completar la ronda 3, construir Ballista en Grass y anotar el daño mostrado en su resumen. Completar la ronda y colocar una pieza de terreno válida. Ahora, antes de que se habilite ronda 4, debe aparecer `CARD_OFFER` con tres cartas. Verificar títulos, descripciones/efectos, rarezas y botones; no se puede iniciar ni construir mientras está abierta. El panel dispone de seis ranuras, pero muestra tres por defecto: la oferta no debe descartarse por no llenar todas las ranuras. Si Mortar y Tesla Coil siguen desbloqueadas y sin reclutar, debe mostrarse al menos una de ellas, no ambas son obligatorias y no pueden ocupar las tres opciones. `Esc` no debe saltarse la elección.
3. Si aparece **Disparo calibrado**, seleccionarlo: la expansión ya está colocada, el panel desaparece y se habilita la ronda 4; al seleccionar la Ballista ya construida, su resumen debe mostrar 2 de daño adicional. Si no aparece esa carta, repetir la run; no hace falta editar recursos.
4. En runs sucesivas, elegir **Depósito de Mana** y comprobar que la capacidad HUD sube 20 sin llenar instantáneamente el saldo; **Flujo constante** aumenta la regeneración 0,5/s; **Circuitos eficientes** reduce el coste por ataque en un 15 %. Para una mejora de estado, seleccionar la carta del estado/torre correspondiente y usar el fixture M8 para comprobar su mayor duración. Alcance y área deben reflejar el stat correspondiente en preview/resumen y comportamiento de ataque. Comprobar en otras ofertas las tres cartas de multiplicador H/A/S descritas abajo.
5. Alcanzar la siguiente oferta (ronda 6). La carta elegida antes no puede aparecer de nuevo con el máximo actual de una copia; las opciones no elegidas sí pueden volver a aparecer. Comprobar el mismo flujo al menos en rondas 9 y 42, y confirmar que tras completar la 45 se abre la tienda sin una oferta temporal adicional. Una run nueva quita efectos y reinicia el límite por run.

M11 queda aceptado cuando se verifican la frecuencia confirmada y el orden expansión→carta→siguiente ronda, bloqueo hasta selección, exactamente tres botones visibles y seleccionables, filtro de unlocks/prerrequisitos/límites y al menos un efecto de cada familia afectada (incluidos estados, Gold, Mana, base y H/A/S), sin mutar recursos compartidos. El ID legado Card Draw no aparece en la tienda ni cambia la oferta. La distribución M66 tiene criterios propios al final de esta página.

### M12 Meta-progresión
> Los criterios de barra con las tres torres simultáneas y la tienda terminal por pestañas son históricos. M35 define el roster por run, el menú separado y el mapa permanente de nodos; conserva de esta sección la persistencia, XP y economía meta.
- Una nueva instalación crea `user://rogue_tower_meta.json` con versión 1, 0 XP de perfil y Ballista, Mortar y Tesla Coil desbloqueadas. El XP nunca cambia al construir torres ni se confunde con el Gold de la run.
- Una derrota de campaña y la victoria al limpiar ronda 45 terminan la run, otorgan XP de perfil una sola vez y muestran el resumen con resultado, ronda, recompensa, saldo total y seed. Los perfiles de torre de diagnóstico no añaden oleadas ni interrumpen la secuencia de campaña.
- Con la configuración demo, la recompensa es `5 + 5 × rondas completas`, más 30 por victoria, con tope 1000: perder en la ronda 1 da 5; perder durante la ronda 2 tras completar la 1 da 10; completar las 45 rondas da 260. Progresar más da una recompensa superior que repetir únicamente una derrota en la primera ronda.
- La tienda deja comprar torres y niveles permanentes solo con saldo suficiente. El coste se resta una sola vez; un elemento ya desbloqueado/nivel máximo no se vuelve a cobrar. Si falla el guardado, la compra se revierte.
- Tras comprar una torre, «Empezar nueva run» mantiene el unlock y permite que aparezca como card de reclutamiento; no la añade directamente a la barra. Solo Ballista está disponible al inicio; una torre sin reclutar no se puede construir. Ver M35.
- Comprueba al menos una mejora de cada familia persistente: «Fondo de campaña» da +20 Gold inicial por nivel; «Reserva de Mana» +15 de capacidad por nivel; «Manantial» +0,25 Mana/s por nivel; «Calibración de torres» multiplica daño ×1,05 por nivel. Deben aplicarse a una run nueva, sin mutar `.tres` ni sobrevivir los modificadores M11 de la run anterior.
- Comprar «Archivo de cartas» añade al pool dos cartas globales identificadas por `meta:card_archive`; sin la compra no aparecen, y la compra debe persistir tras cerrar y volver a abrir el juego.
- `SaveData` contiene solo primitivas, versión y progreso estable. Un archivo corrupto o con versión distinta no se sobrescribe automáticamente; se muestra el error y se deshabilitan compras, conservando el archivo para recuperación. Los guardados normales conservan una copia `.bak` antes de reemplazarse.

#### Prueba manual M12 en el juego
1. En el menú, inicia run con un guardado nuevo. Comprueba que solo Ballista aparece construible; Mortar y Tesla Coil son desbloqueos permanentes iniciales, se reclutan con las cards de la primera oferta programada y pasan a la barra tras elegirlas. M35 reemplaza los demás criterios de UI de esta etapa.
2. Para comprobar el mínimo de 5 XP en derrota de ronda 1, cambia temporalmente `max_health` a 1 en `data/base/base_data.tres` dentro de una copia de trabajo. La ronda inicial contiene un enemigo con 1 de daño a base; déjalo pasar y confirma que el resumen indica derrota en ronda `1/45`, `+5 XP de perfil`, saldo total 5 y seed. Restaura `max_health = 10` al terminar esta comprobación.
3. Para comprobar la recompensa de derrota tras completar una ronda, cambia temporalmente `max_health` a 5 en la misma copia, inicia una nueva run y deja pasar los enemigos de las rondas 1 y 2: la ronda 1 tiene uno y la ronda 2 cuatro, cada uno con 1 de daño a base. La base debe caer durante la ronda 2 y el resumen otorgar 10 (5 base + 5 por una ronda completa), dejando 15 en total. Restaura `max_health = 10` al acabar.
4. Con al menos 50 XP, compra Frost Keep en la tienda y pulsa iniciar run. Frost Keep queda habilitada para aparecer como card de reclutamiento, pero solo entra en la barra tras elegir esa card; el XP conserva el coste descontado al reiniciar. Las torres bloqueadas permanentemente no se ofrecen.
5. Compra un nivel de Treasury y una mejora disponible de cada familia: Mana Capacity, Sourcery, daño, Gold por baja, salud/reparación de base y H/A/S de torre cuando estén desbloqueadas. Desde la nueva run compara Gold/Mana, daño y stats afectados; la oferta sigue mostrando tres opciones. `card_draw` no aparece en la tienda y se conserva únicamente como ID legado. El Archivo de cartas habilita «Filos bruñidos» y «Canalización» en una futura oferta; sin comprarlo siguen filtradas.
6. Verifica saldo insuficiente y máximos: la tienda no cobra, no aumenta niveles ni desbloquea contenido. Abre F3 para iniciar una run de diagnóstico y confirma que completarla no aumenta el contador/recompensa meta ni altera el número de campaña.
7. Para probar migración, conserva una copia externa del JSON y, en una copia de trabajo, cambia solo `version` a `0` o elimínalo. El juego debe cargar los campos reconocidos, reescribir versión 1 y conservar el formato anterior en `.bak`; un valor JSON como `1.0` también debe cargar sin bloqueo. Como ruta de error, prueba JSON inválido o `version: 999`: el juego debe iniciar en fallback sin sobrescribir el archivo incompatible, mostrar la explicación y bloquear compras hasta recuperar un guardado válido.
8. Completa la ronda 45 en una run de aceptación: el resultado es victoria, el bonus se aplica una sola vez y la recompensa configurada es 260. La tienda muestra las 30 mejoras comprables; el catálogo conserva el ID legado Card Draw, que no aparece como nodo. Las ramas de torres bloqueadas no se pueden comprar hasta desbloquear la torre. Volver a pulsar o duplicar el evento de final no vuelve a sumar recompensas.

M12 queda aceptado al comprobar las dos salidas de run, fórmula creciente, aislamiento DEBUG, compras transaccionales, unlocks consumidos por gameplay/cartas, upgrades efectivos en runs posteriores y persistencia/error seguro después de reiniciar. La jerarquía visual de interfaz se valida por separado en M13. Costes/valores siguen siendo provisionales.

### M12A Reglas de torres y capas de Health

- El modelo de cada enemigo contiene Health, Armor y Shield; el perfil configura los tres máximos y cero desactiva una capa para esa unidad. Los perfiles de campaña con varias capas muestran sus filas visibles. Los valores se consumen Shield→Armor→Health; la barra conserva los colores Shield azul, Armor beige, Health verde y actualiza sus segmentos al recibir daño/curación. La oleada/dummy de entrenamiento con valores fijos se retiró en M64.
- El perfil Ballista inicial muestra 10 de daño, H/A/S 10/5/5, rango 5, 20 RPM, sin Mana y precio 10. Comparar los otros seis Resources contra la tabla de `CONTENT_AND_ASSETS.md#initial-content`: Mortar 20/10-15-5/10/10/200(+75); Tesla 9/6-3-10/2/30/5/ataque/200(+75); Frost 6/10-5-5/2/180 iniciales/2 Mana/s/250(+100); Flame 6/6-9-3/4/60/1/ataque/300(+75); Poison 5/6-3-9/4/60/1/ataque/300(+75); Shredder 10/20-10-10/5/5/0/500(+100). Desbloquearlos en tienda meta antes de probarlos. Costes de upgrade provisionales por perfil: Ballista/Mortar 10(+10), Tesla/Frost 20(+20), Flame/Poison/Shredder 30(+30), en línea con las páginas comunitarias consultadas.
- Seleccionar una torre muestra daño, H/A/S, alcance, RPM, crítico, XP H/A/S y Mana. Una elevación de terreno suma +1 al daño base y +0.5 de alcance por nivel. El Frost suma 18 RPM por cada PATH cubierto por el rango cuadrado; los otros perfiles no cambian su RPM.
- El precio de la primera Ballista es 10, segunda 25, tercera 40; demoler devuelve el precio marginal del slot ocupado según M27/ADR-0064 y reduce el siguiente coste; el nivel de la torre no altera la devolución. Intentar comprar o mejorar sin fondos no cobra ni muta la torre.
- Las prioridades se aplican en orden y se revelan con `+`; cada opción secundaria solo desempata la anterior. Repetir una misma opción muestra rechazo/restaura el selector. Validar progreso, menor HP de capa activa, máximo/mínimo H/A/S y velocidad.
- Una mejora manual cobra el coste del siguiente nivel, añade +1 al daño base y +1 a la capa elegida (botones `+ Health`, `+ Armor`, `+ Shield`). El nivel máximo bloquea los tres botones. Para una comprobación rápida de XP, duplicar un `TowerData` local, poner `targeting_xp_required_per_level = 1`, sostener un enemigo en rango y comprobar que gana +1 daño base y +1 a la capa activa; no modificar los Resources versionados del perfil definitivo. Restaurar la copia después.
- Críticos empiezan en 0%. Al conseguir una oferta de carta, `Impulso crítico global` suma 15 puntos porcentuales globales y `Advanced Circuits` 15 a Tesla. `Foco de Health`, `Foco de Armor` y `Foco de Shield` suman +1 al multiplicador de esa capa para todas las torres. El resumen debe reflejar los críticos y los tres modificadores H/A/S. Las tiradas muestran de manera aleatoria ×2/×3/×4 según bandas de chance; si no sale la carta, repetir oferta/run.
- Ballista mueve un proyectil hasta su objetivo. Mortar lanza un shell y al aterrizar daña todo enemigo en el radio, sin depender de estar agrupados al disparar. Tesla descarga sobre todos los enemigos en su alcance circular; Frost deja caer copos sobre PATH dentro de una zona cuadrada, cada copo daña a un único enemigo al contacto y aplica Slow igual al 50% del daño; Flame y Poison afectan solo al cono frontal, aplican 100% del daño base como Burn/Poison y sus ticks pasan por `DamageService`; Shredder pega directamente, aplica Bleed por el 100% del daño base restante y pierde 1 de daño base en cada enemigo atravesado.
- Comprobar la transición de capa con un perfil de campaña con Shield y Armor: Ballista debe consumir primero Shield, luego Armor y finalmente Health. Verificar en `EnemyData` los máximos/regeneraciones configurados y confirmar que el combate no muta el Resource compartido. Con Bleed/Burn/Poison activos, comprobar la supresión de regeneración de Health/Armor/Shield, respectivamente. Un ataque directo recibe +1 una sola vez al multiplicador de la capa asociada al estado; el tick no recibe ese bonus y usa su daño por capa configurado (100% en la asociada, 50% en las otras).
- Los antiguos test DEBUG no están disponibles desde M64; no hay que seleccionar ni preservar oleadas de entrenamiento. Los perfiles de torre `8`, `9` y `0` siguen siendo atajos de diagnóstico sin selector de oleada.

#### Prueba manual M12A en el juego

1. Ejecutar `game/main/main.tscn`, desbloquear varios perfiles en la tienda al disponer de XP de perfil y construir una Ballista. Seleccionarla y comparar su resumen con el perfil actual; debe indicar 20 RPM. Durante combate, medir el tiempo entre dos disparos consecutivos de la Ballista con el mismo objetivo continuamente en rango: debe ser 3 s (20 disparos/minuto); medir el flash o evento de lanzamiento, porque el proyectil viaja después del disparo. Usar `1–7` después de desbloquear las otras torres para confirmar las siete filas de stats.
   - En la ronda 1, sin mejoras, crítico ni elevación, confirma que un proyectil de Ballista elimina al Goblin: 10 de daño base × 10 al Health = 100 contra sus 100 Health. Si el objetivo tiene Armor o Shield, el impacto debe afectar primero esa capa y respetar el multiplicador de la Ballista para ella.
2. Construir tres Ballistas (precios 10/25/40), seleccionar una y pulsar `Demoler`. Comprueba que devuelve el precio marginal del slot y que el precio visible de la próxima Ballista baja al conteo restante, según M27/ADR-0064.
3. Seleccionar la Ballista restante y comprar la mejora `Shield`. Debe cobrar el coste de Shield, subir solo Shield en 1 y añadir +1 al daño base y +1 al multiplicador Shield. Health y Armor conservan su nivel y XP. Comprar después Health y confirmar que Shield no cambia. Las barras muestran progreso/XP propios y los costes usan el nivel de su propia capa.
4. Iniciar una ronda activa que incluya un enemigo de campaña con varias capas. Comprobar que las filas azul/beige/verde aparecen solo para las capas existentes y caen en el orden Shield→Armor→Health; comparar máximos y regeneración con su `EnemyData`. No editar Resources compartidos para esta prueba.
5. Construir un Frost Keep y colocar/enlazar celdas PATH adicionales dentro del cuadrado de alcance; su RPM del resumen debe crecer en 18 por cada PATH adicional y los copos deben caer sobre celdas PATH de ese cuadrado. Las demás torres mantienen RPM base aunque se amplíe el mapa.
6. Probar las prioridades ordenadas con varios enemigos y empates: abrir Prioridad 2 y 3 con `+`; la segunda solo resuelve el empate de la primera y la tercera el empate restante. No se permiten criterios duplicados; elegir una prioridad ya usada debe intercambiar su posición con el criterio desplazado.
7. Comprobar los proyectiles Ballista/Mortar, la explosión AoE del Mortar, el impacto de Tesla sobre todos los enemigos en alcance, los efectos de cono y ticks al 100% de Flame/Poison, Slow Frost solo por contacto y Shredder directo+Bleed/perforación. Verificar que sin Mana Frost no lanza copos y que su drenaje sea 2/s durante combate; Tesla/Flame/Poison esperan su siguiente ataque; Ballista/Mortar/Shredder no consumen.
8. Alcanzar ofertas M11 y seleccionar, en runs sucesivas, `Foco de Health`, `Foco de Armor` y `Foco de Shield`; comprobar que el multiplicador correspondiente aumenta en todas las torres existentes y construidas después. Obtener también `Impulso crítico global` o `Advanced Circuits`, confirmar el crítico en stats y observar impactos con multiplicador variable. Cada carta puede requerir otra run por su peso de oferta.

M12A queda aceptado cuando barra/daño por capas, stats de los siete perfiles, precio incremental/demolición, los dos caminos de upgrade, prioridades ordenadas, crítico, comportamiento diferencial y counters de regeneración pasan en ventana Godot. La progresión individual detallada en M20 tiene su propio criterio manual. La implementación de código está documentada; todavía no se ha ejecutado este procedimiento ni se ha hecho inspección visual.

### M13 UX/UI
> La selección simultánea de siete torres, el timeline fijo de 45 puntos y las pestañas de la tienda terminal son descripciones históricas. La interfaz vigente de acceso, tienda, pausa, resumen y ventana móvil se acepta en M35.

- El HUD activo se actualizó en M22: salud/atajos arriba a la izquierda, Gold/Mana arriba a la derecha, ronda centrada y datos de torre a la derecha debajo de los recursos. Salud y ronda no tienen panel compartido; M55 añade un panel horizontal 9-slice solo a Gold y deja Mana sin panel. El título «RogueTower» no aparece. La salud de Main Tower muestra su valor actual/máximo dentro de una barra segmentada cada 10 puntos, con un segmento final parcial si corresponde. El Gold usa un icono y tamaño visual mayores que el Mana; toda ganancia o gasto anima icono y cifra con escalado y rebote. El Mana se restablece al máximo y se muestra como entero. El timeline de M35 muestra siempre 15 de las 45 rondas, sin selector; el hover de composición y el botón de inicio se conservan.
- No hay selector runtime de oleadas de diagnóstico ni panel técnico F3. `H` oculta y restaura el HUD; la navegación con rueda y botón central continúa funcionando con la interfaz visible/oculta.
- Seleccionar una torre muestra en el panel derecho nivel, daño, H/A/S, alcance, RPM, crítico, patrón, icono de energía si consume y XP por capa. El panel se ajusta al contenido y nunca usa scroll; reduce su escala vertical si el alto del viewport no permite mostrarlo a tamaño natural. Al entrar en build mode presenta el retrato grande de la torre y sus datos; omite la instrucción redundante de elegir Grass/Mountain y muestra el bonus cuantificado de Mountain frente a Grass. Health, Armor y Shield usan negrita y colores distintos. Los tres botones de mejora casi cuadrados enseñan icono, nivel de su capa, barra XP, `+1 Daño`, efecto y precio; Demoler queda debajo. Hover sobre torre no seleccionada muestra el radio y un contorno; al seleccionar, el sprite y card inferior pulsan con brillo alfa, sin círculo y sin pulso del panel. Prioridad 1 aparece sola; botones `+` revelan prioridades únicas 2 y 3. El panel desaparece al deseleccionar la torre o pulsar fuera del tablero.
- Cada objeto tiene su PNG RGBA transparente independiente en `assets/sprites/ui/icons/` (256×256); no existe un atlas compartido. Los atajos inferiores son botones individuales con un asset de marco estilo carta, sprite grande, nombre y precio con icono de moneda; el contenedor que los alinea no muestra fondo ni marco común. El sprite de torre es idéntico al preview y a la torre colocada. La base usa un sprite PNG configurable desde `BaseData`; su tamaño vigente conserva el archivo fuente 270×352 px y lo estira a 1,8 × el radio de huella de ancho por 2,8 × de alto, manteniendo fijo el borde inferior. La huella lógica y la posición Y-sort siguen separadas. No cambian huellas lógicas ni movimiento. La UI sustituye por iconos las menciones a Gold/Mana en textos enriquecidos. Las cards específicas muestran la torre afectada; las cards de terreno conservan el contrato M10.
- Los enemigos muestran un marco de Health con carriles de Shield y Armor sobre una Health fragmentada; los iconos de capa identifican cada carril. Los estados activos aparecen encima y solo muestran cifra cuando hay varias acumulaciones. Cada impacto hace destellar y saltar al enemigo, y presenta daño flotante coloreado según Shield, Armor o Health. El efecto no cambia el cálculo de `DamageService`.
- El resumen de victoria/derrota se presenta en el menú después de cambiar de escena; M35 añade el resumen compacto de cantidad y daño por torre desbloqueada. La seed se conserva como dato técnico.
- La tienda anterior por categorías/filas quedó reemplazada por el mapa de nodos compartido de M35. Sigue mostrando coste/estado y rechaza compras sin saldo o guardado válido.
- A 1440×900, el HUD principal, la barra de torres reclutadas y las ofertas no se recortan ni bloquean la lectura del mapa. El mapa de mejoras se puede recorrer mediante scroll; comprobar encuadre y tooltips en M35.

#### Prueba manual M13 en el juego

1. Arranca en la escena de menú y pulsa iniciar. En una ventana de 1440×900, comprueba la base y la barra de salud segmentada; el HUD no presenta título «RogueTower». La disposición de salud/recursos sigue vigente; el timeline de 45 puntos fue reemplazado por una ventana fija de 15 rondas en M35. El panel derecho empieza oculto. El icono/cifra de Gold destacan sobre Mana y los saldos no muestran decimales.
2. Confirma que el HUD normal no presenta selector de fixtures ni la línea técnica del enemigo. El panel técnico F3 de esta etapa histórica fue retirado en M61. Pulsa `H`, mueve/zoomea el tablero, vuelve a pulsar `H` y comprueba que la interfaz vuelve sin haber cambiado la cámara ni la ronda.
3. Activa build mode para Ballista y para otra torre: el panel derecho debe mostrar un icono grande, coste, stats H/A/S con color y bonus por elevación, sin la frase «selecciona Grass o Mountain». Comprueba que su alto se ajusta a esta información. Construye Ballista en Grass/Mountain con elevaciones diferentes. El botón individual tiene fondo estilo carta y el conjunto no queda dentro de un panel compartido. El botón, el preview del cursor y la torre colocada deben mostrar la misma Ballista ampliada. Pasa el cursor sobre ella: aparece su radio y contorno; selecciónala y comprueba que mantiene su brillo y pulso de sprite/card sin mostrar círculos. Haz clic en una casilla vacía y confirma que el panel desaparece.
4. Selecciona Ballista y una torre reclutada en la barra. Comprueba icono, nombre, precio, disponibilidad por Gold y feedback de construcción. Gasta/recibe Gold y confirma que icono/cifra animan juntos. Gasta Mana antes de una ronda y comprueba que se repone al máximo efectivo al iniciar la siguiente. Verifica hover de rango, selección, prioridades e iconos/capas H/A/S como en la versión anterior de M13.
5. Durante la campaña normal, llega a la ronda 24 y observa Ooogie von Ooogovich con su kit propio. Sobre el enemigo con pools activos debe verse Shield arriba, Armor debajo y Health fragmentada; las barras e iconos deben leerse a simple vista. Observa impactos en cada fase: el enemigo parpadea/salta y los números son cian para Shield, ámbar para Armor y rojo para Health. El valor debe corresponder al daño que realmente aplicó el juego. Las fixtures de daño antiguas ya no se seleccionan en una partida normal.
6. Repite con Status Probe (`0`) o con Frost Keep, Flame Thrower, Poison Sprayer o Shredder sobre una ronda activa. El símbolo PNG de Bleed, Burn, Poison o Slow aparece encima de la barra sin una placa o fondo opaco, a 28×28 px y con transparencia; no debe verse un rectángulo detrás. Para un estado acumulable, aplica al menos dos acumulaciones y comprueba que aparece su cifra; al expirar, icono y cifra desaparecen. Verifica que estado y barra acompañan al enemigo durante su movimiento.
7. Obtén una card específica de una torre durante la run: la card incluye el sprite de esa torre. Elige cartas con descripciones que aumenten o consuman Gold/Mana y confirma que aparecen los iconos en línea; no debe quedar el nombre textual de esas monedas en los elementos enriquecidos.
8. Repite una run hasta derrota dejando llegar enemigos a la base. La tienda debe presentar derrota, ronda, rondas completas, recompensa y saldo meta. Cambia entre TORRES y MEJORAS: solo se ve la lista activa con descripción/coste/estado. Compra una opción asequible y confirma el saldo nuevo; con saldo insuficiente no debe cobrarse. «Empezar nueva run» debe conservar las compras. Completa la campaña hasta 45/45 para revisar la variante de victoria.
9. A 1280×720 y 1440×900, revisa HUD, panel lateral, barra inferior y cards. Los controles deben permanecer legibles; el panel lateral muestra todos sus datos, nunca presenta scroll y se reduce verticalmente si el alto del viewport es insuficiente. La tienda sí debe desplazarse sin bloquear el mapa ni recortar nombres, precios o cifras. Confirma que las ilustraciones de Path/Grass/Mountain coinciden con las caras hexagonales sin corrimiento visible y que torres, enemigos y base conservan sus puntos de anclaje al aumentar de tamaño y desplazarse 6 px hacia abajo.

M13 queda aceptado cuando los nueve puntos anteriores pasan en una ventana Godot y se comprueba que la interfaz guía acciones normales sin requerir DEBUG, mantiene sprites consistentes, segmenta la base cada 10 Health, repone Mana al inicio de cada ronda, anima las variaciones de Gold, comunica estado/capas/daño con iconos y animación, y permite operar prioridades, upgrades y tienda sin ambigüedad. La presentación vigente del HUD y la ausencia del panel F3 se comprueban en M61.

### M14 Terreno, cofres y feedback

#### Prueba manual en el juego

1. Criterio histórico de M14 sustituido por M39. Usa la sección M39 para revisar el pool actual de ocho obstáculos, los 18 props de Path/Grass/Mountain, la escala, la frecuencia y las capas de dibujo.
2. Activa build mode y apunta a obstáculos de varios tipos: el preview debe marcarlos inválidos y no se debe colocar torre. Repite en una celda Grass/Mountain con cofre; la torre tampoco se debe construir hasta abrirlo. Haz clic en el cofre y confirma que desaparece y añade 25 Gold una sola vez, sin alterar la ruta ni la celda axial. Vuelve a hacer clic y confirma que no duplica la recompensa.
3. En la tienda permanente compra «Suerte del explorador» nivel por nivel y comienza otra run para que cambie el porcentaje de cofres. Comprueba que parte del 1 %, sube en pasos de 5 puntos porcentuales y se limita al 20 % tras cuatro niveles; la configuración persiste al reiniciar el juego.
4. Pasa el cursor sobre un cofre sin abrirlo. Debe botar suavemente y mostrar un resplandor dorado mientras siga el hover; al salir, animación y brillo deben detenerse. Al abrirlo, la animación debe terminar sin bloquear la retirada del cofre.
5. Comprueba el VFX al impactar cada torre: Ballista Dust_01, Mortar Explosion_01, Tesla Coil TeslaCoil, Frost Keep Ice_01, Flame Thrower Fire_03, Poison Sprayer Poison y Shredder Blood. Los efectos deben aparecer en la posición de impacto y concluir su animación sin quedarse congelados.
6. Comprueba los cuatro estados del cursor: Cursor_01 normal, Cursor_02 al pasar sobre controles u objetos interactivos, Cursor_03 al apuntar a terreno inválido o una acción deshabilitada, y Cursor_04 mientras se coloca una torre. Confirma que los tres primeros se asignan al puntero del sistema y que al salir del overlay de construcción se restaura el cursor del estado actual.
7. Verifica que el panel lateral de torre no tiene barras de desplazamiento a 1280×720 y 1440×900; debe mostrar todo su contenido y adaptarse a la altura disponible. Revisa que la tienda conserve su scroll cuando una categoría exceda el espacio.

El código y los assets están integrados. M14 requiere ejecutar este procedimiento en ventana y corregir cualquier problema visual/interactivo antes de marcarlo aceptado.

### M17 Oclusión, escala de arte y flujo de rutas

#### Prueba manual en el juego

1. Coloca una torre y un obstáculo en hexes con distintas posiciones Y y mueve enemigos por PATH delante y detrás de ellos. Confirma que el elemento más cercano a la parte frontal del tablero aparece delante, que los props pueden quedar detrás de torres/enemigos y que la base también participa en el orden por profundidad. El orden debe seguir el pie visual de cada elemento, no su centro gráfico.
2. Inspecciona cada tipo y variante de terreno. El borde pintado del PNG debe coincidir con el contorno de la cara hexagonal, sin desplazamiento lateral o vertical visible y sin tapar de más las celdas vecinas.
3. Con `Ctrl+D` desactivado, confirma que cada rama y convergencia de PATH muestra flechas con movimiento continuo hacia la base. Cambia una colocación válida para revisar el grafo candidato; cancélala y comprueba que vuelve a fluir el grafo activo. Los portales pulsantes siguen visibles y no muestran carteles.
4. Comprueba las dimensiones por recurso (torres 84 px y enemigos estándar 72 px) a zoom 1× y 0,75×. Deben conservar proporción y su arte debe quedar unos 6 px por debajo del centro lógico. El tamaño visual vigente de la base está especificado en M46: el PNG fuente permanece 270×352 y su caja renderizada es 1,8 × el radio de huella de ancho por 2,8 × de alto. La ampliación no debe alterar selección, ocupación, alcance, hitboxes de combate ni navegación.

ADR-0041 y ADR-0042 implementan en código la ordenación de props, la alineación del arte, el flujo animado por aristas, la profundidad por elevación, el hover selectivo del grid y el portal de spawn. Esta revisión no marca M17/M18 aceptados hasta completar las comprobaciones visuales en una ventana Godot.

### M18 Orden visual, feedback y piezas de terreno

#### Prueba manual en el juego

1. Haz pasar enemigos por PATH detrás y delante de una montaña elevada. La fachada del cliff debe cubrir a los actores detrás de su borde delantero Y-sorted y quedar bajo los actores delante; las torres y props que se apoyan en la superficie elevada deben seguir legibles.
2. Aleja el cursor de las celdas: no deben verse los bordes blancos del grid ni las conexiones/sockets de PATH. Haz hover sobre una celda y confirma que aparece su borde y ruta; las celdas a una y dos posiciones axiales se muestran con opacidad decreciente y el resto sigue oculto. Las flechas de flujo permanecen visibles.
3. Sigue un portal de spawn alcanzable: debe pulsar suavemente, no debe tener etiqueta/cartel `SPAWN` y debe desaparecer si deja de ser endpoint alcanzable. Selecciona una card, mueve el preview a una posición válida y confirma que los portales siguen los endpoints del grafo candidato con un tono verde; rota, cancela y comprueba que se recalculan o restauran según el estado activo. Verifica que el flujo de flechas apunta a la base en ramas y convergencias.
4. Entra en modo de construcción y confirma que el cursor de torre mide aproximadamente 32 px y pulsa mientras sigue el puntero. Al pasar por un botón debe volver el cursor de interfaz; sobre terreno inválido debe usar el cursor de error. Coloca una torre y confirma que vibra su icono correspondiente en la barra.
5. Comprueba que las siete cartas de torre son más grandes y tienen menor separación entre sí, sin recorte a 1280×720. Gana y gasta Gold y confirma que el icono y el saldo animan en ambas direcciones.
6. Revisa las diez nuevas piezas (Pradera de colinas, Macizo montañoso, Llanura abierta, Cresta escalonada, Loma aislada, Picos gemelos, Pradera con ramal sin salida, Curva junto al acantilado, Camino serpenteante y Bifurcación del barranco). Cada oferta debe tener siete hexes y mostrar el contenido de su plan sobre Grass/Mountain; PATH no lleva props. Los mismos obstáculos/cofres deben permanecer en el ghost y tras confirmar. Cancela y vuelve a elegir para verificar que no se vuelven a tirar. Gira cada pieza y comprueba terreno, reciprocidad PATH y colocación/validación global. En la pieza del ramal, confirma que la rama norte termina dentro de la pieza y la salida este continúa conectándose con el grafo existente.

El código, las piezas y el sprite del portal están integrados. La aceptación M18 queda pendiente hasta recorrer estos puntos en ventana Godot. La corrección de superficies y el preview inicial se registró en ADR-0043; ADR-0060 documenta la consistencia de oferta y M39/ADR-0087 define su excepción al normalizar el anillo de base.

### M19 Auditoría de torres, selección y texturas

#### Prueba manual en el juego

1. Selecciona una torre sobre Grass y otra sobre Mountain elevadas. El panel lateral debe permanecer quieto; la card inferior activa y el sprite de la torre pulsan, y el brillo azul sigue el alfa del PNG. No debe aparecer un círculo alrededor mientras está seleccionada. Revisa desde varios lados que la torre seleccionada aparezca por delante de tapas altas, Path, obstáculos y otras torres; al deseleccionar debe recuperar el Y-sort.
2. Haz hover en una celda Path y en Grass/Mountain de elevación 1 y 2, incluidos hexes delanteros a otras superficies. El borde de la tapa seleccionada debe coincidir con su superficie elevada y quedar legible sobre el arte; sockets PATH deben compartir los anillos con opacidad decreciente.
3. Observa una rama larga y una convergencia. Las flechas deben avanzar en loop hacia la base, a menor velocidad, con menos repeticiones y menor opacidad que el build anterior; verifica que las ramas del candidato válido cambian durante el preview y se restauran al cancelar.
4. Gana Gold por kill, cofre y limpieza, y gasta Gold en construcción/mejora. En una recompensa, icono y cifra deben pegar un rebote amplio juntos y regresar a escala normal; el gasto conserva un efecto perceptible más corto. Cofre nuevo: aparece con una pulsación única y termina en escala normal. Portal: cada spawn pulsa lentamente con fase distinta; no deben volver a oscilar todos al mismo tiempo.
5. Compara las texturas con el tablero a zoom 1× y 2,5×: base, portal, cofre y carta de torre deben conservar la escala visual anterior, con detalles limpios y sin memoria/resolución exageradas. Confirma que existen nueve PNG de tiles de 180×208 y cinco PNG de obstáculos de 208×208; todos conservan alpha y cada una de las catorce rutas está usada en mapa o card. Los dos atlas originales quedan guardados como fuentes, pero no los carga `TerrainVisualCatalog`.
6. Construye cada tipo de torre y coteja el panel con [Auditoría del sistema de torres](CONTENT_AND_ASSETS.md#tower-audit). Comprueba RPM, rango circular/cuadrado, coste de Mana, daño por capa, mejora manual y mejora XP en objetivo de cada capa. Configura dos y tres prioridades para confirmar los desempates lexicográficos del proyecto y su diferencia frente a los pesos oficiales RT. Como observación de balance y sin modificar datos, contrasta las bandas críticas y el Mana de Frost Keep con las preguntas pendientes del informe.

El código y las texturas de M19 están integrados. No se ejecutó Godot para esta revisión; M19 queda pendiente de aceptación visual/interactiva en ventana. El informe distingue hechos runtime de propuestas no aprobadas.

### M20 Progresión individual, targeting y feedback de colocación

#### Prueba manual en el juego

1. En una run, selecciona una torre y compra una mejora Health. Confirma que solo Health aumenta `0 → 1`, que sube +1 el daño base y +1 el multiplicador Health, y que Armor/Shield conservan niveles y XP. Mejora luego Armor y Shield: cada botón debe afectar únicamente a su propia capa. El total del resumen debe aumentar una unidad por compra y mostrar `n/45`.
2. Examina los tres botones: cada uno debe mostrar icono/nombre de la capa, nivel `n/15`, barra XP con color Health verde, Armor ámbar o Shield azul, XP actual/umbral, efecto y coste Gold. Comprueba que la barra solo avanza en la capa activa del enemigo que la torre mantiene como objetivo; cambiar a un enemigo con otra capa activa debe enviar la XP posterior a esa otra capa. XP acumulada previamente en la primera capa no debe desaparecer.
3. Comprueba que las compras de cada capa parten de su coste base independiente (10/20/30 Gold según la torre) y que el siguiente coste de esa misma capa crece con el nivel propio. Para verificar el límite sin farmear toda una run, utiliza un fixture o una copia local de Resource con umbral/costes bajos: una capa debe llegar a `15/15`, bloquear XP y compra solo para sí; las otras dos deben poder seguir subiendo. La suma máxima debe ser 45, con daño base total incrementado en 45 y +15 a cada multiplicador si se maximizan las tres.
4. Al seleccionar una torre, aparece solo Prioridad 1 junto al botón `+`. Cada clic revela una fila debajo, primero Prioridad 2 y después Prioridad 3. Cambia de torre y confirma que las filas no configuradas quedan ocultas. Elige criterios distintos y verifica que sus tooltips explican la métrica; en «Menos HP total», compara objetivos con sumas Health+Armor+Shield distintas. Repite un criterio ocupado y comprueba el intercambio; intenta duplicar en una fila vacía y confirma que se revierte. No quedan duplicados y Prioridad 1 no se puede vaciar. En empate deliberado, la segunda resuelve el empate de la primera y la tercera el empate que quede.
5. Entra en build mode y mueve la torre seleccionada encima de superficies elevadas, obstáculos, Path y huecos. El sprite y el contorno del ghost deben verse siempre delante de terreno, obstáculos, base, torres y enemigos, también si la ubicación es inválida. Las posiciones legales se contornean en verde y las no disponibles en rojo; comprobar por separado Path, obstáculo, celda ocupada y falta de Gold. No se debe colocar torre si el contorno está rojo.
6. La card de torre activa de la fila inferior debe pulsar al entrar en build mode y al seleccionar una torre colocada; las otras cards mantienen su escala normal. Al cambiar selección, el pulso debe trasladarse a la nueva card y resetear la anterior.
7. Criterio histórico de M20: el tamaño de 86×86 px y su offset visual fueron sustituidos por cambios posteriores. La presentación actual de obstáculos y props se comprueba con el catálogo de sprites y los criterios de M39/M41; esta prueba conserva solo el comportamiento de bloqueo de construcción.
8. Revisa la celda de base y sus seis vecinas axiales: PATH se mantiene en 0 y Grass/Mountain pueden tener sus alturas válidas. La validación inicial no debe exigir un anillo plano; prueba una elevación positiva junto a la base.

M20 queda aceptado cuando los contadores, XP, costes y límites son independientes por capa; las prioridades mantienen orden y unicidad; el preview da feedback visible sin permitir colocaciones inválidas; el pulso se mueve con la selección y las cajas de obstáculos coinciden. El criterio histórico del anillo plano queda sustituido por las elevaciones M34/ADR-0073. Esta revisión integró código y documentación, pero no ejecutó Godot ni la prueba manual.

### M21 Herramientas de depuración, prioridades y hover de obstáculos

#### Prueba manual en el juego

1. Pulsa `Ctrl+K` y confirma que el menú abre/cierra y no mueve el mapa. Activa cada acción: Gold aumenta 1.000; Mana aumenta 100 hasta su máximo; la acción de restaurar lo repone al máximo; Curar la base recupera Health; iniciar ronda invoca la ronda seleccionada cuando la fase permite empezar; reiniciar crea una run con tablero/economía/cartas nuevos y conserva las compras permanentes.
2. Activa «Desbloquear todo»: deben aparecer las siete torres y poder ofrecerse cartas con requisito de unlock. Repite después de desactivar el override y comprueba el roster persistente original. Reinicia la run con el override activo y confirma que el nuevo run vuelve a los desbloqueos guardados. Inspecciona el archivo de meta-progresión: el botón de depuración no añadió IDs.
3. Gana Gold por bajas, cofre y ronda, y gástalo en construir o mejorar. Tanto el icono como el número de Gold del HUD superior derecho deben aumentar de tamaño y rebotar juntos. El importe permanece legible y vuelve a escala normal.
4. Selecciona torre: el panel derecho no debe vibrar. Solo pulsa la card inferior elegida y el sprite seleccionado; el sprite conserva brillo recortado pero no muestra círculo. Haz hover sobre otra torre y confirma que se ven su rango y contorno de hover.
5. Prueba targeting en ventana 1280×720 y 1440×900. Por defecto hay una fila; `+` revela la segunda y luego la tercera. Al cambiar a torre con una sola prioridad, las filas extra se ocultan. El panel entero queda dentro de la ventana con sus datos, sin scroll.
6. Haz hover sobre cada obstáculo en diferentes elevaciones. El resplandor debe seguir solo la forma opaca del PNG, incluido el recorte transparente, y desaparecer al abandonar la celda; cofres y terreno no deben adquirir el contorno de obstáculo.
7. Comprueba el invariante del spawn: al arrancar hay al menos una salida PATH exterior con ruta hasta Main Tower. Durante expansión mueve y rota cada pieza candidata. Una que no tenga spawn alcanzable o rompa cualquier ruta existente debe verse inválida y no permitir confirmación; el grafo activo y sus portales no cambian hasta confirmar una pieza válida.

M21 queda aceptado cuando los cheats sirven para preparar una sesión, no alteran datos persistentes salvo el contador normal de run reiniciada, Gold rebota de manera visible, las prioridades se despliegan gradualmente, panel y selección respetan la jerarquía visual y ninguna expansión confirmada elimina todos los spawns alcanzables. La aceptación requiere inspección manual en Godot.

### M22 HUD, oleadas, cards de terreno y fachadas

#### Prueba manual en el juego

1. Inicia `game/main/main.tscn`. Comprueba que no aparecen errores al resolver `%GoldGroup` y que tanto ganar como gastar Gold animan icono y cifra. La vida de Main Tower queda arriba a la izquierda con los atajos debajo; Gold y Mana quedan arriba a la derecha, con valores enteros. Gold usa el panel 9-slice de Iniciar ronda; el criterio histórico de Mana sin panel queda sustituido por M61, que usa el mismo panel 9-slice.
2. Selecciona una torre. El panel lateral debe comenzar debajo de Gold/Mana y no cubrir los recursos. Cambia la resolución entre 1280×720 y 1440×900; el panel de ronda y el botón no deben quedar cortados.
3. Comprueba que el bloque de ronda no tiene panel de fondo y que el botón usa su sprite completo sin deformación, mantiene el texto legible y adapta su anchura con «Iniciar ronda», «Iniciar ronda NN/45» y los estados deshabilitados.
4. Criterio histórico reemplazado por M35: el timeline muestra 15 rondas, sin selector, conserva los círculos/tooltip y desvanece el extremo futuro.
5. Tras completar una ronda y abrir las tres cards de terreno, confirma que no existe panel de fondo compartido. Cada card conserva su marco y preview; la preview se ve completa dentro del marco y no sobresale. En oferta las cards miden al menos 320×420 px; durante colocación se reducen a 184×126 px y mantienen la preview contenida. Debajo indica cantidades como `4 Path 2 Grass 1 Mountain`; comprueba que las categorías con cero unidades no aparecen.
6. Coloca o consulta celdas elevadas Grass y Mountain de nivel 1 y 2. Las fachadas deben usar su material de césped/tierra o roca, conservar el mismo tamaño de detalle entre ambas alturas y quedar cerradas sin grietas ni ángulos abiertos. Confirma la oclusión de actores por Y-sort: enemigo detrás cubierto por la fachada, enemigo delante dibujado por encima. Los PNG pueden reemplazarse sin cambiar la altura lógica.

M22 queda aceptado tras pasar esta revisión manual en ventana Godot. La integración de código y arte está registrada en [ADR-0048](DECISION_HISTORY.md#adr-0048).

### M23 Navegación, preview de portales, ghost y Tower Info

#### Revisión manual en ventana

1. Ejecuta `game/main/main.tscn`. Mantén `W`, `A`, `S`, `D` y prueba diagonales; la cámara debe moverse continuo sin aceleración diagonal extra y mantener velocidad visual al acercar/alejar. Comprueba que `D` panea a la derecha y que `Ctrl+D` alterna el overlay diagnóstico. Suelta las teclas y cambia el foco de ventana mientras una está pulsada: la cámara no debe quedarse moviéndose. Los controles con foco de interfaz deben conservar su entrada.
2. Inspecciona las salidas PATH de una ronda mixta con varios endpoints. Sobre el portal no deben aparecer badges de enemigos. Al hacer hover aparece el contorno que sigue el alfa del frame actual y un tooltip con ronda, total, retratos, nombres y cantidades por tipo; al hacer clic, el panel de información presenta la misma lista. El atlas 4×2 se reproduce en bucle continuo a 96×96 px y cada endpoint tiene una fase distinta. Suma todos los portales y compara con la composición directa de esa `WaveData`.
3. Repite para la ronda siguiente y compara distribución round-robin entre endpoints con la ronda/política activa; no hay fixtures de oleada DEBUG desde M64. Selecciona una expansión válida y mueve/rota su preview: la vista por portal debe usar los endpoints del grafo candidato. Al cancelar o invalidar, debe volver al grafo activo. El tooltip no debe quedarse visible cuando se oculta el HUD ni capturar clics.
4. Entra en colocación de torre y mueve el cursor por celdas legales e ilegales, elevadas y con obstáculos. El sprite fantasma debe quedar encima de terreno y props y recibir tinte verde translúcido si es válido o rojo si no. Al cancelar no debe permanecer el sprite fantasma.
5. Revisa torres, enemigos, base, cofres y obstáculos en profundidad: no deben aparecer sombras generadas por código ni sprites auxiliares de sombra. El cofre conserva su silueta cerrada y simple al tamaño real; los PNG de cofre y portal mantienen alpha y se dibujan con filtro nearest.
6. Selecciona una torre y revisa Tower Info a 1280×720 y 1440×900. La superficie plana no lleva marco ornamental; el icono pequeño comparte cabecera con el nombre y `NIVEL X DE 45`. El panel se ajusta sin scroll ni recorte. Health/Armor/Shield muestran icono, nivel, barra de XP y coste en tres controles compactos; el tooltip conserva las cifras exactas de XP y el efecto completo. Demoler usa un botón de texto horizontal y conserva su comportamiento. Comprueba que el nivel acumulado avanza tras comprar capas y llega como máximo a 45.
7. Abre la selección de expansión de terreno. Las tres cards usan superficies planas con un borde fino para hover/selección, sin marco ornamental; preview, nombre y conteos siguen legibles y seleccionar una pieza conserva el comportamiento.

M23 queda aceptado tras completar esta revisión manual en ventana. El cambio está registrado en [ADR-0051](DECISION_HISTORY.md#adr-0051), [ADR-0053](DECISION_HISTORY.md#adr-0053), [ADR-0055](DECISION_HISTORY.md#adr-0055) y [ADR-0105](DECISION_HISTORY.md#adr-0105).

### M24 Feedback legible de daño

#### Revisión manual en ventana

1. En una oleada de combate, observa impactos repetidos en enemigos con Health, Armor y Shield. Cada número debe entrar con un golpe breve de escala, desplazarse hacia arriba por un arco alternando los lados, variar su tamaño de forma moderada y desaparecer con un contorno oscuro que mantenga legibilidad sobre el mapa.
2. Confirma que el texto y el flash del enemigo identifican Health en rojo, Armor en ámbar y Shield en cian. Compara golpes pequeños y grandes al mismo enemigo: el tamaño relativo debe notarse sin producir números desproporcionados.
3. Genera un crítico y confirma que su etiqueta `CRIT`, tamaño/contorno y punch destacan sin ocultar el color de la capa afectada. Comprueba grupos de muchos enemigos y torres rápidas: los números deben separarse lo suficiente para leerse y no afectar HP ni el resultado de combate.

M24 queda aceptado tras completar esta revisión manual en ventana. La decisión está registrada en [ADR-0052](DECISION_HISTORY.md#adr-0052).

### Feedback de daño a base, recompensas y selección

#### Revisión manual en ventana

1. Inicia una oleada con enemigos que alcanzan la base: el sprite se tiñe de rojo durante un instante y la cámara tiembla brevemente. La cámara debe terminar exactamente en su posición y zoom previos, también al recibir impactos seguidos.
2. Gana Gold por una baja/recompensa y abre un cofre con recompensa: el icono y la cifra de la esquina superior derecha deben rebotar y vibrar juntos. Abre un cofre teniendo Gold al límite y confirma que el cofre también produce el feedback sin cambiar el saldo.
3. Abre una oferta de mejoras y una oferta de expansión de terreno: el tablero queda oscurecido bajo las cards, las cards siguen destacadas y el fondo no bloquea clics. Al elegir una pieza el velo desaparece; cancela su colocación y confirma que vuelve con las tres opciones.

El feedback queda aceptado tras completar esta revisión visual/interactiva. La decisión está registrada en [ADR-0055](DECISION_HISTORY.md#adr-0055).

### Revisión visual global: tipografía y estado sin sombras

#### Revisión manual en ventana

1. Revisa el HUD, selección de terreno, Tower Info, cards de mejora, tienda permanente, tooltips, panel de debug, números de daño y cifras dibujadas junto a iconos. Todos deben usar Patrick Hand; los números de contadores dibujados manualmente también deben coincidir con la tipografía de controles.
2. Comprueba tamaños legibles y ausencia de recortes en 1280×720 y 1440×900. La sustitución de fuente conserva los tamaños tipográficos y la estructura actuales.
3. Coloca una torre, un obstáculo, una celda elevada y una celda plana; mueve enemigos y abre cofres. No deben aparecer sombras proyectadas, pedestales oscuros ni formas que simulen sombra generadas por el juego. Las flechas PATH no deben tener un trazo ancho debajo y los contadores no deben dibujar texto desplazado como sombra. El feedback de hover y selección se mantiene.

La revisión queda aceptada tras completar estos puntos en ventana. La tipografía está registrada en [ADR-0054](DECISION_HISTORY.md#adr-0054); la retirada actual de sombras generadas, en [ADR-0070](DECISION_HISTORY.md#adr-0070).

### M25 Oferta de terreno, pausa y control de fases

#### Revisión manual en ventana

1. Pulsa `P` y el botón junto a la vida durante `ROUND_PREP` y `COMBAT`. Confirma que pausa/reanuda el árbol y que el botón alterna entre el glyph de pausa y el de play, conservando solo la letra `P` visible.
2. Pausa durante `ROUND_PREP` y pulsa «Iniciar ronda». La partida debe despausarse e iniciar la oleada. Durante una selección de terreno o `CARD_OFFER`, iniciar ronda debe permanecer bloqueado y no debe quitar una pausa activa.
3. Durante la oferta y la colocación de terreno, comprueba que la barra de torres/panel de torre se oculta, `1–7` no seleccionan torres, `F3`/`Ctrl+D`/`Ctrl+K` no abren herramientas de diagnóstico, y hacer clic en una torre o cofre del tablero no selecciona/abre nada. Elegir, rotar, cancelar y confirmar la pieza siguen funcionando; al volver a `ROUND_PREP` regresan los controles normales.
4. Elige una card con un obstáculo visible. Verifica que miniatura, ghost al rotar/mover y tablero confirmado enseñan el mismo obstáculo en el mismo hex; miniaturas y ghost no muestran cofres. Cancela y vuelve a la misma oferta: los rolls se conservan.
5. Completa varias ofertas y revisa la pieza marcada `EXTIENDE RUTA`. La posición sugerida debe prolongar una ruta y la geometría debe variar entre recta, curva y bifurcación; cuando la sugerencia sea curva/bifurcación, ninguna card debe ofrecer la pieza recta. Las colocaciones que eliminen toda continuación legal deben seguir bloqueadas.
6. Haz hover sobre un cofre: debe botar y resplandecer en dorado mientras el cursor permanezca sobre el hex; al salir o abrirlo, el movimiento y el brillo deben detenerse.

La implementación M25 está integrada en código. La aceptación de pausa, control de fases, fidelidad de props y variedad de rutas queda pendiente de esta revisión interactiva. Decisiones: [ADR-0060](DECISION_HISTORY.md#adr-0060) y [ADR-0061](DECISION_HISTORY.md#adr-0061).

### M26 Selección/retirada de obstáculos y portales, fachadas y altura

#### Revisión manual en ventana

1. En `ROUND_PREP`, haz clic en obstáculos de cada tipo. El panel debe mostrar Roca, Cristal, Hierba alta, Tótem o Montón de piedra junto a su retrato y altura/terreno.
2. Comprueba que retirar obstáculos cuesta 25, 100 y 225 Gold sucesivamente; la celda queda libre para construir y el siguiente precio cambia solo tras retirar otro obstáculo.
3. Haz clic en cada portal y comprueba que el panel muestra la ronda y una lista desplazable con sprite, nombre y cantidad de cada enemigo asignado.
4. Con cuatro spawns activos, quita uno: cuesta 50 Gold si no se retiró ningún obstáculo, desaparece ese portal y el total directo de enemigos no cambia; la distribución round-robin debe aparecer actualizada en los tres restantes. Con tres activos, la opción de quitar queda deshabilitada. Si ya se retiró un obstáculo, el coste del portal debe ser el doble del siguiente coste de obstáculo.
5. Inicia una oleada después de cerrar portales y confirma que se generan todos los enemigos y salen solo de los portales activos; compara la vista previa con la asignación real.
6. Inspecciona varias uniones de fachadas Grass/Mountain a elevaciones 1 y 2, incluyendo las esquinas de las capturas adjuntas, a zoom 0.45×, 1× y 2×. No debe quedar fondo abierto en vértices coincidentes; la elevación de cada nivel debe distinguirse más sin desalinear hover, tapas, torres ni props.

M26 está implementado en código. La escena se inició con Godot 4.7 sin errores de parseo/runtime; se mantienen avisos de GDScript. La verificación de interacción y la revisión de seams/elevación en ventana quedan pendientes. Ver [ADR-0063](DECISION_HISTORY.md#adr-0063).

### M27 Upgrade Cards, reembolso y cofres

#### Revisión manual en ventana

1. Criterio visual original de M27, sustituido por M34/M36 y luego por M40/ADR-0088: consulta el layout plano, tier y aura en M40.
2. Inspecciona cartas de cada operación general vigente: daño, crítico, alcance, elevación, cadencia, área, Mana, capas Health/Armor/Shield, Gold, enemigo y estados. Ninguna card debe quedar sin imagen. Las cartas de torre específica deben conservar el retrato de la torre.
3. Coloca dos o más torres del mismo tipo. Comprueba que el reembolso de demoler la última torre seleccionada coincide con `precio_base + (cantidad_antes - 1) × incremento`, el conteo baja y el siguiente precio de compra disminuye. Sube una torre de nivel antes de demolerla y confirma que su reembolso no cambia.
4. En una oferta de terreno y al mover/rotar su ghost, verifica que no aparecen cofres en miniaturas ni losas seleccionadas. Confirma terreno Grass/Mountain sin obstáculo: si la tirada genera cofre, aparece en la celda ya colocada con un salto visible; PATH y celdas con obstáculo nunca reciben cofre. Abre uno y confirma que conserva hover, pago y retirada.
5. Abre el proyecto y observa la salida de GDScript: no deben reaparecer los avisos de parámetro/variable sin uso, variable `rotation` en conflicto, `_mana_icon` ni `is_pressed` reportados antes.

La regla M27 de cofres sustituye la visualización de cofres en oferta descrita en M25/ADR-0060. La implementación de sombras descrita en ADR-0066/0068 se retiró posteriormente mediante ADR-0070. Código/PNG integrados; Godot 4.7 inició la escena principal el 2026-10-13 con `errors: []`, incluidos los avisos GDScript listados. La aceptación visual e interactiva sigue pendiente. Ver [ADR-0064](DECISION_HISTORY.md#adr-0064), [ADR-0065](DECISION_HISTORY.md#adr-0065), [ADR-0066](DECISION_HISTORY.md#adr-0066) y [ADR-0070](DECISION_HISTORY.md#adr-0070).

### M28 Hacks de progresión para testeo rápido

#### Revisión manual en ventana

1. Abre `Ctrl+K` desde preparación y selecciona `Saltar a la siguiente card`. Debe buscar la siguiente ronda elegible del pool (3, 6, 9…) y abrir una oferta real de tres cards sin crear ronda dentro de combate.
2. Abre la tienda desde hacks. Debe abrir el mapa de nodos vigente de M35, indicar que es acceso de depuración y permitir comprar; la mejora se aplica a la próxima run. Cerrar el panel vuelve al tablero sin reiniciar la run.
3. Usa `Empezar desde cero`. Los niveles permanentes vuelven a cero, se devuelve el XP gastado en mejoras y el arsenal vuelve a Ballista, Mortar y Tesla Coil; el saldo XP no gastado y los contadores históricos permanecen. `Reiniciar run con mejoras actuales` y la nueva run normal conservan desbloqueos y niveles meta.

M28 está integrado en código. El salto omite combate, recompensa y colocación de terreno, por lo que sirve para revisar cards y no para medir la progresión de campaña. La revisión interactiva está pendiente. Ver [ADR-0067](DECISION_HISTORY.md#adr-0067).

### M29 Sombras receptoras por elevación — sustituido

#### Revisión manual en ventana

Este criterio quedó sustituido por ADR-0070. Ya no debe comprobarse ninguna sombra de terreno u obstáculo.

### M30 Sin sombras y preview PATH despejado

#### Revisión manual en ventana

1. Inicia el tablero y coloca el cursor sobre terreno, obstáculos y torres. No deben aparecer sombras de losetas, obstáculos, edificios, unidades o base. El hover puede resaltar bordes sin dibujar rayos/socket PATH sobre las celdas.
2. Selecciona una pieza de expansión. Las flechas de flujo PATH y las líneas de diagnóstico deben ocultarse mientras la pieza está elegida; al cancelar o confirmar vuelven las flechas del tablero normal. La selección de terreno no debe crear otra visualización del camino.

El overlay de sombras, shader y enlaces a runtime se eliminaron; queda pendiente la inspección en ventana. ADR-0070 sustituye las decisiones de sombra de ADR-0066/0068.

### M31 XP de desbloqueo y feedback de altura
> M35 separa el unlock permanente del reclutamiento temporal; una torre comprada no aparece inmediatamente en la barra de la run siguiente y debe reclutarse con una card.

#### Revisión manual en ventana

1. En un guardado nuevo, comprueba que Ballista, Mortar y Tesla Coil están desbloqueadas; solo Ballista aparece en la barra inicial. Mortar/Tesla se reclutan con cartas; las otras compras permanentes habilitan la opción de reclutamiento futura. La tienda cobra 50 XP por Frost Keep, Flame Thrower y Poison Sprayer, y 100 por Shredder.
2. Desde `Ctrl+K`, usa `Empezar desde cero`. En la run siguiente están desbloqueadas las tres torres iniciales, pero solo aparece Ballista en la barra hasta reclutar Mortar/Tesla con una card. Los niveles permanentes son cero y el XP devuelto permite recomprar mejoras.
3. Selecciona torres sobre Grass 1/2 y Mountain 2/3. El panel muestra su altura y los extras: +1 daño base y +0.5 hex de alcance por nivel según `TowerData`. Comprueba que el badge muestra +1, +2 o +3 y que el daño/alcance coinciden.

Los perfiles actuales cargan y el feedback está integrado; la aceptación manual sigue pendiente. Ver [ADR-0069](DECISION_HISTORY.md#adr-0069).

### M32 Marco de cards y colocación automática

#### Revisión manual en ventana

1. Criterio visual de card sustituido por M34; el panel unificado y las auras por rareza se revisan en esa sección.
2. Abre una oferta de terreno. Las miniaturas de bifurcación y convergencia muestran los hexágonos y obstáculos, sin brazos, ramas ni flechas PATH superpuestos.
3. Elige una pieza y comprueba que aparece `T · Auto-colocar (no recomendado)`. Pulsa T: la pieza debe colocarse en una posición libre que pase las validaciones geométricas y de PATH, incluida la continuación futura de campaña. Repite en un estado donde no exista una posición válida: debe mostrarse un aviso y el tablero no debe cambiar. Comprueba que la rotación manual y la confirmación usual siguen disponibles.

La inspección visual/interactiva de este milestone sigue pendiente. Ver [ADR-0071](DECISION_HISTORY.md#adr-0071) y [ADR-0072](DECISION_HISTORY.md#adr-0072).

### M33 Rotación y tooltip compacto de terreno

#### Revisión manual en ventana

1. Criterio histórico de M33: Q/E giraban y la rueda rotaba durante colocación. M55 sustituyó el uso de la rueda; la regla vigente se verifica en M55.
2. Sin pieza, torre ni objeto seleccionados, mueve el cursor por PATH 0, Grass 1/2 y Mountain 2/3. Debe aparecer junto al puntero un tooltip pequeño con el tipo/estado de la celda, la altura y el bonus de daño/alcance compatible. PATH debe indicar ruta no construible.
3. Comprueba Grass/Mountain con obstáculo, cofre y torre colocada: el estado refleja el bloqueo. El bonus usa los `TowerData` aplicables y aumenta con la elevación. La caja debe permanecer dentro de la ventana incluso junto a sus bordes.
4. Selecciona/coloca una torre, selecciona una pieza, pasa por un portal y abre oferta/tienda/hacks: el tooltip de celda debe ocultarse y los paneles/acciones existentes deben seguir respondiendo.
5. Criterio histórico de M33: sin pieza, la rueda acercaba/alejaba desde el cursor; al seleccionar terreno, no hacía zoom. M55 sustituyó este comportamiento; la regla vigente se verifica en M55.

La implementación está integrada; no se ejecutaron pruebas ni revisión visual/interactiva en esta actualización. Ver [ADR-0072](DECISION_HISTORY.md#adr-0072).

### M34 Elevaciones, vida de base, jefes y upgrade cards

#### Revisión manual en ventana

1. En una run nueva, confirma base en 10/10 HP. En la tienda, cada nivel permanente de Fortification añade +1 HP y cobra 20, 40, 60, 80, 100, 120, 140, 160, 180 y 200 XP; nivel X deja la base en 20/20 HP. No se puede omitir un nivel anterior. Las cards Fortification I, II y III suman +3 HP cada una durante esa run, sin alterar el nivel permanente.
2. En una copia/fixture de campaña con HP sobrante, deja que un enemigo `boss_tier > 0` toque la base y comprueba que la run termina al instante aun si conserva HP. Un enemigo normal debe finalizarla solo al agotar la vida de la base.
3. Genera varios mapas/ofertas. PATH siempre usa altura 0, Grass solo 1 o 2 y Mountain 2 o 3; los valores permanecen iguales desde la miniatura y el ghost hasta confirmar la expansión. La altura Grass varía de forma reproducible por seed.
4. Construye torres en alturas 1, 2 y 3. El badge superior muestra +1/+2/+3 de daño, el alcance aumenta 0,5 hex por altura y la torre conserva su selección/click con el sprite elevado. En torres con coste de Mana escalado por daño, comprueba que el coste por ataque también aumenta con la altura.
5. Selecciona Ballista para construir y mueve el cursor por Grass/Mountain de alturas diferentes. El ghost debe mostrar en todo momento el bonus de daño de la celda; PATH, huecos, obstáculos y casillas inválidas no deben tapar el indicador ni permitir construcción.
6. La presentación vigente de upgrade cards está definida por M40/ADR-0088; comprueba esa sección. El criterio temporal del sprite vertical de M36 queda sustituido.

La aceptación visual/interactiva de M34 está pendiente. No se ejecutaron pruebas en esta actualización. Ver [ADR-0073](DECISION_HISTORY.md#adr-0073), [ADR-0074](DECISION_HISTORY.md#adr-0074) y [ADR-0075](DECISION_HISTORY.md#adr-0075).

### M35 Menú, reclutamiento, tienda de nodos y lectura del tablero

#### Revisión manual en ventana

1. En una partida nueva, confirma 1.000 Gold al entrar. Starting Coffers debe sumar 100 Gold por nivel comprado; al nivel X el saldo inicial debe ser 2.000. Verifica que se trata de Gold de run y no de XP persistente.
2. En el menú principal, inicia una partida y comprueba que aparece solo la Ballista en la barra de construcción. Tras completar la ronda 3 y colocar terreno, la primera oferta programada debe incluir Mortar y Tesla Coil como opciones de reclutamiento. Elige una: aparece su botón y se puede construir; la otra torre no se puede construir antes de reclutarla. Las cartas de mejora específicas de una torre no aparecen hasta reclutarla. Compra el unlock permanente de otra torre y confirma que puede entrar en ofertas de runs posteriores, pero no se construye antes de elegir su carta.
3. Desde el menú, abre la tienda y recorre el mapa de mejoras. Todas las categorías usan la misma tarjeta/nodo y un icono grande del objeto afectado; las ramas tienen conectores. Un nodo bloqueado informa en tooltip del unlock o nivel anterior requerido. Compra uno y confirma que se actualizan sus dependencias y aparece una ráfaga de partículas. Los nombres Better de torre identifican claramente la torre afectada. Para cada torre, Health/Armor/Shield comparten el requisito del unlock de torre y son hermanas; las mejoras de Main Tower conservan su secuencia de niveles.
4. Mientras corre una partida, pulsa Escape: el juego se pausa y muestra opciones para reanudar o volver al menú. Reanuda y comprueba que el juego sigue; vuelve al menú y confirma que se limpia la pausa sin entregar recompensa de derrota. Al perder por daño a la base o contacto de boss, el resultado lleva al menú con la tienda abierta. El cambio de escena no debe disparar consultas del puntero desde el preview desmontado ni errores de `get_viewport()`. Game Over resume por torre la cantidad construida y el daño acumulado; no muestra categorías sin unlock permanente. Ver [ADR-0086](DECISION_HISTORY.md#adr-0086).
5. Comprueba que el timeline no tiene selector y muestra siempre 15 rondas. Verifica círculos, tooltip con retratos/conteos y el total de 45 rondas. La ventana empieza en la ronda actual; al llegar al tramo final, muestra 31–45 para mantener los 15 puntos. El extremo futuro se desvanece. La cámara de juego no rota ni cambia de proyección.
6. Repite la generación del tablero inicial y varias ofertas. En el tablero inicial hay como máximo un obstáculo total y no se coloca en la base ni sus seis vecinas. Cada pieza de siete hexes tiene como máximo dos obstáculos. Confirma los mismos límites al pasar de miniatura a ghost y tablero. Compara las tres vistas de cada oferta: tapa texturada, fachada, altura, props y orden delante/detrás deben coincidir; presta atención a Camino serpenteante. La lista activa de obstáculos y las condiciones de los props se verifican en M39.
7. Recorre celdas delante y detrás entre alturas 0–3 con los dos tipos de fachada. Cada tapa debe verse como polígono cerrado de seis lados; no aparecen vértices abiertos ni caras rectangulares sueltas, y la textura no se estira al subir altura. En uniones de vértice no quedan huecos; los UV no muestran franjas ajenas. Comprueba el orden back-to-front entre tapas y copias elevadas junto a actores detrás, delante y al mismo nivel; las superficies deben ocluir solo lo que queda detrás. La cámara permanece fija.
8. Selecciona Ballista y haz hover por celdas elevadas de altura 1 y 2. El ghost muestra +1/+2 de daño antes de confirmar la construcción; después, la insignia de la torre colocada queda oculta hasta pasar el cursor por encima.
9. Carga la tienda y confirma que la validación del catálogo no informa de prerequisitos ausentes. Archivo de cartas aparece conectado tras Suerte del explorador (ID persistente `meta:chest_finder`); el mapa no emite avisos de división entera al distribuir nodos sueltos. La partida compila con Ballista como torre seleccionada por defecto.

La integración de M35 está en código y documentos. Tras los arreglos de ID, división entera y perfil Ballista, Godot 4.7 arrancó la escena de menú sin errores en la salida de depuración y el escaneo headless no reportó diagnósticos GDScript. No se ejecutaron tests ni se inspeccionó visualmente la interfaz o el tablero. La aceptación de flujo, legibilidad, partículas, ventana y geometría requiere esta revisión visual/interactiva. Ver ADR-0076, ADR-0077, ADR-0079 y ADR-0083.

### M36 Cards de tier, ramas paralelas y tinte de altura

#### Revisión manual en ventana

1. El criterio de sprite vertical de esta sección quedó sustituido por M40/ADR-0088. Conserva aquí la comprobación de ramas H/A/S paralelas; la intensidad del tinte se actualizó en M49.
2. En el mapa permanente, desbloquea una torre y confirma que sus mejoras Health, Armor y Shield pasan juntas a disponibles y que las tres conexiones salen del nodo de torre. Compra una de ellas y verifica que las otras dos siguen comprables; comprueba que puedes elegir las tres en cualquier orden para Ballista y otra torre.
3. Compara tapas Grass/Mountain a elevaciones 0, 1, 2 y 3 junto a sus copias elevadas Y-sorted. El nivel 0 conserva el color original y cada nivel oscurece el RGB con multiplicadores 1,00/0,95/0,90/0,85. Deben seguir visibles los detalles de textura y el patrón no debe estirarse. Verifica que la cámara top-down isométrica, UV, geometría cerrada y oclusión delante/detrás no cambian.

Las ramas H/A/S y el tinte de M36 permanecen vigentes; su presentación de card se reemplazó en M40. No se ejecutaron pruebas automatizadas ni se hizo revisión visual/interactiva; la aceptación queda pendiente. Ver [ADR-0080](DECISION_HISTORY.md#adr-0080), [ADR-0081](DECISION_HISTORY.md#adr-0081), [ADR-0082](DECISION_HISTORY.md#adr-0082) y ADR-0088.

### M37/M38 Geometría axial y fachadas delanteras

#### Revisión manual en ventana

1. Genera tableros con Grass y Mountain en las alturas válidas 1, 2 y 3. En un borde con vecino, la pared solo cubre el desnivel expuesto entre ambas tapas; en un borde vacío llega al suelo. La tapa de cada hexágono permanece completa y nunca queda cubierta por una pared.
2. Revisa celdas contiguas y piezas de siete hexes. Solo se dibujan las dos fachadas delanteras del hex pointy-top; ninguna cara lateral/trasera, extrusión radial, cierre de esquina añadido o polígono marrón debe aparecer.
3. Comprueba que cada fachada mantiene el ancho de la arista axial original, termina exactamente en la tapa vecina y no crea vértices de esquina. Conserva la textura Grass/Mountain y el degradado; las tapas y sus texturas permanecen intactas y los UV de muro no se estiran.
4. Recorre las mismas coordenadas con hover, selección y copias elevadas de `Entities`. La cámara se mantiene fija; las celdas de delante cubren terreno de detrás y los actores conservan el Y-sort acordado.

M37 estableció la retícula axial compartida. M38 simplifica el renderer para responder a la revisión visual: solo dos fachadas delanteras por hex, sin cierres de vértice ni profundidad lateral, con degradado multiplicativo por vértice en las paredes. ADR-0090 limita cada pared al desnivel expuesto para mantener visibles las tapas hexagonales. La matriz completa de alturas, vecinos y oclusión sigue pendiente de revisión en ventana. Ver [ADR-0084](DECISION_HISTORY.md#adr-0084), [ADR-0085](DECISION_HISTORY.md#adr-0085) y [ADR-0090](DECISION_HISTORY.md#adr-0090).

### M39 Props decorativos, obstáculos y base

#### Revisión manual en ventana

1. Genera varios mapas y ofertas. La base conserva intacto su PNG fuente de 270×352 px y se estira a 1,8 × el radio de huella de ancho por 2,8 × de alto. La silueta crece hacia arriba, mantiene anclado su borde inferior y sigue ocupando una sola celda lógica; la cámara sigue aplicando su zoom uniforme al mundo.
2. Inspecciona las seis celdas adyacentes a base en varias semillas: Path es elevación 0, Grass elevación 1 y nunca hay Mountain ni altura mayor que 1.
3. Verifica que cada uno de los 18 props del catálogo solo aparece en su tipo de terreno, con roll independiente del 10 % por asset/celda, tamaño runtime vigente de 39,6×39,6 px y máximo dos props únicos en una celda. Los props no reaccionan al hover/clic, no seleccionan nada ni bloquean construcción.
4. En celdas con dos props, confirma que no se solapan. Cuando una celda tiene obstáculo, este aparece delante de los props; el obstáculo queda centrado en el hex.
5. Comprueba que los ocho obstáculos del catálogo reemplazan al pool antiguo, que sus imágenes conservan el tamaño fuente 208×208 y que su tamaño vigente en tablero/miniatura es 94,6×94,6 px. El anillo de base queda excluido según reglas existentes, con máximo de un obstáculo en tablero inicial y dos por pieza.
6. Para cada pieza, compara el set de props y obstáculos entre miniatura, ghost y terreno confirmado. Sin normalización del anillo de base, debe ser idéntico. Si una celda Mountain se convierte en Grass junto a base, la miniatura conserva el contenido sin ancla y el ghost debe coincidir exactamente con el tablero confirmado. Rota las piezas y verifica que las decoraciones siguen asociadas a su celda local.

El código, los assets y la documentación de M39 están integrados; sus valores visuales vigentes se actualizan en M41/ADR-0089. No se ejecutaron pruebas ni revisión visual/interactiva en esta actualización; aceptación pendiente. Ver [ADR-0087](DECISION_HISTORY.md#adr-0087) y [ADR-0089](DECISION_HISTORY.md#adr-0089).

### M40 Presentación compacta de upgrade cards

#### Revisión manual en ventana

1. Abre varias ofertas de mejora y confirma que cada una muestra exactamente tres cards en una fila, con separación legible y sin ocupar indebidamente el centro del mapa.
2. Todas las rarezas comparten exactamente la misma superficie plana y estructura. No hay sprites de borde/fondo ni variantes por rareza. El tier aparece escrito y el icono, título y descripción tienen tamaño/contraste legible sin recortes.
3. El aura radial animada queda detrás de la superficie y usa color distinto por rareza; se perciben destellos/partículas suaves sin tapar el texto ni el icono. El hover refuerza el aura sin cambiar el panel.
4. Selecciona cartas y confirma que el botón entero recibe la interacción y que el fondo visual no bloquea la lectura o el clic. Reabre y verifica que la oferta conserva sus datos y rarezas.

El código y la documentación de M40 están integrados. No se ejecutaron pruebas ni revisión visual/interactiva en esta actualización; aceptación pendiente. Ver [ADR-0088](DECISION_HISTORY.md#adr-0088).

### M41 Ajustes de base, oclusión, portales y props

#### Revisión manual en ventana

1. Abre un tablero con elevaciones y enemigos en rutas por delante y detrás. La fachada del hex elevado debe ocultar al enemigo tras ella y quedar oculta por el enemigo que pasa delante. Ninguna pared puede tapar una tapa hexagonal; las paredes entre vecinos terminan en la elevación de la tapa vecina.
2. Confirma que la base conserva el PNG fuente 270×352 sin remuestreo y que se dibuja a 1,8 × el radio de huella de ancho por 2,8 × de alto, con el borde inferior visual anclado.
3. Inspecciona todos los portales: el atlas 4×2 recorre los primeros siete frames continuamente y omite el último, duplicado del primero; fases iniciales distintas impiden que dos portales avancen sincronizados. El hover sigue el alfa del frame actual.
4. Revisa varios seeds y celdas con cero, uno y dos props. Cada asset compatible tiene 10 % de probabilidad independiente, el tamaño es 39,6×39,6 px y dos props no se solapan; obstáculos se dibujan a 94,6×94,6 px y por delante.
5. Abre el proyecto con Godot 4.7 y confirma que `TerrainPiecePreview` carga sin errores de parseo en `_apply_base_ring_elevation`.

La implementación M41 está integrada en código y documentación. No se ha ejecutado Godot ni se ha realizado revisión visual/interactiva; aceptación pendiente. Ver [ADR-0089](DECISION_HISTORY.md#adr-0089).

### M42 Contornos compartidos por región de terreno

#### Revisión manual en ventana

1. En un tablero con grupos contiguos de Grass, Mountain y Path, confirma que las aristas internas entre celdas del mismo terreno y altura no se dibujan. El perímetro de cada grupo queda continuo y usa verde para Grass, gris para Mountain y amarillo para Path.
2. Comprueba que los bordes contra celdas de otro terreno, otra altura y vacío se trazan; cuando dos regiones se tocan se ven ambos colores, cada uno dentro de su tapa. El trazo sigue el hex exacto y no tapa props ni caras superiores.
3. Compara el tablero, las copias elevadas Y-sorted y las miniaturas de expansión. Las alturas y los límites deben coincidir; el hover conserva su contorno temporal y las piezas fantasma mantienen el color de colocación legal/ilegal. Revisa las seis esquinas de cada perímetro: las uniones no presentan cortes ni picos separados.

La integración M42 está en código y documentación. La inspección visual/interactiva en Godot queda pendiente. Ver [ADR-0091](DECISION_HISTORY.md#adr-0091).

### M43 Centrado, pulido visual y raíz común de sprites

#### Revisión manual en ventana

1. Criterio histórico de M43: construye cada una de las siete torres en varias celdas y confirma el ancla centrada y el tamaño original +20 %. Esa escala fue sustituida por M53/M54/M55; para la build vigente usa la verificación de M55. Rango, daño, ocupación y selección no cambian.
2. Examina perímetros de varias regiones Grass/Mountain/Path, bordes contra vacío, cambios de altura, superficies Y-sorted y miniaturas. Las líneas deben unirse sin huecos y sus vértices deben verse suaves sin cambiar la forma hexagonal.
3. **Criterio histórico sustituido por M69:** la fachada ya no se acepta por verse oscura ni por un sombreado direccional. Los tonos `#406e4d` Grass y `#646567` Mountain de este milestone corresponden únicamente al contorno de región; los tonos y el gradiente vigentes de las fachadas se comprueban solo en M69.
4. Confirma props de 39,6×39,6 px y obstáculos de 94,6×94,6 px. La probabilidad, distribución por celda y orden de dibujo permanecen iguales.
5. Deja el cursor sobre un portal que vaya a cerrarse, confirma una pieza y comprueba que el tooltip desaparece antes de la siguiente oferta. Observa el loop: usa frames 0–6 y omite el último frame duplicado.
6. Inspecciona `assets/sprites/`: todos los PNG runtime, iconos, enemigos, terreno, interfaz y sidecars `.import` quedan agrupados en subcarpetas por categoría. Confirma que las hojas Tiny Swords locales siguen ignoradas por Git y que `assets/fonts/` y `art_generation/` siguen siendo fuentes aparte.

La implementación M43 y la documentación están integradas. No se ejecutó Godot ni una inspección visual/interactiva; aceptación pendiente. Ver [ADR-0092](DECISION_HISTORY.md#adr-0092).

### M44 Preview exacto, tres cartas y arte de torre (actualizado por M50)

#### Revisión manual en ventana

1. Mueve y rota varias piezas con celdas Grass/Mountain en desniveles, con una o más celdas que auto-rellenen huecos. Compara cada tapa y fachada del ghost con el tablero después de confirmar: altura, textura, obstáculos, props y cofres deben permanecer idénticos.
2. Revisa el contorno de región de terreno Grass/Mountain/Path en tablero, superficies elevadas, hover y miniaturas. Las aristas internas desaparecen; las juntas no tienen huecos ni picos, los extremos son redondeados y el trazo usa un único color plano por terreno: `#406e4d`, `#646567` y amarillo Path.
3. Criterio base de M44: tres cartas, con al menos un reclutamiento elegible y un máximo de dos. El comportamiento vigente (elegibilidad, sorteo ponderado de los otros espacios y persistencia de no elegidas) se acepta con el criterio completo M66; no se usa este apartado como segunda definición de la oferta.
4. Construye Ballista, Mortar, Tesla Coil, Poison Sprayer, Flame Thrower, Frost Keep y Shredder. Cada torre debe usar un único sprite completo sin montaje de partes ni rotación visual, mantener el outline blanco y reflejarse horizontalmente al apuntar a enemigos del lado opuesto. El ghost, la card de construcción y Tower Info deben reutilizar la misma imagen; la fachada conserva Y-sort y alfa completos.
5. Verifica los iconos de los siete tipos en barra, cards y tienda; todos corresponden al sprite nuevo. El séptimo asset se asocia a Shredder, el nombre canónico actual.

La implementación M44 queda integrada en código/documentación. No se ejecutó Godot ni se hizo inspección visual/interactiva; aceptación pendiente. Ver [ADR-0093](DECISION_HISTORY.md#adr-0093).

### M45 Mapa navegable y lectura de altura

#### Revisión manual en ventana

1. Desde el menú abre Mejoras permanentes. Confirma que no existe el pie con instrucciones ni un botón “Empezar nueva run”; el botón × de la esquina superior derecha cierra la tienda y deja visible el menú. Después de perder una run, confirma que la tienda aparece abierta y que el mismo cierre vuelve al menú.
2. Desplaza con rueda en ambos ejes, arrastra con el botón izquierdo una distancia mayor a 8 px y vuelve a probar con el botón central. Verifica que un clic corto todavía selecciona nodos y que el arrastre no compra una mejora al soltar.
3. Recorre todos los nodos generales y de las siete torres: cada uno debe mostrar un icono relacionado, título legible y descripción breve; los tooltips deben conservar descripción completa, coste y requisitos. En cada torre, Health, Armor y Shield se ven en una sola fila debajo del unlock, conectados como alternativas hermanas, sin superponerse con los clusters vecinos.
4. Compara una torre de nivel 1, nivel intermedio y nivel 46. El arte aumenta de forma gradual hasta un máximo discreto de 12 %; la base y cabeza mantienen alineación/pivote. El aumento no cambia daño, alcance, colisión ni celda ocupada.
5. Comprueba una región Grass y una Mountain en elevaciones distintas: las aristas internas de la misma región no se dibujan, los bordes regionales son redondeados y sin huecos, Grass usa únicamente `#406e4d` y Mountain únicamente `#646567`; no debe aparecer keyline ni interior más claro. Hover conserva el mismo color RGB y solo cambia su opacidad. Las fachadas son las dos caras delanteras y respetan la geometría de la tapa; no aparecen costados, cierres de esquina ni cambios de cámara. El color y el gradiente vigentes se comprueban en M69.

M45 está implementado en código y documentado. No se ejecutó Godot ni revisión visual/interactiva; los cinco criterios anteriores siguen pendientes de aceptación manual. Ver [ADR-0094](DECISION_HISTORY.md#adr-0094).

### M46 Contorno de región de terreno y escala de la base

#### Revisión manual en ventana

1. Revisa un borde Grass y uno Mountain con y sin hover, en tablero, copias elevadas y miniaturas. Grass debe usar `#406e4d` y Mountain `#646567` en un único trazo redondeado; no debe aparecer línea de keyline, borde doble ni interior más claro. Path conserva su tono amarillo.
2. Comprueba que el sprite de base mantiene el archivo 270×352 px, se estira a 1,8 × radio de ancho y 2,8 × radio de alto, y crece hacia arriba con su borde inferior anclado. Su huella de reglas y colisiones sigue siendo un hexágono.

M46 está implementado en código/documentación; no se ejecutó Godot ni revisión visual. La aceptación de ambos criterios queda pendiente. Ver [ADR-0095](DECISION_HISTORY.md#adr-0095) y [ADR-0096](DECISION_HISTORY.md#adr-0096).

### M47 Outline de base y enemigos

#### Revisión manual en ventana

1. Comprueba que la silueta visible de la base tenga un outline blanco limpio que siga el alfa de su sprite, comparable al de torres y obstáculos.
2. Recorre varios tipos de enemigo: cada perfil debe tener un contorno pastel claro y distinguible. El contorno debe coincidir con la ilustración durante el movimiento, el cambio de dirección, el salto al recibir daño y una transformación de perfil.
3. Confirma que el outline queda detrás del sprite y que las barras Health/Armor/Shield e iconos de estado se leen encima; al cruzar una fachada, enemigo y contorno deben quedar ocluidos juntos según el orden Y.
4. Usa un perfil DEBUG sin textura para confirmar que el placeholder vectorial conserva un borde claro del tipo asignado o, si no tiene color configurado, el tono de reserva.

M47 está implementado en código/documentación; no se ejecutó Godot ni revisión visual. La aceptación de los cuatro criterios queda pendiente. Ver [ADR-0097](DECISION_HISTORY.md#adr-0097).

### M48 Ajuste de grosor y contorno de portales

#### Revisión manual en ventana

1. Comprueba que el contorno de la base sea visiblemente más fino que el anterior y mantenga un blanco uniforme alrededor de su alfa.
2. Compara varios enemigos con la versión anterior: el borde debe ser solo un poco más ancho, seguir siendo claro y conservar el color asignado por perfil.
3. Coloca varias torres: el borde blanco debe ser fino y uniforme, con `outline_size_px = 6`, sin tapar una parte apreciable del sprite.
4. Observa los portales sin hover: debe verse de forma permanente el mismo borde blanco fino que en los obstáculos. Al hacer hover, marcar una salida candidata o indicar un cierre, conserva su resplandor contextual por encima del borde blanco.
5. Recorre los siete frames del loop y el pulso de los portales; no debe haber saltos del contorno, arte de otra celda ni cambio de tamaño del hitbox.

M48 está implementado en código/documentación; no se ejecutó Godot ni revisión visual. La aceptación de estos criterios queda pendiente. Ver [ADR-0098](DECISION_HISTORY.md#adr-0098).

### M49 Lectura de altura y sombra animada de nubes

#### Revisión manual en ventana

1. Coloca torres en alturas 0–3: la insignia numérica debe estar oculta en reposo y aparecer al pasar el cursor por encima; el indicador del ghost de Ballista sigue visible durante la colocación.
2. Pasa el cursor por celdas en varios bordes de la pantalla. El tooltip debe quedar a 24 px a la derecha y, cuando no quepa, a 24 px al lado contrario; el contenido no debe quedar bajo el cursor ni fuera del viewport.
3. Compara tapas y previews h0–h3: las superficies deben mantener sus texturas y oscurecerse uniformemente por multiplicadores 1,00/0,95/0,90/0,85; el contorno de región y las fachadas no deben cambiar de color ni geometría.
4. Observa al menos una partida durante varios segundos y mueve/zoomea la cámara: el patrón debe seguir anclado al terreno mientras deriva lentamente, con masas irregulares sobre terreno, fachadas, base, torres, enemigos, obstáculos, props y portales. No debe alterar selección, animación, Y-sort ni interacción.
5. Confirma que el velo queda bajo todo el HUD y sigue visible al ocultar el HUD. La UI debe conservar su color y contraste normales.

M49 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0099](DECISION_HISTORY.md#adr-0099).

### M50 Sprite único de torre y tinte de altura

#### Revisión manual en ventana

1. Construye cada torre canónica. Cada una debe aparecer como una sola ilustración con outline blanco; su anclaje queda en el centro del hexágono y el arte se ve ligeramente más abajo (8 px), sin partes que roten de forma independiente.
2. Deja que los enemigos pasen primero por la derecha y luego por la izquierda. La torre mira a la derecha por defecto y usa espejo horizontal para seguir un objetivo a su izquierda; no gira ni se inclina. Comprueba que el disparo sigue llegando al objetivo.
3. Compara la torre colocada, su ghost de construcción, la card de la barra y el retrato de Tower Info: todos deben cargar el mismo PNG completo, sin recortes, y conservar su proporción. El retrato, el nombre y el coste en Gold deben leerse con claridad y aprovechar el panel.
4. Compara tapas y previews de elevación 0–3. El multiplicador RGB debe ser 1,00/0,95/0,90/0,85; el contorno de región y las fachadas conservan color y geometría.

M50 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0100](DECISION_HISTORY.md#adr-0100).

### M51 VFX de combate, estados y feedback de juego

#### Revisión manual en ventana

1. Deja disparar a cada una de las siete torres: debe reproducirse su hoja `shoot` sobre la torre y su hoja `impact` donde ocurre el impacto. Dispara con Mortar y confirma que `tap_ripple` marca la posición objetivo al lanzar el proyectil.
2. Aplica Bleed, Burn, Poison y Slow; también Haste/Fortification en un perfil compatible. Cada uno debe mostrar su spritesheet animado correcto encima del personaje, mantener su contador actual y desaparecer al terminar el estado. El mapeo vigente está en ADR-0101.
3. Sube una torre mediante cada ruta de mejora: `star_burst_gold` y `level_up` deben aparecer sobre ella para la subida manual y la automática por XP. Abre una oferta de cards o una expansión de terreno durante el efecto; la animación debe seguir encima de la interfaz y terminar por sí misma.
4. Deja aparecer un cofre: `item_glow` debe animar detrás del sprite durante toda su disponibilidad. Al abrirlo deben aparecer `coin_burst_gold`, `pickup` y `ui_click`; confirma `coins_top` en cada muerte final de enemigo y `base_hit` sobre la base al recibir daño.
5. Confirma una pieza válida de terreno: `sparkle_twinkle_white_loop` debe aparecer centrado sobre las celdas nuevas y completar dos ciclos. Haz clic en obstacle, portal, torre y base; `ui_click` debe aparecer en el cursor. Termina una run y comprueba `confetti_burst_01` en el menú con la tienda de resultado abierta.
6. Mientras se reproduce cada VFX de mundo (baja, disparo, impacto, daño de base, subida de nivel y colocación), panea con el botón central y cambia el zoom. El efecto debe seguir el mismo punto del mundo que su evento, paneando/zoomeando junto con la celda o actor; no debe quedarse pegado a la pantalla. Comprueba que `ui_click` siga sobre el cursor, que la animación no se congele durante ofertas, terreno o pausa, y que el glow del cofre siga ligado a su celda.

M51 está implementado en código/assets/documentación; la corrección de anclaje a mundo está en código, pero no se ejecutó Godot ni inspección visual/interactiva. Los criterios anteriores, incluido el paneo/zoom durante la animación, quedan pendientes de aceptación manual. Ver [ADR-0101](DECISION_HISTORY.md#adr-0101) y [ADR-0106](DECISION_HISTORY.md#adr-0106).

### M52 Sprites completos de torre, escala y cadencia de feedback

#### Revisión manual en ventana

1. Revisa las siete torres en el tablero, el ghost, las cards de selección y Tower Info. Cada una debe usar su PNG completo, sin cortes ni partes compuestas; debe verse más grande, centrada en la celda y desplazada 8 px hacia abajo. El ghost y la torre construida deben coincidir.
2. Mantén ataques rápidos durante varios segundos. En Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder, el primer `shoot` aparece inmediatamente y los siguientes quedan separados por intervalos aleatorios de 2,0–2,5 s. Ballista y Mortar conservan un efecto por disparo discreto. Comprueba que todos los `impact`, proyectiles, ataques y daños siguen ocurriendo con su cadencia normal.
3. Construye varias torres y retira obstáculos. `pickup.png` debe aparecer una vez en el centro visual de cada acción exitosa; un intento fallido o cancelado no debe mostrar el efecto ni cobrar Gold.
4. Compara las cards (sprite 126×126 px) y Tower Info (152×176 px); los siete PNG deben mantener proporción, transparencia, outline y encuadre completo.

M52 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0102](DECISION_HISTORY.md#adr-0102).

### M53 Escala de torre sin recorte

1. Coloca cada una de las siete torres en terreno plano y elevado. El PNG completo debe quedar visible sin cortes en el tablero; el ghost debe coincidir en tamaño y posición con la torre construida.
2. Confirma que tablero y ghost usan escala 1,32 × 1,12 y offset visual de +8 px, mientras los iconos de la barra de construcción y Tower Info mantienen sus tamaños de UI.

M53 está implementado; su escala 1,32 fue sustituida por M54 y luego refinada por M55. La revisión visual de tamaño vigente se rige por los criterios de M55. No se ejecutó Godot ni revisión visual/interactiva. Ver [ADR-0103](DECISION_HISTORY.md#adr-0103), [ADR-0104](DECISION_HISTORY.md#adr-0104) y [ADR-0105](DECISION_HISTORY.md#adr-0105).

### M54 Reducción adicional de escala de torre

1. Compara torre colocada y ghost en terreno plano/elevado; ambos deben usar escala 1,056 × 1,12, mantener el offset de +8 px y mostrar el PNG completo.
2. Confirma que la reducción de escala es del 20 % respecto a M53 y que cards/Tower Info no cambian de tamaño.

M54 está implementado en código/documentación; su escala 1,056 fue refinada por M55. No se ejecutó Godot ni revisión visual/interactiva. Ver [ADR-0104](DECISION_HISTORY.md#adr-0104).

### M55 Tooltip de spawn, atajos, zoom y panel de Gold

1. Pasa el cursor por cada spawn: no debe aparecer ningún retrato flotante encima del portal. El tooltip debe listar los tipos enemigos asignados, su retrato y el conteo exacto; al quitar el hover debe desaparecer.
2. Inicia una run con Ballista y verifica la tecla `1` tanto en la card como al pulsarla. Recluta otra torre y comprueba que aparece como `2`; recluta más y verifica el orden `1–N` sin huecos. El atajo selecciona la misma torre que su card.
3. Durante colocación de terreno, rueda arriba/abajo debe acercar/alejar la cámara sin cambiar orientación. `Ctrl+rueda` y Q/E deben rotar la pieza. Fuera de colocación, la rueda mantiene el zoom.
4. Compara visualmente el precio de Gold dentro de cada card y el saldo Gold del HUD: ambos usan el mismo panel horizontal 9-slice que Iniciar ronda; el panel cabe en 1440×900 y 1280×720, y Mana permanece legible.
5. En terreno plano y elevado compara torre colocada con ghost. Ambos deben usar escala `0,9504 × 1,12`, mantener el offset visual de +8 px y mostrar el PNG entero. Cards y Tower Info conservan su escala de UI.

M55 está integrado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0105](DECISION_HISTORY.md#adr-0105).

### Loop
- Al completar una oleada de campaña entre las rondas 1–44, se entra en la oferta de expansión y no comienza la siguiente ronda hasta colocar una pieza válida.
- La colocación actualiza el tablero y la ruta una sola vez; la fase de mejora aparece después cuando el calendario de cards la requiere.
- La ronda 45 cierra la campaña al completarse; la victoria/derrota abre el flujo de recompensa y meta-progresión.

### Meta
- Derrota -> XP de perfil.
- Compra persiste tras reiniciar.
- Torre desbloqueada aparece en siguiente run.
- Save corrupto/versión desconocida falla de forma segura.

### UI — migración híbrida (2026-10-10)

#### Smoke de escenas y contratos

Ejecutar `tests/ui_migration_smoke.tscn` en Godot 4.7. Debe completar e imprimir `UI migration smoke: PASS` sin errores de script/escena. El smoke verifica carga/instanciación de `main.tscn`, emisión única del ID `start_wave` por el menú debug, configuración de tarjetas de torre, controles de capa, oferta de tres y cinco cartas, filas de tienda de torre/mejora, cierre de tienda por `close_requested` y filas de tooltip desde `WaveData`. No sustituye la navegación por la partida ni la revisión visual.

#### Revisión visual e interactiva en ventana

1. Abre `game/main/main.tscn` a 1440×900 y después a 1280×720. Compara posiciones, dimensiones, tipografía, iconos, colores, fondos y escalado con la implementación anterior; ningún panel debe quedar cortado ni cubrir Gold/Mana.
2. Usa `Ctrl+K` y cada acción debug disponible. Comprueba que el panel aparece en la misma capa, no bloquea controles fuera de su superficie, emite una sola acción y se cierra/togglea igual. Comprueba que `H` oculta/restaura el HUD como antes.
3. Construye/selecciona una torre, cambia la selección, mejora por Health/Armor/Shield y demuele. Revisa hover, foco, disabled/pressed, el pulso del icono, cantidades/XP/costes y propagación de clics al tablero.
4. Completa una ronda que ofrezca mejoras: abre/cierra la oferta, inspecciona exactamente tres cartas y elige una. Confirma orden, contenido, animación y estado de la run; verifica que el `offer_size` de `CardPoolData` está fijado en 3 y el panel no deja seleccionar botones adicionales.
5. Abre la tienda terminal y cambia entre pestañas. Desplaza listas largas, compra contenido disponible/no disponible, verifica monedas/mensajes, resultado y «Nueva run». Confirma que el guardado y los unlocks conservan el comportamiento anterior.
6. Pasa el cursor por varios puntos de `RoundProgressStrip`. El tooltip debe conservar anclaje/ocultación y total; una sola fila por tipo repetido, mismo retrato y conteo. Comprueba cursor y hover al salir del strip.
7. Selecciona `Main` y expande `ui_icon_catalog`: deben verse las 32 texturas del catálogo, agrupadas por recursos, capas, torres, estados, moneda de perfil y cursor. Cambia un icono de torre y confirma que se refleja en el retrato/cards que consultan el catálogo. Selecciona `TowerShortcut1…7` y `UpgradeHealth/Armor/Shield`; cada instancia debe exponer su `tower_icon_texture` o `layer_icon_texture` y previsualizarla en el `TextureRect` hijo. Comprueba también en esta propiedad los cuatro cursores usados por `BuildCursorOverlay`.
8. Selecciona `StartWave` y las tres `TerrainCard` en `main.tscn`; expande `Theme Overrides > Styles` y comprueba que sus StyleBoxTexture exponen el PNG, nueve cortes, márgenes y tintes de normal/hover/pressed/disabled. Cambia la textura para comprobar la vista previa. Abre `tower_shortcut_card.tscn` y revisa el marco 9-slice del botón.
9. Abre `game/ui/themes/rogue_hud_theme.tres` y edita `Panel`/`PanelContainer`. Las superficies generales son StyleBoxFlat y no usan sprite; los cambios se deben ver en HUD, tienda, oferta y debug sin cambiar su jerarquía.
10. Abre por separado las escenas de componentes en `game/ui/components/` y `game/progression/`. Ajusta tamaños en `custom_minimum_size`, márgenes y separación en sus `Container`, sustituye una textura en el `TextureRect` y confirma que los cambios se reflejan al instanciarlas desde `Main`.

M13 requiere además revisar los estados de selección/build mode del HUD y legibilidad a ambas resoluciones. El smoke headless y el escaneo del editor pasaron en Godot 4.7 el 2026-10-10; la inspección visual, el recorrido funcional completo y la comparación frente al baseline quedan pendientes. Ver [ADR-0049](DECISION_HISTORY.md#adr-0049) y [ADR-0050](DECISION_HISTORY.md#adr-0050).

### Scope
- No existe support building.
- Mana no depende de support building.

### M56 — feedback de progresión, cards y oclusión

1. Aplica estados con acumulaciones a enemigos de campaña: cada sprite de estado debe verse al menos al doble del tamaño anterior (44×44 px), mantener su animación, acumular iconos en una fila legible y conservar el contador de stacks.
2. Revisa enemigos que cruzan junto a fachadas en elevaciones 1–3 y desde ambos lados visibles. La fachada debe cubrirlos cuando están detrás y quedar cubierta cuando pasan delante; el sesgo de empate no debe mover la textura ni abrir juntas.
3. **Criterio histórico, sustituido por M59:** H/A/S se mostraban en una columna; la disposición vigente en una fila se comprueba en M59.
4. **Criterio histórico, sustituido por M60:** las acciones de demolición eran botones cuadrados solo con icono; el texto y los importes actuales se comprueban en M60.
5. Abre cada rama del mapa permanente: todos los nodos tienen un icono que coincide con la torre/efecto; el saldo, coste y recompensa se acompañan de `exp.png` y no aparece texto «XP», «EXP» ni «experiencia» en esa interfaz.
6. Durante varios ataques, compara tiempo hasta subida de nivel automática con la fórmula documentada ×5. Confirma que una subida automática reproduce el mismo `star_burst_gold` y `tower_level_up` que una mejora manual.
7. Pasa el cursor por una mejora de run, una card de terreno y una card de torre. Las tres deben inclinarse y escalar ligeramente, con un brillo radial que sigue el cursor; los clics y la selección deben seguir funcionando.
8. **Criterio histórico, sustituido por M57:** el fondo de agua de M56 era oscuro y de bajo contraste. La apariencia vigente se verifica en la sección M57.

M56 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0107](DECISION_HISTORY.md#adr-0107).

### M57 — agua luminosa y explosión pixel de enemigos

1. Observa el fondo visible alrededor y entre las celdas: debe mostrar grandes manchas orgánicas azul medio/azul claro sobre espuma casi blanca, con movimiento lento y continuo, parecido a la referencia del usuario. Comprueba 1440×900 y 1280×720; el patrón debe conservar escala razonable y cubrir toda la pantalla.
2. Confirma que `WaterBackgroundLayer` permanece por debajo del tablero, las unidades, los VFX y el HUD; el agua no intercepta clics ni altera terreno, hover, selección o zoom de cámara.
3. Mata enemigos con sprites de proporciones y tamaños distintos, incluyendo uno que se mueve hacia la izquierda y uno durante el salto: el burst debe partir del centro visual, mostrar píxeles con los colores del sprite, respetar espejo y escala, y no usar coordenadas desfasadas.
4. Panea y haz zoom mientras el burst está activo: las partículas deben permanecer junto al lugar del mundo donde murió el enemigo. Abre cards/terreno durante la animación: debe terminar por encima de la UI, sin detenerse.
5. Verifica que cada muerte final reproduce tanto `coins_top` como el burst una sola vez y entrega su recompensa solo una vez; una transformación activada al morir no debe generar ninguna baja falsa.
6. Durante bajas simultáneas confirma que cada efecto conserva su propia textura y orientación, el pool reutiliza emisores al terminar y no quedan partículas visibles en la siguiente baja por datos anteriores. Observa el tiempo de GPU con una oleada densa y sprites grandes.

M57 está implementado en código/documentación; no se ejecutó Godot ni revisión visual o de rendimiento. La aceptación queda pendiente. Ver [ADR-0108](DECISION_HISTORY.md#adr-0108).

### M58 — sombra de nubes y agua anclada a cámara

1. En un mapa con terreno visible, compara el sombreado con la versión anterior: las nubes deben notarse un poco más, sin tapar la textura ni cambiar el brillo del HUD.
2. Panea en ambas direcciones: el patrón del agua debe desplazarse junto al mundo y conservar continuidad respecto a las celdas, sin quedarse fijo en pantalla ni flotar sobre el tablero.
3. Cambia el zoom: el agua debe mantener cobertura completa del viewport, acompañar la escala del mundo y no modificar la posición de los controles, el tablero o la simulación.
4. Confirma que agua y sombra siguen debajo del HUD, y que la animación procedural continúa en el tiempo.

M58 está implementado en código/documentación; no se ejecutó Godot ni revisión visual. La aceptación queda pendiente. Ver [ADR-0109](DECISION_HISTORY.md#adr-0109).

### M59 — mejoras de torre en fila y shake de ronda

1. Selecciona una torre: Health, Armor y Shield deben aparecer en una sola fila, centrados y en botones cuadrados de 128 × 128; ninguno debe caer a una segunda fila en el panel de 500 px.
2. Compara los importes H/A/S con los de `TowerShortcutCard`: deben compartir el panel de fondo, el icono de 24 px, el estilo tipográfico y la alineación.
3. Inicia una ronda: la cámara debe mostrar una sacudida muy ligera y continua; al completarla o fallarla, vuelve al offset base. El shake por daño a la base debe seguir viéndose encima de la oscilación y no cancelarla.
4. Durante una pausa, comprueba que no se acumula movimiento ni se reanuda el shake si la ronda ya terminó.

M59 está implementado en código/documentación; no se ejecutó Godot ni revisión visual. La aceptación queda pendiente. Ver [ADR-0110](DECISION_HISTORY.md#adr-0110).

### M60 — barra de XP y precios de demolición

1. Selecciona una torre con XP parcial en Health, Armor y Shield: las tres barras deben medir 88 × 8 px, verse más gruesas y ser más cortas que el ancho anterior; cada una queda centrada bajo el nivel.
2. Selecciona una torre y comprueba que su botón muestra el icono, `DEMOLER` y el importe `+N` con el icono de Gold. Demuele una torre: debe acreditarse el mismo importe que se mostró y el texto no debe incluir niveles ni upgrades.
3. Selecciona un obstáculo: la acción muestra `DEMOLER` y el coste actual como `−N` con el icono de Gold. Tras demolerlo, el siguiente coste debe aumentar según la curva existente.
4. Selecciona un portal: la acción muestra `RETIRAR` y el coste como `−N`, el doble del obstáculo; el botón sigue respetando el mínimo de tres portales y la fase de preparación.

M60 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0111](DECISION_HISTORY.md#adr-0111).

<a id='m61--legibilidad-de-mejoras-hud-y-colocacion-de-terreno'></a>
### M61 — legibilidad de mejoras, HUD y colocación de terreno

1. Abre una oferta de mejoras de run y revisa descripciones con efectos positivos y negativos. Cada cifra positiva debe verse verde y cada perjuicio explícito, como una reducción de daño, rojo. Revisa también mejoras permanentes en el mapa: las cifras de efecto deben conservar esos colores.
2. Selecciona una torre sin mejoras y una torre elevada o mejorada. En Tower Info, Daño, Rango, RPM y Crítico deben compararse con el perfil base: mejoras verdes, reducciones rojas y valores sin cambio con el color normal. Los bonuses de altura y el efecto positivo H/A/S deben verse verdes. Si una mejora reduce el coste de Mana, el coste aparece verde; si lo aumenta, rojo.
3. En `ROUND_PREP` y durante una ronda, pulsa `P` y el botón junto a la vida. El botón debe mostrar solo `P` más el glyph de pausa al jugar y el de play al pausar; ambas acciones deben alternar el estado de pausa.
4. Elige una card de terreno. Debe aparecer sobre las cards de torre el panel prominente `PULSA Q / E PARA ROTAR · T: COLOCACIÓN AUTOMÁTICA`. Comprueba que Q/E rotan, T busca/confirma una posición legal, y el panel desaparece al confirmar o salir de la colocación.
5. Clica un portal: debe aparecer el mismo `ui_click` que al clicar otros interactuables, cerrarse el tooltip y mostrarse en Tower Info la ronda y la lista con retrato, nombre y cantidad asignada a ese portal. Cambia de selección y verifica que la lista anterior no persiste.
6. Compara Gold y Mana en la esquina superior derecha: ambos paneles deben medir 176 × 52 px y usar el mismo fondo 9-slice, separación, iconos de 32 px y cifras de 23 px.
7. Busca `F3` en los controles visibles y pulsa F3 durante la partida: no debe existir ni abrirse ningún panel de terreno/debug. Confirma que la ronda normal sigue el orden secuencial de la campaña de 45 rondas y que la ayuda de colocación de terreno sigue disponible.

M61 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación queda pendiente. Ver [ADR-0112](DECISION_HISTORY.md#adr-0112).

<a id='m62--correcciones-de-paneles-y-pausa-del-agua'></a>
### M62 — correcciones de paneles y pausa del agua

1. Inicia una run desde el menú. La escena debe resolver `%RemovalCostLabel` sin `Node not found` ni advertencias de ruta de padre desaparecida. Inspecciona `main.tscn`: la fila de coste, icono y label debe estar bajo `RemovalCostBadge/RemovalCostRow`, sin nodos huérfanos en la raíz.
2. Selecciona una torre con reembolso y un obstáculo/portal con coste. En cada caso, el botón conserva su icono y texto; el panel Gold aparece como hermano a su derecha, fuera de su superficie.
3. Selecciona una torre. Los iconos Health, Armor y Shield deben quedar centrados en sus botones y medir 64 × 64 px. Cambia el tamaño desde `tower_layer_upgrade_button.tscn` y comprueba que el script no lo sobrescribe.
4. En el Inspector de `Main`, ajusta los parámetros `Tower Info layout`. Comprueba que cambian el ancho y la posición responsivos del panel. Cambia los márgenes del `MarginContainer` y verifica que no se reinician al iniciar ni al cambiar la selección.
5. Durante `ROUND_PREP`, clica cada portal. Tower Info debe mostrar el título, ronda, cantidad de enemigos y lista de retratos/nombres/conteos de esa salida; no depende de mantener el cursor encima.
6. Inicia la ronda, pausa con `P` y confirma que el patrón del agua deja de animarse; al reanudar, continúa sin salto de fase.

M62 está implementado en código/documentación; no se ejecutó Godot ni revisión visual/interactiva. La aceptación de escena queda pendiente. Ver [ADR-0113](DECISION_HISTORY.md#adr-0113).

<a id='m63--alcance-ghost-exacto-y-mapa-de-mejoras'></a>
### M63 — alcance, ghost exacto y mapa de mejoras

1. Coloca una torre en una casilla elevada y otra a nivel de suelo. Al pasar el cursor sobre cada torre y al seleccionarla, el anillo visible debe coincidir con el alcance efectivo del panel.
2. Selecciona una torre para construir y pasa por casillas de elevación distinta. El daño, el alcance del panel, el badge del ghost y su círculo deben coincidir con los valores efectivos tras colocarla, incluyendo cartas activas.
3. Compara una oferta de terreno legal con una ilegal. El ghost debe leerse inmediatamente en lima para válida y rojo para inválida, incluso encima de la textura del terreno.
4. Termina una run usando al menos dos tipos de torre y deja otro tipo desbloqueado sin construir. El resumen debe agrupar cantidad y daño de los tipos construidos, y omitir el tipo sin desplegar.
5. Abre el mapa permanente. Los siete unlocks de torre deben compartir una fila horizontal. Al abrir un unlock, Health, Armor y Shield deben aparecer en una línea horizontal, conectados por separado y poder comprarse en cualquier orden.
6. Revisa nodos generales, torres y capas de mejora: todos deben tener un icono temático. En los nodos con coste, el importe grande queda centrado y el icono `exp.png` a su derecha, alineado en la misma fila.

M63 queda implementado en código/documentación. El smoke de carga headless realizado para M64 no valida el alcance, el ghost ni el mapa durante gameplay; la aceptación visual/interactiva sigue pendiente. Ver [ADR-0114](DECISION_HISTORY.md#adr-0114).

### M64 — interfaz editable desde Inspector y limpieza

1. Ejecuta la escena principal y cambia en el Inspector los grupos exportados de Main para Tower Info, lista/tooltip de portales, inventario/ofertas de terreno, colores semánticos, botón de ronda y tamaños tipográficos. Repite inicio, selección de torre/portal, cambio de fase y actualización de filas: los valores deben persistir y no volver a una constante del script.
2. Abre `upgrade_offer_panel.tscn`, `upgrade_offer_card.tscn`, `tower_layer_upgrade_button.tscn`, `meta_progression_map.tscn`, `meta_upgrade_node.tscn`, `round_progress_strip.tscn`, `spawn_portal.tscn` y `main_menu.tscn`; en `main.tscn`, selecciona además `BaseHealthBar` y `BuildCursor`. Modifica un margen, tamaño, fuente, color o StyleBox desde Inspector y ejecuta la escena; la presentación debe reflejar la propiedad guardada. Revisa que el estilo no se reconstruya en `_ready()`.
3. Cambia dimensiones y tipografías de la oferta de mejora y el mapa permanente. Ajusta en `Main` los tamaños de VFX; cambia en `BuildCursor` su tamaño/pulso y en el mapa colores/tamaño/vida de partículas. Verifica anclajes, centrado, enlaces, tooltips y selección a 1280×720 y 1440×900. Los layout de progreso, portal, cards de terreno y feedback H/A/S deben seguir las propiedades expuestas en sus escenas/scripts.
4. En combate, confirma que los iconos de estado se dibujan a 28×28 px, separados 5 px, con stack count y barras alineadas. Revisa que la fuente y el contorno de los números flotantes de daño se controlan desde el nodo Enemy.
5. Ejecuta el escaneo de escenas/código de Godot y la entrada normal a `game/main/main.tscn`; no deben aparecer recursos faltantes, errores de parseo ni nodos no encontrados tras retirar fixtures y script de preview.
6. Comprueba los importes en los `.import`: iconos UI a 256 px, spritesheet de portal a 768 px y cofre a 168 px. Confirma que los PNG fuente no cambiaron, los 26 PNG alternativos y los recursos retirados ya no están en disco, y los perfiles `8`, `9` y `0` siguen cargando.

El escaneo headless del editor y el smoke de tres frames de `game/main/main.tscn` pasan con código 0, sin errores GDScript ni recursos faltantes. El entorno aislado impidió guardar el inicio de run de prueba. M64 queda aceptado tras completar la revisión en ventana y confirmar que los cambios del Inspector sobreviven al ciclo de vida de los controles. Ver [ADR-0115](DECISION_HISTORY.md#adr-0115).

### M65 — spritesheets de correr de enemigos

1. Inicia una ronda y comprueba los 26 tipos de enemigo al aparecer: todos muestran su ciclo de correr desde el primer instante en que entran al camino, sin quedar en una pose estática mientras se mueven.
2. Revisa que cada hoja canónica mide 512×128 px, contiene cuatro cuadros horizontales de 128×128 px y conserva transparencia alrededor del personaje.
3. Recorre tramos de camino que cambien la dirección horizontal: las imágenes originales miran a la derecha y se espejan al avanzar hacia la izquierda, sin invertir el ciclo ni afectar la ruta.
4. Compara enemigos pequeños, medianos y jefes: el personaje debe quedar centrado, alineado a su base y conservar el tamaño visual configurado en su `EnemyData`.

Las hojas están en sus rutas canónicas y el runtime existente selecciona cuatro cuadros a 8 FPS durante `MOVING`. La revisión en ventana Godot queda pendiente. Ver [ADR-0116](DECISION_HISTORY.md#adr-0116).

### M66 — Oferta aleatoria de reclutamientos y mejoras

1. En la primera oferta de una run con Mortar/Tesla Coil desbloqueadas, comprueba que aparece al menos uno de sus reclutamientos y que los otros dos espacios pueden ser cartas globales o pasivas de Ballista. Debe haber exactamente tres cartas distintas y nunca más de dos reclutamientos.
2. Con varias torres pendientes, repite ofertas/runs: el reclutamiento obligatorio debe poder variar según los pesos/seed; reclutamientos adicionales pueden aparecer en cualquiera de los otros espacios, pero nunca llenan la oferta.
3. Antes de reclutar una torre, sus pasivas específicas siguen ausentes. Tras reclutarla, comprueba que pasan a ser elegibles en ofertas futuras. Las pasivas de torres no reclutadas siguen ausentes; las globales y las pasivas de torres ya reclutadas pueden ocupar los espacios aleatorios.
4. No elijas uno de los reclutamientos disponibles y abre otra oferta en una ronda posterior: debe seguir elegible. Comprueba también una oferta sin torres pendientes, que debe sortear tres cartas normales.

M66 queda aceptado cuando se verifican garantía condicional, límite de dos reclutamientos, mezcla ponderada sin reemplazo, filtros de run y persistencia de no elegidas. Código/documentación integrados; aceptación interactiva pendiente. Ver [ADR-0118](DECISION_HISTORY.md#adr-0118).

### M67 — Feedback de vida de Main Tower

1. En la escena principal, compara la barra de base con la versión previa: pasa de 28 a 42 px de alto y dispone de una fila superior más ancha. La pausa sigue legible junto a ella.
2. Con una base de 10 HP y también con un máximo ampliado por Fortification/cards, confirma que cada HP ocupa un cuadro propio. Al perder un punto, el cuadro perdido hace flash y se encoge/desvanece; al recibir varios puntos de daño, cada cuadro perdido se anima. Curar o reparar repone los segmentos.
3. Observa el relleno con la base completa, a media vida y casi vacía: el color debe cambiar gradualmente de verde a ámbar y rojo, sin saltos entre solo tres colores planos.
4. Al llegar a 3 HP, aparece una viñeta roja tenue en los bordes; a 2 HP se intensifica y a 1 HP se vuelve más clara, con respiración lenta y sutil (aprox. 2,8 s). El centro de juego, los textos y los controles siguen legibles. Comprueba que desaparece al sanar por encima de 3 HP y que la run sigue cómoda durante varios minutos a 1 HP.

M67 queda integrado en código/documentación. La inspección visual e interactiva en Godot sigue pendiente; no se ejecutó Godot en este cambio. Ver [ADR-0119](DECISION_HISTORY.md#adr-0119).

### M68 — Velocidad de simulación de la partida

1. En la escena de juego, confirma que el nuevo botón queda junto al de pausa y muestra ×1 al iniciar.
2. Pulsa sucesivamente el botón: debe pasar a ×2, luego ×3 y volver a ×1. El mundo, enemigos, torretas y temporizadores de ronda deben avanzar con el multiplicador visible.
3. Pausa en ×2 y ×3. El juego debe detenerse y, al reanudar, continuar con el multiplicador elegido antes de pausar.
4. Vuelve al menú e inicia otra run. Debe comenzar en ×1 sin heredar el multiplicador de la run anterior.

M68 queda integrado en código/documentación; la inspección visual e interactiva queda pendiente. No se ejecutó Godot. Ver [ADR-0120](DECISION_HISTORY.md#adr-0120).

### M69 — Color y gradiente de las fachadas elevadas

1. En la partida, revisa las fachadas Grass y Mountain: su borde superior debe mostrar los colores `#407850` y `#3b3c41`, respectivamente; no deben verse casi negras en toda su altura.
2. Revisa la transición vertical de cada pared: el negro se ve en la base y su alfa desaparece progresivamente hasta transparente en la parte superior. La tapa no recibe este sombreado.
3. Compara tablero, ghost/preview de expansión y miniaturas de cartas. Los colores y el gradiente deben coincidir en las tres presentaciones, sin cambiar el contorno, altura ni oclusión Y-sort de las paredes.

M69 queda integrado en código/documentación; la revisión visual en Godot queda pendiente. No se ejecutó el motor. Ver [ADR-0121](DECISION_HISTORY.md#adr-0121).

<a id='doc-audit'></a>
## Auditoría de coherencia documental actual

- Fecha: 2026-10-15.
- Alcance: índices, diseño activo, roadmap, progreso, aceptación, ADR, catálogos de sprites y reglas runtime de elevación.
- Autoridad documental: [índice maestro](README.md#index). Esta página registra los resultados de la conciliación; no introduce reglas adicionales.

### Resultado

La documentación activa tiene un propietario por tema: diseño global, arquitectura, modelos, terreno, combate y progresión en [Especificación del proyecto](PROJECT_SPEC.md); nomenclatura, roster y campaña en [Contenido y assets](CONTENT_AND_ASSETS.md); estado, roadmap y criterios de aceptación en este documento. Los ADR conservan las razones e historia de los cambios. La [documentación](README.md#index), el README raíz y `AGENTS.md` explican la jerarquía y remiten a los mismos propietarios.

**Consolidación documental (2026-10-15):** los Markdown de diseño, auditoría, referencias, arte, backlog e historial se reunieron en cinco documentos temáticos. Se retiraron 164 archivos Markdown antiguos; el contenido histórico se conserva etiquetado dentro de los documentos consolidados. El proyecto queda con ocho Markdown de documentación, incluidos README y AGENTS; no se modificó código ni contenido runtime.

Los ADR conservan las razones e historia de los cambios. No prevalecen sobre el diseño propietario actual; los snapshots, referencias, proceso artístico y backlog se marcan como no normativos. El informe [M64](#m64-audit) queda preservado como fotografía anterior a M65–M69.

### Cambios conciliados

- **Estado:** M65–M69 aparecen en roadmap, progreso, aceptación e índice. El último escaneo/smoke de Godot registrado sigue siendo M64; no se atribuye validación de motor a cambios posteriores.
- **Elevación:** por la decisión explícita del usuario, `AGENTS.md`, ADR-0073, código y documentos propietarios coinciden en elevación lógica 0–3: PATH 0, Grass 1–2 y Mountain 2–3. La generación reproducible, validadores y bonus por nivel permanecen alineados.
- **Enemigos:** M65 mantiene los 26 spritesheets runtime y el orden/nombres confirmados en ADR-0116. La carpeta `assets/sprites/enemies/new/` no existe en el checkout, aunque varios documentos anteriores la daban por conservada; el inventario ya indica que las fuentes originales no están disponibles localmente.
- **Fachadas y terreno:** los valores de M69 (#407850 Grass y #3b3c41 Mountain con negro opaco abajo a transparente arriba) se alinean entre diseño, implementación documentada, criterios y catálogo de sprites. Los colores del contorno regional permanecen separados.
- **Referencias:** se corrigieron enlaces a ADR con nombre equivocado, README de terreno en ruta obsoleta y destinos de auditoría; se retiró la referencia a un README de fuentes de enemigo inexistente.

### Comprobaciones y límites

- El escaneo del checkout encontró 130 PNG bajo `assets/sprites/` y 26 PNG canónicos de enemigo bajo `assets/sprites/enemies/`; no encontró `assets/sprites/enemies/new/`.
- Se revisaron los enlaces Markdown locales y `git diff --check`: no hay destinos locales rotos ni errores de whitespace.
- No se ejecutó Godot ni pruebas automatizadas en la conciliación funcional anterior. La aceptación visual/interactiva de M65–M69 sigue pendiente según `IMPLEMENTATION_AND_QA.md#progress` y `IMPLEMENTATION_AND_QA.md#acceptance`.

<a id='m64-audit'></a>
## Snapshot de verificación M64

> **Snapshot histórico, no estado actual:** este informe se cerró en M64 antes de M65–M69. Para el estado vigente consulta el [índice maestro](README.md#index), [Progreso](#progress) y la [conciliación actual](#doc-audit).

- Fecha: 2026-10-15.
- Alcance: fuente de diseño, roadmap, progreso, aceptación, ADR, código GDScript/escenas/Resources y sprites del checkout actual.
- Base observada: Godot 4.7 estable; checkout con cambios locales M63/ADR-0114 preservados y los cambios de limpieza M64/ADR-0115 aplicados encima. No se crearon commits.
- Verificación: el escaneo headless del editor Godot 4.7 terminó con código 0 sin errores GDScript ni recursos faltantes; `game/main/main.tscn` arrancó headless tres frames con código 0. El sandbox impidió guardar el inicio de la run de prueba y las preferencias del editor; la aceptación visual/interactiva en ventana y la persistencia de cambios del Inspector siguen pendientes.

### Conclusión ejecutiva

No estás en M12, M13 ni M14. El último hito local ahora es **M64 — UI editable desde Inspector y limpieza de recursos**; M63 (alcance, ghost y mapa de mejoras) se conserva como el cambio local anterior. M12 y M13 están implementados en código; M14 sigue parcial y con aceptación pendiente. M63 y M64 están integrados en el checkout, pero aún no se han aceptado visualmente/interactivamente.

La documentación ya está centralizada bajo `docs/rogue_tower/`; `docs/` no contiene otro árbol activo. El índice de autoridad es claro: el diseño aprobado vive en `PROJECT_SPEC.md#game-design`, las reglas se desarrollan por tema y el código/Resources describen la implementación. M64 alinea las referencias activas a fixtures retirados, actualiza la auditoría de sprites y registra el estado del Inspector; el historial de ADR/importación se conserva como histórico.

### Fase real y trabajo que falta

| Área | Estado observado |
|---|---|
| M12 — meta-progresión | Implementada en código; aceptación manual pendiente según `IMPLEMENTATION_AND_QA.md#progress`. |
| M13 — UX/UI | Implementada y refinada en hitos posteriores; aceptación visual pendiente. |
| M14 — vertical slice | Parcialmente implementada; falta recorrer la demo y aceptar interacciones en ventana. |
| M56–M62 | Implementados y registrados en progreso/ADR; aceptación visual, interactiva o de escena pendiente según cada hito. |
| M63 — alcance y mapa | Cambios locales preservados; falta pasar los seis criterios visuales/interactivos. |
| M64 — Inspector y limpieza | Escaneo headless y smoke de la escena principal pasados; falta aceptar las propiedades del Inspector visualmente e interactivamente. |
| Campaña | Diseño activo de 45 rondas. `CONTENT_AND_ASSETS.md#campaign` es la autoridad de composición; los datos/runtime son la autoridad de lo que se ejecuta. |

El siguiente paso es completar M63 y M64 visualmente en ventana, incluyendo verificar que los valores del Inspector persisten tras iniciar/actualizar cada interfaz. Después sigue el orden de revisiones anotado en `IMPLEMENTATION_AND_QA.md#progress`: M62/M55, M50/M49/M48/M47/M45/M41 y los hitos anteriores. También faltan recorridos de campaña hasta 45/45, terreno y medición de rendimiento de la ráfaga GPU M57. M7 es histórico; las capas de daño se aceptan en M12A.

No encontré marcadores `TODO`, `FIXME` o `NotImplemented` en los scripts. El trabajo pendiente se expresa en progreso/aceptación, no mediante TODOs de código. Los valores de balance, algunos efectos propios, el arte final y varios parámetros configurables siguen provisionales por decisión del proyecto.

### Discrepancias y aclaraciones

#### 1. El roadmap llegaba a M55

`IMPLEMENTATION_AND_QA.md` terminaba en M55, mientras progreso, aceptación, arquitectura y ADR ya llegaban a M63. Se añadieron hitos M56–M64 y se marcaron como históricos los procedimientos de M7/M8 que dependían de las oleadas eliminadas.

#### 2. La arquitectura tenía datos anteriores a M61/M63

`PROJECT_SPEC.md` contenía reglas anteriores a M61/M63 y describía fixtures DEBUG que ya no tienen runtime. Ahora refleja panel compartido Gold/Mana, cálculo efectivo para cualquier torre, resumen por torres desplegadas y retirada de fixtures M7/M8.

#### 3. El texto sobre el anillo de selección quedó obsoleto

Una regla previa de `PROJECT_SPEC.md` decía que el sprite no mostraba círculos de selección. M63 añade un anillo de alcance efectivo al hacer hover o seleccionar la torre. Se aclaró que es un radio de alcance, no un círculo decorativo, y se enlazó con ADR-0114.

#### 4. M61 quitó el inspector F3, pero se conserva un menú Ctrl+K

El código ya no escucha F3 ni permite seleccionar fixtures M7/M8 desde la interfaz habitual. `Main` todavía instancia `game/ui/debug_hacks_panel.tscn` y abre `DebugHacksPanel` con Ctrl+K; conserva acciones de preparación de sesión. Además, `8`, `9` y `0` seleccionan Armor Piercing Bolt, Sapping Bolt y Status Probe. M64 conserva intencionadamente esos perfiles y el panel Ctrl+K; la aceptación de M61/M64 debe distinguirlos del panel F3 y del selector de oleadas que sí se retiraron.

Los procedimientos de M7/M8/M9/M9.5/M12A se reescribieron: las oleadas/dummies inexistentes se marcan como historial, y la verificación actual usa enemigos de campaña y los perfiles de torre que siguen activos. También se añadió una lista de aceptación específica M64.

#### 5. Cambios locales de M63

Los cambios locales M63 están representados en `01`, `03`, `09`, `10`, `16` y ADR-0114: radio visible, preview efectivo para elevación/modificadores, validez de terreno más contrastada, resumen por torres desplegadas y mapa H/A/S paralelo. Se preservaron; M64 añadió configuración Inspector y limpieza sobre los mismos archivos cuando era necesario, sin revertir los cambios M63.

### Funciones sin referencias estáticas

La auditoría estática previa encontró 26 métodos candidatos que solo tenían definición; se retiraron en M64 tras comprobar referencias en scripts, escenas y Resources:

- `autoload/meta_progression.gd`: `get_last_run_summary`, `get_best_round_reached`, `get_unlocked_tower_ids`.
- `game/waves/wave_director.gd`: `get_pending_spawn_count`, `_get_spawn_routes`.
- `game/combat/health_component.gd`: `get_health_ratio`.
- `game/enemies/path_follower_component.gd`: `get_waypoint_index`, `get_waypoints`.
- `game/enemies/enemy.gd`: `get_total_current_hit_points`, `get_total_maximum_hit_points`, `get_armor_regen_per_second`, `get_shield_regen_per_second`, `get_regen_counter_time_left`, `get_effective_regen_per_second`.
- `game/build/build_controller.gd`: `get_active_tower_data`, `set_selected_targeting_mode`, `set_selected_targeting_priority`.
- `game/cards/run_card_service.gd`: `get_selected_cards`, `get_offer_size`.
- `game/towers/tower.gd`: `is_mana_blocked`, `get_targeting_mode`, `get_damage_tag_name`, `get_targeting_mode_name`.
- `game/board/terrain_piece_preview.gd`: `set_rotation_steps`.
- `game/board/path_route.gd`: `get_edge_count`.
- `game/board/path_graph.gd`: `get_reachable_node_count`.

Se retiró aparte `game/board/spawn_portal_preview_layer.gd` y su UID porque no tenía instancias; la función `set_entries` solo pertenecía a ese script. Las búsquedas estáticas no cubren llamadas externas/reflexión; no se afirma que toda función pública en el proyecto carezca de uso.

### Sprites y otros recursos visuales

`CONTENT_AND_ASSETS.md#sprite-audit` está actualizado: hay **130 PNG** en disco, incluidos cuatro cursores Tiny Swords locales ignorados por Git, y los 130 tienen uso runtime localizado. Los 26 PNG alternativos de `assets/sprites/enemies/new_enemy/` y `assets/sprites/ui/tower_info_panel_frame.png` se eliminaron. Los 25 iconos UI importan a un máximo de 256 px, el portal a 768 px y el cofre conserva 168 px; los PNG fuente no se redimensionaron. Una búsqueda simple por basename no encuentra las hojas `shoot`/`impact` de Cozy Chunky porque `Main` genera sus rutas dinámicamente; esas rutas están en uso. No se conocen `.import` huérfanos tras la limpieza.

También se retiraron ocho Resources de demo sin consumidores: `data/enemies/cyclops_demo.tres`, `werewolf_demo.tres`, `armored_regenerator.tres`, `status_training_dummy.tres`, `tower_layer_training_dummy.tres`; `data/waves/m7_damage_test.tres`, `m8_status_test.tres` y `tower_layer_training_wave.tres`. Permanecen `armor_piercing_bolt.tres`, `sapping_bolt.tres` y `status_probe_m8.tres` porque el juego aún los carga con `8`, `9` y `0`; `basic_bolt.tres` sigue siendo fixture de `tests/m6_tower_smoke.gd`.

### Interfaz editable

M64 mueve propiedades visuales de la UI a su fuente editable. `Main` expone configuración de Tower Info, filas/tooltip de enemigo y portal, inventario/ofertas de terreno y tipografías dinámicas. Las escenas de `upgrade_offer_panel`, `upgrade_offer_card`, `tower_layer_upgrade_button`, `meta_progression_map`, `meta_upgrade_node`, `round_progress_strip` y `spawn_portal` guardan jerarquía, StyleBoxes, materiales, fuentes y geometría; `Enemy` expone la presentación de barras, estados y daño flotante. El código cambia contenido/estado, pero no debe reinstalar estilos o tamaños estáticos al iniciar. No se ha declarado que toda cifra de lógica del juego sea configurable: el alcance de M64 son los parámetros de presentación enumerados en ADR-0115.

### Mantenibilidad observada

`Main` continúa coordinando fases, controles, HUD, terreno, economía y VFX; M64 reduce los overrides visuales ocultos pero no refactoriza esa coordinación. Sigue siendo el mayor punto de acoplamiento y conviene separar presentación/HUD en una tarea futura, después de aceptar M63/M64, manteniendo los contratos cubiertos por las suites actuales.

### Decisiones y contenido todavía abiertos

- Balance final configurable de Ooogie von Ooogovich, Tesla Coil y parámetros de caída/contacto de Frost Keep.
- Balance propio para el reparto entre varias entradas.
- Regla de overkill y ajustes finales de críticos, rarezas, economía y escalado.
- Arte/tema final, roster posterior a 45 rondas, nuevas familias/jefes, árboles de progreso completos, Freeze y sinergias no promovidas.
- Más contenido y pruebas de campañas posteriores.

Estos puntos están diferenciados en el diseño y en `BACKLOG.md#candidates`; no son bugs ni sistemas que haya que añadir a esta demo por defecto. Support buildings, crafting, inventario de objetos, héroes y PvP están expresamente fuera de alcance.

### Siguiente orden recomendado

1. Completar la aceptación en ventana de M64 (persistencia de cambios en Inspector y legibilidad a dos resoluciones) y después la aceptación visual/interactiva M63.
2. Continuar el orden pendiente de `IMPLEMENTATION_AND_QA.md#progress`; revisar M62/M55 y los cambios visuales M50/M49/M48/M47/M45/M41. Medir rendimiento de M57 durante una oleada densa.
3. Completar la cobertura manual de M8–M14 y M17–M24 usando campaña activa, no fixtures eliminados; luego recorrer la campaña completa hasta victoria/derrota.
4. Tras aceptar los cambios actuales, valorar dividir la presentación de `Main` por responsabilidad. Mantener balance configurable/provisional y registrar las decisiones que el usuario confirme en ADR y páginas temáticas.

Esta auditoría describe el estado observado en la fecha indicada. El código/Resources siguen definiendo lo que corre; los ADR y el diseño activo definen lo que se quiere conservar. Si vuelven a diferir, registra el estado y la resolución en Progreso/Aceptación antes de dar el cambio por cerrado.

<a id='import-audit'></a>
## Auditoría importada, solo histórica

- Fecha: 2026-10-09.
- Alcance: cuatro borradores personales, paquete de diseño importado, ADR existentes y comprobaciones dirigidas a los datos actuales de campaña, roster y desbloqueos.
- Resultado: los materiales quedaron bajo `docs/rogue_tower/`. El índice [README](README.md#index) fija cómo resolver discrepancias y qué autoridad tienen sus subcarpetas.

> **Auditoría histórica:** este informe describe el estado documental previo a la campaña de 45 rondas y queda sustituido en reglas activas por ADR-0037. Su fila sobre upgrades también es anterior a [ADR-0062](DECISION_HISTORY.md#adr-0062), que promueve las 173 entradas compatibles de cartas y las mejoras permanentes. Para los criterios vigentes, sigue README.md y los documentos enlazados allí.
### Comparación por fuente

| Fuente anterior | Qué aporta | Resultado de la comparación |
|---|---|---|
| `borradores_personales/01_torres.md` | Arquetipos, sinergias, multiplicadores y progreso de torres de Rogue Tower. | Conservado como [referencia](CONTENT_AND_ASSETS.md#reference-towers). Los siete perfiles usan nombres canónicos y adoptan los parámetros base de la referencia, con cambios oficiales en ADR-0036. Los árboles completos y reglas de progreso propias no se importan. |
| `borradores_personales/02_monstruos.md` | Tablas de aparición, atributos y poderes, incluidos tres jefes Tier 2. | Conservado como [referencia](CONTENT_AND_ASSETS.md#reference-enemies). La campaña prepara el roster normal publicado hasta ronda 20, incluyendo Vampire desde la 20. Cyclops 17, Werewolf 19 y Ooogie von Ooogovich 20 conservan encuentros propios. Los conteos/grupos de cada oleada no aparecen en la fuente consultada; quedan pendientes, no inventados. |
| `borradores_personales/03_upgrades.md` | XP, mejoras permanentes y árboles de cartas del juego de referencia. | Conservado como [referencia](CONTENT_AND_ASSETS.md#reference-upgrades). La meta-progresión propia usa moneda persistente, tienda y cinco upgrades actuales; las cartas de run tienen pool propio de 18 Resources. Los árboles, XP, costes y cifras externos no se han promovido. |
| `borradores_personales/04_status_effects.md` | Bleed, Burn, Poison, Slow, Freeze, Haste, Fortification y sinergias. | Conservado como [referencia](CONTENT_AND_ASSETS.md#reference-effects). El juego propio maneja Slow, Burn, Bleed y Poison. Freeze, Haste y Fortification siguen como candidatos, no parte del catálogo aprobado. Las reglas propias de capa y bonus están en ADR-0023. |
| `fuente_de_verdad/` | Diseño inicial, contratos técnicos, roadmap, progreso, aceptación y un JSON duplicado. | Sus documentos activos pasaron a [design](README.md#index), con actualizaciones para incorporar decisiones posteriores. `project_spec.json` y los auxiliares importados están en `archive/initial_import/`; el JSON no es una especificación activa ni una fuente runtime. |
| `decisiones/` | Historial técnico y de diseño desde ADR-0001. | ADR-0001 a ADR-0031 se conservaron en [decisions](DECISION_HISTORY.md#decision-index); ADR-0032 incorpora la identidad y fase del jefe y ADR-0033 la nomenclatura canónica. Los ADR históricos siguen explicando su contexto, y los reemplazos parciales quedan enlazados. |

### Discrepancias encontradas y tratamiento

1. **Identidad y ciclo del jefe final:** diseño inicial y ADR-0016 mantenían abierta la variante, mientras el perfil activo conserva estadísticas genéricas provisionales. La elección del usuario resuelve la identidad y las mecánicas adaptadas: Ooogie invoca Bats y, al perder su forma inicial, pasa a Bat como fase dos. No se copia la frecuencia/cantidad de invocación ni los 10 000 Health de la referencia. La recompensa espera la derrota final. Diseño aprobado; balance propio, Resource de dos fases e implementación siguen pendientes.
2. **Torres desbloqueadas:** el cierre de `CONTENT_AND_ASSETS.md#initial-content` afirmaba que los siete perfiles ya estaban desbloqueados. `data/meta/demo_meta_progression.tres`, los Resources de torre y el contrato de tienda indican que Ballista comienza desbloqueada y las otras seis se compran. Se corrigió el documento para distinguir “siete perfiles en el roster” de “siete disponibles al empezar”.
3. **Jefe aprobado frente a perfil ejecutable:** `data/enemies/campaign_tier2_boss.tres` aún contiene estadísticas provisionales de M10 y no demuestra invocación ni fase Bat. El nombre visible ya es Ooogie von Ooogovich; su Resource de dos fases y balance propios siguen siendo bloqueadores de M10.
4. **Progreso frente a alcance de diseño:** varias páginas describían como pendiente la identidad de variante aunque M10 ya estaba implementado con un placeholder. Se actualizó la distinción: identidad y patrón del jefe aprobados; balance e integración pendientes. El estado “implementado” no implica aceptación visual ni balance final.
5. **Borradores frente a fuentes aprobadas:** los cuatro textos personales contenían reglas confirmadas propias mezcladas con tablas comunitarias. Permanecen disponibles con atribución bajo `references`; las elecciones explícitas (incluidos los parámetros base de torres y enemigos hasta la ronda 20) enlazan al diseño activo. Árboles completos, poderes no elegidos y contenido fuera del alcance están en el [backlog](BACKLOG.md#candidates).
6. **Jerarquía antigua:** `AGENTS.md` daba precedencia general al paquete importado. Se actualizó para que decidan las elecciones posteriores del usuario, que el paquete sea el punto de partida y que el código/Resources indiquen implementación, no autoridad de diseño.

### Pendientes que siguen siendo decisiones reales

- Habilidades detalladas e implementación de Cyclops y Werewolf como Minibosses; la selección de sus nombres por rol está resuelta por ADR-0033.
- Atributos y balance propio de Ooogie y sus Bats, incluido número/frecuencia de invocación, estadísticas por fase, recompensa y reglas de spawn/muerte.
- Roster de enemigos y sistemas de progresión posteriores a la demo.
- Composición y totales exactos de cada oleada; la página Monsters consultada publica cuándo empiezan a aparecer los tipos, pero no enumera cantidades por oleada. Hace falta otra fuente verificable o aprobar una curva propia.
- Si el juego propio incorporará Freeze, Haste o Fortification y qué contrato tendrían.
- Aceptación manual de los milestones que `IMPLEMENTATION_AND_QA.md#progress` marca pendientes.

El material de referencia que podría informar estas elecciones, con sus preguntas pendientes, se concentra en [Content Candidates](BACKLOG.md#candidates); no se presupone que haya que adoptarlo.
