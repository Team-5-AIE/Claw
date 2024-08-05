@tool
extends Tree

# ---Signals---
signal graphOpened
signal graphClosed

# ---Variables---
@onready var m_fileDialogue : FileDialog = get_node("FileDialogue")

var m_treeRoot : TreeItem

# ---Functions---
# Godot Functions
func _ready() -> void:
	# Enable mouse interactionsw, like our drag-and-drop
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	m_treeRoot = create_item()
	hide_root = true

func _can_drop_data(at_position : Vector2, data : Variant) -> bool:
	# We expect that the data passed to us from te file system will be of a certain type and format
	# If it's not, we refuse to allow the data to be dropped
	if(data is Dictionary and data.has("files")):
		for file : String in data.get("files"):
			if (file.get_extension() != "tres" and file.get_extension() != "res"):
				return false
			
			if ! load(file) is SceneGraph:
				return false
	
	return true

func _drop_data(at_position : Vector2, data : Variant) -> void:
	# Drop data can contain multiple files. We've previously made sure that
	# all of these files are .tscn files
	for file : String in data.get("files"):
		# To avoid duplicates, we check all of our currently loaded files
		# against whatever files we're importing
		var existingTreeItem : TreeItem = null
		for item : TreeItem in m_treeRoot.get_children():
			# Metadata is expected to be a string containing the full path of the file
			var metadata : SceneGraphMetadata = item.get_metadata(0)
			if metadata.filePath == file:
				existingTreeItem = item
				break
		
		# If the file already exists as a treeItem, simply select and open it
		if existingTreeItem:
			SelectGraph(existingTreeItem)
			OpenGraph(existingTreeItem)
		else:
			var newTreeItem = AddGraphToTree(file)
			SelectGraph(newTreeItem)
			OpenGraph(newTreeItem)

func _on_item_activated() -> void:
	var activatedItem : TreeItem = get_selected()
	OpenGraph(activatedItem)

# FileMenu signals
func _on_new_graph():
	var newGraph : SceneGraph = MakeNewGraph()
	var newTreeItem : TreeItem = AddGraphToTree("", newGraph)
	newTreeItem.set_text(0, "[New Graph]")
	SelectGraph(newTreeItem)
	OpenGraph(newTreeItem)

func _on_load_graph():
	m_fileDialogue.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	m_fileDialogue.visible = true

func _on_save_graph():
	var selectedTreeItem : TreeItem = get_selected()
	var metadata : SceneGraphMetadata = selectedTreeItem.get_metadata(0)
	
	if metadata.sceneGraph.resource_path == "":
		_on_save_graph_as()
	else:
		ResourceSaver.save(metadata.sceneGraph, metadata.sceneGraph.resource_path)

func _on_save_graph_as():
	m_fileDialogue.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	m_fileDialogue.visible = true

func _on_close_graph():
	var selectedTreeItem : TreeItem = get_selected()
	CloseGraph(selectedTreeItem)

# FileDialogue signals
# This function will only be triggered by a dialogue in FILE_MODE_SAVE_FILE mode
func _on_file_selected(path):
	var selectedTreeItem : TreeItem = get_selected()
	var metadata : SceneGraphMetadata = selectedTreeItem.get_metadata(0)
	
	ResourceSaver.save(metadata.sceneGraph, path, ResourceSaver.FLAG_CHANGE_PATH)

# This function will only be triggered by a dialogue in FILE_MODE_OPEN_FILES mode
func _on_files_selected(paths):
	# Modified from _drop_data
	for file : String in paths:
		var existingTreeItem : TreeItem = null
		for item : TreeItem in m_treeRoot.get_children():
			# Metadata is expected to be a string containing the full path of the file
			var metadata : SceneGraphMetadata = item.get_metadata(0)
			if metadata.filePath == file:
				existingTreeItem = item
				break
		
		# If the file already exists as a treeItem, simply select and open it
		if existingTreeItem:
			SelectGraph(existingTreeItem)
			OpenGraph(existingTreeItem)
		else:
			var newTreeItem = AddGraphToTree(file)
			SelectGraph(newTreeItem)
			OpenGraph(newTreeItem)

# Custom Functions
func MakeNewGraph(scenes_ : Array[PackedScene] = []) -> SceneGraph:
	return SceneGraph.new(scenes_)

func AddGraphToTree(filePath_ : String = "", graph_ : SceneGraph = null) -> TreeItem:
	assert(filePath_ != "" || graph_ != null)
	
	var treeFile = create_item(m_treeRoot)
	
	var metadata : SceneGraphMetadata = SceneGraphMetadata.new(filePath_, graph_)
	treeFile.set_metadata(0, metadata)
	
	treeFile.set_tooltip_text(0, filePath_)
	treeFile.set_text(0, filePath_.get_file())
	
	return treeFile

func SelectGraph(sceneItem_ : TreeItem) -> void:
	sceneItem_.select(0)

func OpenGraph(sceneItem_ : TreeItem) -> void:
	graphOpened.emit()
	
	var metadata : SceneGraphMetadata = sceneItem_.get_metadata(0)
	if metadata.sceneGraph == null:
		metadata.sceneGraph = load(metadata.filePath)
	sceneItem_.set_metadata(0, metadata);

func CloseGraph(sceneItem_ : TreeItem) -> void:
	graphClosed.emit()
	
	m_treeRoot.remove_child(sceneItem_)
	sceneItem_.free()
