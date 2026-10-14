# ADR-0073: Elevaciones 0–3 y bonus de torre

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código integrado, aceptación visual pendiente.
- Amplía y sustituye el rango lógico de elevación de [ADR-0063](ADR-0063-seleccion-y-retirada-de-objetos-del-terreno.md) y el feedback de altura de [ADR-0069](ADR-0069-desbloqueos-xp-y-feedback-de-altura.md).

## Contexto

El juego solo admitía PATH 0, Grass 1 y Mountain 2, aunque el terreno debe variar sus desniveles por mapa y el jugador pidió que la altura sea legible tanto en terreno como en las torres.

## Decisiones

1. El rango lógico es 0–3: PATH solo usa 0; Grass usa 1 o 2; Mountain usa 2 o 3. Cada celda construible recibe una elevación reproducible por seed de run, coordenada/identidad de oferta. La card, el ghost y el tablero confirmado conservan el mismo valor.
2. Una torre en altura h gana `+h` de daño base y `+0.5 × h` hexágonos de alcance. Las reglas configurables de coste de Mana siguen perteneciendo a cada `TowerData`.
3. La torre construida muestra sobre su sprite una insignia con su bonus de daño efectivo (`+1`, `+2` o `+3`). El tooltip y Tower Info continúan mostrando daño y alcance.
4. PATH no recibe desnivel. El anillo de la base no tiene una regla especial de terreno bajo; el mapa sortea Grass/Mountain con sus rangos habituales.
5. Si en el futuro se incorpora un edificio cuya colocación dependa de una feature adyacente, su regla deberá evaluar la elevación de la feature vecina además de su relación axial. No se añade ahora ningún edificio de soporte ni lógica nueva de adyacencia.
6. No se incorporan elevaciones avanzadas 4–6: el diseño de este proyecto termina en 3.

## Consecuencias

- `HexCell`, `TerrainPieceCellData` y sus validadores aceptan el rango y combinaciones de terreno indicados.
- El offset visual continúa siendo 28 px por nivel; fachadas, hover, ghost y selección deben cubrir desniveles de hasta tres niveles.
- Los perfiles/configuraciones de Mana mantienen su comportamiento actual: los que escalan por daño pueden elevar su coste efectivo con el bonus de altura.
- La revisión visual de generación, insignias, oclusión y colocación queda pendiente en M34 de `10_ACCEPTANCE_TESTS.md`.

## Referencias

- Petición explícita del usuario, 2026-10-14; fija los rangos PATH/Grass/Mountain y el tope 3.
- [Map features — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Map_features) y [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers), wiki comunitaria consultada el 2026-10-14. Los extractos indexados describen el bonus de altura (+1 daño y +0.5 rango por nivel) y alturas avanzadas; prevalece el límite explícito 0–3 del proyecto.
- [05 — Hex Grid & Terrain](../design/05_HEX_GRID_AND_TERRAIN.md), consultado el 2026-10-14.
