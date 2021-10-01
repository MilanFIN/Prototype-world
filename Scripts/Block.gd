extends StaticBody


var lastPos = Vector3.ZERO

var location = Vector3.ZERO
var direction = Vector2.ZERO

var snap = false

onready var leftRay = $LeftRay


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

	var breakSnap = false

	if (snap):
		if ((location - global_transform.origin).length() > 3):
			snap = false
			breakSnap = true


	if (not snap):
		global_transform.origin = location
		
		var angle = direction.angle()
		rotation.y = angle + deg2rad(-90)
		
		if (not breakSnap):
			if (leftRay.get_collider() != null):
				if (leftRay.get_collider().is_in_group("Block")):
					var collider = leftRay.get_collider()
					var colPos = collider.to_local(collider.global_transform.origin)
					var locPos = collider.to_local(global_transform.origin)
					var diffVector = locPos - colPos
					var absDiffVector = diffVector.abs()
					var dir = absDiffVector.max_axis()
					#print(dir, absDiffVector)
					#var colPos = to_local(leftRay.get_collider().global_transform.origin)

					
					if (dir == 0): #AXIS_X
						var offset = 2
						if ( diffVector.x < 0):
							offset *= -1
						var newPos = collider.core.to_global(collider.core.translation + Vector3(offset,0, 0))
						newPos.y = collider.global_transform.origin.y
						
						global_transform.origin = newPos#newPos
						rotation = collider.rotation

					elif (dir == 2): #AXIS_Z
						var offset = 2
						if ( diffVector.z < 0):
							offset *= -1
						var newPos = collider.core.to_global(collider.core.translation + Vector3(0, 0, offset))
						newPos.y = collider.global_transform.origin.y
						
						global_transform.origin = newPos#newPos
						rotation = collider.rotation

					#else:
					#	global_transform.origin = collider.global_transform.origin
					
					snap = true
		

func place():
	placed = true

func _physics_process(delta: float) -> void:
	pass
