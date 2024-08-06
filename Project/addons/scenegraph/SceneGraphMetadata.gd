@tool
extends Resource
class_name SceneGraphMetadata

@export var filePath : String
@export var sceneGraph : SceneGraph

func _init(filePath_ : String, sceneGraph_ : SceneGraph = null) -> void:
	filePath = filePath_
	sceneGraph = sceneGraph_
