extends Spatial


var weapon = null
const DEFATTACKDELAY = 333
const DEFDAMAGE = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setWeapon(item):
	if (weapon != null):
		weapon.queue_free()

	weapon = load("res://Assets/Weapons/"+ item+".tscn").instance()
	add_child(weapon)

func getAttackDelay():
	if (weapon != null):
		return weapon.attackDelay
	else:
		return DEFATTACKDELAY
func getDamage():
	if (weapon != null):
		return weapon.damage
	else:
		return DEFDAMAGE

