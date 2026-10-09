# ADR-0034: Reembolso de cooldown de Ballista al perder el objetivo

- **Fecha:** 2026-10-09
- **Estado:** Aceptado; Godot 4.7 analizó los scripts sin errores de parseo. La aceptación funcional dentro de una run sigue pendiente.
- **Ámbito:** proyectiles de Ballista durante la campaña.
- **Fuente de la decisión:** instrucción del usuario del 2026-10-09.

## Contexto

Al principio de la campaña, varias Ballistas pueden disparar al mismo enemigo y quedar esperando todo su tiempo de recarga aunque otras torres ya hayan eliminado el objetivo. Se necesita conservar la cadencia independiente de cada Ballista y recuperar parte de la recarga solo cuando su proyectil pierde un objetivo vivo por una causa ajena a ese impacto.

## Decisión

1. Cada proyectil de Ballista identifica el ciclo de recarga que inició su propio disparo.
2. Si su objetivo pasa a `DEAD` antes del impacto de ese proyectil, la Ballista dueña del disparo descuenta del tiempo restante el **33 % de la duración completa de ese cooldown**.
3. El reembolso no puede reducir el cooldown por debajo de cero y se puede aplicar una sola vez al ciclo activo de esa Ballista.
4. El impacto que mata al objetivo no da reembolso. Tampoco lo da un objetivo que llega a la base ni un objetivo que muere después de que el proyectil ya impactó.
5. Mortar y las demás torres no usan esta regla. Cada Ballista conserva su propio cooldown y los proyectiles de ciclos antiguos no pueden alterar la recarga de un disparo posterior.

## Consecuencias

- Varios proyectiles pueden perseguir al mismo objetivo sin bloquear la cadencia de las Ballistas cuyo proyectil perdió el objetivo.
- El ajuste no cambia el cooldown normal cuando el objetivo sobrevive hasta el impacto.
- El 33 % se calcula sobre la recarga completa del disparo, no sobre una cifra global compartida.
- Los casos de disparo, muerte por otra torre y muerte por el propio impacto deben verificarse en Godot antes de dar por validada la implementación.

## Referencias

- [Diseño de combate](../design/06_COMBAT_SYSTEM.md)
- [Catálogo de contenido](../design/13_CONTENT_ROSTER.md)
- [Ballista — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Ballista) (referencia de cadencia base; esta regla es propia del proyecto).
