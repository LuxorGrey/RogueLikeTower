shader_type canvas_item;
render_mode unshaded;

uniform vec4 aura_color : source_color = vec4(0.42, 0.72, 0.9, 1.0);
uniform float glow_strength : hint_range(0.0, 1.0) = 0.42;

void fragment() {
	vec2 point = (UV - vec2(0.5)) * 2.0;
	point.x *= 0.78;
	float radius = length(point);
	float angle = atan(point.y, point.x);
	float pulse = 0.82 + 0.18 * sin(TIME * 1.25);
	float halo = exp(-pow((radius - 0.78) * 6.0, 2.0));
	float rays = pow(max(cos(angle * 18.0 + TIME * 0.24), 0.0), 11.0);
	float radial_rays = rays * exp(-pow((radius - 0.78) * 4.2, 2.0));
	float sparkles = 0.0;
	for (int index = 0; index < 8; index++) {
		float particle_angle = float(index) * 0.785398 + TIME * 0.34;
		float orbit = 0.93 + 0.025 * sin(TIME * 1.8 + float(index) * 1.7);
		vec2 particle_point = vec2(cos(particle_angle) * orbit * 0.78, sin(particle_angle) * orbit);
		float particle_distance = length(point - particle_point);
		sparkles += 1.0 - smoothstep(0.012, 0.035, particle_distance);
	}
	float alpha = (halo * 0.22 + radial_rays * 0.11 + sparkles * 0.48) * pulse * glow_strength;
	COLOR = vec4(aura_color.rgb, alpha);
}
