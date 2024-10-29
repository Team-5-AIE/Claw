class_name LevelActivator
extends Node

signal activated(flagID)
signal deactivated(flagID)

var _flag_ID: int
var is_active : bool :
	get:
		return LevelFlags.chapterFlags[_flag_ID]
	set(value):
		LevelFlags.chapterFlags[_flag_ID] = value
		match(value):
			true:
				activated.emit(_flag_ID)
			false:
				deactivated.emit(_flag_ID)

# Assert that the LevelFlags dict has this flag ID, 
# then send a startup signal based on if is_active is true or false
func _ready() -> void:
	assert(0 <= _flag_ID && _flag_ID < LevelFlags.chapterFlags.size(), 
	str(self) + "is out of bounds of chapterFlags array.")
	
