extends Control

@export_file("*.tscn") var startChapterScenePath : String

@export var startButton : Button

@export var roomContainer : Node2D
@export var pauseMenu : Node
@export var timeTracker : Control
@export var dialogueManager : Control
@export var bgmPlayer : AudioStreamPlayer
@onready var bloomieDisplay: Control = $"../CanvasLayer/BloomieDisplay"

func _ready() -> void:
	pauseMenu.startChapterScenePath = startChapterScenePath
	pauseMenu.roomContainer = roomContainer
	pauseMenu.timeTracker = timeTracker
	pauseMenu.dialogueManager = dialogueManager
	pauseMenu.bgmPlayer = bgmPlayer
	
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)

func _on_start_button_pressed():
	startButton.disabled = true
	
	FadeTransitions.Transition()
	await FadeTransitions.on_fade_in_finished
	
	var room = roomContainer.LoadRoom(startChapterScenePath, timeTracker, pauseMenu)
	room.StartingRoomSetup()
	visible = false
	GlobalWorldEnvironment.StartLevel()
	await FadeTransitions.on_fade_out_finished
	FadeTransitions.lockPlayer = true
	dialogueManager.AddDialougeTextBox("I have to find the cure... for Izumo.")
	dialogueManager.AddDialougeTextBox("Someone in town must know about it.\nI better start looking.")
	bloomieDisplay.visible = true
	timeTracker.StartTimer()
	
	
	queue_free()
