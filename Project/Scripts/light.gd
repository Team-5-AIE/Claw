@tool
extends Node2D

@export var lightIntensity : float:
	set(value):
		lightIntensity = value
		queue_redraw()

func _draw():
	if Engine.is_editor_hint():
		draw_circle(Vector2(0, 0), lightIntensity, Color(1, 1, 1, 0.5))
