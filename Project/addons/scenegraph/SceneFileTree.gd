@tool
extends Tree

# ---Variables---
var treeRoot : TreeItem

# ---Functions---
# Godot Functions
func _ready() -> void:
	# Enable mouse interactionsw, like our drag-and-drop
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	treeRoot = create_item()
	treeRoot.set_text(0, "[ScTr File Name]")

func _can_drop_data(at_position : Vector2, data : Variant) -> bool:
	# We expect that the data passed to us from te file system will be of a certain type and format
	# If it's not, we refuse to allow the data to be dropped
	if(data is Dictionary and data.has("files")):
		for file : String in data.get("files"):
			if (file.get_extension() != "tscn"):
				return false
	
	return true

func _drop_data(at_position : Vector2, data : Variant) -> void:
	# Drop data can contain multiple files. We've previously made sure that
	# all of these files are .tscn files
	for file : String in data.get("files"):
		# To avoid duplicates, we check all of our currently loaded files
		# against whatever files we're importing
		var existingTreeItem : TreeItem = null
		for item : TreeItem in treeRoot.get_children():
			# Metadata is expected to be a string containing the full path of the file 
			if item.get_metadata(0) == file:
				existingTreeItem = item
				break
		
		# If the file already exists as a treeItem, simply select and open it
		if existingTreeItem:
			OpenSceneItem(existingTreeItem)
		else:
			var newTreeItem = AddSceneToTree(file)
			OpenSceneItem(newTreeItem)

# Custom Functions
func MakeNewTree() -> Resource:
	var  newScTr = .new()

func AddSceneToTree(filePath : String) -> TreeItem:
	var treeFile = create_item(treeRoot)
	treeFile.set_metadata(0, filePath)
	treeFile.set_tooltip_text(0, filePath)
	treeFile.set_text(0, filePath.get_file())
	
	return treeFile

func OpenSceneItem(sceneItem : TreeItem) -> void:
	sceneItem.select(0)
