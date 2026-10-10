# Documentación de Rogue Tower

Esta es la única carpeta activa de documentación del juego. Empieza aquí para saber qué documento manda, qué describe el juego actual y qué sigue siendo una propuesta.

La comparación realizada el 2026-10-09 y sus discrepancias resueltas o pendientes están resumidas en [Auditoría documental](AUDIT.md).

## Autoridad

1. Las decisiones explícitas del usuario, registradas en los ADR y reflejadas en el diseño, prevalecen sobre el paquete importado y cualquier referencia externa.
2. [Diseño del juego](design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md) contiene las reglas propias aprobadas. Las páginas de [diseño](design/README.md) desarrollan esas reglas por tema; no son fuentes independientes. Si se contradicen, se resuelve la discrepancia y se registra un ADR antes de cambiar implementación.
3. El código y los Resources cargados describen el comportamiento implementado hoy. La especificación describe el comportamiento aprobado o deseado. Si difieren, [Progreso](design/09_PROGRESS.md) y [Aceptación](design/10_ACCEPTANCE_TESTS.md) deben hacer visible la diferencia; no se debe presentar un placeholder como diseño aprobado.
4. Los [ADR](decisions/README.md) explican decisiones, alcance y reemplazos. No duplican la especificación vigente; un ADR sustituido sirve como historial.
5. Las [referencias](references/README.md) documentan fuentes externas y datos aportados para comparar. No definen balance ni reglas propias por defecto.
6. El [backlog](backlog/CONTENT_CANDIDATES.md) conserva candidatos sin aprobar. Un candidato solo pasa al diseño activo tras una elección explícita y su ADR cuando corresponda.
7. El [archivo](archive/initial_import/README.md) conserva la importación original como historial. No es una especificación activa.

## Cómo leer el estado

El estado de diseño y el de implementación son independientes:

| Estado de diseño | Significado |
|---|---|
| **Confirmado** | Regla propia aprobada. |
| **Provisional** | Configuración temporal de la demo; puede cambiar sin redefinir la fantasía del juego. |
| **Candidato** | Idea pendiente de elección; no se implementa como regla final. |
| **Solo referencia** | Dato de otro juego o fuente externa; no tiene autoridad propia. |
| **Sustituido** | Decisión o texto histórico reemplazado por uno posterior. |

Para implementación, usa etiquetas concretas como **implementado en código**, **aceptación manual pendiente** o **TODO**. “Implementado” no convierte por sí solo un valor provisional en balance confirmado.

## Mapa

- [Diseño activo](design/README.md): diseño principal, roadmap, arquitectura, modelos, terreno, combate, progresión, nomenclatura, progreso y aceptación.
- [Decisiones](decisions/README.md): ADR de cambios de diseño y arquitectura.
- [Referencias](references/README.md): cuatro borradores personales y procedencia de las fuentes.
- [Backlog de candidatos](backlog/CONTENT_CANDIDATES.md): material externo o ideas propias aún no promovidas.
- [Nomenclatura canónica](design/12_NOMENCLATURE.md): nombres vigentes de entidades, estados, capas, recursos, cards y equivalencias propias.
- [Catálogo y escalado](design/13_CONTENT_ROSTER.md): roster activo y efectos/escalado configurados para torres, mejoras, enemigos y estados.
- [Campaña de 45 rondas](design/14_CAMPANA_45_RONDAS.md): tabla única de composición y 1.093 enemigos directos.
- [Auditoría de torres](design/15_AUDITORIA_SISTEMA_DE_TORRES.md): revisión del daño, mejoras, XP, Mana, cadencia, alcance, crítico y estados frente a la wiki.
- [Progresión de mejoras](design/16_PROGRESION_Y_SELECCION_DE_TORRES.md): límites, curvas, niveles por capa, prioridades y feedback de selección.
- [Importación archivada](archive/initial_import/README.md): snapshot del paquete recibido, incluido el JSON espejo.

## Incorporar un cambio

1. Decide y registra el cambio en un ADR si altera diseño, arquitectura o alcance.
2. Actualiza la página temática activa y los artefactos de implementación que dependan de ella.
3. Cambia el estado de implementación en Progreso y los criterios de Aceptación cuando aplique.
4. Mueve al backlog cualquier dato de referencia que siga sin aprobar; conserva su atribución y fuente.
5. Busca enlaces y nombres antiguos tras mover o renombrar documentos.
