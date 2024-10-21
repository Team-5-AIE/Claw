extends Area2D

var toggle : bool = false
@onready var sprite: Sprite2D = $Sprite
@onready var time_before_deactivate: Timer = $TimeBeforeDeactivate
@export var doorNode : Node2D
var switchPuzzleFinished : bool = false

func _process(_delta: float) -> void:
	#Check if the door has been opened.
	if !switchPuzzleFinished && doorNode != null:
		if doorNode.doorOpened:
			switchPuzzleFinished = true
			toggle = true
			sprite.frame = 1
			time_before_deactivate.stop()

func _on_body_entered(_body: Node2D) -> void:
	# Return if door has been opened.
	if switchPuzzleFinished:
		return
	# Toggle on the switch and add it to the door.
	toggle = true
	sprite.frame = 1
	time_before_deactivate.start()
	if doorNode != null:
		doorNode.toggledCoins += 1


func _on_time_before_deactivate_timeout() -> void:
	# Toggle off the switch
	toggle = false
	sprite.frame = 0
	if doorNode != null:
		doorNode.toggledCoins -= 1
	
