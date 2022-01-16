extends Control


onready var menuClick = $MenuClick


func _ready() -> void:
	if (OS.get_name() != "Android"):
		for i in get_node("CanvasLayer").get_children():
			if (i is TouchScreenButton):
				i.visible = false

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Escape")):
		_on_Main_pressed()


func _on_Main_pressed() -> void:
	menuClick.play()
	yield(menuClick, "finished")
	get_tree().change_scene("res://Menu.tscn")

