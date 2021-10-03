extends Spatial


var item = null
var block = null
var placeMode = false

onready var blockPreview = $BlockPreview
onready var itemHolder = $ItemHolder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#load a new item
func setItem(i):
	item = load("res://Assets/Items/"+ i+".tscn").instance()

	itemHolder.add_child(item)

func placeItem():
	
	if (block.place()):
		blockPreview.remove_child(block)
		var placedBlock = block
		block = null
		placeMode = false
		return placedBlock
	else:
		return null

func cyclePlace():
	if (item != null):
		placeMode = ! placeMode
	else:
		placeMode = false

	if (not placeMode):
		for i in blockPreview.get_children():
			blockPreview.remove_child(i)
		block = null

	if (placeMode):
		block = load("res://Assets/Blocks/"+ item.block+".tscn").instance()
		blockPreview.add_child(block)

func setDirection(dir, location):
	if (placeMode):
		block.preview(dir, location)


	
	
