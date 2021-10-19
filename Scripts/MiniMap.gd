extends MarginContainer


var player = null
onready var playerMarker = $Radar/PlayerMarker

var markers = {} #object, marker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerMarker.position = rect_size / 2
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!player):
		return
	else:
		pass
		var angle = player.getRotation()
		playerMarker.rotation_degrees = -angle
		#print()

	var objs = get_tree().get_nodes_in_group("Resource")
	#print(len(objs))
