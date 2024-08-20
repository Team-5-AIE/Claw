extends Node2D

# ---Functions---
# Godot functions
func _ready():
	var player : SWPlatformerCharacter = get_tree().get_root().m_player
	if (player == null):
		player = load("res://SWPlatformerPackage/Player/player_character.tscn").instantiate()
		get_tree().current_scene.add_child.call_deferred(player)
		player.position = position
		player.name = "Player"
		player.set_unique_name_in_owner(true)
		
		var camera : Camera2D = load("res://SWPlatformerPackage/custom_camera.tscn").instantiate()
		player.add_child(camera)
