extends Control

@export_file("*.tscn") var startGameScene : String

@export var roomLoader : Node2D

func _on_start_button_pressed():
	var room = roomLoader.LoadRoom(startGameScene)
	room.call_deferred("StartingRoomSetup")
	
	queue_free()
