# Combat System

## Objetivo
Conservar la lectura estratégica de Rogue Tower: enemigos con defensas distintas y torres que funcionan mejor/peor según el objetivo.

## Enemy survivability
Cada enemigo tiene como mínimo:
- Health.
- Armor.
- Regeneration.

No copiar números de Rogue Tower. Crear sistema propio configurable.

## Damage pipeline
Centralizar el cálculo:
1. torre crea `DamagePacket`;
2. aplicar modificadores de run;
3. resolver counter/perfil contra armor/health;
4. aplicar daño;
5. aplicar status;
6. emitir eventos;
7. si health <= 0 -> kill/reward.

No repartir fórmulas entre cada torre.

## Counters
El modelo debe permitir que una torre sea:
- fuerte contra vida;
- fuerte contra armadura;
- anti-regeneración;
- especializada en status;
- generalista.

Los multiplicadores concretos son balance, no arquitectura.

## Regeneración
Regeneración por segundo o tick. Debe poder ser reducida/contrarrestada por efectos o torres si se define una build anti-regen.

## Targeting
Mínimo:
- first/progress;
- last;
- highest health;
- highest armor.

No implementar 15 modos antes de necesitarlos.

## Height advantage
Framework:
```text
height_delta = tower_elevation - target_elevation
```
Debe existir una función única que traduzca `height_delta` a bonus.

La fórmula final sigue abierta. Para prototipo usar bonus configurable y documentado, por ejemplo rango adicional o multiplicador moderado. No fijarlo como balance definitivo.

## Status framework
Primera versión:
- Slow: modifica velocidad.
- Burn: DoT.
- Poison/Bleed: segundo DoT o anti-regen provisional.

El framework debe soportar:
- duración;
- refresh;
- stack;
- tick;
- source;
- limpieza al morir.

## Torre
Estados:
- idle;
- acquire target;
- cooldown;
- attack.

Separar:
- datos;
- targeting;
- ataque;
- visual.

## Enemy path movement
Movimiento visual continuo entre centros de hexes de la ruta.
El enemigo conoce:
- path actual;
- índice;
- progress normalizado.

M5 consume la secuencia axial `PathRoute` cacheada por M4 para inicializar el camino del enemigo y conserva sus propios waypoints, índice y progreso. Si cambia el mapa solo entre rondas, no hace falta recalcular rutas con enemigos vivos. `WaveDirector` escoge candidatos spawn según la política de cada grupo; la muestra usa `FIRST_SORTED`, mientras que la configuración final por ronda sigue abierta. M4 expone candidatos y no decide esa política.

La primera integración M5 implementa `HealthComponent`, `GameBase`, `Enemy`, `PathFollowerComponent` y `WaveDirector`. El enemigo se mueve continuamente entre centros de hex, inicia en la coordenada exterior del endpoint y aplica su daño configurado al llegar; el director retira enemigos llegados o derrotados y termina la oleada al concluir los spawns y quedar cero enemigos activos. La UI bloquea la colocación durante `COMBAT`; una base agotada cambia a `RUN_DEFEAT`, y una oleada superada habilita `TERRAIN_EXPANSION`.

M6 añade el primer ciclo defensivo con una torre `Basic Bolt`: se puede colocar en una celda Grass o Mountain libre, seleccionar, cambiar prioridad y mejorar. La prioridad consulta enemigos vivos en alcance cada 0.1 s: primero/último por fracción recorrida de `PathRoute`, mayor vida actual o mayor armadura configurada. El ataque ocurre durante `COMBAT`, dentro del alcance, a la cadencia configurada; el prototipo aplica daño directamente al `Enemy` y muestra un breve flash vectorial de hitscan. La torre no bloquea PATH ni exige recalcular rutas.

La altura de la torre suma provisionalmente `height_range_bonus_per_level` al alcance por nivel de elevación. Los valores iniciales de Basic Bolt son 10 de daño, 1 ataque/s, 3 hexes de alcance, +5 daño y +0.25 hex por nivel hasta nivel 3; cada nivel de elevación también agrega +0.25 hex. Son datos configurables para validar el sistema, no balance final. Las mejoras no cuestan moneda todavía; M9 añadirá economía. M6 usa `EnemyData.armor` para highest armor, pero el valor no mitiga el daño hasta M7.

El contenido M5 continúa siendo una prueba funcional de base 50 HP, enemigo 20 HP, velocidad 90 px/s, daño de llegada 10, tres enemigos con intervalo 1 s y política `FIRST_SORTED`. Con M6 las torres pueden derrotar esos enemigos; la demo sigue sin representar balance final ni rondas repetibles. Regeneración, recompensas, mitigación y pipeline centralizado de daño siguen en milestones posteriores.
