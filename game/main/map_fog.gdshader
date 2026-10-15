shader_type canvas_item;
render_mode unshaded;

uniform vec4 fog_color : source_color = vec4(0.035, 0.075, 0.090, 1.0);
uniform vec2 camera_world_position = vec2(0.0);
uniform vec2 fog_center_world_position = vec2(0.0);
uniform vec2 viewport_size = vec2(1152.0, 648.0);
uniform float camera_zoom = 1.0;
uniform float fog_reveal_radius = 360.0;
uniform float fog_fade_distance = 170.0;
uniform float fog_edge_roughness = 34.0;
uniform float fog_max_opacity : hint_range(0.0, 1.0) = 0.98;
uniform float water_time = 0.0;

float hash21(vec2 point) {
	point = fract(point * vec2(123.34, 456.21));
	point += dot(point, point + 45.32);
	return fract(point.x * point.y);
}

float value_noise(vec2 point) {
	vec2 cell = floor(point);
	vec2 local = fract(point);
	local = local * local * (3.0 - 2.0 * local);
	float lower = mix(hash21(cell), hash21(cell + vec2(1.0, 0.0)), local.x);
	float upper = mix(hash21(cell + vec2(0.0, 1.0)), hash21(cell + vec2(1.0, 1.0)), local.x);
	return mix(lower, upper, local.y);
}

void fragment() {
	vec2 world_position = camera_world_position
		+ (UV - vec2(0.5)) * viewport_size / max(camera_zoom, 0.001);
	float distance_from_base = distance(world_position, fog_center_world_position);
	float edge_noise = value_noise(world_position * 0.009 + vec2(water_time * 0.018, -water_time * 0.012));
	float irregular_radius = fog_reveal_radius + (edge_noise - 0.5) * fog_edge_roughness;
	float fade_width = max(fog_fade_distance, 1.0);
	float fog_amount = smoothstep(irregular_radius - fade_width * 0.45, irregular_radius + fade_width, distance_from_base);

	// Un trazo diagonal irregular rompe el borde uniforme sin ocultar la silueta del mapa.
	float strokes = sin(world_position.x * 0.071 + world_position.y * 0.034
		+ sin(world_position.y * 0.019 + water_time * 0.025) * 1.4);
	float ink_marks = smoothstep(0.76, 0.97, abs(strokes));
	float grain = value_noise(world_position * 0.027 + vec2(3.7, water_time * 0.01));
	float opacity = fog_amount * min(fog_max_opacity, 0.91 + ink_marks * 0.055 + grain * 0.025);
	COLOR = vec4(fog_color.rgb, opacity);
}
