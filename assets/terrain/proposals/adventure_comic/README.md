# Propuestas de terreno: cómic de aventura

Propuestas visuales independientes para evaluar un lenguaje de cómic fantástico: formas simples, contorno oscuro, color plano y un tono juguetón. Son texturas candidatas; no sustituyen los PNG activos ni están conectadas al runtime. Hay tres variantes de Path, tres de Grass, cuatro de Mountain, una fachada genérica para Grass y otra para Mountain, además de cinco sprites de obstáculo en [`obstacles/`](obstacles/README.md).

Las caras superiores conservan el formato actual: 180 × 208 px, hexágono pointy-top y alfa transparente fuera de la silueta. Se generaron con ImageGen y se redujeron desde sus originales con remuestreo de alta calidad. Las fachadas son tiras opacas de 2172 × 724 px, como las texturas de cliff actuales.

| Archivo | Propuesta |
|---|---|
| `path_comic_01.png` | Camino de tierra albaricoque y oro, con sendero crema, piedrecillas y hojas sueltas. |
| `path_comic_02.png` | Camino coral y malva con sendero rosa pálido, cantos y brotes verde azulado. |
| `path_comic_03.png` | Camino malva grisáceo con franja peatonal melocotón y detalles verde salvia. |
| `grass_comic_01.png` | Pradera verde lima con flores blancas y amarillas, tréboles y hierba dibujada. |
| `grass_comic_02.png` | Pradera menta y turquesa con manchas de musgo, flores pequeñas y trazos de hierba. |
| `grass_comic_03.png` | Pradera oliva cálida con manchas verde claro y flores blancas y coral. |
| `mountain_comic_01.png` | Lajas y bloques de roca lavanda gris con grietas, musgo y huecos verde oscuro. |
| `mountain_comic_02.png` | Estratos de roca coral y ocre con grietas simples y musgo turquesa. |
| `mountain_comic_03.png` | Suelo de placas de pizarra gris lavanda encajadas al ras, con juntas finas y líquenes. |
| `mountain_comic_04.png` | Suelo plano de piedra arenisca coral y ocre, con grietas delicadas y líquenes turquesa. |
| `grass_cliff_face.png` | Fachada genérica sencilla con una franja superior de césped y tierra ocre. |
| `mountain_cliff_face.png` | Fachada genérica de roca gris lavanda en bandas planas con pocas grietas. |

Las dos nuevas variantes de Mountain son superficies planas: la piedra queda integrada al nivel del suelo y no sobresalen rocas.

No se han incorporado assets externos ni se ha cambiado la selección de texturas del juego. Para adoptarlas, hay que elegir las propuestas y actualizar las referencias del catálogo y la documentación activa.
