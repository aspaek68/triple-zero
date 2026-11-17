shader_type canvas_item;

// Intensity of the whole effect (0 = off).
uniform float intensity : hint_range(0.0, 1.0) = 0.6;
// Vignette darkness at the screen corners.
uniform float vignette : hint_range(0.0, 1.0) = 0.55;
// Film grain amount.
uniform float grain : hint_range(0.0, 1.0) = 0.12;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	// Vignette: darken towards the edges.
	vec2 c = uv - 0.5;
	float dist = length(c);
	float vig = smoothstep(0.35, 0.85, dist);
	// Film grain: animated noise.
	float g = hash(uv * 900.0 + TIME * 47.0) - 0.5;
	float g2 = hash(uv * 1400.0 - TIME * 31.0) - 0.5;
	float grain_val = (g + g2) * 0.5;
	// Final alpha: vignette + grain, scaled by intensity.
	float a = (vig * vignette + grain_val * grain * 0.4) * intensity;
	a = clamp(a, 0.0, 0.85);
	COLOR = vec4(0.0, 0.0, 0.0, a);
}
