shader_type spatial;


uniform float sandLine;// = 2.5;
uniform float grassLine;// = 9.0;
uniform float snowLine;// = 12.0;


void vertex() {

	vec4 snow = vec4(0.9, 0.9, 0.9, 1.0);
	vec4 stone = vec4(0.2, 0.2, 0.2, 1.0);
	vec4 grass = vec4(0.0, 0.2, 0.0, 1.0);
	vec4 sand = vec4(0.3, 0.3, 0.0, 1.0);

	float pos = VERTEX.y;

	vec3 normal = NORMAL;
	vec3 up = vec3(0., 1., 0.);
	
	float angle = acos(dot(normal, up)) * 180./3.14;
	
	if (UV.x == 0.) {
		
		COLOR = sand;
	}
	else {
		if (angle > 35.) {
			COLOR = stone;
		}
		else {
			COLOR = grass;
		}
	}

	
}


void fragment() {
	//NORMALMAP = texture(normalmap, tex_position).xyz;

	//ALBEDO = vec3(0.0, 0.2, 0.0);
	ALBEDO.r = COLOR.r;
	ALBEDO.g = COLOR.g;
	ALBEDO.b = COLOR.b;

	
	METALLIC = 0.0;
	ROUGHNESS = 0.8;
	

}
