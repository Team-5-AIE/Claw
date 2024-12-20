extends Camera2D

# ---Variables---
# Editor variables
@export var frontOffset : int

# Scene nodes
@onready var player : SWPlatformerCharacter = $".."
var roomBounds : CollisionShape2D

# Public members
var crosshair : Node2D
var lookDirection : Vector2

# ---Functions---
# Godot functions
func _process(_delta):
	if player != null and roomBounds != null:
		var rtnArray = get_tree().get_nodes_in_group("Crosshair")
		if (rtnArray.size() > 0):
			crosshair = rtnArray[0]
		lookDirection = (crosshair.global_position - player.global_position).normalized()
		position = frontOffset * lookDirection
		
		# Clamp camera x
		var clampedX = ClampCameraAxis(roomBounds.global_position.x, roomBounds.shape.size.x,
									   get_viewport_rect().size.x)
		limit_right = clampedX.x
		limit_left = clampedX.y
		
		# Clamp camera y
		var clampedY = ClampCameraAxis(roomBounds.global_position.y, roomBounds.shape.size.y,
									   get_viewport_rect().size.y)
		limit_bottom = clampedY.x
		limit_top = clampedY.y

# Custom functions
func ClampCameraAxis(boundsPos : float, boundsSize : float, camSize : float) -> Vector2:
	var clamped : Vector2 = Vector2(0, 0)
	
	if boundsSize <= camSize:
		var halfCamSizeY = camSize / 2
		clamped.x = boundsPos + halfCamSizeY
		clamped.y = boundsPos - halfCamSizeY
	else:
		var halfBoundsSizeY = boundsSize / 2
		clamped.x = boundsPos + halfBoundsSizeY
		clamped.y = boundsPos - halfBoundsSizeY
	
	return clamped
