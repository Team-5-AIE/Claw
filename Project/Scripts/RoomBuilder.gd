extends Node2D

# ---Signals---
signal roomInit()

# ---Variables---
@export var playerSpawn : Node2D

var gameRoot : Node
var player : SWPlatformerCharacter

# ---Functions---
func Init(gameRoot_ : Node, player_ : SWPlatformerCharacter):
	gameRoot = gameRoot_
	
	if player_ == null:
		player = playerSpawn.SpawnPlayer(gameRoot)
	else:
		player = player_
	
	roomInit.emit()
