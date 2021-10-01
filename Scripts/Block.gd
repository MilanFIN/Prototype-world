extends StaticBody


var lastPos = Vector3.ZERO

var location = Vector3.ZERO
var direction = Vector2.ZERO

var snap = false

onready var leftRay = $LeftRay
onready var middleRay = $MiddleRay

onready var collisionShape = $CollisionShape



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


func _physics_process(delta: float) -> void:


	if (snap):
		if ((location - global_transform.origin).length() > 4):
			snap = false

	if (not snap):
		global_transform.origin = location
		
		var angle = direction.angle()
		rotation.y = angle + deg2rad(-90)
		
		if (leftRay.get_collider() != null):
			if (leftRay.get_collider().is_in_group("Block")):
				global_transform.origin = leftRay.get_collider().global_transform.origin
				snap = true
