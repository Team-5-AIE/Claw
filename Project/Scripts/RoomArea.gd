@tool
extends Area2D

# ---Variables---
# Editor variables
@export var roomGlobals : Node2D
@export var roomBounds : CollisionShape2D

var player : SWPlatformerCharacter
var playerCamera : Camera2D

# ---Functions---
# Init
func _on_room_init():
	player = roomGlobals.player
	playerCamera = player.get_node("PlayerCamera")

# Godot functions
func _on_tree_entered():
	if Engine.is_editor_hint():
		get_parent().set_editable_instance(self, true)

func _on_body_entered(body_):
	if body_ == player:
		playerCamera.roomBounds = roomBounds
