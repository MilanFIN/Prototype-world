extends Node

var tree = preload("res://Assets/Objects/Tree.tscn") 
var rock = preload("res://Assets/Objects/Rock.tscn") 


const GENSPERFRAME = 3
#shaders
var stoneShader# = preload("res://Shaders/stone.shader")
var woodShader# = preload("res://Shaders/wood.shader")
var leafShader# = preload("res://Shaders/leaf.shader")
var woodMaterial
var leafMaterial
var stoneMaterial

var initialized = false


var valueGenerator
var objectNode
#following x,z in chunk coordinates
var populations = {} #Vector2(x, z): [objects]
#following in actual world coords
var orphans = {} #Vector2(x, z) : [time, [objects]]

#protecting thread inputs&outputs
var semaphore
var mutex
var threads = []


var exit_thread = false
#of structure: [x, z, chunkSize, resolution]
var threadInputs = []
#of structure: (Vector2(x, z),  Objects)
# x, z is chunk coordinates (NOT world)
var threadOutputs = []


var chunkSize
var resolution

var lastCacheTime = OS.get_ticks_msec()

var SURFACETOOL = SurfaceTool.new()

var treeMeshes = []
var rockMeshes = []

var test = 0

func _init( objnode) -> void:

	initialized = true
	
	
	valueGenerator = Global.valueGenerator
	
	semaphore = Semaphore.new()
	mutex = Mutex.new()
	exit_thread = false
	"""UNCOMMENT FOR THREADING"""
	"""
	for i in range(0,1):
		var thread = Thread.new()
		thread.start(self, "_objectWorker")
		threads.push_back(thread)
	"""
	objectNode = objnode
	chunkSize = valueGenerator.chunkSize
	resolution = valueGenerator.resolution

	for i in range(10):
		for j in range(10):
			treeMeshes.push_back(makeTree(i, j))
	for i in range(10):
		for j in range(10):
			rockMeshes.push_back(makeRock(i, j))
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

func test():
	print(test)
	test += 1

func makeMeshes():

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
	
	var res = []
	
	for i in points:
		for j in points:

			var objType = valueGenerator.hasObject(x * chunkSize + i, z* chunkSize + j)

			if (objType != -1):#-1):

				var result
				var meshNumber = int(valueGenerator.value(x * chunkSize + i, 
										z* chunkSize + j, 0, 99))
				
				if (objType == 0):
					result = rockMeshes[meshNumber]#[[resMesh, "rock"]]
					res.push_back([i, j, "rock", result])
				elif (objType == 1): # == 1
					result = treeMeshes[meshNumber]#[[resMesh, "rock"]]
					res.push_back([i, j, "tree", result])





	if (len(res) != 0):
		output = [coordinates,res]

	mutex.lock()
	threadOutputs.push_back(output)
	mutex.unlock()



func process(delta = 0) -> void:

	#print(len(objectNode.get_children()))

	"""REMOVE FOR THREADING"""
	"""
	var r = len(threadInputs)
	r = clamp(r, 0, GENSPERFRAME)
	for i in range(r):
		_objectWorker(null)
	#if (len(threadInputs) !=0):
	#	_objectWorker(null)

	"""

	while (len(threadInputs) != 0):
		makeMeshes()

	
	mutex.lock()
	var calculations = 0

	while (len(threadOutputs) != 0):

		var out = threadOutputs.pop_back()


		var coordinates = out[0]

		var data = out[1]



		for objData in data:

			var x = objData[0]
			var z = objData[1]
			var type = objData[2]
			var meshList = objData[3]
			#var material = objData[3][1]



#			if (not (coordinates in populations)):

			
			var newObj
			if (type == "tree"):
				newObj = tree.instance()
			elif (type == "rock"):
				newObj = rock.instance()


			newObj.transform.origin = Vector3(coordinates.x*chunkSize + x, 500, coordinates.y*chunkSize + z)

			objectNode.add_child(newObj)
			newObj.setType(type)
			var rot = valueGenerator.value(coordinates.x*chunkSize + x, coordinates.y*chunkSize + z, 0, 360, 10)
			for i in meshList:
				
				newObj.addMesh(i[0], i[1])

			for i in newObj.get_children():
				i.rotation_degrees.y = rot
			#newObj.rotation_degrees.y = rot
			
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
	"""MAKE A LOOP FOR THREADING"""
	"""
	while true:
		semaphore.wait() # Wait until posted.
		mutex.lock()
		var should_exit = exit_thread
		mutex.unlock()
		if should_exit:
			break
"""
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
	
	var res = []
	
	for i in points:
		for j in points:
			var objType = valueGenerator.hasObject(x * chunkSize + i, z* chunkSize + j)
			if (objType != -1):

				var result
				if (objType == 0):
					result = makeRock(i, j)

					res.push_back([i, j, "rock", result])
				elif (objType == 1):
					result = makeTree(i, j)#makeTree(i, j)
					
					res.push_back([i, j, "tree", result])

	#TODO: FIGURE OUT WHY THIS BREAKS???
	if (len(res) != 0):
		output = [coordinates,res]

	mutex.lock()
	threadOutputs.push_back(output)
	mutex.unlock()


#location = vector3
func makeLeaf(location):
	var st = SURFACETOOL#SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var radius = valueGenerator.value(location.x, location.z, 1, 5)
	var top = location
	top.y += radius / 1.5
	
	var index = 0#1
	var upperRingVector = Vector3(radius, 0, 0)
	
	st.add_vertex(top)

	var upperRing = []
	for i in range(6):
		upperRing.push_back(location + upperRingVector.rotated(Vector3.UP, deg2rad(60*i)))
	for i in range(6):
		index += 2
		var first = upperRing[i]
		var second
		if (i < 5):
			second = upperRing[i+1]
		else:
			second = upperRing[0]
		#set vertices to make first triangle
		st.add_vertex(first)
		st.add_vertex(second)
		#create topmost triangle
		st.add_index(0);
		st.add_index(index);
		st.add_index(index-1);
	
	var bottom = location
	bottom.y -= radius / 1.5
	st.add_vertex(bottom)
	index += 1
	var bottomIndex = index


	var lowerRingVector = upperRingVector
	var lowerRing = []
	for i in range(6):
		lowerRing.push_back(location + lowerRingVector.rotated(Vector3.UP, deg2rad(60*i)))
	for i in range(6):
		index += 2
		var first = lowerRing[i]
		var second
		if (i < 5):
			second = lowerRing[i+1]
		else:
			second = lowerRing[0]
		#set vertices to make first triangle
		st.add_vertex(first)
		st.add_vertex(second)
		#create topmost triangle
		st.add_index(bottomIndex);
		st.add_index(index-1);
		st.add_index(index);
	
	st.generate_normals()
	var mesh = st.commit()

	st.clear()
	return [mesh, "leaf"]

func makeTree(x, z):

	var st = SURFACETOOL#SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height = valueGenerator.value(x, z,5,20, 1)
	
	var topxz = Vector2(0,0)#valueGenerator.value2d(0,0,-1,1)
	
	var top = Vector3(topxz.x, height, topxz.y)

	var base = []
	var radius = valueGenerator.value(x, z,0.5,1, 2)
	for i in range(3):
		base.push_back(Vector3(radius, 0, 0).rotated(Vector3.UP, deg2rad(120.0*i)))
		
		
	var index = 0#1
	st.add_vertex(top)
	index += 1
	for i in range(3):
		index += 2
		var first = base[i]
		var second
		if (i < 2):
			second = base[i+1]
		else:
			second = base[0]
		
		#set vertices to make first triangle
		st.add_vertex(first)
		st.add_vertex(second)
		#create topmost triangle
		st.add_index(0);
		st.add_index(index-1);
		st.add_index(index-2);




	var branchCount = valueGenerator.getInt(x, z,1,5, 5)
	var branchTips = [top]
	
	for i in range(branchCount):

		var branchIndex = index
		var start = valueGenerator.value(x, z,height*0.25, height*0.9, i+2)
		var end = valueGenerator.value2d(x, z,-3,3, i+4)
		var endHeight = valueGenerator.value(x, z,start, height+2, i+6)
		var branchRadius = 0.3

		var branchTop = Vector3(end.x, endHeight, end.y)
		branchTips.append(branchTop)
		st.add_vertex(branchTop)
		index += 1
		var branchBase = []
		for j in range(3):
			branchBase.push_back(Vector3(branchRadius, start, 0).rotated(Vector3.UP, deg2rad(120.0*j)))



		for j in range(3):
			index += 2
			var first = branchBase[j]
			var second
			if (j < 2):
				second = branchBase[j+1]
			else:
				second = branchBase[0]

		
			st.add_vertex(first)
			st.add_vertex(second)
			
			st.add_index(branchIndex);
			st.add_index(index-1);
			st.add_index(index-2);


	st.generate_normals()
	var trunkMesh = st.commit()

	
	st.clear()
	
	var leaves = []
	for i in branchTips:
		var leaf = makeLeaf(i)

		leaves.append(leaf)

	#print(len([trunkMesh, woodMaterial] + leaves))
	var result = []
	result.push_back([trunkMesh, "wood"])
	for i in leaves:
		result.push_back(i)
		pass
		


	return result#CubeMesh.new()


func makeRock(x, z):

	var st = SURFACETOOL#SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var innerRadius = valueGenerator.value(x, z,1,3)
	var outerRadius = valueGenerator.value(x, z,innerRadius*0.8 ,innerRadius*1.2)
	
	var height = outerRadius#valueGenerator.value(1,1,1,3)

	var topxz = valueGenerator.value2d(x, z,-1,1)
	var top = Vector3(topxz.x, height, topxz.y)
	st.add_vertex(top)


	var lowerPoint = Vector3(innerRadius, height/1.3, 0)
	
	var index = 1

	#generate the 3 points that make up the first 3 triangels under the top

	#calculating the two points that will be the base of the triangle
	var points = []
	for i in range(3):
		
		var point = lowerPoint.rotated(Vector3.UP, deg2rad(120.0*i))
		point.x += top.x
		point.z += top.z

		point += valueGenerator.value3d(x, z,-0.5, 0.5, i)


		points.push_back(point)


	
	for i in range(3):

		var first = points[i]
		var second
		if (i < 2):
			second = points[i+1]
		else:
			second = points[0]
		st.add_vertex(first)
		st.add_vertex(second)

		st.add_index(0);
		st.add_index(index+1);
		st.add_index(index);
		#create 3 triangles under that to make a wider base 
		#aka finishing a triforce for one side
		#first must calculate the vertexes that make up the base (in 2d space)

		var bottomXz = Vector2(top.x, top.z)


		var lowFirstXz = Vector2(first.x, first.z)
		lowFirstXz += (lowFirstXz - bottomXz).normalized()* (outerRadius-innerRadius)
		var lowFirst = Vector3(lowFirstXz.x, top.y-height, lowFirstXz.y)



		var lowSecondXz = Vector2(second.x, second.z)
		lowSecondXz += (lowSecondXz - bottomXz).normalized()* (outerRadius-innerRadius)
		var lowSecond = Vector3(lowSecondXz.x, top.y-height, lowSecondXz.y)
		
		var bottom = top
		bottom.y = top.y-height
		var lowCenter = ((lowFirst + lowSecond) / 2) 
		var lowDir = lowCenter - bottom
		lowCenter += lowDir.normalized() * (outerRadius - lowDir.length())

		var lowCenterOffset = valueGenerator.value2d(x, z,-0.5, 0.5, i*3)
		lowCenter.x += lowCenterOffset.x
		lowCenter.z += lowCenterOffset.y
		#lowCenter += (lowCenter - lowTop) * 0.5

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
	#var mesh = Mesh.new()#null
	st.clear()

	return [[mesh, "rock"]]#CubeMesh.new()


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


