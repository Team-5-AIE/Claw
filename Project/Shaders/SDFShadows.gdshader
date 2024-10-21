shader_type canvas_item;
render_mode unshaded;

uniform vec4 ambientColour : source_color;

uniform bool directionalLightEnabled;
uniform float directionalLightAngle : hint_range(0.0, 360.0);
uniform float directionalLightMaxDist = 50;

void fragment() {
	vec2 sdfPos = screen_uv_to_sdf(SCREEN_UV);
	
	float finalPixelAlpha = ambientColour.a;
	
	float finalDirLightIntensity = 0.0;
	if (directionalLightEnabled)
	{
		float dirLightAngleRad = directionalLightAngle * (3.1416 / 180.0);
		vec2 lightDir = vec2(sin(dirLightAngleRad), cos(dirLightAngleRad));
		
		vec2 sdfSamplePos = sdfPos;
		float accumulator = 0.0;
		while(accumulator < directionalLightMaxDist)
		{
			float dist = texture_sdf(sdfSamplePos);
			accumulator += dist;
			
			if (dist < 0.01) { break; }
			
			sdfSamplePos += dist * lightDir;
		}
		
		float lightIntensity = 1.0;
		if (texture_sdf(sdfPos) >= 0.0)
		{
			lightIntensity = min(1.0, accumulator/directionalLightMaxDist);
		}
		
		finalDirLightIntensity = lightIntensity;
	}
	
	finalPixelAlpha -= finalDirLightIntensity;
	
	COLOR = vec4(ambientColour.xyz, finalPixelAlpha);
}
