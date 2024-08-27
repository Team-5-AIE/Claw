@tool
extends Area2D

# ---Variables---
# Editor variables
@export var m_roomBounds : CollisionShape2D

var m_player : SWPlatformerCharacter
var m_playerCamera : Camera2D

# ---Functions---
# Godot functions
func _ready():
	if ! Engine.is_editor_hint():
		m_player = get_parent().get_node("%Player")
		m_playerCamera = m_player.get_node("PlayerCamera")

func _on_tree_entered():
	if Engine.is_editor_hint():
		get_parent().set_editable_instance(self, true)

func _on_body_entered(body):
	# TODO: This feels like it depends on too many arbitrary things.
	# Find a better way later, and keep an eye on it for now.
	if body == m_player:
		m_playerCamera.m_roomBounds = m_roomBounds
