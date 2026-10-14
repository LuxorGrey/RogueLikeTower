# Roguelike Progression

## Dos capas

### Dentro de la run
- construcción;
- upgrades de torre;
- mapa;
- Gold de construcción (saldo temporal de `RunEconomyService`);
- Mana (saldo temporal, capacidad y regeneración configurables);
- cartas;
- status/build synergies.

### Entre runs
- XP de perfil (`MetaProgression.meta_currency`, persistente y separada del Gold de construcción; se conserva ese nombre interno para no invalidar guardados versión 1);
- tienda;
- desbloqueo de torres;
- mejoras permanentes.

Los desbloqueos permanentes de una instalación nueva son Ballista, Mortar y Tesla Coil, pero el roster temporal de construcción empieza únicamente con Ballista. Tras la expansión de la ronda 3, la primera selección programada incluye reclutamientos de Mortar y Tesla Coil. Una torre desbloqueada permanentemente puede aparecer en las siguientes ofertas como reclutamiento; al elegir su card se añade al roster de esa run y se habilitan sus cartas de mejora. No se puede construir una torre que no se haya reclutado en la run. Frost Keep, Flame Thrower y Poison Sprayer cuestan 50 XP de perfil cada una; Shredder cuesta 100. El hack de reinicio de prueba restablece los unlocks a las tres torres iniciales, pone a cero las mejoras permanentes y devuelve el XP gastado en ellas. El saldo XP no gastado se conserva. La fórmula propia de XP ganada por run sigue configurable; no se importa la fórmula de Rogue Tower. Ver ADR-0069/0076.

Cada run comienza con 1.000 Gold de construcción. Starting Coffers suma +100 Gold por nivel permanente hasta +1.000, para un máximo de 2.000 al nivel X. El Gold no se persiste y se mantiene separado del XP de perfil. Al perder, el juego pasa al menú principal con la tienda abierta; al pausar con Escape, la escena permite reanudar o volver al menú. Volver desde pausa abandona la run sin cobrar la recompensa de derrota. El resumen final agrupa torres construidas y daño por tipo, mostrando solo las torres con unlock permanente. Ver [ADR-0076](../decisions/ADR-0076-economia-inicial-roster-de-run-y-flujo-de-escenas.md).

Main Tower empieza con 10/10 HP. Fortification I–X añade +1 HP máximo por nivel hasta 20/20, con costes secuenciales 20/40/60/80/100/120/140/160/180/200 XP (1.100 XP total); cada nivel superior requiere el anterior. Fortification I–III de run son independientes y añaden +3 HP cada una. Un enemigo con `boss_tier > 0` que alcanza la base termina la run al instante, aunque conserve HP. Ver [ADR-0074](../decisions/ADR-0074-vida-de-base-y-derrota-por-jefe.md).

## Recompensa por derrota
El jugador debe recibir moneda aunque no llegue a ronda 45.

Crear fórmula configurable basada principalmente en progreso de ronda. Evitar que farmear ronda 1 sea óptimo.

## Permanent shop
Tipos iniciales:
- unlock tower;
- pequeño bonus global;
- mejora de economía inicial;
- mejora de Mana;
- ampliar/alterar pool de cartas.
- aumentar permanentemente la probabilidad de encontrar cofres.

No introducir support buildings.

M9 implementa solo economía runtime: Gold inicial, gasto en construcción/mejoras, recompensas por baja y ronda superada, y Mana con coste por ataque y regeneración. Por decisión UX posterior, el Mana se repone al máximo efectivo al comenzar cada ronda de campaña y el HUD lo presenta sin decimales. El Gold no se guarda ni se convierte en XP de perfil en M9. M12 conserva la responsabilidad de recompensas de fin de run, tienda permanente, desbloqueos y guardado. No hay edificios que generen Gold o Mana.

M10 implementa la campaña de 45 rondas. La secuencia de terreno se produce después de limpiar las rondas 1–44 y la ronda 45 termina la demo. WaveData contiene la cantidad directa exacta de cada grupo; cada enemigo se distribuye secuencialmente entre rutas alcanzables sin multiplicar cantidades por endpoints. Hay 1.093 enemigos directos en total según la tabla de usuario, más los enemigos que aparezcan por habilidades. Cyclops/Werewolf no son Minibosses especiales en las rondas 17/19. Ooogie von Ooogovich usa sus invocaciones y fase Bat adaptadas con balance propio, y la ronda espera su derrota final. Las reglas vigentes, apariciones y premios están en 14_CAMPANA_45_RONDAS.md, 13_CONTENT_ROSTER.md y ADR-0037.

M11 ofrece cartas temporales después de colocar terreno y antes de preparar la ronda siguiente. Para las 173 entradas compatibles de referencia se añaden 172 Resources; Advanced Circuits ya existía entre las 18 cards propias y se reutiliza, por lo que hay 190 IDs de mejora. M35 añade seis cards de reclutamiento y eleva el pool runtime a 196 IDs. El catálogo cubre las siete torres y mejoras generales/de estado. `RunCardService` filtra por unlock permanente, roster, prerequisitos, peso y límite por run; la oferta no repite carta. Las operaciones modifican daño, alcance, área, Mana, críticos, multiplicadores H/A/S, estados, economía o base sin mutar recursos compartidos. No hay mejoras de RPM por carta; Frost Keep escala por cobertura PATH. La oferta aparece cada tres rondas completadas, después de 3–42, y contiene siempre tres cards: reclutamientos elegibles y mejoras se mezclan en espacios aleatorios; una torre no elegida continúa disponible para futuras ofertas. `CardPoolData`, `RunCardService` y el panel comparten ese límite. La cadencia está confirmada; los números/rareza son provisionales. Ver ADR-0062/0076/0093.

M12 implementa `MetaProgression` como propietario del estado permanente y conserva intactos el Gold/Mana de cada `RunEconomyService`. En cada run, `begin_run()` crea un seed que se comparte con la selección aleatoria de cartas y piezas; `finish_run()` entrega moneda una sola vez tanto por derrota como por victoria y persiste un resumen. La fórmula provisional es `5 + 5 × rondas completadas`, más 30 por victoria, limitada a 1000; perder durante ronda 1 todavía concede 5 y progresar aumenta la recompensa. La regla de interfaz de M12 presentaba tienda terminal con pestañas y todos los unlocks en la barra; esa presentación fue sustituida en M35: escenas separadas de menú/run/pausa, roster reclutado por run y tienda como mapa conectado de nodos. El archivo versionado JSON usa `user://`, validación, temporal y backup. Si el guardado es corrupto o incompatible se preserva y las compras se desactivan. La economía inicial y el roster actuales están fijados en [ADR-0076](../decisions/ADR-0076-economia-inicial-roster-de-run-y-flujo-de-escenas.md); las decisiones de persistencia y fórmula conservan [ADR-0022](../decisions/ADR-0022-meta-progression-y-guardado.md).

M12A aplica las reglas de torre/capas de HP descritas en [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md), con demolición actualizada por [ADR-0064](../decisions/ADR-0064-reembolso-al-demoler-torres.md): cada nivel da +1 daño base y +1 al multiplicador Health/Armor/Shield elegido; una torre también sube por XP al retener objetivos, y la capa activa del enemigo asigna esa experiencia. Los upgrades se cobran con Gold de run. Construir una torre del mismo tipo suma el incremento al precio; demoler devuelve el precio marginal del último slot ocupado, calculado solo con precio base, incremento y cantidad del tipo antes de retirarla. Los niveles y mejoras no alteran el reembolso. El modelo de cada enemigo contiene Health, Armor y Shield; cada perfil configura los máximos, y cero desactiva una capa en esa unidad. La barra dibuja las capas activas en el orden Shield→Armor→Health. Bleed/Burn/Poison bloquean la regeneración correspondiente y aumentan en +1 el multiplicador del ataque en su capa. Los ticks de estado hacen daño completo en su capa asociada y mitad en las otras. El test Health/Armor/Shield vive en DEBUG; el perfil provisional de Ooogie von Ooogovich también porta Shield para mostrar la barra en campaña.

«Suerte del explorador» persiste entre runs: una celda construible sin obstáculo empieza con 1 % de probabilidad de generar cofre. Cuatro niveles añaden +5 puntos porcentuales cada uno; el tope de 20 % limita el último incremento. Los costes 10/20/35/55 y el premio provisional de 25 Gold por abrir un cofre son configurables. El cofre paga Gold de la run, nunca XP de perfil.

## Filosofía
Las permanentes facilitan progreso y variedad, pero no deben convertir el juego en "ganar por estadísticas" sin estrategia.

## Cards
Las cartas sustituyen parte del espacio sistémico que en Rogue Tower ocupan upgrades/support.

Categorías:
- tower-specific;
- tower-family;
- status;
- economy;
- mana;
- global utility.

Las cartas pueden aumentar:
- capacidad de Mana;
- regeneración de Mana;
- eficiencia;
- estadísticas de torre;
- status;
- economía.

Las cartas de oferta usan una superficie plana común sin sprites de borde/fondo. El tier aparece escrito, una separación pequeña distingue cada opción y el aura radial con partículas comunica la rareza con su color, sin cambiar el panel ni el resto de la card. La oferta siempre tiene tres columnas y tres opciones; no hay ampliación por Card Draw. Ver [ADR-0088](../decisions/ADR-0088-presentacion-compacta-de-upgrade-cards.md) y ADR-0093; ADR-0080 conserva el historial del sprite vertical ya retirado.

## Desbloqueos
Una torre bloqueada permanentemente no aparece en las opciones de reclutamiento ni en sus cartas específicas. Un unlock permanente tampoco la hace construible inmediatamente durante la run: primero debe reclutarse con una card de run. La barra de construcción muestra únicamente el roster temporal reclutado.

## Tienda permanente
La tienda usa un mapa desplazable de nodos conectados y una escena de tarjeta compartida por todas las mejoras. Cada nodo muestra icono grande del sistema o torre afectada, título, descripción, coste y estado. Las conexiones reflejan `prerequisites`; un nodo bloqueado explica sus requisitos en tooltip. Las mejoras Health, Armor y Shield de cada torre son tres ramas hermanas habilitadas por el unlock permanente de esa torre, y se pueden comprar en cualquier orden. Comprar un nodo emite partículas y actualiza las dependencias afectadas. La escena se reutiliza en el menú principal y tras Game Over. Ver [ADR-0077](../decisions/ADR-0077-mapa-de-mejoras-permanentes-con-nodos.md) y [ADR-0081](../decisions/ADR-0081-mejoras-de-torre-en-ramas-paralelas.md).

La vista de tienda no muestra instrucciones en el pie ni un botón para iniciar una run; el menú principal conserva esa acción. Un botón × fijo en la esquina superior derecha cierra el mapa. El árbol tiene espacio horizontal entre sus clusters, usa iconos propios en todos los nodos y permite desplazarse con rueda o arrastrar la vista con el botón izquierdo o central del ratón. Las tres ramas Health/Armor/Shield de cada torre aparecen en una misma fila, conectadas desde su nodo de desbloqueo. Los detalles completos y requisitos se conservan en el tooltip; los títulos del mapa se priorizan y las descripciones se resumen. Ver [ADR-0094](../decisions/ADR-0094-mapa-de-mejoras-y-legibilidad-del-terreno.md).

## Run seed
Guardar seed en resumen de run para reproducir:
- ofertas de cartas;
- selección de piezas;
- variaciones de wave que se autoricen.

## Victoria/derrota
- Base health <= 0 -> derrota; cualquier boss (`boss_tier > 0`) que toca la base también termina la run inmediatamente.
- Completar ronda 45 -> victoria demo.
- Ambos casos calculan recompensa meta y muestran resumen.
