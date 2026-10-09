# ADR-0027: HUD en tres paneles e iconos vectoriales reutilizables

- Estado: Parcialmente sustituida por ADR-0028 para feedback/controles de torre y ADR-0031 para el formato de iconos; distribución en tres paneles, jerarquía de recursos y comportamiento terminal siguen vigentes. Aceptación visual manual pendiente.
- Fecha: 2026-10-08.
- Contexto: la primera organización M13 reunía recursos, ronda y torre seleccionada en un panel superior grande. La lectura era densa y el jugador no distinguía de un vistazo la salud de la base, el inicio de la ronda y las acciones de torre.

## Decisiones

1. El HUD normal se distribuye en tres paneles: recursos compactos arriba a la izquierda, ronda/progreso/acción arriba al centro y detalles/acciones de la torre arriba a la derecha. La barra inferior de construcción conserva los atajos `1–7`.
2. Se elimina el título «RogueTower». La salud de la base se representa con una `ProgressBar` y el valor actual/máximo dentro de la barra. Oro y maná tienen iconos propios; el icono y valor del oro reciben mayor tamaño visual.
3. El panel de torre solo aparece durante la selección de una torre o mientras se está colocando una. Un clic en una casilla sin torre o fuera del tablero limpia la selección; abrir F3 oculta temporalmente el panel de torre y mantiene accesibles sus controles técnicos.
4. La primera versión guardó nueve iconos en un atlas SVG propio. ADR-0028 registró su sustitución por PNG RGBA; ADR-0031 reemplaza el atlas por un PNG independiente para cada objeto.
5. El panel de ronda mantiene los veinte segmentos de campaña y el botón de inicio. La nueva distribución solo cambia la presentación y la selección de torre; no modifica balance, combate, economía, progresión ni reglas de campaña.

## Consecuencias y aceptación

- El mapa conserva espacio libre en el centro y los tres paneles separan claramente los estados permanentes, el control de ronda y las estadísticas contextuales.
- La aceptación manual debe confirmar lectura a 1440×900, valor de vida dentro de la barra, jerarquía de oro/maná, los nueve iconos, visibilidad condicional de torre y convivencia con F3, `H` y la barra inferior.
- El atlas SVG y el atlas PNG fueron retirados; el formato actual de iconos PNG independientes está en ADR-0031.

## Referencias

- Sustituye la distribución descrita en los puntos 1–3 y actualiza el recurso visual descrito en el punto 5 de [ADR-0026](ADR-0026-jerarquia-ux-ui.md); su jerarquía de tienda y comportamiento terminal siguen vigentes.
- [M13 UX/UI](../design/02_IMPLEMENTATION_ROADMAP.md).
- [Pruebas de aceptación](../design/10_ACCEPTANCE_TESTS.md).
