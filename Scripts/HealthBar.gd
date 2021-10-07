extends Sprite


var textureSize = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	region_enabled = true
	textureSize = texture.get_size()
	
	region_rect = Rect2(0,0, textureSize.x, textureSize.y)

	pass # Replace with function body.

func setHp(c, m): #current, max
	var ratio = float(c) / m
	
	region_rect = Rect2(0,0, int(textureSize.x*ratio), textureSize.y)

