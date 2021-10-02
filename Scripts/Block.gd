extends StaticBody


var lastPos = Vector3.ZERO

var location = Vector3.ZERO
var direction = Vector2.ZERO

var snap = false

onready var leftRay = $LeftRay
onready var rays = $Rays

onready var collisionShape = $CollisionShape
onready var core = $Core

var placed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func preview(dir, loc):
	dir.y = 0
	location = loc
	location.x += dir.x * 10
	location.z += dir.z * 10
	location.y = Global.valueGenerator.getY(location.x, location.z)
	direction = Vector2(dir.x, -dir.z)
	setLocation()

func setLocation():

	#needed, as raycasts don't update until next physics call
	#otherwise snap will just end up re-enabled
	var brokeSnap = false

	if (snap):
		if ((location - global_transform.origin).length() > 2.1):
			snap = false
			brokeSnap = true


	if (not snap):
		global_transform.origin = location
		
		var angle = direction.angle()
		rotation.y = angle + deg2rad(-90)
		
		if (not brokeSnap):
			
			for ray in rays.get_children():
				if (ray.get_collider() != null):
					if (ray.get_collider().is_in_group("Block")):
						var collider = ray.get_collider()
						var colPos = collider.to_local(collider.global_transform.origin)
						var locPos = collider.to_local(global_transform.origin)
						var diffVector = locPos - colPos
						var absDiffVector = diffVector.abs()
						var dir = absDiffVector.max_axis()


						#90 snapped angle that should be added to collider rotation
						#for the desired goal rotation
						var rotDiff = round((rotation_degrees.y-collider.rotation_degrees.y) / 90.0) *90


						if (dir == 0): #AXIS_X
							var offset = 2
							if ( diffVector.x < 0):
								offset *= -1
							var newPos = collider.core.to_global(collider.core.translation + Vector3(offset,0, 0))
							newPos.y = Global.valueGenerator.getY(newPos.x, newPos.z)#collider.global_transform.origin.y
							
							global_transform.origin = newPos#newPos

							rotation_degrees.y = collider.rotation_degrees.y + rotDiff
						elif (dir == 2): #AXIS_Z
							var offset = 2
							if ( diffVector.z < 0):
								offset *= -1
							var newPos = collider.core.to_global(collider.core.translation + Vector3(0, 0, offset))
							newPos.y = Global.valueGenerator.getY(newPos.x, newPos.z)#collider.global_transform.origin.ya
							
							global_transform.origin = newPos#newPos

							rotation_degrees.y = collider.rotation_degrees.y + rotDiff

						#else:
						#	global_transform.origin = collider.global_transform.origin
						
						snap = true
						break
		

func place():
	placed = true

func _physics_process(delta: float) -> void:
	pass
