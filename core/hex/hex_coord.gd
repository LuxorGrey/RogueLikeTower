class_name HexCoord
extends RefCounted

const DIRECTION_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 1),
	Vector2i(-1, 0),
	Vector2i(0, -1),
	Vector2i(1, -1),
]

var q: int
var r: int

func _init(q_value: int = 0, r_value: int = 0) -> void:
	q = q_value
	r = r_value

func s() -> int:
	return -q - r

func to_key() -> Vector2i:
	return Vector2i(q, r)

func add(other: HexCoord) -> HexCoord:
	return HexCoord.new(q + other.q, r + other.r)

func neighbor(direction_index: int) -> HexCoord:
	var offset: Vector2i = DIRECTION_OFFSETS[posmod(direction_index, DIRECTION_OFFSETS.size())]
	return HexCoord.new(q + offset.x, r + offset.y)

func equals(other: HexCoord) -> bool:
	return other != null and q == other.q and r == other.r

func distance_to(other: HexCoord) -> int:
	var delta_q: int = q - other.q
	var delta_r: int = r - other.r
	return maxi(maxi(absi(delta_q), absi(delta_r)), absi(delta_q + delta_r))

func rotated60(steps: int) -> HexCoord:
	var result: Vector2i = to_key()
	for _turn in range(posmod(steps, 6)):
		result = Vector2i(-result.y, result.x + result.y)
	return HexCoord.new(result.x, result.y)

static func rotated_direction_index(direction_index: int, steps: int) -> int:
	return posmod(direction_index + steps, DIRECTION_OFFSETS.size())

func _to_string() -> String:
	return "(%d,%d)" % [q, r]
