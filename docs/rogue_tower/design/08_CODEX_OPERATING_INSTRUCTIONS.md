# Instrucciones operativas para Codex

Estas son convenciones operativas del paquete inicial. Se aplican subordinadas a `AGENTS.md`, al [índice de documentación](../README.md) y a las instrucciones actuales del usuario. Para reglas de diseño, consulta [el diseño activo](01_GAME_DESIGN_SOURCE_OF_TRUTH.md); no uses el texto importado ni el código placeholder para revivir decisiones sustituidas.

## Cuando el usuario diga "avanza"
1. Leer `09_PROGRESS.md`.
2. Identificar el primer milestone incompleto.
3. Implementarlo.
4. Ejecutar proyecto/tests/checks disponibles.
5. Corregir errores.
6. Actualizar `09_PROGRESS.md`.
7. Responder con:
   - milestone completado;
   - archivos creados/modificados;
   - cómo probarlo;
   - decisiones provisionales introducidas;
   - siguiente milestone.

No pedir confirmación para decisiones técnicas internas reversibles.

## Cuándo SÍ detenerse
Detenerse y preguntar solo si:
- una decisión cambiaría una regla de diseño marcada como confirmada;
- requiere elegir temática/arte definitivo;
- requiere eliminar un sistema confirmado;
- existen dos alternativas incompatibles que afectarían significativamente al gameplay;
- el repositorio existente contradice esta documentación de forma no trivial.

## Calidad
- GDScript tipado siempre que sea razonable.
- `class_name` para tipos de dominio reutilizables.
- Signals con tipos.
- Evitar strings mágicos; IDs/enum centralizados.
- Métodos cortos.
- Nada de singletons para todo.
- Autoloads solo para estado global real.
- Resources para contenido.
- No mezclar UI con cálculo de combate.
- No mezclar renderer con autoridad del grid.
- Comentarios explican "por qué", no cada línea.

## Prototipo antes que contenido
Ejemplo:
- 1 enemigo antes de 8.
- 1 torre antes de 6.
- 2 piezas antes de 12.
- 1 carta antes de 20.

Validar sistema y después multiplicar contenido.

## Placeholders
Si falta arte:
- usar Polygon2D/Sprite placeholder;
- etiquetar terreno con iconos/colores debug;
- no bloquear implementación por assets.

## Compatibilidad
Objetivo: Godot 4.7.
No usar API obsoleta de Godot 3.x.
Si una API concreta es dudosa, consultar documentación 4.7 antes de implementarla.

## Git
Commits sugeridos por milestone:
`feat(hex): implement axial grid and rotation`
`feat(terrain): add seven-hex piece placement`
etc.

No mezclar refactors masivos con features salvo necesidad.
