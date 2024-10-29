class_name Lock
extends LevelActivator

@export var flagID : int :
	get:
		return _flag_ID
	set(value):
		_flag_ID = value

var keys : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	var has_keys : bool = false
	
	# Add keys to the lock's list
	if not is_active:
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
	assert(has_keys, "Need keys for this door: " + str(self))

# Adjust array based on keys collected. If there are no more keys, open lock
func on_key_collected(keyID: int):
	keys[keyID] = true
	
	if keys.find(false) == -1 && not is_active:
		is_active = true

func on_key_reset(keyID: int):
	keys[keyID] = false
