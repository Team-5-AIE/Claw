class_name StateIdle
extends State
@onready var player = $"../.."
# This state can transition to: Move, Fall, Slide, Jump, Crouch and Dash.
# This is also the default state.
# This state happens if we are grounded and there is no input.

func EnterState() -> void:
	player.finite_state_machine.reset_grounded_variables()
	player.wall_grab_stamina.stop()
	if player.debug_mode:
		print("Debug: Idle State")
	player.animation_player.play("Idle")

func UpdatePhysics(_delta)-> void:  # Runs in _physics_process()
	# Change to Fall state
	if !player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_fall)
		return
	# Change to Move state
	if player.input_axis.x != 0:
		player.finite_state_machine.ChangeState(player.state_move)
		return

func Inputs(event):
	if Input.is_action_just_pressed("Claw") && player.spearCooldownTimer.time_left <= 0.0:
		player.finite_state_machine.ChangeState(player.state_claw)
	var just_pressed = event.is_pressed() && !event.is_echo()
	# Change to Slide state !!Important: This must be BEFORE Jump state.
	if player.finite_state_machine.can_we_slide(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_slide)
		return
	# Change to Jump state !!Important: This must be AFTER Slide state.
	if player.finite_state_machine.can_we_jump(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_jump)
		return
	# Change to Crouch state
	if player.finite_state_machine.can_we_crouch(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_crouch)
		return
	# Change to Dash state
	if player.finite_state_machine.can_we_dash(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_dash)
		return
	

func ExitState() -> void:
	pass

