shader_type canvas_item;
uniform bool saturate;
uniform vec3[3] foregroundColors;
uniform vec3[3] backgroundColors;
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void fragment() 
{
	vec3 sample = texture(TEXTURE, UV).rgb;
	if (saturate)
	{	
		sample = rgb2hsv(sample);
		sample.y = 1.0;
		sample.z = 1.0;
		sample = hsv2rgb(sample);	
	}
	
	//sample = sample.r * foregroundColors[0] + (vec3(1,1,1) - sample.r) * backgroundColors[0] +
	//			sample.g * foregroundColors[1] + (vec3(1,1,1) - sample.g) * backgroundColors[1]+
	//			sample.b * foregroundColors[2] + (vec3(1,1,1) - sample.b) * backgroundColors[2];

	COLOR = vec4(sample,1);
}



//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
