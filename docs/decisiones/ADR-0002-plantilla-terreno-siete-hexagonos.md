# ADR-0002: plantilla inicial de terreno de siete hexágonos

- Estado: Aceptada para la forma de las losetas de siete celdas; su uso como tablero de campaña queda sustituido por ADR-0025.
- Fecha: 2026-10-07.

## Contexto

El diseño base establece que cada expansión usa una pieza compuesta por siete celdas hexagonales. El usuario precisó la huella inicial como `(0,0)`, `(0,-1)`, `(1,-1)`, `(1,0)`, `(0,1)`, `(-1,1)` y `(-1,0)`: el centro axial más sus seis vecinos.

## Decisión

- La plantilla de loseta de siete celdas tiene exactamente esas coordenadas locales, con `(0,0)` como pivote.
- Cada celda guarda su propio terreno: PATH, GRASS o MOUNTAIN. La primera muestra usa 2 PATH, 3 GRASS y 2 MOUNTAIN para que los tres colores aparezcan; esa distribución es provisional y editable en el Resource.
- La vista debug usa PATH `#59666E`, GRASS `#479157` y MOUNTAIN `#A1947A`, además de etiquetas P/G/M para que el tipo no dependa solo del color. Las etiquetas de montaña usan tinta oscura para conservar contraste. No se importa ni distribuye arte de terceros.
- El giro ocurre en seis pasos de 60° alrededor del origen. Las coordenadas y los bits de conexiones de camino giran juntos; el Resource original no se modifica.
- Esta huella define la primera plantilla, no todas las piezas futuras: el modelo conserva la regla de admitir cualquier conjunto conectado de siete hexágonos.

## Alcance y estado de implementación

M3 usó esta plantilla como tablero semilla; ADR-0025 sustituye ese uso por `StartingBoardData` de 19 celdas y mantiene las siete coordenadas como forma estándar de losetas. M3 también añadió cinco Resources expansivos con sockets de camino, validador, preview y confirmación/cancelación. M4 implementa `PathGraph` y ancla provisionalmente la base en PATH `(0,0)`. La interacción M3 y el overlay M4 siguen pendientes de inspección en Godot.

## Referencias

- Requerimiento del usuario en esta conversación, 2026-10-07.
- Paquete de diseño del usuario: `05_HEX_GRID_AND_TERRAIN.md` y `04_DATA_MODELS.md`, consultados el 2026-10-07.
