extends Node2D

# ---Variables---
var currentRoom : Node2D
var lastRoom : Node2D

# ---Functions---
# Custom functions
func LoadRoom(roomScene : PackedScene) -> void:
	lastRoom = currentRoom
	
	var room = roomScene.instantiate()
	add_child(room)
	currentRoom = room
	
	room.Init(get_parent(), self, null)
