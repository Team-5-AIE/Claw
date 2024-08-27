@tool
extends Resource
class_name RoomGraphNode

@export var scene : PackedScene

var connectionIndices : Array[TravelNode]

func _init(scene_ : PackedScene) -> void:
	scene = scene_
