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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	var playerPos = player.translation

	get_node("Terrain").check(playerPos)
	get_node("Animals").check(playerPos)
	#if (delta >= 0.017):
	#	print("SLOW!: ", delta)
	if (not stickMoving):
		stick.position = base.position
	
	stickMoving = false
	
func _input(event: InputEvent) -> void:

	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if ((event.position - base.position).length() < maxStickDelta):
			stickMoving = true
			stick.position = event.position
			var moveVector = (event.position - base.position) / maxStickDelta
			player.setMoveVector(moveVector)

		elif (event is InputEventScreenDrag):
			var mouseDelta = event.relative * touchSensitivity
			player.setMouseDelta(mouseDelta)
	if event is InputEventMouseMotion:
		var mouseDelta = event.relative * mouseSensitivity
		player.setMouseDelta(mouseDelta)
