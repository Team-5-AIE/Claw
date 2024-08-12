class_name StateLand
extends State
@onready var player = $"../.."
# This state can transition to: Land, Glide, Dash, Jump, Double Jump
# This state happens when we have just become grounded.

func EnterState() -> void:
	player.finite_state_machine.reset_grounded_variables()
	player.wall_grab_stamina.stop()
	if player.debug_mode:
		print("Debug: Land State")
	player.animation_player.play("Land")
	
func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.acceleration * delta)
	# Change state to Idle
	if player.animation_end:
		player.finite_state_machine.ChangeState(player.state_idle)
		return
	# Change to Move state
	if player.input_axis.x != 0:
		player.finite_state_machine.ChangeState(player.state_move)
		return

func Inputs(event):
	if Input.is_action_just_pressed("Claw") && player.spearCooldownTimer.time_left <= 0.0:
		player.finite_state_machine.ChangeState(player.state_claw)
	var just_pressed = event.is_pressed() && !event.is_echo()
	# Change to Slide state - !!Important: This must be before Jump state.
	if player.finite_state_machine.can_we_slide(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_slide)
		return
	# Change to Jump state
	if player.finite_state_machine.can_we_jump(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_jump)
		return
	# Change to Dash state
	if player.finite_state_machine.can_we_dash(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_dash)
		return
	# Change to Crouch state
	if player.finite_state_machine.can_we_crouch(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_crouch)
		return

func ExitState() -> void:
	pass
