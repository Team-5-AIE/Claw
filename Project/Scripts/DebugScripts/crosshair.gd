extends Node2D

enum ControlConfig {HOLD, TOGGLE}

@export var crosshairs_enabled: bool = true
@export var control_config: ControlConfig = ControlConfig.TOGGLE
@export var is_mouse_used: bool = true
@export var crosshair_reach: float = 60
@export var aim_crosshair_delay: float = 0.1
@export var aim_duration: float = 0.1

var aim_direction: Vector2

@onready var player = $".." as SWPlatformerCharacter
@onready var aim_visual = $AimPoint as Sprite2D
@onready var throw_visual = $AimCrosshair as Sprite2D
@onready var spear_launch_visual = $SwingPoint as Sprite2D
@onready var swing_release_visual = $SwingCrosshair as Sprite2D

# Sets the visibility of the crosshairs depending on the state of player
func _set_crosshair_visibility():
	if crosshairs_enabled:
		if player.finite_state_machine.state == player.state_spear:
			aim_visual.visible = false
			throw_visual.visible = false
			swing_release_visual.visible = true
			spear_launch_visual.visible = true
		else:
			aim_visual.visible = true
			throw_visual.visible = true
			swing_release_visual.visible = false
			spear_launch_visual.visible = false
	else:
		aim_visual.visible = false
		throw_visual.visible = false
		swing_release_visual.visible = false
		spear_launch_visual.visible = false

# Set position of the different crosshairs
func _set_crosshair_position(delta: float):
	# Set aim_visual direction depending on player's aim, either with mouse, right stick or 45 degree default
	if is_mouse_used:
		aim_visual.position = (get_global_mouse_position() - global_position).normalized() * crosshair_reach
	elif aim_direction != Vector2.ZERO:
		aim_visual.position = aim_direction * crosshair_reach
	else:
		aim_visual.position = Vector2(player.last_input_direction.x,-1).normalized() * crosshair_reach
	
	# Set throw_visual direction depending on aim_visual, player velocity and a set delay 
	var spear_direction = (aim_visual.position - player.velocity * aim_crosshair_delay).normalized()
	throw_visual.position = spear_direction * crosshair_reach
	
	if player.finite_state_machine.state == player.state_spear:
		# Set swing_release_visual direction to player's velocity
		swing_release_visual.position = player.velocity.normalized() * crosshair_reach
		
		# When spear exists, set spear_launch_visual direction depending on the launch velocity when pulling
		if is_instance_valid(player.state_spear.spearInstance):
			var spearToPlayer = player.spear_marker.global_position - player.state_spear.spearInstance.global_position
			var launch_velocity = player.velocity * (1.0 - player.state_spear.pullJumpStopFraction) - spearToPlayer.normalized() * player.state_spear.pullJumpStrength
			
			spear_launch_visual.position = launch_velocity.normalized() * crosshair_reach

func _update_config(new_config: ControlConfig = control_config, mouse_use: bool = is_mouse_used):
	if control_config != new_config:
		control_config = new_config
	match (control_config):
					ControlConfig.TOGGLE:
						$"../DebugHUD/Controls".text = "TOGGLE MODE\n"
					ControlConfig.HOLD:
						$"../DebugHUD/Controls".text = "HOLD MODE\n"
	match (is_mouse_used):
		true:
			$"../DebugHUD/Controls".text += "Mouse and Keyboard:\nA/D - Move\nSpace - Jump\nCtrl/S - Slide\nMouse - Aim\nLeftMouseButton - Use/Release Spear\nRightMouseButton - Launch from Swing"
		false:
			$"../DebugHUD/Controls".text += "XBox Gamepad:\nL Stick - Move\nR Stick - Aim\nA/LB - Jump\nB/RB - Use/Release Spear\nX/LT - Slide\nY/RT - Launch from Swing"

# Override the spear controls with the SpearSpecial control so that certain actions can be done 
# Requires no binds in the Spear or LetGoOfSpear controls
func _custom_control_execution(delta: float):
	var special_spear_use: InputEvent = InputEventAction.new()
	match (control_config):
		ControlConfig.TOGGLE:
			if Input.is_action_just_pressed("SpearSpecial"):
				if player.finite_state_machine.state == player.state_spear:
					print("TOGGLE: Let go of spear")
					special_spear_use.action = "LetGoOfSpear"
				else:
					print("TOGGLE: Used spear")
					special_spear_use.action = "Spear"
		ControlConfig.HOLD:
			if Input.is_action_just_pressed("SpearController") && player.finite_state_machine.state != player.state_spear:
				print("HOLD: Used spear")
				special_spear_use.action = "Spear"
			elif Input.is_action_just_released("SpearController") && player.finite_state_machine.state == player.state_spear:
				print("HOLD: Let go of spear")
				special_spear_use.action = "LetGoOfSpear"
	
	special_spear_use.pressed = true
	Input.parse_input_event(special_spear_use)

func _ready() -> void:
	_update_config(control_config)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.global_position = player.spear_marker.global_position
	aim_direction = Input.get_vector("Aim Left", "Aim Right", "Aim Up", "Aim Down")
	
	# If in controller mode and right stick isn't used, enable the 45 degree lock
	player.lockspear45direction = (not is_mouse_used && aim_direction == Vector2.ZERO)
	
	_set_crosshair_visibility()
	_set_crosshair_position(delta)
	_custom_control_execution(delta)
	
	if Input.is_action_just_pressed("Debug Hold n Toggle Cycle"):
		match (control_config):
			ControlConfig.HOLD:
				print("Toggle Spear Config")
				_update_config(ControlConfig.TOGGLE)
			ControlConfig.TOGGLE:
				print("Hold Spear Config")
				_update_config(ControlConfig.HOLD)
	elif Input.is_action_just_pressed("Debug Controller n Mouse Cycle"):
		is_mouse_used = !is_mouse_used
		match (is_mouse_used):
			true:
				print("Mouse Controls")
				_update_config(control_config, true)
			false:
				print("Controller Controls")
				_update_config(control_config, false)
	elif Input.is_action_just_pressed("Insta Restart"):
		print("Manually Restarted")
		if player.state_spear.spearInstance != null:
			player.state_spear.spearInstance.Release()
			player.state_spear.spearInstance = null
		player.restartPlayer.emit()
