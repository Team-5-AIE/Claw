extends PanelContainer

# ---Variables---
# Resources
@export_file("*.tscn") var mainMenuScenePath : String
var startChapterScenePath : String

# Editor variables
@export var restartButton : Button

var roomContainer : Node2D
var timeTracker : Node
var dialogueManager: Control
var bgmPlayer : AudioStreamPlayer

# Member variables
# - Public
var player : SWPlatformerCharacter

var inGame : bool = false
# - Private
var _paused : bool = false

# ---Functions---
# Godot built ins
func _input(event : InputEvent) -> void:
	if inGame and event.is_action_pressed("TogglePause"):
		TogglePause()

# Button signals
func _on_resume_button_pressed() -> void:
	TogglePause()

func _on_retry_button_pressed() -> void:
	TogglePause()
	player._on_spike_area_body_entered(null)

func _on_restart_button_pressed() -> void:
	inGame = false
	restartButton.disabled = true
	bgmPlayer.stop()
	dialogueManager.ClearDialogueBox()
	
	FadeTransitions.Transition()
	await FadeTransitions.on_fade_in_finished
	
	TogglePause()
	
	Global.chapterOneBloomiesThisSession.fill(false)
	
	for room in roomContainer.get_children():
		roomContainer.FreeRoom(room)
	
	player.free()
	
	var room = roomContainer.LoadRoom(startChapterScenePath, timeTracker, self)
	room.StartingRoomSetup()
	visible = false
	bgmPlayer.play()
	
	timeTracker.visible = false
	
	await FadeTransitions.on_fade_out_finished
	FadeTransitions.lockPlayer = true
	dialogueManager.AddDialougeTextBox("I have to find the cure... for Izumo.")
	dialogueManager.AddDialougeTextBox("Someone in town must know about it.\nI better start looking.")
	timeTracker.StartTimer()
	
	restartButton.disabled = false
	inGame = true

func _on_quit_button_pressed() -> void:
	inGame = false
	
	FadeTransitions.Transition()
	await FadeTransitions.on_fade_in_finished
	
	TogglePause()
	
	Global.chapterOneBloomiesThisSession.fill(false)
	get_tree().change_scene_to_file(mainMenuScenePath)
	
	await FadeTransitions.on_fade_out_finished

# Custom Functions
func TogglePause() -> void:
	if _paused:
		# Unpause
		_paused = false
		visible = false
		
		get_tree().paused = false
	else:
		# Pause
		_paused = true
		visible = true
		
		get_tree().paused = true
