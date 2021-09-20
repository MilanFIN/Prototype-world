extends KinematicBody


var velocity = Vector3.ZERO
var gravity = 9.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("MOI")
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if (is_on_floor()):
		pass
		velocity = Vector3.ZERO
		#velocity = Vector3.ZERO
	else:
		velocity.y -= gravity *delta 
	velocity.y = move_and_slide(velocity, Vector3.UP).y
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
