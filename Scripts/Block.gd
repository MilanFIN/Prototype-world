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
var dead = false
onready var hitParticles = $HitParticles

onready var placedMesh = $PlacedMesh
onready var previewMesh = $PreviewMesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#returns the distance of an edge from core, if looking at a direction
#edge is the one with smallest normal
func getOffset(directionAxis):
	if (directionAxis == 0): #AXIS_X

		return width/2
	else: #AXIS_Z
		return depth/2

func checkOverlap():
	var overlap = false
	for body in placementBox.get_overlapping_bodies():
		if (body.is_in_group("Block")):
			if (body != self):
				overlap = true
				break
	return overlap

#call when previewing to set block location based on player pos & camera dir
func preview(dir, loc):
	dir.y = 0
	location = loc
	location.x += dir.x * 10
	location.z += dir.z * 10
	location.y = Global.valueGenerator.getY(location.x, location.z)
	direction = Vector2(dir.x, -dir.z)
	setLocation()

#either sets the block to location, or snaps to a nearby one, if
#they are close enough and legal placements
func setLocation():
	#needed, as raycasts don't update until next physics call
	#otherwise snap will just end up re-enabled
	var brokeSnap = false

	#currently snapped, check if needs to break
	if (snap):
		if ((location - global_transform.origin).length() > snapBreakDistance
				or checkOverlap()):
			brokeSnap = true
			snap = false

			global_transform.origin = location
		

	if ((not snap) and not brokeSnap):
		#set location to the one that was suggested, might modify later
		#if rays intersect
		global_transform.origin = location
		
		var angle = direction.angle()
		rotation.y = angle + deg2rad(-90)
		
		#can't snap if in a position where placement would overlap
		var blockSnapping = false
		if checkOverlap():
			blockSnapping = true
		
		
		if ((not brokeSnap) and (not blockSnapping)):
			#go through all 4(?) rays
			for ray in rays.get_children():
				if (ray.get_collider() != null):
					if (ray.get_collider().is_in_group("Block")):
						#now we know that a ray has intersected a block
						var collider = ray.get_collider()
						
						#position differences in collider local coordinate space
						#figuring out where new block is in comparison to old 
						var colPos = collider.to_local(collider.global_transform.origin)
						var locPos = collider.to_local(global_transform.origin)
						var diffVector = locPos - colPos
						var absDiffVector = diffVector.abs()
						#0 for x and 2 for z axis 
						var dir = absDiffVector.max_axis()
						
						#position differences in self local coord space
						#figuring out the direction of old block
						#in comparison to old coord space
						var localColPos = to_local(collider.global_transform.origin)
						var localSelfPos = to_local(global_transform.origin)
						var localAbsDiffVector = (localColPos - localSelfPos).abs()
						var localDir = localAbsDiffVector.max_axis()


						#90 snapped angle that should be added to collider rotation
						#for the desired goal rotation
						var rotDiff = round((rotation_degrees.y-collider.rotation_degrees.y) / 90.0) *90

						#calculating distance of the old block edge from its center
						var offset = collider.getOffset(dir)
						#adding the distance to the new blocks corresponding edge 
						#to its center
						if (localDir == 0): #AXIS_X, old block is on left or right
							offset += width /2
						elif (localDir == 2): #AXIS_Z, old is front or back
							offset += depth /2

						rotation_degrees.y = collider.rotation_degrees.y + rotDiff
						snapBreakDistance = offset + SNAPMARGIN

						
						if (dir == 0): #AXIS_X
							#must flip the direction if on right
							if ( diffVector.x < 0):
								offset *= -1
							#adding offset vector, must use old block core as basis
							var newPos = collider.core.to_global(collider.core.translation + Vector3(offset,0, 0))
							newPos.y = Global.valueGenerator.getY(newPos.x, newPos.z)
							
							global_transform.origin = newPos


						elif (dir == 2): #AXIS_Z
							#must flip direction if on left
							if ( diffVector.z < 0):
								offset *= -1
							var newPos = collider.core.to_global(collider.core.translation + Vector3(0, 0, offset))
							newPos.y = Global.valueGenerator.getY(newPos.x, newPos.z)
							global_transform.origin = newPos
						#set snap to true as now we are locked to the edge 
						#of old block, then break, as other rays don't matter
						snap = true
						break

#check if a block can be placed, (overlaps)
func place():
	#check if the block is overapping others, as that would be an illegal
	#placement

	if (checkOverlap()):
		return false
	#otherwise all ok
	placed = true
	placedMesh.visible = true
	previewMesh.visible = false
	return true

func damage(amount):
	dead = true
	hitParticles.emitting = true
	for i in (get_children()):
		if i is CollisionShape:
			i.disabled = true
		if i is MeshInstance:
			i.visible = false
		if i is CPUParticles:
			i.emitting = true

func _physics_process(delta: float) -> void:
	if (dead):
		if (not hitParticles.emitting):
			queue_free()
