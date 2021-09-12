extends KinematicBody



#NEW
#shamelessly adapted from (was MIT licensed)
#https://github.com/GarbajYT/godot_updated_fps_controller
var snap
var gravityVec = Vector3()
const GROUNDACCEL = 10
const AIRACCEL = 3
onready var accel = GROUNDACCEL
const jumpPower = 10 # 7
var velocity = Vector3(0,0,0)
const moveSpeed = 20
const gravity = 9.8
var mouseDelta = Vector2()
var moveVector = Vector2()
const sensitivity = 10

const minLookAngle = -90
const maxLookAngle = 90


onready var rightMeleeAnim = $RightMeleeAnim
onready var rightHitbox = $Camera/RightHandHitbox

onready var camera = $Camera
onready var handCamera = $Camera/ViewportContainer/Viewport/HandCamera

var damage = 4

var initialized = false

# initializing mouse to be captured
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  
	camera = get_node("Camera")


# recording mouse movements
func setMouseDelta(mD):
	mouseDelta = mD

func setMoveVector(mV):
	moveVector = mV

func melee():
	if (Input.is_action_just_pressed("AttackRight")):
		if not (rightMeleeAnim.is_playing()):
			rightMeleeAnim.play("RightAttack")
			rightMeleeAnim.queue("RightReturn")
			for body in rightHitbox.get_overlapping_bodies():
				if body.is_in_group("Enemy") or body.is_in_group("Resource"):
					body.damage(damage)

func _process(delta: float) -> void:
	handCamera.global_transform = camera.global_transform

func _physics_process(delta: float) -> void:

	#MOUSE MOVEMENT
	#vertical rotates camera
	camera.rotation_degrees.x -= mouseDelta.y * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	#horizontal rotates entire player
	rotation_degrees.y -= mouseDelta.x * delta
	mouseDelta = Vector2()



	#wait until scene rendered
	if (not initialized):
		if (get_node("GroundRay").get_collider() == null):

			return
		else:
			translation = get_node("GroundRay").get_collision_point()
			translation.y += 5
			initialized = true
	melee()



	#movement
	var input = Vector2.ZERO

	if (moveVector != Vector2.ZERO):
		input = moveVector
	else:
		if Input.is_action_pressed("forward"):
			input.y -= 1
		if Input.is_action_pressed("back"):
			input.y += 1
		if Input.is_action_pressed("left"):
			input.x -= 1
		if Input.is_action_pressed("right"):
			input.x += 1
	
	
	var jump = false
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
	
	moveVector = Vector2.ZERO

