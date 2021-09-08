extends StaticBody

var material = preload("res://Materials/BloodSplatter.tres")
var particle = preload("res://Assets/Particles/StaticObjParticles.tscn")

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

	for i in (get_children()):
		if i is MeshInstance:

			var particleInst = particle.instance()

			particleInst.translation = i.mesh.get_aabb().position 
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
		#get_node("StaticObjParticles").emitting = true
		

		#must set material
		var color = Color(0.0, 0.0, 0.0)
		if (type == "tree"):
			color = Color(0.0, 0.8, 0.0)
		elif (type == "rock"):
			color = Color(0.3, 0.3, 0.3)


		material.albedo_color = color


		for i in (get_children()):
			if i is CollisionShape:
				i.disabled = true
			if i is MeshInstance:
				i.visible = false
			if i is CPUParticles:

				i.material_override = material

				i.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
