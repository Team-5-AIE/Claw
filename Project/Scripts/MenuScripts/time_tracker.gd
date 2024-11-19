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
	currentTime += delta
	wholeTime = floor(currentTime)
	seconds = floor(currentTime) % 60
	minutes = floor(currentTime/60)
	hours = floor(currentTime/3600)
	UpdateText()

func UpdateText() -> void:
	var secondsStr = "0" if seconds < 10 else ""
	secondsStr += str(seconds)
	
	var minutesStr = "0" if minutes < 10 else ""
	minutesStr += str(minutes % 60)
	
	var hoursStr = ""
	if hours >= 10:
		hoursStr = str(hours)
		currentTimeString = str(hours, ":", minutesStr,":",secondsStr)
	elif hours >= 1:
		hoursStr = "0" + str(hours)
		currentTimeString = str(hours, ":", minutesStr,":",secondsStr)
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
	Global.lastScore = ["Name",str(minutes,":",seconds),wholeTime]
