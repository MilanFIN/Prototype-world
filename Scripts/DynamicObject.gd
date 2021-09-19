
extends KinematicBody

var velocity = Vector3.ZERO
var gravity = 9.81

var currentFootPoint
var lastFootPoint
var nextFootPoint
#time that moving the foot should take in seconds
const STEPTIME = 0.4
const STEPHEIGHT = 0.5
const MOVESPEED = 200
var stepElapsed = 0.0

var length0 = 2
var length1 = 2

const STEPLENGTH = 1.5

var eyeMover = OpenSimplexNoise.new()


var waypoints = []
var waypointIndex = 0

#set to true, when the actual height of the object has been set
var set = false
var initialized = false

var hp = 10
var dead = false
var remove = false

onready var deathParticles = $DeathParticles
onready var hitParticles = $HitParticles


func _ready() -> void:
	currentFootPoint = get_node("FootRay").get_collision_point()# -global_transform.origin
	nextFootPoint = null

	eyeMover.period = 1024
	eyeMover.octaves = 1
	
	for i in range(5):
		var x = global_transform.origin.x +  randi()%21+1 - 10
		var z = global_transform.origin.z + randi()%21+1 - 10
		waypoints.push_back(Vector2(x, z))



func damage(amount):
	hp -= amount
	if (hp <= 0):
		#die
		dead = true
		get_node("Body").visible = false
		deathParticles.emitting = true
	else:
		hitParticles.emitting = true




func setJoints():
	var jointAngle0;
	var jointAngle1;
	
	#var jointPos0 = get_node("Body/Hip").global_transform.origin
	var jointPos0 = get_node("Body/Hip").translation
	jointPos0 = Vector2(jointPos0.z, jointPos0.y)

	
	#var target = Vector2(currentFootPoint.z, currentFootPoint.y)
	var target = Vector2(get_node("Body/Foot").translation.z, get_node("Body/Foot").translation.y)

	var length2 = (target-jointPos0).length();

	# Angle from Joint0 and Target
	var diff = target-jointPos0;
	var arctan = rad2deg(atan2(diff.y, diff.x) );
	# Is the target reachable?
	# If not, we stretch as far as possible
	if (length0 + length1 < length2):
		jointAngle0 = arctan;
		jointAngle1 = 0;

	else:
		var cosAngle0 = ((length2 * length2) + (length0 * length0) - (length1 * length1)) / (2 * length2 * length0);
		var angle0 = rad2deg(acos(cosAngle0) );
		var cosAngle1 = ((length1 * length1) + (length0 * length0) - (length2 * length2)) / (2 * length1 * length0);
		var angle1 = rad2deg(acos(cosAngle1) );
		# So they work in Unity reference frame
		jointAngle0 = arctan - angle0;
		jointAngle1 = 180 - angle1;
		
	var angle0 = -jointAngle0 - 90
	var angle1 = -jointAngle1

	get_node("Body/Hip").rotation_degrees.x = angle0
	get_node("Body/Hip/Knee").rotation_degrees.x = angle1



	
	if (angle1 < 0):
		angle1 *= -1
		#get_node("Body/Hip/Knee").translation#global_transform.origin
		var kneePoint = get_node("Body/Hip/Knee").translation#global_transform.origin
		kneePoint = to_local(get_node("Body/Hip/Knee").global_transform.origin)
		kneePoint = jointPos0+ Vector2(kneePoint.z, kneePoint.y)

		var kneeVector = kneePoint - jointPos0
		var targetVector = target - jointPos0
		
		var misAngle = rad2deg(targetVector.angle_to(kneeVector))
		angle0 += 2*misAngle
	
		get_node("Body/Hip").rotation_degrees.x = angle0
		get_node("Body/Hip/Knee").rotation_degrees.x = angle1
	

func moveFootPoint(delta):
	if (nextFootPoint != null):

		if (stepElapsed < STEPTIME):
			
			stepElapsed += delta

			var stepVector = nextFootPoint - lastFootPoint
			var nextContribution = stepElapsed / STEPTIME
			nextContribution = clamp(nextContribution, 0, 1)
			currentFootPoint = nextContribution*stepVector + lastFootPoint
			
			var yChange = abs(nextFootPoint.y - lastFootPoint.y)
			yChange = clamp(yChange, -1, 1)
			
			currentFootPoint.y += sin(PI*nextContribution)*yChange*STEPHEIGHT
			
			get_node("Body").translation.y = sin(PI*nextContribution)*yChange*STEPHEIGHT * 2

		else:

			currentFootPoint = nextFootPoint

func _physics_process(delta):

	if (dead):
		if (deathParticles.emitting == false):
			remove = true
		return

	if (not initialized):
		return
	if (not set):
		pass
		var collider = get_node("SetRay").get_collider()
		if (collider != null):
			transform.origin.y = get_node("SetRay").get_collision_point.y + 5
			set = true


	var newVelocity = velocity
	var waypoint = waypoints[waypointIndex]

	var xDiff = global_transform.origin.x - waypoint.x
	var zDiff = global_transform.origin.z - waypoint.y

	if (xDiff < -1):
		newVelocity.x = MOVESPEED*delta
	elif (xDiff > 1):
		newVelocity.x = -MOVESPEED*delta
	else:
		newVelocity.x = 0

	if (zDiff < -1):
		newVelocity.z = MOVESPEED*delta
	elif (zDiff > 1):
		newVelocity.z = -MOVESPEED*delta
	else:
		newVelocity.z = 0

	if (abs(xDiff) < 1 and abs(zDiff) < 1):
		waypointIndex += 1
		if (waypointIndex == len(waypoints)):
			waypointIndex = 0
	

	velocity = velocity.linear_interpolate(newVelocity, 0.1)

	var angle = rad2deg(Vector2(velocity.z, velocity.x).angle())
	rotation_degrees.y = angle + 180
	
	if (is_on_floor()):
		velocity.y = 0
	else:
		velocity.y -= gravity *delta 

	
	
	velocity.y -= gravity *delta 
	velocity.y = move_and_slide(velocity, Vector3.UP).y
	
	if (is_on_floor() and get_slide_count() > 0):

		

		var  footPoint = get_node("FootRay").get_collision_point() #-global_transform.origin# translation - 


		if (footPoint != null):
			var xDist = abs(currentFootPoint.x - global_transform.origin.x) #footPoint.x
			var zDist = abs(currentFootPoint.z - global_transform.origin.z)
			
			var dist = sqrt(xDist*xDist + zDist*zDist)
			if (dist > STEPLENGTH):
				lastFootPoint = currentFootPoint
				nextFootPoint = footPoint
				stepElapsed = 0.0
				#get_node("Foot").rotation_degrees.x = angle - 90

		
			get_node("Body/Foot").global_transform.origin = currentFootPoint #+ global_transform.origin

	if (velocity.x != 0 or velocity.z != 0):
		pass
		moveFootPoint(delta)
		setJoints()
	

	
	var time = OS.get_ticks_msec()
	var eyeAngle = eyeMover.get_noise_1d(time) * 30
	var eyeAngle2 = eyeMover.get_noise_1d(time+1001) * 20
	get_node("Body/Eye/Pupiljoint").rotation_degrees.y = eyeAngle
	get_node("Body/Eye/Pupiljoint").rotation_degrees.x = eyeAngle2
