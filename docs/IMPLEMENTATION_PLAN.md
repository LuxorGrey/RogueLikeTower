# Plan de implementación

El orden reduce riesgo: primero se valida la lectura del tablero y la interacción; después se añaden reglas de rutas y combate; por último se escala el contenido con datos tabulares.

## 0. Base de proyecto

- Crear el proyecto Godot 4.7, escena principal, configuración de resolución y carpetas `scenes/`, `scripts/`, `data/`, `assets/` y `ui/`.
- Mantener el modelo lógico fuera de la vista: coordenadas enteras y tipos de celda, con render isométrico intercambiable.
- Inventariar dimensiones, pivotes, escala y variantes de los sprites CellTile antes de fijar la proyección de pantalla.
- Mantener separadas las 81 casillas lógicas del tablero, el volumen visual de hasta 27 CellTiles por casilla y sus nueve posiciones de construcción.

## 1. Generación de cuadrícula y render isométrico — primer núcleo

1. Generar el tablero inicial fijo de 9×9 casillas confirmado por el usuario.
2. Representar cada celda con datos explícitos (coordenada, tipo de terreno, altura, camino/conector, ocupación e indicadores de construcción), no con el color o píxel del sprite.
3. Crear una transformación única entre coordenadas de rejilla y pantalla isométrica 2:1. Todas las celdas, hit tests, resaltados y previews usan esa transformación inversa/forward compartida.
4. Cargar las variantes CellTile por tipo y altura, elegir variantes de forma reproducible con una semilla y evitar cambiar la apariencia al hacer zoom o al actualizar la escena.
5. Renderizar suelo/celda base primero, capas de altura después y elementos con anclaje en el punto de apoyo. Ordenar por profundidad y usar la altura como desempate.
6. Probar visualmente terreno, camino, piedra, escalera y cambios de altura con el inventario recibido; definir qué sprite corresponde a cada tipo antes de añadir decoraciones.

**Resultado:** tablero isométrico visible, estable, reproducible y con hit testing alineado con lo que se ve.

## 2. Selección de celdas e interfaz limpia — primer núcleo

- Estados de interacción separados: normal, hover/foco, seleccionado, construible, bloqueado, ocupado y preview.
- Prioridad visual: contraste de borde/silueta y patrón/icono además del color. Evitar que una selección oculte camino, altura o tipo de terreno.
- Mostrar panel contextual compacto para la celda enfocada: terreno, altura, contenido y motivo de bloqueo.
- La selección de loseta muestra preview en el tablero; rotar actualiza inmediatamente orientación, conectores y ocupación.
- Confirmar coloca solo una opción legal; cancelar devuelve a elección sin alterar el tablero.
- Añadir navegación por ratón y teclado desde el principio; decidir gamepad y teclas exactas después.
- Comunicar acciones con feedback visual breve y consistente: selección, rotación, colocación válida, conexión inválida, ocupado y recompensa/región completada.
- Mantener el HUD fuera del área de interacción de celdas y dejar visibles ronda, integridad y recursos.

**Resultado:** el jugador siempre entiende qué celda controla, qué ocurrirá al confirmar y por qué una acción no es válida.

## 3. Reglas de losetas y preparación

- Codificar patrones, conectores de borde, rotaciones y campamentos como datos.
- Separar validación de adyacencia de conectividad real hasta la base.
- Generar ofertas de tres patrones distintos y garantizar que exista una colocación legal o una alternativa de reemplazo.
- Conectar los nueve emplazamientos de construcción al modelo lógico de la loseta grande; rotar también sus máscaras.
- Mostrar razones de invalidez y previsualizar cambios de camino/región antes de confirmar.
- Añadir edificios y mejoras de torres de forma incremental después de validar el loop de colocación.

## 4. Grafo y rutas congeladas por oleada

- Construir el grafo desde puertos de patrón y conectividad interna, no desde el dibujo.
- Validar que caminos nuevos enlacen con la red de la base.
- Modelar campamentos como cierres/divisores explícitos.
- Encontrar extremos abiertos válidos y calcular una ruta simple por tipo de enemigo antes de cada oleada.
- Congelar rutas al empezar; la ruta no cambia durante el combate.
- Mostrar la ruta prevista y entradas antes de pulsar «Siguiente oleada».

## 5. Oleadas y enemigos editables como hoja de cálculo

- Separar catálogo de enemigos de programación de oleadas.
- Definir una fila por grupo de aparición: ronda, orden, tipo, cantidad, intervalo, entrada/selector, escala de vida, escala de velocidad y si es jefe.
- Resolver la hoja a una secuencia ordenada para el juego. Los grupos se repiten por datos, no por scripts nuevos.
- Mantener habilidades especiales como propiedades/efectos declarativos con claves soportadas por el motor.
- Crear validador de datos para ids inexistentes, rangos negativos, grupos sin entrada, jefes fuera de hito y campos requeridos.
- Poder revisar y balancear todas las veinte rondas en LibreOffice/Excel y guardar el CSV versionado como fuente de verdad.
- Probar cada ronda aislada con una semilla fija y luego probar la campaña completa.

## 6. Combate, recursos y recompensas

- Añadir movimiento determinista sobre ruta, objetivo, alcance, ataque, salud, estados y fuga.
- Implementar construcción/mejoras solo en preparación y bloqueo durante combate.
- Añadir integridad base (20), fuga normal (1) y jefe letal; las cifras quedan en datos de balance.
- Modelar oro y maná separados, recompensas por ronda/bajas/regiones y coste de torres.
- Usar telemetría o resumen de run para detectar oleadas imposibles y economía que se agota antes del hito.

## 7. Cartas progresivas y metaprogresión

- Comenzar con un conjunto pequeño de cartas de efecto directo y campos de datos comunes.
- Limitar elecciones tempranas a opciones fáciles de leer; aumentar sinergias, requisitos, rareza y efectos condicionales gradualmente.
- Definir frecuencia de oferta, pool por ronda/hito, duplicados, exclusiones y recompensas de jefe como datos.
- Separar mejoras de run de desbloqueos permanentes.
- Validar que cada carta tenga texto legible, efecto soportado, objetivo válido y frecuencia permitida.

## 8. Arte final, accesibilidad y beta

- Integrar variantes finales y normalizar pivotes/escala.
- Añadir señales no basadas solo en color, ajuste de escala de interfaz y límites de zoom.
- Completar una run de veinte rondas con un contenido compacto y todos los sistemas incluidos.
- Ajustar economía, integridad, duración objetivo de 30–45 min y carga de decisiones.
- Dejar para después variedad amplia, tutorial final y contenido de progresión extensivo.

## Criterios de salida del primer núcleo

- La rejilla 9×9 se genera de forma reproducible y sus sprites coinciden con los datos lógicos.
- La proyección 2:1 y el hit testing apuntan a la misma celda.
- Hover, selección, celdas bloqueadas y preview se entienden con color y con forma/patrón.
- Una acción inválida explica el motivo y una acción válida confirma sin saltos visuales.
- Las 81 casillas lógicas, sus capas visuales CellTile y las nueve posiciones de construcción permanecen independientes en el modelo.
