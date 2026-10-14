# ADR-0064: Reembolso al demoler torres

- Fecha: 2026-10-13
- Estado: Aceptado por petición explícita del usuario; código integrado, aceptación manual pendiente.
- Sustituye: la regla provisional sin reembolso de [ADR-0023](ADR-0023-reglas-de-torres-y-capas-de-vida.md), solo en demolición.

## Contexto

El usuario pidió que demoler torres devuelva Gold siguiendo el comportamiento de Rogue Tower. El coste de compra de este proyecto escala por perfil: `precio_base + cantidad_del_tipo × incremento`. Los niveles y mejoras se acumulan sobre la torre y no deben cambiar el coste de comprar/demoler.

## Decisiones

1. Al demoler una torre de tipo `T`, se devuelve el precio marginal del último slot ocupado: `precio_base(T) + (cantidad_antes_de_demoler(T) - 1) × incremento(T)`.
2. El cálculo usa únicamente el perfil de torre y el conteo previo de torres del mismo tipo. No lee nivel, XP ni upgrades comprados.
3. La devolución se acredita al Gold de la run; el siguiente coste de compra usa el conteo reducido.
4. La cifra devuelta aparece en Tower Info/mensaje y en el tooltip de demolición.

La fórmula marginal exacta es una elección propia para este proyecto, inferida de la curva por cantidad y del precio vigente tras retirar una torre. No se presenta como una transcripción literal de la wiki.

## Fuentes consultadas

- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers), wiki comunitaria de Fandom; consulta 2026-10-13. Referencia contextual para precio base, incremento, cantidad del mismo tipo y que el nivel es irrelevante.
- [Rogue Tower for Newbs (OUTDATED) — Steam Community](https://steamcommunity.com/sharedfiles/filedetails/?id=2742933260), guía comunitaria marcada como desactualizada; consulta 2026-10-13. Contexto sobre la venta de torres mejoradas; no fija el balance de esta demo.

## Consecuencias

- `BuildController` calcula y acredita el reembolso antes de emitir `tower_demolished`.
- Las compras de niveles/XP quedan fuera del reembolso.
- La UI comunica el importe y que los niveles no se reembolsan.
- Hay que revisar en ventana que 1.º, 2.º y 3.º ejemplar devuelven respectivamente su precio marginal configurado y que demoler una torre mejorada no cambia la cifra.
