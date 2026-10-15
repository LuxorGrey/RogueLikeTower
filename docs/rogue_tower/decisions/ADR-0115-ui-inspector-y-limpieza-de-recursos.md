# ADR-0115 — UI editable desde Inspector y limpieza de recursos

- Fecha: 2026-10-15
- Estado: escaneo headless y smoke de escena principal pasados; aceptación de Inspector y revisión visual pendiente. El sandbox impidió guardar el inicio de run de prueba y las preferencias del editor.
- Decisiones relacionadas: desarrolla ADR-0049/0050 para configuración de UI; el ajuste de iconos de estado sustituye el tamaño 44×44 px de ADR-0107. No cambia las reglas de M63.

## Contexto

La UI ya se construye principalmente con escenas `.tscn`, pero varios scripts reasignaban fuentes, márgenes, estilos, tamaños y posiciones al iniciar. Esto hacía que cambios del Inspector se perdieran o que los controles creados durante la partida carecieran de una configuración visible. También quedaban hojas PNG y Resources de oleadas DEBUG sin consumidores después de retirar el selector F3.

## Decisiones

1. Los valores estáticos de tipografía, espaciado y estilo viven en escenas, Themes o StyleBoxes asignados desde Inspector. Para contenido generado durante la partida, la escena/script propietario expone los tamaños, fuentes, separaciones y colores que usa; el código no sustituye esos valores por constantes ocultas.
2. Las ofertas de mejora conservan su jerarquía `.tscn`; los StyleBoxes y el material de aura se asignan en la escena. Se exponen en Inspector las dimensiones del panel y las cartas, la distribución del mapa permanente, los enlaces, el timeline, el feedback de enemigo, las dos composiciones de cards de terreno, los colores de estado HUD, el tamaño adaptable del botón de ronda, las dimensiones/pulso del cursor y los tamaños de VFX.
3. El marcador de portal se convierte en un `Label` estático de `spawn_portal.tscn`. El mapa permanente contiene su título central en `meta_progression_map.tscn`. Los estilos de XP H/A/S se configuran en la escena reutilizable `TowerLayerUpgradeButton`.
4. Los iconos de estado del enemigo pasan de 44×44 a 28×28 px, con 5 px de separación. La colocación, el contador de stacks, las barras H/A/S y el texto flotante de daño quedan configurables desde el Inspector del nodo Enemy. El contador de vida segmentada expone fondo/borde/grosor; el burst del mapa permanente expone colores, cantidad, tamaño, distancia y duración; el confeti de resumen expone su tamaño.
5. Los 25 iconos de `assets/sprites/ui/icons/` limitan la textura importada a 256 px; la hoja del portal a 768 px y el cofre conserva el límite existente de 168 px. Se mantienen intactos los PNG fuente. La hoja del portal conserva dos píxeles importados por píxel de frame a su tamaño de dibujo de 96 px.
6. Se retiran los 26 PNG alternativos sin consumidor autorizados por el usuario, el marco antiguo de Tower Info, el script `SpawnPortalPreviewLayer` sin instancias y los Resources de enemigo/oleada M7/M8 sin selector ni prueba activa. Se conservan Armor Piercing Bolt, Sapping Bolt y Status Probe porque siguen disponibles en runtime con los atajos `8`, `9` y `0`.
7. No se modifica el combate, la economía, la campaña ni los Resources que alimentan el juego normal. Los procedimientos que dependían de F3 o de las oleadas retiradas quedan marcados como históricos; la aceptación vigente usa la campaña y los criterios M12A/M13/M63.

## Consecuencias

- El Inspector de las escenas relevantes expone las medidas de UI y los recursos de estilo que determinan la presentación en runtime.
- Se reduce memoria de texturas importadas para iconos y hojas grandes sin perder los originales de arte.
- El estado de implementación es M64; la aceptación visual en ventana sigue pendiente.
- El escaneo headless del editor y el smoke de tres frames de `game/main/main.tscn` terminaron con código 0, sin errores GDScript ni recursos faltantes. La aceptación en ventana se mantiene pendiente en [Progreso](../design/09_PROGRESS.md) y [Aceptación](../design/10_ACCEPTANCE_TESTS.md).
