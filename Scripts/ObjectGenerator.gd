extends Node

var staticobj = preload("res://Assets/Objects/StaticObject.tscn")
var stoneShader = preload("res://Shaders/stone.shader")

var valueGenerator
var objectNode
#following x,z in chunk coordinates
var populations = {} #Vector2(x, z): [objects]
#following in actual world coords
var orphans = {} #Vector2(x, z) : [time, [objects]]

var semaphore
var mutex
var threads = []
#var thread
var exit_thread = false
#of structure: [x, z, chunkSize, resolution]
var threadInputs = []
var threadOutputs = []

var chunkSize
var resolution

var lastCacheTime = OS.get_ticks_msec()

func _init(values, objnode) -> void:
	

	valueGenerator = values
	
	semaphore = Semaphore.new()
	mutex = Mutex.new()
	exit_thread = false

	for i in range(0,1):
		var thread = Thread.new()
		thread.start(self, "_objectWorker")
		threads.push_back(thread)

	objectNode = objnode
	chunkSize = valueGenerator.chunkSize
	resolution = valueGenerator.resolution

func populate(x, z):
	var coordinates = Vector2(x, z)
	if (coordinates in populations):
		return
	

	if (coordinates in orphans):
		#should simply add the previously orphaned nodes back in
		addOrphans(x, z)
	else:
		mutex.lock()
		threadInputs.push_back([x, z])
		mutex.unlock()
		semaphore.post()


func addOrphans(x, z):
	var coordinates = Vector2(x, z) 
	if (coordinates in orphans):

		populations[coordinates] = orphans[coordinates][1]
		orphans.erase(coordinates)
		for i in populations[coordinates]:
			objectNode.add_child(i)


func remove(x, z):
	
	var keys = populations.keys()

	for i in keys:

		var xDist = abs(i.x - x)
		var zDist = abs(i.y - z)

		#if (sqrt(xDist*xDist + zDist*zDist) > removalDistance):
		if (xDist > valueGenerator.drawDistance or zDist > valueGenerator.drawDistance):

			#get_node("MeshMatrix").remove_child(chunks[i])
			orphans[i] = [OS.get_ticks_msec(), populations[i]]


			populations.erase(i)

			for j in orphans[i][1]:
				objectNode.remove_child(j)



func process(delta = 0) -> void:
	


	
	mutex.lock()
	var calculations = 0
	while (len(threadOutputs) != 0):

		var out = threadOutputs.pop_front()

		var coordinates = out[0]
		var data = out[1]

		for objData in data:
			var x = objData[0]
			var z = objData[1]
			var type = objData[2]
			var mesh = objData[3][0]
			var material = objData[3][1]

			if (not (coordinates in populations)):

				var newObj = staticobj.instance()
				newObj.get_node("MeshInstance").mesh = mesh
				newObj.get_node("MeshInstance").set_surface_material(0, material)
				newObj.get_node("MeshInstance").create_trimesh_collision()
				newObj.transform.origin = Vector3(coordinates.x*chunkSize + x, 500, coordinates.y*chunkSize + z)

				objectNode.add_child(newObj)
				newObj.initialized = true



				if (not (coordinates in populations)):
					populations[coordinates] = [newObj]
				else:
					populations[coordinates].push_back(newObj)
				
		calculations += 1
		if (calculations > valueGenerator.calculationLimit):
			break
	mutex.unlock()




	var currentTime = OS.get_ticks_msec()
	if (currentTime - lastCacheTime > valueGenerator.cacheTime):

		var keys = orphans.keys()
		for i in keys:
			if (orphans[i][0] < currentTime - valueGenerator.cacheTime):
				for j in orphans[i][1]:
					j.queue_free()
				orphans.erase(i)
		lastCacheTime = currentTime
		



#handles entire chunks at a time
func _objectWorker(userdata):
	while true:
		semaphore.wait() # Wait until posted.
		mutex.lock()
		var should_exit = exit_thread
		mutex.unlock()
		if should_exit:
			break

		mutex.lock()
		var inputs = threadInputs.pop_front()
		mutex.unlock()

		
		
		var x = inputs[0]
		var z = inputs[1]

		var coordinates = Vector2(x, z)
		
			
		var tileSize = float(chunkSize) / resolution 
		var limit = float(chunkSize) / 2 - tileSize/2
		var points = []
		var p = -limit
		while p < limit or abs(limit - p) < 0.0001:
			points.append(p)
			p += tileSize
		
		var output = [coordinates,[]]
		
		for i in points:
			for j in points:

				if (valueGenerator.hasObject(x * chunkSize + i, z* chunkSize + j)):
					
					var result = makeRock() #CubeMesh.new()
					#

					output[1].push_back([i, j, "Mesh", result])



			#if (not (coordinates in populations)):
			#	populations[coordinates] = []

			mutex.lock()

			threadOutputs.push_back(output)
			mutex.unlock()


func makeRock():
	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var innerRadius = valueGenerator.value(1,1,1,3)
	var outerRadius = valueGenerator.value(1,1,0.5*innerRadius,1.5*innerRadius)
	var height = valueGenerator.value(1,1,1,3)

	var top = Vector3(0, height, 0)
	st.add_vertex(top)

	var lowerPoint = Vector3(innerRadius, height/2, 0)
	var index = 1


	for i in range(3):

		#calculating the two points that will be the base of the triangle
		var first = lowerPoint.rotated(Vector3.UP, deg2rad(120.0*i))

		var second = lowerPoint.rotated(Vector3.UP, deg2rad(120.0*(i+1)))

		#set vertices to make first triangle
		st.add_vertex(first)
		st.add_vertex(second)
		#create topmost triangle
		st.add_index(0);
		st.add_index(index+1);
		st.add_index(index);

		#create 3 triangles under that to make a wider base 
		#aka finishing a triforce for one side
		#first must calculate the vertexes that make up the base (in 2d space)
		var lowFirst = Vector2(first.x, first.z).normalized() * outerRadius
		var lowSecond = Vector2(second.x, second.z).normalized() * outerRadius
		var lowCenter = (lowFirst+lowSecond).normalized() * outerRadius
		
		#converting to 3d space
		lowFirst = Vector3(lowFirst.x, -1, lowFirst.y)
		lowSecond = Vector3(lowSecond.x, -1, lowSecond.y)
		lowCenter = Vector3(lowCenter.x, -1, lowCenter.y)

		st.add_vertex(lowFirst)
		st.add_vertex(lowCenter)
		st.add_vertex(lowSecond)

		#leftmost triangle
		st.add_index(index);
		st.add_index(index+3);
		st.add_index(index+2);
		
		#center (inverted)
		st.add_index(index);
		st.add_index(index+1);
		st.add_index(index+3);

		#right triangle
		st.add_index(index+1);
		st.add_index(index+4);
		st.add_index(index+3);

		#increment index, as each side of the "pyramid" has 5 vertices
		# in addition to the top, which is shared
		index += 5


	st.generate_normals()
	var mesh = st.commit()
	
	var material = ShaderMaterial.new()
	material.shader = stoneShader

	

	return [mesh, material]#CubeMesh.new()


# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	# Set exit condition to true.
	mutex.lock()
	exit_thread = true # Protect with Mutex.
	threadInputs = []
	mutex.unlock()
	# Wait until it exits.
	for thread in threads:
		semaphore.post()
		thread.wait_to_finish()


