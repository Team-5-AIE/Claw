extends Node2D

# ---Functions---
# Custom functions
func LoadRoom(roomScenePath_ : String, player_ : SWPlatformerCharacter = null) -> Node2D:
	assert(roomScenePath_ != "")
	
	var room = load(roomScenePath_).instantiate()
	add_child(room)
	
	room.Init(get_parent(), self, player_)
	
	return room
