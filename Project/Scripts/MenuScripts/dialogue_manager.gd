extends Control

@onready var textSpeedTimer: Timer = $TextSpeedTimer
@onready var textLabel: Label = $Text
var textQueue : Array = []

var textAsPart : String = ""
func _ready():
	HideDialouge()


func _process(_delta):
	if textQueue.size() > 0: #there is text queued
		if textQueue[0].length() != textAsPart.length(): #we haven't written all the text yet
			
			UpdateText()
			ShowDialouge()
			return
		if Input.is_action_just_pressed("Confirm"): # Show next queued text
			ResetDialougeBox()

func UpdateText() -> void:
	if textSpeedTimer.time_left <= 0.0:
		var textLength = textQueue[0].length()
		for s in textLength:
			if s == textAsPart.length():
				textAsPart = textAsPart + textQueue[0][s]
				textSpeedTimer.start()
				textLabel.text = textAsPart
				return
				
func AddDialougeTextBox(newText : String = ""):
	textQueue.append(newText)

func HideDialouge() -> void:
	visible = false
	FadeTransitions.lockPlayer = false
	
func ShowDialouge() -> void:
	if !visible:
		visible = true
		FadeTransitions.lockPlayer = true

func ResetDialougeBox():
	textAsPart = ""
	if textQueue.size() > 0:
		textQueue.pop_front()
	if textQueue.size() == 0:
		HideDialouge()

func ClearDialogueBox():
	textAsPart = ""
	
	if textQueue.size() > 0:
		textQueue.clear()
	
	HideDialouge()
