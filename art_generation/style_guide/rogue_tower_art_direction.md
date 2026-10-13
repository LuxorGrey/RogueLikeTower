# Dirección artística — Rogue Tower

**Estado:** dirección artística y cinco muestras aprobadas por el usuario el 2026-10-13 para producir las 18 piezas restantes. La aceptación artística final del conjunto completo sigue pendiente de su revisión.

## Fuentes y alcance

- Brief adjunto por el usuario: ilustración 2D de fantasía gótica, dibujo a mano, contorno irregular oscuro, materiales envejecidos y color terroso apagado. Se conserva esa intención sin copiar assets concretos de otro juego.
- Referencias de estructura: los archivos listados en el [manifiesto](../asset_manifest.md), inspeccionados en su estado actual.
- En el adjunto no llegó una carpeta de capturas externa. Por tanto, la guía toma la descripción escrita como referencia estética y las texturas reales de Rogue Tower como referencia técnica.
- Las cinco muestras aprobaron esta dirección para la producción del lote; los valores de paleta siguen siendo orientativos y configurables.

## Lenguaje visual compartido

### Paleta base provisional

| Uso | Colores de trabajo | Regla |
|---|---|---|
| Tinta y sombra | carbón #211D1C, marrón negro #342B27 | Contornos y sombras profundas; evitar negro plano dominante. |
| Piedra | pizarra #50585A, gris musgo #70756B, luz #9A9582 | Las montañas se leen primero como roca, incluso con musgo. |
| Hierba | oliva #596546, musgo #78805A, paja #A09264 | Variar temperatura, no luminosidad de forma abrupta entre los tres tiles. |
| Tierra | umber #594535, arcilla apagada #806447, ocre #A18A62 | Sin líneas ni manchas que sugieran ruta, dirección o huellas. |
| Madera y cuero | corteza #50382D, madera #79583D, luz #A07A50 | Vetas curvas y escasas, grietas cortas; nada de barniz. |
| Hierro | #393B39, #66635A, óxido #80513C | Planos mates, muescas y remaches legibles a tamaño de juego. |
| Hueso | marfil #D4C8A8, sombra #887A63 | Mancha irregular con línea oscura fina; sin gore. |
| Acentos | cian grisáceo #579498, rojo vino #873C39, veneno oliva #879341, brasa #B26A3E | Un acento dominante por función. Brillo pequeño, sin halo grande. |

Los valores son una paleta de arranque, no una regla de balance ni una paleta final aprobada. Los tonos pueden desplazarse para mantener contraste con el tile vecino, pero no hacia saturación luminosa.

### Contorno, línea y detalle

- Contorno exterior con tinta carbón, ligeramente desigual y con esquinas orgánicas; no usar trazo vectorial geométrico perfecto.
- Como punto de partida relativo, el contorno de objetos ocupa alrededor del 1,5–2,5 % del ancho visual ocupado. La línea interior suele medir entre la mitad y dos tercios de ese grosor.
- En las caras de terreno no se añade un borde decorativo alrededor del hexágono. El límite alfa existente define la silueta y debe mantenerse pixel por pixel en posición.
- La línea interior describe grietas, vetas, facetas y hojas. Limitar el rayado cruzado a zonas de sombra; no cubrir superficies completas con ruido.
- Todo detalle debe seguir separándose al tamaño de render actual. Se omiten rayas que desaparecerían al reducir los sprites.

### Forma, materiales y volumen

- Siluetas algo asimétricas y hechas a mano, sin cambiar la identidad ni la función del original.
- Piedra: planos rotos, grietas cortas y variación de valor en 2–3 masas pintadas.
- Madera: piezas torcidas, uniones visibles, fibras curvas y desgaste localizado.
- Metal: bordes golpeados, hierro ennegrecido y puntos de óxido; sin reflejos especulares realistas.
- Vegetación: hojas y hierbas que terminan en puntas dibujadas, organizadas en grupos; evitar ruido uniforme.
- Cristal, electricidad, hielo, fuego y veneno: acentos planos pequeños que distinguen función sin efectos de ataque permanentes ni glow ambiental.
- Hueso y símbolos se incorporan solo donde el brief lo pide y la silueta fuente los admite.

### Color y sombreado

- Iluminación constante desde arriba a la izquierda, compartida por el conjunto. La cara superior recibe la luz; los bordes inferiores y huecos reciben sombra.
- Volumen con manchas pintadas planas, un tono de sombra y uno de luz por material. Nada de gradientes PBR o brillos cinematográficos.
- Desaturar los colores actuales más intensos. Reservar cian, rojo, verde venenoso y naranja para acentos funcionales muy localizados.
- La base puede llevar un acento cálido discreto; el portal puede usar rojo vino. Ninguno debe convertirse en una fuente de luz con halo expansivo.

### Perspectiva y escala

- Vista superior 2D y orientación exacta de cada original. Los tiles permanecen en la misma geometría hexagonal y no reciben paredes, montañas ni sombras que sobresalgan.
- Torres y obstáculos conservan su inclinación y volumen lateral existente. No se convierten en ilustraciones isométricas nuevas.
- El canvas, su centro, los márgenes alfa y el punto de apoyo se preservan por asset. Las dimensiones observadas en el manifiesto son las de cada original; no se normalizan entre categorías.
- El código actual dibuja el terreno en una caja de 90×104 unidades por celda hexagonal, los obstáculos en 86×86 unidades con un offset vertical de 6, las torres alrededor de 84×84 según cada Resource, la base a 176×176 y el portal a 64×96. Estos son valores de presentación existentes, no tamaños de exportación propuestos.
- El punto funcional de cada objeto continúa en el centro/alineación que usa el recurso actual; no se añaden bases, pedestales o sombras que cambien el apoyo.

### Densidad por familia

- Grass: grupos pequeños de hierba y hojas; diferencias entre variantes por densidad y estado de la planta, manteniendo la misma escala de trazo.
- Mountain: placas de roca legibles, grietas finas y musgo secundario; MOUNTAIN_02 puede tener fracturas más visibles sin cambiar su masa total.
- Dirt: variación de gravilla, compactación y erosión; nunca caminos, huellas, bifurcaciones o señales de dirección.
- Obstáculos: una masa principal clara, separable del fondo y del tile. No incluyen terreno hexagonal.
- Torres: componentes mecánicos identificables antes de los adornos. Todas comparten línea, contraste, envejecimiento y cantidad de hatching.
- Base y portal: más presencia que una torre normal mediante escala visual y contraste de silueta; no agregando detalle microscópico.

## Criterios de aprobación de las muestras

Antes de aceptar el conjunto deben coincidir el color de tinta, el grosor relativo de línea, la luz, la textura y la perspectiva. Se comprueba cada muestra sobre su transparencia y a tamaño de render, y se compara la huella del original. Grass_01 sirve como plantilla geométrica provisional de Dirt_01 porque no existe una textura Dirt fuente; esa correspondencia está marcada expresamente en el manifiesto.

Las cinco muestras aprobadas y las 18 salidas posteriores siguen siendo propuestas de arte fuera del juego; ninguna se conectó a Resources. La [composición de los 23 assets](../previews/full_asset_composition.png) permite revisar el conjunto a la escala de presentación actual. El [informe final](../validation/final_validation.md) separa el resultado técnico de la aceptación artística del usuario.
