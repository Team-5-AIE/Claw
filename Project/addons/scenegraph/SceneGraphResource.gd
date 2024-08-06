@tool
extends Resource
class_name SceneGraph

@export var scenes : Array[PackedScene]

func _init(scenes_ : Array[PackedScene] = []) -> void:
	scenes = scenes_
