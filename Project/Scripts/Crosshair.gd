extends Node

@export var radius = 50
@onready var crosshair = $"."
var player: CharacterBody2D
var mousePos
var isMouseUsed: bool = true
@export var joyPadSpeed: float = 2

func _ready() -> void:
	self.visible = false
	Global.connect("playerCreated", _player_created)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		
		
		if player == null:
			return
		
		isMouseUsed = false
	
	elif event is InputEventMouseMotion:
		isMouseUsed = true

func _player_created():
	self.visible = true
	player = get_parent().get_child(6)
	print (player)

func _process(delta: float) -> void:
	if isMouseUsed == true:
		mousePos = crosshair.get_global_mouse_position()
		crosshair.global_position = mousePos
	else:
		var joyX: int
		var joyY: int
		
		if Input.is_action_pressed("Aim Down"):
			joyY = joyPadSpeed
		elif Input.is_action_pressed("Aim Up"):
			joyY = -joyPadSpeed
		if Input.is_action_pressed("Aim Right"):
			joyX = joyPadSpeed
		elif Input.is_action_pressed("Aim Left"):
			joyX = -joyPadSpeed
		
		var getJoyAxis = Vector2(joyX,joyY)
		crosshair.global_position += getJoyAxis
		
		var newPos = get_viewport().get_screen_transform() * crosshair.get_global_transform_with_canvas() * getJoyAxis
		Input.warp_mouse(newPos)
		
		#mousePos = crosshair.get_global_mouse_position()
		#var playerPos = player.global_position
		#var distance = playerPos.distance_to(mousePos)
		#var mouseDir = (mousePos-playerPos).normalized()
		#
		#if distance > radius:
			#mousePos = playerPos + (mouseDir * radius)
		#
		#crosshair.global_position = mousePos
