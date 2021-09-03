extends StaticBody

#set to true, when the actual height of the object has been set
var set = false
var initialized = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


#atm only figures out where ground is and initializes the height to be ground
#level
func _process(delta: float) -> void:
	if (not initialized):
		return
	if (not set):
		pass
		var ground = get_node("SetRay").get_collision_point()
		if (ground != null):
			transform.origin.y = ground.y
			set = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
