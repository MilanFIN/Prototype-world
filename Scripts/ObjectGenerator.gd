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
	var coordinates = Vector2(x, z)
	if (coordinates in populations):
		return

	var tileSize = float(chunkSize) / resolution 
	var limit = float(chunkSize) / 2 - tileSize/2
	var points = []
	var p = -limit
	while p < limit or abs(limit - p) < 0.0001:
		points.append(p)
		p += tileSize
	
	for i in points:
		for j in points:
			#
			if (rand_range(0,1) < 0.01):
				var newObj = staticobj.instance()
				newObj.transform.origin = Vector3(x*chunkSize +i, 500, z*chunkSize + j)

				objectNode.add_child(newObj)
				newObj.initialized = true

				if (not (coordinates in populations)):
					populations[coordinates] = [newObj]
				else:
					populations[coordinates].push_back(newObj)

	if (len(points) == 0):
		if (not (coordinates in populations)):
			populations[coordinates] = []



