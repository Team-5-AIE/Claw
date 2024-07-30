@tool
extends EditorPlugin

var testDock : Node

func _enter_tree():
	testDock = preload("res://addons/scenetree/SceneTreeDock.tscn").instantiate()
	add_control_to_bottom_panel(testDock, "Scene Tree")

func _exit_tree():
	remove_control_from_bottom_panel(testDock)
	testDock.queue_free()
