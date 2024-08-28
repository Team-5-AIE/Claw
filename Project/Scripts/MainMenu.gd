extends Control

@export_file("*.tscn") var startGameScene : String

@export var roomLoader : Node2D

func _on_start_button_pressed():
	roomLoader.LoadRoom(startGameScene)
	
	queue_free()
