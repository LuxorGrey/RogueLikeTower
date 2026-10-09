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
- moneda meta (`MetaProgression.meta_currency`, persistente y separada del Gold de construcción);
- tienda;
- desbloqueo de torres;
- mejoras permanentes.

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

M9 implementa solo economía runtime: Gold inicial, gasto en construcción/mejoras, recompensas por baja y ronda superada, y Mana con coste por ataque y regeneración. Por decisión UX posterior, el Mana se repone al máximo efectivo al comenzar cada ronda de campaña y el HUD lo presenta sin decimales. El Gold no se guarda ni se convierte en meta moneda en M9. M12 conserva la responsabilidad de recompensas de fin de run, tienda permanente, desbloqueos y guardado. No hay edificios que generen Gold o Mana.

M10 implementa la campaña de 45 rondas. La secuencia de terreno se produce después de limpiar las rondas 1–44 y la ronda 45 termina la demo. WaveData contiene la cantidad directa exacta de cada grupo; cada enemigo se distribuye secuencialmente entre rutas alcanzables sin multiplicar cantidades por endpoints. Hay 1.093 enemigos directos en total según la tabla de usuario, más los enemigos que aparezcan por habilidades. Cyclops/Werewolf no son Minibosses especiales en las rondas 17/19. Ooogie von Ooogovich usa sus invocaciones y fase Bat adaptadas con balance propio, y la ronda espera su derrota final. Las reglas vigentes, apariciones y premios están en 14_CAMPANA_45_RONDAS.md, 13_CONTENT_ROSTER.md y ADR-0037.

M11 implementa cartas dentro de la run, después de la expansión de terreno y antes de preparar la siguiente ronda cuando el calendario de `CardPoolData` lo indica. `RunCardService` mantiene la oferta actual y cartas elegidas, filtra por unlocks, peso y límite por run; la oferta no repite una carta. Las operaciones cambian daño, alcance, área, Mana, crítico, multiplicadores H/A/S o duración de estado sin mutar recursos compartidos. No hay mejoras de RPM de carta; Frost Keep sí escala por cobertura PATH. El pool actual tiene 12 opciones originales, dos de Archivo M12, una global de crítico y tres mejoras globales de +1 al multiplicador H/A/S; ofrece tres al limpiar las rondas 3, 6, 9, 12, 15 y 18. Calendario y cifras son provisionales.

M12 implementa `MetaProgression` como propietario del estado permanente y conserva intactos el Gold/Mana de cada `RunEconomyService`. En cada run, `begin_run()` crea un seed que se comparte con la selección aleatoria de cartas y piezas; `finish_run()` entrega moneda una sola vez tanto por derrota como por victoria y persiste un resumen. La fórmula provisional es `5 + 5 × rondas completadas`, más 30 por victoria, limitada a 1000; perder durante ronda 1 todavía concede 5 y progresar aumenta la recompensa. La tienda aparece al terminar la campaña y permite desbloquear torres, mejorar recursos/daño para runs siguientes y comprar el Archivo de cartas. Ballista es el único perfil inicial; los unlocks bloquean tanto la barra como la compra por código y alimentan los filtros de cartas. El archivo versionado JSON usa `user://`, validación, temporal y backup. Si el guardado es corrupto o incompatible se preserva y las compras se desactivan. Roster, precios, fórmula y valores de upgrade son placeholders, documentados en [ADR-0022](../decisions/ADR-0022-meta-progression-y-guardado.md). La aceptación manual todavía está pendiente.

M12A aplica las reglas de torre/capas de HP descritas en [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md): cada nivel da +1 daño base y +1 al multiplicador Health/Armor/Shield elegido; una torre también sube por XP al retener objetivos, y la capa activa del enemigo asigna esa experiencia. Los upgrades se cobran con Gold de run. Construir una segunda torre del mismo tipo suma su incremento al precio; demoler reduce el precio futuro sin reembolso provisional. El modelo de cada enemigo contiene Health, Armor y Shield; cada perfil configura los máximos, y cero desactiva una capa en esa unidad. La barra dibuja las capas activas en el orden Shield→Armor→Health. Bleed/Burn/Poison bloquean la regeneración correspondiente y aumentan en +1 el multiplicador del ataque en su capa. Los ticks de estado hacen daño completo en su capa asociada y mitad en las otras. El test Health/Armor/Shield vive en DEBUG; el perfil provisional de Ooogie von Ooogovich también porta Shield para mostrar la barra en campaña.

«Suerte del explorador» persiste entre runs: una celda construible sin obstáculo empieza con 1 % de probabilidad de generar cofre. Cuatro niveles añaden +5 puntos porcentuales cada uno; el tope de 20 % limita el último incremento. Los costes 10/20/35/55 y el premio provisional de 25 Gold por abrir un cofre son configurables. El cofre paga Gold de la run, nunca moneda meta.

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

## Desbloqueos
Una torre bloqueada no aparece en:
- build menu;
- pools de cartas específicos;
- recompensas que dependan de ella.

## Run seed
Guardar seed en resumen de run para reproducir:
- ofertas de cartas;
- selección de piezas;
- variaciones de wave que se autoricen.

## Victoria/derrota
- Base health <= 0 -> derrota.
- Completar ronda 45 -> victoria demo.
- Ambos casos calculan recompensa meta y muestran resumen.
