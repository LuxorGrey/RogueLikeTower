shader_type canvas_item;
render_mode unshaded;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_size_px : hint_range(1.0, 24.0, 1.0) = 3.0;

void fragment() {
	vec4 texel = texture(TEXTURE, UV);
	float expanded_alpha = texel.a;
	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			vec2 direction = vec2(float(x), float(y));
			if (length(direction) <= 2.0 && (x != 0 || y != 0)) {
				vec2 sample_uv = UV + direction * TEXTURE_PIXEL_SIZE * outline_size_px;
				expanded_alpha = max(expanded_alpha, texture(TEXTURE, sample_uv).a);
			}
		}
	}
	float alpha = max(texel.a, expanded_alpha * outline_color.a);
	vec3 rgb = mix(outline_color.rgb, texel.rgb, texel.a);
	COLOR = vec4(rgb, alpha);
}
