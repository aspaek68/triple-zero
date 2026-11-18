shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = vec2(0.5);
	vec2 dir = uv - center;
	float dist = length(dir);
	// Radial blur: sample along the radial direction.
	vec4 col = texture(screen_tex, uv);
	int samples = 6;
	for (int i = 1; i <= samples; i++) {
		float t = float(i) / float(samples);
		vec2 off = dir * t * intensity * 0.04;
		col += texture(screen_tex, uv - off);
	}
	col /= float(samples + 1);
	COLOR = col * (1.0 - intensity * 0.15) + texture(screen_tex, uv) * (intensity * 0.15);
	// Blend with original based on intensity.
	COLOR = mix(texture(screen_tex, uv), col, intensity);
}
