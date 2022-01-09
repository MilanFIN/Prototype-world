extends "res://Scripts/Block.gd"




onready var placedOpen = $PlacedOpen
onready var collider = $CollisionShape

func _process(delta: float) -> void:
	hp += delta
	if (hp > maxHp):
		hp = maxHp*3

func damage(amount):
	hp -= 3
	if (hp <= 0):
		dead = true
		hitParticles.emitting = true
		for i in (get_children()):
			if i is CollisionShape:
				i.disabled = true
			if i is MeshInstance:
				i.visible = false
			if i is CPUParticles:
				i.emitting = true
	else:
		if (placedMesh.visible):
			placedMesh.visible = false
			placedOpen.visible = true
			set_collision_mask_bit(0, false)
		else:
			placedMesh.visible = true
			placedOpen.visible = false
			set_collision_mask_bit(0, true)
