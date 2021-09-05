extends Node

var blob = preload("res://Assets/Objects/DynamicObject.tscn")
var animals = []

var lastUpdateTime
#msec, how often the animal statuses are checked
const UPDATEINTERVAL = 2000
#how far animals can go until they are removed
const DRAWDISTANCE = 300
const ANIMALLIMIT = 30
const SPAWNRADIUS = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lastUpdateTime = OS.get_ticks_msec()


func check(pos, force=false):
	if (OS.get_ticks_msec() > lastUpdateTime + UPDATEINTERVAL):
		lastUpdateTime = OS.get_ticks_msec()
		for i in range(len(animals)-1, -1, -1):
			var animal = animals[i]
			var animPos = animal.global_transform.origin
			if (abs(animPos.x - pos.x) > DRAWDISTANCE or abs(animPos.z - pos.z) > DRAWDISTANCE):
				animal.queue_free()
				animals.remove(i)
			if (animal.dead):
				animal.queue_free()
				animals.remove(i)

		for i in range(3):
			if (len(animals) >= ANIMALLIMIT):
				break
			var xPos = (randi()%SPAWNRADIUS+2) - SPAWNRADIUS/2 + pos.x
			var zPos = (randi()%SPAWNRADIUS+2) - SPAWNRADIUS/2 + pos.z
			var newAnim = blob.instance()
			newAnim.global_transform.origin = Vector3(xPos,20,zPos)
			add_child(newAnim)
			animals.push_back(newAnim)
			newAnim.initialized = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
