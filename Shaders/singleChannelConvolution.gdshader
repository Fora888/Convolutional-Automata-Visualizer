shader_type canvas_item;

uniform mat3[1] kernels;

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
	float colorTR 	= texture(TEXTURE, fract(vec2(UV.x - pixel_size.x, 	UV.y + pixel_size.y))).r;
	float colorT 	= texture(TEXTURE, fract(vec2(UV.x, 					UV.y + pixel_size.y))).r;
	float colorTL 	= texture(TEXTURE, fract(vec2(UV.x + pixel_size.x, 	UV.y + pixel_size.y))).r;
	float colorMR 	= texture(TEXTURE, fract(vec2(UV.x - pixel_size.x, 	UV.y))).r;
	float colorM 	= texture(TEXTURE, fract(vec2(UV.x, 					UV.y))).r;
	float colorML 	= texture(TEXTURE, fract(vec2(UV.x + pixel_size.x, 	UV.y))).r;
	float colorBR 	= texture(TEXTURE, fract(vec2(UV.x - pixel_size.x, 	UV.y - pixel_size.y))).r;
	float colorB 	= texture(TEXTURE, fract(vec2(UV.x, 					UV.y - pixel_size.y))).r;
	float colorBL 	= texture(TEXTURE, fract(vec2(UV.x + pixel_size.x, 	UV.y - pixel_size.y))).r;
	
	float result = 	kernels[0][0][0] * colorTR	+ kernels[0][0][1] * colorT + kernels[0][0][2] * colorTL + 
				kernels[0][1][0] * colorMR	+ kernels[0][1][1] * colorM + kernels[0][1][2] * colorML +
				kernels[0][2][0] * colorBR	+ kernels[0][2][1] * colorB + kernels[0][2][2] * colorBL;
	

	result = activation(result);
	
	float randomColor = hash(vec3(UV, TIME)).r;
	if((randomColor) == 0.5f)
	{
		result = randomColor;
	}
	
	COLOR = vec4(result, result, result, 1);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
