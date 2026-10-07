# Referencias visuales recibidas

Las imágenes aportadas se conservan como referencias de análisis; su presencia en `docs/.../referencias/` no autoriza distribuirlas como arte del juego.

| Archivo del proyecto | Referencia | Uso |
|---|---|---|
| [Infografía de losetas](assets/infografia-carcassonne-losetas-referencia.png) | Distribución A–Y de piezas Carcassonne | Estudiar conectores y proporciones. La vectorización final debe quedar en datos propios. |
| [Captura de Don't Starve Together](assets/dont-starve-together-profundidad-referencia.png) | Encuadre y sensación de profundidad | Estudiar lectura espacial, no copiar arte. |

## Dirección de terreno vigente

- Juego 2D isométrico fijo, proyección 2:1, sprites ordenados por profundidad.
- Cada chunk consta de nueve celdas lógicas en una cuadrícula 3×3, con tipos PATH, GRASS y STONE.
- El modelo de terreno es autoritativo; TileMapLayer y PNG solo representan su estado. No hay volumen lógico 3×3×3 ni inferencia desde píxeles.
- Ver [Sistema de losetas isométricas](../sistemas/sistema-losetas-isometricas.md) para todas las reglas.

## Assets CellTile

Directorio fuente: `assets/CellTile`. El inventario actualizado de archivos presentes, roles visuales y asuntos de licencia está en [assets/CellTile/README.md](../../../../assets/CellTile/README.md). En el estado revisado hay grass1–grass10, path_1/path_2, stone1–stone4 y spritesheet_nature-blocks.png; los antiguos dirt2/dirt3, path_variant_1 y stair_stone1 no existen actualmente.

La licencia de redistribución debe confirmarse antes de incluir estos PNG en una build pública.

## Procedencia

La infografía de losetas y la captura se aportaron como imágenes de usuario. Como referencia comparativa, Devir describe su [guía de distribución de losetas](https://deviramericas.com/guia-de-losetas-de-carcassonne/) y la edición consultada como juego base de 72 losetas ([edición de aniversario](https://deviramericas.com/product/carcassonne-20mo-aniversario/)). La imagen registrada suma 75; la diferencia permanece documentada en [patrones A–Y](losetas-carcassonne-adaptacion.md).
