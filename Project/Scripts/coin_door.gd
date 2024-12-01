extends Node2D

@export var coinsNeeded : int = 3
var toggledCoins : int = 0
@onready var sprite: Sprite2D = $CoinDoor
var doorOpened : bool = false


#this is a temporary value 
var startPos : Vector2 = Vector2.ZERO
@onready var label: Label = $Label

func _ready() -> void:
	startPos = global_position

func _process(_delta: float) -> void:
	label.text = str(toggledCoins) + "/" + str(coinsNeeded)
	if toggledCoins == coinsNeeded && !doorOpened:
		AudioManager.play_modulated_game_sound(AudioManager.DOOR1, -5)
		doorOpened = true
		sprite.frame = 1
		
	#This is temporary to just move the door when opened. will talk to Traveen about how she wants this to act
	if doorOpened:
		global_position.y -= 1 
		if startPos.distance_to(global_position) >= 50:
			queue_free()
