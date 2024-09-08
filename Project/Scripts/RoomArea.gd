@tool
extends Area2D

# ---Variables---
# Editor variables
@export var roomBounds : CollisionShape2D

@onready var roomGlobals : Node2D = get_owner()
var player : SWPlatformerCharacter
var playerCamera : Camera2D

# ---Functions---
# Init
func _on_room_init():
	player = roomGlobals.player
	playerCamera = player.get_node("PlayerCamera")
	
	roomGlobals.playerEnteredRoom.connect(_on_player_entered_room)

# Godot functions
func _on_tree_entered():
	if Engine.is_editor_hint():
		get_parent().set_editable_instance(self, true)

# RoomTransition signals
func _on_player_entered_room():
	playerCamera.roomBounds = roomBounds
