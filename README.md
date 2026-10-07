# RogueLikeTower

Roguelite de defensa de torres centrado en diseñar rutas con losetas, combinar defensas y superar veinte oleadas. La presentación será 2D isométrica y usará los sprites CellTile del proyecto.

> **Estado del repositorio:** documentación y assets iniciales. Aún no contiene un proyecto Godot ejecutable.

## Cómo se juega

- En preparación, se elige una loseta entre tres, se rota en pasos de 90° y se coloca respetando la conexión de caminos.
- Se construyen y mejoran defensas, se elige cuándo comenzar y se resuelven oleadas automáticas.
- El mapa y las elecciones de mejora cambian las opciones defensivas durante una partida de veinte rondas.
- Las decisiones explícitas de este proyecto prevalecen sobre las reglas de los juegos de referencia.

## Dirección técnica y visual

- Motor previsto: Godot 4.7.
- Proyección 2D isométrica fija 2:1; paneo y zoom sin giro.
- Sprites de terreno: [`assets/CellTile`](assets/CellTile/).
- El tablero inicial es una cuadrícula fija de 9×9 casillas.
- Cada casilla/loseta grande se representa con hasta 3×3×3 CellTiles; dentro conserva nueve posiciones lógicas de construcción.

## Documentación

- [Resumen detallado del juego (GDD)](docs/GDD.md)
- [Plan de implementación](docs/IMPLEMENTATION_PLAN.md)
- [Formato editable de oleadas y cartas](docs/DATA_FORMATS.md)
- [Preguntas abiertas](docs/OPEN_QUESTIONS.md)
- [Inventario de CellTile](assets/CellTile/README.md)

## Inicio de implementación

La primera entrega jugable será el tablero isométrico, la generación de sus celdas, la selección con feedback claro y las reglas visuales de altura. Los enemigos, sus oleadas y las cartas vendrán después como datos editables, para que ampliar contenido no requiera reprogramar el sistema.
