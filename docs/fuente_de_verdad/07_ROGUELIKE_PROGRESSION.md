# Roguelike Progression

## Dos capas

### Dentro de la run
- construcción;
- upgrades de torre;
- mapa;
- oro de construcción (saldo temporal de `RunEconomyService`);
- maná (saldo temporal, capacidad y regeneración configurables);
- cartas;
- status/build synergies.

### Entre runs
- moneda meta (`MetaProgression.meta_currency`, persistente y separada del oro de construcción);
- tienda;
- desbloqueo de torres;
- mejoras permanentes.

## Recompensa por derrota
El jugador debe recibir moneda aunque no llegue a ronda 20.

Crear fórmula configurable basada principalmente en progreso de ronda. Evitar que farmear ronda 1 sea óptimo.

## Permanent shop
Tipos iniciales:
- unlock tower;
- pequeño bonus global;
- mejora de economía inicial;
- mejora de maná;
- ampliar/alterar pool de cartas.

No introducir support buildings.

M9 implementa solo economía runtime: oro inicial, gasto en construcción/mejoras, recompensas por baja y ronda superada, y maná con coste por ataque y regeneración. El oro no se guarda ni se convierte en meta moneda en M9. M12 conserva la responsabilidad de recompensas de fin de run, tienda permanente, desbloqueos y guardado. No hay edificios que generen oro o maná.

M10 implementa el loop técnico de campaña: rondas 1–19 alternan limpieza, recompensa y una oferta de tres piezas de terreno distintas; elegir una y colocar una pieza válida de siete hexes desbloquea la siguiente ronda. `Esc` vuelve a la oferta actual. Los huecos encerrados se rellenan al azar con Grass/Montaña salvo las aberturas PATH de spawn. La ronda 20 limpia y entra a victoria demo. La recompensa y el resumen persistentes no formaban parte del alcance original de M10; M12 completa actualmente ese flujo, descrito abajo. En cada pulso de grupo, los enemigos aparecen simultáneamente en todos los finales PATH abiertos y alcanzables. Los encuentros propios confirmados son minijefes en 17/19 y jefe Tier 2 en 20, aún con variantes/poderes pendientes. El selector de ronda y los fixtures M7/M8 de diagnóstico no cambian el avance de campaña. La oferta M10 son opciones de terreno, no `CardData`; las cartas de mejoras siguen en M11.

M11 implementa cartas dentro de la run, después de la expansión de terreno y antes de preparar la siguiente ronda cuando el calendario de `CardPoolData` lo indica. `RunCardService` mantiene la oferta actual y cartas elegidas, filtra por unlocks, peso y límite por run; la oferta no repite una carta. Las operaciones cambian daño, alcance, área, maná, crítico, multiplicadores H/A/E o duración de estado sin mutar recursos compartidos. No hay mejoras de RPM de carta; Frost Keep sí escala por cobertura PATH. El pool actual tiene 12 opciones originales, dos de Archivo M12, una global de crítico y tres mejoras globales de +1 al multiplicador H/A/E; ofrece tres al limpiar las rondas 3, 6, 9, 12, 15 y 18. Calendario y cifras son provisionales.

M12 implementa `MetaProgression` como propietario del estado permanente y conserva intactos el oro/maná de cada `RunEconomyService`. En cada run, `begin_run()` crea un seed que se comparte con la selección aleatoria de cartas y piezas; `finish_run()` entrega moneda una sola vez tanto por derrota como por victoria y persiste un resumen. La fórmula provisional es `5 + 5 × rondas completadas`, más 30 por victoria, limitada a 1000; perder durante ronda 1 todavía concede 5 y progresar aumenta la recompensa. La tienda aparece al terminar la campaña y permite desbloquear torres, mejorar recursos/daño para runs siguientes y comprar el Archivo de cartas. Ballista es el único perfil inicial; los unlocks bloquean tanto la barra como la compra por código y alimentan los filtros de cartas. El archivo versionado JSON usa `user://`, validación, temporal y backup. Si el guardado es corrupto o incompatible se preserva y las compras se desactivan. Roster, precios, fórmula y valores de upgrade son placeholders, documentados en [ADR-0022](../decisiones/ADR-0022-meta-progression-y-guardado.md). La aceptación manual todavía está pendiente.

M12A aplica reglas de torre/capas de HP descritas en [ADR-0023](../decisiones/ADR-0023-reglas-de-torres-y-capas-de-vida.md): cada nivel da +1 daño base y +1 al multiplicador H/A/E elegido; una torre también sube por XP al retener objetivos, y el HP actual del objetivo asigna esa experiencia a Health, Armor o Shield. Los upgrades se cobran con oro de run. Construir una segunda torre del mismo tipo suma su incremento al precio; demoler reduce el precio futuro sin reembolso provisional. El enemigo presenta una barra segmentada H/A/E y sus regeneraciones se contrarrestan con Bleed/Burn/Poison. Estos cambios no agregan support buildings ni modifican recompensas meta; el test H/A/E vive en DEBUG.

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
- capacidad de maná;
- regeneración de maná;
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
- Completar ronda 20 -> victoria demo.
- Ambos casos calculan recompensa meta y muestran resumen.
