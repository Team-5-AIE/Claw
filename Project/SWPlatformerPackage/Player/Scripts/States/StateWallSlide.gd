class_name StateWallSlide
extends State
@onready var player = $"../.."

func EnterState() -> void:
	player.wall_grab_stamina.paused = false
	if player.debug_mode:
		print("Debug: Wall Slide State")
	if player.finite_state_machine.get_next_to_wall() == Vector2.RIGHT:
		player.sprite_sheet.flip_h = true
	elif player.finite_state_machine.get_next_to_wall() == Vector2.LEFT:
		player.sprite_sheet.flip_h = false
	player.finite_state_machine.sprite_flip_lock = true
	player.animation_player.play("WallSlide")
	
func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	player.animation_player.play("WallSlide")
	if player.wall_grab_stamina.time_left <= 0.0 && !player.finite_state_machine.can_grab_wall:
		player.finite_state_machine.ChangeState(player.state_fall)
		return
	player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.acceleration * delta)
	# Change to Ledge Climb State
	if player.finite_state_machine.can_we_ledge_climb():
		player.finite_state_machine.ChangeState(player.state_ledge_climb)
		return
	# Change to Land state
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_land)
		return
	# Change to Fall state 
	if player.finite_state_machine.get_next_to_wall() == Vector2.ZERO:
		player.finite_state_machine.ChangeState(player.state_fall)
		return
	if !player.finite_state_machine.wall_grab_input && !player.finite_state_machine.wall_jump_input:
		player.finite_state_machine.ChangeState(player.state_fall)
		return
	# Change to Wall Climb state 
	if player.finite_state_machine.wall_grab_input && player.finite_state_machine.wall_jump_input:
		if player.wall_climb_enabled:
			player.finite_state_machine.ChangeState(player.state_wall_climb)
			return
	# Slide character faster down if pressing down key
	if !player.input_axis.y > 0:
		player.velocity.y *= player.wall_slide_friction

func Inputs(event) -> void:  # Runs in _process()
	var just_pressed = event.is_pressed() && !event.is_echo()
	# Change to Dash State
	if player.finite_state_machine.can_we_dash(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_dash)
		return
	# Change to Wall Jump State
	if player.finite_state_machine.can_we_wall_jump(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_wall_jump)
		return

func ExitState() -> void:
	player.finite_state_machine.sprite_flip_lock = false
	player.wall_grab_stamina.paused = true

