@tool
extends MenuButton

# ---Signals---
signal NewGraph
signal LoadGraph
signal SaveGraph
signal SaveGraphAs
signal CloseGraph

# ---Variables---
@onready var popupMenu : PopupMenu = get_popup()

# ---Functions---
# Godot functions
func _ready():
	popupMenu.id_pressed.connect(SignalDispatcher)

# Custom functions
func SignalDispatcher(id : int) -> void:
	match id:
		1: NewGraph.emit()
		2: LoadGraph.emit()
		3: SaveGraph.emit()
		4: SaveGraphAs.emit()
		5: CloseGraph.emit()
