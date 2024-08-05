class_name StateFall
extends State
@onready var player = $"../.."
# This state can transition to: Land, Glide, Dash, Jump, Double Jump
# This state happens if we are not grounded.
func EnterState() -> void:
	if player.debug_mode:
		print("Debug: Fall State")
	if player.finite_state_machine.previous_state == player.state_claw:
		player.animation_player.play("Jump")
	else:
		player.animation_player.play("Fall")

func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	player.animation_player.play("Fall")
	if player.finite_state_machine.previous_state == player.state_claw:
		pass
	else:
		if player.input_axis != Vector2.ZERO:
			if !player.state_jump.bunnyhop:
				player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.air_acceleration * delta)
	# Jump buffer 
	if player.finite_state_machine.jump_buffer_jump():
		return
	# Change to Ledge Climb State
	if player.finite_state_machine.can_we_ledge_climb():
		player.finite_state_machine.ChangeState(player.state_ledge_climb)
		return
	# Change to Land state
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_land)
		return
	# Change to Glide state 
	if player.finite_state_machine.can_we_glide():
		player.finite_state_machine.ChangeState(player.state_glide)
		return
	# Change to Wall Climb state
	if player.finite_state_machine.can_we_wall_climb():
		player.finite_state_machine.ChangeState(player.state_wall_climb)
		return
	# Change to Wall Slide state
	if player.finite_state_machine.can_we_wall_slide():
		player.finite_state_machine.ChangeState(player.state_wall_slide)
		return


func Inputs(event):
	if Input.is_action_just_pressed("Claw"):
		player.finite_state_machine.ChangeState(player.state_claw)
	var just_pressed = event.is_pressed() && !event.is_echo()	
	# Jump buffer Check
	if player.finite_state_machine.jump_buffer_check(event) && just_pressed:
		player.jump_buffer = true
		player.jump_buffer_timer.start()
	# Change to Dash state
	if player.finite_state_machine.can_we_dash(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_dash)
	# Change to Wall Jump State
	if player.finite_state_machine.can_we_wall_jump(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_wall_jump)
		return
	# Change to Jump state
	if player.finite_state_machine.can_we_jump(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_jump)
		return
	# Change to Double Jump state
	if player.finite_state_machine.can_we_double_jump(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_double_jump)
		return

func ExitState() -> void:
	pass

