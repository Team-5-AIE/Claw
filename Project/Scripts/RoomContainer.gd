extends Node2D

# ---Variables---
# Member variables
var loadedRooms : Array[Node2D]

# ---Functions---
# Custom functions
func LoadRoom(roomScenePath_ : String, player_ : SWPlatformerCharacter = null) -> Node2D:
	assert(roomScenePath_ != "")
	
	var room = load(roomScenePath_).instantiate()
	call_deferred("add_child", room)
	
	room.call_deferred("Init", get_parent(), self, player_)
	
	loadedRooms.append(room)
	
	return room

func FreeRoom(room_ : Node2D) -> void:
	loadedRooms.erase(room_)
	room_.queue_free()
