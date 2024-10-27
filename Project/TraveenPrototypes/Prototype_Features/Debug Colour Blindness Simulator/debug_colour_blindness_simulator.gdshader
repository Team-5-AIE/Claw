/* Credits:
Program Inspiration: https://github.com/paulloz/godot-colorblindness
Math: https://ixora.io/projects/colorblindness/color-blindness-simulation-research/
*/ 
/* Notes:
- Matrices used for multiplying with colour are transposed (compared to the sites), 
  so that they can give intended results
*/
shader_type canvas_item;

// 0=None; 1=Protanopia; 2=Deuteranopia; 3=Tritanopia; 4=Blue Monochroma; 5=Red Monochroma
uniform int filter_type: hint_range(0, 5, 1) = 0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// Convert Godot's RGB model to the standard RGB model, then to the LMS model
vec3 rgb_to_lms(vec3 col) {
	// RGB -> sRGB
	if (col.r <= 0.04045) { col.r /= 12.92; } else { col.r = pow((col.r + 0.055) / 1.055, 2.4); }
	if (col.g <= 0.04045) { col.g /= 12.92; } else { col.g = pow((col.g + 0.055) / 1.055, 2.4); }
	if (col.b <= 0.04045) { col.b /= 12.92; } else { col.b = pow((col.b + 0.055) / 1.055, 2.4); }
	
	// sRGB -> LMS
	mat3 transform_matrix = mat3(
		vec3(0.31399022, 0.15537241, 0.01775239),
		vec3(0.63951294, 0.75789446, 0.10944209),
		vec3(0.04649755, 0.08670142, 0.87256922)
	);
	col = transform_matrix * col;
	
	return col;
}

// Convert the LMS model to the standard RGB model, then to Godot's RGB model
vec3 lms_to_rgb(vec3 col) {
	// LMS -> sRGB
	mat3 transform_matrix = mat3(
		vec3( 5.47221206, -1.1252419,   0.02980165),
		vec3(-4.6419601,   2.29317094, -0.19318073),
		vec3( 0.16963708, -0.1678952,   1.16364789)
	);
	col = transform_matrix * col;
	
	// sRGB -> RGB
	if (col.r <= 0.0031308) { col.r *= 12.92; } else { col.r = pow(1.055 * col.r, 0.41666) - 0.055; }
	if (col.g <= 0.0031308) { col.g *= 12.92; } else { col.g = pow(1.055 * col.g, 0.41666) - 0.055; }
	if (col.b <= 0.0031308) { col.b *= 12.92; } else { col.b = pow(1.055 * col.b, 0.41666) - 0.055; }
	
	return col;
}

// Apply a transformation to colour to simulate protanopia
vec3 lms_protanopia(vec3 col) {
	mat3 protanopia_matrix = mat3(
		vec3( 0,           0, 0),
		vec3( 1.05118294,  1, 0),
		vec3(-0.05116099,  0, 1)
	);
	return protanopia_matrix * col;
}

// Apply a transformation to colour to simulate deuteranopia
vec3 lms_deuteranopia(vec3 col) {
	mat3 deuteranopia_matrix = mat3(
		vec3(1, 0.9513092,  0),
		vec3(0, 0,          0),
		vec3(0, 0.04866992, 1)
	);
	return deuteranopia_matrix * col;
}

// Apply a transformation to colour to simulate tritanopia
vec3 lms_tritanopia(vec3 col) {
	mat3 tritanopia_matrix = mat3(
		vec3(1, 0, -0.86744736),
		vec3(0, 1, 1.86727089),
		vec3(0, 0, 0)
	);
	return tritanopia_matrix * col;
}

// Apply a dot product to colour to simulate Blue Monochroma
vec3 lms_blue_monochroma(vec3 col) {
	vec3 blue_monochroma_transform = vec3(0.01775, 0.10945, 0.87262);
	return vec3(dot(col, blue_monochroma_transform));
}

// Apply a dot product to colour to simulate Red Monochroma
vec3 lms_red_monochroma(vec3 col) {
	vec3 red_monochroma_transform = vec3(0.212656, 0.715158, 0.072186);
	return vec3(dot(col, red_monochroma_transform));
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 pixel_colour = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	
	// Convert to LMS colour model before modifying
	pixel_colour = rgb_to_lms(pixel_colour);
	
	// Convert pixel colour to appropriate mode
	vec3 output_colour;
	switch (filter_type)
	{
		case 1: // Protanopia
			output_colour = lms_protanopia(pixel_colour);
			break;
		case 2: // Deuteranopia
			output_colour = lms_deuteranopia(pixel_colour);
			break;
		case 3: // Tritanopia
			output_colour = lms_tritanopia(pixel_colour);
			break;
		case 4: // Blue Monochroma
			output_colour = lms_blue_monochroma(pixel_colour);
			break;
		case 5: // Red Monochroma
			output_colour = lms_red_monochroma(pixel_colour);
			break;
		default: // None
			output_colour = pixel_colour;
			break;
	}
	
	// Convert back to RGB model before applying to pixel
	output_colour = lms_to_rgb(output_colour);
	COLOR.rgb = output_colour;
}
