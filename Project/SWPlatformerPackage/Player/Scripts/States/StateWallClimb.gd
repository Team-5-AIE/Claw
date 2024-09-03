class_name StateWallClimb
extends State
@onready var player = $"../.."
func EnterState() -> void:
	player.wall_grab_stamina.paused = false
	if player.debug_mode:
		print("Debug: Wall Climb State")
		
	# Start Grab stamina timer if enabled
	if player.wall_grab_stamina_enabled:
		if player.wall_grab_stamina.time_left <= 0.0 && player.finite_state_machine.can_grab_wall:
			player.wall_grab_stamina.start()
			player.finite_state_machine.can_grab_wall = false
			
	# Set up for climb
	player.finite_state_machine.disable_gravity = true
	if player.finite_state_machine.get_next_to_wall() == Vector2.RIGHT:
		player.sprite_sheet.flip_h = true
	elif player.finite_state_machine.get_next_to_wall() == Vector2.LEFT:
		player.sprite_sheet.flip_h = false
	player.finite_state_machine.sprite_flip_lock = true
	player.animation_player.play("WallHold")
	
func UpdatePhysics(_delta)-> void:  # Runs in _physics_process()

	# Apply Climb velocity
	climb_movement() 
	player.velocity.y += player.climb_resistance
	
	# Change to State Land
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_land)
		return
	
	# Change to State Fall
	if player.wall_grab_stamina.time_left <= 0.0 && !player.finite_state_machine.can_grab_wall:
		# Ran out of stamina, fall
		player.finite_state_machine.ChangeState(player.state_fall)
		return
	
	if player.finite_state_machine.get_next_to_wall() == Vector2.ZERO:
		player.finite_state_machine.ChangeState(player.state_fall)
		return
	
	if !player.finite_state_machine.wall_grab_input && !player.wall_slide_enabled:
		player.finite_state_machine.ChangeState(player.state_fall)
	
	# Change to State Wall Slide
	if !player.finite_state_machine.wall_grab_input:
		if player.wall_slide_enabled:
			player.finite_state_machine.ChangeState(player.state_wall_slide)
			return

func Inputs(_event) -> void:  # Runs in _process()
	# Change to Spear Throw state
	if player.finite_state_machine.can_we_throw_spear():
		player.finite_state_machine.ChangeState(player.state_claw)
		return
	
	# Change to Wall Jump State
	if player.finite_state_machine.can_we_wall_jump():
		player.finite_state_machine.ChangeState(player.state_wall_jump)
		return

func ExitState() -> void:
	player.finite_state_machine.sprite_flip_lock = false
	player.finite_state_machine.disable_gravity = false
	player.wall_grab_stamina.paused = true

func climb_movement() -> void:
	if player.finite_state_machine.wall_climb_input:
		# Move up
		if player.input_axis.y < 0:
			player.finite_state_machine.disable_gravity = true
			player.velocity.y = -player.wall_climb_up_speed
			player.animation_player.play("WallClimb")
			player.animation_player.speed_scale = 1
		# Move Down
		elif player.input_axis.y > 0:
			player.finite_state_machine.disable_gravity = false
			player.velocity.y *= player.wall_climb_friction
			if player.animation_player.current_animation == "WallClimb" || player.animation_player.current_animation == "WallHold":
				player.animation_player.stop()
				player.animation_player.play("WallClimb")
				player.animation_player.speed_scale = 0

	else:
		player.finite_state_machine.disable_gravity = true
		player.velocity.y = 0
		player.animation_player.play("WallHold")
