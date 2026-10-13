# ADR-0054: Tipografía global y ausencia de sombras generadas por código

- Fecha: 2026-10-13.
- Estado: aceptado; integración en código/configuración completada, aceptación visual pendiente.
- Complementa: ADR-0051 y ADR-0053.
- Alcance: presentación tipográfica global y sombras procedurales de la escena 2D. No cambia gameplay, estado, profundidad ni feedback de hover/selección.

## Contexto

El usuario pidió que ningún elemento del juego genere sombras por código, en especial las torres, y que Patrick Hand sea la fuente principal de todo el proyecto tal como está actualmente. El tema del HUD se aplicaba desde las escenas, pero no estaba configurado como tema predeterminado del proyecto. También había cifras pintadas manualmente que elegían `ThemeDB.fallback_font` en vez del tema activo.

## Decisiones

1. Se configura `rogue_hud_theme.tres` como tema predeterminado en `project.godot` y Patrick Hand como su `default_font`. Se conserva el tamaño tipográfico de cada control y no se añade ningún override local de fuente.
2. Los contadores que se dibujan manualmente en retratos de enemigos y previews de portal cargan directamente la misma FontFile para mantener consistencia con los controles.
3. Se elimina el polígono oscuro que `Tower._draw()` dibujaba bajo cada torre, el trazo ancho bajo las flechas de `PathFlowOverlay` y la copia de texto desplazada que simulaba sombra en los contadores de estados. La revisión no encontró una rutina equivalente de sombra para obstáculos, enemigos o base. No se consideran sombras el contorno de hover ni el feedback de selección; permanecen disponibles.
4. El archivo `PatrickHand-Regular.ttf` se copia desde la carpeta proporcionada por el usuario a `assets/fonts/`; se conserva junto a él `OFL.txt`. La fuente se distribuye bajo SIL Open Font License 1.1.

## Consecuencias

- La fuente predeterminada cubre los controles del proyecto y los dos usos de texto dibujado manualmente.
- Las torres ya no muestran la base/polígono oscuro generado por código, las flechas PATH no tienen trazo ancho debajo y los contadores no dibujan una copia de texto desplazada. Obstáculos, enemigos, base y props no reciben sombras runtime.
- La legibilidad, el ajuste de texto y la apariencia final deben confirmarse en ventana Godot a 1280×720 y 1440×900.

## Referencias

- Fuente proporcionada por el usuario: `F:\Desktop\TowerDefense\Patrick_Hand\PatrickHand-Regular.ttf`.
- Licencia incluida con la fuente: SIL Open Font License 1.1, `OFL.txt`.
- [Revisión visual global](../design/10_ACCEPTANCE_TESTS.md).
- [ADR-0051: navegación, preview de portales y Tower Info](ADR-0051-navegacion-prevision-portales-y-panel-torre.md).
