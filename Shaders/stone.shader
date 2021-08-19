shader_type spatial;


void vertex() {


	

	vec4 stone = vec4(0.2, 0.2, 0.2, 1.0);

	COLOR = stone;
	
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
