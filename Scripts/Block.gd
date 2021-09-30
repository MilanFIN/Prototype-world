extends StaticBody


var lastPos = Vector3.ZERO

onready var setRay = $SetRay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func preview(dir, location):
	global_transform.origin = location + dir*10
	global_transform.origin.y += 100
	
	#set to ground level



func _physics_process(delta: float) -> void:
	if (setRay.get_collider() != null):
		transform.origin.y = setRay.get_collision_point().y 
	else:
		global_transform.origin.y -= 100
