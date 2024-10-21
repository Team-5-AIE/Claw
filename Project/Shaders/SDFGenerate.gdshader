shader_type canvas_item;
render_mode unshaded;

float circle(vec2 pos, float rad) {
	return length(pos);
}

void fragment() {
	// Calc distance to nearest object
	float dist = circle(FRAGCOORD, 2.0);
	
	vec4 sdfColour = vec4(dist, dist, dist, 1);
	COLOR = sdfColour;
}
