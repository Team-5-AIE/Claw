class_name Lock
extends Node

signal activated(switchID)
signal startup_activated(switchID)

@export var lockID : int :
	get:
		return switchID
	set(value):
		switchID = value

var switchID: int 
var keys : Array = []
var open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var has_keys : bool = false
	
	# Add keys to the lock's list
	if not open:
		var keyCount : int = 0
		for child in get_children():
			if child is ObstacleKey:
				has_keys = true
				keys.append(false)
				
				child.keyID = keyCount
				child.key_collected.connect(on_key_collected)
				child.key_reset.connect(on_key_reset)
				keyCount += 1
	else:
		startup_activated.emit(switchID)
		for child in get_children():
			if child is ObstacleKey:
				has_keys = true
				keys.append(true)
				child.delete_key()
	assert(has_keys, "Need keys for this door: " + str(self))

# Adjust array based on keys collected. If there are no more keys, open lock
func on_key_collected(keyID: int):
	keys[keyID] = true
	
	if keys.find(false) == -1 && not open:
		open = true
		activated.emit(switchID)

func on_key_reset(keyID: int):
	keys[keyID] = false
