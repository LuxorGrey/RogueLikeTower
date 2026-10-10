# ADR-0052: Números de daño animados y legibles

- Fecha: 2026-10-10
- Estado: Aceptado; código integrado, revisión visual pendiente
- Decisores: usuario y equipo del proyecto
- Sustituye: ninguna

## Contexto

El daño ya se mostraba con un `Label` flotante, pero todos los impactos aparecían centrados y con tamaño/recorrido casi idénticos. Los ataques simultáneos se amontonaban. El usuario pidió adaptar la presentación del reel de CapyEmber, que combina entrada con golpe, trayectorias alternas, color semántico y énfasis de críticos.

## Decisiones

1. El feedback se dispara después de `DamageService.damage_resolved` cuando el resultado aplica daño positivo. Es presentación; no modifica `DamagePacket`, `DamageResult`, HP, estados ni cadencia.
2. Cada número entra con una escala breve tipo punch, asciende por dos tramos que forman un arco y alterna izquierda/derecha. Rota entre tres alturas iniciales para reducir solapamientos. Se desvanece y se libera al terminar su tween.
3. Health usa rojo, Armor ámbar y Shield cian, tanto en el texto como en el flash breve del sprite. El tamaño usa la proporción entre el daño y una media móvil por enemigo, limitada para conservar la legibilidad.
4. El crítico añade `CRIT`, mayor tamaño y contorno más fuerte sin sustituir el color de la capa afectada.
5. Los indicadores siguen siendo `Label` dinámicos dentro del mundo (`Entities`), como en la arquitectura M22; el tween está enlazado a la vida del propio indicador para que sobreviva si su enemigo muere durante la animación.

## Consecuencias

- Una sucesión de impactos en el mismo objetivo distribuye los valores por ambos lados y conserva la relación visual entre magnitud, capa y crítico.
- El daño se comprime visualmente con límites; no se promete equivalencia numérica con el tamaño del texto del reel.
- Sigue pendiente comprobar legibilidad y rendimiento con la oleada más densa y torres de cadencia alta. Si la revisión muestra presión de nodos, el siguiente ajuste será agrupar o reutilizar indicadores sin alterar el cálculo del combate.

## Referencias

- CapyEmber, «How I make damage numbers that feel good, with hundreds of enemies on screen», Instagram Reels, https://www.instagram.com/reels/DeSHBhkoEYE/, consultado el 2026-10-10.
- [Sistema de combate](../design/06_COMBAT_SYSTEM.md), sección «Feedback visual de impacto».
- [Aceptación manual M24](../design/10_ACCEPTANCE_TESTS.md).
