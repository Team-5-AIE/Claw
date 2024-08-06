@tool
extends ItemList

# ---Signals---
signal graphOpened
signal graphClosed

# ---Variables---
var m_loadFileDialogue : EditorFileDialog
var m_saveFileDialogue : EditorFileDialog

# ---Functions---
# Godot Functions
func _ready() -> void:
	# Enable mouse interactionsw, like our drag-and-drop
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	var commonFileDialogue : EditorFileDialog = EditorFileDialog.new()
	commonFileDialogue.add_filter("*.tres", "Text Resource Files")
	commonFileDialogue.add_filter("*.res", "Resource Files")
	commonFileDialogue.display_mode = EditorFileDialog.DISPLAY_LIST
	commonFileDialogue.dialog_hide_on_ok = true
	commonFileDialogue.dialog_close_on_escape = false
	commonFileDialogue.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	commonFileDialogue.size = Vector2i(600, 400)
	
	m_loadFileDialogue = commonFileDialogue.duplicate()
	m_loadFileDialogue.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILES
	m_loadFileDialogue.ok_button_text = "Load"
	m_loadFileDialogue.files_selected.connect(_on_load_file_dialogue_files_selected)
	
	m_saveFileDialogue = commonFileDialogue.duplicate()
	m_saveFileDialogue.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	m_saveFileDialogue.ok_button_text = "Save"
	m_saveFileDialogue.file_selected.connect(_on_save_file_dialogue_file_selected)
	
	commonFileDialogue.free()
	
	add_child(m_loadFileDialogue)
	add_child(m_saveFileDialogue)

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
		var existingItemIndex : int = -1
		for i : int in item_count:
			# Metadata is expected to be a string containing the full path of the file
			var metadata : SceneGraphMetadata = get_item_metadata(i)
			if metadata.filePath == file:
				existingItemIndex = i
				break
		
		# If the file already exists as a treeItem, simply select and open it
		if existingItemIndex >= 0:
			SelectGraph(existingItemIndex)
			OpenGraph(existingItemIndex)
		else:
			var newListItem = AddGraphToTree(file)
			SelectGraph(newListItem)
			OpenGraph(newListItem)

# Notifications
func _notification(notif) -> void:
	match notif:
		NOTIFICATION_PREDELETE: _on_predelete()

func _on_predelete() -> void:
	m_saveFileDialogue.free()
	m_loadFileDialogue.free()

# FileTree signals
func _on_item_selected() -> void:
	var activatedItem : TreeItem = get_selected()
	OpenGraph(activatedItem)

# FileSystemDock signals
func _on_file_removed(path : String) -> void:
	for item : TreeItem in m_treeRoot.get_children():
		if item.get_metadata(0).filePath == path:
			CloseGraphWithoutSaving(item)
			break

func _on_file_moved(oldPath : String, newPath : String) -> void:
	for item : TreeItem in m_treeRoot.get_children():
		var metadata : SceneGraphMetadata = item.get_metadata(0)
		if metadata.filePath == oldPath:
			metadata.filePath = newPath
			item.set_metadata(0, metadata)
			
			item.set_tooltip_text(0, newPath)
			item.set_text(0, newPath.get_file())
			break

# FileMenu signals
func _on_new_graph() -> void:
	var newGraph : SceneGraph = MakeNewGraph()
	var newTreeItem : TreeItem = AddGraphToTree("", newGraph)
	newTreeItem.set_text(0, "[New Graph]")
	SelectGraph(newTreeItem)
	OpenGraph(newTreeItem)

func _on_load_graph() -> void:
	m_loadFileDialogue.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILES
	m_loadFileDialogue.popup()

func _on_save_graph() -> void:
	var selectedTreeItem : TreeItem = get_selected()
	var metadata : SceneGraphMetadata = selectedTreeItem.get_metadata(0)
	
	if metadata.sceneGraph.resource_path == "":
		_on_save_graph_as()
	else:
		ResourceSaver.save(metadata.sceneGraph, metadata.sceneGraph.resource_path)

func _on_save_graph_as() -> void:
	m_saveFileDialogue.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	m_saveFileDialogue.popup()

func _on_close_graph() -> void:
	var selectedTreeItem : TreeItem = get_selected()
	CloseGraph(selectedTreeItem)

# FileDialogue signals
# This function will only be triggered by m_saveFileDialogue
func _on_save_file_dialogue_file_selected(path : String) -> void:
	var selectedTreeItem : TreeItem = get_selected()
	var metadata : SceneGraphMetadata = selectedTreeItem.get_metadata(0)
	
	ResourceSaver.save(metadata.sceneGraph, path, ResourceSaver.FLAG_CHANGE_PATH)
	
	metadata.filePath = path
	selectedTreeItem.set_metadata(0, metadata)
	
	selectedTreeItem.set_tooltip_text(0, path)
	selectedTreeItem.set_text(0, path.get_file())

# This function will only be triggered by m_loadFileDialogue
func _on_load_file_dialogue_files_selected(paths : Array[String]) -> void:
	# Modified from _drop_data
	for file : String in paths:
		var existingItemIndex : int = -1
		for i : int in item_count:
			# Metadata is expected to be a string containing the full path of the file
			var metadata : SceneGraphMetadata = get_item_metadata(i)
			if metadata.filePath == file:
				existingItemIndex = i
				break
		
		# If the file already exists as a treeItem, simply select and open it
		if existingItemIndex >= 0:
			SelectGraph(existingItemIndex)
			OpenGraph(existingItemIndex)
		else:
			var newListItem = AddGraphToList(file)
			SelectGraph(newListItem)
			OpenGraph(newListItem)

# Custom Functions
func MakeNewGraph(scenes_ : Array[PackedScene] = []) -> SceneGraph:
	return SceneGraph.new(scenes_)

func AddGraphToList(filePath_ : String = "", graph_ : SceneGraph = null) -> int:
	assert(filePath_ != "" || graph_ != null)
	
	var itemIndex = add_item(filePath_.get_file())
	
	var metadata : SceneGraphMetadata = SceneGraphMetadata.new(filePath_, graph_)
	set_item_metadata(itemIndex, metadata)
	
	set_item_tooltip(itemIndex, filePath_)
	
	return itemIndex

func SelectGraph(index_ : int) -> void:
	select(index_)

func OpenGraph(index_ : int) -> void:
	graphOpened.emit()
	
	var metadata : SceneGraphMetadata = get_item_metadata(index_)
	if metadata.sceneGraph == null:
		metadata.sceneGraph = load(metadata.filePath)
	set_item_metadata(index_, metadata)

# TODO: Add a check if the user has unsaved work
func CloseGraph(index_ : int) -> void:
	graphClosed.emit()
	
	remove_item(index_)

func CloseGraphWithoutSaving(index_ : int) -> void:
	graphClosed.emit()
	
	remove_item(index_)
