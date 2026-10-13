# ADR-0057: Assets pixel art activos y encaje hexagonal

- Fecha: 2026-10-12.
- Estado: implementado en la rama `Pixel-Change`; aceptación visual/interactiva responsive pendiente.
- Contexto relacionado: [ADR-0031](ADR-0031-png-individuales-por-objeto.md), [ADR-0038](ADR-0038-base-sprite-y-feedback-del-hud.md), [ADR-0039](ADR-0039-panel-torre-y-escalado-individual.md), [ADR-0049](ADR-0049-arquitectura-hibrida-ui-editable.md), [ADR-0055](ADR-0055-assets-pixel-art-nativo-y-muestreo-nearest.md) y [ADR-0056](ADR-0056-sombras-pixel-art-proyectadas.md).
- Sustituye parcialmente: ADR-0055 en la conservación de PNG originales; ADR-0049 en el alcance del Theme activo.

## Contexto

El usuario pidió usar ya los PNG pixel art de la rama como arte activo, retirar los sprites antiguos, aplicar la fuente Patrick Hand desde `F:\Desktop\TowerDefense\Patrick_Hand`, conservar enemigos estáticos y compartir una sola imagen por torre entre UI y tablero. También pidió comprobar el ajuste de los sprites con la cuadrícula hexagonal y corregir la configuración de filtrado de la base y el portal.

## Decisiones

1. Los 62 PNG de `assets/pixel_art/` son los únicos sprites propios activos. Se eliminan 74 PNG antiguos y sus 74 sidecars `.import` de `assets/base/`, `assets/enemies/`, `assets/terrain/`, `assets/ui/` y `game/ui/icons/`, incluidas las siete alternativas de iconos de torre y los marcos PNG inactivos. Se mantienen los 11 PNG pixelados de Tiny Swords porque son recursos de terceros licenciados ya usados por VFX y cursores.
2. La fuente `PatrickHand-Regular.ttf` y su licencia OFL se copian a `assets/fonts/Patrick_Hand/`. El Theme de interfaz la define como fuente predeterminada a 16 px y `project.godot` la aplica como Theme global. Los textos dibujados en sprites de estado y previews de portal cargan también esa misma fuente.
3. Cada una de las siete torres conserva un PNG en `assets/pixel_art/ui/icons/`. `IconCatalog.get_tower_icon()` entrega la misma textura para el botón, preview de construcción, panel de selección y torre colocada. No se crean versiones mundiales y de UI separadas.
4. Los Resources de enemigo siguen usando una textura PNG estática por perfil. La incorporación de spritesheets y animaciones queda aplazada.
5. La huella de las teselas encaja con el hexágono: los PNG de terreno miden 180×208 y se dibujan a aproximadamente 90×104 unidades, igual que el hex pointy-top de radio 52. Los obstáculos y las torres se dibujan a 86×86 y 84×84, por debajo de los 90,07 px de anchura del hex. El portal se reduce de 112×168 a 100×150; su alfa opaco máximo, incluso durante el pulso, queda dentro de la anchura de una celda. La base mantiene su tamaño de landmark vertical y su huella lógica sigue siendo un hex.
6. Los contornos interactivos del hover, la base, las cards y la construcción insetan el centro del trazo por la mitad de su grosor, de modo que el borde exterior no rebase el perímetro de la celda vecina. Las rutas de terreno, las caras elevadas y los footprints lógicos no cambian.
7. El proyecto mantiene filtro global nearest, ajuste 2D a píxel y `canvas_items`, y añade `window/stretch/aspect="expand"` para preservar proporciones al cambiar de relación de aspecto. No se fuerza una escala entera del viewport: el HUD y Patrick Hand conservan su resolución nativa. El zoom fraccionario todavía puede hacer variar el grosor aparente de los píxeles.
8. Base y portal fijan también `texture_filter=1` en sus escenas; sus scripts mantienen nearest en runtime. No se habilita filtrado lineal en esas texturas.

## Consecuencias

- No queda una copia antigua de los sprites propios que pueda confundirse con la textura activa. La reversión visual requiere recuperar los archivos desde Git o rehacer/redibujar una fuente, no cambiar un path de vuelta.
- La interfaz usa Patrick Hand incluso en los textos que se dibujan dentro del mundo. Los PNG de iconos de torre son una única fuente para UI y juego.
- Las tapas de terreno tienen el mismo footprint lógico y visual. Los trazos de selección quedan dentro de ese footprint; los elementos altos como la fortaleza y las unidades pueden sobresalir visualmente según su función.
- `canvas_items` evita bajar el HUD a una textura de resolución reducida y `expand` evita deformar el lienzo al cambiar proporciones. Se debe comprobar manualmente 1280×720 y 1440×900 y revisar zooms 1× y 2,5×.

## Verificación

- Antes de borrar, se verificaron los 62 PNG pixel art del runtime y no se encontraron referencias activas a los PNG antiguos.
- Pendiente de ejecutar Godot 4.7 para comprobar carga de la fuente, Theme, escenas y shaders, y de aceptar visualmente el hover/ghost, el pulso del portal y la UI a ambas resoluciones.

## Referencias

- Godot Engine 4.7, [Multiple resolutions](https://docs.godotengine.org/en/4.7/tutorials/rendering/multiple_resolutions.html), consultado el 2026-10-12.
- Godot Engine 4.7, [CanvasItem](https://docs.godotengine.org/en/4.7/classes/class_canvasitem.html), consultado el 2026-10-12.
- Tipografía Patrick Hand, fuente y licencia OFL aportadas por el usuario desde `F:\Desktop\TowerDefense\Patrick_Hand`.
