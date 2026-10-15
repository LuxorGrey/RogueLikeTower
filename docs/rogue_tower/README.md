# Rogue Tower — documentación

<a id='index'></a>

Empieza aquí. Los temas están reunidos por función; cada regla activa tiene un único documento propietario.

## Documentos

| Documento | Autoridad |
|---|---|
| [Especificación del proyecto](PROJECT_SPEC.md) | Diseño aprobado, arquitectura, modelos, terreno, combate y progresión. Fuente normativa de reglas. |
| [Contenido y assets](CONTENT_AND_ASSETS.md) | Nombres canónicos, roster, campaña, balance ejecutable de referencia, arte y procedencia de assets. Los valores runtime efectivos siguen en código y Resources. |
| [Implementación y QA](IMPLEMENTATION_AND_QA.md) | Roadmap, milestone y estado actuales, auditorías históricas identificadas como snapshots y criterios de aceptación. |
| [Historial de decisiones](DECISION_HISTORY.md) | ADRs: motivo, contexto, fecha y evolución. Es historial; para la regla vigente vuelve a la Especificación. |
| [Backlog](BACKLOG.md) | Propuestas sin aprobar. No son requisitos de implementación. |

## Precedencia y mantenimiento

1. Una instrucción explícita reciente del usuario prevalece y actualiza la sección propietaria de la Especificación o de Contenido y assets.
2. Código, escenas y Resources describen el comportamiento y los valores que ejecuta el checkout; la documentación define el diseño aprobado. Si divergen, anota el desfase en Implementación y QA y corrige el propietario correspondiente.
3. El Historial explica por qué evolucionó una regla, pero no la vuelve a definir. Las referencias importadas y externas son contexto, no autoridad del proyecto.
4. Al cambiar diseño o arquitectura, añade una entrada ADR al final del Historial y actualiza la sección propietaria. Actualiza Implementación y QA solo si también cambia el estado, el próximo paso o la aceptación.
5. No crees un Markdown por cada cambio. Mantén el índice y los enlaces de estos documentos; deja aquí solo la información que tenga un propietario claro.

El paquete inicial de diseño se conserva dentro de Contenido y assets como referencia histórica. Las decisiones posteriores del usuario prevalecen sobre él. Para continuar el trabajo, consulta [el primer milestone incompleto](IMPLEMENTATION_AND_QA.md#roadmap) y el estado más reciente en [Implementación y QA](IMPLEMENTATION_AND_QA.md#progress).
