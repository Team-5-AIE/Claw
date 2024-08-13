class_name StateFall
extends State
@onready var player = $"../.."
# This state can transition to: Land, Jump, 
# This state happens if we are not grounded.
func EnterState() -> void:
	if player.debug_mode:
		print("Debug: Fall State")
	if player.finite_state_machine.previous_state == player.state_claw:
		player.animation_player.play("Jump")
	else:
		player.animation_player.play("Fall")

func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	player.animation_player.play("Fall") #NOTE: not needed? need test
	if player.finite_state_machine.previous_state == player.state_claw:
		#NOTE: below stops momentum when holding - check only if holding oposite direction of
		#current velocity
		if player.input_axis.x != sign(player.velocity.x):
			player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.air_acceleration * delta)
	else:
		if player.input_axis != Vector2.ZERO:
			if !player.state_jump.bunnyhop:
				player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.air_acceleration * delta)
	
	# Jump buffer #NOTE: why is this here?
	if player.finite_state_machine.jump_buffer_jump():
		return
	
	# Change to Land state
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_land)
		return

	# Change to Wall Climb state
	if player.finite_state_machine.can_we_wall_climb():
		player.finite_state_machine.ChangeState(player.state_wall_climb)
		return
	
	# Change to Wall Slide state
	if player.finite_state_machine.can_we_wall_slide():
		player.finite_state_machine.ChangeState(player.state_wall_slide)
		return


func Inputs(_event):
	# Change to Spear Throw state
	if player.finite_state_machine.can_we_throw_spear():
		player.finite_state_machine.ChangeState(player.state_claw)
		return
	
	# Jump buffer Check
	if player.finite_state_machine.jump_buffer_check():
		player.jump_buffer = true
		player.jump_buffer_timer.start()
	
	# Change to Wall Jump State
	if player.finite_state_machine.can_we_wall_jump():
		player.finite_state_machine.ChangeState(player.state_wall_jump)
		return
	
	# Change to Jump state
	if player.finite_state_machine.can_we_jump():
		player.finite_state_machine.ChangeState(player.state_jump)
		return

func ExitState() -> void:
	pass

