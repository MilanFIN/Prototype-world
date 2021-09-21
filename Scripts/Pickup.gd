extends KinematicBody


var velocity = Vector3.ZERO
var gravity = 9.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	velocity.y = 10
	velocity.x = rand_range(-5.0, 5.0)
	velocity.z = rand_range(-5.0, 5.0)
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if (is_on_floor()):
		pass
		velocity = Vector3.ZERO
		#velocity = Vector3.ZERO
	else:
		velocity.y -= gravity *delta 
	velocity.y = move_and_slide(velocity, Vector3.UP).y

func pickup():
	queue_free()
