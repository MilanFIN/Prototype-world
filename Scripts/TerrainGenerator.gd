extends Spatial

var valueGenerator = preload("res://Scripts/ValueGenerator.gd").new()
var objectGenerator


onready var groundShader = preload("res://Shaders/ground.shader")
var groundMaterial = ShaderMaterial.new()

onready var waterShader = preload("res://Shaders/water.shader")


var chunkSize = 25
var resolution = 5#0.2

var drawDistance = 6


var xz = Vector3(0,0,0)

var chunks = {} #x, z: mesh

var waterNoise = NoiseTexture.new()

var semaphore
var mutex
var threads = []
#var thread
var exit_thread = false
var threadInputs = []
var threadOutputs = []


func _ready():

	objectGenerator = preload("res://Scripts/ObjectGenerator.gd").new(valueGenerator, get_node("Objects"))



	semaphore = Semaphore.new()
	mutex = Mutex.new()
	exit_thread = false

	groundMaterial.shader = groundShader
	groundMaterial.set_shader_param("sandLine", valueGenerator.sandLine)
	groundMaterial.set_shader_param("grassLine", valueGenerator.grassLine)
	groundMaterial.set_shader_param("snowLine", valueGenerator.snowLine)
	waterNoise.width = 64
	waterNoise.noise = OpenSimplexNoise.new()

	for i in range(0,1):
		var thread = Thread.new()
		thread.start(self, "_terrainWorker")
		threads.push_back(thread)

	generate(0,0)

func check(playerPosition):

	var chunkPosition = (playerPosition / chunkSize).round()


	if (xz.x != chunkPosition.x or xz.z != chunkPosition.z):
		generate(chunkPosition.x, chunkPosition.z)
		
		remove(chunkPosition.x, chunkPosition.z)
		xz = chunkPosition
	

func remove(x, z):
	
	var keys = chunks.keys()
	for i in keys:
		var xDist = abs(i.x - x)
		var zDist = abs(i.y - z)
		

		#if (sqrt(xDist*xDist + zDist*zDist) > removalDistance):
		if (xDist > drawDistance or zDist > drawDistance):
			#get_node("MeshMatrix").remove_child(chunks[i])
			chunks[i].queue_free()
			chunks.erase(i)



func makeWater(x, z):
	var flip = [false, true]
	var waterMeshes = []
	for f in flip:
		

		
		var waterPlane = PlaneMesh.new()
		waterPlane.size = Vector2(chunkSize, chunkSize)
		waterPlane.flip_faces = f
		
		var planeMesh = PlaneMesh.new()
		planeMesh.subdivide_depth = chunkSize * resolution
		planeMesh.subdivide_width = chunkSize * resolution
		
		var surfaceTool = SurfaceTool.new()
		
		surfaceTool.create_from(waterPlane, 0)
		
		surfaceTool.generate_normals()
		
		var arrayPlane = surfaceTool.commit()
		
		#var dataTool = MeshDataTool.new()
		#var error = dataTool.create_from_surface(arrayPlane, 0)
		
		


		var mesh = surfaceTool.commit()
		
		waterMeshes.push_back(mesh)



	return waterMeshes
	


func makeChunk(x, z):

	
	"""
	var planeMesh = PlaneMesh.new()
	
	planeMesh.size = Vector2(chunkSize, chunkSize)
	planeMesh.subdivide_depth = chunkSize * resolution
	planeMesh.subdivide_width = chunkSize * resolution
	
	var surfaceTool = SurfaceTool.new()

	surfaceTool.create_from(planeMesh, 0)
	var arrayPlane = surfaceTool.commit()
	

	var dataTool = MeshDataTool.new()

	var error = dataTool.create_from_surface(arrayPlane, 0)#arrayPlane
	
	for i in range(dataTool.get_vertex_count()):
		var vertex = dataTool.get_vertex(i)
		vertex.y = getY(vertex.x + x*chunkSize, vertex.z + z*chunkSize)
		dataTool.set_vertex(i, vertex)

	for s in range(arrayPlane.get_surface_count()):
		arrayPlane.surface_remove(s)
	
	#var arrayPlane
	dataTool.commit_to_surface(arrayPlane)
	#surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surfaceTool.create_from(arrayPlane, 0)



	surfaceTool.generate_normals()


	var surfaceMesh = MeshInstance.new()

	var mesh = surfaceTool.commit()

	"""
	

	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var tileSize = float(chunkSize) / resolution 

	var index = 0
	var limit = float(chunkSize) / 2 - tileSize/2
	var points = []
	var p = -limit
	while p < limit or abs(limit - p) < 0.0001:
		points.append(p)
		p += tileSize

	for i in points:#range(-limit, limit+1, tileSize):
		for j in points:#range(-limit, limit+1, tileSize):

			var X = tileSize / 2
			var Z = tileSize / 2


			var y1 = valueGenerator.getY(x*chunkSize + i -X, z*chunkSize + j +Z)
			var y2 = valueGenerator.getY(x*chunkSize + i -X, z*chunkSize + j -Z)
			var y3 = valueGenerator.getY(x*chunkSize + i +X, z*chunkSize + j -Z)
			var y4 = valueGenerator.getY(x*chunkSize + i +X, z*chunkSize + j +Z)



			st.add_vertex(Vector3(i-X, y1, j+Z))
			st.add_vertex(Vector3(i-X, y2, j-Z))
			st.add_vertex(Vector3(i+X, y3, j-Z))
			st.add_vertex(Vector3(i+X, y4, j+Z))


			st.add_index(index + 0);
			st.add_index(index + 1);
			st.add_index(index + 2);
			
			st.add_index(index + 3);
			st.add_index(index + 0);
			st.add_index(index + 2);
			
			index += 4

	st.generate_normals()


	var mesh = st.commit()

	
	var waterMeshes = makeWater(x, z)
	
	return [mesh, waterMeshes]





func generate(x, z):

	
	xz = Vector3(x, 0, z)
	#make terrain
	mutex.lock()
	for i in range(x-drawDistance, x+drawDistance+1):
		for j in range(z-drawDistance, z+drawDistance+1):
			#if (sqrt(i*i + j*j) <= removalDistance):
			if (not (Vector2(i, j) in chunks) and not (Vector2(i, j) in threadInputs)):
				threadInputs.push_back(Vector2(i, j))
				semaphore.post()
	
	mutex.unlock()
	
	#make objects for each terrain
	for i in range(x-drawDistance, x+drawDistance+1):
		for j in range(z-drawDistance, z+drawDistance+1):
			objectGenerator.populate(i, j,chunkSize,  resolution)






func _terrainWorker(userdata):

	while true:

		semaphore.wait() # Wait until posted.

		mutex.lock()
		var should_exit = exit_thread
		mutex.unlock()

		if should_exit:
			break

		mutex.lock()
		var coordinates = threadInputs.pop_front()
		mutex.unlock()
		
		#prevent any issues with an empty list
		#(shouldn't happen, but just in case)
		if (coordinates == null):
			continue

		var chunk = makeChunk(coordinates.x, coordinates.y)

		#push outputs
		mutex.lock()
		threadOutputs.push_back([coordinates, chunk])
		mutex.unlock()


func _process(delta: float) -> void:
	
	mutex.lock()

	var calculations = 0
	while (len(threadOutputs) != 0):
		var out = threadOutputs.pop_front()
		var coordinates = out[0]
		var chunk = out[1]
		#do ground mesh ->meshinstance conversion
		var newMeshInstance = MeshInstance.new()
		newMeshInstance.mesh = chunk[0]
		newMeshInstance.set_surface_material(0, groundMaterial)
		newMeshInstance.transform.origin = Vector3(coordinates.x*chunkSize, 0, coordinates.y*chunkSize)
		newMeshInstance.create_trimesh_collision()
		#do watermesh -> meshinstance conversion
		var waterMaterial = ShaderMaterial.new()
		waterMaterial.set_shader_param("location", Vector2(coordinates.x*chunkSize, coordinates.y*chunkSize))
		waterMaterial.set_shader_param("noise", waterNoise)
		
		waterMaterial.shader = waterShader
		
		var waterMeshInstances = []
		for i in range(2):
			var waterMesh = MeshInstance.new()
			waterMesh.mesh = chunk[1][i]
			waterMesh.transform.origin = Vector3(coordinates.x*chunkSize, 0, coordinates.y*chunkSize)
			waterMesh.set_surface_material(0, waterMaterial)
			waterMeshInstances.push_back(waterMesh)
	
		#append to the game to make visible
		if (not (coordinates  in chunks)):
			var node = Node.new()
			node.add_child(newMeshInstance)
			for instance in waterMeshInstances:
				node.add_child(instance)
			chunks[coordinates] = node
			get_node("MeshMatrix").add_child(node)
		calculations += 1
		if (calculations > valueGenerator.calculationLimit):
			break
	mutex.unlock()


	objectGenerator.process()

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
