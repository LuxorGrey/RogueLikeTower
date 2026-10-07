# Acceptance Tests

## Grid
- Rotar un HexCoord 6 veces devuelve la posición original.
- Cada celda tiene exactamente 6 vecinos potenciales.
- Distancia A->B == B->A.

## TerrainPiece
- Toda plantilla cargada contiene 7 celdas únicas, conectadas, con pivote `(0,0)`.
- Se cargan las cinco plantillas M3: `straight`, `gentle_turn`, `hard_turn`, `fork` y `convergence`.
- No se puede confirmar una pieza que solape celdas existentes o no toque el tablero por un borde.
- Rotar 6 veces devuelve la pieza original.
- Path edges y sockets laterales flexibles rotan junto a la geometría.
- Las conexiones internas requieren `path_edges` recíprocos; en el borde entre piezas puede emparejarse un socket explícito con uno flexible o dos sockets flexibles complementarios.
- Un borde explícito sin pareja frente a una celda existente es inválido, una salida flexible puede permanecer abierta, y ninguna salida explícita puede entrar en terreno no PATH.
- La salida externa de una celda PATH abre visualmente los laterales contiguos que también queden fuera de la huella y permite colocar una pieza conectada por cualquiera de esos lados.
- Una pieza expansiva requiere enlazar al menos un PATH existente por un par de sockets compatibles.
- El ghost legal se muestra verde; el ilegal, rojo con el motivo en HUD. Solo la colocación legal confirma.
- Confirmar inserta las siete celdas en el tablero; Cancelar, Esc y clic derecho no alteran el tablero.
- La plantilla inicial admite su socket de salida al exterior sin exigir una conexión entrante.
- La verificación de ruta completa spawn-base pertenece a M4, cuando exista `PathGraph`.

## Paths
- Una recta produce ruta válida.
- Una bifurcación produce más de una opción.
- Una convergencia vuelve a una ruta común.
- Ningún spawn activo puede iniciar ronda sin ruta a base.
- La ruta es determinista para una seed/estado dado.

## Elevation
- Path = 0.
- Mountain = 2.
- Torre conserva su HexCoord aunque sprite se dibuje elevado.
- Click/selección funciona sobre sprite desplazado.
- Hover sobre una cara superior resalta con un color que distingue PATH, GRASS y MOUNTAIN.
- En el tablero, el HUD superior muestra coordenadas axiales globales `(q,r)`, terreno y altura; al salir del top face se limpia.
- Un cliff no se detecta como cara superior.
- Las caras cliff se dibujan sin avisos de triangulación y conservan el desnivel de cada borde.
- Los hijos del contenedor `Entities` se ordenan por Y.

## Map navigation
- `H` alterna el HUD sin mover ni escalar el mapa.
- Arrastrar con el botón central pannea el tablero y el ghost juntos.
- La rueda acerca/aleja con zoom uniforme y mantiene el punto bajo el cursor.
- El zoom queda acotado entre `0.45×` y `2.5×`.
- `R` centra la cámara sobre las celdas colocadas y restablece zoom `1×`.

## Combat
- Enemy llega a base y causa daño.
- Tower adquiere target y lo daña.
- Armor/health/regen alteran el resultado.
- Status expira correctamente.
- Matar enemigo entrega recompensa una vez.

## Loop
- Al terminar oleada se entra en expansión.
- No empieza siguiente ronda hasta colocar pieza válida.
- Ronda incrementa una sola vez.
- Ronda 20 completada -> victoria.

## Meta
- Derrota -> moneda meta.
- Compra persiste tras reiniciar.
- Torre desbloqueada aparece en siguiente run.
- Save corrupto/versión desconocida falla de forma segura.

## Scope
- No existe support building.
- Mana no depende de support building.
