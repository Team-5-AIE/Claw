extends Node

var chapterOneFlagCount: int = 32
# Chapter specific flag counts as separate vars, 
# with some functionality to choose which one to use when creating chapter array

var chapterFlags: Array[bool]

# Update based on
func _ready() -> void:
	_create_flag_array(chapterOneFlagCount)

# Create chapter flag array of specified size and fill it with false flags
func _create_flag_array(flag_count: int) -> void:
	chapterFlags.resize(flag_count)
	chapterFlags.fill(false)
