shader_type canvas_item;
render_mode unshaded;

uniform float burn_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 ember_color : source_color = vec4(1.0, 0.38, 0.08, 1.0);

float noise_value(vec2 point) {
	return fract(sin(dot(point, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float noise = noise_value(floor(UV * vec2(46.0, 28.0)));
	float burn_edge = 1.0 - burn_progress + (noise - 0.5) * 0.08;
	float distance_to_edge = UV.y - burn_edge;
	float burned = smoothstep(-0.02, 0.02, distance_to_edge);
	float flame_line = 1.0 - smoothstep(0.0, 0.055, abs(distance_to_edge));
	vec3 soot_color = vec3(0.045, 0.025, 0.018);
	vec3 overlay_color = mix(soot_color, ember_color.rgb, flame_line);
	float overlay_alpha = max(burned * 0.88, flame_line * 0.98);
	COLOR = vec4(overlay_color, overlay_alpha);
}
