# ADR-0055: Feedback de base, selección y recompensas

- Fecha: 2026-10-13.
- Estado: aceptado; código integrado, aceptación visual pendiente.
- Complementa: ADR-0038, ADR-0045, ADR-0051 y ADR-0052.
- Alcance: respuesta visual al daño de la base, recompensas Gold, selección de cartas y escala del sprite del portal. No cambia cálculos de combate, economía, oleadas ni rutas.

## Contexto

El usuario pidió feedback de combate y selección más evidente, pero breve y claro: la base debe avisar al recibir daño; Gold debe reaccionar al ganarse y al abrir cofres; las ofertas de terreno/mejoras deben destacar sobre el tablero; y el portal de aparición debe ocupar menos espacio.

## Decisiones

1. Cuando `WaveDirector` comunica daño positivo a la base, `Main` activa un tinte rojo temporal del sprite de base y una sacudida breve de `Camera2D.offset`. La cámara conserva su posición y zoom.
2. El grupo de icono y cifra de Gold recibe un golpe inmediato de escala, color e inclinación y vuelve con una secuencia breve de rebote. Así el efecto no depende de alcanzar un pico gradual ni pierde su énfasis cuando entran varias recompensas seguidas. Las ganancias y cofres con recompensa positiva usan la señal `gold_changed`; abrir un cofre sin Gold aceptado también anima el grupo una vez.
3. `SelectionBackdrop`, un `ColorRect` negro translúcido que ignora el ratón, queda bajo los controles del HUD. Se muestra para ofertas de terreno sin pieza elegida y para ofertas de mejora. Se oculta al elegir la pieza de terreno para colocar, y reaparece si se cancela la colocación y retorna la oferta.
4. El sprite de `SpawnPortal` reduce su caja visual de 112×168 a 64×96 px; se ajusta el desplazamiento vertical para conservar su alineación con el terreno. No se altera el área de interacción ni la previsualización de enemigos.

## Consecuencias

- El jugador recibe señales visuales acotadas en los eventos solicitados sin cambiar resultados de partida.
- El oscurecimiento queda detrás de las cards y no intercepta entradas.
- La intensidad/legibilidad y el anclaje del portal requieren revisión en ventana Godot.

## Referencias

- [Arquitectura técnica](../design/03_TECHNICAL_ARCHITECTURE.md).
- [Pruebas de aceptación visual](../design/10_ACCEPTANCE_TESTS.md).
- [ADR-0038: sprite de base y feedback de HUD](ADR-0038-base-sprite-y-feedback-del-hud.md).
- [ADR-0051: navegación y portales](ADR-0051-navegacion-prevision-portales-y-panel-torre.md).
