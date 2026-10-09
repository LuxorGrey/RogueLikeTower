# ADR-0015 — Bleed y recorrido de Shredder

- Estado: recorrido y presupuesto Bleed aceptados; la ausencia de daño directo queda sustituida por ADR-0023, 2026-10-08.
- Contexto: Shredder estaba usando el multiplicador de vida del golpe directo y el daño fijo del Bleed M8. Además, proyectar la hoja al punto geométrico más cercano de toda la ruta podía saltarse la posición actual del objetivo.
- Decisión histórica de M9.5: el contacto de la hoja no aplicaba daño directo. ADR-0023 sustituye esa parte: cada contacto ahora aplica daño directo según H/A/S y añade Bleed con un presupuesto bruto igual al daño base restante de la hoja (10, 9, 8…). El estado reparte el presupuesto entero entre sus ticks restantes.
- Defensa y tipos: cada tick sigue pasando por `DamageService`; armadura y multiplicadores por tag pueden reducir el daño efectivo en HP. El override es runtime por instancia de estado y no muta el `StatusEffectData` compartido.
- Recorrido: la hoja vuela desde la torre hasta la posición actual del objetivo seleccionado y luego avanza por los waypoints restantes de esa ruta. Comprueba cada segmento, registra un impacto por enemigo y desaparece al terminar la ruta o alcanzar daño base cero. Si hay bifurcaciones, sigue la ruta del objetivo inicial.
- Consecuencias históricas reemplazadas: ahora se verifica tanto el impacto directo como el presupuesto de Bleed; la prueba nueva está en la sección M12A de `10_ACCEPTANCE_TESTS.md`.
- Verificación pendiente: seguir la prueba manual M9.5 de [10_ACCEPTANCE_TESTS.md](../design/10_ACCEPTANCE_TESTS.md#roster-jugable-m95); esta revisión no ejecutó Godot ni pruebas automatizadas.
