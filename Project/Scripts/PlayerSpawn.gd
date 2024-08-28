@tool
extends Node2D

# ---Functions---
func _ready():
	if ! Engine.is_editor_hint():
		visible = false

func SpawnPlayer(gameRoot_ : Node) -> SWPlatformerCharacter:
	var playerScene : PackedScene = load("res://SWPlatformerPackage/Player/player_character.tscn")
	var player : SWPlatformerCharacter = playerScene.instantiate()
	gameRoot_.add_child(player)
	player.position = position
	
	var camera : Camera2D = load("res://Objects/player_camera.tscn").instantiate()
	player.add_child(camera)
	
	return player
