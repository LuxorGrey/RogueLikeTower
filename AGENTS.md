# Normas del proyecto Rogue Tower

## Documentación obligatoria

Cada cambio de diseño, código, contenido, datos, configuración o assets debe actualizar **todos los archivos del proyecto que describen o dependen de ese cambio**. Antes de cerrar una tarea:

1. Identifica las fuentes de verdad y artefactos afectados.
2. Actualiza el documento de diseño, glosario, ADR, esquema de datos, comentarios de configuración, guía de uso o notas de versión que corresponda. Evita duplicar texto innecesariamente; enlaza a la fuente de verdad.
3. Mantén requisitos, reglas, nombres, cifras y ejemplos coherentes entre los archivos afectados.
4. Si cambia una decisión, actualiza su ADR/registro y marca como sustituidas las reglas anteriores.
5. Informa qué documentación se sincronizó y señala cualquier parte pendiente o no verificable.

«Todos los archivos correspondientes» significa todos los artefactos relevantes para entender, editar, configurar, probar, importar, ejecutar o mantener la característica. No significa añadir una mención irrelevante a cada archivo del repositorio.

## Fuentes y assets externos

- Separa las reglas confirmadas del proyecto, propuestas de diseño y datos de juegos de referencia.
- Registra el título, URL, edición/versión si se conoce y fecha de consulta de las fuentes.
- No tomes una fuente comunitaria como balance vigente sin comprobar changelogs y discrepancias.
- No incorpores ilustraciones, sprites, modelos, tipografías ni assets de terceros sin licencia compatible. Las configuraciones mecánicas se pueden estudiar; el arte final debe ser propio o tener permiso/licencia.
- Las imágenes que aporte el usuario pueden conservarse dentro de `docs/.../referencias/` como material de consulta; no deben cargarse como assets del juego ni distribuirse con una build sin comprobar derechos y licencia.

## Diseño y tecnología

- Nombre de trabajo: **Rogue Tower**, hasta elegir otro.
- Referencia de gameplay principal: *Rogue Tower*. Investiga la wiki y las guías disponibles, y usa sus sistemas como base salvo cuando el usuario haya indicado una adaptación explícita. Documenta por separado hechos de referencia, consejos comunitarios y reglas propias; las decisiones expresas del usuario prevalecen.
- Motor objetivo: **Godot 4.7**.
- Presentación: **2D isométrica**, proyección fija 2:1 y sprites ordenados por profundidad. El terreno sigue el chunk lógico de 3×3 `PATH`/`GRASS`/`STONE` definido en [Sistema de losetas isométricas](docs/diseno/rogue-tower/sistemas/sistema-losetas-isometricas.md) y ADR-0013; no se modela como volumen CellTile 3×3×3.
- Para decisiones técnicas, consulta los módulos aplicables de `godot-master` y `godot-gdscript-patterns`; registra las decisiones de arquitectura en los documentos del proyecto.
