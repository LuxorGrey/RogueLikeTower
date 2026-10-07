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

Si cambia el mapa solo entre rondas, no hace falta recalcular rutas con enemigos vivos. Esto simplifica enormemente el sistema.
