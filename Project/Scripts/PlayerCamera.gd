extends Camera2D

@export var m_offset : int

@onready var m_player = $".."

var m_lookDirection : Vector2

var m_currentRoomManager

func _process(delta):
	#if m_player.input_axis.x != 0 and m_player.input_axis.x != m_player.last_input_direction.x:
	if m_player.input_axis.x:
		m_lookDirection = Vector2(m_player.input_axis.x, 0)
		position = m_offset * m_lookDirection
