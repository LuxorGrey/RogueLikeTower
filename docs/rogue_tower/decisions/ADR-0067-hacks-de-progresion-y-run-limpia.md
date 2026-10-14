# ADR-0067: Hacks de progreso, tienda general y run limpia

- Fecha: 2026-10-13
- Estado: Aceptado por petición explícita del usuario; código integrado, aceptación manual pendiente.

## Contexto

Las cards de run solo se ofrecen al terminar las rondas definidas por `CardPoolData` (cada tres rondas en la demo). Probarlas requiere jugar combate y colocar expansiones. También se necesita revisar la tienda de mejoras permanentes desde cualquier fase y repetir una run sin efectos comprados.

## Decisiones

1. El panel de hacks `Ctrl+K` permite saltar desde preparación o expansión hasta la siguiente ronda que tenga oferta según `RunCardService.should_offer_after()`. El hack actualiza la ronda de campaña y abre el pool real de cards; las rondas y colocaciones omitidas no otorgan recompensas.
2. El panel puede abrir la pestaña de mejoras generales de la tienda permanente. El acceso de debug muestra un botón para volver al tablero. Las compras se guardan y se aplican al comenzar una run posterior, igual que en el acceso normal de post-run.
3. La primera versión de `Empezar run limpia` conservaba los desbloqueos; [ADR-0069](ADR-0069-desbloqueos-xp-y-feedback-de-altura.md) sustituye esa regla: el hack vuelve al arsenal inicial, reinicia mejoras permanentes y devuelve el XP gastado en ellas. El saldo XP no gastado y los contadores históricos se conservan. Las cards temporales se reinician al configurar el nuevo `RunCardService`.
4. La acción normal de nueva run mantiene la progresión permanente; el reinicio limpio se activa únicamente desde el panel de hacks para facilitar pruebas sin cambiar el loop de progresión aprobado.

## Consecuencias

- Se pueden inspeccionar cards sin esperar el combate ni colocar dos piezas entre ofertas.
- El test de run limpia permite volver a comprar las mejoras con el XP devuelto, mientras mantiene el guardado reversible desde la interfaz de la tienda.
- La secuencia de salto es solo una herramienta de depuración: no simula recompensas ni el crecimiento del terreno de las rondas omitidas.
- Falta probar en ventana la cadencia 3/6/9, el acceso a la tienda y el reinicio/rehacer compras.
