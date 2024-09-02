extends Node2D

# ---Signals---
signal roomInit

# ---Variables---
@export var playerSpawn : Node2D

@onready var currentSpawner : Node2D = playerSpawn

var roomInitListenersArray : Array[Area2D]
var gameRoot : Node
var roomLoader : Node2D
var player : SWPlatformerCharacter

# ---Functions---
# Init
func Init(gameRoot_ : Node, roomLoader_ : Node2D, player_ : SWPlatformerCharacter):
	gameRoot = gameRoot_
	
	roomLoader = roomLoader_
	
	if player_ == null:
		player = currentSpawner.SpawnPlayer(gameRoot)
	else:
		player = player_
	
	player.restartPlayer.connect(on_restart_player)
	
	var rtnArray = get_tree().get_nodes_in_group("RoomInitListeners")
	roomInitListenersArray.assign(rtnArray)
	
	for roomInitListener : Area2D in roomInitListenersArray:
		roomInit.connect(roomInitListener._on_room_init)
	
	roomInit.emit()

# Player Signals
func on_restart_player():
	player.global_position = currentSpawner.global_position
	player.velocity = Vector2.ZERO
