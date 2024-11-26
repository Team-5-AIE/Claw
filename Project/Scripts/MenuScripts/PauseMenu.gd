extends PanelContainer

# ---Variables---
# Resources
@export_file("*.tscn") var mainMenuScenePath : String
var startChapterScenePath : String

# Editor variables
@export var restartButton : Button
@export var shadowShader : ColorRect

var roomContainer : Node2D
var timeTracker : Node
var dialogueManager: Control

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
	if _paused:
		TogglePause()

func _on_retry_button_pressed() -> void:
	if _paused:
		TogglePause()
		player._on_spike_area_body_entered(null)

func _on_restart_button_pressed() -> void:
	if !_paused:
		TogglePause()
	
	inGame = false
	restartButton.disabled = true
	dialogueManager.ClearDialogueBox()
	
	FadeTransitions.Transition()
	await FadeTransitions.on_fade_in_finished
	
	TogglePause()
	AudioManager.play_music(AudioManager.MUSIC_WOLF, 0)
	
	shadowShader.lightingEnabled = false
	
	Global.chapterOneBloomiesThisSession.fill(false)
	if LevelFlags.chapterFlags.size() > 0: LevelFlags.chapterFlags.fill(false)
	
	for room in roomContainer.get_children():
		roomContainer.FreeRoom(room)
	
	player.free()
	
	var room = roomContainer.LoadRoom(startChapterScenePath, timeTracker, self)
	room.StartingRoomSetup()
	visible = false
	
	timeTracker.visible = false
	
	await FadeTransitions.on_fade_out_finished
	FadeTransitions.lockPlayer = true
	dialogueManager.AddDialougeTextBox("I have to find the cure... for Izumo.")
	dialogueManager.AddDialougeTextBox("Someone in town must know about it.\nI better start looking.")
	timeTracker.StartTimer()
	
	restartButton.disabled = false
	inGame = true

func _on_quit_button_pressed() -> void:
	if !_paused:
		TogglePause()
	
	inGame = false
	
	FadeTransitions.Transition()
	await FadeTransitions.on_fade_in_finished
	
	TogglePause()
	
	Global.chapterOneBloomiesThisSession.fill(false)
	if LevelFlags.chapterFlags.size() > 0: LevelFlags.chapterFlags.resize(0)
	get_tree().change_scene_to_file(mainMenuScenePath)
	
	shadowShader.lightingEnabled = false
	
	await FadeTransitions.on_fade_out_finished

# Custom Functions
func TogglePause() -> void:
	if !FadeTransitions.animation_player.is_playing():
		if _paused:
			# Unpause
			_paused = false
			visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
			AudioManager.resume_current_music()
			AudioManager.resume_all_game_sounds()
			get_tree().paused = false
		else:
			# Pause
			_paused = true
			visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			AudioManager.pause_current_music()
			AudioManager.pause_all_game_sounds()
			get_tree().paused = true



func _on_options_button_pressed() -> void:
	$OptionsScreen.is_active = true

func _on_options_return_button_pressed() -> void:
	$OptionsScreen.is_active = false
