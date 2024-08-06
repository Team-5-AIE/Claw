@tool
extends EditorPlugin

var m_sceneGraphDock : Node
var m_fileTree : Tree

func _enter_tree() -> void:
	m_sceneGraphDock = preload("res://addons/scenegraph/SceneGraphDock.tscn").instantiate()
	add_control_to_bottom_panel(m_sceneGraphDock, "Scene Graph")
	
	m_fileTree = m_sceneGraphDock.get_node("%FileTree")
	
	var fileSystem : FileSystemDock = get_editor_interface().get_file_system_dock()
	
	fileSystem.file_removed.connect(fileRemoved)
	fileSystem.files_moved.connect(fileMoved)

func _exit_tree() -> void:
	remove_control_from_bottom_panel(m_sceneGraphDock)
	m_sceneGraphDock.free()

func fileRemoved(path : String) -> void:
	m_fileTree._on_file_removed(path)

func fileMoved(oldPath : String, newPath : String) -> void:
	m_fileTree._on_file_moved(oldPath, newPath)
