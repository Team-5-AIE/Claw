extends Node2D

enum ControlConfig {HOLD, TOGGLE}

@export var crosshairs_enabled: bool = true
@export var control_config: ControlConfig = ControlConfig.TOGGLE
@export var is_mouse_used: bool = false
@export var crosshair_reach: float = 60
@export var aim_crosshair_delay: float = 0.1
@export var aim_duration: float = 0.1

var aim_direction: Vector2

@onready var player = $".." as SWPlatformerCharacter
@onready var aim_visual = $AimPoint as Sprite2D
@onready var throw_visual = $AimCrosshair as Sprite2D
@onready var swing_visual = $SwingPoint as Sprite2D
@onready var launch_visual = $SwingCrosshair as Sprite2D

func _set_crosshair_visibility():
	if crosshairs_enabled:
		if player.finite_state_machine.state == player.state_spear:
			aim_visual.visible = false
			throw_visual.visible = false
			launch_visual.visible = true
			swing_visual.visible = true
		else:
			aim_visual.visible = true
			throw_visual.visible = true
			launch_visual.visible = false
			swing_visual.visible = false
	else:
		aim_visual.visible = false
		throw_visual.visible = false
		launch_visual.visible = false
		swing_visual.visible = false

func _set_crosshair_position(delta: float):
	if is_mouse_used:
		aim_visual.position = (get_global_mouse_position() - global_position).normalized() * crosshair_reach
	elif aim_direction != Vector2.ZERO:
		aim_visual.position = aim_direction * crosshair_reach
	else:
		aim_visual.position = Vector2(player.last_input_direction.x,-1).normalized() * crosshair_reach
	
	var spear_direction = (aim_visual.position - player.velocity * aim_crosshair_delay).normalized()
	throw_visual.position = spear_direction * crosshair_reach
	
	if player.finite_state_machine.state == player.state_spear:
		launch_visual.position = player.velocity.normalized() * crosshair_reach
		if is_instance_valid(player.state_spear.spearInstance):
			var spearToPlayer = player.spear_marker.global_position - player.state_spear.spearInstance.global_position
			var launch_velocity = player.velocity * (1.0 - player.state_spear.pullJumpStopFraction) - spearToPlayer.normalized() * player.state_spear.pullJumpStrength
			
			swing_visual.position = launch_velocity.normalized() * crosshair_reach

#func _display_label():
	#match (control_config):
			#ControlConfig.TOGGLE:
				#$"../../../CanvasLayer/ExitLabel".text = "TOGGLE (Press P to switch configs)\nLeft Stick - Move\nRight Stick - Aim Spear\nB/RB - Shoot/Pull Spear\nA/LB - Jump\nX - Slide"
			#ControlConfig.HOLD:
				#$"../../../CanvasLayer/ExitLabel".text = "HOLD (Press P to switch configs)\nLeft Stick - Move\nRight Stick - Shoot/pull Spear\nA/LB - Jump\nX - Slide"

func _controller_config(delta: float):
	var controller_spear_use: InputEvent = InputEventAction.new()
	match (control_config):
		ControlConfig.TOGGLE:
			if Input.is_action_just_pressed("SpearController"):
				if player.finite_state_machine.state == player.state_spear:
					print("TOGGLE: Let go of spear")
					controller_spear_use.action = "LetGoOfSpear"
				else:
					print("TOGGLE: Used spear")
					controller_spear_use.action = "Spear"
		ControlConfig.HOLD:
			if Input.is_action_just_pressed("SpearController") && player.finite_state_machine.state != player.state_spear:
				print("HOLD: Used spear")
				controller_spear_use.action = "Spear"
			elif Input.is_action_just_released("SpearController") && player.finite_state_machine.state == player.state_spear:
				print("HOLD: Let go of spear")
				controller_spear_use.action = "LetGoOfSpear"
	
	controller_spear_use.pressed = true
	Input.parse_input_event(controller_spear_use)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.global_position = player.spear_marker.global_position
	aim_direction = Input.get_vector("Aim Left", "Aim Right", "Aim Up", "Aim Down")
	
	_set_crosshair_visibility()
	_set_crosshair_position(delta)

	
	if not is_mouse_used:
		player.lockspear45direction = (aim_direction == Vector2.ZERO)
		
		_controller_config(delta)
	
	if Input.is_action_just_pressed("Debug Toggle"):
		match (control_config):
			ControlConfig.HOLD:
				print("Toggle Controls")
				control_config = ControlConfig.TOGGLE
			ControlConfig.TOGGLE:
				print("Hold Controls")
				control_config = ControlConfig.HOLD
