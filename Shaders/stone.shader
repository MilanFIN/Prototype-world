shader_type spatial;

uniform vec4 color = vec4(0.2, 0.2, 0.2, 1.0);

void vertex() {


	



	COLOR = color;
	
}


void fragment() {

	ALBEDO.r = COLOR.r;
	ALBEDO.g = COLOR.g;
	ALBEDO.b = COLOR.b;

	
	METALLIC = 0.1;
	ROUGHNESS = 0.8;
	
}
