extends Control





# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Escape")):
		_on_Main_pressed()


func _on_Main_pressed() -> void:
	get_tree().change_scene("res://Menu.tscn")

