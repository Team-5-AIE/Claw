shader_type canvas_item;
render_mode unshaded;

uniform vec4 shadowColour : source_color;

uniform float angle : hint_range(0.0, 360.0);
uniform float maxDist = 50;

void fragment() {
	float angleRad = angle * (3.1416 / 180.0);
	vec2 lightDir = vec2(sin(angleRad), cos(angleRad));
	
	vec2 sdfPos = screen_uv_to_sdf(SCREEN_UV);
	
	vec2 sdfSamplePos = sdfPos;
	float accumulator = 0.0;
	while(accumulator < maxDist)
	{
		float dist = texture_sdf(sdfSamplePos);
		accumulator += dist;
		
		if (dist < 0.01) { break; }
		
		sdfSamplePos += dist * lightDir;
	}
	
	float alpha = 0.0;
	if (texture_sdf(sdfPos) >= 0.0)
	{
		alpha = 1.0 - min(1.0, accumulator/maxDist);
	}
	
	COLOR = vec4(shadowColour.rgb, alpha * shadowColour.a);
}
