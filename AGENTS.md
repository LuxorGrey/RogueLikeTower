# Instrucciones de trabajo — Rogue Tower

Lee primero el [índice documental](docs/rogue_tower/README.md). La documentación activa está reunida en pocos documentos; cada regla debe tener un solo propietario. No restaures referencias a los Markdown históricos ni dupliques su contenido.

## Fuente de verdad

- [Especificación del proyecto](docs/rogue_tower/PROJECT_SPEC.md): reglas aprobadas de juego, arquitectura, datos, terreno, combate y progresión.
- [Contenido y arte](docs/rogue_tower/CONTENT_AND_ASSETS.md): nombres canónicos, campaña, roster, assets y fuentes.
- [Implementación y QA](docs/rogue_tower/IMPLEMENTATION_AND_QA.md): roadmap, milestone vigente, estado de implementación, auditorías y criterios de aceptación.
- [Historial de decisiones](docs/rogue_tower/DECISION_HISTORY.md): ADRs y contexto histórico; no sustituye la regla activa en la especificación.
- [Backlog](docs/rogue_tower/BACKLOG.md): propuestas sin aprobar; no son requisitos.

Si una instrucción explícita reciente del usuario cambia una regla, actualiza su única sección propietaria, la implementación afectada y el estado/criterios que dependan de ella. Registra el motivo y las sustituciones en el historial de decisiones. Si código o Resources contradicen el diseño aprobado, informa el desfase en Implementación y QA y corrige el artefacto pertinente; el estado runtime no convierte por sí solo una propuesta en diseño aprobado.

## Contrato vigente del proyecto

- Motor Godot 4.7; usa GDScript tipado siempre que sea razonable.
- Juego 2D sobre retícula hexagonal axial; la elevación es lógica y visual, sin terreno 3D.
- Elevaciones 0–3: PATH siempre 0, Grass 1–2 y Mountain 2–3. Las piezas de expansión tienen siete hexágonos.
- Demo de 45 rondas; no hay edificios de soporte. Crafting, inventario de objetos, héroes y PvP quedan fuera de alcance.
- Mantén diferenciados diseño aprobado, propuesta provisional, contenido runtime y referencia externa. Los valores no confirmados deben seguir configurables.
- Usa nombres canónicos del apartado [Nomenclatura](docs/rogue_tower/CONTENT_AND_ASSETS.md#canonical-names). No importes balance o habilidades por reutilizar nombres.
- No añadas assets de terceros sin licencia compatible; las referencias visuales no se importan como assets.

## Flujo de trabajo

- Para «avanza», sigue el primer milestone incompleto de [Implementación y QA](docs/rogue_tower/IMPLEMENTATION_AND_QA.md#roadmap), sin volver a preguntar decisiones ya resueltas.
- En tareas Godot, aplica los módulos pertinentes de `.agents/skills/godot-master/` y `.agents/skills/godot-gdscript-patterns/`. No uses APIs de Godot 3.x.
- Prefiere tipos de dominio reutilizables y Signals tipados, IDs/Enums frente a strings mágicos, Resources para contenido y métodos breves. Evita convertir todo en Autoload.
- Conserva responsabilidades separadas: UI y cálculo de combate, renderer y autoridad del grid, estado global y sistemas locales.
- Pide aclaración solo cuando falte una decisión aprobada necesaria o haya alternativas incompatibles que cambien materialmente el diseño. Avanza con las partes independientes.
- Al cerrar un cambio, actualiza únicamente los documentos propietarios afectados y los enlaces relevantes; no crees un documento nuevo para cada cambio.
- Mantén el contenido histórico etiquetado como tal. No restaures contenido importado sustituido por decisiones posteriores.
