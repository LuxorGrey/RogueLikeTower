# ADR-0001: cuadrícula axial con orientación pointy-top

- Estado: Aceptada para el prototipo M1; provisional hasta revisar el arte del tablero.
- Fecha: 2026-10-07.

## Contexto

El paquete de diseño confirma coordenadas axiales `(q,r)`, seis vecinos, rotación, conversión mundo/pantalla y una cuadrícula lógica independiente del renderer. Deja la orientación pointy-top o flat-top para elegirla durante M1 según la referencia visual. En esta fase todavía no hay arte propio ni licencia verificada para arte externo.

## Decisión

M1 usa hexágonos pointy-top. La conversión axial–pantalla usa un radio lógico configurable y un origen centrado en la vista. Las reglas y búsquedas usan coordenadas axiales; la clave del diccionario es `Vector2i(q,r)`. El renderizador puede reemplazarse sin cambiar el modelo lógico.

La elección es provisional: queda fijada de forma coherente para el prototipo y solo debe cambiar mediante una decisión documentada cuando se revise el arte propio de M2.

## Consecuencias

- Las seis direcciones, vecinos y rotación se centralizan en `HexCoord`; la conversión axial–pantalla queda en `HexMath`, sin dependencias circulares entre ambos tipos.
- La cuadrícula lógica no depende de `TileMapLayer`, píxeles ni elevación visual.
- Las pruebas de referencia de rotación y conversión quedan descritas en `10_ACCEPTANCE_TESTS.md`; no se añadieron ni ejecutaron pruebas en esta tarea.
- La igualdad de coordenadas se compara por `(q,r)` y la clave canónica del diccionario es `Vector2i(q,r)`, que aporta hash por valor sin usar instancias `RefCounted` como claves.

## Reglas sustituidas

Esta decisión inaugura el registro del proyecto reiniciado. El paquete nuevo sustituye las reglas de terreno y cámara anteriores que definían chunks 3×3/3×3×3, proyección isométrica 2:1 o `TileMapLayer` como autoridad lógica. El inventario de documentos retirados consta en [`ORIGEN.md`](../references/ORIGEN.md).

## Fuentes

- Paquete del usuario: `05_HEX_GRID_AND_TERRAIN.md`, consultado el 2026-10-07.
- *Urtuk: The Desolation*, Steam y Press Kit, consultados el 2026-10-07; referencia visual, no regla de orientación: [Steam](https://store.steampowered.com/app/1181830/Urtuk_The_Desolation/), [Press Kit](https://www.urtuk.com/page/presskit).
