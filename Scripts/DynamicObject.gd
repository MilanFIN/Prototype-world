
extends KinematicBody

var velocity = Vector3.ZERO
var gravity = 9.81

var currentFootPoint

var length0 = 2
var length1 = 2

func _ready() -> void:
	currentFootPoint = get_node("FootRay").get_collision_point()# -global_transform.origin


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func setJoints():
	var jointAngle0;
	var jointAngle1;
	
	var jointPos0 = get_node("Hip").global_transform.origin
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

	get_node("Hip").rotation_degrees.x = -jointAngle0 - 90
	get_node("Hip/Knee").rotation_degrees.x = -jointAngle1

func _physics_process(delta):

	
	velocity.x = 0
	velocity.z = -100*delta

	if (is_on_floor()):
		velocity.y = 0
	else:
		velocity.y -= gravity *delta 

	velocity = move_and_slide(velocity, Vector3.UP)
	
	if (is_on_floor() and get_slide_count() > 0):
		var groundNormal = get_node("FootRay").get_collision_normal()
		

		#var corrected = align_with_y(global_transform, goalRotation)
		#global_transform = global_transform.interpolate_with(corrected, 0.2)


		var angle = rad2deg(Vector2(-groundNormal.z, groundNormal.y).angle()) 

		get_node("Hip").rotation_degrees.x = angle - 90

		var  footPoint = get_node("FootRay").get_collision_point() #-global_transform.origin# translation - 


		if (footPoint != null):
			if (abs(currentFootPoint.length() - footPoint.length()) > 8):
				currentFootPoint = footPoint
				#get_node("Foot").rotation_degrees.x = angle - 90

		
			get_node("Foot").global_transform.origin = currentFootPoint #+ global_transform.origin

	setJoints()
