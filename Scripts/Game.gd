extends Node

"""
TODO:

"""


onready var player = $Player

onready var base = $Hud/Base
onready var stick = $Hud/Stick
var stickMoving = false
const maxStickDelta = 100

var mouseSensitivity = 0.3
var touchSensitivity = 1

var stickTouchIndex = 0
var stickPressed = false

var firstDragIndex = 0
var secondDragIndex = 0
var firstDragPressed = false
var secondDragPressed = false
var firstLocation = Vector2.ZERO
var secondLocation = Vector2.ZERO

onready var hud = $Hud

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  
	#get_node("DayAnimator").play("DayCycle")

	get_node("Hud/MiniMap").player = player

func _process(delta: float) -> void:
	var playerPos = player.translation

	get_node("Terrain").check(playerPos)

	var moveVector = Vector2.ZERO
	if (stickPressed):
		moveVector = (stick.position - base.position) / maxStickDelta
	player.setMoveVector(moveVector)
	
	hud.get_node("HealthBar").setHp(player.hp, player.maxHp)
	
	
	var dayState = get_node("DayAnimator").current_animation_position
	if (dayState > 3 && dayState < 7):
		get_node("Animals").check(delta, playerPos, false)
	else:
		get_node("Animals").check(delta, playerPos, true)
	

func _input(event: InputEvent) -> void:

	if event is InputEventScreenTouch:
		if (event.is_pressed()):
			if ((event.position - base.position).length() < maxStickDelta):
				stickPressed = true
				stickTouchIndex = event.index
			elif (not firstDragPressed):
				firstDragPressed = true
				firstDragIndex = event.index
				firstLocation = event.position
			elif (not secondDragPressed):
				secondDragPressed = true
				secondDragIndex = event.index
				secondLocation = event.position
		else:
			if (event.index == stickTouchIndex):
				stickPressed = false
				stick.position = base.position
			if (event.index == firstDragIndex):
				firstDragPressed = false
			if (event.index == secondDragIndex):
				secondDragPressed = false
	if (event is InputEventScreenDrag):
		if (stickPressed and event.index == stickTouchIndex):
			var stickPos = event.position
			stickPos.x = clamp(stickPos.x ,base.position.x - maxStickDelta, base.position.x + maxStickDelta)
			stickPos.y = clamp(stickPos.y ,base.position.y - maxStickDelta, base.position.y + maxStickDelta)
			stick.position = stickPos
		elif (firstDragPressed and secondDragPressed):
			var distance = (firstLocation - secondLocation).length()
			if (event.index == firstDragIndex):
				firstLocation = event.position
			elif (event.index == secondDragIndex):
				secondLocation = event.position
			var newDistance = (firstLocation - secondLocation).length()
				
			if (distance - newDistance < 0):
				player.zoomIn(0.01 * abs(distance-newDistance))
			elif (distance - newDistance > 0):
				player.zoomOut(0.01 * abs(distance-newDistance))
		else:
			var mouseDelta = event.relative * touchSensitivity
			player.setMouseDelta(mouseDelta)


	if event is InputEventMouseMotion:
		var mouseDelta = event.relative * mouseSensitivity
		player.setMouseDelta(mouseDelta)


	if (event.is_action_pressed("in")):
		player.zoomIn()

	elif (event.is_action_pressed("out")):
		player.zoomOut()
