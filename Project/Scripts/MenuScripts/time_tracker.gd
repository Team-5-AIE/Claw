extends Control

@onready var label: Label = $Label
@onready var seconds_timer: Timer = $SecondsTimer
@onready var minutes_timer: Timer = $MinutesTimer

var minutes : int = 0
var seconds : int = 0
var currentTimeString : String = "" #This can be saved into the Json files emma is working on for display.


func _ready() -> void:
	visible = false
	UpdateText()

func _process(delta: float) -> void:
	UpdateText()

func UpdateText() -> void:
	var secondsStr = str(seconds)
	if seconds < 10:
		secondsStr = "0" + str(seconds)
	currentTimeString = str(minutes,":",secondsStr)
	label.text = currentTimeString

func StartTimer():
	seconds_timer.start()
	minutes_timer.start()
	visible = true

func _on_seconds_timer_timeout() -> void:
	seconds += 1
	seconds_timer.start()

func _on_minutes_timer_timeout() -> void:
	minutes += 1
	minutes_timer.start()