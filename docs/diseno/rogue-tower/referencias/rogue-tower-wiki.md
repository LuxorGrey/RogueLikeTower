# Referencia de diseño: Rogue Tower Wiki

**Propósito:** recoger datos que ayuden a diseñar nuestro juego, con separación clara entre hechos de la referencia y propuestas propias. No es un clon de la wiki ni una especificación de nuestro balance.

**Fecha de consulta:** 2026-10-06. La wiki tiene 99 páginas y muestra licencia comunitaria CC BY-SA salvo indicación distinta. Esta recopilación resume y estructura la información con atribución y enlaces a las páginas; no pretende ser una copia textual completa de los 99 artículos. Parte de las tablas generales difiere de fichas individuales o changelogs, por lo que las cifras se etiquetan como datos publicados, no como un único balance vigente.

## Jerarquía de referencia para el proyecto

El usuario fija *Rogue Tower* como referencia del gameplay general. Por defecto, se investigarán y propondrán sus sistemas como baseline; las modificaciones expresas del proyecto prevalecen y se registran como desviaciones. Se consultarán la wiki para datos mecánicos y tablas, la página oficial de Steam para el loop/promesa de diseño y las guías de la comunidad como consejos prácticos secundarios. Una guía de jugador no se tratará como regla del juego. Para este proyecto, el cambio estructural principal es sustituir la expansión automática/elección de dirección por construcción de terreno con losetas que el jugador coloca y gira durante preparación.

La página de [Upgrade Cards](https://rogue-tower.fandom.com/wiki/Upgrade_Cards) describe elecciones de mejora al finalizar oleadas y cofres de jefe. Su calendario original (cada 3 oleadas al inicio; más frecuente mediante desbloqueos) deberá adaptarse a la campaña propia de 20 rondas. Se toma el sistema de cartas como baseline, salvo que el usuario indique que no lo quiere.

Steam mantiene un [índice de guías comunitarias de Rogue Tower](https://steamcommunity.com/app/1843760/guides/), con categorías como fundamentos de gameplay, guías de torres, estrategias y árbol de cartas. El índice contiene guías de jugador de calidad/antigüedad diversas; sirven como apoyo para interpretar estrategias, no para sustituir los datos de la wiki o las reglas explícitas del usuario. La [página oficial del juego](https://store.steampowered.com/app/1843760/Rogue_Tower/) define el camino influenciable, la relevancia de la colocación de torres y las mejoras como parte del núcleo anunciado.

Guías comunitarias consultadas como material secundario:

| Guía | Qué aporta | Limitación |
|---|---|---|
| [Rogue Tower for Newbs (OUTDATED)](https://steamcommunity.com/sharedfiles/filedetails/?id=2742933260) | Consejos por torre, colocación, selección de mejoras y rol táctico. | El propio título la marca obsoleta; algunos datos describen el estado del juego en 2022. Solo sirve para formular hipótesis o descubrir interacciones que luego se verifican en la wiki. |
| [Cards Tech Tree](https://steamcommunity.com/sharedfiles/filedetails/?id=2780743120) | Referencia visual comunitaria sobre rutas de desbloqueo de cartas. | El autor la marcó como trabajo en curso y señaló que no había una forma oficial de verificar todas las dependencias. Contrastar cada requisito con la wiki antes de usarlo. |

La página oficial de Steam también declara desbloqueo de torres/edificios, construcción de defensas, mejoras mediante cartas y dinero, expansión táctica del camino, y adaptación a amenazas emergentes. Esto respalda que las cartas y el sistema de preparación no son añadidos optativos en nuestro diseño base; se adaptan a las reglas específicas del proyecto.

## Sistemas de referencia extraídos

La extracción detallada de comportamiento por monstruo se mantiene en [comportamiento-de-enemigos.md](comportamiento-de-enemigos.md); las tablas generales de oleadas/estadísticas están en [monstruos-y-jefes.md](monstruos-y-jefes.md). Esta wiki describe habilidades especiales individuales que no aparecen en la tabla general (por ejemplo, buffos al grupo, invocaciones y teletransporte); deben consultarse por ficha, no inferirse por familia. Las mejoras permanentes y reglas de progresión se documentan en [mejoras-y-progresion.md](mejoras-y-progresion.md); las cartas de run siguen en exportación porque sus árboles son extensos.

| Área | Hechos útiles para diseño | Posible aplicación propia |
|---|---|---|
| Crecimiento del mapa | El camino se expande por losetas y, cuando ya no puede ampliarse, aparece un portal de entrada de enemigos. | Las losetas que consumen espacio también pueden crear presión espacial y mover el frente de aparición. |
| Altura | La elevación beneficia el daño y alcance de torres; hay niveles distintos y la elevación avanzada aparece en etapas tardías. | Proyecto: montañas geométricas con hasta 3 niveles, definidos por grupos conectados de 2–3, 4–6 y 7+ losetas. |
| Sitios de recursos | Vetas de hierro, cristales de maná, casas, tumbas y santuarios interactúan con edificios o momentos concretos de la partida. | Los elementos del mapa pueden convertir una loseta en oportunidad económica, táctica o de riesgo. |
| Defensas | Hay torres de disparo directo, área, ralentización, daño persistente, apoyo/selección de blancos, ataques de largo alcance y economía. | Importar provisionalmente todas las torres, nombres, stats y reglas; los nombres se cambiarán después. |
| Crecimiento de defensas | Las torres mejoran por experiencia/tiempo de objetivo y mediante gasto; el tipo de punto de vida atacado influye en el tipo de mejora. | Importar upgrades, cartas temporales y mejoras permanentes; ajustar los requisitos solo si la campaña de 20 rondas lo obliga. |
| Elecciones de mejora | Hay cartas ofrecidas tras rondas; la cantidad y frecuencia dependen del progreso/desbloqueos. Las cartas pueden habilitar ramas y efectos globales. | Las recompensas pueden combinarse con la oferta de losetas, pero hay que evitar demasiadas decisiones entre rondas. |
| Amenazas | Los enemigos varían en salud, armadura, escudo, velocidad y habilidades; los grupos y jefes se introducen por etapas. | El reparto de enemigos puede enseñar los roles de torre por etapas y poner a prueba la red creada. |
| Presión por fuga | La wiki indica que cada monstruo común inflige 1 daño a la base y que jefes pueden destruirla de inmediato. | Proyecto: base con 20 de integridad; fuga ordinaria = 1, fuga de jefe = letal. Los 20 puntos son diseño propio. |

## Elementos del mapa de la wiki

| Elemento | Comportamiento descrito por la wiki | Información útil para el diseño |
|---|---|---|
| Elevaciones | Niveles de altura que aumentan daño base y alcance de torres; la elevación también puede incrementar el gasto de maná. | Un mismo sitio puede ser más potente y más caro de operar. |
| Vetas de hierro | Permiten colocar minas; estas mejoran la vida máxima y pueden reparar la base. | El recurso espacial puede sostener una estrategia defensiva de supervivencia. |
| Cristales de maná | Un sifón adyacente produce maná; mejoras pueden añadir cristales junto a la base. | Importa definir qué significa adyacencia y si las losetas/edificios compiten por ese borde. |
| Casas | Producen oro al inicio de cada oleada en función de las torres adyacentes y de la ronda; las mejoras pueden añadir casas en la base. | La economía premia planificar espacios y vecindades antes de que empiece el combate. |
| Tumbas | Aparecen en la etapa de oleadas 16–25; habilitan edificios que consumen maná para producir oro. | Los elementos pueden aparecer por capítulo/bioma y cambiar el valor de una zona. |
| Santuarios ocultos | Se describen para la etapa 26–35; son requisito de funcionamiento de una universidad. | Algunos puntos del mapa pueden actuar como requisitos de sistema y no solo como bonificación. |
| Portal | Aparece cuando no se puede extender el camino; funciona como entrada de monstruos y bloquea nuevas ampliaciones de ese camino. | El límite de expansión también puede definir el frente y la dificultad. |

La wiki detalla generación aleatoria y dependencias por oleada. Este proyecto tiene como objetivo provisional 20 rondas; sus calendarios, elementos y cantidades no se trasladan automáticamente.

## Página oficial de Steam

La descripción oficial resume el núcleo de *Rogue Tower* como un camino que se expande de forma continua y que el jugador puede influir. Describe que en cada nivel se elige dirección, que el camino puede torcerse y dividirse, y que el jugador puede controlar parcialmente su forma y la distancia hasta la torre. También destaca elegir entre separar el flujo de enemigos o reunirlos para favorecer el daño de área, y usar cartas para desbloquear/mejorar torres. Esas relaciones validan las referencias funcionales del concepto; nuestra colocación por losetas y las regiones siguen siendo ideas propias.

## Puntos de vida, efectos y lectura de enemigos

La wiki distingue tres reservas de defensa enemiga: **salud**, **armadura** y **escudo**. Las torres tienen multiplicadores diferentes frente a cada reserva. Los estados persistentes de referencia incluyen **sangrado**, **quemadura**, **veneno**, **ralentización**, **celeridad** y **fortificación**. Algunos estados interactúan con una reserva concreta y con ataques posteriores; por ejemplo, un estado puede impedir regenerar cierta reserva o aumentar el daño de ataques contra ella.

El proyecto adopta provisionalmente las tres capas de vida y los estados de referencia, con nombres y comportamiento de *Rogue Tower*, hasta que el usuario los revise. Cualquier modificación para encajarlos con la campaña de 20 rondas se documentará como adaptación.

## Roster de torres (nombres de referencia adoptados temporalmente)

El proyecto usará temporalmente los mismos nombres de las torres de *Rogue Tower*. El usuario prevé renombrarlos más adelante. El objetivo es importar el roster completo, stats, roles y mejoras, registrando discrepancias entre tabla general, ficha individual y changelog.

| Torre de referencia | Rol/rasgo descrito en las páginas consultadas |
|---|---|
| Ballista | Proyectil individual; económica; tiene ramas de daño y ralentización. |
| Mortar | Proyectil explosivo de área y recorrido lento; cifras de la tabla general entran en conflicto con el changelog de su artículo. |
| Tesla Coil | Descargas de área a múltiples enemigos; consume maná; se especializa frente a escudos. |
| Frost Keep | Ralentización en un área cuadrada; su frecuencia puede depender de cuánto camino cubre. |
| Flame Thrower | Daño persistente de quemadura y sinergias contra armadura. |
| Poison Sprayer | Daño persistente de veneno y sinergias contra escudo. |
| Shredder | Daño persistente de sangrado y mejoras de crítico. |
| Encampment | Torre cuyo ritmo se vincula al camino cubierto; aplica efectos de apoyo/campo. |
| Lookout | Marca objetivos y transfiere/mejora el daño que reciben de otras torres. |
| Vampire Lair | Torre de maná asociada a daño/absorción; necesita validación de artículo para detallar. |
| Cannon | Disparo lineal perforante según su artículo. |
| Monument | Invoca un ataque que persigue objetivos según su artículo. |
| Radar | Llama un avión de ataque de largo alcance. |
| Obelisk | Torre de daño de alcance/ritmo característicos; confirmar detalles por artículo. |
| Particle Cannon | Ataque de largo alcance con gasto de maná; confirmar detalles por artículo. |

### Tabla general de estadísticas publicada por la wiki

Transcripción de la tabla general de [Towers](https://rogue-tower.fandom.com/wiki/Towers), en el orden que presenta la página: daño base, multiplicadores de Health/Armor/Shield, alcance, disparos por minuto, coste de maná y precio de compra (el incremento entre paréntesis). Son cifras de referencia de esa tabla; todavía no están reconciliadas con cada ficha individual y su changelog.

| Torre | Daño | Salud × | Armadura × | Escudo × | Alcance | RPM | Maná | Precio |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Ballista | 10 | 10 | 5 | 5 | 5 | 20 | 0 | 10 (+15) |
| Mortar | 20 | 10 | 15 | 5 | 10 | 10 | 0 | 200 (+75) |
| Tesla Coil | 10 | 6 | 3 | 10 | 1.5 | 30 | 5/shot | 200 (+75) |
| Frost Keep | 6 | 10 | 5 | 5 | 2 | 180 | 2/sec | 250 (+100) |
| Flame Thrower | 5 | 6 | 9 | 3 | 4 | 60 | 1/shot | 300 (+75) |
| Poison Sprayer | 5 | 6 | 3 | 9 | 4 | 60 | 1/shot | 300 (+75) |
| Shredder | 10 | 20 | 10 | 10 | 5 | 5 | 0 | 500 (+100) |
| Encampment | 20 | 10 | 15 | 5 | 2 | 5 | 0 | 500 (+100) |
| Lookout | 1 | 2 | 1 | 3 | 8 | 0 | 0 | 500 (+100) |
| Vampire Lair | 12 | 10 | 5 | 5 | 9 | 6 | 12/shot | 750 (+150) |
| Cannon | 20 | 10 | 20 | 5 | 6 | 20 | 0 | 750 (+150) |
| Monument | 15 | 10 | 5 | 15 | 7 | 12 | 3/shot | 750 (+150) |
| Radar | 20 | 20 | 10 | 10 | 30 | 700 | 0 | 1000 (+250) |
| Obelisk | 8 | 5 | 10 | 2 | 5 | 360 | 2/shot | 1000 (+250) |
| Particle Cannon | 50 | 15 | 10 | 20 | 20 | 12 | 12/shot | 1000 (+250) |

#### Conflictos de versión observados

- La ficha de [Mortar](https://rogue-tower.fandom.com/wiki/Mortar) publica atributos base 20 daño, 10/15/5 de multiplicadores, alcance 10 y 10 RPM; su propia sección de cambios describe una revisión con 10 daño, 5 de alcance, multiplicadores 5/10/1 y 100 RPM. No elegiré una de esas cifras como «la actual» sin una fuente/versionado más claro.
- Las fichas individuales de [Ballista](https://rogue-tower.fandom.com/wiki/Ballista) y [Frost Keep](https://rogue-tower.fandom.com/wiki/Frost_Keep) muestran información de nivel/alcance/ritmo que no se alinea por completo con la tabla general. Además, habilidades concretas pueden explicar parte de las diferencias, pero hay que documentarlo por ficha.
- La página de torres señala que Frost Keep y Encampment pueden aumentar el ritmo en función de los caminos cubiertos; no debe tratarse su RPM como constante universal.

#### Reglas generales de torres

Transcripción estructurada del artículo [Towers](https://rogue-tower.fandom.com/wiki/Towers), adoptada provisionalmente en el proyecto junto con los nombres y la lista de torres. Los cambios concretos se validarán contra las fichas de torre y changelogs.

| Regla | Dato de referencia |
|---|---|
| Daño por capa | Daño = daño base × multiplicador de la capa actual (Shield, luego Armor, luego Health). |
| Subida de nivel | Cada nivel de torre añade +1 daño base y +1 al multiplicador de una capa. |
| Experiencia de torre | Gana XP por el tiempo que apunta a enemigos, no por el daño hecho. XP/s = 0,5 + 1/(2 × alcance). El tipo de capa del enemigo al que apunta determina qué multiplicador gana XP. |
| Mejora manual | Se puede comprar nivel en un multiplicador; el precio escala con el nivel de la torre. |
| Elevación | Cada nivel de elevación añade +1 daño base y +0,5 alcance. También puede aumentar el coste de maná porque sube el daño base. |
| RPM | Los disparos por minuto normalmente son fijos; Frost Keep y Encampment escalan su cadencia con el camino cubierto. |
| Maná | Algunas torres lo consumen para funcionar; suele escalar con daño base, salvo Frost Keep, que consume 2 maná/s. |
| Estados | Algunas cartas habilitan que torres causen una parte de su daño como estado persistente. |
| Críticos | Probabilidad inicial 0%. Cada +50% de probabilidad habilita un escalón de daño ×2, ×3 y ×4 respectivamente; máximo útil: 150%. Por disparo se prueba primero ×4, luego ×3 y luego ×2, deteniéndose con el primer éxito. |
| Prioridades de objetivo | Se configuran hasta 3 criterios: Progress, Near Death, Most/Least Health, Most/Least Armor, Most/Least Shield, Slowest, Fastest y Marked. |
| Compra | Precio por unidad = precio base + incremento por cantidad de torres iguales actualmente colocadas; el nivel de torre no cambia el coste. |
| Demolición | Reembolsa oro y reduce el coste futuro de comprar otra torre del mismo tipo. |

La tabla general contiene las 15 torres enumeradas en la wiki. Sus nombres se adoptan temporalmente en el proyecto. La extracción sigue con fichas individuales, cartas, edificios y habilidades, conservando el mismo criterio de discrepancias. La tabla de mejoras permanentes generales ya se transcribió en [mejoras-y-progresion.md](mejoras-y-progresion.md); los árboles de cartas temporales siguen incompletos.

## Oleadas y composición

## Elementos de mapa relevantes para este proyecto

La página de [Map features](https://rogue-tower.fandom.com/wiki/Map_features) describe elevaciones normales de nivel 1, 2 y 3. Las torres colocadas sobre ellas reciben **+1 de daño base y +0,5 de alcance por cada nivel de elevación**. Elevaciones avanzadas de nivel 4–6 pueden aparecer entre las oleadas 26–45. Estos son datos del juego de referencia, no reglas vigentes del terreno del proyecto. El sistema propio actual define STONE de altura 1 con multiplicador configurable de alcance; ver [sistema de losetas](../sistemas/sistema-losetas-isometricas.md).

La misma página describe el Portal como punto de aparición de monstruos cuando el camino no puede seguir expandiéndose porque todas las opciones están bloqueadas, y dice que un camino que ya generó Portal no puede expandirse más. La adaptación propia ya tiene una regla diferente confirmada: los enemigos entran por todos los extremos abiertos salvo la base, y todas las piezas con camino nuevas tienen que conectar con la red existente. Por tanto, no se importa la condición de portal terminal de Rogue Tower.

| Elemento de referencia | Aparición/posición descrita | Efecto y regla útil | Adaptación al proyecto |
|---|---|---|---|
| Elevation | Generación aleatoria; nivel 1–3. | Cada nivel da +1 daño base y +0,5 alcance a torres; según torre, también puede aumentar coste de maná. | Dato de referencia; no se adopta como regla de terreno vigente. El proyecto usa STONE con alcance configurable (ADR-0013). |
| Advanced Elevation | Puede aparecer en rondas 26–45; nivel 3–6. | Funciona como elevación normal. | Se descarta por campaña de 20 rondas y límite de altura acordado. |
| Iron Vein | Generación aleatoria del mapa. | Una Mine adyacente añade +1 a la vida máxima de base y 10% de probabilidad por nivel de reparar 1 punto. | Fuente de inspiración para regiones mineras, si se aprueban recursos/curación. |
| Mana Crystal | Generación aleatoria; también pueden aparecer junto a la base con desbloqueos. | Mana Siphon adyacente genera 1 maná/segundo. | Mantener como feature de referencia sujeto a resolver el maná y la adaptación al sistema de losetas. |
| House | Generación aleatoria; desbloqueos pueden añadir casas en la base. | Al inicio de cada oleada da oro igual a torres adyacentes × número de oleada; diagonal no cuenta. | Posible referencia de terreno de economía. |
| Grave | Puede aparecer entre rondas 16–25. | Permite colocar Haunted House adyacente. | Aparición fuera de campaña propia; elemento no trasladado directamente. |
| Occult Shrine | Generación entre rondas 26–35; un cambio de versión garantiza una por loseta del intervalo. | Requisito de adyacencia para University. | No trasladado directamente; posible hito de región/estructura tardía. |
| Portal | Aparece al bloquearse todas las expansiones de un camino. | Punto de entrada de monstruos; el camino con portal no se expande más. | Sustituido por la regla propia: cada extremo abierto no ocupado por la base es entrada, y no hay un cierre de expansión especial. |

## Support Buildings adoptados temporalmente

La categoría que el usuario llamó «super buildings» es [Support Buildings](https://rogue-tower.fandom.com/wiki/Support_Buildings). El usuario confirma que importará los cinco edificios y sus nombres de referencia de forma temporal; sus efectos se documentarán desde las fichas individuales y su funcionamiento con oro/maná se adaptará al formato de 20 rondas según ADR-0008.

| Edificio | Coste publicado | Ubicación/requisito | Efecto resumido |
|---|---:|---|---|
| [Mana Siphon](https://rogue-tower.fandom.com/wiki/Mana_Siphon) | 100 oro | Junto a Mana Crystal, misma elevación para operar | Genera 1 maná/segundo. Sin cristal adyacente no produce. |
| [Mine](https://rogue-tower.fandom.com/wiki/Mine) | 150 oro | Junto a Iron Vein | +1 vida máxima a la base y +10% de probabilidad por nivel, cada oleada, de reparar 1 vida. La vida extra también aumenta ingresos de Haunted House en la versión descrita por su ficha. |
| [Haunted House](https://rogue-tower.fandom.com/wiki/Haunted_House) | 100 oro | Junto a Grave | Consume 1 maná/s y genera oro con los espíritus. La fórmula anterior publicada era √(eficiencia × tumbas adyacentes × maná consumido); la ficha advierte que cambió para basarse en la vida de la base y que el historial/fórmula no está totalmente limpiado. Cifra pendiente de verificar por versión. |
| [Mana Bank](https://rogue-tower.fandom.com/wiki/Mana_Bank) | 500 oro | Cualquier posición | +20 maná máximo y +1 maná/s base. Saving Account I/II suman +15/+30 de máximo; el historial indica que se eliminó una tercera carta y se cambió el bono a +15. |
| [University](https://rogue-tower.fandom.com/wiki/University) | 500 oro | Junto a Occult Shrine | Inversión de oro para una probabilidad de +1 al multiplicador global por capa al inicio de cada oleada. Cada mejora compra +1% a una capa; primera mejora 20 oro y siguientes +20 de coste incremental. Scholarships mejoran investigación; Research Breakthrough! da +5% crítico global. |

Las reglas individuales y upgrades de estos edificios se extraerán en detalle; el marco de recursos oro/maná está confirmado en ADR-0008, aunque sus tasas y cantidades propias siguen pendientes de balance.

## Recursos de referencia

| Recurso | Uso y adquisición según la wiki | Precaución al adaptarlo |
|---|---|---|
| Oro | Compra torres/edificios y mejora torres/universidades. Inicio mínimo 1000 (permanentes pueden subirlo hasta 2000); muertes dan oro relacionado con oleada de entrada, con excepción de Goblin (4), y +1 por cada tipo de torre que dañó al enemigo. Casas y Haunted Houses también producen oro. | Oro confirmado como recurso de run; ingresos/costes del formato de 20 rondas siguen por balancear (ADR-0008). |
| Maná | Recurso de operación para ciertas torres/edificios. Fuentes: mejoras permanentes, cartas, Mana Siphon y Mana Bank. | Maná confirmado como segundo recurso; límites/regeneración y costes de run pendientes de balancear (ADR-0008). |
| XP | Se consigue entre partidas y desbloquea contenido/mejoras permanentes; las fórmulas varían por modo/oleadas superadas. | Se conserva como metaprogresión; fórmula aplicable a 20 rondas pendiente de decidir. |

## Estados que alteran los combates

La página de [Status Effects](https://rogue-tower.fandom.com/wiki/Status_Effects) detalla estados de daño y de movimiento. Valores base resumidos; cartas pueden aumentarlos.

| Estado | Efecto base | Función contra capas/otras reglas |
|---|---|---|
| Bleed | Hasta 24 daño/segundo hasta agotarse; daño reducido a la mitad si el objetivo está en Armor o Shield. | Impide regenerar Health; los ataques obtienen +1 multiplicador contra Health. |
| Burn | Hasta 24 daño/segundo; mitad si el objetivo está en Health o Shield. | Impide regenerar Armor; ataques obtienen +1 multiplicador contra Armor. |
| Poison | Hasta 24 daño/segundo; mitad si el objetivo está en Health o Armor. | Impide regenerar Shield; ataques obtienen +1 multiplicador contra Shield. |
| Slow | Reduce velocidad hasta 60%; máximo 60, decae a 6 por segundo. | Frost Keep/Ballista con mejora; algunas cartas conectan Slow con daño Burn/Poison. |
| Haste | Aumenta velocidad hasta 60%; máximo 60, decae a 6 por segundo. | Proviene de habilidades de monstruos y puede ser contrarrestado por Encampment con mejoras. |
| Fortification | Reduce en 5 el daño base recibido por cada efecto; máximo 60, decae a 6 por segundo. | Suele provenir de habilidades enemigas. |

Son reglas de referencia para el dossier, no un compromiso de mantener seis sistemas de estado. Las fichas individuales siguen siendo necesarias para registrar inmunidades y habilidades concretas.

## Daño por fugas y resistencia de la base

El artículo general de [Monsters](https://rogue-tower.fandom.com/wiki/Monsters) indica que cada monstruo común inflige **1 de daño** a la torre base y que los monstruos jefe pueden destruirla de inmediato. El usuario confirmó que cualquier fuga daña la base y que llegar a cero termina la partida en cualquier ronda. Se adopta como referencia 1 de integridad por enemigo ordinario y fuga letal para los jefes, alineada con la condición de derrota del proyecto.

El artículo general no publica un valor inicial universal de integridad. La página [Permanent Upgrades](https://rogue-tower.fandom.com/wiki/Permanent_Upgrades) muestra mejoras que aumentan la vida máxima de la base, y [Support Buildings](https://rogue-tower.fandom.com/wiki/Support_Buildings) describe una mina junto a una vena de hierro que añade vida máxima y oportunidad de reparación. El proyecto fija por decisión propia 20 de integridad inicial; no se presenta como dato de Rogue Tower. Como referencia secundaria, el juego tiene defensas single/double/triple con distinto número de caminos, pero nuestro modo inicial único y su base necesitan su propio balance.

La wiki organiza el juego de referencia en cuatro etapas: rondas 1–15, 16–25, 26–35 y 36–45. A partir de las etapas tardías selecciona grupos temáticos de enemigos; algunos jefes aparecen al final de cada etapa. El catálogo incluye, entre otros, grupos de orcos, no muertos, entidades fantasmales, demonios, máquinas, elementales, sólidos geométricos, invasores y seres eldritch.

No se traslada este calendario de 45 rondas. La utilidad para Rogue Tower es observar cómo los cambios de familia de enemigos crean pruebas de composición y obligan a adaptar las defensas. En una campaña de 20 rondas cabe decidir si cada capítulo dura cinco rondas o si se usa una curva continua.

## Economía y edificios de apoyo

La referencia usa oro para construir y mejorar, maná para operar algunas torres/edificios y XP para desbloquear mejoras permanentes/cartas. El coste de una torre puede crecer con el número de torres del mismo tipo. Los edificios de apoyo interactúan con elementos del mapa (mina/vena, sifón/cristal, casa/torres adyacentes) y algunos se pueden colocar libremente. El usuario confirmó oro y maná como recursos distintos para el proyecto; las tasas/costes se adaptarán al formato de 20 oleadas (ADR-0008).

La referencia separa economía de construcción, consumo de activación, experiencia de metaprogresión y producción ligada al mapa. El usuario confirmó conservar oro y maná separados, sustituyendo la regla inicial de un recurso (ADR-0008). También está confirmado el esquema de recompensa fija por oleada y bonus por bajas/regiones; su importe y reparto entre recursos se debe conciliar con esta economía. La experiencia de metaprogresión y el papel económico de las regiones siguen por adaptar.

## Lo que falta para una exportación de datos exhaustiva

La wiki contiene páginas separadas de cada torre, enemigo, carta, mejora, efecto y edificio, además de changelogs. Una tabla maestra de cifras fiable necesita reconciliar las páginas individuales con las tablas generales y fijar versión del juego. El índice tiene 99 páginas. Ya hay una transcripción de la tabla general de torres y una extracción de la tabla de monstruos por grupo en [monstruos-y-jefes.md](monstruos-y-jefes.md). El índice y el control de cobertura por artículo se mantienen en [indice-y-cobertura.md](indice-y-cobertura.md); la exportación total seguirá en curso hasta que cada página esté resumida o registrada como página sin datos mecánicos.

## Fuentes

- [Rogue Tower Wiki: Towers](https://rogue-tower.fandom.com/wiki/Towers)
- [Rogue Tower Wiki: Map features](https://rogue-tower.fandom.com/wiki/Map_features)
- [Rogue Tower Wiki: Monsters](https://rogue-tower.fandom.com/wiki/Monsters)
- [Rogue Tower Wiki: Hit Points](https://rogue-tower.fandom.com/wiki/Hit_Points)
- [Rogue Tower Wiki: Status Effects](https://rogue-tower.fandom.com/wiki/Status_Effects)
- [Rogue Tower Wiki: Upgrade Cards](https://rogue-tower.fandom.com/wiki/Upgrade_Cards)
- [Rogue Tower Wiki: Upgrades](https://rogue-tower.fandom.com/wiki/Upgrades)
- [Rogue Tower Wiki: Permanent Upgrades](https://rogue-tower.fandom.com/wiki/Permanent_Upgrades)
- [Rogue Tower Wiki: Changelogs](https://rogue-tower.fandom.com/wiki/Changelogs)
- [Rogue Tower Wiki: comportamiento de enemigos, fichas individuales](comportamiento-de-enemigos.md)
- [Rogue Tower en Steam, página oficial](https://store.steampowered.com/app/1843760/Rogue_Tower/)
- [Guía oficial de losetas de Carcassonne, Devir Américas](https://deviramericas.com/guia-de-losetas-de-carcassonne/)
- [Infografía de 72 losetas base aportada por el usuario](https://deviramericas.com/wp-content/uploads/2022/01/Carcassonne-infografia-bolsillo-single.pdf)
- [Guía single de distribución de las 72 losetas, PDF de Devir](https://devir.mx/wp-content/uploads/2022/05/Carcassonne-infografia-bolsillo-single.pdf)

Fuente consultada con el índice de búsqueda web el 2026-10-06. Los datos y nombres pertenecen a sus titulares respectivos y se incluyen como referencia comparativa con atribución.

## Aclaración sobre la referencia de Carcassonne

La [guía de Devir](https://deviramericas.com/guia-de-losetas-de-carcassonne/) presenta su infografía single/doble como cantidades por tipo de loseta del juego base. El PDF proporcionado pesa aproximadamente 61 MB y el lector web no puede extraerlo. El usuario aportó además la imagen de la matriz A–Y, que se conserva en el proyecto; la transcripción de sus tipos y valores está en [losetas-carcassonne-adaptacion.md](losetas-carcassonne-adaptacion.md).

Hay una discrepancia visible: los valores de la imagen recibida suman 75, mientras una edición base de Devir se describe con 72 losetas. No se corrige ni normaliza silenciosamente. La guía aún debe cotejarse con el PDF exacto/edición del juego. Para el diseño, el usuario decidió que los pesos prioricen patrones frecuentes, en especial caminos; mientras se resuelve la cifra total, la imagen recibida es la referencia visual de trabajo.

El dossier describe las mecánicas publicadas de *Rogue Tower* como referencia, separadas de las reglas del proyecto. La antigua adaptación de ciudad a montaña, monasterios y campamentos está sustituida para la creación del terreno por [Sistema de losetas isométricas](../sistemas/sistema-losetas-isometricas.md). La dirección visual se documenta en [imagenes-de-referencia.md](imagenes-de-referencia.md); los datos lógicos vigentes en ADR-0013.
