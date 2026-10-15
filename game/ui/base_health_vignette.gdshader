shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.48, 0.055, 0.09, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float thickness : hint_range(0.05, 0.5) = 0.36;
uniform float softness : hint_range(0.01, 0.4) = 0.28;

void fragment() {
	float edge_distance = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float inner_edge = max(thickness - softness, 0.0);
	float vignette = 1.0 - smoothstep(inner_edge, thickness, edge_distance);
	COLOR = vec4(vignette_color.rgb, vignette_color.a * intensity * vignette);
}
