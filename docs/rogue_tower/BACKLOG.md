# Rogue Tower — backlog no aprobado

Las propuestas de este archivo no forman parte del diseño aprobado hasta que el usuario las confirme. La regla vigente está en PROJECT_SPEC.md.

<a id='candidates'></a>
## Candidatos y propuestas no aprobadas

Este backlog recoge material de referencia que todavía no es una regla del juego propio. Para promover una entrada hay que aprobar su alcance y sus reglas en una decisión; hasta entonces no se implementan como requisito ni se mezclan con el balance de la demo.

### Enemigos y jefes

- [ ] Contenido posterior a la ronda 45 y familias alternativas de Rogue Tower (por ejemplo, Undead y Ephemerald) fuera de la tabla aprobada.
- [ ] Habilidades y variantes de Rogue Tower no seleccionadas para los 26 perfiles de campaña.
- [ ] Más contenido de enemigos, jefes, sprites y sus pruebas para futuras campañas.
### Torres, progresión y estados

- [ ] Reglas de elevación, XP y niveles, más detalles/árboles completos de cartas de [Torres](CONTENT_AND_ASSETS.md#reference-towers). Los parámetros base de las siete torres sí se promovieron y están en el catálogo activo; las reglas no elegidas no se infieren del material de referencia.
- [ ] Freeze y sinergias adicionales de cartas de [Efectos de estado](CONTENT_AND_ASSETS.md#reference-effects). El juego propio implementa Haste y Fortification mediante habilidades enemigas; cualquier expansión del catálogo exige reglas y pruebas propias.
- [ ] Economía, drops de oro, cofres, XP y frecuencia de cartas extraídos de la referencia; la meta-progresión vigente se define por ADR-0022 y los datos configurables del proyecto.

### Criterio de promoción

Antes de aprobar un candidato, decidir explícitamente: alcance (demo o después), comportamiento, números propios o provisionales, condiciones límite, impacto técnico y aceptación. Registrar la decisión, enlazarla desde el documento activo y mantener el dato externo atribuido en Referencias. Si una pregunta no está resuelta, el estado sigue siendo **Candidato**.

### Promovido

- [Árbol compatible de Upgrade Cards y Permanent Upgrades](DECISION_HISTORY.md#adr-0062): integrado con la cadencia cada tres rondas y los filtros propios del roster. Permanecen fuera las torres/sistemas no implementados, Freeze y cambios de frecuencia incompatibles.
