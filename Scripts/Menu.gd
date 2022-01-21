extends Control

onready var menuClick = $MenuClick

func _ready() -> void:
	if (OS.get_name() != "Android"):
		for i in get_node("CanvasLayer").get_children():
			if (i is TouchScreenButton):
				i.visible = false
	else:
		pass
		#get_node("CanvasLayer/ControlLabel").visible = false



func _on_Begin_pressed() -> void:

	menuClick.play()
	yield(menuClick, "finished")
	get_tree().change_scene("res://Game.tscn")



func _on_License_notice_pressed() -> void:

	menuClick.play()
	yield(menuClick, "finished")
	get_tree().change_scene("res://Licenses.tscn")



func _on_Exit_pressed() -> void:
	menuClick.play()
	yield(menuClick, "finished")
	get_tree().quit()


func _on_Shadows_toggled(button_pressed: bool) -> void:
	Global.shadows = button_pressed


	pass # Replace with function body.


func _on_TouchScreenButton4_pressed() -> void:
	Global.shadows = !Global.shadows
	get_node("CanvasLayer/Shadows").pressed = Global.shadows
	pass # Replace with function body.
