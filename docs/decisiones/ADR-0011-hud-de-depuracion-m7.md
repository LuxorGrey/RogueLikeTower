# ADR-0011: HUD compacto y oleadas repetibles para depuración M7

- Estado: aceptada para el harness de depuración; no define el HUD final de M13.
- Fecha: 2026-10-08.

## Contexto

El HUD M7 acumulaba selector de perfiles, controles de terreno, estadísticas completas, estado del pipeline de daño y controles de torre en una única columna alta. Ocultaba el tablero y no dejaba repetir el fixture después de la primera oleada, lo que dificultaba comparar los perfiles de daño. Además, el editor del usuario informó que `DamageService`, `DamagePacket` y `DamageResult` no estaban disponibles como tipos globales al analizar scripts nuevos.

## Decisión

- La interfaz principal muestra únicamente estado de base/oleada, selector e inicio de oleada, resumen de torre y un renglón del objetivo actual (HP, armadura, regeneración y daño estimado).
- Una barra inferior ofrece botones persistentes con los atajos `1` Basic Bolt, `2` Perforadora y `3` Drenadora. El atajo/botón inicia el modo de construcción; repetir el mismo atajo lo cancela. Las torres se colocan con clic sobre Grass o Mountain libres.
- `F3` alterna el panel de diagnóstico de terreno (pieza, hover axial, validez, conexiones y herramientas). `D` conserva el overlay visual de rutas y `H` oculta o muestra toda la interfaz.
- Al terminar una muestra, el juego vuelve a `TERRAIN_EXPANSION`, habilita el selector y permite iniciar cualquiera de los fixtures disponibles más de una vez. Esta capacidad solo sirve para validación local de M7; M10 sigue definiendo rondas, incremento de número y victoria de run.
- Los nuevos scripts M7 se cargan por `preload` explícito y los límites entre `Tower`, `BuildController` y el pipeline usan `Node`/`RefCounted`, sin requerir que los tipos globales M7 estén previamente en la caché del editor. Los bits Físico/Fuego/Arcano mantienen sus valores 1/2/4 en los Resources para que sus datos no dependan de cargar una clase de combate.

## Consecuencias

- Se reduce el espacio ocupado por el HUD y los datos de diagnóstico siguen accesibles durante el combate.
- El jugador puede comparar perfiles y oleadas distintas en la misma ejecución, aunque la vida perdida de la base se conserva entre pruebas. Reiniciar la escena devuelve la base a su estado inicial.
- Los atajos son parte del harness M7, no un compromiso con controles finales. La revisión visual de layout, navegación de foco y repetición de fixtures es criterio manual en `10_ACCEPTANCE_TESTS.md`.
- La interfaz `RefCounted` evita fallos por orden de indexado de `class_name`, a costa de usar `get`/`set`/`call` en el pipeline M7. La validación manual debe confirmar que no haya errores de método/propiedad en tiempo de ejecución.

## Referencias

- `docs/fuente_de_verdad/02_IMPLEMENTATION_ROADMAP.md`, sección M7, consultado el 2026-10-08.
- `docs/fuente_de_verdad/03_TECHNICAL_ARCHITECTURE.md`, `09_PROGRESS.md` y `10_ACCEPTANCE_TESTS.md`, consultados el 2026-10-08.
- `.agents/skills/godot-master/references/ui-containers.md`, `resource-data-patterns.md` y `combat-system.md`, consultados el 2026-10-08.
