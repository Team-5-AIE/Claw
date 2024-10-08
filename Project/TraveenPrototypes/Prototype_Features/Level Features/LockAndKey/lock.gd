class_name Lock
extends Node

signal unlocked()

@export var lockID: int = 0
@export var door_collision: Node

var keys : Array = []
var open: bool = false
var is_unique: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var has_keys : bool = false
	
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
		for child in get_children():
			if child is ObstacleKey:
				has_keys = true
				keys.append(true)
				child.delete_key()
			elif child == door_collision:
				door_collision.queue_free()
	assert(has_keys, "Need keys for this door: " + str(self))

func on_key_collected(keyID: int):
	keys[keyID] = true
	
	if keys.find(false) == -1 && not open:
		open = true
		unlocked.emit()

func on_key_reset(keyID: int):
	keys[keyID] = false
