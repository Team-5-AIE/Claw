extends Node2D

# ---Signals---
signal roomInit()

# ---Variables---
@export var playerSpawn : Node2D

var roomTransitionNodeArray : Array[Area2D]
var gameRoot : Node
var roomLoader : Node2D
var player : SWPlatformerCharacter

# ---Functions---
func Init(gameRoot_ : Node, roomLoader_ : Node2D, player_ : SWPlatformerCharacter):
	gameRoot = gameRoot_
	
	roomLoader = roomLoader_
	
	if player_ == null:
		player = playerSpawn.SpawnPlayer(gameRoot)
	else:
		player = player_
	
	var rtnArray = get_tree().get_nodes_in_group("RoomTransitionNodes")
	roomTransitionNodeArray.assign(rtnArray)
	
	for roomTransition : Area2D in roomTransitionNodeArray:
		if self == roomLoader.currentRoom:
			roomLoader.LoadRoom(roomTransition.nextScene)
			roomTransition.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
	roomInit.emit()
