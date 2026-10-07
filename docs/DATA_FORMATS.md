# Datos editables de oleadas y cartas

Los balances deben poder editarse en una hoja de cálculo y guardarse como CSV versionado. La hoja describe contenido; el código interpreta columnas conocidas y valida el archivo al cargarlo.

## Archivos propuestos

### `enemy_types.csv`

Una fila por tipo de enemigo. Columnas iniciales:

`id,name,role,hp,move_speed,armor,shield,leak_damage,route_policy,reward_gold,flags`

`id` es estable y sin espacios; `role` clasifica rápido, común, tanque, soporte o jefe; `route_policy` toma una clave soportada (por ejemplo, `shortest` o `longest`). Los datos se deben definir en unidades del juego. Los valores exactos siguen pendientes.

### `wave_groups.csv`

Una fila por grupo que aparece en una oleada:

`wave,sequence,enemy_id,count,spawn_interval,entry_policy,hp_multiplier,speed_multiplier,elite,boss_id`

- `wave`: 1–20.
- `sequence`: orden del grupo dentro de la ronda.
- `enemy_id`: referencia a `enemy_types.csv`.
- `count` e `spawn_interval`: tamaño y separación del grupo.
- `entry_policy`: extremo más lejano, aleatorio legal o grupo concreto; enumeración por definir.
- Multiplicadores: modifican estadísticas base sin duplicar una definición por ronda.
- `boss_id`: opcional, requerido en rondas de jefe según el calendario final.

El formato evita una fila con veinte columnas distintas por ronda y permite ordenar, filtrar y comparar todas las oleadas en Excel.

### `cards.csv`

Una fila por carta:

`id,name,category,rarity,target,effect_key,value,value_2,unlock_wave,weight,requires,excludes,description`

Los efectos usan claves implementadas y valores numéricos/textuales validados. `requires` y `excludes` permiten expresar desbloqueos y conflictos sin código por carta. El formato y el calendario definitivo se revisarán al construir el sistema.

## Validaciones mínimas

- ids únicos; referencias a enemigo/carta existentes; CSV con encabezados exactos.
- oleadas dentro de 1–20, cantidades e intervalos válidos, multiplicadores positivos.
- orden de secuencia sin duplicados dentro de una oleada.
- rondas 5, 10 y 15 con su mini-jefe, y ronda 20 con el jefe final, cuando se fije el roster.
- toda clave de ruta, efecto, objetivo, requisito y rareza pertenece a la lista admitida por el motor.
- valores desconocidos producen error legible con archivo/fila/columna; nunca se ignoran silenciosamente.

## Flujo de autoría

1. Editar la hoja en LibreOffice/Excel.
2. Exportar CSV UTF-8 con encabezados estables.
3. Ejecutar el validador al importar o al iniciar modo desarrollo.
4. Mostrar errores por fila y permitir una previsualización/resumen de la ronda.
5. Confirmar en el juego con semillas reproducibles antes de ajustar balance.

La hoja es la fuente de autoría y el runtime consume los CSV validados; no se mantienen copias manuales del mismo balance dentro de scripts.
