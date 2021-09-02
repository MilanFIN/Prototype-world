extends Node

var blob = preload("res://Assets/Objects/DynamicObject.tscn")
var animals = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	for i in range(100):
		var x = randi()%51+1 - 25
		var z = randi()%51+1 - 25
		var newAnim = blob.instance()
		newAnim.global_transform.origin = Vector3(x,20,z)
		add_child(newAnim)
		animals.push_back(newAnim)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
