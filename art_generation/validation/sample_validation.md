# Revisión de las cinco muestras

**Estado:** el usuario aprobó las cinco muestras el 2026-10-13 y autorizó producir las 18 restantes.

## Resultado técnico

Las salidas de ImageGen se conservaron como intermediarios de alta resolución en raw/. El exportador [fit_sprite_to_source.py](../tools/fit_sprite_to_source.py) solo las reduce con Lanczos al canvas de la fuente y sustituye el canal alfa por el original; el dibujo visible procede de la generación, no de un filtro de color. En los cinco resultados el tamaño, modo RGBA y bytes del canal alfa coinciden con la fuente estructural. Dirt_01 coincide con la máscara de Grass_01, que se usó como proxy porque no existe fuente Dirt.

| Archivo final | Tamaño | Modo | Máscara alfa | Nota de estructura |
|---|---:|---|---|---|
| generated/samples/grass_01.png | 180×208 | RGBA | Idéntica a Grass_01 | Hex y orientación originales. |
| generated/samples/mountain_01.png | 180×208 | RGBA | Idéntica a Mountain_01 | Placas y distribución top-down; la transparencia define el hex. |
| generated/samples/dirt_01.png | 180×208 | RGBA | Idéntica a Grass_01 proxy | Superficie genérica; sin camino ni huellas. |
| generated/samples/ballista.png | 256×256 | RGBA | Idéntica a la fuente Ballista | Arco, cuerda, virote, base y dirección conservados. |
| generated/samples/rock.png | 208×208 | RGBA | Idéntica a OBSTACLE_ROCK | Masa compacta y apoyo conservados; sin terreno debajo. |

## Revisión visual de las muestras

- **Grass_01:** oliva y musgo apagados, grupos de hierba dibujados con tinta, flores pequeñas y lectura clara a tamaño reducido.
- **Mountain_01:** placas de pizarra, grietas y musgo secundario. Se corrigió el marco continuo que apareció en la primera generación; la última versión deja que las placas lleguen al límite alfa.
- **Dirt_01:** tierra umber con gravilla escasa y rayado corto. No hay elementos que sugieran una ruta. Es una muestra provisional porque no existe una fuente Dirt propia.
- **Ballista:** la silueta mecánica, el eje del virote y la estructura de madera/hierro siguen siendo reconocibles. Se omitieron proyectiles en vuelo y efectos de ataque.
- **Rock:** roca gris angulosa, sombreado pintado mate y silueta compacta. Mantiene el canvas transparente independiente.

El usuario aprobó estas cinco muestras y el uso de Grass_01 como proxy geométrico de Dirt_01. A partir de ese visto bueno se generaron las otras 18 piezas. La aceptación artística del conjunto completo queda pendiente de su revisión; el control técnico y la composición están en el [informe final](final_validation.md) y la [vista conjunta](../previews/full_asset_composition.png). No se ha probado la integración runtime porque los archivos siguen aislados y no se cambiaron recursos del juego.
