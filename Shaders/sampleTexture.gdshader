shader_type canvas_item;

void fragment() 
{
	vec3 sample = texture(TEXTURE, UV).rgb;
	COLOR = vec4(sample,1);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
