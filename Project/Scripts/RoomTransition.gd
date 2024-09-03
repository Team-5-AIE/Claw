@tool
extends Area2D
class_name RoomTransition

# ---Variables---
# Editor variables
@export var playerSpawn : Node2D

@export var roomGraph : RoomGraph
@export_file("*.tscn") var nextRoom : String
@export_enum("Right", "Left", "Down", "Up") var exitDirection : String = "Right":
	set(value):
		exitDirection = value
		
		match value:
			"Right":
				_exitDirInternal = Vector2.RIGHT
			"Left":
				_exitDirInternal = Vector2.LEFT
			"Down":
				_exitDirInternal = Vector2.DOWN
			"Up":
				_exitDirInternal = Vector2.UP

# Public variables
@onready var roomGlobals : Node2D = get_owner()

var player : SWPlatformerCharacter
var roomContainer : Node2D

# Private variables
var _exitDirInternal : Vector2

var _justLoadedLeewayCounter : int = 0
var _justLoaded : bool

# ---Functions---
# Init
func _on_room_init():
	player = roomGlobals.player
	roomContainer = roomGlobals.roomContainer

# Godot functions
func _ready():
	match exitDirection:
			"Right":
				_exitDirInternal = Vector2.RIGHT
			"Left":
				_exitDirInternal = Vector2.LEFT
			"Down":
				_exitDirInternal = Vector2.DOWN
			"Up":
				_exitDirInternal = Vector2.UP
	
	if Engine.is_editor_hint():
		get_parent().set_editable_instance(self, true)

func _process(_delta):
	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	if Engine.is_editor_hint():
		DrawArrow(_exitDirInternal, 30, 3, Color(1, 0, 0, 0.5))

# RoomTransition signals
func _on_body_entered(body_):
	if body_ == player:
		# Dot the exit's facing direction with the player's velocity to see
		# whether they are entering or exiting the room
		var facingDotVelocity = _exitDirInternal.dot(player.velocity.normalized())
		if facingDotVelocity > 0:
			# Player just exited the room
			print_debug("Player exited room")
			
			var excludedRooms : Array[String] = [roomGlobals.scene_file_path, nextRoom]
			roomContainer.FreeAdjacentRooms(excludedRooms)
			
			roomGlobals.playerExitedRoom.emit()
		
		else:
			# Player just entered the room
			print_debug("Player entered room")
			
			roomContainer.currentRoom = roomGlobals
			roomContainer.LoadAdjacentRooms()
			
			roomGlobals.currentSpawner = playerSpawn
			
			roomGlobals.playerEnteredRoom.emit()

func _on_body_exited(body_):
	if body_ == player:
		var facingDotVelocity = _exitDirInternal.dot(player.velocity.normalized())
		if facingDotVelocity > 0:
			# Player just exited the room
			print_debug("Player exited room")
			
			var excludedRooms : Array[String] = [roomGlobals.scene_file_path, nextRoom]
			roomContainer.FreeAdjacentRooms(excludedRooms)
			
			roomGlobals.playerExitedRoom.emit()
		
		else:
			# Player just entered the room
			print_debug("Player entered room")
			
			roomContainer.currentRoom = roomGlobals
			roomContainer.LoadAdjacentRooms()
			
			roomGlobals.currentSpawner = playerSpawn
			
			roomGlobals.playerEnteredRoom.emit()

# Custom functions
func DrawArrow(direction_ : Vector2, length_ : float, lineWidth_ : float, colour_ : Color) -> void:
	# Arrow constants
	var headLength : float = 20
	var headAngle : float = 40
	
	var exitLine : Vector2 = direction_ * length_
	draw_line(Vector2.ZERO, exitLine, colour_, lineWidth_)
	var arrowHead : Vector2 = -direction_ * headLength
	draw_line(exitLine, arrowHead.rotated(headAngle),
			  colour_, lineWidth_)
	draw_line(exitLine, arrowHead.rotated(-headAngle),
			  colour_, lineWidth_)
