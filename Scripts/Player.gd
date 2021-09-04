extends KinematicBody



#NEW
#shamelessly adapted from (was MIT licensed)
#https://github.com/GarbajYT/godot_updated_fps_controller
var snap
var gravityVec = Vector3()
const GROUNDACCEL = 10
const AIRACCEL = 3
onready var accel = GROUNDACCEL
const jumpPower = 7
var velocity = Vector3(0,0,0)
const moveSpeed = 20
const gravity = 9.8
var mouseDelta = Vector2()
const sensitivity = 10
var camera = Node
const minLookAngle = -90
const maxLookAngle = 90


onready var rightMeleeAnim = $RightMeleeAnim
onready var rightHitbox = $Camera/RightHandHitbox


# initializing mouse to be captured
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  
	camera = get_node("Camera")


# recording mouse movements
func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

func melee():
	if (Input.is_action_just_pressed("AttackRight")):
		if not (rightMeleeAnim.is_playing()):
			rightMeleeAnim.play("RightAttack")
			rightMeleeAnim.queue("RightReturn")
			for body in rightHitbox.get_overlapping_bodies():
				#if body.is_in_group("Enemy")
				print(body.name)

func _physics_process(delta: float) -> void:

	melee()

	#movement
	var input = Vector3(0,0,0)

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
		jump = true



	var forward = global_transform.basis.z
	var right = global_transform.basis.x

	var relativeDir = (forward * input.y + right * input.x)

	if is_on_floor():
		snap = -get_floor_normal()
		accel = GROUNDACCEL
		gravityVec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = AIRACCEL
		gravityVec += Vector3.DOWN * gravity * delta
	
	if (jump and is_on_floor()):
		snap = Vector3.ZERO
		gravityVec = Vector3.UP * jumpPower

	velocity = velocity.linear_interpolate(relativeDir * moveSpeed, accel * delta)
	var movement = velocity + gravityVec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)


	#MOUSE MOVEMENT
	#vertical rotates camera
	camera.rotation_degrees.x -= mouseDelta.y * sensitivity * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	#horizontal rotates entire player
	rotation_degrees.y -= mouseDelta.x * sensitivity * delta
	mouseDelta = Vector2()
