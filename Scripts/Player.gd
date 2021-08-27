extends KinematicBody


var velocity = Vector3(0,0,0)
const moveSpeed = 20
const gravity = 9.8
var mouseDelta = Vector2()
const sensitivity = 10
var camera = Node
const minLookAngle = -90
const maxLookAngle = 90

var jumping = false

var snapDirection = Vector3.DOWN
var snapLength = 1.0
var snapVector = snapDirection * snapLength

var maxFloorAngle = deg2rad(45)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  
	camera = get_node("Camera")
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

func _physics_process(delta: float) -> void:

	if (get_node("FootRay").get_collider() != null):
		jumping = false
	else:
		jumping = true


	#CHARACTER MOVEMENT
	var input = Vector3(0,0,0)

	velocity.x = 0
	velocity.z = 0
	var jump = false

	if Input.is_action_pressed("forward"):
		input.y -= 1
	if Input.is_action_pressed("back"):
		input.y += 1
	if Input.is_action_pressed("left"):
		input.x -= 1
	if Input.is_action_pressed("right"):
		input.x += 1
	if Input.is_action_pressed("jump"):
		if (jumping == false):
			jump = true



	var forward = global_transform.basis.z
	var right = global_transform.basis.x

	var relativeDir = (forward * input.y + right * input.x)
	


	#UNCOMMENT FOR GRAVITY
	velocity.y -= gravity * delta
	velocity.x = relativeDir.x * moveSpeed
	velocity.z = relativeDir.z * moveSpeed
	#velocity = move_and_slide(velocity, Vector3.UP, true);
	if (jump == true):
		velocity.y += 1
		velocity.y = move_and_slide(velocity, Vector3.UP, true).y;
	else:
		velocity.y = move_and_slide_with_snap(velocity, snapVector, Vector3.UP, true, 4, maxFloorAngle).y


	#MOUSE MOVEMENT
	#vertical rotates camera
	camera.rotation_degrees.x -= mouseDelta.y * sensitivity * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	#horizontal rotates entire player
	rotation_degrees.y -= mouseDelta.x * sensitivity * delta
	mouseDelta = Vector2()
