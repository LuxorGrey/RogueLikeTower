# Rogue Tower

Tower Defense Roguelike con progresión roguelike y un mapa que el jugador expande para construir la ruta que tendrá que defender. El proyecto usa Godot 4.7, GDScript y una cuadrícula hexagonal lógica con terreno 2D de elevación visual.

## Fuente de verdad

El paquete de diseño vigente está en [`docs/fuente_de_verdad/`](docs/fuente_de_verdad/). El documento principal es [Game Design — Source of Truth](docs/fuente_de_verdad/01_GAME_DESIGN_SOURCE_OF_TRUTH.md); el orden de trabajo está en [Implementation Roadmap](docs/fuente_de_verdad/02_IMPLEMENTATION_ROADMAP.md), y el estado actual en [Project Progress](docs/fuente_de_verdad/09_PROGRESS.md). El origen del paquete y las referencias consultadas constan en [ORIGEN.md](docs/fuente_de_verdad/ORIGEN.md).

## Ejecutar

Abre esta carpeta con Godot 4.7 y ejecuta `game/main/main.tscn`. La escena presenta la plantilla inicial de siete hexágonos, coloreada por terreno. Usa los botones o Q/E para rotarla en pasos de 60° entre sus seis orientaciones.

## Estado

La implementación anterior de terreno 3×3×3 se retiró al adoptar el paquete nuevo. La grilla lógica M1 está implementada; el preview de terreno de M2/M3 está en progreso. Los hitos y verificaciones pendientes aparecen en el [documento de progreso](docs/fuente_de_verdad/09_PROGRESS.md).
