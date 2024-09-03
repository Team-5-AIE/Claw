extends Node2D

# ---Signals---
signal roomInit

signal playerEnteredRoom
signal playerExitedRoom

# ---Variables---
@export var playerSpawn : Node2D

@onready var currentSpawner : Node2D = playerSpawn

var gameRoot : Node
var roomContainer : Node2D
var player : SWPlatformerCharacter

#var adjacentRoomPaths : Array[String]

# ---Functions---
# Init
func Init(gameRoot_ : Node, roomContainer_ : Node2D, player_ : SWPlatformerCharacter):
	gameRoot = gameRoot_
	
	roomContainer = roomContainer_
	
	if player_ == null:
		player = currentSpawner.SpawnPlayer(gameRoot)
	else:
		player = player_
	
	var rtnArray = get_tree().get_nodes_in_group("RoomInitListeners")
	var roomInitListenersArray : Array[Area2D]
	roomInitListenersArray.assign(rtnArray)
	
	for roomInitListener : Area2D in roomInitListenersArray:
		if roomInitListener.owner == self:
			roomInit.connect(roomInitListener._on_room_init)
	
	playerEnteredRoom.connect(_on_player_entered_room)
	playerExitedRoom.connect(_on_player_exited_room)
	
	roomInit.emit()

func StartingRoomSetup():
	roomContainer.currentRoom = self
	roomContainer.LoadAdjacentRooms()
	
	playerEnteredRoom.emit()

# RoomTransition signals
func _on_player_entered_room():
	player.restartPlayer.connect(on_restart_player)

func _on_player_exited_room():
	player.restartPlayer.disconnect(on_restart_player)

# Player signals
func on_restart_player():
	player.global_position = currentSpawner.global_position
	player.velocity = Vector2.ZERO
