# Rogue Tower

Tower Defense Roguelike con progresión roguelike y un mapa que el jugador expande para construir la ruta que tendrá que defender. El proyecto usa Godot 4.7, GDScript y una cuadrícula hexagonal lógica con terreno 2D de elevación visual.

## Fuente de verdad

Toda la documentación vigente, las decisiones, las referencias y los candidatos están reunidos en [`docs/rogue_tower/`](docs/rogue_tower/). Su [índice de autoridad](docs/rogue_tower/README.md) explica qué documento manda en caso de discrepancia. El diseño activo está en [design](docs/rogue_tower/design/README.md); el origen del paquete y las referencias constan en [ORIGEN.md](docs/rogue_tower/references/ORIGEN.md).

## Ejecutar

Abre el proyecto con Godot 4.7 y ejecuta `game/main/main.tscn`. La campaña contiene 45 rondas y 1.093 enemigos directos conforme a la tabla única de `docs/rogue_tower/design/14_CAMPANA_45_RONDAS.md`: al terminar una oleada, elige una de las tres piezas visuales de terreno, colócala en una ubicación legal y continúa; en las rondas programadas también aparecerá una oferta de mejoras. El modelo de cada enemigo incluye Health, Armor y Shield, resueltos en ese orden defensivo: Shield, Armor y Health. Cada perfil configura sus máximos; un máximo cero desactiva esa capa para ese enemigo. Las barras de las capas activas aparecen sobre el enemigo.

Controles principales: `1–7` seleccionan las torres disponibles durante preparación/combate, `P` pausa o reanuda, `F3` muestra herramientas de diagnóstico, `H` oculta o muestra el HUD, `Q/E` rota la pieza seleccionada, el botón central y arrastre desplazan el mapa, la rueda ajusta el zoom y `R` centra el tablero. Durante una elección de terreno solo se puede elegir, rotar, colocar o cancelar la pieza; iniciar ronda reanuda la partida desde `ROUND_PREP`.

## Estado

La campaña, las siete torres, las ofertas de terreno, la pausa, la meta-progresión y los hitos M0–M25 están integrados en código. La actualización M25 sincroniza obstáculos/cofres entre miniatura, ghost y tablero, restringe acciones durante la expansión y ofrece formas variables para prolongar rutas. La aceptación visual/interactiva en ventana Godot sigue pendiente; el [registro de progreso](docs/rogue_tower/design/09_PROGRESS.md) distingue lo integrado de lo que requiere revisión manual.
