extends Node

"""
TODO:
androidilla kaatuu koko homma jos palauttaa staticobj outputtina


"""


onready var player = $Player

onready var base = $Hud/Base
onready var stick = $Hud/Stick
var stickMoving = false
const maxStickDelta = 100

var mouseSensitivity = 10
var touchSensitivity = 50

var stickTouchIndex = 0
var stickPressed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  
	pass

func _process(delta: float) -> void:
	var playerPos = player.translation

	get_node("Terrain").check(playerPos)
	get_node("Animals").check(playerPos)
	#if (delta >= 0.017):
	#	print("SLOW!: ", delta)
	
	#if (not stickMoving):
	#	stick.position = base.position
	#stickMoving = false
	
	if (stickPressed):
		var moveVector = (stick.position - base.position) / maxStickDelta
		player.setMoveVector(moveVector)
	
func _input(event: InputEvent) -> void:

	if event is InputEventScreenTouch:
		if (event.is_pressed()):
			if ((event.position - base.position).length() < maxStickDelta):
				stickPressed = true
				stickTouchIndex = event.index
		else:
			if (event.index == stickTouchIndex):
				stickPressed = false
				stick.position = base.position
	if (stickPressed and event is InputEventScreenDrag):
		if (event.index == stickTouchIndex):
			var stickPos = event.position
			stickPos.x = clamp(stickPos.x ,base.position.x - maxStickDelta, base.position.x + maxStickDelta)
			stickPos.y = clamp(stickPos.y ,base.position.y - maxStickDelta, base.position.y + maxStickDelta)
			stick.position = stickPos


	if event is InputEventMouseMotion:
		var mouseDelta = event.relative * mouseSensitivity
		player.setMouseDelta(mouseDelta)

