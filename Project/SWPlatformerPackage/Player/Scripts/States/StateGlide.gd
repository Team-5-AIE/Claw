class_name StateGlide
extends State
@onready var player = $"../.."
# This state can transition to: Fall, Dash, Jump, Double Jump
# This state happens if we are not grounded and hold the glide button.

func EnterState() -> void:
	player.current_gravity = player.glide_gravity
	player.current_max_gravity = player.max_glide_gravity
	player.velocity.y = 0
	if player.debug_mode:
		print("Debug: Glide State")
	player.animation_player.play("Glide")
	

func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	player.velocity.x = move_toward(player.velocity.x, player.glide_speed * player.input_axis.x, player.glide_acceleration * delta)
	
	
	# Change to Fall state
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_land)
		return
	# Change to Wall Climb state
	if player.finite_state_machine.can_we_wall_climb():
		player.finite_state_machine.ChangeState(player.state_wall_climb)
		return
	

func Inputs(event):
	var just_pressed = event.is_pressed() && !event.is_echo()
	# Change to Fall state
	if !Input.is_key_pressed(player.key_glide):
		player.finite_state_machine.ChangeState(player.state_fall)
		return 
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
	player.current_gravity = player.gravity_speed
	player.current_max_gravity = player.max_gravity
	

