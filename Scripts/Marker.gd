extends Spatial

enum TYPE {player, enemy, friendly }
export(TYPE) var type = TYPE.enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var instanceMat = get_node("MeshInstance").get_active_material(0).duplicate()

	if (type == TYPE.enemy):
		instanceMat.set_albedo(Color(1,0,0,1))
	elif (type == TYPE.player):
		instanceMat.set_albedo(Color(1,1,1,1))
	elif(type == TYPE.friendly):
		instanceMat.set_albedo(Color(0,0,1,1))

	get_node("MeshInstance").set("material/0", instanceMat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
