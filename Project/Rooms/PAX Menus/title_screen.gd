extends MarginContainer

@export var chapterScreen : Control
@export var creditsScreen : Control

@export var highscoreRank : RichTextLabel
@export var highscoreNames : RichTextLabel
@export var highscoreSeparator : RichTextLabel
@export var highscoreTimes : RichTextLabel

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
	if self.visible == true and event.is_pressed():
		chapterScreen.visible = true
		self.visible = false

func _on_credits_button_pressed() -> void:
	creditsScreen.visible = true
	chapterScreen.visible = false

func _on_credits_return_button_pressed() -> void:
	chapterScreen.visible = true
	creditsScreen.visible = false
