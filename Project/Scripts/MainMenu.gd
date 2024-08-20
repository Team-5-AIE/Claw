extends Control

@export var startGameScene : PackedScene

@export var roomManager : Node2D

func _on_start_button_pressed():
	# Spawn player, and give roomManager a reference to them
	# Then, from somewhere, move the player to the spawn point after the level has loaded
	
	var gameScene = startGameScene.instantiate()
	roomManager.add_child(gameScene)
	
	queue_free()
