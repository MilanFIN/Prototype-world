extends KinematicBody




#base for the movement was shamelessly adapted from (was MIT licensed)
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


const minLookAngle = -88.0
const maxLookAngle = 88.0


var maxHp = 100
var hp = maxHp

#deg/s
const turnRate = 480

const zoomStep = 1.0
const minZoom = 3
const maxZoom = 40

var lastAttackTime = 0
var attackDelay = 333 #ms

onready var rightMeleeAnim = $RightMeleeAnim
onready var rightHitbox = $Body/RightHandHitbox

onready var camera = $CameraJoint/Camera
onready var cameraJoint = $CameraJoint
onready var cameraWallChecker = $CameraJoint/WallChecker


onready var body = $Body

onready var animator = $Animator
onready var animationTree = $AnimationTree

onready var inventory = $Body/LeftShoulder/LeftArm/Inventory

#onready var handCamera = $Camera/ViewportContainer/Viewport/HandCamera

var damage = 4

var initialized = false



# initializing mouse to be captured
func _ready() -> void:
	camera.translation.z = cameraWallChecker.cast_to.z


# recording mouse movements
func setMouseDelta(mD):
	mouseDelta = mD

func setMoveVector(mV):
	moveVector = mV

func checkAttackDelay(reset = true):
	if (OS.get_ticks_msec()- lastAttackTime < attackDelay):
		return false
	else:
		if (reset):
			lastAttackTime = OS.get_ticks_msec()
		return true

func damage(amount):
	hp -= amount


func melee():

	if (Input.is_action_just_pressed("Attack")):
		if (checkAttackDelay()):
			animationTree.set("parameters/RightAttack/active", true)
			if (inventory.placeMode):
				var item = inventory.placeItem()
				if (item != null):
					get_parent().get_node("Blocks").add_child(item)
				else:
					pass
				
			else:
				for body in rightHitbox.get_overlapping_bodies():
					if body.is_in_group("Enemy"):
						var right = camera.global_transform.basis.x
						var forward = right.rotated(Vector3.UP, deg2rad(90))
						body.damage(damage, forward)
					elif body.is_in_group("Resource"):
						body.damage(damage)
					elif (body.is_in_group("Pickup")):
						var pickup = body.pickup()
						# {"type": type, "value": amount, "item": item}
						if (pickup["type"] == "item"):
							inventory.setItem(pickup["item"], pickup["amount"])
						elif (pickup["type"] == "health"):
							hp+= pickup["amount"]
							hp = clamp(hp, 0, maxHp)
					elif body.is_in_group("Block"):
						body.damage(damage)

	if (Input.is_action_just_pressed("SecondaryAttack")):
		animationTree.set("parameters/LeftAttack/active", true)
		inventory.cyclePlace()

func _process(delta: float) -> void:
	#handCamera.global_transform = camera.global_transform
	pass

func zoomIn(amount = zoomStep):
	var zoom = cameraWallChecker.cast_to.z
	zoom -= amount
	zoom = clamp(zoom, minZoom, maxZoom)
	cameraWallChecker.cast_to.z = zoom
	cameraWallChecker.cast_to.z = zoom

func zoomOut(amount = zoomStep):
	var zoom = cameraWallChecker.cast_to.z
	zoom += amount
	zoom = clamp(zoom, minZoom, maxZoom)
	cameraWallChecker.cast_to.z = zoom

func _physics_process(delta: float) -> void:


	#MOUSE MOVEMENT
	#vertical rotates camera
	#camera.rotation_degrees.x -= mouseDelta.y * delta
	#camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	#horizontal rotates entire player
	#rotation_degrees.y -= mouseDelta.x * delta
	#mouseDelta = Vector2()

	inventory.setDirection(camera.global_transform.basis.x.rotated(Vector3.UP, deg2rad(90))
							, translation)

	#vertical rotation
	if (mouseDelta != Vector2.ZERO):
		var newAngle = cameraJoint.rotation_degrees.x - mouseDelta.y #* delta
		cameraJoint.rotation_degrees.x = clamp(newAngle, minLookAngle, maxLookAngle)
		#horizontal rotation
		cameraJoint.rotation_degrees.y -= mouseDelta.x #* delta
	
	var cameraOffset = cameraWallChecker.cast_to.z
	if (cameraWallChecker.get_collider() != null):
		cameraOffset = (cameraWallChecker.get_collision_point() - global_transform.origin).length() + 0.5

	camera.translation.z = cameraOffset

	mouseDelta = Vector2.ZERO



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



	#var forward = camera.global_transform.basis.z
	var right = camera.global_transform.basis.x
	var forward = right.rotated(Vector3.UP, deg2rad(-90))

	var relativeDir = (forward * input.y + right * input.x)
	
	#body.rotation_degrees = 0

	var animBlend
	if (input.length_squared() != 0):

		var angle = -rad2deg(Vector2(relativeDir.z, relativeDir.x).angle_to(Vector2.UP))
		angle = int(angle) % 360

		body.rotation_degrees.y = angle

		animBlend = input.length()
		animBlend = clamp(animBlend, 0.0, 1.0)


	animationTree.set("parameters/Moving/blend_amount", animBlend)







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
	


