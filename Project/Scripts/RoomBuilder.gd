extends Node2D

# ---Signals---
signal roomInit()

# ---Variables---
@export var playerSpawn : Node2D

var roomInitListenersArray : Array[Area2D]
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
	
	var rtnArray = get_tree().get_nodes_in_group("RoomInitListeners")
	roomInitListenersArray.assign(rtnArray)
	
	for roomInitListener : Area2D in roomInitListenersArray:
		roomInit.connect(roomInitListener._on_room_init)
	
	roomInit.emit()
