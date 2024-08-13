@tool
extends Resource
class_name RoomGraphMetadata

@export var filePath : String
@export var sceneGraph : RoomGraph

func _init(filePath_ : String, sceneGraph_ : RoomGraph = null) -> void:
	filePath = filePath_
	sceneGraph = sceneGraph_
