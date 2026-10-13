# ADR-0059: Frost Keep usa copos de impacto individual

- **Fecha:** 2026-10-13
- **Estado:** implementación integrada; aceptación manual pendiente
- **Sustituye parcialmente:** decisión 10 de ADR-0037 (Frost Keep) y decisión 2 de ADR-0045 (patrón de ataque Frost). El alcance cuadrado de ADR-0045 se conserva.
- **Autoridad:** petición explícita del usuario; Rogue Tower se usa como referencia de comportamiento y cifras.

## Contexto

Frost Keep estaba configurado como `ALL_IN_RANGE`: cada disparo aplicaba un paquete de daño directo a todos los enemigos del cuadrado, aunque no hubiera un impacto visual. La aplicación repetida de un golpe garantizado convertía a Frost en daño de área constante y podía hacer que eliminase una oleada por sí sola. Además, Slow tenía un multiplicador fijo de 0,85 durante 1 segundo, distinto del efecto proporcional al daño de la referencia.

La página individual de Frost Keep describe copos que caen sobre PATH, alcance cuadrado, impacto a un enemigo por copo, Slow equivalente al 50% del daño y coste de 2 Mana/s. Su ficha indexada aún muestra daño 5; el anuncio oficial 1.1.2.0 posterior subió el daño de Frost de 5 a 6. La configuración usa 6.

## Decisiones

1. Frost Keep usa daño base 6, multiplicadores Health/Armor/Shield 10/5/5, alcance 2 en cuadrado, 180 RPM base y +18 RPM por celda PATH cubierta.
2. Durante combate, cada ataque crea un copo sobre una celda PATH aleatoria dentro de la cobertura cuadrada. El copo cae visualmente; al tocar un enemigo en movimiento dentro del alcance aplica un único `DamagePacket` por `DamageService` y desaparece. Puede fallar; un copo sin contacto no hace daño ni aplica estados. Un copo nunca golpea más de un enemigo.
3. Slow recibe fuerza igual al 50% del daño realmente aplicado por el impacto. La fuerza se suma hasta 60 y decae a 6 puntos por segundo; cada punto es un punto porcentual de reducción de velocidad. Si el daño aplicado es cero, no se aplica Slow. La fuerza por enemigo queda en la instancia de `StatusEffectController` y no muta el Resource compartido.
4. El coste de 2 Mana/s se drena continuamente mientras la run está en `COMBAT`, aunque Frost no tenga objetivo. Las cards que modifican el coste multiplican esa tasa. Sin Mana suficiente, la torre se bloquea y no lanza copos hasta reunir el coste del siguiente paso.
5. Altura de caída, velocidad y radio de contacto son parámetros de `TowerData` para ajustar el dibujo y la tolerancia de colisión. Son aproximaciones configurables del efecto visual; la distribución interna exacta de partículas del juego original no es pública.
6. Se conserva la carta Blizzard y el sistema de mejoras por capas del proyecto. No se importa el árbol específico de cartas de Rogue Tower.

## Consecuencias

- El daño vuelve a coincidir con la ficha oficial más reciente, pero cada impacto exige contacto y solo puede afectar a un enemigo. Los copos pueden fallar, por lo que Frost deja de repartir un golpe garantizado a todos los objetivos del cuadrado.
- Con 100% de impactos sobre un solo objetivo, el techo matemático inicial es 180 Health/s, 90 Armor/s o 90 Shield/s antes de overkill. El daño real depende de cuántos copos contacten con enemigos. Las mejoras y cartas del proyecto pueden elevar las cifras runtime.
- La cadencia conserva su sinergia PATH: cada celda cubierta añade 18 ataques por minuto. Más cobertura también aumenta los copos creados, conforme a la regla publicada.
- El coste nominal refleja 2 Mana/s durante combate y no queda sujeto a la presencia de objetivos.
- Queda pendiente observar en Godot la frecuencia visual de contactos, el Slow acumulado y la lectura del HUD. La altura/velocidad/radio configurables pueden necesitar ajuste tras esa aceptación.

## Fuentes

- [Frost Keep — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Frost_Keep), consultada 2026-10-13. Referencia comunitaria para lluvia de copos, contacto individual, Slow, coste, rango y cadencia por PATH; la ficha indexada muestra daño 5.
- [Anuncios oficiales de Rogue Tower en Steam](https://steamcommunity.com/app/1843760/announcements/), Patch Notes 1.1.2.0, 2022-09-08; consultados 2026-10-13. El changelog sube el daño base de Frost de 5 a 6.
- [Status Effects — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Status_Effects), consultada 2026-10-13. Referencia para el cap de Slow 60 y decaimiento 6/s.
- [Discusión de Steam sobre Slow](https://steamcommunity.com/app/1843760/discussions/0/3182358518959301391/), respuesta del desarrollador consultada 2026-10-13. Explica que los copos aplican Slow al contacto y que Frost acelera con más cobertura.
