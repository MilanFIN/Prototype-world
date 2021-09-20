extends StaticBody

export var drop = ""
export var particleType = ""



"""
var particleDict  = {
	"tree": load("res://Assets/Particles/TreeParticle.tscn"),
	"rock": load("res://Assets/Particles/StoneParticles.tscn")
	}
"""
var particle




#set to true, when the actual height of the object has been set
var set = false
var initialized = false

var fullHp = 10
var hp = fullHp
var dead = false

var deathTime
var respawnDelay = 5000

var type = ""

var stoneShader# = preload("res://Shaders/stone.shader")
var woodShader# = preload("res://Shaders/wood.shader")
var leafShader# = preload("res://Shaders/leaf.shader")

var shaderDict
var hitParticle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
	stoneShader = load("res://Shaders/stone.shader")
	woodShader = load("res://Shaders/wood.shader")
	leafShader = load("res://Shaders/leaf.shader")

	shaderDict = {
		"wood": woodShader,
		"leaf": leafShader,
		"rock": stoneShader
	}



func setType(t):

	type = t


	particle = load("res://Assets/Particles/"+particleType+".tscn")
	#particleDict[type]

	hitParticle = particle.instance()
	hitParticle.translation = Vector3(0, 2, 0)
	add_child(hitParticle)


func addMesh(mesh, matName):
	var meshInst = MeshInstance.new()
	meshInst.mesh = mesh
	
	var material = ShaderMaterial.new()
	material.shader = shaderDict[matName]
	

	meshInst.set_surface_material(0, material)

	#old broken shite, should avoid
	#meshInst.create_trimesh_collision()
	#FIX is HERE, creating separate collisionpolys for each
	#mesh and adding them to the root spatial node of staticobj
	var collisionShape = mesh.create_trimesh_shape()
	var collisionPoly = CollisionShape.new()
	collisionPoly.shape = collisionShape
	add_child(collisionPoly)
	add_child(meshInst)

	var particleInst = particle.instance()
	particleInst.translation = mesh.get_aabb().position 
	add_child(particleInst)

#atm only figures out where ground is and initializes the height to be ground
#level
func _process(delta: float) -> void:


	if (dead):
		
		if ( OS.get_ticks_msec() - deathTime > respawnDelay):
			dead = false
			visible = true
			hp = fullHp
			
			for i in (get_children()):
				if i is CollisionShape:
					i.disabled = false
				if i is MeshInstance:
					i.visible = false
		else:
			return
		
		
	if (not initialized):
		return
	if (not set):
		pass
		var ground = get_node("SetRay").get_collision_point()
		if (ground != null):
			transform.origin.y = ground.y
			set = true


func damage(amount):
	hp -= amount

	if (hp <= 0):
		dead = true
		#visible = false
		deathTime = OS.get_ticks_msec()


		for i in (get_children()):
			if i is CollisionShape:
				i.disabled = true
			if i is MeshInstance:
				i.visible = false
			if i is CPUParticles:
				i.emitting = true
		
		if (drop != ""):
			var dropRes = load("res://Assets/Pickups/"+drop+".tscn")
			var dropInst = dropRes.instance()
			get_parent().add_child(dropInst)
			dropInst.global_transform.origin = global_transform.origin
	else:
		

		hitParticle.emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
