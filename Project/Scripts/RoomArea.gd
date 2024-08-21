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
	
	if playerCamera.roomBounds == null:
		playerCamera.roomBounds = roomBounds

# Godot functions
func _on_tree_entered():
	if Engine.is_editor_hint():
		get_parent().set_editable_instance(self, true)

# RoomTransition signals
func _on_player_entered_room(_player):
	playerCamera.roomBounds = roomBounds
