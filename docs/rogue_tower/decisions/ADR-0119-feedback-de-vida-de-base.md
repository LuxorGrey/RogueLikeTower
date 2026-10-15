# ADR-0119 — Feedback de vida de la base

- Fecha: 2026-10-15.
- Estado: código y documentación integrados; aceptación visual pendiente.
- Decisiones relacionadas: ADR-0074 define la vida y derrota de Main Tower; ADR-0115 mantiene el HUD editable desde Inspector.

## Contexto

El HUD mostraba la vida de Main Tower como bloques de 10 HP y con una barra baja. La pérdida de un punto no era fácil de leer, y el estado crítico de la base no tenía una señal ambiental persistente.

## Decisiones

1. Aumentar aproximadamente un 50 % el tamaño del indicador de vida: alto de barra de 28 a 42 px y más ancho disponible en la fila superior izquierda. Mantener el estado `actual / máximo` y la pausa junto a la barra.
2. Dibujar un segmento independiente por cada HP, también cuando una mejora amplíe la vida máxima. Al perder uno o más segmentos, cada cuadro perdido hace un flash ámbar, se encoge y se desvanece durante 0,28 s.
3. Cambiar el color del relleno de forma continua según la proporción restante: verde a vida completa, ámbar a la mitad y rojo cerca de cero, usando los colores editables de Main.
4. Añadir una viñeta rojo oscuro a pantalla completa por detrás del HUD. Se activa con 3 HP, gana intensidad con 2 HP y con 1 HP mantiene una respiración lenta de amplitud baja (periodo de 2,8 s) para sostener tensión sin parpadear ni cubrir el centro de la pantalla.
5. Basar la viñeta en HP actuales absolutos y retirarla al superar 3 HP; las intensidades y parámetros visuales quedan editables desde Inspector.

## Consecuencias

- Cada golpe a la base tiene una representación discreta en la barra, mientras el degradado refuerza la tendencia de vida restante.
- Los umbrales de 3/2/1 HP mantienen una lectura estable aunque el máximo de vida aumente por Fortification.
- La viñeta queda debajo de HUD y no bloquea entradas. Al permanecer a 1 HP, su pulso lento y limitado evita el flash rápido o la vibración continua.
- Falta la revisión visual en ventana Godot; no se ejecutó Godot ni se añadieron pruebas en este cambio.

## Implementación

- `game/ui/segmented_health_bar.gd`
- `game/ui/base_health_vignette.gdshader`
- `game/main/main.tscn`
- `game/main/main.gd`
- `docs/rogue_tower/design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md`
- `docs/rogue_tower/design/10_ACCEPTANCE_TESTS.md`
