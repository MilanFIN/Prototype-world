extends StaticBody

#set to true, when the actual height of the object has been set
var set = false
var initialized = false

var fullHp = 10
var hp = fullHp
var dead = false
var parent = null

var deathTime
var respawnDelay = 5000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
	print(hp)
	if (hp <= 0):
		dead = true
		visible = false
		deathTime = OS.get_ticks_msec()

		for i in (get_children()):
			if i is CollisionShape:
				i.disabled = true




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
