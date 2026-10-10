shader_type canvas_item;
render_mode unshaded;

uniform vec4 ghost_color : source_color = vec4(0.2, 1.0, 0.42, 1.0);
uniform float ghost_opacity : hint_range(0.1, 1.0) = 0.62;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float alpha = source.a;
	float neighbor_alpha = alpha;
	vec2 sample_step = TEXTURE_PIXEL_SIZE * 2.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			if (x != 0 || y != 0) {
				neighbor_alpha = max(
					neighbor_alpha,
					texture(TEXTURE, UV + vec2(float(x), float(y)) * sample_step).a
				);
			}
		}
	}
	float edge = max(neighbor_alpha - alpha, 0.0);
	vec3 tinted = mix(source.rgb, ghost_color.rgb, 0.72);
	tinted = mix(tinted, ghost_color.rgb, edge * 0.85);
	COLOR = vec4(tinted, alpha * ghost_opacity);
}
