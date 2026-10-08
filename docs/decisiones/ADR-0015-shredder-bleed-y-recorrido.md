# ADR-0015 — Bleed y recorrido de Shredder

- Estado: aceptada por la petición explícita del usuario, 2026-10-08.
- Contexto: Shredder estaba usando el multiplicador de vida del golpe directo y el daño fijo del Bleed M8. Además, proyectar la hoja al punto geométrico más cercano de toda la ruta podía saltarse la posición actual del objetivo.
- Decisión: el contacto de la hoja no aplica daño directo. Para cada enemigo atravesado, el `DamagePacket` asigna como presupuesto bruto total de Bleed el daño base restante de la hoja (10 en el primer enemigo, 9 en el segundo con la pérdida configurada de 1, etc.). El estado reparte el presupuesto entero entre sus ticks restantes, conservando exactamente el total bruto antes de las defensas.
- Defensa y tipos: cada tick sigue pasando por `DamageService`; armadura y multiplicadores por tag pueden reducir el daño efectivo en HP. El override es runtime por instancia de estado y no muta el `StatusEffectData` compartido.
- Recorrido: la hoja vuela desde la torre hasta la posición actual del objetivo seleccionado y luego avanza por los waypoints restantes de esa ruta. Comprueba cada segmento, registra un impacto por enemigo y desaparece al terminar la ruta o alcanzar daño base cero. Si hay bifurcaciones, sigue la ruta del objetivo inicial.
- Consecuencias: el debug de combate muestra el presupuesto bruto de Bleed para Shredder, no un daño directo estimado de cero. La prueba manual sin armadura confirma 10 HP totales en el primer enemigo y 9 en el segundo.
- Verificación pendiente: seguir la prueba manual M9.5 de [10_ACCEPTANCE_TESTS.md](../fuente_de_verdad/10_ACCEPTANCE_TESTS.md#roster-jugable-m95); esta revisión no ejecutó Godot ni pruebas automatizadas.
