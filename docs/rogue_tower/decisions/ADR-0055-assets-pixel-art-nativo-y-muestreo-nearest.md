# ADR-0055: Variantes de assets pixel art nativo y muestreo nearest

- Fecha: 2026-10-10.
- Estado: experimento visual implementado en la rama `Pixel-Change`; el uso activo de estas variantes y la retirada de copias antiguas en esta rama quedan concretados por [ADR-0057](ADR-0057-assets-pixel-art-activos-y-encaje-hexagonal.md). La dirección artística de producción sigue pendiente.
- Contexto relacionado: [ADR-0031](ADR-0031-png-individuales-por-objeto.md), [ADR-0041](ADR-0041-occlusion-arte-terreno-y-flujo-de-rutas.md), [ADR-0049](ADR-0049-arquitectura-hibrida-ui-editable.md), [ADR-0053](ADR-0053-interfaz-plana-y-feedback-contextual.md) y [ADR-0054](ADR-0054-prueba-visual-pixel-art-32px.md).
- Sustituye: el pase de pantalla completo que ADR-0054 describía.

## Contexto

Se pidió que el juego se viera pixel art sin pixelar la imagen final completa. La prueba anterior aplicaba un shader sobre mundo, texto y HUD; eso suavizaba la lectura de recursos pequeños y no hacía que los archivos fuente fueran arte pixelado.

## Decisiones

1. Se crean 62 PNG derivados en `assets/pixel_art/` para los recursos propios activos: 26 enemigos, 11 teselas/fachadas, 5 obstáculos, base, portal, cofre, 16 iconos de juego y el icono de demolición. Cada PNG conserva las dimensiones y el lienzo del arte de partida. En el estado inicial del experimento, los originales permanecían intactos; ADR-0057 sustituye esa política en `Pixel-Change` y retira las copias PNG antiguas después de verificar las rutas activas.
2. El arte se hornea en cuadrículas lógicas por familia: enemigos y obstáculos a 32 px de ancho, teselas y fachadas a 48 px, iconos a 32 px, base a 64 px, portal/cofre a 32 px e icono de demolición a 24 px. La altura mantiene la proporción propia del recurso; no se fuerza una caja cuadrada cuando el original es apaisado o vertical.
3. Las variantes conservan transparencia, se ajustan a la silueta de la fuente y usan agrupaciones de píxeles duras. Las referencias de Resources, escenas y catálogos activos apuntan a `assets/pixel_art/`; las carpetas originales se mantienen como fuente recuperable.
4. La interpolación de los CanvasItem que dibujan sprites usa nearest, el filtro por defecto del proyecto también es nearest y está activo el ajuste de transformaciones 2D a píxel. El ajuste de vértices queda desactivado para evitar el movimiento menos suave que Godot documenta al combinar ambos ajustes. No hay shader ni renderizado a una textura global de baja resolución. La tipografía/UI continúa en sus controles planos actuales.
5. Los sprites y efectos de Tiny Swords mantienen su archivo de origen de terceros: ya son pixel art, forman parte de su paquete con licencia y no se editan ni se duplican dentro del juego.
6. No cambian cuadrícula, reglas, balance, economía, tamaños de colocación, lógica de combate ni layout plano del HUD. La prueba no aprueba todavía la dirección de producción ni los colores finales.

## Consecuencias

- En el juego, los sprites tienen bordes de píxel nítidos en vez de pasar por un filtro de pantalla que afecta también a texto y paneles.
- La resolución lógica de píxel se elige por familia para que el terreno repetido y las siluetas de personaje no compartan a la fuerza una única caja 32 × 32.
- Nearest mantiene el color de cada píxel, aunque los zooms fraccionarios pueden dar bloques con anchuras distintas. La revisión visual debe decidir si se fija un zoom entero antes de aprobar arte de producción.
- Los iconos y algunos enemigos tienen menos detalle que sus fuentes originales; las fuentes se conservan para que un artista pueda redibujar y sustituir cada variante sin cambiar sus rutas de gameplay.
- Los marcos decorativos de UI siguen sin incorporarse; se conserva la interfaz plana de ADR-0053.

## Verificación

- Godot 4.7 importó los 62 PNG derivados; todas las imágenes mantienen las dimensiones de sus recursos fuente.
- La escena principal arranca sin errores de parseo ni de carga de recursos. Permanecen tres warnings de scripts preexistentes en `wave_director.gd` y `main.gd`.
- Capturas de la escena a 1440 × 900: [preparación](../../../output/pixel-art-assets-preview.png) y [ronda activa](../../../output/pixel-art-assets-combat-preview.png). La revisión confirma que el HUD plano y el texto conservan su legibilidad; la aceptación manual del estilo de producción sigue pendiente.

## Referencias

- Godot Engine 4.7, [CanvasItem / TextureFilter](https://docs.godotengine.org/en/4.7/classes/class_canvasitem.html), consultado el 2026-10-10.
- Godot Engine 4.7, [ProjectSettings / 2D pixel snapping](https://docs.godotengine.org/en/4.7/classes/class_projectsettings.html), consultado el 2026-10-10.
- Referencias visuales de juego: ninguna importada como asset. Las fuentes originales del proyecto continúan siendo la autoridad de identidad y escala.
