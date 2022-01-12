extends KinematicBody




#base for the movement was shamelessly adapted from (MIT licensed)
#https://github.com/GarbajYT/godot_updated_fps_controller
var snap
var gravityVec = Vector3()
const GROUNDACCEL = 10
const AIRACCEL = 3
onready var accel = GROUNDACCEL
const jumpPower = 7 # 7
var velocity = Vector3(0,0,0)
const moveSpeed = 10
const gravity = 13
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


var inRoom = false


onready var rightMeleeAnim = $RightMeleeAnim
onready var rightHitbox = $Body/RightHandHitbox

onready var camera = $CameraJoint/Camera
onready var cameraJoint = $CameraJoint
onready var cameraWallChecker = $CameraJoint/WallChecker


onready var body = $Body

onready var animator = $Animator
onready var animationTree = $AnimationTree

onready var blockInventory = $Body/LeftShoulder/LeftArm/BlockInventory

onready var minimapCamera = $MinimapViewportContainer/Viewport/MinimapCamera

onready var weaponHolder = $Body/RightShoulder/RightArm/WeaponHolder

#onready var handCamera = $Camera/ViewportContainer/Viewport/HandCamera

onready var walkAudio = $WalkAudio
onready var hitAudio = $HitAudio

var initialized = false

onready var F1 = $RoomDetection/F1
onready var F2 = $RoomDetection/F2
onready var B1 = $RoomDetection/B1
onready var B2 = $RoomDetection/B2
onready var L1 = $RoomDetection/L1
onready var L2 = $RoomDetection/L2
onready var R1 = $RoomDetection/R1
onready var R2 = $RoomDetection/R2




# initializing mouse to be captured
func _ready() -> void:
	camera.translation.z = cameraWallChecker.cast_to.z
	
	var landingsound = preload("res://Audio/newlanding.wav")
	walkAudio.stream = landingsound
	
	var hitsound = preload("res://Audio/hit.wav")
	hitAudio.stream = hitsound


# recording mouse movements
func setMouseDelta(mD):
	mouseDelta = mD

func setMoveVector(mV):
	moveVector = mV

func checkAttackDelay(reset = true):
	if (OS.get_ticks_msec()- lastAttackTime < weaponHolder.getAttackDelay()):
		return false
	else:
		if (reset):
			lastAttackTime = OS.get_ticks_msec()
		return true

func damage(amount):
	hp -= amount


func melee():
	if (!initialized):
		return

	if (Input.is_action_just_pressed("Attack")):
		if (checkAttackDelay()):
			animationTree.set("parameters/RightAttack/active", true)
			if (blockInventory.placeMode):
				var item = blockInventory.placeItem()
				if (item != null):
					get_parent().get_node("Blocks").add_child(item)
				else:
					pass

			else:
				for body in rightHitbox.get_overlapping_bodies():
					if body.is_in_group("Enemy"):
						var right = camera.global_transform.basis.x
						var forward = right.rotated(Vector3.UP, deg2rad(90))
						var damage = weaponHolder.getDamage()
						body.damage(damage, forward)
						if (!hitAudio.is_playing()):
							hitAudio.play()
					elif body.is_in_group("Resource"):
						var damage = weaponHolder.getDamage()
						body.damage(damage)
						if (!hitAudio.is_playing()):
							hitAudio.play()
					elif (body.is_in_group("Pickup")):
						if (!hitAudio.is_playing()):
							hitAudio.play()
						
						var pickup = body.pickup()

						# {"type": type, "value": amount, "item": item}
						if (pickup["type"] == "block"):
							blockInventory.setItem(pickup["item"], pickup["amount"])
						elif (pickup["type"] == "health"):

							hp+= pickup["amount"]
							hp = clamp(hp, 0, maxHp)
						elif (pickup["type"] == "weapon"):

							weaponHolder.setWeapon(pickup["item"])
						else:
							pass
							#print(pickup["type"])
					elif body.is_in_group("Block"):
						var damage = 1#weaponHolder.getDamage()
						body.damage(damage)
						if (!hitAudio.is_playing()):
							hitAudio.play()

	if (Input.is_action_just_pressed("SecondaryAttack")):
		animationTree.set("parameters/LeftAttack/active", true)
		blockInventory.cyclePlace()

func _process(delta: float) -> void:
	#handCamera.global_transform = camera.global_transform
	
	updateMinimap()




func getRotation():
	var bodyAngle = fmod(body.rotation_degrees.y, 360)
	var cameraAngle = fmod(cameraJoint.rotation_degrees.y, 360)

	return bodyAngle - cameraAngle

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

	blockInventory.setDirection(camera.global_transform.basis.x.rotated(Vector3.UP, deg2rad(90))
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

	#get_node("ViewPortContainer/Viewport/InfoCamera").global_transform.origin = camera.global_transform.origin
	get_node("ViewPortContainer/Viewport/InfoCamera").global_transform = camera.global_transform

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
		if (gravityVec != Vector3.ZERO):
			if (!walkAudio.is_playing()):
				walkAudio.play()
		elif (relativeDir.length_squared() != 0):
			if (!walkAudio.is_playing()):
				walkAudio.play()
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



	
	if (F1.get_collider() == null && F2.get_collider() == null):
		inRoom = false
	elif (B1.get_collider() == null && B2.get_collider() == null):
		inRoom = false
	elif (L1.get_collider() == null && L2.get_collider() == null):
		inRoom = false
	elif (R1.get_collider() == null && R2.get_collider() == null):
		inRoom = false
	else:
		inRoom = true
	#print(inRoom)

func updateMinimap():
	var pos = global_transform.origin
	var cameraRot = fmod(cameraJoint.rotation_degrees.y, 360) + 90
	minimapCamera.global_transform.origin.x = pos.x
	minimapCamera.global_transform.origin.z = pos.z
	#must be way above player regardless of position
	minimapCamera.global_transform.origin.y = pos.y+50
	minimapCamera.rotation_degrees.y = cameraRot


