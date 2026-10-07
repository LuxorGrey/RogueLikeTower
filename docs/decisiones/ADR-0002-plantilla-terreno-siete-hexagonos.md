# ADR-0002: plantilla inicial de terreno de siete hexágonos

- Estado: Aceptada para la plantilla inicial.
- Fecha: 2026-10-07.

## Contexto

El diseño base establece que cada expansión usa una pieza compuesta por siete celdas hexagonales. El usuario precisó la huella inicial como `(0,0)`, `(0,-1)`, `(1,-1)`, `(1,0)`, `(0,1)`, `(-1,1)` y `(-1,0)`: el centro axial más sus seis vecinos.

## Decisión

- La plantilla inicial tiene exactamente esas siete coordenadas locales, con `(0,0)` como pivote.
- Cada celda guarda su propio terreno: PATH, GRASS o MOUNTAIN. La primera muestra usa 2 PATH, 3 GRASS y 2 MOUNTAIN para que los tres colores aparezcan; esa distribución es provisional y editable en el Resource.
- La vista debug usa PATH `#59666E`, GRASS `#479157` y MOUNTAIN `#A1947A`, además de etiquetas P/G/M para que el tipo no dependa solo del color. Las etiquetas de montaña usan tinta oscura para conservar contraste. No se importa ni distribuye arte de terceros.
- El giro ocurre en seis pasos de 60° alrededor del origen. Las coordenadas y los bits de conexiones de camino giran juntos; el Resource original no se modifica.
- Esta huella define la primera plantilla, no todas las piezas futuras: el modelo conserva la regla de admitir cualquier conjunto conectado de siete hexágonos.

## Alcance pendiente

La plantilla se presenta con el renderer placeholder definido en ADR-0003. Todavía no se coloca en el mapa ni se validan solapamientos, adyacencia, entradas de camino o rutas hacia la base; esos requisitos siguen en M3 del roadmap.

## Referencias

- Requerimiento del usuario en esta conversación, 2026-10-07.
- Paquete de diseño del usuario: `05_HEX_GRID_AND_TERRAIN.md` y `04_DATA_MODELS.md`, consultados el 2026-10-07.
