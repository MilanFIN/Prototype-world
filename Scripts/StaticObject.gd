extends StaticBody

export var drop = ""
export var particleType = ""
export var roll = false

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

var materialDict = {
	"rock": "RockMaterial.tres",
	"wood": "WoodMaterial.tres",
	"leaf": "LeafMaterial.tres",
	"box": "WoodMaterial.tres"
}

var shaderDict
var hitParticle

onready var setRay = $SetRay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


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

	
	var matType = materialDict[matName]

	var material = load("res://Materials/"+matType)


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
	if (not set and setRay.get_collider() != null):

		#var ground = get_node("SetRay").get_collision_point()
		#if (ground != null):
		var height = Global.valueGenerator.getY(transform.origin.x, transform.origin.z)
		transform.origin.y = height #ground.y
		
		if (roll):
			
			var normal = setRay.get_collision_normal()

			#works for sure
			var xAngle = Vector2(normal.z, normal.y).angle_to(Vector2.UP)
			var zAngle = Vector2(normal.x, normal.y).angle_to(Vector2.UP)


			rotation_degrees.x = rad2deg(xAngle) +180
			rotation_degrees.z = -rad2deg(zAngle) +180
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
			dropInst.setPosition(global_transform.origin)

	else:
		

		hitParticle.emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
