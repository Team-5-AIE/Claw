@tool
extends MenuButton

enum Options {
	eNew,
	eLoad,
	eSave,
	eSaveAs,
	eClose
}

# ---Signals---
signal NewGraph
signal LoadGraph
signal SaveGraph
signal SaveGraphAs
signal CloseGraph

# ---Variables---
@onready var m_popupMenu : PopupMenu = get_popup()

var m_popupMenuOriginalPos : Vector2

# ---Functions---
# Godot functions
func _ready():
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	m_popupMenu.add_item("New Scene Graph", Options.eNew)
	m_popupMenu.add_separator()
	m_popupMenu.add_item("Load", Options.eLoad)
	m_popupMenu.add_item("Save", Options.eSave)
	m_popupMenu.add_item("Save As...", Options.eSaveAs)
	m_popupMenu.add_separator()
	m_popupMenu.add_item("Close", Options.eClose)
	
	m_popupMenu.id_pressed.connect(SignalDispatcher)
	
	m_popupMenuOriginalPos = m_popupMenu.position

# FileMenu signals
#func _on_about_to_popup():
	#m_popupMenu.position = m_popupMenuOriginalPos

# FileTree signals
func _on_file_tree_empty_clicked(position : Vector2, mouse_button_index : int):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		m_popupMenu.position = position
		m_popupMenu.popup()

# Custom functions
func SignalDispatcher(id : int) -> void:
	match id:
		Options.eNew: NewGraph.emit()
		Options.eLoad: LoadGraph.emit()
		Options.eSave: SaveGraph.emit()
		Options.eSaveAs: SaveGraphAs.emit()
		Options.eClose: CloseGraph.emit()
