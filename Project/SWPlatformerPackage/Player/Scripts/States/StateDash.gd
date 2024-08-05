class_name StateDash
extends State
@onready var player = $"../.."
var dash_direction : Vector2 = Vector2.ZERO
var prev_velocity
var start_dash_direction : Vector2 = Vector2.ZERO
# This state can transition to: Idle, Double Jump, Jump
# This state happens if we are holding the Crouch key but there is no movement input.

func EnterState() -> void:
	player.current_dashes -= 1
	if player.current_dashes == 0:
		player.dash_available = false
	player.finite_state_machine.air_resistance_lock = true
	player.finite_state_machine.disable_gravity = true
	player.finite_state_machine.friction_lock = true
	player.move_lock = true
	dash_direction = player.input_axis
	start_dash_direction = player.input_axis
	player.finite_state_machine.sprite_flip_lock = true
	player.dash_timer.start()
	if player.debug_mode:
		print("Debug: Dash State")
	player.animation_player.play("Dash")


func UpdatePhysics(delta) -> void: # Runs in _physics_process()
	Dash(delta)
	# Set to fall state if we hit the roof of a collision
	if player.is_on_ceiling():
		player.finite_state_machine.ChangeState(player.state_fall)
	# Have we finished dashing?
	if player.dash_timer.time_left <= 0.0:
		# Are we on the ground?
		if player.is_on_floor():
			# Change to Idle State
			player.finite_state_machine.ChangeState(player.state_idle)
			return
		else:
			# Change to Glide state 
			if player.finite_state_machine.can_we_glide():
				player.finite_state_machine.ChangeState(player.state_glide)
				return
			else:
				# Change to Fall State
				player.finite_state_machine.ChangeState(player.state_fall)
				return
	# Change to Wall Climb state
	if player.finite_state_machine.get_next_to_wall() != Vector2.ZERO:
		if player.wall_climb_enabled && !player.move_lock:
			if player.finite_state_machine.wall_grab_input:
				if player.finite_state_machine.can_grab_wall || player.wall_grab_stamina.time_left > 0.0:
					player.finite_state_machine.ChangeState(player.state_wall_climb)
					return

func Inputs(event):
	# Check if we have pressed the jump key during dash
	if Input.is_action_just_pressed("Jump") && player.wall_jump_enabled && player.wall_jump_available:
		if player.finite_state_machine.can_we_wall_jump(event):
			player.finite_state_machine.ChangeState(player.state_wall_jump)
			return
	if Input.is_action_just_pressed("Jump") && player.jump_enabled:
		if player.coyote_jump_timer.time_left > 0.0 || player.is_on_floor() || player.can_always_jump:
			PressedJumpWhileDashing()
			return
	if Input.is_action_just_pressed("Jump") && player.double_jump_enabled:
		PressedDoubleJumpWhileDashing()
		return

func ExitState() -> void:
	player.dash_cooldown.start()
	player.finite_state_machine.sprite_flip_lock = false
	player.finite_state_machine.disable_gravity = false
	player.move_lock = false
	player.finite_state_machine.air_resistance_lock = false
	player.finite_state_machine.friction_lock = false
	if player.exit_dash_forced_gravity_enabled:
		if dash_direction == Vector2(1,-1) || dash_direction == Vector2(-1,-1) || dash_direction == Vector2(0,-1):
			player.velocity.y = dash_direction.normalized().y * -player.exit_dash_forced_gravity_multipler
	pass

func Dash(delta) -> void:
	if player.dash_timer.time_left >= player.dash_time - 0.15:
		#Implement Dash
		if dash_direction != Vector2.ZERO:
			# Left/Right
			if player.finite_state_machine.get_bottom_to_wall() == Vector2.ZERO:
				player.velocity.y = dash_direction.normalized().y * player.dash_speed
			
			# Up/Down
			if dash_direction == Vector2(0,-1):
				player.velocity.y = dash_direction.normalized().y * player.dash_speed*0.8
				print("up dash")
			if dash_direction == Vector2(0,1): 
				player.velocity.y = dash_direction.normalized().y * player.dash_speed
				print("down dash")
			
			 # Diagonal Up Left/Right
			if dash_direction == Vector2(1,-1) || dash_direction == Vector2(-1,-1):
				player.velocity.y = dash_direction.normalized().y * player.dash_speed
			
			# Diagonal Down Right
			if dash_direction == Vector2(1,1) : 
				if player.is_on_floor() && player.finite_state_machine.get_bottom_to_wall() == Vector2.ZERO:
					dash_direction = Vector2(1,0)
				else: player.velocity.y = dash_direction.normalized().y * player.dash_speed
			
			# Diagonal Down Left
			if dash_direction == Vector2(-1,1): 
				if player.is_on_floor() && player.finite_state_machine.get_bottom_to_wall() == Vector2.ZERO: 
					dash_direction = Vector2(-1,0)
				else: player.velocity.y = dash_direction.normalized().y * player.dash_speed
			
			player.velocity.x = dash_direction.normalized().x * player.dash_speed
		else:
			if player.sprite_sheet.flip_h == true:
				dash_direction = Vector2(-1,0)
			elif  player.sprite_sheet.flip_h == false:
				dash_direction = Vector2(1,0)
			player.velocity = dash_direction.normalized() * player.dash_speed
	else:
		player.finite_state_machine.disable_gravity = false
		player.finite_state_machine.sprite_flip_lock = false
		player.move_lock = false
		player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.dash_acceleration * delta)

func PressedJumpWhileDashing() -> void:
	if player.is_on_floor() && player.wave_dash_enabled: 
		print(str(player.dash_timer.time_left) + "|" + str(player.dash_time - player.wave_dash_enabled_time_window))
		if player.dash_timer.time_left >= player.dash_time - player.wave_dash_enabled_time_window:
			if start_dash_direction == Vector2(-1,1) || start_dash_direction == Vector2(1,1):
				if !player.jump_available:
					print("reset dash")
					player.finite_state_machine.reset_grounded_variables()
					player.finite_state_machine.ChangeState(player.state_jump)
					return
	if player.jump_available:
		print("normal jump from dash")
		player.finite_state_machine.ChangeState(player.state_jump)
		return

func PressedDoubleJumpWhileDashing() -> void:
	player.finite_state_machine.ChangeState(player.state_double_jump)
	return
