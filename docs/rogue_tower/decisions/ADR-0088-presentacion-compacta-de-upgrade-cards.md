# ADR-0088: Presentación compacta de upgrade cards

- Fecha: 2026-10-14
- Estado: Aceptado; escena y shader integrados, aceptación visual pendiente.
- Ámbito: presentación de ofertas de mejora temporales durante una run.

## Contexto

La presentación anterior seguía usando un panel vertical NinePatch que ocupaba demasiado espacio y restaba legibilidad a las opciones. La referencia aportada muestra tres opciones claramente separadas, iconos grandes y una iluminación suave asociada a la rareza. El diseño debe mantener el contenido funcional de cada card y no requerir assets de borde distintos.

## Decisión

1. Todas las `UpgradeOfferCard` comparten una superficie plana y una única estructura; no se usan sprites de marco/fondo ni variantes visuales por rareza. Se retira `upgrade_card_universal.png`.
2. La oferta base muestra tres cards en una fila centrada, con una separación visible. Cuando Card Draw amplía la oferta hasta seis, se conservan tres columnas y se distribuye el resto en una segunda fila.
3. Cada card muestra tier/rareza como texto, icono grande, título y descripción. El panel debe dejar legibles estos elementos y permitir que el botón completo reciba la interacción.
4. Un shader procedural dibuja un aura radial detrás de la superficie común, con destellos/partículas animadas. El color expresa rarity (Common gris, Uncommon verde y Rare azul); el hover solo refuerza el aura y la superficie no cambia por rareza.
5. La oferta conserva los efectos, orden, rareza y reglas de selección definidos por el catálogo y `RunCardService`; esta decisión afecta solo la presentación.

## Consecuencias

- La forma del panel no compite con el contenido ni con el tablero, y los efectos de rareza quedan limitados a una capa de aura.
- No se necesitan texturas PNG de card. El shader y la escena son la fuente visual común.
- La presentación de M36 con sprite vertical se sustituye; siguen vigentes la etiqueta de tier, las ramas paralelas H/A/S de ADR-0081 y el tinte de altura de ADR-0082.
- Tamaño final, legibilidad, intensidad del aura, animación y clicabilidad requieren aceptación manual en ventana; no se declara aceptación visual todavía.

## Decisiones relacionadas

- [ADR-0075](ADR-0075-panel-unico-y-aura-de-rareza.md): panel único y aura por rareza.
- [ADR-0080](ADR-0080-sprite-vertical-y-tier-de-upgrade-cards.md): sprite/tier previo, sustituido solo en su presentación de marco.
- [ADR-0081](ADR-0081-mejoras-de-torre-en-ramas-paralelas.md): ramas de mejoras permanentes, no afectadas por esta ADR.
