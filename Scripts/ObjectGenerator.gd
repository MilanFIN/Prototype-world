extends Node

var staticobj = preload("res://Assets/Objects/StaticObject.tscn")

var valueGenerator
#following x,z in chunk coordinates
var populations = {} #Vector2(x, z): [objects]
#following in actual world coords
var orphans = {} #Vector2(x, z) : object

func _init(values) -> void:
	valueGenerator = values


func populate(x, z, chunkSize, resolution, objectNode):
	randomize()
	var tileSize = float(chunkSize) / resolution 
	var limit = float(chunkSize) / 2 - tileSize/2
	var points = []
	var p = -limit
	while p < limit or abs(limit - p) < 0.0001:
		points.append(p)
		p += tileSize
	
	for i in points:
		for j in points:
			var val = rand_range(0.0,1.0)
			if (val > 0.99):

				var newObj = staticobj.instance()
				newObj.transform.origin = Vector3(x*chunkSize +i, 500, z*chunkSize + j)
				print(newObj.transform.origin)
				objectNode.add_child(newObj)
				newObj.initialized = true





