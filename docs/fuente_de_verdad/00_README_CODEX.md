# Tower Defense Roguelike — Codex Handoff

## Objetivo
Este repositorio/documentación define el plan de implementación de una demo jugable en **Godot 4.7** de un **Tower Defense Roguelike** inspirado en la profundidad sistémica de Rogue Tower y en la representación 2D hexagonal con falsa elevación de Urtuk: The Desolation.

Codex debe tratar estos documentos como la fuente de verdad del proyecto.

## Regla principal para Codex
Cuando el usuario diga **"avanza"**, ejecutar el siguiente milestone incompleto de `02_IMPLEMENTATION_ROADMAP.md`, de principio a fin, sin volver a preguntar decisiones que ya estén resueltas aquí.

Antes de modificar código:
1. Leer `01_GAME_DESIGN_SOURCE_OF_TRUTH.md`.
2. Leer `03_TECHNICAL_ARCHITECTURE.md`.
3. Leer `04_DATA_MODELS.md`.
4. Consultar `05_HEX_GRID_AND_TERRAIN.md` para cualquier trabajo de mapa.
5. Consultar `06_COMBAT_SYSTEM.md` para combate.
6. Consultar `07_ROGUELIKE_PROGRESSION.md` para cartas/meta-progresión.
7. Actualizar `09_PROGRESS.md` al terminar.

## Principios
- Godot 4.7.
- GDScript tipado.
- Proyecto 2D.
- Sistemas data-driven mediante Resources `.tres`.
- Separar lógica de simulación y presentación.
- Nada de support buildings.
- Demo: 20 rondas.
- No sobrearquitecturar.
- Primero placeholders; arte final después.
- Cada milestone debe dejar el proyecto ejecutable.
- Nunca implementar contenido masivo antes de validar el sistema con 1-3 ejemplos.
- No introducir sistemas no aprobados como crafting, inventario de objetos, héroes, PvP, etc.

## Definition of Done de cada milestone
- Proyecto abre sin errores.
- No hay errores rojos en debugger.
- Feature verificable jugando.
- Código tipado y organizado.
- Datos configurables desde Resources.
- Se añaden pruebas unitarias/lógicas donde tengan sentido.
- Se actualiza `09_PROGRESS.md`.
