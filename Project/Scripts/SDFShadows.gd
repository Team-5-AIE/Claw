extends ColorRect

# ---Functions---
func _unhandled_input(event):
	if event.is_action_pressed("ShaderToggle"):
		visible = !visible
