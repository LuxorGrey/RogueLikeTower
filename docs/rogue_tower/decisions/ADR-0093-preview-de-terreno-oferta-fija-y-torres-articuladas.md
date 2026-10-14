# ADR-0093: Preview exacto, oferta fija y torres articuladas

- **Estado:** aceptado e implementado en código; aceptación visual/interactiva pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** las celdas del ghost podían tener alturas y contenido distintos a los de la colocación confirmada. Los contornos de regiones conservaban colores neón y pequeños insets que separaban juntas. El servicio de cartas podía ampliar la oferta por encima de tres. El arte nuevo de torres incluye una base y una cabeza separadas que deben poder girar por separado.
- **Decisiones:**
  1. `Main` crea un snapshot determinista del tablero candidato para la selección actual y entrega el mismo snapshot al preview y a la confirmación. Los auto-rellenos también se generan con semilla/coordenada deterministas.
  2. Los límites de regiones usan los vértices axiales exactos, sin inset; las uniones se redondean con extremos circulares compartidos. Grass toma `#53B56F`, Mountain `#8A8B91` y Path conserva el amarillo configurado.
  3. `CardPoolData`, `RunCardService`, `UpgradeOfferPanel` y `Main` fijan exactamente tres opciones y tres botones seleccionables. Los reclutamientos elegibles se mezclan con las mejoras; las cartas no elegidas permanecen elegibles para rondas siguientes. El nodo permanente `card_draw` se retira de la tienda y su ID permanece en el catálogo solo para compatibilidad con perfiles guardados.
  4. Las siete imágenes nuevas sustituyen sus iconos canónicos. `TowerArtCatalog` crea regiones `AtlasTexture` para una base fija y una cabeza rotatoria cuyo pivote se alinea con la unión de la base. El ghost reutiliza las mismas partes.
  5. Un shader alfa de `CanvasItem` dibuja un contorno blanco por Sprite2D en las bases/cabezas de torre y obstáculos. Esto conserva su orden de profundidad individual y evita agruparlos en `CanvasGroup`.
  6. El asset proporcionado como séptima torreta se asigna a Shredder, porque ese es el séptimo tipo del roster canónico y no existe una torre Raider en el proyecto.
- **Consecuencias:** preview y estado confirmado comparten elevación, variantes, obstáculos, props, cofres y auto-rellenos; todas las ofertas mantienen un panel de tres opciones y no dejan botones extra seleccionables; las torres pueden seguir visualmente la dirección de sus objetivos; los objetos interactuables tienen un borde legible. El panel no cambia de rareza ni de tamaño.
- **Validación:** no se ejecutó Godot ni la inspección visual/manual en esta actualización. Ver criterios M44 en [`10_ACCEPTANCE_TESTS.md`](../design/10_ACCEPTANCE_TESTS.md).
- **Referencias:** imágenes de torre aportadas por el usuario en `assets/sprites/ui/icons/newTowers/`; [Canvas Group Outline — Godot Shaders](https://godotshaders.com/shader/canvas-group-outline/), consultado 2026-10-14. El shader del proyecto implementa la dilatación alfa para sprites individuales; no copia el código publicado.
- **Sustituye:** cualquier comportamiento de Card Draw que aumentase las ofertas por encima de tres y las reglas visuales anteriores de color/inset del contorno. Complementa ADR-0084, ADR-0091 y ADR-0092.
