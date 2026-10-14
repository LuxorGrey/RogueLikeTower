# ADR-0065: Panel común e iconos para Upgrade Cards

- Fecha: 2026-10-13
- Estado: Parcialmente sustituido por ADR-0075: ya no se usan fondos PNG ni marco 9-slice; se conservan el panel reutilizable y los iconos de efecto.

## Contexto

Las ofertas temporales reutilizan una plantilla para cartas de muchas torres, rarezas y efectos generales. Hasta ahora, la plantilla ocultaba el icono en efectos globales y todas las rarezas compartían la misma superficie.

## Decisiones

1. Todas las cartas de run usan la misma escena `UpgradeOfferCard`; el recurso de carta solo aporta texto, rareza y operaciones.
2. El catálogo visual proporciona un marco común perimetral y fondos PNG separados para Común, Poco común y Rara. La rareza elige el fondo, sin duplicar la escena; el marco usa cortes 9-slice con el centro transparente y no debe cruzar ni tapar el contenido.
3. El icono de efecto/torre se presenta siempre y aumenta de 50×50 a 78×78 px. Las cartas que afectan a una sola torre conservan su sprite de torre.
4. El catálogo asigna icono a cada tipo de operación actual: daño, crítico, alcance, elevación, cadencia, área, Mana, Health/Armor/Shield, Gold, enemigo o estado. Una operación futura sin regla explícita usa el icono de daño como fallback visible.
5. Los siete PNG de efecto general son assets base editables, separados por concepto, bajo `game/ui/icons/`.

## Consecuencias

- `IconCatalogData` mantiene los PNG y resuelve el icono de cada carta sin cambiar los Resources del pool.
- La frecuencia de oferta cada tres rondas sigue siendo la de ADR-0062; esta decisión cambia la presentación.
- Se debe revisar a 1280×720 y 1440×900 la legibilidad de los fondos, el marco perimetral 9-slice y el nuevo tamaño del icono, también con ofertas de hasta seis cartas. El encuadre se corrigió en [ADR-0071](ADR-0071-marco-de-cards-y-colocacion-automatica.md).
