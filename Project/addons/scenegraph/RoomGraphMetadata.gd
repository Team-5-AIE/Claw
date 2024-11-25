@tool
extends Resource
class_name RoomGraphMetadata

@export var filePath : String
@export var roomGraph : RoomGraph

func _init(filePath_ : String = "", roomGraph_ : RoomGraph = null) -> void:
	filePath = filePath_
	roomGraph = roomGraph_
