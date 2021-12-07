extends Node

var valueGenerator = preload("res://Scripts/ValueGenerator.gd").new()

var dropTable = {
	"blurb": [],
	"cow": [[1, "Health"], [1, "Hammer"]],
	"fish": [],
	"squirrel": [],
	"troll": [],
	"turtle": [],
	"zombie": []
}
#	"cow": [(1, "Health")]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
