class_name StateDoubleJump
extends State
@onready var player = $"../.." 
# This state can transition to: Dash, Fall
# This state happens if we press the Double Jump button.

func EnterState() -> void:
	player.double_jump_available = false
	player.velocity.y = -player.double_jump_height # Apply jump velocity
	if player.debug_mode:
		print("Debug: Double Jump State")
	player.animation_player.play("DoubleJump")

func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	# Move the player left and right if pressed
	player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.air_acceleration * delta)
	
	# Set to fall state if we hit the roof of a collision
	if player.is_on_ceiling():
		player.finite_state_machine.ChangeState(player.state_fall)
		
	if player.animation_end:
		if player.finite_state_machine.can_we_glide():
			player.finite_state_machine.ChangeState(player.state_glide)
			return
		else:
			player.finite_state_machine.ChangeState(player.state_fall)
			return
	# Change to Wall Climb state
	if player.finite_state_machine.can_we_wall_climb():
		player.finite_state_machine.ChangeState(player.state_wall_climb)
		return


func Inputs(event):
	var just_pressed = event.is_pressed() && !event.is_echo()
	# Change to Dash state
	if player.finite_state_machine.can_we_dash(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_dash)
		return
	# Change to Wall Jump State
	if player.finite_state_machine.can_we_wall_jump(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_wall_jump)
		return


func ExitState() -> void:
	pass
