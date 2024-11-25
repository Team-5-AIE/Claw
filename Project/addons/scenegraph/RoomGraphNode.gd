@tool
extends Resource
class_name RoomGraphNode

var scenePath : String
var connections : Dictionary # Key: RoomGraphNode | Value: Room Transition Index

func _init(scenePath_ : String) -> void:
	scenePath = scenePath_
