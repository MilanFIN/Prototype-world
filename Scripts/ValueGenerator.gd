extends Node

#size (godot units), of an individual chunk
const chunkSize = 25#25
#resolution (how many tiles per chunk) of a chunk
const resolution = 5#5

#how many chunks can be added/populated per frame
#used to limit heavy operations
var calculationLimit = 10


#terrain related
var noise = OpenSimplexNoise.new()
var noise2 = OpenSimplexNoise.new()
var terrainVariance = 70
var planeVariance = 0.5

#object related
var objectDensity = OpenSimplexNoise.new()
var objectType = OpenSimplexNoise.new()

var objectProbability = 0.3#0.15

var drawDistance = 6

const sandLine = 2.5;

const grassLine = 9.0;
const snowLine = 12.0;



#how many milliseconds objects should be kept in memory after a chunk has been deleted
#just in case the player goes back there
var cacheTime = 180*1000

var SEED = 1
# Called when the node enters the scene tree for the first time.
func _init() -> void:
	randomize()
	
	SEED = randi()

	
	noise.seed = SEED
	noise.octaves = 3 #4
	noise.lacunarity = 2.0
	noise.period = 96#64.0
	noise.persistence = 0.5#0.5

	noise2.seed = noise.seed +1
	noise2.octaves = 1
	noise2.lacunarity = 2.0
	noise2.period = 256#2048
	noise2.persistence = 0.5
	
	#print(noise.seed, ", ", noise2.seed)

	objectDensity.seed = noise.seed +2
	objectDensity.octaves = 1
	objectDensity.period = 1



#returns height of a point on the map
func getY(x, z):
	var layer1 = noise.get_noise_2d(x, z) *terrainVariance
	var layer2 = (noise2.get_noise_2d(x, z) +1) * planeVariance
	return layer2 * layer1


# figures out if a world coordinate (x,z) should have any type of object in it
# return: -1 for no object, 0-x for obj type
# note: static only, increase getint parameter when more items are added
func hasObject(x, z):

	if (getY(x, z) < 0):
		return -1
	if ((objectDensity.get_noise_2d(x, z) +1) *0.5 < objectProbability):
		return getInt(x, z, 0, 1)
	return -1

# parameters: (x, z) world coordinates
# min & max = value range
# optional: modifier to get multiple results for same coordinates
# returns a value between min & max based on x&z&optional & seed
# return values are float
func value(x, z, minimum, maximum, optional=1):
	
	x = int(1000*x)
	z = int(1000*z)
	optional = int(1000*optional)
	var initial = (561307 * x + 593291 * z + optional*625087) ^ SEED #
	initial = abs(initial)
	initial = float("0."+str(initial))
	var value = (initial - 0) * (maximum-minimum) + minimum

	return value


# parameters: same as value()
# return: 2 values, similar to value, but they are different
# return values are float
func value2d(x, z, minimum, maximum, optional = 1):
	var first = value(x, z, minimum, maximum, optional)
	var second = value(x, z, minimum, maximum, optional << 2)
	return Vector2(first, second)

func value3d(x, z, minimum, maximum, optional = 1):
	var first = value(x, z, minimum, maximum, optional)
	var second = value(x, z, minimum, maximum, optional << 2)
	var third = value(x, z, minimum, maximum, optional << 4)
	return Vector3(first, second, third)

# parameters: same as value()
# returns a pseudorandom integer between range min&max
func getInt(x, z, minimum, maximum, optional = 1):
	return int(value(x, z, minimum, maximum+1, optional))
