# Game Design — Source of Truth

## 1. Pitch
Tower Defense Roguelike de runs cortas/medias donde el jugador no solo construye torres: **construye el propio tablero que tendrá que defender**.

La referencia sistémica principal es Rogue Tower, reducida a un scope de demo pequeño. La referencia visual/técnica del tablero es Urtuk: The Desolation: grid hexagonal lógica, arte 2D que simula volumen y elevaciones discretas.

## 2. Scope confirmado
- Motor: **Godot 4.7**.
- Género: Tower Defense + Roguelike.
- Demo: **20 rondas**.
- Grid: hexagonal.
- Expansión del mapa: al terminar cada ronda.
- El jugador coloca una pieza predefinida compuesta por **7 hexágonos**.
- La pieza puede rotarse en las 6 orientaciones hexagonales.
- Si contiene camino, sus conexiones deben ser válidas con el mapa existente.
- El mapa puede generar prolongaciones, bifurcaciones y convergencias.
- Tres niveles lógicos de altura: 0, 1, 2.
- Terrenos principales:
  - Camino: altura 0, transitable por enemigos, no construible.
  - Grass: construible; normalmente altura 1, pudiendo existir variantes elevadas según definición de pieza.
  - Montaña: altura 2, construible y con ventaja de altura.
- Enemigos: vida, armadura, regeneración y estadísticas/counters.
- Torres especializadas contra diferentes defensas/tipos de enemigo.
- Status effects inspirados en Rogue Tower, pero catálogo reducido.
- Upgrade Cards durante la run, reducidas/simplificadas.
- Permanent Upgrades entre runs, reducidas/simplificadas.
- El jugador recibe moneda meta al acabar una run, incluso si pierde pronto.
- Tienda permanente: mejoras y desbloqueo de nuevas torres.
- Maná existe como recurso/sistema.
- **No existen support buildings.**
- El maná y sus mejoras se obtienen mediante cartas/permanentes/sistemas de progresión, no edificios de soporte.

## 3. Core loop
1. Comienza run.
2. Cargar desbloqueos y mejoras permanentes.
3. Preparación de ronda.
4. Oleada: aparecen enemigos y recorren la red de caminos hacia el objetivo.
5. Jugador construye/mejora torres y administra recursos.
6. Resolver victoria/derrota de ronda.
7. Si sigue vivo: recompensa de ronda.
8. Fase de expansión: ofrecer/seleccionar pieza de 7 hexágonos.
9. Rotar y colocar pieza legalmente.
10. Resolver nuevas conexiones/rutas/spawns.
11. Fase de carta/mejora cuando corresponda.
12. Siguiente ronda.
13. Ronda 20 superada = demo completada.
14. Al perder o completar: otorgar moneda meta.
15. Volver a tienda/meta.
16. Comprar mejoras/desbloqueos.
17. Nueva run.

## 4. Fantasía estratégica
El mapa debe ser una decisión. Una pieza puede:
- aumentar la longitud de una ruta;
- abrir una bifurcación peligrosa;
- crear una convergencia/kill zone;
- dar una posición elevada excepcional;
- ampliar superficie construible;
- introducir un nuevo punto de entrada.

No debe existir una única decisión obvia en todas las expansiones.

## 5. Dificultad
Objetivo: conservar la sensación de presión de Rogue Tower. La progresión permanente debe ayudar, pero no sustituir la toma de decisiones.

Principio: un jugador nuevo probablemente no completa la run. Las derrotas alimentan meta-progresión y desbloqueos.

## 6. Sistemas deliberadamente fuera de scope
- Support buildings.
- Campaña narrativa compleja.
- Multijugador.
- PvP.
- Mundo 3D real.
- Terreno 3D/meshes como base del tablero.
- Generación procedural libre de geometría: las piezas son plantillas diseñadas.
- Más de 20 rondas en la demo.
- Contenido final masivo antes de validar vertical slice.

## 7. Decisiones todavía abiertas
No inventar como definitivas:
- Número final de torres.
- Roster final de enemigos.
- Lista final de status.
- Fórmula exacta de altura.
- Número de cartas ofrecidas.
- Frecuencia exacta de cartas.
- Economía/balance numérico final.
- Número exacto de piezas de terreno.
- Bosses y rondas exactas de boss.
- Reglas definitivas para múltiples entradas.
- Arte/temática final.

Para el prototipo usar valores temporales centralizados y fáciles de sustituir.
