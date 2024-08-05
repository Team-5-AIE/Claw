@tool
extends GraphEdit

func _on_graph_opened():
	if ! visible:
		visible = true

func _on_file_tree_graph_closed():
	if visible:
		visible = false
