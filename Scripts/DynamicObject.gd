
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

func _ready() -> void:
	currentFootPoint = get_node("FootRay").get_collision_point()# -global_transform.origin
	nextFootPoint = null

	eyeMover.period = 1024
	eyeMover.octaves = 1

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func setJoints():
	var jointAngle0;
	var jointAngle1;
	
	var jointPos0 = get_node("Body/Hip").global_transform.origin
	var target = Vector2(currentFootPoint.z, currentFootPoint.y)
	jointPos0 = Vector2(jointPos0.z, jointPos0.y)
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
	
		var kneePoint = get_node("Body/Hip/Knee").global_transform.origin
		kneePoint = Vector2(kneePoint.z, kneePoint.y)
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

			
			currentFootPoint = nextContribution*stepVector + lastFootPoint
			

			var yChange = abs(nextFootPoint.y - lastFootPoint.y)
			
			
			currentFootPoint.y += sin(PI*nextContribution)*yChange*STEPHEIGHT
			
			get_node("Body").translation.y = sin(PI*nextContribution)*yChange*STEPHEIGHT * 2
			

			
			
			
		else:
			currentFootPoint = nextFootPoint

func _physics_process(delta):

	
	velocity.x = 0
	velocity.z = -MOVESPEED*delta

	if (is_on_floor()):
		velocity.y = 0
	else:
		velocity.y -= gravity *delta 

	velocity = move_and_slide(velocity, Vector3.UP)
	
	if (is_on_floor() and get_slide_count() > 0):
		var groundNormal = get_node("FootRay").get_collision_normal()
		

		#var corrected = align_with_y(global_transform, goalRotation)
		#global_transform = global_transform.interpolate_with(corrected, 0.2)


		#var angle = rad2deg(Vector2(-groundNormal.z, groundNormal.y).angle()) 

		#get_node("Body/Hip").rotation_degrees.x = angle - 90

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

	moveFootPoint(delta)
	setJoints()
	
	
	var time = OS.get_ticks_msec()
	var eyeAngle = eyeMover.get_noise_1d(time) * 30
	var eyeAngle2 = eyeMover.get_noise_1d(time+1001) * 20
	get_node("Body/Eye/Pupiljoint").rotation_degrees.y = eyeAngle
	get_node("Body/Eye/Pupiljoint").rotation_degrees.x = eyeAngle2
