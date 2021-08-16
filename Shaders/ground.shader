shader_type spatial;


uniform float sandLine;// = 2.5;
uniform float grassLine;// = 9.0;
uniform float snowLine;// = 12.0;

void vertex() {


	
	float sandCont = clamp(VERTEX.y - sandLine, 0., 1.);
	float grassCont = clamp(VERTEX.y - grassLine, 0., 1.);
	float snowCont = clamp(VERTEX.y - snowLine, 0., 1.);
	
	vec4 snow = vec4(0.9, 0.9, 0.9, 1.0);
	vec4 stone = vec4(0.2, 0.2, 0.2, 1.0);
	vec4 grass = vec4(0.0, 0.2, 0.0, 1.0);
	vec4 sand = vec4(0.3, 0.3, 0.0, 1.0);

	float pos = VERTEX.y;

	if (pos < sandLine) {
		COLOR = sand;
	}
	if (pos > sandLine && pos < grassLine) {
		COLOR = grass;
	}
	if (pos > grassLine && pos < snowLine) {
		COLOR = stone;
	}
	if (pos > snowLine) {
		COLOR = snow;
	}

	
}


void fragment() {
	//NORMALMAP = texture(normalmap, tex_position).xyz;

	//ALBEDO = vec3(0.0, 0.2, 0.0);
	ALBEDO.r = COLOR.r;
	ALBEDO.g = COLOR.g;
	ALBEDO.b = COLOR.b;

	
	METALLIC = 0.1;
	ROUGHNESS = 0.8;
	
}
