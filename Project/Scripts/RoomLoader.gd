extends Node2D

# ---Functions---
# Custom functions
func LoadRoom(roomScene : PackedScene) -> void:
	var room = roomScene.instantiate()
	add_child(room)
	
	room.Init(get_parent(), null)
