# ADR-0005: navegación del mapa y visibilidad del HUD

- Estado: Aceptada para el prototipo M3.
- Fecha: 2026-10-08.

## Contexto

El mapa puede crecer más allá de la ventana y la interfaz de colocación tapa una parte de la vista. Se necesita mover y escalar el mundo sin alterar las coordenadas axiales ni el tamaño del HUD.

## Decisión

- Un `Camera2D` dentro de la escena principal desplaza y escala el tablero. El `CanvasLayer` conserva el HUD en coordenadas de pantalla.
- El botón central del ratón, mantenido y arrastrado, pannea la cámara; el movimiento se divide por el zoom para mantener una velocidad visual constante.
- La rueda hace zoom uniforme centrado en el cursor. El rango inicial configurable es `0.45×`–`2.5×`, con pasos multiplicativos de `1.12`.
- `H` alterna la visibilidad del HUD sin desactivar la navegación del mapa.
- `R` restablece zoom `1×` y centra la cámara sobre los límites actuales de las celdas confirmadas.
- Mientras se pannea no se mueve el ancla del ghost. Al soltar el botón central, la posición del cursor vuelve a actualizarla.

## Consecuencias

- La navegación queda desacoplada del `HexGrid`; pan y zoom no cambian coordenadas, ocupación ni validación.
- El zoom centrado en cursor facilita inspeccionar/posicionar piezas lejos del centro de la pantalla.
- No hay límites de cámara específicos por tamaño del mapa; `R` permite recuperar la vista del tablero.
- La sensibilidad, rango de zoom y teclas son controles provisionales que pueden ajustarse al probar la interfaz.

## Fuentes

- Requerimiento explícito del usuario en esta conversación, 2026-10-08.
- Godot Engine 4.7, clase `Camera2D`, https://docs.godotengine.org/en/4.7/classes/class_camera2d.html, consultada el 2026-10-08. Se usa `Camera2D` para el scroll del viewport y su propiedad `zoom` uniforme.
