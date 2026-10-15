shader_type canvas_item;
render_mode unshaded;

uniform vec4 shadow_color : source_color = vec4(0.025, 0.035, 0.055, 1.0);
uniform float shadow_opacity : hint_range(0.0, 0.35) = 0.20;
uniform float wind_speed : hint_range(0.0, 0.02) = 0.0025;
uniform vec2 camera_world_position = vec2(0.0);
uniform vec2 viewport_size = vec2(1152.0, 648.0);
uniform float camera_zoom = 1.0;

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
	vec2 drift = vec2(TIME * wind_speed, -TIME * wind_speed * 0.31);
	vec2 world_position = camera_world_position + (UV - vec2(0.5)) * viewport_size / max(camera_zoom, 0.001);
	vec2 field = world_position * vec2(0.00191, 0.00239) + drift;
	vec2 warp = vec2(sin(field.y * 1.9 + TIME * 0.07), cos(field.x * 1.6 - TIME * 0.05)) * 0.12;
	float broad_shapes = value_noise(field + warp);
	float medium_shapes = value_noise(field * 2.6 + vec2(8.2, 4.1));
	float hand_drawn_edge = value_noise(field * 8.4 + vec2(5.8, 13.2));
	float cloud_shape = broad_shapes * 0.70 + medium_shapes * 0.25 + hand_drawn_edge * 0.05;
	float cloud_mask = smoothstep(0.48, 0.60, cloud_shape);
	float alpha = cloud_mask * shadow_opacity;
	COLOR = vec4(shadow_color.rgb, alpha);
}
