@tool
extends Resource
class_name RoomGraph

var m_rootNode : RoomGraphNode = null

func _init(scene_ : String = "") -> void:
	if scene_ != "":
		m_rootNode = RoomGraphNode.new(scene_)
