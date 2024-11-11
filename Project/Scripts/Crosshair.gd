extends Node

@export var radius = 50
@onready var crosshair = $"."
var player: CharacterBody2D
var mousePos

func _ready() -> void:
	Global.connect("playerCreated", _player_created)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		
		if player == null:
			return
		
		mousePos = crosshair.get_global_mouse_position()
		var playerPos = player.global_position
		var distance = playerPos.distance_to(mousePos)
		var mouseDir = (mousePos-playerPos).normalized()
		
		if distance > radius:
			mousePos = playerPos + (mouseDir * radius)
		
		crosshair.offset.y = -20
		crosshair.global_position = mousePos
		
		

	elif event is InputEventMouseMotion:
		mousePos = crosshair.get_global_mouse_position()
		crosshair.offset.y = 0
		crosshair.global_position = mousePos

func _player_created():
	player = get_parent().get_child(6)
	print (player)
