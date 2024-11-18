extends MarginContainer

@export var mainScreen : Control
@export var scoreboardScreen : Control
@export var creditsScreen : Control
@export var optionsScreen : Control

@export_group("Scores")
@export var highscoreRank : RichTextLabel
@export var highscoreNames : RichTextLabel
@export var highscoreSeparator : RichTextLabel
@export var highscoreTimes : RichTextLabel

var titleScreenActivated = false
var isQuitting = false

func _ready() -> void:
	highscoreRank.text = ""
	highscoreNames.text = ""
	highscoreSeparator.text = ""
	highscoreTimes.text = ""
	
	for i in 5:
		var scoreRank = str(i + 1)
		var scoreSeparator = "|"
		var scoreBlank = "--"
		if i < Global.highscores.size():
			var scoreName = Global.highscores[i][0]
			var scoreString = Global.highscores[i][1]
			
			highscoreRank.text += str(scoreRank, ".\n")
			highscoreNames.text += str(scoreName, "\n")
			highscoreSeparator.text += str(scoreSeparator, "\n")
			highscoreTimes.text += str("[center]", scoreString, "[/center]\n")
		else:
			highscoreRank.text += str(scoreRank, ".\n")
			highscoreNames.text += str("[center]", scoreBlank, "[/center]\n")
			highscoreSeparator.text += str(scoreSeparator, "\n")
			highscoreTimes.text += str("[center]", scoreBlank, "[/center]\n")

func _input(event: InputEvent) -> void:
	if event.is_pressed() and not titleScreenActivated:
		mainScreen.visible = true
		scoreboardScreen.visible = true
		creditsScreen.visible = false

# Credits Buttons
func _on_credits_button_pressed() -> void:
	creditsScreen.visible = true
	scoreboardScreen.visible = false
func _on_credits_return_button_pressed() -> void:
	scoreboardScreen.visible = true
	creditsScreen.visible = false

# Quit Button
func _on_quit_button_pressed() -> void:
	if not isQuitting:
		isQuitting = true
		FadeTransitions.Transition()
		await FadeTransitions.on_fade_in_finished
		get_tree().quit()
