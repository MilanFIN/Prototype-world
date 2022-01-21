extends Node



onready var player = $Player

onready var base = $Android/Base
onready var stick = $Android/Stick
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
onready var androidHud = $Android
onready var skipNightButton = $Android/SkipNight

var gameOver = false

var score = 0
var previousWasDay = true

var initialized = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if (OS.get_name() == "Android"):
		androidHud.visible = true
	else:
		androidHud.visible = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  



	get_node("Hud/MiniMap").player = player
	

	get_node("DirectionalLight").shadow_enabled = Global.shadows




func _process(delta: float) -> void:
	
	#if (player.initialized and !initialized):
	#	get_node("DayAnimator").play("DayCycle")
	#	initialized = true
	
	if (!initialized):
		$Hud/LoadingScreen.visible = true
		
		var loadStage = get_node("Terrain").getProgress()
		$Hud/LoadingScreen/LoadingText.text = "Generating a new world... " + str(int(loadStage)) + "%"
		if (loadStage == 100):
			get_node("DayAnimator").play("DayCycle")

			initialized = true
	else:
		$Hud/LoadingScreen.visible = false

	var playerPos = player.translation

	get_node("Terrain").check(playerPos)

	var moveVector = Vector2.ZERO
	if (stickPressed):
		moveVector = (stick.position - base.position) / maxStickDelta
	player.setMoveVector(moveVector)
	
	hud.get_node("HealthBar").setHp(player.hp, player.maxHp)
	
	
	var dayState = get_node("DayAnimator").current_animation_position
	var day = true
	if (dayState > 3 && dayState < 7):
		day = false
	

	get_node("Animals").check(delta, playerPos, day)
	
	
	if (!previousWasDay and day):
		score += 1

	previousWasDay = day
	
	if (day and skipNightButton.visible):
		skipNightButton.visible = false
	elif (!day and !skipNightButton.visible):
		skipNightButton.visible = true

	if (!day and player.inRoom):
		$Hud/SkipLabel.visible = true
		$Android/SkipNight.visible = true
	else:
		$Hud/SkipLabel.visible = false
		$Android/SkipNight.visible = false

	if (player.blockInventory.item != null):
		$Android/Place.visible = true
		if (player.blockInventory.placeMode):
			$Android/Toggle.visible = true
		else:
			$Android/Toggle.visible = false
	else:
		$Android/Place.visible = false
		$Android/Toggle.visible = false
	

	if (Input.is_action_just_pressed("SkipNight")):

		if (!day and player.inRoom):
			print("skip")
			get_node("DayAnimator").seek(7.0)
		
	if (Input.is_action_just_pressed("Escape")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  
		for i in get_children():
			i.queue_free()
		get_tree().change_scene("res://Menu.tscn")

	if (!gameOver):

		if (player.hp <= 0):

			gameOver = true
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  
			get_node("Hud/DeathNote").setScore(score)
			get_node("Hud/DeathNote").visible = true
			yield(get_tree().create_timer(3.0), "timeout")
			
			get_tree().paused = false
			for i in get_children():

				i.queue_free()
			get_tree().change_scene("res://Menu.tscn")

			#get_tree().paused = false


			
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


