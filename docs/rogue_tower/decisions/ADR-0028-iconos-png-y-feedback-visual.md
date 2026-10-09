# ADR-0028: Atlas PNG y feedback visual de torres y enemigos

- Estado: Parcialmente sustituida por ADR-0031 en el formato y almacenamiento de iconos; las decisiones de feedback visual, HUD y controles restantes siguen vigentes. Revisión manual en ventana pendiente.
- Fecha: 2026-10-08.
- Contexto: los controles de selección, el preview y las torres colocadas usaban representaciones distintas; el HUD mostraba demasiada información textual y los impactos/estados de enemigos no tenían feedback visual suficiente.

## Decisiones

1. La primera implementación M13 utilizó `game/ui/tower_defense_icons.png`, un atlas PNG RGBA 4×4 con 16 regiones: moneda, energía, vida, armadura, escudo, siete torres y cuatro estados (fuego, ralentización, veneno y sangrado). El arte era placeholder de proyecto, no importado de terceros; el atlas quedó retirado por ADR-0031.
2. En esa versión, `IconCatalog` proporcionaba regiones `AtlasTexture` a la barra de selección, preview de construcción, torres colocadas, barras/cap de estados, economía, resumen y mejoras de capas, tienda y cards. Cada atajo de torre era cuadrado, con icono grande, nombre y precio con el icono de moneda. ADR-0031 conserva los usos y sustituye la implementación por `Texture2D` independientes.
3. El hover y la selección de una torre muestran alcance y contorno; el panel lateral puede desplazarse para evitar recortes. La prioridad se configura desde un único menú checkable y admite hasta tres criterios distintos.
4. La vida del enemigo se dibuja en fragmentos y con barras/carriles mayores para que se lean en el tablero. Escudo y armadura ocupan carriles sobre la salud en un marco común; cada carril se identifica con su PNG ampliado. Los estados activos muestran el símbolo PNG sin una placa de fondo y un contador solo si hay más de una acumulación; los iconos también aumentan de tamaño.
5. `DamageService.damage_resolved` alimenta la presentación: el enemigo destella y salta; se genera un texto flotante coloreado según escudo, armadura o salud. El servicio continúa siendo dueño del cálculo de daño.
6. Los textos de cards, mensajes y lecturas técnicas que nombran oro/maná insertan el icono en línea. Las cards que modifican una torre muestran su sprite. La moneda meta conserva su identidad separada.
7. La UI y el feedback son de presentación; no alteran balance, costes, duración de estados, priorización efectiva, daños, progresión ni reglas de campaña. En su momento se sustituyó el atlas SVG de ADR-0027; la decisión de guardar iconos en un atlas PNG queda sustituida por ADR-0031.

## Consecuencias y aceptación

- La selección, el preview y la torre colocada muestran el mismo sprite reconocible.
- La prueba manual debe confirmar hover/selección, panel desplazable, selector de prioridades, iconos y fragmentación de barras, acumulaciones, textos de daño y animación. El procedimiento completo queda en `10_ACCEPTANCE_TESTS.md`.
- Los iconos y las animaciones son placeholders editables. El formato vigente y el catálogo de IDs se definen en ADR-0031.

## Referencias

- [ADR-0027: HUD en tres paneles](ADR-0027-hud-en-tres-paneles-e-iconos-vectoriales.md).
- [Roadmap M13](../design/02_IMPLEMENTATION_ROADMAP.md).
- [Arquitectura técnica](../design/03_TECHNICAL_ARCHITECTURE.md).
- [Pruebas de aceptación](../design/10_ACCEPTANCE_TESTS.md).
