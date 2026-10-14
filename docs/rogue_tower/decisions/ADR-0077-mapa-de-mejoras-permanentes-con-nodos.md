# ADR-0077: Mapa conectado de mejoras permanentes

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; el caso de mejoras H/A/S en paralelo se amplía en [ADR-0081](ADR-0081-mejoras-de-torre-en-ramas-paralelas.md); aceptación visual pendiente.
- Actualiza la presentación de tienda definida en [ADR-0022](ADR-0022-meta-progression-y-guardado.md); no cambia los efectos ni los costes configurados de las mejoras.

## Contexto

La tienda anterior agrupaba las mejoras como una lista terminal. El usuario quiere una progresión explorable con dependencias visibles, tarjetas consistentes e iconografía que identifique de inmediato qué entidad modifica cada mejora.

## Decisiones

1. Las mejoras permanentes se presentan en un mapa desplazable de nodos conectados. Comprar un nodo habilita los nodos que dependan de él según sus `prerequisites`; no se permite saltar los requisitos. Las tres mejoras H/A/S de torre son ramas hermanas reveladas por el unlock de su torre, conforme a ADR-0081.
2. Todas las mejoras usan una única escena reutilizable de tarjeta/nodo, independientemente de su categoría. Cada nodo muestra icono grande, título, descripción/efecto, coste y estado. Se reutiliza la iconografía existente; cualquier icono faltante se crea como PNG sencillo.
3. Los iconos representan el objeto o sistema afectado: retrato de torre, moneda/economía, carta/archivo, base u otro icono de sistema pertinente. Los títulos de mejoras de torre identifican explícitamente la torre afectada.
4. El tooltip de un nodo bloqueado explica los prerequisitos y cómo desbloquearlo. Comprar un nodo reproduce una ráfaga de partículas y actualiza en el momento sus conexiones/estados.
5. Este ADR solo decide la presentación y navegación del mapa; el catálogo, los identificadores, los efectos y el balance siguen siendo los Resources de datos y las reglas de diseño activo. Las conexiones usan exactamente `PermanentUpgradeData.id`; no se quitan prefijos ni se normalizan IDs al enlazar prerequisitos o dibujar ramas.

## Consecuencias

- `MetaProgressionMap` dibuja conexiones y partículas; `MetaUpgradeNode` es el componente compartido. El menú reutiliza la misma tienda.
- El código y contenido de la tienda están integrados. La legibilidad de iconos, bloqueos, conexiones, costes, escalado y feedback queda pendiente de aceptación visual en M35.

## Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño activo](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [progresión](../design/07_ROGUELIKE_PROGRESSION.md) y [nomenclatura](../design/12_NOMENCLATURE.md), consultados el 2026-10-14.
