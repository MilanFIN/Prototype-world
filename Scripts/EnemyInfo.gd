extends Spatial



onready var healthBar = $HealthBar



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	var camera = get_viewport().get_camera()
	var point = camera.global_transform.origin
	#point.y *= -1
	#healthBar.look_at(Vector3(point.x, point.y, point.z), Vector3.UP)
	#look_at(point, Vector3.DOWN)


		#look_at(Vector3(point.x, plane.transform.y, point.z), Vector3.DOWN)
