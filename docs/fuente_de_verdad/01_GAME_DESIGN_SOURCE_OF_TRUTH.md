# Game Design — Source of Truth

## 1. Pitch
Tower Defense Roguelike de runs cortas/medias donde el jugador no solo construye torres: **construye el propio tablero que tendrá que defender**.

La referencia sistémica principal es Rogue Tower, reducida a un scope de demo pequeño. La referencia visual/técnica del tablero es Urtuk: The Desolation: grid hexagonal lógica, arte 2D que simula volumen y elevaciones discretas.

## 2. Scope confirmado
- Motor: **Godot 4.7**.
- Género: Tower Defense + Roguelike.
- Demo: **20 rondas**.
- Grid: hexagonal.
- Expansión del mapa: tras limpiar las rondas 1–19 se ofrecen tres piezas distintas de siete hexágonos como cards visuales con solo el nombre y una vista de la pieza. Al elegir una, las tres permanecen en un inventario inferior para poder cambiar la selección antes de colocar; `Esc` vuelve a la oferta centrada con las mismas opciones. Al confirmar una pieza legal desaparece el inventario. Limpiar la ronda 20 completa la demo.
- El jugador coloca una pieza predefinida compuesta por **7 hexágonos**.
- La pieza puede rotarse en las 6 orientaciones hexagonales.
- Si contiene camino, sus conexiones deben ser válidas con el mapa existente.
- El mapa puede generar prolongaciones, bifurcaciones y convergencias.
- Tres niveles lógicos de altura: 0, 1, 2.
- Terrenos principales:
  - Camino: altura 0, transitable por enemigos, no construible.
  - Grass: construible; normalmente altura 1, pudiendo existir variantes elevadas según definición de pieza.
  - Montaña: altura 2, construible y con ventaja de altura.
- La base ocupa la huella visual completa de un hexágono y reserva su celda axial.
- Tras una expansión, los huecos completamente encerrados dentro de la envolvente axial del mapa se rellenan al azar con Grass o Montaña. Una abertura PATH que funcione como salida/spawn nunca se rellena.
- Los conjuntos conectados de Grass o Montaña brillan suavemente desde tres hexágonos; el resplandor es algo más intenso desde cinco. En esta fase es únicamente señal visual de combo, sin bonus de gameplay.
- Enemigos: el diseño confirmado prevé escudo, armadura y salud en ese orden de agotamiento; Bleed detiene la regeneración de salud, Burn la de armadura y Poison la de escudo. La capa de escudo y la transferencia del daño sobrante aún no están implementadas/decididas en el prototipo.
- La demo incluye minijefes en las rondas 17 y 19 y un jefe fijo de Tier 2 en la ronda 20. Su variante, habilidades y estadísticas finales siguen abiertas.
- Torres especializadas contra diferentes defensas/tipos de enemigo.
- Status effects inspirados en Rogue Tower, pero catálogo reducido.
- Upgrade Cards durante la run, reducidas/simplificadas.
- Permanent Upgrades entre runs, reducidas/simplificadas.
- El jugador recibe moneda meta al acabar una run, incluso si pierde pronto.
- Tienda permanente: mejoras y desbloqueo de nuevas torres.
- Maná existe como recurso/sistema.
- **No existen support buildings.**
- El maná y sus mejoras se obtienen mediante cartas/permanentes/sistemas de progresión, no edificios de soporte.

## 3. Core loop
1. Comienza run.
2. Cargar desbloqueos y mejoras permanentes.
3. Preparación de ronda.
4. Oleada: en cada pulso configurado aparecen simultáneamente enemigos en todos los finales PATH abiertos que tengan ruta a la base; el grupo conserva su número de pulsos por endpoint.
5. Jugador construye/mejora torres y administra recursos.
6. Resolver victoria/derrota de ronda.
7. Si sigue vivo: recompensa de ronda.
8. Fase de expansión: ofrecer tres cards visuales de piezas distintas de siete hexágonos; mostrar solo título y vista del terreno, conservar las tres en el inventario inferior mientras se coloca y retirarlas tras una colocación válida.
9. Rotar y colocar la pieza elegida legalmente; `Esc` vuelve a la misma oferta.
10. Cerrar con Grass/Montaña los huecos interiores, resolver nuevas conexiones/rutas y activar todas las salidas PATH abiertas.
11. Fase de carta/mejora cuando corresponda.
12. Siguiente ronda.
13. Ronda 20 superada = demo completada.
14. Al perder o completar: otorgar moneda meta.
15. Volver a tienda/meta.
16. Comprar mejoras/desbloqueos.
17. Nueva run.

## Reglas de combate confirmadas y pendientes de implementación
- Los enemigos tendrán capas de escudo → armadura → salud.
- La torre aplica daño base por el multiplicador de la capa activa. Falta decidir si el excedente al vaciar una capa pasa a la siguiente.
- Bleed contrarresta regeneración de salud, Burn la de armadura y Poison la de escudo. Se conservan los comportamientos actuales de los estados hasta implementar las capas faltantes.
- La demo coloca minijefes en las rondas 17 y 19 y un jefe Tier 2 fijo en la 20. No se ha elegido una de las tres variantes de referencia.
- Las cifras y apariencias de los enemigos de M10 son placeholders internos. Las tablas de Rogue Tower Wiki en `docs/borradores_personales/02_monstruos.md` son referencia comunitaria, no balance propio ni catálogo aprobado.

## 4. Fantasía estratégica
El mapa debe ser una decisión. Una pieza puede:
- aumentar la longitud de una ruta;
- abrir una bifurcación peligrosa;
- crear una convergencia/kill zone;
- dar una posición elevada excepcional;
- ampliar superficie construible;
- introducir un nuevo punto de entrada.

No debe existir una única decisión obvia en todas las expansiones.

## 5. Dificultad
Objetivo: conservar la sensación de presión de Rogue Tower. La progresión permanente debe ayudar, pero no sustituir la toma de decisiones.

Principio: un jugador nuevo probablemente no completa la run. Las derrotas alimentan meta-progresión y desbloqueos.

## 6. Sistemas deliberadamente fuera de scope
- Support buildings.
- Campaña narrativa compleja.
- Multijugador.
- PvP.
- Mundo 3D real.
- Terreno 3D/meshes como base del tablero.
- Generación procedural libre de geometría: las piezas son plantillas diseñadas.
- Más de 20 rondas en la demo.
- Contenido final masivo antes de validar vertical slice.

## 7. Decisiones todavía abiertas
No inventar como definitivas:
- Número total de torres del juego final. Para la demo, el usuario confirmó siete perfiles jugables en ADR-0014.
- Roster final de enemigos.
- Lista final de status.
- Fórmula exacta de altura.
- Número de cartas de mejora ofrecidas en M11; la oferta de expansión de terreno es de tres piezas.
- Frecuencia exacta de cartas.
- Economía/balance numérico final.
- Número exacto de piezas de terreno.
- Variante, habilidades y balance exactos de los jefes/minijefes.
- Balance definitivo para múltiples entradas; en la demo se usan todos los finales PATH abiertos y se spawnea por ellos simultáneamente.
- Arte/temática final.

Para el prototipo usar valores temporales centralizados y fáciles de sustituir.
