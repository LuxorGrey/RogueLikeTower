# ADR-0069: Arsenal inicial, XP de perfil y lectura de altura

- Fecha: 2026-10-13
- Estado: Aceptado por petición explícita del usuario; código integrado, aceptación manual pendiente.
- Actualiza: el roster inicial de [ADR-0022](ADR-0022-meta-progresion-y-guardado.md) y el reinicio limpio de [ADR-0067](ADR-0067-hacks-de-progresion-y-run-limpia.md).
- ADR-0076 aclara que las tres torres iniciales son unlocks permanentes: solo Ballista está reclutada al comenzar una run.

## Contexto

Una instalación nueva estaba dejando disponibles solo Ballista y cobrando costes bajos en moneda meta por las demás torres. El usuario pidió seguir el principio de XP de Rogue Tower, empezar con Ballista/Mortar/Tesla Coil, usar los costes de su tabla y explicar visualmente el bonus de construir en altura.

## Decisiones

1. El saldo persistente que el código guarda como `meta_currency` se presenta al jugador como XP de perfil. Se conserva la clave JSON existente para mantener compatibilidad con los guardados versión 1. Este saldo financia desbloqueos de torres y mejoras permanentes; la recompensa por run sigue siendo configurable por el diseño propio.
2. Ballista, Mortar y Tesla Coil forman el conjunto de unlocks permanentes gratuitos iniciales. ADR-0076 sustituye la lectura de que las tres se puedan construir desde el comienzo de cada run: solo Ballista empieza reclutada y las demás requieren elegir su card de reclutamiento. Frost Keep, Flame Thrower y Poison Sprayer cuestan 50 XP de perfil cada una; Shredder cuesta 100 XP. Un desbloqueo comprado persiste en las runs normales y habilita reclutamientos/cartas específicos de esa torre.
3. El hack `Empezar desde cero` deja solo el arsenal inicial, restablece mejoras permanentes y devuelve el XP que se gastó en esas mejoras. Conserva XP no gastado, desbloqueos de contenido que no sean torres y contadores históricos. Una run normal conserva los unlocks.
4. Al seleccionar una torre colocada en una celda elevada, Tower Info muestra `ALTURA hN`, el aumento de daño base y el aumento de alcance derivados de `TowerData`. La cifra usa `tower.elevation × bonus_per_level`, igual que el cálculo runtime.
5. Los costes y roster provistos por el usuario se usan directamente. El resto del árbol, la fórmula de XP por run y cualquier balance que no haya pedido siguen siendo propios y configurables.

## Consecuencias

- Una instalación nueva tiene tres torres con unlock permanente. El roster construible y los botones de una run se limitan a las torres reclutadas, según ADR-0076.
- Los perfiles ya guardados conservan sus torres compradas y reciben las tres torres iniciales gratuitas si les faltaban; el reset de prueba las vuelve a bloquear si son extras.
- No se cambia el formato de guardado. La tienda muestra XP de perfil para compras de torres y mejoras.
- Falta comprobar la barra inicial, compra/persistencia, reinicio de prueba y cifras de altura en ventana.

## Referencias

- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers), wiki comunitaria consultada el 2026-10-13. La página directa respondió HTTP 402; la búsqueda indexada devolvió la tabla de torres y el usuario aportó la tabla de XP/costes que se aplica aquí.
- [Upgrades — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Upgrades), wiki comunitaria consultada el 2026-10-13; referencia del XP persistente y su uso para unlocks y mejoras. No se importa su fórmula de recompensas.
