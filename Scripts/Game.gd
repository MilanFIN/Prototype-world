extends Node

"""
#TODO !!!!!
#change maketree to use x,z 
#also change all random calls to use xz and
#the optional parameter when needed (loops)
!!!!!
"""


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	var playerPos = get_node("Player").translation
	if (playerPos.y < 0):
		get_node("WaterMirage").visible = false
	else:
		get_node("WaterMirage").visible = false
	get_node("Terrain").check(playerPos)

	#if (delta >= 0.017):
	#	print("SLOW!: ", delta)
