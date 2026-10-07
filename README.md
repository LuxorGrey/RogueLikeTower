# Rogue Tower

Tower Defense Roguelike con progresión roguelike y un mapa que el jugador expande para construir la ruta que tendrá que defender. El proyecto usa Godot 4.7, GDScript y una cuadrícula hexagonal lógica con terreno 2D de elevación visual.

## Fuente de verdad

El paquete de diseño vigente está en [`docs/fuente_de_verdad/`](docs/fuente_de_verdad/). El documento principal es [Game Design — Source of Truth](docs/fuente_de_verdad/01_GAME_DESIGN_SOURCE_OF_TRUTH.md); el orden de trabajo está en [Implementation Roadmap](docs/fuente_de_verdad/02_IMPLEMENTATION_ROADMAP.md), y el estado actual en [Project Progress](docs/fuente_de_verdad/09_PROGRESS.md). El origen del paquete y las referencias consultadas constan en [ORIGEN.md](docs/fuente_de_verdad/ORIGEN.md).

## Ejecutar

Abre esta carpeta con Godot 4.7 y ejecuta `game/main/main.tscn`. La escena muestra el tablero inicial y las cinco piezas placeholder de M3. Elige una pieza en el HUD; mueve el cursor para ajustar su pivote al grid, gira con Q/E o con los botones, y confirma solo cuando el fantasma esté verde. El fantasma rojo explica por qué la colocación no es legal. Usa el botón central + arrastre para panear, la rueda para hacer zoom, `H` para ocultar/mostrar la interfaz y `R` para centrar el tablero. La ruta global spawn-base se añadirá en M4.

## Estado

La implementación anterior de terreno 3×3×3 se retiró al adoptar el paquete nuevo. M1 y M2 están implementados; M3 ya incluye datos y flujo de colocación, pendiente de inspección en Godot. El preview dibuja alturas y cliffs temporales, resalta por terreno al pasar el cursor sobre una cara superior y muestra `(q,r)` global en el HUD. Los hitos pendientes aparecen en el [documento de progreso](docs/fuente_de_verdad/09_PROGRESS.md).
