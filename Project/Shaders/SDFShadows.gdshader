shader_type canvas_item;
render_mode unshaded;

uniform bool lightingEnabled;

uniform vec2 camOffset;

uniform vec4 ambientColour : source_color;

//uniform bool directionalLightEnabled;
//uniform float directionalLightAngle : hint_range(0.0, 360.0);
//uniform float directionalLightMaxDist = 50;

// xy = pos, z = intensity
uniform vec3 pointLights[64];

void fragment() {
	vec2 sdfPos = screen_uv_to_sdf(SCREEN_UV);

	float finalPixelAlpha = ambientColour.a;

	// Directional
	//float finalDirLightIntensity = 0.0;
	//if (directionalLightEnabled)
	//{
		//float dirLightAngleRad = directionalLightAngle * (3.1416 / 180.0);
		//vec2 lightDir = vec2(sin(dirLightAngleRad), cos(dirLightAngleRad));
		//
		//vec2 sdfSamplePos = sdfPos;
		//float accumulator = 0.0;
		//while(accumulator < directionalLightMaxDist)
		//{
			//float dist = texture_sdf(sdfSamplePos);
			//accumulator += dist;
			//
			//if (dist < 0.01) { break; }
			//
			//sdfSamplePos += dist * lightDir;
		//}
		//
		//float lightIntensity = 1.0;
		//if (texture_sdf(sdfPos) >= 0.0)
		//{
			//lightIntensity = min(1.0, accumulator/directionalLightMaxDist);
		//}
		//
		//finalDirLightIntensity = lightIntensity;
	//}

	// Point
	float finalPointLightIntensity = 0.0;

	vec2 pixelCoords = sdfPos;
	for (int i = 0; i < pointLights.length(); i++)
	{
		if (pointLights[i].z == -1.0) { break; }

		vec2 pointLightCoords = pointLights[i].xy - camOffset;

		vec2 lightVector = pointLightCoords - pixelCoords;
		vec2 lightDir = normalize(lightVector);
		float lightDist = length(lightVector);

		int samples = 32;
		vec2 sdfSamplePos = sdfPos;
		float accumulator = 0.0;
		float result = 0.0;
		for (int j = 0; j < samples; j++)
		{
			float dist = texture_sdf(sdfSamplePos);
			accumulator += dist;

			if (dist <= 0.0)
			{
				result = 0.0;
				break;
			}

			if (accumulator > lightDist)
			{
				result = 1.0 - (lightDist / pointLights[i].z);
				break;
			}

			sdfSamplePos += dist * lightDir;
		}

		if (lightDist <= pointLights[i].z)
		{
			finalPointLightIntensity += result;
		}
	}

	finalPixelAlpha -= finalPointLightIntensity;

	if (texture_sdf(sdfPos) < 0.0)
	{
		finalPixelAlpha = 0.0;
	}

	COLOR = vec4(ambientColour.xyz, finalPixelAlpha * float(lightingEnabled));

	//float sdfSample = texture_sdf(sdfPos) / 100.0;
	//COLOR += vec4(sdfSample, sdfSample, sdfSample, 0.5);

	//COLOR = vec4(FRAGCOORD.xyz * 0.001, 1);
	//COLOR = vec4(VERTEX, 0.0, 1.0);
}
