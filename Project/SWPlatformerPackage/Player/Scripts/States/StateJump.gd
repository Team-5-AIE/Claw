class_name StateJump
extends State
@onready var player = $"../.."
var prev_velocity
var dir
var half_jump = false
# This state can transition to: Double jump, Dash, Fall.
# This state happens if we have pressed the Jump key.

func EnterState() -> void:
	half_jump = false
	player.jump_available = false
	player.velocity.y = -player.jump_height # Apply jump velocity
	prev_velocity = player.velocity
	dir = player.velocity
	if player.debug_mode:
		print("Debug: Jump State")
	player.animation_player.play("Jump")

func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	if dir.x > 0 && prev_velocity.x > 0:
		prev_velocity.x -= dir.normalized().x*6
	if dir.x < 0 && prev_velocity.x < 0:
		prev_velocity.x -= dir.normalized().x*6
	if prev_velocity.y < 0:
		prev_velocity.y += 14

	# Set to fall state if we hit the roof of a collision
	if player.is_on_ceiling():
		player.finite_state_machine.ChangeState(player.state_fall)
	# Are we in the air and finished jumping?
	if !player.is_on_floor() && player.velocity.y >= 0:
		# Can we glide?
		if player.finite_state_machine.can_we_glide():
			# Change to Glide state
			player.finite_state_machine.ChangeState(player.state_glide)
			return
		else:
			# Change to Fall state
			player.finite_state_machine.ChangeState(player.state_fall)
			return
	# Change to Wall Climb state
	if player.finite_state_machine.can_we_wall_climb():
		player.finite_state_machine.ChangeState(player.state_wall_climb)
		return
	# Change to Idle state
	if player.is_on_floor() && player.animation_end:
		player.velocity.y = 0
		player.finite_state_machine.ChangeState(player.state_idle)
		return
		
	# Move the player left and right if pressed
	if player.finite_state_machine.previous_state == player.state_dash:
		if player.input_axis.x == 0 || player.input_axis.x == -1 && dir.x < 0 || player.input_axis.x == 1 && dir.x > 0:
			if !half_jump:
				print("retain vel")
				player.velocity.x = move_toward(player.velocity.x, prev_velocity.x, player.air_acceleration * delta)
				player.velocity.y = move_toward(player.velocity.y, prev_velocity.y, player.air_acceleration * delta)
				return
	print("normal vel")
	player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.air_acceleration * delta)

func Inputs(event):
	var just_pressed = event.is_pressed() && !event.is_echo()
	
	# Variable Jump
	if event is InputEventKey and not event.pressed:
		if event.keycode == player.key_jump && player.velocity.y < -player.jump_height/2 && !player.is_on_floor():
			player.velocity.y = -player.jump_height/2
			half_jump = true
	
	# Change to Wall Jump State
	if player.finite_state_machine.can_we_wall_jump(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_wall_jump)
		return
	# Change to Double Jump state
	if player.finite_state_machine.can_we_double_jump(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_double_jump)
		return
	# Change to Dash state
	if player.finite_state_machine.can_we_dash(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_dash)
		return


func ExitState() -> void:
	pass
