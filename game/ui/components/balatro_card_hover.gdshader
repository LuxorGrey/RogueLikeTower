shader_type canvas_item;
render_mode unshaded;

uniform vec2 hover_uv = vec2(0.5, 0.5);
uniform float effect_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float diagonal_position = hover_uv.x * 0.62 + hover_uv.y;
	float shine = 1.0 - smoothstep(0.025, 0.12, abs(UV.x * 0.62 + UV.y - diagonal_position));
	float glow = 1.0 - smoothstep(0.08, 0.82, distance(UV, hover_uv));
	float alpha = (shine * 0.11 + glow * 0.075) * effect_strength;
	COLOR = vec4(vec3(0.78, 0.93, 1.0), alpha);
}
