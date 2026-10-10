shader_type canvas_item;
render_mode unshaded;

uniform vec4 outline_color : source_color = vec4(0.46, 0.95, 1.0, 0.95);

void fragment() {
	float center_alpha = texture(TEXTURE, UV).a;
	float near_alpha = center_alpha;
	float far_alpha = center_alpha;
	vec2 near_step = TEXTURE_PIXEL_SIZE * 5.0;
	vec2 far_step = TEXTURE_PIXEL_SIZE * 10.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			if (x != 0 || y != 0) {
				vec2 direction = vec2(float(x), float(y));
				near_alpha = max(near_alpha, texture(TEXTURE, UV + direction * near_step).a);
				far_alpha = max(far_alpha, texture(TEXTURE, UV + direction * far_step).a);
			}
		}
	}
	float outline = max(near_alpha - center_alpha, 0.0);
	float halo = max(far_alpha - center_alpha, 0.0) * 0.26;
	COLOR = vec4(outline_color.rgb, max(outline, halo) * outline_color.a);
}
