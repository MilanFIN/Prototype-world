extends KinematicBody

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
var dead = false
var remove = false

#set to true, when the actual height of the object has been set
var set = false
var initialized = false

onready var animationTree = $AnimationTree
onready var hitParticles = $HitParticles


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(5):
		var x = global_transform.origin.x +  randi()%21+1 - 10
		var z = global_transform.origin.z + randi()%21+1 - 10
		waypoints.push_back(Vector2(x, z))


func _on_DetectionArea_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body


func _on_DetectionArea_body_exited(body: Node) -> void:
	if body.name == "Player":
		player = null



func damage(amount, direction):
	hp -= amount
	if (hp <= 0):
		#die
		dead = true
		get_node("Body").visible = false
		hitParticles.emitting = true
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
		pass
		var collider = get_node("SetRay").get_collider()
		if (collider != null):
			transform.origin.y = get_node("SetRay").get_collision_point().y + 3
			set = true

	velocity.y = move_and_slide(velocity, Vector3.UP).y

	if (is_on_floor()):
		velocity.y = 0
		var newVelocity = velocity
		if (player):
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




	animationTree.set("parameters/Moving/blend_amount", 1)



