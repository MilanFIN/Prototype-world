extends Node

"""
TODO:
2 kättä, molempiin mahtuu talteen item

interpolate_with kun muuttaa velocityn x ja z komponentteja
	
"""



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	var playerPos = get_node("Player").translation

	get_node("Terrain").check(playerPos)
	


	#if (delta >= 0.017):
	#	print("SLOW!: ", delta)
