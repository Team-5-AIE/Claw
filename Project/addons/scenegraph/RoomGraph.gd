@tool
extends Resource
class_name RoomGraph

@export var scenes : Array[PackedScene]

func _init(scenes_ : Array[PackedScene] = []) -> void:
	scenes = scenes_
