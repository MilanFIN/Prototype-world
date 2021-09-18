extends StaticBody

#var material = 
var particle = load("res://Assets/Particles/TreeParticle.tscn")
# preload("res://Assets/Particles/TreeParticle.tscn")

#set to true, when the actual height of the object has been set
var set = false
var initialized = false

var fullHp = 10
var hp = fullHp
var dead = false
var parent = null

var deathTime
var respawnDelay = 5000

var type = ""



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func setType(t):

	type = t

	if (type == "tree"):
		particle = load("res://Assets/Particles/TreeParticle.tscn")


	"""
	for i in (get_children()):
		if i is MeshInstance:
			var particleInst = particle.instance()
			particleInst.translation = i.mesh.get_aabb().position 
			add_child(particleInst)
			pass
	"""

func addMesh(mesh, material):
	var meshInst = MeshInstance.new()
	meshInst.mesh = mesh

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
	parent = get_parent()

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
