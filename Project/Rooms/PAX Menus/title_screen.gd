extends MarginContainer

@export var chapterScreen : Control
@export var creditsScreen : Control

@export var highscoreNames : RichTextLabel
@export var highscoreTimes : RichTextLabel

func _ready() -> void:
	highscoreNames.text = ""
	highscoreTimes.text = ""
	
	for i in Global.highscores.size():
		var scoreName = Global.highscores[i][0]
		var scoreString = Global.highscores[i][1]
		
		highscoreNames.text += str(i + 1, ". ", scoreName, " \n")
		highscoreTimes.text += str("| ", scoreString, "\n")

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
