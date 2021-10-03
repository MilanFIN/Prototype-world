extends StaticBody

export var width = 2
export var depth = 2

var lastPos = Vector3.ZERO

var location = Vector3.ZERO
var direction = Vector2.ZERO

var snap = false
var snapBreakDistance = 0
const SNAPMARGIN = 0.1

onready var rays = $Rays

onready var collisionShape = $CollisionShape
onready var core = $Core

onready var placementBox = $PlacementBox

var placed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func getOffset(directionAxis):
	if (directionAxis == 0): #AXIS_X

		return width/2
	else: #AXIS_Z
		return depth/2

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
		if ((location - global_transform.origin).length() > snapBreakDistance):
			brokeSnap = true
			snap = false


	if (not snap):
		global_transform.origin = location
		
		var angle = direction.angle()
		rotation.y = angle + deg2rad(-90)
		
		var blockSnapping = false
		
		for body in placementBox.get_overlapping_bodies():
			if (body.is_in_group("Block")):
				if (body != self):
					blockSnapping = true
		
		if (not brokeSnap and not blockSnapping):
			for ray in rays.get_children():
				if (ray.get_collider() != null):
					if (ray.get_collider().is_in_group("Block")):
						var collider = ray.get_collider()
						
						#position differences in collider local coordinate space
						var colPos = collider.to_local(collider.global_transform.origin)
						var locPos = collider.to_local(global_transform.origin)
						var diffVector = locPos - colPos
						var absDiffVector = diffVector.abs()
						var dir = absDiffVector.max_axis()
						
						#position differences in self local coord space
						var localColPos = to_local(collider.global_transform.origin)
						var localSelfPos = to_local(global_transform.origin)
						var localAbsDiffVector = (localColPos - localSelfPos).abs()
						var localDir = localAbsDiffVector.max_axis()
						

						#90 snapped angle that should be added to collider rotation
						#for the desired goal rotation
						var rotDiff = round((rotation_degrees.y-collider.rotation_degrees.y) / 90.0) *90

						var offset = collider.getOffset(dir)

						rotation_degrees.y = collider.rotation_degrees.y + rotDiff

						if (localDir == 0): #AXIS_X, old block is on left or right
							offset += width /2
						elif (localDir == 2): #AXIS_Z, old is front or back
							offset += depth /2

						
						snapBreakDistance = offset + SNAPMARGIN

						
						if (dir == 0): #AXIS_X
							
							if ( diffVector.x < 0):
								offset *= -1
							var newPos = collider.core.to_global(collider.core.translation + Vector3(offset,0, 0))
							newPos.y = Global.valueGenerator.getY(newPos.x, newPos.z)#collider.global_transform.origin.y
							
							global_transform.origin = newPos#newPos


						elif (dir == 2): #AXIS_Z


							if ( diffVector.z < 0):
								offset *= -1
							var newPos = collider.core.to_global(collider.core.translation + Vector3(0, 0, offset))
							newPos.y = Global.valueGenerator.getY(newPos.x, newPos.z)#collider.global_transform.origin.ya
							
							global_transform.origin = newPos#newPos



						#else:
						#	global_transform.origin = collider.global_transform.origin
						
						snap = true
						break
		

func place():
	for body in placementBox.get_overlapping_bodies():
		if (body.is_in_group("Block")):
			if (body != self):
				return false

	placed = true
	return true

func _physics_process(delta: float) -> void:
	pass
