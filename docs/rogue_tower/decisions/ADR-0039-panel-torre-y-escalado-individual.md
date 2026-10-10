# ADR-0039: Panel lateral de torre y escala visual por objeto

- Fecha: 2026-10-09
- Estado: Aceptado; la regla de scroll se sustituyó por ADR-0040 y las escalas visuales por ADR-0041. La aceptación visual sigue pendiente.
- Ámbito: panel informativo/build de torres y tamaño mostrado de torres, enemigos y base.
- Decisiones relacionadas: ADR-0026, ADR-0031, ADR-0038.
- Sustituye parcialmente: ADR-0038 en el tamaño visual de la base.

## Contexto

El panel de torre mantenía una altura fija excesiva, no identificaba visualmente la torre al construir y repetía instrucciones que el preview ya comunica con color. Las capas de daño y los botones de mejora no eran suficientemente legibles. El usuario también pidió sprites mayores cerca del 15% por objeto, evitando una escala global.

## Decisiones

1. Decisión histórica, sustituida por ADR-0040: el panel lateral se coloca arriba a la derecha y ajusta su altura al contenido; no presenta scroll y reduce la escala vertical si falta espacio.
2. Al construir, el panel presenta un icono de torre grande, nombre, resumen de rol, precio, daño, alcance, cadencia, multiplicadores Health/Armor/Shield y consumo de Mana si existe. Muestra la diferencia real de elevación `Mountain vs Grass` tomada del `TowerData`; no muestra el texto genérico de elegir terreno. El preview conserva el feedback verde/rojo y los errores de colocación siguen informándose.
3. En el resumen seleccionado, Health se muestra en verde, Armor en ámbar y Shield en azul, con etiquetas en negrita. Los tres botones de mejora son cuadrados y muestran icono, coste y la ganancia de +1 daño base junto con +1 al multiplicador de la capa elegida. Demoler aparece en la fila inferior.
4. Decisión histórica, sustituida por ADR-0041: el tamaño visual se configura por Resource y objeto. Los perfiles originales subieron las torres a 62 px, los enemigos alrededor de 15 % y la base a 129×129; ADR-0041 fija los tamaños mayores vigentes.
5. El escalado solo afecta la presentación, las sombras y el espacio de sus barras/estados. Mantiene el tamaño lógico de la huella axial, la ocupación del tablero, los rangos, las colisiones lógicas y el movimiento.
6. Por petición directa del usuario, el 2026-10-10 se actualizaron los iconos activos de Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder en `game/ui/icons/`. Son sprites originales de fantasía cómica 2D, con siluetas legibles, trazos simples y colores planos. Las alternativas quedan en `game/ui/icons/proposals/adventure_comic/`; el sprite activo y el alternativo conservan el tamaño fuente de 256×256. No cambia ningún `TowerData`, estadística ni comportamiento.

## Consecuencias

- El panel puede ser más bajo cuando la torre está seleccionada y más alto en build mode por el retrato; a ventanas bajas recurre al scroll.
- Alturas, tamaños de sprite y perfiles siguen editables desde Resources individuales; no hay multiplicador global de escena.
- El preview y la torre construida comparten el sprite y tamaño configurado. Cambiar el PNG conserva el tamaño guardado en su Resource.
- La revisión de los nuevos iconos a su escala de juego sigue pendiente junto con la revisión visual indicada abajo.
- La revisión visual en Godot queda pendiente a 1280×720 y 1440×900, incluidos texto, foco/hover de botones, recorte de sprites y panel durante build mode.

## Fuentes

- Petición directa del usuario en la sesión del 2026-10-09.
- Petición directa del usuario en la sesión del 2026-10-10 para renovar los sprites de las siete torres con estilo de cómic sencillo.
- `TowerData`, `EnemyData`, `BaseData` y los PNG existentes del proyecto.
