shader_type canvas_item;

uniform mat3[9] kernels;
uniform mat3 time;

const uint k = 1103515245U;
vec3 hash( vec3 input )
{
	uvec3 x = floatBitsToUint(input);
    x = ((x>>8U)^x.yzx)*k;
    x = ((x>>8U)^x.yzx)*k;
    x = ((x>>8U)^x.yzx)*k;
    
    return vec3(x)*(1.0/float(0xffffffffU));
}

float activation(float x)
{
	return x;
}

void fragment() {
	
	vec2 pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
	vec3 colorTR 	= texture(TEXTURE, fract(vec2(UV.x - pixel_size.x, 	UV.y + pixel_size.y))).rgb;
	vec3 colorT 	= texture(TEXTURE, fract(vec2(UV.x, 					UV.y + pixel_size.y))).rgb;
	vec3 colorTL 	= texture(TEXTURE, fract(vec2(UV.x + pixel_size.x, 	UV.y + pixel_size.y))).rgb;
	vec3 colorMR 	= texture(TEXTURE, fract(vec2(UV.x - pixel_size.x, 	UV.y))).rgb;
	vec3 colorM 	= texture(TEXTURE, fract(vec2(UV.x, 					UV.y))).rgb;
	vec3 colorML 	= texture(TEXTURE, fract(vec2(UV.x + pixel_size.x, 	UV.y))).rgb;
	vec3 colorBR 	= texture(TEXTURE, fract(vec2(UV.x - pixel_size.x, 	UV.y - pixel_size.y))).rgb;
	vec3 colorB 	= texture(TEXTURE, fract(vec2(UV.x, 					UV.y - pixel_size.y))).rgb;
	vec3 colorBL 	= texture(TEXTURE, fract(vec2(UV.x + pixel_size.x, 	UV.y - pixel_size.y))).rgb;
	
	vec3 result;
	result.x = 	dot(kernels[0][0], colorTR)	+ dot(kernels[0][1], colorT) + 	dot(kernels[0][2], colorTL)
			+ 	dot(kernels[1][0], colorMR)	+ dot(kernels[1][1], colorM) + 	dot(kernels[1][2], colorML)
			+ 	dot(kernels[2][0], colorBR)	+ dot(kernels[2][1], colorB) + 	dot(kernels[2][2], colorBL);
	
	result.y = 	dot(kernels[3][0], colorTR)	+ dot(kernels[3][1], colorT) + 	dot(kernels[3][2], colorTL)
			+ 	dot(kernels[4][0], colorMR)	+ dot(kernels[4][1], colorM) + 	dot(kernels[4][2], colorML)
			+ 	dot(kernels[5][0], colorBR)	+ dot(kernels[5][1], colorB) + 	dot(kernels[5][2], colorBL);
			
	result.z = 	dot(kernels[6][0], colorTR)	+ dot(kernels[6][1], colorT) + 	dot(kernels[6][2], colorTL)
			+ 	dot(kernels[7][0], colorMR)	+ dot(kernels[7][1], colorM) + 	dot(kernels[7][2], colorML)
			+ 	dot(kernels[8][0], colorBR)	+ dot(kernels[8][1], colorB) + 	dot(kernels[8][2], colorBL);
	

	result = vec3(activation(result.r), activation(result.g), activation(result.b));
	
	vec3 randomColor = hash(vec3(UV, TIME));
	if((randomColor.x + randomColor.y + randomColor.z) == 1.5f)
	{
		result = randomColor;
	}
	
	COLOR = vec4(result,1);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
