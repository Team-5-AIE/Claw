class_name Crosshair
extends Node

@export var radius = 50
@export var joyPadSpeed: float = 2

@onready var crosshair = $"."
var player: CharacterBody2D
var gameRoot: Node

var mousePos
var isMouseUsed: bool = true

#------------------------------------------------------------------------------

func _ready() -> void:
	#self.visible = false
	player = get_parent()
	gameRoot = get_parent().get_parent()
	Global.crosshair = crosshair



func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		isMouseUsed = false
	
	elif event is InputEventMouseButton or event is InputEventKey:
		isMouseUsed = true
		self.visible = true



func _process(delta: float) -> void:
	if isMouseUsed == true:
		crosshair.reparent(gameRoot)
		mousePos = crosshair.get_global_mouse_position()
		crosshair.global_position = mousePos
		self.visible = true
		crosshair.modulate = Color.WHITE
	else:
		crosshair.reparent(player)
		
		var getJoyAxis = get_joy_vector()
		var fixedPlayerPos = Vector2(player.global_position.x, player.spear_marker.global_position.y)
		var mouseDir = (crosshair.global_position-fixedPlayerPos).normalized()
		
		var crosshair_offset = getJoyAxis * radius
		crosshair.global_position = crosshair.global_position.move_toward(fixedPlayerPos + crosshair_offset, joyPadSpeed)
		
		#crosshair.global_position += getJoyAxis
		#
		#if fixedPlayerPos.distance_to(crosshair.global_position) > radius:
			#crosshair.global_position = fixedPlayerPos + (mouseDir * radius)
		
		if getJoyAxis == Vector2.ZERO:
			var newPos = get_viewport().get_screen_transform() * player.spear_marker.get_global_transform_with_canvas() * getJoyAxis
			Input.warp_mouse(Vector2(newPos.x,newPos.y))
			crosshair.global_position = crosshair.get_global_mouse_position()
			self.visible = false
		else:
			var newPos = get_viewport().get_screen_transform() * crosshair.get_global_transform_with_canvas() * getJoyAxis
			Input.warp_mouse(newPos)
			self.visible = true
			crosshair.modulate = Color(1, 1, 1, (fixedPlayerPos - crosshair.global_position).length()/radius)

func get_joy_vector() -> Vector2:
	var joyX: float
	var joyY: float
	
	#if Input.is_action_pressed("Aim Down"):
		#joyY = joyPadSpeed
	#elif Input.is_action_pressed("Aim Up"):
		#joyY = -joyPadSpeed
	#if Input.is_action_pressed("Aim Right"):
		#joyX = joyPadSpeed
	#elif Input.is_action_pressed("Aim Left"):
		#joyX = -joyPadSpeed
		
	var leftJoyAxis = Input.get_vector("Left", "Right", "Up", "Down")
	var rightJoyAxis = Input.get_vector("Aim Left", "Aim Right", "Aim Up", "Aim Down")
	
	if rightJoyAxis != Vector2.ZERO:
		joyX = rightJoyAxis.x
		joyY = rightJoyAxis.y
	elif leftJoyAxis != Vector2.ZERO:
		joyX = leftJoyAxis.x
		joyY = leftJoyAxis.y
	else:
		joyX = 0
		joyY = 0
	
	return Vector2(joyX, joyY)
