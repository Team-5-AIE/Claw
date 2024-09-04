extends Control

@export_file("*.tscn") var startGameScene : String

@export var roomLoader : Node2D
@onready var dialogue_manager: Control = $"../CanvasLayer/DialogueManager"
@onready var start_button: Button = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/StartButton


func _on_start_button_pressed():
	start_button.disabled = true
	FadeTransitions.Transition()
	await FadeTransitions.on_fade_in_finished
	var room = roomLoader.LoadRoom(startGameScene)
	room.StartingRoomSetup()
	await FadeTransitions.on_fade_out_finished
	FadeTransitions.lockPlayer = true
	dialogue_manager.AddDialougeTextBox("I have to find the cure...")
	dialogue_manager.AddDialougeTextBox("I know someone here will have some information.\n Just have to find them.")
	
	queue_free()
