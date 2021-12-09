extends KinematicBody

export var drop = ""
export var hostile = false
export var nocturnal = false
export var underwater = false


var velocity = Vector3.ZERO
var gravity = 9.81
const MOVESPEED = 6
var bounce = 9
var knockBack = 5

#ms
var lastActionTime = 0
var actionDelay = 500



var player = null

var waypoints = []
var waypointIndex = 0


export var hp = 10
var maxHp = hp

var lastAttackTime = 0
export var attackDelay = 333#ms
export var damage = 3.0

export var minLevel = 1
export var title = ""

var dead = false
var remove = false

#set to true, when the actual height of the object has been set
var set = false
var initialized = false

onready var animationTree = $AnimationTree
onready var hitParticles = $HitParticles

onready var attackShape = $AttackShape

onready var detectionArea = $DetectionArea

onready var info = $Info

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	for i in range(5):
		var x = global_transform.origin.x +  randi()%21+1 - 10
		var z = global_transform.origin.z + randi()%21+1 - 10
		var y = Global.valueGenerator.getY(x, z)
		if (underwater):
			if (y <= 0):
				waypoints.push_back(Vector2(x, z))
		else:
			if (y >= 0):
				waypoints.push_back(Vector2(x, z))

	if (len(waypoints) == 0):
		var x = global_transform.origin.x
		var z = global_transform.origin.z
		waypoints.push_back(Vector2(x, z))

	info.setInfo(title, minLevel)
	info.setHp(hp, maxHp)

func damage(amount, direction, environmentDamage=false):
	if (hp <= 0):
		return
	hp -= amount
	info.setHp(hp, maxHp)
	if (hp <= 0):
		#die
		dead = true
		get_node("Body").visible = false
		info.visible = false
		hitParticles.emitting = true
		
		if (drop != "" and !environmentDamage):
			if (drop in Global.dropTable):
				var dropList = Global.dropTable[drop]
				if (len(dropList) != 0):
					var probRange = 0.0
					for i in (dropList):
						probRange += i[0]
					var limit = rand_range(0.0001, probRange - 0.0001)
					var cumulative = 0
					var dropRes = ""
					for i in dropList:
						if (cumulative <= limit && cumulative+i[0] > limit):
							dropRes = i[1]
						cumulative += i[0]
					if (dropRes != ""):
						var dropInst = load("res://Assets/Pickups/"+dropRes+".tscn").instance()
						get_parent().add_child(dropInst)
						dropInst.setPosition(global_transform.origin)
	else:
		pass
		hitParticles.emitting = true
	direction *= knockBack
	if (is_on_floor()):
		direction += Vector3.UP*bounce
	velocity = direction

	
	
func _physics_process(delta: float) -> void:
	if (dead):
		if (hitParticles.emitting == false):
			remove = true
			return

	if (not initialized):
		return
	if (not set):

		var collider = get_node("SetRay").get_collider()
		if (collider != null):
			transform.origin.y = get_node("SetRay").get_collision_point().y + 3
			set = true


	if (hostile):
		for body in attackShape.get_overlapping_bodies():
			if (body.is_in_group("Player")):
				if (OS.get_ticks_msec()- lastAttackTime > attackDelay):
					body.damage(damage)
					lastAttackTime = OS.get_ticks_msec()


	velocity.y = move_and_slide(velocity, Vector3.UP).y

	player = null
	var bodies = detectionArea.get_overlapping_bodies()
	if (len(bodies) != 0):
		player = bodies[0]
		

	if (is_on_floor()):
		velocity.y = 0
		var newVelocity = velocity
		if (player and hostile):
			newVelocity = Vector3.ZERO
			var dir = player.translation - translation
			dir = Vector2(dir.x, dir.z).normalized()
			newVelocity.x = dir.x * MOVESPEED
			newVelocity.z = dir.y * MOVESPEED
			velocity = newVelocity
		else:
			var waypoint = waypoints[waypointIndex]

			var xDiff = global_transform.origin.x - waypoint.x
			var zDiff = global_transform.origin.z - waypoint.y

			if (xDiff < -1):
				newVelocity.x = MOVESPEED#*delta
			elif (xDiff > 1):
				newVelocity.x = -MOVESPEED#*delta
			else:
				newVelocity.x = 0

			if (zDiff < -1):
				newVelocity.z = MOVESPEED#*delta
			elif (zDiff > 1):
				newVelocity.z = -MOVESPEED#*delta
			else:
				newVelocity.z = 0

			if (abs(xDiff) < 1 and abs(zDiff) < 1):
				waypointIndex += 1
				if (waypointIndex == len(waypoints)):
					waypointIndex = 0



			velocity = velocity.linear_interpolate(newVelocity, 3*delta)
			
			
		var angle = rad2deg(Vector2(velocity.z, velocity.x).angle())
		rotation_degrees.y = angle + 180


	else:
		velocity.y -= gravity *delta 


	var futureX = global_transform.origin.x + velocity.normalized().x
	var futureZ = global_transform.origin.z + velocity.normalized().z
	if (underwater and Global.valueGenerator.getY(futureX, futureZ) > 0):
		velocity.x = 0
		velocity.z = 0

	elif (!underwater and Global.valueGenerator.getY(futureX, futureZ) < 0):
		velocity.x = 0
		velocity.z = 0
	animationTree.set("parameters/Moving/blend_amount", 1)




