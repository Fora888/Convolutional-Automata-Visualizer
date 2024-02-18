shader_type canvas_item;

uniform mat3[3] kernels;
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
	
	vec3 result = 	kernels[0][0] * colorTR	+ kernels[0][1] * colorT + kernels[0][2] * colorTL + 
				kernels[1][0] * colorMR	+ kernels[1][1] * colorM + kernels[1][2] * colorML +
				kernels[2][0] * colorBR	+ kernels[2][1] * colorB + kernels[2][2] * colorBL;
	

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
