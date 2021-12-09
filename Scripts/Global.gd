extends Node

var valueGenerator = preload("res://Scripts/ValueGenerator.gd").new()

var dropTable = {
	"blurb": [[1, "Health"], [1, "Hammer"], [1, "Club"], [3, ""]],
	"cow": [[1, "Health"], [1, "Logs"], [1, "Stone"], [2, ""]],
	"fish": [[1, "Health"], [1, "Logs"], [4, ""]],
	"squirrel": [[1, "Health"], [1, "Stone"], [2, ""]],
	"troll": [[1, "Spear"], [1, "Hammer"], [1, "Club"], [2, ""]],
	"turtle": [[1, "Health"], [1, "Stone"], [2, ""]],
	"zombie": [[1, "Spear"], [1, "Sword"], [2, ""]]
}
#	"cow": [(1, "Health")]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
