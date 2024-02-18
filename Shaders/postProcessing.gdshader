shader_type canvas_item;
uniform bool saturate;
uniform vec3[3] foregroundColors;
uniform vec3[3] backgroundColors;

void fragment() 
{
	vec3 sample = texture(TEXTURE, UV).rgb;
	if (saturate)
	{
		sample.x = float(sample.x > 0.5);
		sample.y = float(sample.y > 0.5);
		sample.z = float(sample.z > 0.5);
	}
	
	sample = sample.r * foregroundColors[0] + (vec3(1,1,1) - sample.r) * backgroundColors[0] +
				sample.g * foregroundColors[1] + (vec3(1,1,1) - sample.g) * backgroundColors[1]+
				sample.b * foregroundColors[2] + (vec3(1,1,1) - sample.b) * backgroundColors[2];

	COLOR = vec4(sample,1);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
