shader_type canvas_item;
render_mode unshaded;

uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 0.95);
uniform float breakup_scale = 1.0;

vec2 random_point(vec2 cell) {
	vec3 value = fract(vec3(cell.xyx) * vec3(0.1031, 0.1030, 0.0973));
	value += dot(value, value.yxz + 33.33);
	return fract((value.xx + value.yz) * value.zy);
}

vec2 voronoi_distances(vec2 point) {
	vec2 cell = floor(point);
	vec2 local_point = fract(point);
	float nearest = 10.0;
	float second_nearest = 10.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x), float(y));
			vec2 offset = neighbor + random_point(cell + neighbor) - local_point;
			float distance_to_point = length(offset);
			if (distance_to_point < nearest) {
				second_nearest = nearest;
				nearest = distance_to_point;
			} else if (distance_to_point < second_nearest) {
				second_nearest = distance_to_point;
			}
		}
	}
	return vec2(nearest, second_nearest);
}

void fragment() {
	vec2 cellular = voronoi_distances(vec2(UV.x * 5.0 * breakup_scale, UV.y * 2.0));
	float coast_warp = (cellular.x - 0.42) * 0.55;
	float warped_distance = UV.y + coast_warp;
	float coast_band = 1.0 - smoothstep(0.12, 0.88, warped_distance);
	float cell_separation = cellular.y - cellular.x;
	float voronoi_breakup = mix(0.64, 1.0, smoothstep(0.025, 0.18, cell_separation));
	float outer_softness = 1.0 - smoothstep(0.82, 1.0, UV.y);
	float alpha = foam_color.a * coast_band * voronoi_breakup * outer_softness;
	COLOR = vec4(foam_color.rgb, alpha);
}
