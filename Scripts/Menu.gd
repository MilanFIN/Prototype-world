extends Control

onready var menuClick = $MenuClick





func _on_Begin_pressed() -> void:

	menuClick.play()
	yield(menuClick, "finished")
	get_tree().change_scene("res://Game.tscn")



func _on_License_notice_pressed() -> void:

	menuClick.play()
	yield(menuClick, "finished")
	get_tree().change_scene("res://Licenses.tscn")

