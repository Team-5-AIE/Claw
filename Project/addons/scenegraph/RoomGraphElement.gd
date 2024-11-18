@tool
extends GraphEdit

# ---Variables---
@export_file("*.tscn") var roomGraphNodeElement

@export var fileList : ItemList

var currentRoomGraph : RoomGraph

# ---Functions---
# Godot functions
func _can_drop_data(at_position_ : Vector2, data_ : Variant) -> bool:
	if(data_ is Dictionary and data_.has("files")):
		for file : String in data_.get("files"):
			if (file.get_extension() != "tscn" and file.get_extension() != "scn"):
				return false
	
	return true

func _drop_data(at_position_ : Vector2, data_ : Variant) -> void:
	for file : String in data_.get("files"):
		NewNode(file, at_position_)

# RoomGraph signals
func _on_delete_nodes_request(nodes_ : Array[StringName]):
	# Little weird that they don't just give me an array of node references
	for nodeName in nodes_:
		DeleteNode(get_node(String(nodeName)))

# FileList signals
func _on_file_list_graph_opened():
	if ! visible:
		visible = true
	
	var selectedListItemIndex : int = fileList.get_selected_items()[0]
	var metadata : RoomGraphMetadata = fileList.get_item_metadata(selectedListItemIndex)
	
	currentRoomGraph = metadata.roomGraph

func _on_file_list_graph_closed():
	if visible:
		visible = false

# Custom functions
func UpdateRoomPreview(node_ : GraphNode) -> void:
	var resourcePreviewer = EditorInterface.get_resource_previewer()
	
	resourcePreviewer.queue_resource_preview(node_.get_meta("scenePath", ""), self,
											 "RoomPreviewHandler", node_)

func RoomPreviewHandler(path_: String, preview_ : Texture2D, thumbnail_preview_ : Texture2D,
						userdata_ : Variant):
	var roomPreview : TextureRect = userdata_.get_node("RoomPreview")
	
	roomPreview.texture = preview_

func NewNode(scenePath_ : String, cursorPos_ : Vector2) -> void:
	var newGraphNode : GraphNode = load(roomGraphNodeElement).instantiate()
	add_child(newGraphNode)
	
	newGraphNode.title = scenePath_.get_file().trim_suffix(".tscn").trim_suffix(".scn")
	newGraphNode.position_offset = cursorPos_
	
	newGraphNode.set_meta("scenePath", scenePath_)
	
	UpdateRoomPreview(newGraphNode)

func DeleteNode(node_ : GraphNode) -> void:
	node_.queue_free()
