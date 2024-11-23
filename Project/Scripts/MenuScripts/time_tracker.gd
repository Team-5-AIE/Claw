extends Control
class_name TimeTracker
@onready var label: Label = $Label

var currentTime: float = 0
var currentTimeString : String = "" #This can be saved into the Json files emma is working on for display.

var hours : int = 0
var minutes : int = 0
var seconds : int = 0
var wholeTime : int = 0 #Used for easier sorting.

func _ready() -> void:
	visible = false
	UpdateText()

func _process(delta: float) -> void:
	if visible && not FadeTransitions.lockPlayer:
		currentTime += delta
		wholeTime = int(floor(currentTime))
		seconds = int(floor(currentTime)) % 60
		minutes = int(floor(currentTime/60)) % 60
		hours = int(floor(currentTime/3600))
		UpdateText()

func UpdateText() -> void:
	var secondsStr = "0" if seconds < 10 else ""
	secondsStr += str(seconds)
	
	var minutesStr = "0" if minutes < 10 else ""
	minutesStr += str(minutes)
	
	var hoursStr = ""
	if hours >= 10:
		hoursStr = str(hours)
		currentTimeString = str(hoursStr, ":", minutesStr,":",secondsStr)
	elif hours >= 1:
		hoursStr = "0" + str(hours)
		currentTimeString = str(hoursStr, ":", minutesStr,":",secondsStr)
	else:
		currentTimeString = str(minutesStr,":",secondsStr)
	label.text = currentTimeString

func StartTimer():
	currentTimeString = ""
	currentTime = 0
	wholeTime = 0
	seconds = 0
	minutes = 0
	hours = 0
	visible = true

func StopTimerAddToLastScore() -> void: #Call when level is finished.
	visible = false
	#NOTE: change the "Name" to be whatever the player types.
	Global.lastScore = ["Name",currentTimeString,wholeTime]
