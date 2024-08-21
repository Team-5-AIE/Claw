@tool
extends Area2D

# ---Signals---
signal playerEnteredRoom(player : SWPlatformerCharacter)

# ---Variables---
# Editor variables
@export var sceneGraph : SceneGraph
@export var nextScene : PackedScene

@export var roomGlobals : Node2D

# Public variables
var player : SWPlatformerCharacter
var playerCamera : Camera2D

# Private variables
var _exitDirection : Vector2 = Vector2(1, 0)

var _lineLength : float = 30
var _lineColour : Color = Color(1, 0, 0, 0.5)
var _lineWidth : float = 3

var _headLength : float = 20
var _headAngle : float = 40

# ---Functions---
# Init
func _on_room_init():
	player = roomGlobals.player
	playerCamera = player.get_node("PlayerCamera")

# Godot functions
func _ready():
	if ! Engine.is_editor_hint():
		set_physics_process(false)

func _process(_delta):
	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	if Engine.is_editor_hint():
		var exitLine : Vector2 = _exitDirection * _lineLength
		draw_line(Vector2.ZERO, exitLine, _lineColour, _lineWidth)
		var arrowHead : Vector2 = -_exitDirection * _headLength
		draw_line(exitLine, arrowHead.rotated(_headAngle),
				  _lineColour, _lineWidth)
		draw_line(exitLine, arrowHead.rotated(-_headAngle),
				  _lineColour, _lineWidth)

# RoomTransition signals
func _on_body_entered(body_):
	if body_ == player:
		# This is awful ;w;
		for roomTransition : Area2D in roomGlobals.roomLoader.lastRoom.roomTransitionNodes:
			roomTransition.set_process_mode(Node.PROCESS_MODE_INHERIT)
		
		for roomTransition : Area2D in roomGlobals.roomTransitionNodes:
			roomTransition.set_process_mode(Node.PROCESS_MODE_DISABLED)
		
		playerEnteredRoom.emit(body_)
