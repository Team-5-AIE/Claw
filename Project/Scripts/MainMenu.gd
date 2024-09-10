extends Control

@export_file("*.tscn") var startGameScenePath : String

@export var roomContainer : Node2D
@export var pauseMenu : Node
@export var startButton : Button
@onready var dialogue_manager: Control = $"../CanvasLayer/DialogueManager"
@onready var time_tracker: Control = $"../CanvasLayer/TimeTracker"

func _ready() -> void:	
	pass
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)

func _on_start_button_pressed():
	startButton.disabled = true
	
	FadeTransitions.Transition()
	await FadeTransitions.on_fade_in_finished
	
	var room = roomContainer.LoadRoom(startGameScenePath)
	room.StartingRoomSetup(pauseMenu)
	visible = false
	
	await FadeTransitions.on_fade_out_finished
	FadeTransitions.lockPlayer = true
	dialogue_manager.AddDialougeTextBox("I have to find the cure... for Izumo.")
	dialogue_manager.AddDialougeTextBox("I know someone here has information.\n Just have to find them.")
	time_tracker.StartTimer()
	
	queue_free()
