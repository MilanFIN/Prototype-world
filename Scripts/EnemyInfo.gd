extends Spatial



onready var healthBar = $HealthBar
var enemyName = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#var camera = get_viewport().get_camera()
	#var point = camera.global_transform.origin
	#look_at(point, Vector3.DOWN)
	#look_at(Vector3(point.x, plane.transform.y, point.z), Vector3.DOWN)
func setInfo(n, level):
	enemyName = n
	get_node("LevelViewPort/Label").text = enemyName + "\n" \
												+ "Level " + str(level)

func setHp(hp, maxHp):
	var fraction = float(hp)/maxHp
	var green = get_node("HealthViewPort/Green")
	var red = get_node("HealthViewPort/Red")
	var maxWidth = red.rect_size.x
	green.rect_size.x = maxWidth * fraction

func setLevel(level):
	setInfo(name, level)
