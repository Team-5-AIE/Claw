class_name LevelActivator
extends Node

signal activated(flagID)
signal deactivated(flagID)

signal startup_activated(flagID)
signal startup_deactivated(flagID)

var _flag_ID: int
var is_active : bool :
	get:
		return is_active
	set(value):
		is_active = value
		# Update Global dict with new value
		match(value):
			true:
				activated.emit(_flag_ID)
			false:
				deactivated.emit(_flag_ID)

# _ready: Assert that the Global dict has this flag ID, then ask for the flag's state
