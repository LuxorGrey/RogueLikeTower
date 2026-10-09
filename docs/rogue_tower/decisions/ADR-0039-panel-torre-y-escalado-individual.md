# ADR-0039: Panel lateral de torre y escala visual por objeto

- Fecha: 2026-10-09
- Estado: Aceptado por petición explícita del usuario; código y Resources actualizados, aceptación visual pendiente.
- Ámbito: panel informativo/build de torres y tamaño mostrado de torres, enemigos y base.
- Decisiones relacionadas: ADR-0026, ADR-0031, ADR-0038.
- Sustituye parcialmente: ADR-0038 en el tamaño visual de la base.

## Contexto

El panel de torre mantenía una altura fija excesiva, no identificaba visualmente la torre al construir y repetía instrucciones que el preview ya comunica con color. Las capas de daño y los botones de mejora no eran suficientemente legibles. El usuario también pidió sprites mayores cerca del 15% por objeto, evitando una escala global.

## Decisiones

1. El panel lateral se coloca arriba a la derecha y ajusta su altura al contenido disponible. Conserva scroll cuando el contenido excede el alto de la ventana.
2. Al construir, el panel presenta un icono de torre grande, nombre, resumen de rol, precio, daño, alcance, cadencia, multiplicadores Health/Armor/Shield y consumo de Mana si existe. Muestra la diferencia real de elevación `Mountain vs Grass` tomada del `TowerData`; no muestra el texto genérico de elegir terreno. El preview conserva el feedback verde/rojo y los errores de colocación siguen informándose.
3. En el resumen seleccionado, Health se muestra en verde, Armor en ámbar y Shield en azul, con etiquetas en negrita. Los tres botones de mejora son cuadrados y muestran icono, coste y la ganancia de +1 daño base junto con +1 al multiplicador de la capa elegida. Demoler aparece en la fila inferior.
4. El tamaño visual se configura por Resource y objeto. Los siete perfiles jugables y los Resources de torre de diagnóstico usan `TowerData.visual_icon_size = 62` frente a 54 px (aprox. +15%); el preview de construcción lee ese mismo valor. Los perfiles de enemigo definen `EnemyData.sprite_extent` y aumentan su `placeholder_radius` de presentación alrededor de 15%. La base aumenta `BaseData.sprite_size` de 112×112 a 129×129.
5. El escalado solo afecta la presentación, las sombras y el espacio de sus barras/estados. Mantiene el tamaño lógico de la huella axial, la ocupación del tablero, los rangos, las colisiones lógicas y el movimiento.

## Consecuencias

- El panel puede ser más bajo cuando la torre está seleccionada y más alto en build mode por el retrato; a ventanas bajas recurre al scroll.
- Alturas, tamaños de sprite y perfiles siguen editables desde Resources individuales; no hay multiplicador global de escena.
- El preview y la torre construida comparten el sprite y tamaño configurado. Cambiar el PNG conserva el tamaño guardado en su Resource.
- La revisión visual en Godot queda pendiente a 1280×720 y 1440×900, incluidos texto, foco/hover de botones, recorte de sprites y panel durante build mode.

## Fuentes

- Petición directa del usuario en la sesión del 2026-10-09.
- `TowerData`, `EnemyData`, `BaseData` y los PNG existentes del proyecto.
