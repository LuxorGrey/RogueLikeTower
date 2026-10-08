class_name WaveEnemyGroupData
extends Resource

enum SpawnEndpointPolicy { FIRST_SORTED, ROUND_ROBIN }

@export var enemy_data: EnemyData
# In campaign waves, each count unit is a spawn pulse replicated across all active endpoints.
@export_range(1, 10000, 1) var count: int = 1
@export_range(0.0, 60.0, 0.1) var spawn_interval: float = 1.0
@export_enum("Primero ordenado", "Rotación por endpoints")
var spawn_endpoint_policy: int = SpawnEndpointPolicy.FIRST_SORTED
@export_range(0.0, 60.0, 0.1) var delay_before_group: float = 0.0

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if enemy_data == null:
		errors.append("El grupo de oleada no tiene EnemyData.")
	else:
		errors.append_array(enemy_data.validate())
	if count <= 0:
		errors.append("El grupo debe generar al menos un enemigo.")
	if spawn_interval < 0.0:
		errors.append("El intervalo de spawn no puede ser negativo.")
	if delay_before_group < 0.0:
		errors.append("La pausa previa al grupo no puede ser negativa.")
	if spawn_endpoint_policy < SpawnEndpointPolicy.FIRST_SORTED or spawn_endpoint_policy > SpawnEndpointPolicy.ROUND_ROBIN:
		errors.append("La política de spawn endpoint no es válida.")
	return errors
