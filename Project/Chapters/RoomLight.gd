extends PointLight2D

# ---Variables---
@onready var playerCamera : Node2D = get_owner()

# ---Functions---
func _process(_delta):
	global_position = playerCamera.get_screen_center_position()
