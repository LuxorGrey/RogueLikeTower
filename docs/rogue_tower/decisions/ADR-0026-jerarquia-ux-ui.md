# ADR-0026: Jerarquía de la interfaz de run y tienda terminal

- Estado: Parcialmente sustituida por ADR-0027 para la distribución del HUD y ADR-0031 para el formato actual de iconos; los acuerdos funcionales restantes siguen vigentes. Aceptación visual manual pendiente.
- Fecha: 2026-10-08.
- Contexto: la escena ya tenía controles funcionales para campaña, terreno, combate, siete torres y meta-progresión, pero acumulaba el selector de diagnóstico y la lectura técnica del objetivo junto al HUD habitual. La tienda terminal mostraba muchos desbloqueos y mejoras en una sola lista, y el resultado de run compartía jerarquía con las compras. M13 requiere que los sistemas de la demo sean legibles sin depender del modo DEBUG.

## Decisiones

1. El HUD habitual prioriza la vida de la base, oro/maná de run, fase/ronda y las acciones de campaña. Una franja visual de veinte segmentos diferencia rondas completadas, actual y pendientes; los encuentros especiales 17/19/20 reciben un acento discreto.
2. La selección de fixtures de ronda y el inspector detallado de objetivo pasan al panel técnico que abre `F3`. No se eliminan los harnesses M7/M8 ni los atajos de diagnóstico `8–0`. El resumen compacto de la torre seleccionada mantiene sus stats relevantes visibles; al pasar el cursor sobre él se consulta el objetivo, capas, regeneración, daño estimado y estados.
3. Las estadísticas de torre se presentan en líneas agrupadas: nivel, daño, multiplicadores H/A/S, alcance, RPM, crítico, patrón, coste de maná y XP. Prioridad, mejora y demolición aparecen solo con una torre seleccionada; sus tooltips describen coste y efecto.
4. La tienda terminal muestra primero victoria/derrota, ronda alcanzada, rondas completadas, recompensa y saldo meta. Dos categorías separan desbloqueos de torres y mejoras permanentes; cada opción explica efecto/estado y coste, y una acción persistente inicia la siguiente run.
5. Un helper de estilo aplica placas azul pizarra, bordes acero, botones con hover ámbar y colores de estado verde/terracota. La jerarquía se construye con controles nativos de Godot; el uso posterior de iconos propios en SVG queda especificado en ADR-0027.
6. Los cambios M13 son de presentación y acceso a información. No cambian fórmulas, datos de balance, reglas de progresión, save, combate ni controles de cámara. `H` sigue ocultando todo el HUD y el panel F3.

## Consecuencias y aceptación

- Las funciones DEBUG continúan disponibles en una vista técnica plegable, mientras el estado de campaña no comparte espacio con datos continuos de diagnóstico.
- La tienda conserva compra persistente, validación de saldo/guardado y reload de nueva run de M12; solo cambia su organización visual.
- Implementar no equivale a aceptar: `10_ACCEPTANCE_TESTS.md` define la comprobación manual de campaña, torre, terreno, tooltips y ambas salidas terminales en ventana Godot.
- Esta decisión no fija balance ni arte final; colores, espaciados y placeholders siguen ajustables después de la revisión visual.

## Referencias

- `docs/rogue_tower/design/02_IMPLEMENTATION_ROADMAP.md` (M13 UX/UI).
- `docs/rogue_tower/design/03_TECHNICAL_ARCHITECTURE.md` (presentación de M13).
- `docs/rogue_tower/design/10_ACCEPTANCE_TESTS.md` (aceptación manual M13).
