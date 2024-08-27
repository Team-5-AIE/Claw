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
@onready var _resourcePreviewer : EditorResourcePreview = EditorInterface.get_resource_previewer()

var _previewCanvasItem : RID
var _previewCanvasTexture : RID

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
		DrawArrow(Vector2.RIGHT, 30, 3, Color(1, 0, 0, 0.5))
		_resourcePreviewer.queue_resource_preview(nextScene.resource_path, self, "DrawRoomPreview", null)

# RoomTransition signals
func _on_body_entered(body_):
	if body_ == player:
		# This is awful ;w;
		for roomTransition : Area2D in roomGlobals.roomLoader.lastRoom.roomTransitionNodes:
			roomTransition.set_process_mode(Node.PROCESS_MODE_INHERIT)
		
		for roomTransition : Area2D in roomGlobals.roomTransitionNodes:
			roomTransition.set_process_mode(Node.PROCESS_MODE_DISABLED)
		
		playerEnteredRoom.emit(body_)

# EditorResourcePreview reciever function
func DrawRoomPreview(path : String, preview : Texture2D, thumbnail_preview : Texture2D,
					 userdata : Variant) -> Variant:
	draw_texture(preview, Vector2.ZERO)
	#_previewCanvasItem = RenderingServer.canvas_item_create()
	#_previewCanvasTexture = RenderingServer.canvas_texture_create()
	#
	#preview.draw_rect(_previewCanvasItem, preview.get_size())
	
	return userdata

# Custom functions
func DrawArrow(direction_ : Vector2, length_ : float, lineWidth_ : float, colour_ : Color):
	# Arrow constants
	var headLength : float = 20
	var headAngle : float = 40
	
	var exitLine : Vector2 = direction_ * length_
	draw_line(Vector2.ZERO, exitLine, colour_, lineWidth_)
	var arrowHead : Vector2 = -direction_ * length_
	draw_line(exitLine, arrowHead.rotated(headAngle),
			  colour_, lineWidth_)
	draw_line(exitLine, arrowHead.rotated(-headAngle),
			  colour_, lineWidth_)
