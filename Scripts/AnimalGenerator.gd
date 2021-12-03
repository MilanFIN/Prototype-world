extends Node

var turtle = preload("res://Assets/Enemies/Turtle.tscn")
var zombie = preload("res://Assets/Enemies/Zombie.tscn")
var squirrel = preload("res://Assets/Enemies/Squirrel.tscn")
var troll = preload("res://Assets/Enemies/Troll.tscn")
var cow = preload("res://Assets/Enemies/Cow.tscn")
var blurb = preload("res://Assets/Enemies/Blurb.tscn")
var fish = preload("res://Assets/Enemies/Fish.tscn")


#enemies
var enemies = [troll, blurb]
var nocturnal = [zombie]
var mobs = enemies + nocturnal
var underwater = [fish]
#friendlies
var friendlies = [turtle, squirrel, cow]


var animals = []

var lastUpdateTime
#msec, how often the animal statuses are checked
const UPDATEINTERVAL = 2000
#how far animals can go until they are removed
const DRAWDISTANCE = 150
const ANIMALLIMIT = 10
const SPAWNRADIUS = 100



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lastUpdateTime = OS.get_ticks_msec()

func pickAnimal(day, water):

	if (water):
		return underwater[0].instance()
	elif day:
		var index  = randi()%(len(friendlies))+0
		return friendlies[index].instance()
	else:
		var index  = randi()%(len(mobs))+0
		return mobs[index].instance()
func check(delta, pos, day):

	#uncomment to disable
	#return

	if (day):
		for animal in animals:
			if (animal.nocturnal):
				animal.damage(delta*5, Vector3.ZERO, true)

	
	if (OS.get_ticks_msec() > lastUpdateTime + UPDATEINTERVAL):
		lastUpdateTime = OS.get_ticks_msec()
		for i in range(len(animals)-1, -1, -1):
			var animal = animals[i]
			var animPos = animal.global_transform.origin
			if ((animPos- pos).length() > DRAWDISTANCE ):
				animal.queue_free()
				animals.remove(i)
			if (animal.remove):
				animal.queue_free()
				animals.remove(i)

		for i in range(20):
			if (len(animals) >= ANIMALLIMIT):
				break
			var xPos = rand_range(- SPAWNRADIUS, SPAWNRADIUS) + pos.x
			var zPos = rand_range(- SPAWNRADIUS, SPAWNRADIUS) + pos.z
			
			var y = Global.valueGenerator.getY(xPos, zPos)
			var water = false
			if y < 0:
				water = true
			var newAnim = pickAnimal(day, water)
			newAnim.global_transform.origin = Vector3(xPos,20,zPos)
			add_child(newAnim)
			animals.push_back(newAnim)
			newAnim.initialized = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
