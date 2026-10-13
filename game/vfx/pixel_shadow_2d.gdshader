shader_type canvas_item;
render_mode unshaded;

uniform vec4 shadow_color : source_color = vec4(0.035, 0.047, 0.078, 0.84);

void fragment() {
	// Keep the source alpha silhouette, but replace its palette with one flat
	// dark color. Nearest sampling on the Sprite2D preserves the pixel-art edge.
	COLOR = vec4(shadow_color.rgb, COLOR.a * shadow_color.a);
}
