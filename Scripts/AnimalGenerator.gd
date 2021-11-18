extends Node

var turtle = preload("res://Assets/Enemies/BoxThing.tscn")
var zombie = preload("res://Assets/Enemies/Zombie.tscn")
var squirrel = preload("res://Assets/Enemies/Squirrel.tscn")
var troll = preload("res://Assets/Enemies/Troll.tscn")
var cow = preload("res://Assets/Enemies/Cow.tscn")
var blurb = preload("res://Assets/Enemies/Blurb.tscn")
var animals = []

var lastUpdateTime
#msec, how often the animal statuses are checked
const UPDATEINTERVAL = 2000
#how far animals can go until they are removed
const DRAWDISTANCE = 300
const ANIMALLIMIT = 10
const SPAWNRADIUS = 200



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lastUpdateTime = OS.get_ticks_msec()

func pickAnimal(day):
	var choise = randi()%2+1 #int between 1 and 2
	if (choise == 1):
		return blurb.instance()
	else:
		return cow.instance()

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
			if (abs(animPos.x - pos.x) > DRAWDISTANCE or abs(animPos.z - pos.z) > DRAWDISTANCE):
				animal.queue_free()
				animals.remove(i)
			if (animal.remove):
				animal.queue_free()
				animals.remove(i)
		if (day):
			for i in range(20):
				if (len(animals) >= ANIMALLIMIT):
					break
				var xPos = (randi()%SPAWNRADIUS+2) - SPAWNRADIUS/2 + pos.x
				var zPos = (randi()%SPAWNRADIUS+2) - SPAWNRADIUS/2 + pos.z
				var newAnim = pickAnimal(day)
				newAnim.global_transform.origin = Vector3(xPos,20,zPos)
				add_child(newAnim)
				animals.push_back(newAnim)
				newAnim.initialized = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
