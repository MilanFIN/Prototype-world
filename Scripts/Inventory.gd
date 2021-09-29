extends Spatial


var item = null
var placeMode = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setItem(i):
	item = load("res://Assets/Items/"+ i+".tscn").instance()
	print(item)
	add_child(item)

func cyclePlace():
	if (item != null):
		placeMode = ! placeMode
	else:
		placeMode = false
	print(placeMode)
