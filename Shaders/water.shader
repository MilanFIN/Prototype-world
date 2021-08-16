
shader_type spatial;

uniform float frequency = 10;//60
uniform float depth = 0.008;//0.005;
uniform sampler2D noise;
uniform vec2 location;

void fragment() {

	METALLIC = 0.5;
	RIM = 0.05;
	ROUGHNESS = 0.4;
	vec2 uv = SCREEN_UV;
	uv.x += sin(uv.y * frequency + TIME) * depth;
	uv.x = clamp(uv.x, 0.0, 1.0);
	vec3 c = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;

	ALBEDO.rgb = c;
	
	
	ALBEDO.b = 1.;
	ALBEDO.r*=0.5;
	ALBEDO.g*= 0.5;
	
}

float height(vec2 position, float time) {
	//float offset = 0.3 * cos(position.x + position.x*position.y + time);
	//return offset;
	vec2 offset = 0.1 * cos(position + time*0.2);
	return texture(noise, (position / 10.0) - offset).x * 2.;
	
	//float height = texture(noise, position).x;
	//return height*10.;
}


void vertex() {
	vec2 pos = VERTEX.xz + location;
	
	float k = height(pos, TIME);
	VERTEX.y = k;
	//NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME)));
}
