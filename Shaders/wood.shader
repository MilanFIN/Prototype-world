shader_type spatial;

uniform vec4 color = vec4(0.4, 0.22, 0.05, 1.0);
void vertex() {

	// vec4(0.5, 0.27, 0.08, 1.0);


	COLOR = color;
	
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
