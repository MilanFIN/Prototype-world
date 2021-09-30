extends StaticBody


var lastPos = Vector3.ZERO

onready var setRay = $SetRay


var location = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func preview(dir, loc):

	
	location = loc
	location.x += dir.x * 10
	location.z += dir.z * 10
	#set to ground level



func _physics_process(delta: float) -> void:
	global_transform.origin = location
	global_transform.origin.y = Global.valueGenerator.getY(location.x, location.z)



	"""
	if (setRay.get_collider() != null):
		transform.origin.y = setRay.get_collision_point().y 
	else:
		global_transform.origin.y -= 100
	"""
