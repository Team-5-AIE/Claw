extends Node2D

# ---Signals---
signal roomInit

signal playerEnteredRoom
signal playerExitedRoom

# ---Variables---
@export var standaloneSpawner : Node2D

@onready var currentSpawner : Node2D = standaloneSpawner

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
		assert(currentSpawner != null)
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
	
	roomInit.emit()

func StartingRoomSetup(pauseMenu_ : Node):
	pauseMenu_.player = player
	
	roomContainer.currentRoom = self
	roomContainer.LoadAdjacentRooms()
	
	playerEnteredRoom.emit()

# Custom functions
func ConnectRestartPlayerSignal():
	player.restartPlayer.connect(_on_restart_player)

func DisconnectRestartPlayerSignal():
	player.restartPlayer.disconnect(_on_restart_player)

# RoomTransition signals
func _on_player_entered_room():
	if roomContainer.lastRoom != null:
		roomContainer.lastRoom.player.restartPlayer.disconnect(roomContainer.lastRoom._on_restart_player)
	
	player.restartPlayer.connect(_on_restart_player)

# Player signals
func _on_restart_player():
	FadeTransitions.TransitionRestart()
	await FadeTransitions.on_fade_in_finished
	player.global_position = currentSpawner.global_position
	player.velocity = Vector2.ZERO
	player.finite_state_machine.ChangeState(player.state_idle)
	await FadeTransitions.on_fade_out_finished
