# ADR-0081: Mejoras permanentes H/A/S en ramas paralelas

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código y catálogo integrados, aceptación interactiva pendiente.
- Amplía el mapa de nodos de [ADR-0077](ADR-0077-mapa-de-mejoras-permanentes-con-nodos.md).

## Contexto

Al desbloquear una torre, el jugador debe poder escoger en qué orden mejora sus bonos de daño contra Health, Armor y Shield. Comprar una capa no debe bloquear las otras.

## Decisiones

1. Para cada torre, sus mejoras permanentes Health, Armor y Shield requieren únicamente el unlock permanente de esa torre.
2. Las tres mejoras son hermanas: no tienen requisitos mutuos ni orden obligatorio y pueden comprarse en cualquier orden. Comprar una no cambia el estado de disponibilidad de las otras.
3. El mapa dibuja las tres conexiones directamente desde el nodo de unlock de la torre. Se aplica a Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder.
4. Los requisitos secuenciales de otras ramas, como Main Tower Fortification I–X, no cambian.

## Consecuencias

- `PermanentUpgradeData.prerequisite_unlock_ids` mantiene el control del unlock de torre; las dependencias de compra entre cada trío H/A/S se eliminan del catálogo.
- El orden vertical de las tarjetas solo organiza el mapa, no expresa prerrequisitos.
- La comprobación de que los tres nodos se habiliten juntos y permanezcan disponibles tras una compra queda en M36 de `10_ACCEPTANCE_TESTS.md`.

## Referencias

- Petición explícita del usuario, 2026-10-14.
- [ADR-0077](ADR-0077-mapa-de-mejoras-permanentes-con-nodos.md), consultado el 2026-10-14.
