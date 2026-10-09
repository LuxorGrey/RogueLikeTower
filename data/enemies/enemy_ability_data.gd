class_name EnemyAbilityData
extends Resource

enum Trigger { ON_SPAWN, NEAR_BASE, ARMOR_DEPLETED, SHIELD_DEPLETED, ON_DEATH, PERIODIC }
enum Effect { HASTE, FORTIFICATION, SPAWN_ENEMY, TRANSFORM, TELEPORT }
enum TargetPolicy { SELF, NEARBY_ENEMIES, SELF_AND_NEARBY_ENEMIES }

@export_enum("Al aparecer", "Cerca de la base", "Armor agotado", "Shield agotado", "Al morir", "Periódico")
var trigger: int = Trigger.ON_SPAWN
@export_enum("Haste", "Fortification", "Invocar enemigo", "Transformarse", "Teletransportarse")
var effect: int = Effect.HASTE
@export_enum("Solo este enemigo", "Enemigos cercanos", "Este y enemigos cercanos")
var target_policy: int = TargetPolicy.SELF
@export_range(0, 60, 1) var strength: int = 0
@export_range(0.0, 60.0, 0.1) var interval: float = 0.0
@export_range(1, 20, 1) var near_base_hexes: int = 5
@export_range(0, 5, 1) var radius_hexes: int = 2
@export_range(1, 100, 1) var spawn_count: int = 1
@export var spawn_enemy_data: EnemyData
@export_range(0, 500000, 1) var spawned_health_override: int = 0
@export_range(-1, 500000, 1) var spawned_armor_override: int = -1
@export_range(-1, 500000, 1) var spawned_shield_override: int = -1
@export_range(0.0, 1000.0, 0.1) var spawned_move_speed_override: float = 0.0
@export var transform_enemy_data: EnemyData
@export_range(0, 500000, 1) var transformed_health_override: int = 0
@export_range(1, 20, 1) var teleport_tiles: int = 1

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if trigger < Trigger.ON_SPAWN or trigger > Trigger.PERIODIC:
		errors.append("El trigger de EnemyAbilityData no es válido.")
	if effect < Effect.HASTE or effect > Effect.TELEPORT:
		errors.append("El efecto de EnemyAbilityData no es válido.")
	if target_policy < TargetPolicy.SELF or target_policy > TargetPolicy.SELF_AND_NEARBY_ENEMIES:
		errors.append("La selección de objetivos de EnemyAbilityData no es válida.")
	if strength < 0 or strength > 60:
		errors.append("La fuerza de Haste/Fortification debe estar entre 0 y 60.")
	if trigger == Trigger.PERIODIC and interval <= 0.0:
		errors.append("Una habilidad periódica requiere un intervalo positivo.")
	if effect == Effect.SPAWN_ENEMY and spawn_enemy_data == null:
		errors.append("Una habilidad de invocación requiere EnemyData.")
	if effect == Effect.TRANSFORM and transform_enemy_data == null:
		errors.append("Una transformación requiere EnemyData de destino.")
	if effect == Effect.TELEPORT and teleport_tiles <= 0:
		errors.append("Un teletransporte debe avanzar al menos un hexágono.")
	return errors
