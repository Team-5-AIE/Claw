extends Camera2D

# ---Variables---
# Editor variables
@export var m_offset : int

# Scene nodes
@onready var m_player = $".."
var m_roomBounds : CollisionShape2D

# Public members
var m_lookDirection : Vector2


# ---Functions---
# Godot functions
func _process(delta):
	if m_player.input_axis.x:
		m_lookDirection = Vector2(m_player.input_axis.x, 0)
		position = m_offset * m_lookDirection
	
	# Clamp camera x
	var clampedX = ClampCameraAxis(m_roomBounds.global_position.x, m_roomBounds.shape.size.x,
								   get_viewport_rect().size.x)
	limit_right = clampedX.x
	limit_left = clampedX.y
	
	# Clamp camera y
	var clampedY = ClampCameraAxis(m_roomBounds.global_position.y, m_roomBounds.shape.size.y,
								   get_viewport_rect().size.y)
	limit_bottom = clampedY.x
	limit_top = clampedY.y

# Custom functions
func ClampCameraAxis(boundsPos : float, boundsSize : float, camSize : float) -> Vector2:
	var clamped : Vector2
	
	if boundsSize <= camSize:
		var halfCamSizeY = camSize / 2
		clamped.x = boundsPos + halfCamSizeY
		clamped.y = boundsPos - halfCamSizeY
	else:
		var halfBoundsSizeY = boundsSize / 2		
		clamped.x = boundsPos + halfBoundsSizeY
		clamped.y = boundsPos - halfBoundsSizeY
	
	return clamped
