extends StaticBody

#set to true, when the actual height of the object has been set
var set = false
var initialized = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if (not initialized):
		return
	if (not set):
		var ground = get_node("SetRay").get_collision_point()
		if (ground != null):
			transform.origin.y = ground.y
			set = true
			print("SET TO: ", ground)
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
