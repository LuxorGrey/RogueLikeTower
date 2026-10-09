# Origen y referencias

## Fuente de diseño del proyecto

- Título: *Tower Defense Roguelike — Codex Handoff*.
- Archivo recibido: `tower_defense_roguelike_codex_pack.zip`.
- Ubicación al recibirlo: `D:/DescargaRuben/tower_defense_roguelike_codex_pack.zip`.
- Autor, edición y licencia: no indicados en el paquete.
- Fecha de recepción y consulta: 2026-10-07.
- Contenido importado: los 12 documentos numerados, el prompt inicial y `project_spec.json`.
- Estado: especificación inicial suministrada por el usuario. El diseño activo incorpora decisiones posteriores y su jerarquía está definida en [el índice](../README.md); las instrucciones operativas del paquete se aplican solo si no contradicen instrucciones de mayor prioridad ni peticiones posteriores del usuario.

## Referencias externas

Estas fuentes orientan el contexto. No sustituyen las reglas propias confirmadas en `01_GAME_DESIGN_SOURCE_OF_TRUTH.md`.

| Título | URL | Edición o versión | Consulta | Uso y límites |
|---|---|---|---|---|
| *Rogue Tower* — página oficial de Steam | <https://store.steampowered.com/app/1843760/Rogue_Tower/> | Versión de tienda consultada; la página no fija una versión de juego | 2026-10-07 | Contexto oficial del juego de referencia. Para mecánicas sensibles al parche, revisar también anuncios y notas oficiales. |
| Anuncios oficiales de *Rogue Tower* en Steam | <https://steamcommunity.com/app/1843760/announcements/> | Anuncios y parches publicados por el desarrollador | 2026-10-07 | Fuente primaria para comprobar cambios de mecánicas y discrepancias con wikis comunitarias. |
| *Rogue Tower Wiki* | <https://rogue-tower.fandom.com/wiki/Rogue_Tower_Wiki> | Wiki comunitaria; edición cambiante | 2026-10-07 | Índice y contexto, no balance vigente por sí solo. No se usó para definir este milestone. |
| *Shredder* — Rogue Tower Wiki | <https://rogue-tower.fandom.com/wiki/Shredder> | Wiki comunitaria; versión/edición no visible | 2026-10-08 | Referencia de rol para la hoja que avanza por PATH, perfora enemigos, pierde daño por impacto y aplica Bleed. Se adaptó el arquetipo; no se copió el balance. |
| *Rogue Tower Wiki* — Towers, Monsters, Status Effects, Upgrade Cards y Permanent Upgrades | <https://rogue-tower.fandom.com/wiki/Towers>, <https://rogue-tower.fandom.com/wiki/Monsters>, <https://rogue-tower.fandom.com/wiki/Status_Effects>, <https://rogue-tower.fandom.com/wiki/Upgrade_Cards>, <https://rogue-tower.fandom.com/wiki/Permanent_Upgrades> | Wiki comunitaria; versión/edición no visible | 2026-10-09 | Nombres canónicos, parámetros publicados de torres y perfiles base de enemigos aprobados en ADR-0035, más referencia para cards/estados. La página Monsters no da conteos/grupos de enemigos por wave; no se atribuyen esos valores a la fuente. Los jefes/minibosses con balance propio siguen las decisiones del proyecto. |
| *Rogue Tower* — anuncios y changelogs oficiales de Steam | <https://steamcommunity.com/app/1843760/announcements/> | Parche 1.1.2.0 (2022-09-08); último parche oficial localizado 1.3.2.0 (2023-04-07); anuncio de desarrollo de RT2 (2025-06-24) | 2026-10-09 | Fuente primaria de correcciones de balance cuando las fichas comunitarias quedaron obsoletas: Tesla Coil rango 2/Shield 10, Flame Thrower daño 6 y Frost Keep daño 6. Se adoptan Tesla/Flame en ADR-0036; las demás cifras no indicadas por notas permanecen contrastadas con las fichas de torre. |
| *Urtuk: The Desolation* — página de Steam | <https://store.steampowered.com/app/1181830/Urtuk_The_Desolation/> | Edición comercial; publicada el 2021-02-27 | 2026-10-07 | Referencia visual/técnica secundaria para el tablero hexagonal y arte 2D. No se reutiliza arte. |
| *Urtuk: The Desolation* — Press Kit | <https://www.urtuk.com/page/presskit> | Capturas del press kit; versión de cada captura según la página | 2026-10-07 | Referencia visual de campos de batalla hexagonales. No se reutilizan imágenes ni assets. |
| *Godot Engine* — Static typing in GDScript | <https://docs.godotengine.org/en/4.7/tutorials/scripting/gdscript/static_typing.html> | Documentación oficial de Godot 4.7 | 2026-10-07 | Tipado de clases, colecciones, enums y tipos de retorno usados por M1. |
| *Godot Engine* — CanvasItem | <https://docs.godotengine.org/en/4.7/classes/class_canvasitem.html> | Documentación oficial de Godot 4.7 | 2026-10-07 | Referencia de las primitivas 2D usadas por la vista debug de M1. |
| *Godot Engine* — ThemeDB | <https://docs.godotengine.org/en/4.7/classes/class_themedb.html> | Documentación oficial de Godot 4.7 | 2026-10-07 | Fuente de la tipografía fallback usada para las etiquetas debug. |

La consulta de *Rogue Tower* en este hito fue solo de contexto; no se implementaron ni balancearon sus mecánicas. La orientación pointy-top de M1 es una decisión de prototipo del proyecto, no una regla atribuida a *Urtuk*.

## Reglas anteriores retiradas

Al reiniciar el proyecto se retiraron los documentos y prototipos que describían chunks 3×3/3×3×3, proyección isométrica fija 2:1 y `TileMapLayer` como modelo del terreno, incluidos los ADR anteriores de topología, presentación y losetas. Esas reglas quedan sustituidas por el paquete de diseño del usuario. Las decisiones compatibles no se presumen vigentes si no aparecen en los documentos nuevos.
