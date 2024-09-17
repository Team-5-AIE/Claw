@tool
extends GraphEdit

# ---Variables---
@export var m_fileList : ItemList

var m_currentRoomGraph : RoomGraph

# ---Functions---
# Godot functions
func _can_drop_data(at_position : Vector2, data : Variant) -> bool:
	if(data is Dictionary and data.has("files")):
		for file : String in data.get("files"):
			if (file.get_extension() != "tscn" and file.get_extension() != "scn"):
				return false
	
	return true

func _drop_data(at_position : Vector2, data : Variant) -> void:
	for file : String in data.get("files"):
		var globalCursorPos : Vector2 = global_position + at_position
		
		CreateNewNode(file, at_position)

# RoomGraph signals
func _on_delete_nodes_request(nodes_ : Array[StringName]):
	# Little weird that they don't just give me an array of node references
	for nodeName in nodes_:
		DeleteNode(get_node(String(nodeName)))

# FileList signals
func _on_file_list_graph_opened():
	if ! visible:
		visible = true
	
	var selectedListItemIndex : int = m_fileList.get_selected_items()[0]
	var metadata : RoomGraphMetadata = m_fileList.get_item_metadata(selectedListItemIndex)
	
	m_currentRoomGraph = metadata.roomGraph

func _on_file_list_graph_closed():
	if visible:
		visible = false

# Custom functions
func CreateNewNode(scenePath_ : String, cursorPos_ : Vector2):
	var newGraphNode : GraphNode = GraphNode.new()
	add_child(newGraphNode)
	
	newGraphNode.title = scenePath_.get_file().trim_suffix(".tscn").trim_suffix(".scn")
	newGraphNode.position_offset = cursorPos_

func DeleteNode(node : GraphNode):
	node.queue_free()
