extends Node

#terrain related
var noise = OpenSimplexNoise.new()
var noise2 = OpenSimplexNoise.new()
var terrainVariance = 10
var planeVariance = 3

#object related
var objectDensity = OpenSimplexNoise.new()
var objectType = OpenSimplexNoise.new()




const sandLine = 2.5;
const grassLine = 9.0;
const snowLine = 12.0;

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	randomize()
	noise.seed = randi()
	noise.octaves = 8 #4
	noise.lacunarity = 2.0
	noise.period = 256#64.0
	noise.persistence = 0.5#0.5

	noise2.seed = noise.seed +1
	noise2.octaves = 4
	noise2.lacunarity = 2.0
	noise2.period = 2048#256
	noise2.persistence = 0.5
	
	print(noise.seed, ", ", noise2.seed)



func getY(x, z):
	var layer1 = noise.get_noise_2d(x, z) *terrainVariance
	var layer2 = (noise2.get_noise_2d(x, z) +1) * planeVariance
	return layer1*layer2

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
