# ADR-0040: terreno, obstáculos, cofres y feedback visual

- Fecha: 2026-10-09.
- Estado: aceptado e integrado. La tasa inicial de cofres y el número de niveles de mejora quedaron parcialmente sustituidos por ADR-0041; la aceptación visual en ventana sigue pendiente.
- Contexto: el tablero necesitaba más variación por celda, un punto de economía explorable y feedback visual inmediato para ataques e interacción. El usuario pidió que el panel de torre muestre toda su información sin scroll, ajustándose al alto de los datos.

## Decisiones

1. Path, Grass y Mountain tienen tres variantes visuales PNG coherentes. La ilustración se genera para el proyecto y se mantiene independiente de la lógica de celdas.
2. Una celda Grass genera un obstáculo con probabilidad 25 %; Mountain, 15 %. El tipo se selecciona uniformemente entre roca, esquirla, hierba alta, tótem y piedras. No aparecen props de obstáculo o cofre sobre Path.
3. Obstáculos bloquean construcción del mismo modo que una celda no construible; no son nodos del PathGraph y no alteran terreno, elevación o conectividad.
4. Una celda construible que no tenga obstáculo genera un cofre con probabilidad base 5 %. La permanente «Suerte del explorador» suma cinco puntos porcentuales por nivel, hasta 20 % con tres niveles. Esta tasa se conservó como regla inicial y quedó sustituida parcialmente por ADR-0041, que reduce el inicio a 1 % y amplía la mejora a cuatro niveles. El premio al abrirlo es Gold de la run. Se implementa inicialmente como 25 Gold por cofre; la cantidad es configurable y provisional porque el usuario no especificó un monto.
5. Cofre cerrado bloquea la construcción en su celda. Un clic lo abre, retira el cofre y paga una vez sin alterar ruta ni celda axial.
6. La asignación de variante/obstáculo/cofre se deriva de seed de run, coordenada axial y salts separados. Repetir la misma run con idénticas acciones reproduce las mismas asignaciones. La selección de variantes no debe cambiar el camino ni los stats.
7. Cada torre emite un VFX al impacto que le corresponde: Ballista `Dust_01`, Mortar `Explosion_01`, Tesla Coil `TeslaCoil`, Frost Keep `Ice_01`, Flame Thrower `Fire_03`, Poison Sprayer `Poison` y Shredder `Blood`.
8. El cursor usa `Cursor_01` en estado normal, `Cursor_02` al pasar por controles/objetos interactivos, `Cursor_03` en una acción deshabilitada o posición inválida y `Cursor_04` al colocar una torre.
9. El panel de información de torre nunca tiene scroll. Se ajusta al contenido visible y reduce su escala vertical para conservar todos los datos si no caben al alto natural del viewport. El scroll de otras interfaces, como la tienda, se mantiene independiente.
10. Los siete spritesheets VFX y cuatro cursores se cargan desde una dependencia local de Tiny Swords entregada por el usuario. El source PNG no se incorpora a Git: el creador permite uso personal/comercial pero no la redistribución o reempaquetado de los archivos fuente. `assets/third_party/tiny_swords/README.md` conserva las rutas de instalación y mapeo.

## Consecuencias

- `HexCell` almacena el tipo de obstáculo y la presencia de cofre; `TerrainVisualCatalog` asigna contenido determinista a tablero inicial, expansiones confirmadas y huecos rellenados.
- `BuildController` rechaza celdas con obstáculo/cofre cerrado; `Main` abre cofres con clic y actualiza el saldo de Gold.
- `MetaProgression` aplica la mejora permanente de cofres a las runs siguientes. La probabilidad se limita a 20 %.
- El terreno usa atlas PNG con tres filas de terreno y tres columnas de variantes; props y cofres se dibujan separados sobre la celda.
- La ejecución y registro de integración no sustituyen la aceptación visual/interactiva; el procedimiento queda en `10_ACCEPTANCE_TESTS.md` y el estado en `09_PROGRESS.md`.

## Referencias

- Petición del usuario en la tarea del 2026-10-09: probabilidades de obstáculos/cofres, mejora permanente hasta 20 %, contenido PNG, efectos Particle FX, cursores y panel de torre sin scroll.
- Pixel Frog, *Tiny Swords (Free Pack)*, <https://pixelfrog-assets.itch.io/tiny-swords>, consultado el 2026-10-09. Ver [Origen](../references/ORIGEN.md) para atribución/licencia y límites de distribución.
- [ADR-0039: panel lateral de torre y escala visual por objeto](ADR-0039-panel-torre-y-escalado-individual.md).
