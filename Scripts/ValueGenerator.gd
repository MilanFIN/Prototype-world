extends Node

#size (godot units), of an individual chunk
const chunkSize = 25
#resolution (how many tiles per chunk) of a chunk
const resolution = 5

#how many chunks can be added/populated per frame
#used to limit heavy operations
var calculationLimit = 10


#terrain related
var noise = OpenSimplexNoise.new()
var noise2 = OpenSimplexNoise.new()
var terrainVariance = 10
var planeVariance = 3

#object related
var objectDensity = OpenSimplexNoise.new()
var objectType = OpenSimplexNoise.new()

var objectProbability = 0.15

var drawDistance = 6

const sandLine = 2.5;
const grassLine = 9.0;
const snowLine = 12.0;

#how many milliseconds objects should be kept in memory after a chunk has been deleted
#just in case the player goes back there
var cacheTime = 10*1000

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
	
	#print(noise.seed, ", ", noise2.seed)

	objectDensity.seed = noise.seed +2
	objectDensity.octaves = 1
	objectDensity.period = 1



func getY(x, z):
	var layer1 = noise.get_noise_2d(x, z) *terrainVariance
	var layer2 = (noise2.get_noise_2d(x, z) +1) * planeVariance
	return layer1*layer2

# figures out if a world coordinate (x,z) should have any type of object in it
func hasObject(x, z):

	if ((objectDensity.get_noise_2d(x, z) +1) *0.5 < objectProbability):

		return getInt(x, z, 0, 1)
	return -1

#takes absolute coordinates
func value(x, z, minimum, maximum):
	#TODO: replace initial with procedural function
	var initial = randf()
	var value = (initial - 0) * (maximum-minimum) + minimum
	return value
	
func value2d(x, z, minimum, maximum):
	var first = value(x, z, minimum, maximum)
	var second = value(x, z, minimum, maximum)
	return Vector2(first, second)

#should return a "random" integer including the max limit
func getInt(x, z, minimum, maximum):
	return int(value(x, z, minimum, maximum+1))
