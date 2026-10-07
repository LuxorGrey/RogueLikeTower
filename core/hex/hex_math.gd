class_name HexMath
extends RefCounted

const SQRT_3: float = 1.7320508075688772

static func axial_to_world(coord: HexCoord, hex_radius: float) -> Vector2:
	return Vector2(
		SQRT_3 * hex_radius * (float(coord.q) + float(coord.r) * 0.5),
		1.5 * hex_radius * float(coord.r)
	)

static func world_to_axial(position: Vector2, hex_radius: float) -> HexCoord:
	if hex_radius <= 0.0:
		push_error("hex_radius debe ser mayor que cero.")
		return HexCoord.new()

	var fractional_q: float = (SQRT_3 / 3.0 * position.x - position.y / 3.0) / hex_radius
	var fractional_r: float = (2.0 / 3.0 * position.y) / hex_radius
	var fractional_s: float = -fractional_q - fractional_r
	var rounded_q: int = roundi(fractional_q)
	var rounded_r: int = roundi(fractional_r)
	var rounded_s: int = roundi(fractional_s)
	var q_error: float = absf(float(rounded_q) - fractional_q)
	var r_error: float = absf(float(rounded_r) - fractional_r)
	var s_error: float = absf(float(rounded_s) - fractional_s)

	if q_error > r_error and q_error > s_error:
		rounded_q = -rounded_r - rounded_s
	elif r_error > s_error:
		rounded_r = -rounded_q - rounded_s

	return HexCoord.new(rounded_q, rounded_r)
