extends PanelContainer

# ---Variables---
# Resources
@export_file("*.tscn") var mainMenuScenePath : String

# Member variables
# - Public
var player : SWPlatformerCharacter
# - Private
var _paused : bool = false

# ---Functions---
# Godot built ins
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("TogglePause"):
		TogglePause()

# Button signals
func _on_resume_button_pressed() -> void:
	TogglePause()

func _on_retry_button_pressed() -> void:
	TogglePause()
	player._on_spike_area_body_entered(null)

func _on_quit_button_pressed() -> void:	
	FadeTransitions.Transition()
	await FadeTransitions.on_fade_in_finished
	
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
