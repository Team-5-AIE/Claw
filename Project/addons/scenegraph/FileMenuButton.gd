@tool
extends MenuButton

enum Options {
	eNew,
	eOpen,
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
@onready var m_fileList : ItemList = %FileList

var m_popupMenuOriginalPos : Vector2

# ---Functions---
# Godot functions
func _ready():
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	m_popupMenu.clear()
	
	m_popupMenu.add_item("New Scene Graph", Options.eNew)
	m_popupMenu.add_separator()
	m_popupMenu.add_item("Open Scene Graph", Options.eOpen)
	m_popupMenu.add_item("Save", Options.eSave)
	m_popupMenu.add_item("Save As...", Options.eSaveAs)
	m_popupMenu.add_separator()
	m_popupMenu.add_item("Close", Options.eClose)
	
	m_popupMenu.set_item_accelerator(m_popupMenu.get_item_index(Options.eNew), KEY_MASK_CTRL | KEY_N)
	m_popupMenu.set_item_accelerator(m_popupMenu.get_item_index(Options.eOpen), KEY_MASK_CTRL | KEY_O)
	m_popupMenu.set_item_accelerator(m_popupMenu.get_item_index(Options.eSave), KEY_MASK_CTRL | KEY_S)
	m_popupMenu.set_item_accelerator(m_popupMenu.get_item_index(Options.eSaveAs), KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
	m_popupMenu.set_item_accelerator(m_popupMenu.get_item_index(Options.eClose), KEY_MASK_CTRL | KEY_W)
	
	m_popupMenu.id_pressed.connect(SignalDispatcher)
	m_popupMenu.about_to_popup.connect(_on_popup_menu_about_to_popup)
	
	m_popupMenuOriginalPos = m_popupMenu.position

# FileMenu signals
func _on_popup_menu_about_to_popup():
	if m_fileList.is_anything_selected():
		m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eNew), false)
		m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eOpen), false)
		m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eSave), false)
		m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eSaveAs), false)
		m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eClose), false)
	else:
		m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eNew), false)
		m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eOpen), false)
		m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eSave), true)
		m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eSaveAs), true)
		m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eClose), true)

# FileList signals
func _on_file_list_empty_clicked(at_position : Vector2, mouse_button_index : int):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		m_popupMenu.position = position
		m_popupMenu.popup()

# Custom functions
func SignalDispatcher(id : int) -> void:
	match id:
		Options.eNew: NewGraph.emit()
		Options.eOpen: LoadGraph.emit()
		Options.eSave: SaveGraph.emit()
		Options.eSaveAs: SaveGraphAs.emit()
		Options.eClose: CloseGraph.emit()
