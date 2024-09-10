extends Node2D

# ---Variables---
# Member variables
var loadedRooms : Array[Node2D]
var lastRoom : Node2D
var currentRoom : Node2D :
	set(value):
		assert(loadedRooms.has(value))
		lastRoom = currentRoom
		currentRoom = value

# ---Functions---
# Custom functions
func LoadRoom(roomScenePath_ : String, timeTracker_ : Node, pauseMenu_ : Node, \
			  player_ : SWPlatformerCharacter = null) -> Node2D:
	assert(roomScenePath_ != "")
	
	var room = load(roomScenePath_).instantiate()
	add_child(room)
	
	room.Init(get_parent(), self, timeTracker_, pauseMenu_, player_)
	
	loadedRooms.append(room)
	
	return room

func QueueFreeRoom(room_ : Node2D) -> void:
	loadedRooms.erase(room_)
	room_.queue_free()

func FreeRoom(room_ : Node2D) -> void:
	loadedRooms.erase(room_)
	room_.free()

func LoadAdjacentRooms() -> void:
	var rtnArray = get_tree().get_nodes_in_group("RoomTransitionNodes")
	var roomTransitionNodesArray : Array[Area2D]
	roomTransitionNodesArray.assign(rtnArray)
	
	for roomTransitionNode in roomTransitionNodesArray:
		if roomTransitionNode.owner == currentRoom:
			var roomAlreadyExists : bool = false
			for loadedRoom in loadedRooms:
				if roomTransitionNode.nextRoom == loadedRoom.scene_file_path:
					roomAlreadyExists = true
					break
			
			if !roomAlreadyExists:
				var room = LoadRoom(roomTransitionNode.nextRoom, currentRoom.timeTracker, \
									currentRoom.pauseMenu, currentRoom.player)
				
				# Even though we did this earlier to get roomTransitionNodesArray,
				# we've now loaded a new room, so we have to get this array
				# again, and, since the number of nodes here differ from the
				# array that we are currently looping through, we also have
				# to store the new array in a new variable
				rtnArray = get_tree().get_nodes_in_group("RoomTransitionNodes")
				var newRoomTransitionNodesArray : Array[Area2D]
				newRoomTransitionNodesArray.assign(rtnArray)
				
				for otherRoomTransitionNode : Area2D in newRoomTransitionNodesArray:
					if otherRoomTransitionNode.owner == room:
						if otherRoomTransitionNode.nextRoom == currentRoom.scene_file_path:
							room.position += roomTransitionNode.global_position - otherRoomTransitionNode.global_position
							break

func FreeAdjacentRooms(excludedRooms_ : Array[String]) -> void:
	for room : Node2D in loadedRooms:
		if not excludedRooms_.has(room.scene_file_path):
			QueueFreeRoom(room)
