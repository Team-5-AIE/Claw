extends Node2D

# ---Signals---
signal roomInit

# ---Variables---
@export var playerSpawn : Node2D

@onready var currentSpawner : Node2D = playerSpawn

var gameRoot : Node
var roomContainer : Node2D
var player : SWPlatformerCharacter

var roomTransitionNodesArray : Array[Area2D]
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
	
	rtnArray = get_tree().get_nodes_in_group("RoomTransitionNodes")
	roomTransitionNodesArray.assign(rtnArray)
	
	#for roomTransitionNode : Area2D in roomTransitionNodesArray:
		#if roomTransitionNode.owner == self:
			#adjacentRoomPaths.append(roomTransitionNode.nextScene)
	
	roomInit.emit()

func StartingRoomSetup():
	LoadAdjacentRooms()

# Custom functions
func LoadAdjacentRooms() -> void:
	for roomTransitionNode in roomTransitionNodesArray:
		var roomAlreadyExists : bool = false
		for loadedRoom in roomContainer.loadedRooms:
			if roomTransitionNode.nextRoom == loadedRoom.scene_file_path:
				roomAlreadyExists = true
				break
		
		if !roomAlreadyExists:
			var room = roomContainer.LoadRoom(roomTransitionNode.nextRoom, player)
			
			var rtnArray = get_tree().get_nodes_in_group("RoomTransitionNodes")
			var roomTransitionNodeArray : Array[Area2D]
			roomTransitionNodeArray.assign(rtnArray)
			
			for otherRoomTransitionNode : Area2D in roomTransitionNodeArray:
				if otherRoomTransitionNode.owner == room:
					if otherRoomTransitionNode.nextScene == scene_file_path:
						room.position += roomTransitionNode.global_position - otherRoomTransitionNode.global_position
						break

func FreeAdjacentRooms(excludedRooms_ : Array[String]) -> void:
	for room : Node2D in roomContainer.loadedRooms:
		for excluded in excludedRooms_:
			if room.scene_file_path != excluded:
				roomContainer.FreeRoom(room)

func PlayerEntered():
	player.restartPlayer.connect(on_restart_player)

# Player Signals
func on_restart_player():
	player.global_position = currentSpawner.global_position
	player.velocity = Vector2.ZERO
