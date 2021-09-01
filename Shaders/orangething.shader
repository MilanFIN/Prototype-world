shader_type spatial;


void vertex() {


	

	vec4 color = vec4(1.0, 0.2, 0.0, 1.0);

	COLOR = color;
	
}


void fragment() {
	//NORMALMAP = texture(normalmap, tex_position).xyz;

	//ALBEDO = vec3(0.0, 0.2, 0.0);
	ALBEDO.r = COLOR.r;
	ALBEDO.g = COLOR.g;
	ALBEDO.b = COLOR.b;

	
	METALLIC = 0.3;
	ROUGHNESS = 0.5;
	
	
}
