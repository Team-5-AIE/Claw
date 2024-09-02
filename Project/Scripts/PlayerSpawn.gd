@tool
extends Node2D

# ---Variables---
# Editor Variables
@export var spawnPreview : Sprite2D
@export var flipSpawnDir : bool = false:
	set(value):
		flipSpawnDir = value
		spawnPreview.flip_h = value

# Member Variables
var parentRoomTransition : Area2D = null
var standaloneSpawner : bool = true

# ---Functions---
# Godot Functions
func _ready():
	if ! Engine.is_editor_hint():
		visible = false
		
		var parentScript = get_parent().get_script()
		if parentScript != null and parentScript.get_global_name() == "RoomTransition":
			parentRoomTransition = get_parent()
			standaloneSpawner = false

# Custom Functions
func SpawnPlayer(gameRoot_ : Node) -> SWPlatformerCharacter:
	var playerScene : PackedScene = load("res://SWPlatformerPackage/Player/player_character.tscn")
	var player : SWPlatformerCharacter = playerScene.instantiate()
	gameRoot_.add_child(player)
	player.position = position
	
	var camera : Camera2D = load("res://Objects/player_camera.tscn").instantiate()
	player.add_child(camera)
	
	return player
