extends Spatial


var weapon = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setWeapon(item):
	if (weapon != null):
		weapon.queue_free()

	var weapon = load("res://Assets/Weapons/"+ item+".tscn").instance()
	add_child(weapon)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
