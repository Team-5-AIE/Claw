@tool
extends EditorPlugin

var testDock : Node

func _enter_tree():
	testDock = preload("res://addons/scenegraph/SceneGraphDock.tscn").instantiate()
	add_control_to_bottom_panel(testDock, "Scene Graph")

func _exit_tree():
	remove_control_from_bottom_panel(testDock)
	testDock.queue_free()
