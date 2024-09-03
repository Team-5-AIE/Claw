extends Node2D

enum ControlConfig {HOLD, TOGGLE}

@export var control_config: ControlConfig = ControlConfig.TOGGLE
@export var crosshair_reach: float = 50
@export var aim_crosshair_delay_time: float = 0.1

var aim_direction: Vector2
var aim_time: float = 0.1
var aim_timer: float = 0
var spear_used: bool = false
var is_mouse_used: bool = false

@onready var player = $"../.." as SWPlatformerCharacter
@onready var aim_visual = $AimPoint as Sprite2D
@onready var throw_visual = $AimCrosshair as Sprite2D
@onready var swing_visual = $SwingPoint as Sprite2D
@onready var launch_visual = $SwingCrosshair as Sprite2D

func _set_crosshair_visibility():
	if player.finite_state_machine.state == player.state_spear:
		aim_visual.visible = false
		throw_visual.visible = false
		launch_visual.visible = true
		swing_visual.visible = true
	elif control_config == ControlConfig.TOGGLE || is_mouse_used:
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
	
	var spear_direction = (aim_visual.position - player.velocity * aim_crosshair_delay_time).normalized()
	throw_visual.position = spear_direction * crosshair_reach
	
	if player.finite_state_machine.state == player.state_spear:
		var spearToPlayer = player.spear_marker.global_position - player.state_spear.spearInstance.global_position
		var launch_velocity = player.velocity * (1.0 - player.state_spear.pullJumpStopFraction) - spearToPlayer.normalized() * player.state_spear.pullJumpStrength
		
		launch_visual.position = player.velocity.normalized() * crosshair_reach
		swing_visual.position = launch_velocity.normalized() * crosshair_reach

#func _display_label():
	#match (control_config):
			#ControlConfig.TOGGLE:
				#$"../../../CanvasLayer/ExitLabel".text = "TOGGLE (Press P to switch configs)\nLeft Stick - Move\nRight Stick - Aim Spear\nB/RB - Shoot/Pull Spear\nA/LB - Jump\nX - Slide"
			#ControlConfig.HOLD:
				#$"../../../CanvasLayer/ExitLabel".text = "HOLD (Press P to switch configs)\nLeft Stick - Move\nRight Stick - Shoot/pull Spear\nA/LB - Jump\nX - Slide"

func _held_joystick_config(delta: float):
	if aim_direction != Vector2.ZERO || Input.is_action_pressed("Spear"):
		if player.finite_state_machine.state == player.state_spear:
			aim_timer = 0
		else:
			aim_timer += delta
			if aim_timer >= aim_time && not spear_used && player.spearCooldownTimer.time_left <= 0:
					aim_timer = 0
					player.finite_state_machine.ChangeState(player.state_spear)
					spear_used = true
	else:
		aim_timer = 0
		spear_used = false
		
		if player.finite_state_machine.state == player.state_spear:
			var spearToPlayer = player.spear_marker.global_position - player.state_spear.spearInstance.global_position
			
			player.state_spear.audio_stream_player.stream = player.state_spear.PULLJUMP
			player.state_spear.audio_stream_player.play()
			player.state_spear.spearInstance.pullReleased = true
			player.velocity *= (1.0 - player.state_spear.pullJumpStopFraction)
			player.velocity += -spearToPlayer.normalized() * player.state_spear.pullJumpStrength

#func _ready() -> void:
	#_display_label()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	aim_direction = Input.get_vector("Aim Left", "Aim Right", "Aim Up", "Aim Down")
	
	_set_crosshair_visibility()
	_set_crosshair_position(delta)

	
	if control_config == ControlConfig.HOLD:
		_held_joystick_config(delta)
	elif control_config == ControlConfig.TOGGLE && !is_mouse_used:
		if aim_direction == Vector2.ZERO:
			player.lockspear45direction = true
		else:
			player.lockspear45direction = false
	
	#if Input.is_action_just_pressed("Debug Toggle"):
		#match (control_config):
			#ControlConfig.HOLD:
				#control_config = ControlConfig.TOGGLE
			#ControlConfig.TOGGLE:
				#control_config = ControlConfig.HOLD
		#_display_label()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if aim_direction == Vector2.ZERO:
			is_mouse_used = true
		else:
			is_mouse_used = false
