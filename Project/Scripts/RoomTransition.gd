@tool
extends Area2D
class_name RoomTransition

# ---Variables---
# Editor variables
@export var playerSpawn : Node2D

@export var roomGraph : RoomGraph
@export_file("*.tscn") var nextScene : String
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
var playerCamera : Camera2D

# Private variables
#@onready var _resourcePreviewer : EditorResourcePreview = EditorInterface.get_resource_previewer()

var _exitDirInternal : Vector2

var _previewCanvasItem : RID
var _previewCanvasTexture : RID

var _justLoadedLeewayCounter : int = 0
var _justLoaded : bool

# ---Functions---
# Init
func _on_room_init():
	player = roomGlobals.player
	playerCamera = player.get_node("PlayerCamera")

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
	
	if ! Engine.is_editor_hint():
		print_debug("Just loaded = true")
		_justLoaded = true
	else:
		get_parent().set_editable_instance(self, true)

func _process(_delta):
	if ! Engine.is_editor_hint():
		# This is awful, but is the hacky way I'm making it so that the player isn't seen as leaving
		# the room the moment they enter
		if _justLoaded == true:
			if _justLoaded == true and _justLoadedLeewayCounter < 3:
				print_debug("Just loaded leeway: " + str(_justLoadedLeewayCounter))
				_justLoadedLeewayCounter += 1
			else:
				print_debug("Just loaded = false")
				_justLoaded = false
	else:
		queue_redraw()

func _draw():
	if Engine.is_editor_hint():
		DrawArrow(_exitDirInternal, 30, 3, Color(1, 0, 0, 0.5))
		#_resourcePreviewer.queue_resource_preview(nextScene.resource_path, self, "DrawRoomPreview", null)

# RoomTransition signals
func _on_body_entered(body_):
	if _justLoaded == false:
		print_debug("Body entered when just loaded = false")
		if body_ == player:
			var room = roomGlobals.roomLoader.LoadRoom(nextScene, player)
			
			var rtnArray = room.get_tree().get_nodes_in_group("RoomTransitionNodes")
			var roomTransitionNodeArray : Array[Area2D]
			roomTransitionNodeArray.assign(rtnArray)
			
			for roomTransition : Area2D in roomTransitionNodeArray:
				if roomTransition.nextScene == roomGlobals.scene_file_path:
					var gp = global_position
					var rtgp = roomTransition.global_position
					room.position += global_position - roomTransition.global_position
					break
			
			roomGlobals.queue_free()
			
			# This is bad ;w;
			#for roomTransition : Area2D in roomGlobals.roomLoader.lastRoom.roomTransitionNodes:
				#roomTransition.set_process_mode(Node.PROCESS_MODE_INHERIT)
			#
			#for roomTransition : Area2D in roomGlobals.roomTransitionNodes:
				#roomTransition.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
	else:
		print_debug("Body entered when just loaded = true")
		
		roomGlobals.currentSpawner = playerSpawn

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
