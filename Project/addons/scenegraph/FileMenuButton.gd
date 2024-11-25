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

# ---Functions---
# Godot functions
func _ready():
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	m_popupMenu.clear()
	
	m_popupMenu.add_item("New Scene Graph", Options.eNew, KEY_MASK_CTRL | KEY_N)
	m_popupMenu.add_separator()
	m_popupMenu.add_item("Open Scene Graph", Options.eOpen, KEY_MASK_CTRL | KEY_O)
	m_popupMenu.add_item("Save", Options.eSave, KEY_MASK_CTRL | KEY_S)
	m_popupMenu.add_item("Save As...", Options.eSaveAs, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
	m_popupMenu.add_separator()
	m_popupMenu.add_item("Close", Options.eClose, KEY_MASK_CTRL | KEY_W)
	
	m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eNew), false)
	m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eOpen), false)
	m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eSave), true)
	m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eSaveAs), true)
	m_popupMenu.set_item_disabled(m_popupMenu.get_item_index(Options.eClose), true)
	
	m_popupMenu.id_pressed.connect(SignalDispatcher)

# FileList signals
func _on_file_list_empty_clicked(at_position : Vector2, mouse_button_index : int):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		SetFileSelectedEnables(false)
		
		var globalCursorPos = ViewportCursorToScreen(at_position)
		
		m_popupMenu.position = globalCursorPos
		m_popupMenu.popup()

func _on_file_list_item_clicked(index, at_position, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		SetFileSelectedEnables(true)
		
		var globalCursorPos = ViewportCursorToScreen(at_position)
		
		m_popupMenu.position = globalCursorPos
		m_popupMenu.popup()

# Custom functions
func ViewportCursorToScreen(vpCursorPos : Vector2) -> Vector2:
	# Add at_position (mouse position local to fileList) to fileList's position
	var globalCursorPos : Vector2 = m_fileList.global_position + vpCursorPos
	# Then, transform the whole thing to the screen, instead of the
	# slightly smaller Godot viewport
	var viewportToScreenTransform = get_viewport().get_screen_transform()
	globalCursorPos = globalCursorPos * viewportToScreenTransform
	
	# The final touch - add 23 to align the corner with the cursor,
	# for some reason
	globalCursorPos.y += 23
	
	return globalCursorPos

func SignalDispatcher(id : int) -> void:
	match id:
		Options.eNew:
			NewGraph.emit()
			SetFileSelectedEnables(true)
		Options.eOpen:
			LoadGraph.emit()
			SetFileSelectedEnables(true)
		Options.eSave: SaveGraph.emit()
		Options.eSaveAs: SaveGraphAs.emit()
		Options.eClose:
			CloseGraph.emit()
			SetFileSelectedEnables(m_fileList.is_anything_selected())

func SetFileSelectedEnables(fileSelected : bool) -> void:
	if fileSelected:
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
