shader_type canvas_item;

const uint k = 1103515245U;

vec3 hash( vec3 input )
{
	uvec3 x = floatBitsToUint(input);
    x = ((x>>8U)^x.yzx)*k;
    x = ((x>>8U)^x.yzx)*k;
    x = ((x>>8U)^x.yzx)*k;
    
    return vec3(x)*(1.0/float(0xffffffffU));
}

void fragment() {
	COLOR = vec4(hash(vec3(UV.x, UV.y, TIME)), 1.0);
}

