extends Node2D

enum ControlConfig {HOLD, TOGGLE}
enum SpearAltUseConfig {RELEASE, LAUNCH}

@export var control_config: ControlConfig = ControlConfig.TOGGLE
@export var spear_alt_use_config: SpearAltUseConfig = SpearAltUseConfig.LAUNCH
@export var is_mouse_used: bool = true

@export var crosshairs_enabled: bool = true
@export var crosshair_reach: float = 45
@export var aim_crosshair_delay: float = 0.05
@export var control_labels_enabled: bool = true
@export var debug_labels_enabled: bool = false

var aim_direction: Vector2

@onready var player = $".." as SWPlatformerCharacter
@onready var crosshairs_group = $"../Crosshairs" as Node2D
@onready var aim_visual = $"../Crosshairs/AimPoint" as Sprite2D
@onready var throw_visual = $"../Crosshairs/AimCrosshair" as Sprite2D
@onready var swing_launch_visual = $"../Crosshairs/SwingLaunchPoint" as Sprite2D
@onready var swing_jump_visual = $"../Crosshairs/SwingJumpCrosshair" as Sprite2D

@onready var controls_label = $"../DebugHUD/Controls" as Label
@onready var debug_label = $"../DebugHUD/DebugControls" as Label

# Sets the visibility of the crosshairs depending on the state of player
func _set_crosshair_visibility():
	if crosshairs_enabled:
		if player.finite_state_machine.state == player.state_spear:
			aim_visual.visible = false
			throw_visual.visible = false
			swing_launch_visual.visible = true
			swing_jump_visual.visible = true
		else:
			aim_visual.visible = true
			throw_visual.visible = true
			swing_launch_visual.visible = false
			swing_jump_visual.visible = false
	else:
		aim_visual.visible = false
		throw_visual.visible = false
		swing_launch_visual.visible = false
		swing_jump_visual.visible = false

# Set position of the different crosshairs
func _set_crosshair_position():
	crosshairs_group.global_position = player.spear_marker.global_position
	
	# Set aim_visual direction depending on player's aim
	aim_visual.position = aim_direction * crosshair_reach
	
	# Set throw_visual direction depending on aim_visual, player velocity and a set delay 
	var spear_direction = aim_visual.position - player.velocity * aim_crosshair_delay
	throw_visual.position = spear_direction.normalized() * crosshair_reach
	
	if player.finite_state_machine.state == player.state_spear:
		# Set swing_jump_visual to player's jump direction from a swing
		var jump_direction = player.velocity
		jump_direction.y = -player.jump_height
		jump_direction = (jump_direction) * crosshair_reach/player.run_speed + 0.5 * (crosshair_reach/player.run_speed)**2 * (Vector2.DOWN * player.gravity_speed)
		swing_jump_visual.position = jump_direction.normalized() * crosshair_reach
		
		# When spear exists, set swing_launch_visual direction depending on the launch velocity when pulling
		if is_instance_valid(player.state_spear.spearInstance):
			var spearToPlayer = player.spear_marker.global_position - player.state_spear.spearInstance.global_position
			var launch_velocity = player.velocity * (1.0 - player.state_spear.pullJumpStopFraction) - spearToPlayer.normalized() * player.state_spear.pullJumpStrength
			
			swing_launch_visual.position = launch_velocity.normalized() * crosshair_reach

# Returns a string of the input event to execute
func _get_control_to_execute() -> String:
	if Input.is_action_just_pressed("SpearExtra"):
		# Tap the SpearExtra bind to either let go or pull
		match (spear_alt_use_config):
			SpearAltUseConfig.LAUNCH:
				print("EXTRA: Let go of spear")
				return "LetGoOfSpear"
			SpearAltUseConfig.RELEASE:
				print("EXTRA: Launched from spear swing")
				return "SpearPull"
	else:
		match (control_config):
			ControlConfig.TOGGLE:
				# When not in Spear state, tap to shoot spear. 
				# When in Spear state, tap to either pull or let go.
				if Input.is_action_just_pressed("SpearPrimary"):
					if player.finite_state_machine.state == player.state_spear:
						match (spear_alt_use_config):
							SpearAltUseConfig.RELEASE:
								print("TOGGLE: Let go of spear")
								return "LetGoOfSpear"
							SpearAltUseConfig.LAUNCH:
								print("TOGGLE: Launched from spear swing")
								return "SpearPull"
					else:
						print("TOGGLE: Used spear")
						return "Spear"
			ControlConfig.HOLD:
				# When not in Spear state, hold input to shoot spear. 
				# When in Spear state, release input to either pull or let go.
				if Input.is_action_pressed("SpearPrimary") && player.finite_state_machine.state != player.state_spear:
					print("HOLD: Used spear")
					return "Spear"
				elif Input.is_action_just_released("SpearPrimary") && player.finite_state_machine.state == player.state_spear:
					match (spear_alt_use_config):
						SpearAltUseConfig.RELEASE:
							print("HOLD: Let go of spear")
							return "LetGoOfSpear"
						SpearAltUseConfig.LAUNCH:
							print("HOLD: Launched from spear swing")
							return "SpearPull"
	return "Jump"

# Override the spear controls with the SpearSpecial control so that certain actions can be done 
# Requires no binds in all of the spear controls (Spear, SpearPull and LetGoOfSpear)
func _custom_control_execution():
	var special_spear_use: InputEvent = InputEventAction.new()
	var new_action: String = _get_control_to_execute()
	
	if new_action != "Jump": 
		special_spear_use.action = new_action
	
	special_spear_use.pressed = true
	Input.parse_input_event(special_spear_use)

func _ready() -> void:
	_update_display_label()
	_change_label_description()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_mouse_used:
		aim_direction = (player.get_global_mouse_position() - player.spear_marker.global_position).normalized()
	else:
		aim_direction = Input.get_vector("Aim Left", "Aim Right", "Aim Up", "Aim Down")
	
	# If in controller mode and right stick isn't used, enable the 45 degree lock
	if not is_mouse_used && aim_direction == Vector2.ZERO:
		aim_direction = Vector2(player.last_input_direction.x,-1).normalized() * crosshair_reach
		player.lockspear45direction = (not is_mouse_used && aim_direction == Vector2.ZERO)
	
	self.global_position = player.spear_marker.global_position + aim_direction
	
	if crosshairs_enabled:
		_set_crosshair_visibility()
		_set_crosshair_position()
	_custom_control_execution()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Debug Hold n Toggle Cycle"):
		match (control_config):
			ControlConfig.HOLD:
				print("Toggle Spear Config")
				control_config = ControlConfig.TOGGLE
			ControlConfig.TOGGLE:
				print("Hold Spear Config")
				control_config = ControlConfig.HOLD
		_update_display_label()
	elif Input.is_action_just_pressed("Debug Controller n Mouse Cycle"):
		is_mouse_used = !is_mouse_used
		match (is_mouse_used):
			true:
				print("Mouse Controls")
			false:
				print("Controller Controls")
		_update_display_label()
	elif Input.is_action_just_pressed("Debug Spear Alt Use Cycle"):
		match (spear_alt_use_config):
			SpearAltUseConfig.RELEASE:
				print("Toggle Spear Config")
				spear_alt_use_config = SpearAltUseConfig.LAUNCH
			SpearAltUseConfig.LAUNCH:
				print("Hold Spear Config")
				spear_alt_use_config = SpearAltUseConfig.RELEASE
		_update_display_label()
	elif Input.is_action_just_pressed("Debug Insta Restart"):
		print("Manually Restarted")
		if player.state_spear.spearInstance != null:
			player.state_spear.spearInstance.Release()
			player.state_spear.spearInstance = null
		player.restartPlayer.emit()
	elif Input.is_action_just_pressed("Debug Toggle Controls Labels"):
		control_labels_enabled = !control_labels_enabled
		_change_label_description()
	elif Input.is_action_just_pressed("Debug Toggle Debug Items"):
		debug_labels_enabled = !debug_labels_enabled
		_change_label_description()
	elif Input.is_action_just_pressed("Debug Toggle Crosshairs"):
		crosshairs_enabled = !crosshairs_enabled
		_set_crosshair_visibility()

func _update_display_label():
	if controls_label.visible:
		controls_label.text = ""
		# Apply Debug mode line for players to read off for forum
		if debug_labels_enabled:
			match (spear_alt_use_config):
				SpearAltUseConfig.RELEASE:
					controls_label.text += "MODE: SR-"
				SpearAltUseConfig.LAUNCH:
					controls_label.text += "MODE: SL-"
			match (control_config):
				ControlConfig.TOGGLE:
					controls_label.text += "BT-"
				ControlConfig.HOLD:
					controls_label.text += "BH-"
			match (is_mouse_used):
				true:
					controls_label.text += "CM\n"
				false:
					controls_label.text += "CX\n"
		match (is_mouse_used):
			true:
				controls_label.text += "Mouse and Keyboard:\nA/D - Move\nSpace - Jump\nCtrl/S - Slide\nMouse - Aim\n"
				match (spear_alt_use_config):
					SpearAltUseConfig.RELEASE:
						controls_label.text += "L Mouse - Use/Release Spear\nR Mouse - Launch from Swing"
					SpearAltUseConfig.LAUNCH:
						controls_label.text += "L Mouse - Use Spear/Launch from Swing\nR Mouse - Release Spear"
			false:
				controls_label.text += "XBox Gamepad:\nL Stick - Move\nR Stick - Aim\nA/LB - Jump\nX/LT - Slide\n"
				match (spear_alt_use_config):
					SpearAltUseConfig.RELEASE:
						controls_label.text += "B/RB - Use/Release Spear\nY/RT - Launch from Swing"
					SpearAltUseConfig.LAUNCH:
						controls_label.text += "B/RB - Use Spear/Launch from Swing\nY/RT - Release Spear"

func _change_label_description():
	controls_label.visible = control_labels_enabled
	debug_label.visible = control_labels_enabled
	
	_update_display_label()
	if control_labels_enabled && debug_labels_enabled:
		debug_label.text = "Toggles:\nI key - Spear controls\nO key - Hold/Toggle\nP key - Controller/MnK\nK key - Crosshairs Display\nL key - Control Display\n\\ key - Debug Labels\n\nR key - Restart room"
	elif control_labels_enabled:
		debug_label.text = "K key - Show/Hide Crosshairs\nL key - Show/Hide Controls\nR key - Restart room"
